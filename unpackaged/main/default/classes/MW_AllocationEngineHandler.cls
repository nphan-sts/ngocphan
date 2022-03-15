/**
 * Created by ilazarte on 1/12/22.
 *
 * A note on logging:
 * Historically CLS code logs to loan batch process logs for failures.
 * Also, it typically logs cl common logs for application specific or ui reasons
 * Finally, use the log utility for non error scenarios
 *
 * Can invoke synchronously as well, in order to be invoked from Batch jobs
 *
 * Futures documentation
 * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_async_overview.htm
 *
 * Try to keep requests bulkified
 * https://developer.salesforce.com/docs/atlas.en-us.224.0.apexcode.meta/apexcode/apex_gov_limits.htm
 */

public with sharing class MW_AllocationEngineHandler {

    private static final Integer NO_RESPONSE = -1;

    @TestVisible
    private static final String HAPPY_MONEY_OKTA_SERVICE_NAME = 'Happy Money Okta';

    /**
     * These constants:
     * advp,reallocation,manual,final,cancel
     * are decision levels, and used to control json generation behavior and queries.
     * They are also used in the final url to callout.
     */

    @TestVisible
    private static final String ADVP = 'advp';

    @TestVisible
    private static final String REALLOCATION = 'reallocation';

    @TestVisible
    private static final String MANUAL = 'manual';

    @TestVisible
    private static final String FINALIZED = 'final';

    @TestVisible
    private static final String CANCELLED = 'cancel';

    private static final Integer CALLOUT_TIMEOUT_IN_SECONDS = 5 * 1000;

    private static final Integer RESPONSE_CATEGORY_5XX = 5;

    private static final Integer RESPONSE_CATEGORY_4XX = 4;

    private static final Integer RESPONSE_CATEGORY_2XX = 2;

    private static final String LOG_NAME = 'MW_AllocationEngineHandler';

    private static final Integer MAX_RETRY =  5;

    private static final Set<String> DECISION_LEVELS = new Set<String> {
        ADVP, REALLOCATION, MANUAL, FINALIZED, CANCELLED
    };

    private static final Set<String> ALLOCATION_DECISION_LEVELS = new Set<String> {
        ADVP, REALLOCATION, MANUAL
    };

    private static final Set<String> DEPLOYMENT_MODES = new Set<String> {
            'LEGACY_MODE', 'DARK_MODE', 'FULL_MODE'
    };

    /**
     * Dark mode is either legacy-mode, dark-mode, and full-mode.
     * The rules api should be active when either legacy, dark, or blank.
     * @return Should the rules api be executed
     */
    public static Boolean isRulesApiEnabled() {
        return 'LEGACY_MODE' == MW_Settings__c.getOrgDefaults().Allocation_Engine_Deployment_Mode__c ||
                'DARK_MODE' == MW_Settings__c.getOrgDefaults().Allocation_Engine_Deployment_Mode__c ||
                !DEPLOYMENT_MODES.contains(MW_Settings__c.getOrgDefaults().Allocation_Engine_Deployment_Mode__c);
    }

    /**
     * Only run if dark mode or full mode is engaged
     * @return Should the AES callout be executed
     */
    public static Boolean isAllocationEngineServiceEnabled() {
        return 'DARK_MODE' == MW_Settings__c.getOrgDefaults().Allocation_Engine_Deployment_Mode__c ||
                'FULL_MODE' == MW_Settings__c.getOrgDefaults().Allocation_Engine_Deployment_Mode__c;
    }

    public static void handleAdvp(List<Id> appIds) {
        /* app somehow has is back at advp, reallocate */
        List<Id> hasAllocationIds = filterByAllocationIds(appIds, true);
        if (!hasAllocationIds.isEmpty()) {
            handle(hasAllocationIds, null, REALLOCATION);
        }

        handle(appIds, null, ADVP);
    }

    public static void handleReallocation(List<Id> appIds) {
        /* app is asked to rellocate, but no allocation id is present */
        List<Id> noAllocationIds = filterByAllocationIds(appIds, false);
        if (!noAllocationIds.isEmpty()) {
            handle(noAllocationIds, null, ADVP);
        }

        handle(appIds, null, REALLOCATION);
    }

    public static void handleManual(List<Id> appIds, List<Id> manualPartnerIds) {
        /* app is asked to rellocate, but no allocation id is present */
        List<Id> noAllocationIds = filterByAllocationIds(appIds, false);
        if (!noAllocationIds.isEmpty()) {
            handle(noAllocationIds, null, ADVP);
        }

        handle(appIds, manualPartnerIds, MANUAL);
    }

    public static void handleCancelled(List<Id> appIds) {
        handle(appIds, null, CANCELLED);
    }

    public static void handleFinal(List<Id> appIds) {
        handle(appIds, null, FINALIZED);
    }

    private class CalloutResult {
        private HttpResponse response { get; set; }
        private Integer responseCategory { get; set; }
        private List<String> messages { get; set; }
        private String finalMessage {
            get {
                return String.join(messages, '; ');
            }
        }
    }

    /**
     * The public entry point for communicating with allocation engine.
     * Internally will log and execute retries up until the maximum amount.
     *
     * @param appIds The list of app ids to consider
     * @param manualPartnerIds The list of allocation partners
     * @param decisionLevel The allocation type to send
     * @param useFuture Whether to execute in future or not
     */
    private static void handle(List<Id> appIds, List<Id> manualPartnerIds, String decisionLevel, Boolean useFuture) {

        final String logMethodName = 'handle';

        if (appIds == null || appIds.isEmpty()) {
            MW_LogUtility.warnMessage(LOG_NAME, logMethodName, 'Allocation Engine Handler called with null or 0 app ids');
            return;
        }

        if (!DECISION_LEVELS.contains(decisionLevel)) {
            handleInvalidDecisionLevel(logMethodName, appIds, decisionLevel);
            return;
        }

        List<Id> validAppIds;
        String json;

        try {
            validAppIds = validateAndLogApps(appIds, manualPartnerIds, decisionLevel);
            if (validAppIds.isEmpty()) {
                return;
            }

            System.debug(': ' + validAppIds);

            json = toJson(validAppIds, manualPartnerIds, decisionLevel);

        } catch (Exception e) {

            System.debug('Exception: ' + exceptionToStr(e));

            /* if we have valid app ids, then our exception came after that
               else, we should use the original list
             */
            List<Id> logIds = validAppIds != null ? validAppIds : appIds;
            handleExceptionHandler(logMethodName, logIds, decisionLevel, e);
            return;
        }

        if (useFuture) {
            callAllocationEngineServiceFuture(validAppIds, json, decisionLevel);
        } else {
            callAllocationEngineService(validAppIds, json, decisionLevel);
        }
    }

    private static void handle(List<Id> appIds, List<Id> manualPartnerIds, String decisionLevel) {
        handle(appIds, manualPartnerIds, decisionLevel, true);
    }

    /**
     * When a pre-existing application is sent to the allocation engine,
     * we have to inform the model about it's existence if it wasn't allocated by it
     * This method is used to map pre-allocation engine apps into allocations.
     *
     * Mutates source list.
     *
     * @param src Remove any id without a previous allocation id
     * @param hasAllocationIds Filter with allocation ids
     *
     *
     * @return tgt Receive any id without a previous allocation id
     */
    @TestVisible
    private static List<Id> filterByAllocationIds(List<Id> src, Boolean hasAllocationIds) {

        List<Id> res = new List<Id>();
        if (src == null) {
            return res;
        }

        List<genesis__Applications__c> apps = getApplicationsAllocationIds(src);

        /* iterating twice to keep order non surprising.
           There's no it.remove in Apex */

        for (genesis__Applications__c app : apps) {
            if ((app.Allocation_ID__c != null) == hasAllocationIds) {
                res.add(app.Id);
            }
        }

        for (Integer i = src.size() - 1; i > -1; i--) {
            if (res.contains(src.get(i))) {
                src.remove(i);
            }
        }

        return res;
    }

    @TestVisible
    private static void handleInvalidDecisionLevel(String logMethodName, List<Id> appIds, String decisionLevel) {
        final String format = LOG_NAME + ': Invalid decision level of "{0}" attempted';
        String message = String.format(format, new List<String>{ decisionLevel });
        String leadIds = toLeadIdsStr(appIds);

        insertErrorCommonLog(appIds, message + ' for this application');
        insertLoanBatchProcessLog(message + ' for lead ids: ' + leadIds);

        Map<String, String> msg = new Map<String, String>{
                'decisionLevel' => decisionLevel,
                'message' => message,
                'leadIds' => leadIds,
                'error' => 'Invalid decision level'
        };

        MW_LogUtility.errorMessage(LOG_NAME, logMethodName, msg);
    }

    /**
     * It's possible to have attempted an incorrect decision level.
     * Record this in the object.
     *
     * @param logMethodName The invoking method
     * @param appIds Valid app ids to execute the call for
     * @param decisionLevel The attempted decision level
     * @param e The exception received
     */
    @TestVisible
    private static void handleExceptionHandler(String logMethodName, List<Id> appIds, String decisionLevel, Exception e) {
        updateOperationError(appIds, decisionLevel);

        String message = LOG_NAME + ': Failed JSON request generation';
        String leadIds = toLeadIdsStr(appIds);
        String error = exceptionToStr(e);

        String logMsg = String.format('{0}: Exception on lead guids: {1}, during decision level: {2}, caused by: {3}',
                new List<String> {message, leadIds, decisionLevel, error});
        insertLoanBatchProcessLog(logMsg);

        Map<String, String> msg = new Map<String, String>{
                'decisionLevel' => decisionLevel,
                'message' => message,
                'leadIds' => leadIds,
                'error' => error
        };
        MW_LogUtility.errorMessage(LOG_NAME, logMethodName, msg);
    }

    /**
     * Dont send apps which have somehow not moved down the funnel correctly.
     * This is a sanity check to filter out non viable apps per decision level.
     * It returns the valid app ids to proceed with, and logs those which aren't and how they failed.
     *
     * @param appIds Original app id list
     * @param manualPartnerIds Partner ids for manual scenario
     * @param decisionLevel Intended decision level
     *
     * @return filtered list
     */
    private static List<Id> validateAndLogApps(List<Id> appIds, List<Id> manualPartnerIds, String decisionLevel) {

        List<clcommon__Batch_Process_Log__c> logs = new List<clcommon__Batch_Process_Log__c>();
        List<genesis__Applications__c> updateApps = new List<genesis__Applications__c>();

        List<Id> validIds = new List<Id>();

        List<Allocation_Partner__c> previousPartners = getAllocationPartnersByAppIds(appIds);
        List<Allocation_Partner__c> manualPartners = getAllocationPartnersByIds(manualPartnerIds);

        Map<Id, List<Allocation_Partner__c>> appIdPreviousPartners = groupAllocationPartnersByAppId(previousPartners);
        Map<Id, List<Allocation_Partner__c>> appIdToManualPartners = groupAllocationPartnersByAppId(manualPartners);

        for (genesis__Applications__c app : getApplications(appIds, decisionLevel)) {
            List<String> messages = new List<String>();
            if (isAllocationDecisionLevel(decisionLevel)) {
                validateNotNull(app, messages, new List<String>{
                        'genesis__Status__c',
                        'genesis__APR__c',
                        'genesis__Interest_Rate__c',
                        'Pricing_Tier__c',
                        'genesis__Term__c',
                        'FICO__c',
                        'Monthly_DTI__c',
                        'Net_Disposable_Income_NDI_Num__c',
                        'genesis__Loan_Amount__c'
                });

                if (REALLOCATION == decisionLevel || MANUAL == decisionLevel) {

                    validateNotNull(app, messages, new List<String>{
                            'Allocation_ID__c',
                            'Expected_Yield__c',
                            'Expected_Chargeoff__c',
                            'Allocation_Timestamp__c'
                    });

                    List<Allocation_Partner__c> partners = appIdPreviousPartners.get(app.Id);
                    if (partners == null || partners.size() == 0) {
                        messages.add('No previously allocated partners were found');
                    }

                    if (MANUAL == decisionLevel) {
                        List<Allocation_Partner__c> manuals = appIdToManualPartners.get(app.Id);
                        if (manuals == null || manuals.size() == 0) {
                            messages.add('No manually selected partners were found');
                        }
                    }
                }

            } else if (CANCELLED == decisionLevel) {
                validateNotNull(app, messages, new List<String>{
                        'Allocation_ID__c',
                        'genesis__Status__c'
                });
            } else if (FINALIZED == decisionLevel) {
                validateNotNull(app, messages, new List<String>{
                        'Allocation_ID__c'
                });
            }

            if (messages.size() > 0) {
                logs.add(makeCommonBatchProcessLog(app, decisionLevel, messages));
                app.Allocation_Operation_Error__c = decisionLevel;
                updateApps.add(app);
            } else {
                validIds.add(app.Id);
            }
        }

        if (!logs.isEmpty()) {
            insert logs;
        }

        if (!updateApps.isEmpty()) {
            update updateApps;
        }

        return validIds;
    }

    /**
     * @param app App to check
     * @param messages Messages to add if field is null
     * @param fields List of fields to check
     */
    private static void validateNotNull(genesis__Applications__c app, List<String> messages, List<String> fields) {
        Map<String, Object> appMap = app.getPopulatedFieldsAsMap();
        for (String field : fields) {
            if (!appMap.containsKey(field) || appMap.get(field) == null) {
                messages.add(String.format('Field: {0} cannot be null', new List<String> {field}));
            }
        }
    }

    /**
     * This method is public only for testing purposes
     * It doesn't make sense to break out into its own class because it's not a general json generator.
     *
     * @param appIds app ids to query for the json generation
     * @param manualPartnerIds The allocation partner ids to pass to allocation engine if selected
     * @param decisionLevel The string allocation type
     *
     * @return A json string
     */
    @TestVisible
    private static String toJson(List<Id> appIds, List<Id> manualPartnerIds, String decisionLevel) {

        List<Allocation_Partner__c> previousPartners = getAllocationPartnersByAppIds(appIds);
        List<Allocation_Partner__c> manualPartners = getAllocationPartnersByIds(manualPartnerIds);

        Map<Id, List<Allocation_Partner__c>> appIdPreviousPartners = groupAllocationPartnersByAppId(previousPartners);
        Map<Id, List<Allocation_Partner__c>> appIdToManualPartners = groupAllocationPartnersByAppId(manualPartners);

        JSONGenerator json = System.JSON.createGenerator(false);

        json.writeStartObject();
        json.writeStringField('deploymentMode', MW_Settings__c.getOrgDefaults().Allocation_Engine_Deployment_Mode__c);
        json.writeStringField('batchID', new Uuid().getValue());
        json.writeFieldName('allocation-requests');
        json.writeStartArray();

        for (genesis__Applications__c app : getApplications(appIds, decisionLevel)) {

            List<Allocation_Partner__c> appPartners = appIdPreviousPartners.get(app.Id);

            json.writeStartObject();
            json.writeStringField('requestID', app.Lead_ID__c);
            json.writeStringField('leadGuid', app.Lead_ID__c);
            json.writeDateTimeField('timestamp', Datetime.now());

            if (isAllocationDecisionLevel(decisionLevel)) {

                json.writeStringField('lendingState', app.genesis__Status__c);
                json.writeNumberField('APR', app.genesis__APR__c);
                json.writeNumberField('interestRate', app.genesis__Interest_Rate__c);
                json.writeStringField('tier', app.Pricing_Tier__c);
                json.writeNumberField('term', app.genesis__Term__c);
                json.writeNumberField('FICO', app.FICO__c);
                json.writeNumberField('debtToIncome', app.Monthly_DTI__c);
                json.writeNumberField('netDisposableIncome', app.Net_Disposable_Income_NDI_Num__c);
                json.writeStringField('zipCode', app.genesis__Account__r.ZIP_Code__c);

                writeNullableString(json, 'loanPurpose', app.Loan_Purpose__c);

                /*
                 Emulate an eventual array, but CLS only stores a single approval model if anything.
                 */
                if (app.Credit_Policy_Approval_Models__c == null) {
                    json.writeNullField('approvalModels');
                } else {
                    json.writeFieldName('approvalModels');
                    json.writeStartArray();
                    json.writeString(app.Credit_Policy_Approval_Models__c);
                    json.writeEndArray();
                }

                if (REALLOCATION == decisionLevel || MANUAL == decisionLevel) {

                    json.writeStringField('allocationId', app.Allocation_ID__c);
                    json.writeNumberField('expectedYield', app.Expected_Yield__c);
                    json.writeNumberField('expectedChargeoff', app.Expected_Chargeoff__c);
                    json.writeDateTimeField('previousTimestamp', app.Allocation_Timestamp__c);

                    writePartnerArray(json, 'previousInvestor', appPartners);

                    if (MANUAL == decisionLevel) {

                        List<Allocation_Partner__c> manuals = appIdToManualPartners.get(app.Id);
                        writePartnerArray(json, 'manualInvestor', manuals);
                    }
                }

                json.writeFieldName('channel');
                json.writeStartObject();

                writeNullableString(json, 'utmMedium', app.utm_medium__c);
                writeNullableString(json, 'utmSource', app.utm_source__c);
                writeNullableString(json, 'utmCampaign', app.utm_campaign__c);
                writeNullableString(json, 'lastTouchUtmChannelGrouping', app.utm_content__c);

                json.writeEndObject();
                json.writeNumberField('loanAmount', app.genesis__Loan_Amount__c);

            } else if (decisionLevel == CANCELLED) {

                writeNullableString(json, 'allocationId', app.Allocation_ID__c);
                writePartnerArrayWithInvestorFallback(json, 'previousInvestor', app, appPartners);
                json.writeStringField('reason', app.genesis__Status__c);

            } else if (decisionLevel == FINALIZED) {

                writeNullableString(json, 'allocationId', app.Allocation_ID__c);
                writePartnerArrayWithInvestorFallback(json, 'previousInvestor', app, appPartners);
            }
            json.writeEndObject();
        }

        json.writeEndArray();
        json.writeEndObject();

        return json.getAsString();
    }

    /**
     * Write back allocation partners in the event of a reallocation or manual allocation
     * @param json The json request
     * @param fieldName The field name to use
     * @param partners The allocation partners for this request
     */
    private static void writePartnerArray(JSONGenerator json, String fieldName, List<Allocation_Partner__c> partners) {
        json.writeFieldName(fieldName);
        json.writeStartArray();
        for (Allocation_Partner__c partner : partners) {
            json.writeStartObject();
            json.writeStringField('investorCode', partner.Investor__r.Investor_Code__c);
            writeNullableBoolean(json, 'leadPartner', partner.Lead_Partner__c);
            json.writeEndObject();
        }
        json.writeEndArray();
    }

    /**
     * For cancel and final applications, we might have submissions that were in-flight or rules-api allocated.
     * Try to send allocated partners, or if not available, send just the previous allocated apps if any.
     * @param json Json generator
     * @param fieldName The field name
     * @param app Application instance
     * @param partners Model allocated partners
     */
    private static void writePartnerArrayWithInvestorFallback(
            JSONGenerator json, String fieldName, genesis__Applications__c app, List<Allocation_Partner__c> partners) {

        if (app.Allocation_ID__c != null) {
            writePartnerArray(json, fieldName, partners);
            return;
        }
        writeInvestorArray(json, fieldName, app);
    }


    /**
     * Write the previous investor for final apps
     * @param json Json writer
     * @param fieldName The field name to write
     * @param app The app with investor data
     */
    private static void writeInvestorArray(JSONGenerator json, String fieldName, genesis__Applications__c app) {

        if (app.Investor__r == null) {
            json.writeNullField(fieldName);
            return;
        }

        json.writeFieldName(fieldName);
        json.writeStartArray();
        json.writeStartObject();
        json.writeStringField('investorCode', app.Investor__r.Investor_Code__c);
        json.writeBooleanField('leadPartner', true);
        json.writeEndObject();
        json.writeEndArray();
    }

    private static void writeNullableBoolean(JSONGenerator json, String fieldName, Boolean value) {
        if (value == null) {
            json.writeNullField(fieldName);
        } else {
            json.writeBooleanField(fieldName, value);
        }
    }

    private static void writeNullableString(JSONGenerator json, String fieldName, String value) {
        if (value == null) {
            json.writeNullField(fieldName);
        } else {
            json.writeStringField(fieldName, value);
        }
    }

    /**
     * DO NOT put a DML operation (insert/update/ansyc method etc) before the callout!
     * see: https://developer.salesforce.com/docs/atlas.en-us.234.0.apexcode.meta/apexcode/apex_callouts_timeouts.htm
     *
     * @param appIds App ids to process
     * @param json The json request
     * @param decisionLevel The decision level to executed
     */
    private static void callAllocationEngineService(List<Id> appIds, String json, String decisionLevel) {

        final String logMethodName = 'callAllocationEngineService';
        List<String> leadIds = toLeadIds(appIds);
        Map<String, Object> msg = new Map<String, Object>{
                'decisionLevel' => decisionLevel,
                'leadIds' => toLeadIdsStr(appIds),
                'requestBody' => json
        };

        try {
            CalloutResult cr = executeCallout(leadIds, json, decisionLevel, 0, new List<String>());

            if (cr.responseCategory == NO_RESPONSE ||
                cr.responseCategory == RESPONSE_CATEGORY_5XX ||
                cr.responseCategory == RESPONSE_CATEGORY_4XX) {

                /*
                < 0 = connection or local exceptions, 5 = 5xx error, 4 = 4xx error
                1. Log any connectivity or server error to each app via common batch logs
                2. Set operation error on app to know which action was attempted
                 */
                msg.put('message', cr.finalMessage);

                insertErrorCommonLog(appIds, cr.responseCategory, decisionLevel);
                insertLoanBatchProcessLog(msg.toString());

                updateOperationError(appIds, decisionLevel);
                MW_LogUtility.errorMessage(LOG_NAME, logMethodName, msg);

            } else {

                /*
                  This block will only be 2xx due to callout handling
                  1. Clear previous operation error
                  2. It will write Allocation_Partner__c for selected investors
                  3. It will note any errors, non allocations in cl errors logs
                 */
                updateOperationError(appIds, null);
                msg.put('message', '2xx response code, allocations handled by AES');
                MW_LogUtility.infoMessage(LOG_NAME, logMethodName, msg);
            }

        } catch (Exception e) {

            msg.put('message', 'Failed execution of Allocation Engine Service Callout');
            msg.put('error', exceptionToStr(e));

            System.debug('Exception: ' + exceptionToStr(e));
            insertLoanBatchProcessLog(msg.toString());
            MW_LogUtility.errorMessage(LOG_NAME, logMethodName, msg);
        }
    }

    @Future(Callout = true)
    private static void callAllocationEngineServiceFuture(List<Id> appIds, String json, String decisionLevel) {
        callAllocationEngineService(appIds, json, decisionLevel);
    }

    private static List<genesis__Applications__c> getApplicationsAllocationIds(List<Id> appIds) {
        return [SELECT Id,
                        Allocation_ID__c
                FROM   genesis__Applications__c
                WHERE   Id IN :appIds];
    }

    private static List<genesis__Applications__c> getApplications(List<Id> appIds, String decisionLevel) {

        return isAllocationDecisionLevel(decisionLevel) ?
                [SELECT Id,
                        genesis__Status__c,
                        genesis__APR__c,
                        genesis__Interest_Rate__c,
                        Pricing_Tier__c,
                        genesis__Term__c,
                        FICO__c,
                        Monthly_DTI__c,
                        Net_Disposable_Income_NDI_Num__c,
                        utm_medium__c,
                        utm_source__c,
                        utm_campaign__c,
                        utm_content__c,
                        Lead_ID__c,
                        genesis__Loan_Amount__c,
                        genesis__Account__r.ZIP_Code__c,
                        Loan_Purpose__c,
                        Investor__c,
                        Investor__r.Investor_Code__c,
                        Credit_Policy_Approval_Models__c,
                        Expected_Yield__c,
                        Expected_Chargeoff__c,
                        Allocation_ID__c,
                        Allocation_Timestamp__c
                 FROM    genesis__Applications__c
                 WHERE   Id IN :appIds] :
                [SELECT Id,
                        Lead_ID__c,
                        Allocation_ID__c,
                        Investor__c,
                        Investor__r.Investor_Code__c,
                        genesis__Status__c
                 FROM   genesis__Applications__c
                 WHERE   Id IN :appIds];
    }

    /**
     * @param appIds The app id
     *
     * @return All allocation partners for this application
     */
    @TestVisible
    private static List<Allocation_Partner__c> getAllocationPartnersByAppIds(List<Id> appIds) {
        return [SELECT Id,
                        Application__c,
                        Investor__c,
                        Investor__r.Investor_Code__c,
                        Lead_Partner__c
                FROM   Allocation_Partner__c
                WHERE  Application__c IN :appIds
                ORDER BY Lead_Partner__c];
    }

    /**
     * @param allocationPartnerIds All partner ids to consider
     *
     * @return A map of app id to list of partner allocations
     */
    private static List<Allocation_Partner__c> getAllocationPartnersByIds(List<Id> allocationPartnerIds) {
        if (allocationPartnerIds == null || allocationPartnerIds.isEmpty()) {
            return new List<Allocation_Partner__c>();
        }

        return [SELECT Id,
                        Application__c,
                        Investor__c,
                        Investor__r.Investor_Code__c,
                        Lead_Partner__c
                FROM   Allocation_Partner__c
                WHERE  Id IN :allocationPartnerIds
                ORDER BY Lead_Partner__c];
    }

    /**
     * @param partners A list of partners will all fields selected
     *
     * @return Map grouped by app id
     */
    private static Map<Id, List<Allocation_Partner__c>> groupAllocationPartnersByAppId(List<Allocation_Partner__c> partners) {
        Map<Id, List<Allocation_Partner__c>> partnerMap = new Map<Id, List<Allocation_Partner__c>>();
        for (Allocation_Partner__c partner : partners) {
            List<Allocation_Partner__c> appPartners = partnerMap.get(partner.Application__c);
            if (appPartners == null) {
                appPartners = new List<Allocation_Partner__c>();
                partnerMap.put(partner.Application__c, appPartners);
            }
            appPartners.add(partner);
        }
        return partnerMap;
    }

    /**
     * Execute the callout recursively up to a limit of MAX_RETRY.
     * Since this is executing in a future, take governer limits in consideration!
     * Messages are added to when context is gathered
     *
     * @param leadIds Lead ids in this batch
     * @param json The json payload
     * @param decisionLevel The type of invocation
     * @param retryCount Retry count
     * @param messages Messages gathered during retries
     *
     * @return The CalloutResult summary object
     */
    private static CalloutResult executeCallout(List<String> leadIds, String json, String decisionLevel, Integer retryCount, List<String> messages) {

        HttpResponse res;
        Integer responseCategory = NO_RESPONSE;

        if (retryCount < 0) {
            retryCount = 0;
        }

        try {
            /*
            Don't include the client certificate because this call will be secured by oauth
             */
            String fmt = MW_Settings__c.getInstance().Allocation_Engine_Service_URL_FMT__c;
            String url = String.format(fmt, new List<String> { decisionLevel.toLowerCase() });
            String method = isAllocationDecisionLevel(decisionLevel) ? 'POST' : 'PATCH';
            String bearerToken = MW_ClientCredentialsOAuthHelper.getBearerToken(HAPPY_MONEY_OKTA_SERVICE_NAME);

            HttpRequest req = new HttpRequest();
            req.setMethod(method);
            req.setEndpoint(url);
            req.setTimeout(CALLOUT_TIMEOUT_IN_SECONDS);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Cache-Control', 'no-cache');
            req.setHeader('Authorization', 'Bearer ' + bearerToken);
            req.setBody(json);

            Http http = new Http();
            res = http.send(req);

            responseCategory = res.getStatusCode() / 100;

            if (RESPONSE_CATEGORY_5XX == responseCategory) {
                retryCount++;
                if (MAX_RETRY <= retryCount) {
                    messages.add(makeCalloutMessage('Retrying exhausted after: ', res, null));

                    CalloutResult cr = new CalloutResult();
                    cr.response = res;
                    cr.responseCategory = responseCategory;
                    cr.messages = messages;
                    return cr;
                }

                messages.add(makeCalloutMessage('Retry ' + retryCount + ' after: ', res, null));
                return executeCallout(leadIds, json, decisionLevel, retryCount, messages);
            } else if (RESPONSE_CATEGORY_4XX == responseCategory) {
                messages.add(makeCalloutMessage('Failed AES validation: ', res, null));
            } else if (RESPONSE_CATEGORY_2XX != responseCategory) {
                throw new IllegalArgumentException('Unhandled response code: ' + res.getStatusCode());
            }

        } catch (Exception e) {

            retryCount++;
            if (MAX_RETRY <= retryCount) {
                messages.add(makeCalloutMessage('Retrying exhausted after: ', res, e));

                CalloutResult cr = new CalloutResult();
                cr.response = res;
                cr.responseCategory = responseCategory;
                cr.messages = messages;
                return cr;
            }

            messages.add(makeCalloutMessage('Retry ' + retryCount + ' after: ', res, e));
            return executeCallout(leadIds, json, decisionLevel, retryCount, messages);
        }

        CalloutResult cr = new CalloutResult();
        cr.response = res;
        cr.responseCategory = responseCategory;
        cr.messages = messages;
        return cr;
    }

    private static String makeCalloutMessage(String context, HttpResponse response, Exception e) {

        List<String> msgs = new List<String>();

        if (context != null) {
            msgs.add(context);
        }

        if (response != null) {
            msgs.add('Response code: ' + response.getStatusCode());
            msgs.add('Response body: ' + response.getBody());
        }

        if (e != null) {
            msgs.add(exceptionToStr(e));
        }

        return String.join(msgs, ', ');
    }

    private static Boolean isAllocationDecisionLevel(String decisionLevel) {
        return ALLOCATION_DECISION_LEVELS.contains(decisionLevel);
    }

    /**
     * @param msg A message for a general logging statement
     *  Loan Batch Process logs are used for general (non app id specific) errors
     *
     */
    private static void insertLoanBatchProcessLog(String msg) {

        loan__Batch_Process_Log__c bpl = new loan__Batch_Process_Log__c();
        bpl.loan__Origin__c = 'Allocation Engine';
        bpl.loan__Message__c = msg;
        bpl.loan__Type__c = 'Exception';
        bpl.loan__Time__c = Datetime.now();
        insert bpl;
    }

    /**
     * Send logs to show up on the CLS application tab in response to AES communication errors
     *
     * @param appIds App ids to send logs to
     * @param responseCategory The type of failure response
     * @param decisionLevel The decision level
     */
    private static void insertErrorCommonLog(List<Id> appIds, Integer responseCategory, String decisionLevel) {

        List<clcommon__Batch_Process_Log__c> logs = new List<clcommon__Batch_Process_Log__c>();

        String cause = '';

        if (NO_RESPONSE == responseCategory) {
            cause = 'Local exception';
        } else if (RESPONSE_CATEGORY_5XX == responseCategory) {
            cause = '5xx response, meaning unhandled AES error';
        } else if (RESPONSE_CATEGORY_4XX == responseCategory) {
            cause = '4xx response, meaning CLS side error according to AES';
        } else {
            cause = 'Unknown response';
        }

        for (Id appId : appIds) {

            String msg = String.format('Unable to send to Allocation Engine to perform {0} for application due to: {1}.\n' +
                    'Check loan batch process logs and DataDog for more info',
                    new List<String> {decisionLevel, cause});

            clcommon__Batch_Process_Log__c bpl = new clcommon__Batch_Process_Log__c();
            bpl.clcommon__Log_Level__c = 'INFO';
            bpl.clcommon__Type__c = 'Info';
            bpl.clcommon__Batch_Id__c = appId;
            bpl.clcommon__Message__c = msg;
            logs.add(bpl);
        }

        insert logs;
    }

    /**
     * @param appIds The app ids to send to
     * @param msg The message to apply to all
     */
    private static void insertErrorCommonLog(List<Id> appIds, String msg) {

        List<clcommon__Batch_Process_Log__c> logs = new List<clcommon__Batch_Process_Log__c>();

        for (Id appId : appIds) {

            clcommon__Batch_Process_Log__c bpl = new clcommon__Batch_Process_Log__c();
            bpl.clcommon__Log_Level__c = 'INFO';
            bpl.clcommon__Type__c = 'Info';
            bpl.clcommon__Batch_Id__c = appId;
            bpl.clcommon__Message__c = msg;
            logs.add(bpl);
        }

        insert logs;
    }

    /**
     * @param app The app id to create a log for
     * @param decisionLevel The decision level
     * @param messages Validation failure messages
     *
     * @return An instance to be inserted later
     */
    private static clcommon__Batch_Process_Log__c makeCommonBatchProcessLog(
            genesis__Applications__c app,
            String decisionLevel,
            List<String> messages) {

        String msg = String.format('Can not execute operation: {0} for Lead Id: {1} due to: {2}',
                new List<String> {
                        decisionLevel,
                        app.Lead_ID__c,
                        String.join(messages, ',')
                }
        );

        clcommon__Batch_Process_Log__c bpl = new clcommon__Batch_Process_Log__c();
        bpl.clcommon__Log_Level__c = 'INFO';
        bpl.clcommon__Type__c = 'Info';
        bpl.clcommon__Batch_Id__c = app.Id;
        bpl.clcommon__Message__c = msg;
        return bpl;
    }

    /**
     * Save the operation intended to the application records.
     *
     * @param appIds The app ids to save
     * @param decisionLevel Attempted decision level
     *
     */
    private static void updateOperationError(List<Id> appIds, String decisionLevel) {

        List<genesis__Applications__c> apps  = new List<genesis__Applications__c>();

        for (Id Id : appIds) {
            genesis__Applications__c app = new genesis__Applications__c();
            app.Id = Id;
            app.Allocation_Operation_Error__c = decisionLevel;
            apps.add(app);
        }

        update apps;
    }

    /**
     * @param e Exception to convert to a string
     *
     * @return a log friendly exception string
     */
    private static String exceptionToStr(Exception e) {
        if (e == null) {
            return '';
        }

        return String.format('Type: {0}, Message: {1}, Line Number: {2}, Stack Trace: {3}', new List<String>{
                e.getTypeName(),
                e.getMessage(),
                String.valueOf(e.getLineNumber()),
                e.getStackTraceString()});
    }

    /**
     * @param appIds App ids
     *
     * @return lead ids
     */
    private static List<String> toLeadIds(List<Id> appIds) {
        List<String> leadIds = new List<String>();
        List<genesis__Applications__c> apps = [SELECT Lead_ID__c FROM  genesis__Applications__c WHERE Id IN :appIds];
        for (genesis__Applications__c app : apps) {
            leadIds.add(app.Lead_ID__c);
        }
        return leadIds;
    }

    private static String toLeadIdsStr(List<Id> appIds) {
        return String.join(toLeadIds(appIds),', ');
    }

    /**
     * @param apps Apps to turn intto id list
     *
     * @return the list
     */
    private static List<Id> toIds(List<genesis__Applications__c> apps) {
        List<Id> ids = new List<Id>();
        for (genesis__Applications__c app : apps) {
            ids.add(app.Id);
        }
        return ids;
    }

}