/**
 * Created by ilazarte on 2/7/22.
 */

@IsTest
private class MW_AllocationEngineHandlerTest {

    private static final String OFFERS_API = 'offers-api';

    /* A realistic UUID is required for docusign related test in agent verified test method */
    private static final String REALISTIC_UUID = '5fdc44e3-d43d-47ed-a800-9d7aa1f7c147';

    private static final String OFFERS_API_ADVP_FAILURE_MSG_APP2 = 'Can not execute operation: advp for Lead Id: '
            + REALISTIC_UUID + ' due to: Program Id is null and default program id cannot be used due to utm_source__c: offers-api and api product flow: offers-api';

    private static final String OKTA_DOMAIN = 'https://oktadomain';

    private static final String FE_ENDPOINT = 'https://sfapi-dev.payoff.com/ms/api/cls/update_user';

    private static final String BOX_URL = 'https://test.app.box.com/file/00000000000';

    private static final String DOCUSIGN_URL_PART = 'envelopes/';

    public class AESCalloutExceptionMock implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest httpRequest) {

            if(httpRequest.getEndpoint().startsWith(OKTA_DOMAIN)) {
                return makeOktaSuccess();
            }

            throw new CalloutException('Callout Failure Simulation');
        }
    }

    public class AESServerErrorMock implements HttpCalloutMock {

        public Integer attempts = 0;

        public HttpResponse respond(HttpRequest httpRequest) {

            if(httpRequest.getEndpoint().startsWith(OKTA_DOMAIN)) {
                return makeOktaSuccess();
            }
            String requestBody = httpRequest.getBody();
            System.debug(LoggingLevel.INFO, 'Request Body: ' + requestBody);

            String json = '{"timestamp":"2022-02-17T16:05:21.659Z","data":{},"errors":["Unhandled Exception"]}';

            attempts++;

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(json);
            res.setStatusCode(500);
            return res;
        }
    }

    public class AESValidationFailureMock implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest httpRequest) {

            if(httpRequest.getEndpoint().startsWith(OKTA_DOMAIN)) {
                return makeOktaSuccess();
            }

            String requestBody = httpRequest.getBody();
            System.debug(LoggingLevel.INFO, 'Request Body: ' + requestBody);

            String json = '{"timestamp":"2022-02-17T16:05:21.659Z","data":{},"errors":["Missing foo bar"]}';

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(json);
            res.setStatusCode(400);
            return res;
        }
    }

    public class AESSuccessMock implements HttpCalloutMock {

        public Integer requestCount = 0;

        public List<String> endpoints = new List<String>();

        public HttpResponse respond(HttpRequest httpRequest) {

            if(httpRequest.getEndpoint().startsWith(OKTA_DOMAIN)) {
                return makeOktaSuccess();
            }

            if(httpRequest.getEndpoint().startsWith(FE_ENDPOINT)) {
                return makeSimpleSuccess();
            }

            if (httpRequest.getEndpoint().containsIgnoreCase(DOCUSIGN_URL_PART)) {
                return makeDocusignSentSuccess();
            }

            requestCount++;

            endpoints.add(httpRequest.getEndpoint());

            String requestBody = httpRequest.getBody();
            System.debug(LoggingLevel.INFO, 'Requesting: ' + httpRequest.getEndpoint() + ' Request Body: ' + requestBody);

            String json = '{ "timestamp": "2022-02-18T21:27:24.509Z", "data": { "allocation-responses": [ { "timestamp": "2022-02-18T21:27:24.509Z", "status": "success", "detail": "string", "allocationId": "string", "allocationEngineVersion": "string", "requestID": "string", "capitalPartnerInfo": [ { "capitalPartnerName": "string", "investorCode": "string", "leadPartner": true } ] } ] }, "errors": [] }';

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(json);
            res.setStatusCode(201);
            return res;
        }
    }

    /**
     * Not re-testing Okta in this class, so always return a success
     * @return success token
     */
    private static HttpResponse makeOktaSuccess() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"token_type":"Bearer","expires_in":3600,"access_token":"accesstokenvalue","scope":"HM"}');
        res.setStatusCode(200);
        return res;
    }

    /**
     * @return success response
     */
    private static HttpResponse makeSimpleSuccess() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"value":"success"}');
        res.setStatusCode(200);
        return res;
    }

    /**
     * @return A mocked successful return from docusign
     */
    private static HttpResponse makeDocusignSentSuccess() {

        WrapperDocuSign body = new WrapperDocuSign();
        body.envelopeId = '1234567890';
        body.status = 'sent';
        body.statusDateTime = '2022-02-18T21:27:24.509Z';
        body.uri = 'https://demo.docusign.net/restapi/v2/accounts/123456/envelopes/1234567890';

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JSON.serialize(body));
        res.setStatusCode(200);
        return res;
    }

    /*
     Json parser for testing.
     Could be worth breaking out into own class.
     Much easier to use when keys don't bind well (dashes in keys etc)

     Premise:
     1. traversal methods all return new Jsons
        .key string path supports period descent.
         indices would be nice, but .index is available
     2. value methods return values after null checks, and casting
     */

    class Jsons {

        final Object obj;

        Jsons(Object obj) {
            this.obj = obj;
        }

        Jsons key(String path) {
            List<String> keys = path.split('\\.');
            Map<String, Object> curr = (Map<String, Object>) this.obj;
            Object res;

            for (Integer i = 0, last = keys.size() - 1 ; i < keys.size(); i++) {
                if (curr == null) {
                    return new Jsons(null);
                }
                String key = keys.get(i);
                if (i == last) {
                    res = curr.get(key);
                } else {
                    curr = (Map<String, Object>) curr.get(key);
                }
            }

            return new Jsons(res);
        }

        Jsons index(Integer idx) {
            if (this.obj == null) {
                return new Jsons(null);
            }

            List<Object> objs = (List<Object>) this.obj;
            if (idx >= objs.size()) {
                return new Jsons(null);
            }

            return new Jsons(objs.get(idx));
        }

        Integer size() {
            if (this.obj == null) {
                return null;
            }

            if (this.obj instanceof List<Object>) {
                return ((List<Object>) this.obj).size();
            }
            return ((Map<Object, Object>) this.obj).size();
        }

        Boolean isNull() {
            return this.obj == null;
        }

        Object getObject(String key) {
            if (this.obj == null) {
                return null;
            }
            Map<String, Object> obj = (Map<String, Object>) this.obj;
            return obj.get(key);
        }

        Boolean getBoolean(String key) {
            Object obj = this.getObject(key);
            return obj == null ? null : (Boolean) obj;
        }

        Decimal getDecimal(String key) {
            Object obj = this.getObject(key);
            return obj == null ? null : (Decimal) obj;
        }

        List<Object> getList(String key) {
            Object obj = this.getObject(key);
            return obj == null ? null : (List<Object>) obj;
        }

        String get(String key) {
            Object obj = this.getObject(key);
            return obj == null ? null : (String) obj;
        }

        Boolean containsKey(String key) {
            if (this.obj == null) {
                return null;
            }
            Map<String, Object> obj = (Map<String, Object>) this.obj;
            return obj.containsKey(key);
        }
    }

    @TestSetup static void setup() {

        MW_Settings__c mwSettings = new MW_Settings__c();
        mwSettings.Allocation_Engine_Deployment_Mode__c = 'DARK_MODE';
        mwSettings.Allocation_Engine_Service_URL_FMT__c = 'http://localhost:8080/{0}';
        mwSettings.Allocation_Engine_Cancel_Statuses__c = 'Declined,Expired,Withdrawn,Decline_Manual_Review,Expired-Withdrawn';
        mwSettings.Allocation_Engine_Default_Program_Id__c = 'test-program-id';
        mwSettings.Allocation_Engine_API_Product_Flow__c = OFFERS_API;
        mwSettings.LEADS_FE_EndpointURL__c = FE_ENDPOINT;
        insert mwSettings;

        insert MW_GlobalTestUtility.getCLDocumentRecord();

        /* in theory not required, but leave triggers executing to observe for errors */
        /*
        genesis__Org_Parameters__c genorg = genesis__Org_Parameters__c.getOrgDefaults();
        genorg.genesis__Disable_Triggers__c = true;
        upsert genorg;
         */

        Account investor1 = MW_GlobalTestUtility.GetAccount('Investor');
        investor1.loan__Collect_Service_Fees_on__c = 'No Fees';
        investor1.Amount_Invested__c = 100000;
        investor1.Number_Of_Applications_Invested__c = 3;
        investor1.Investor_Code__c = 'FCU';

        Account investor2 = MW_GlobalTestUtility.GetAccount('Investor');
        investor2.loan__Collect_Service_Fees_on__c = 'No Fees';
        investor2.Amount_Invested__c = 100000;
        investor2.Number_Of_Applications_Invested__c = 3;
        investor2.Investor_Code__c = 'GCSU';

        Account investor3 = MW_GlobalTestUtility.GetAccount('Investor');
        investor3.loan__Collect_Service_Fees_on__c = 'No Fees';
        investor3.Amount_Invested__c = 100000;
        investor3.Number_Of_Applications_Invested__c = 3;
        investor3.Investor_Code__c = 'USAFCU';

        Account member1 = MW_GlobalTestUtility.GetAccount('Member');
        member1.State__c = 'CA';
        member1.loan__Collect_Service_Fees_on__c = 'No Fees';
        member1.ZIP_Code__c = '92782';

        Account member2 = MW_GlobalTestUtility.GetAccount('Member');
        member2.State__c = 'VA';
        member2.loan__Collect_Service_Fees_on__c = 'No Fees';
        member2.ZIP_Code__c = '92782';

        insert new List<Account> {investor1, investor2, investor3, member1, member2};

        /* Used for most tests, but typical app wont have all this data */
        genesis__Applications__c app1 = MW_GlobalTestUtility.GetApplication();
        app1.genesis__Account__c = member1.Id;
        app1.genesis__Status__c = PayoffConstants.AGENT_DOCUMENT_VERIFICATION_PENDING;
        app1.Investor__c = investor1.Id;
        app1.Lead_ID__c = 'abc123';
        app1.genesis__APR__c = 7.00;
        app1.genesis__Interest_Rate__c = 10.00;
        app1.Pricing_Tier__c = 't1';
        app1.genesis__Term__c = 5;
        app1.FICO__c = 700.00;
        app1.Monthly_DTI__c = 12;
        app1.Net_Disposable_Income_NDI_Num__c = 1200;
        app1.Loan_Purpose__c = 'debt_consolidation';
        app1.Credit_Policy_Approval_Models__c = 'crb_otb';
        app1.genesis__Loan_Amount__c = 25000.00;
        app1.Origination_fee__c = 10.00;
        app1.utm_medium__c = 'medium';
        app1.utm_source__c = 'source';
        app1.utm_campaign__c = 'campaign';
        app1.Allocation_ID__c = 'alloc1';
        app1.Allocation_Operation_Error__c = MW_AllocationEngineHandler.ADVP;
        app1.Allocation_Timestamp__c = Datetime.now();
        app1.Expected_Yield__c = 321.11;
        app1.Expected_Chargeoff__c = 432.0;
        app1.Invested_Amount__c = app1.genesis__Loan_Amount__c;
        app1.Program_id__c = 'program_id1';

        /* fresh advp apps will look more like this */
        genesis__Applications__c app2 = MW_GlobalTestUtility.GetApplication();
        app2.genesis__Account__c = member2.Id;
        app2.genesis__Status__c = PayoffConstants.AGENT_DOCUMENT_VERIFICATION_PENDING;
        app2.Lead_ID__c = REALISTIC_UUID;
        app2.genesis__APR__c = 7.99;
        app2.genesis__Interest_Rate__c = 10.00;
        app2.Pricing_Tier__c = 't2';
        app2.genesis__Term__c = 5;
        app2.FICO__c = 700.00;
        app2.Monthly_DTI__c = 12;
        app2.Net_Disposable_Income_NDI_Num__c = 1200;
        app2.Loan_Purpose__c = 'debt_consolidation';
        app2.Credit_Policy_Approval_Models__c = null;
        app2.genesis__Loan_Amount__c = 15000.00;
        app2.Origination_fee__c = 10.00;
        app2.Invested_Amount__c = app2.genesis__Loan_Amount__c;
        app2.Program_id__c = 'program_id2';

        /* order of insertion matters for getApps call */
        insert new List<genesis__Applications__c> {app1, app2};

        /* insert til cateegory and attachment for allocated app */
        genesis__Application_Document_Category__c adc = new genesis__Application_Document_Category__c();
        adc.Name = 'TIL Document';
        adc.genesis__Application__c = app1.Id;
        insert adc;

        Attachment att = new Attachment();
        att.Name = 'TIL Document' + app1.Id;
        att.Body = Blob.valueOf('Unit Test Attachment Body');
        att.ParentId = app1.Id;
        insert att;

        /* insert allocation partners only for the first app for scenarios */
        Allocation_Partner__c  ap1 = new Allocation_Partner__c();
        ap1.Application__c = app1.Id;
        ap1.Investor__c = investor1.Id;

        Allocation_Partner__c  ap2 = new Allocation_Partner__c();
        ap2.Application__c = app1.Id;
        ap2.Lead_Partner__c = true;
        ap2.Investor__c = investor2.Id;

        insert new List<Allocation_Partner__c> {ap1, ap2};

        ints__OAuth_Settings__c okta = new ints__OAuth_Settings__c();
        okta.ints__Consumer_Key__c = 'aclientid';
        okta.ints__Consumer_Secret__c = 'aclientsecret';
        okta.ints__Access_Token_URL__c = OKTA_DOMAIN + '/v1/token';
        okta.ints__Service_Name__c = MW_AllocationEngineHandler.HAPPY_MONEY_OKTA_SERVICE_NAME;
        insert okta;
    }

    @IsTest static void testStatusChecker() {
        String statusCsv = MW_Settings__c.getOrgDefaults().Allocation_Engine_Cancel_Statuses__c;

        System.assert(MW_AllocationEngineHandler.statusListContains(statusCsv, 'Declined'));
        System.assert(MW_AllocationEngineHandler.statusListContains(statusCsv, 'Expired'));
        System.assert(MW_AllocationEngineHandler.statusListContains(statusCsv, 'Withdrawn'));
        System.assert(MW_AllocationEngineHandler.statusListContains(statusCsv, 'Decline_Manual_Review'));
        System.assert(MW_AllocationEngineHandler.statusListContains(statusCsv, 'Expired-Withdrawn'));
        System.assert(!MW_AllocationEngineHandler.statusListContains(statusCsv, 'bogus'));
    }

    @IsTest static void testDeploymentModes() {

        MW_Settings__c settings = MW_Settings__c.getOrgDefaults();
        settings.Allocation_Engine_Deployment_Mode__c = 'foo';
        update settings;

        System.assert(MW_AllocationEngineHandler.isRulesApiEnabled());
        System.assert(!MW_AllocationEngineHandler.isAllocationEngineServiceEnabled());

        settings.Allocation_Engine_Deployment_Mode__c = 'LEGACY_MODE';
        update settings;

        System.assert(MW_AllocationEngineHandler.isRulesApiEnabled());
        System.assert(!MW_AllocationEngineHandler.isAllocationEngineServiceEnabled());

        settings.Allocation_Engine_Deployment_Mode__c = 'DARK_MODE';
        update settings;

        System.assert(MW_AllocationEngineHandler.isRulesApiEnabled());
        System.assert(MW_AllocationEngineHandler.isAllocationEngineServiceEnabled());

        settings.Allocation_Engine_Deployment_Mode__c = 'FULL_MODE';
        update settings;

        System.assert(!MW_AllocationEngineHandler.isRulesApiEnabled());
        System.assert(MW_AllocationEngineHandler.isAllocationEngineServiceEnabled());

        settings.Allocation_Engine_Deployment_Mode__c = null;
        update settings;

        System.assert(MW_AllocationEngineHandler.isRulesApiEnabled());
        System.assert(!MW_AllocationEngineHandler.isAllocationEngineServiceEnabled());
    }
    
    @IsTest static void testHandleInvalidDecisionLevel() {

        List<Id> ids = toIds(getApps());

        MW_AllocationEngineHandler.handleInvalidDecisionLevel(ids, 'potato');

        List<loan__Batch_Process_Log__c> logs = getLoanLogs();
        System.assertEquals(1, logs.size());
        loan__Batch_Process_Log__c loanLog = logs.get(0);

        System.assertEquals(
                'MW_AllocationEngineHandler: Invalid decision level of "potato" attempted for lead ids: abc123, ' + REALISTIC_UUID,
                loanLog.loan__Message__c);

        List<clcommon__Batch_Process_Log__c> commonlogs = getCommonLogs();
        System.assertEquals(2, commonlogs.size());

        System.assertEquals(
                'MW_AllocationEngineHandler: Invalid decision level of "potato" attempted for this application',
                commonlogs.get(0).clcommon__Message__c);
        System.assertEquals(ids.get(0), commonlogs.get(0).clcommon__Batch_Id__c);

        System.assertEquals(
                'MW_AllocationEngineHandler: Invalid decision level of "potato" attempted for this application',
                commonlogs.get(1).clcommon__Message__c);
        System.assertEquals(ids.get(1), commonlogs.get(1).clcommon__Batch_Id__c);
    }

    @IsTest static void testHandleExceptionHandler() {

        genesis__Applications__c app = getApp();
        IllegalArgumentException e = new IllegalArgumentException('There be dragons');

        MW_AllocationEngineHandler.handleExceptionHandler(new List<String> {app.Id}, MW_AllocationEngineHandler.ADVP, e);

        genesis__Applications__c actual = getApp();
        System.assertEquals(MW_AllocationEngineHandler.ADVP, actual.Allocation_Operation_Error__c);

        List<loan__Batch_Process_Log__c> logs = getLoanLogs();
        System.assertEquals(1, logs.size());

        loan__Batch_Process_Log__c log = logs.get(0);
        System.assertEquals('Allocation Engine', log.loan__Origin__c);
        System.assert(log.loan__Message__c.contains('Failed JSON request generation: Exception on lead guids: abc123'));
        System.assert(log.loan__Message__c.contains('There be dragons'));
        System.assertEquals('Exception', log.loan__Type__c);
        System.assertNotEquals(null, log.loan__Time__c);
    }

    @IsTest static void testFilterByAllocationIds() {

        List<Id> mainIds = new List<Id>();
        List<genesis__Applications__c> apps = getApps();
        for (genesis__Applications__c app : apps) {
            app.Allocation_ID__c = null;
            mainIds.add(app.Id);
        }
        update apps;

        System.assertEquals(2, mainIds.size());

        List<Id> noAllocsIds = null;
        List<Id> actualIds1 = mainIds.clone();
        noAllocsIds = MW_AllocationEngineHandler.filterByAllocationIds(actualIds1, false);

        System.assertEquals(0, actualIds1.size());
        System.assertEquals(2, noAllocsIds.size());


        apps.get(0).Allocation_ID__c = '123';
        update apps;
        List<Id> actualIds2 = mainIds.clone();

        noAllocsIds = MW_AllocationEngineHandler.filterByAllocationIds(actualIds2, false);

        System.assertEquals(1, actualIds2.size());
        System.assertEquals(1, noAllocsIds.size());

        apps.get(1).Allocation_ID__c = '456';
        update apps;
        List<Id> actualIds3 = mainIds.clone();
        noAllocsIds = MW_AllocationEngineHandler.filterByAllocationIds(actualIds3, false);

        System.assertEquals(2, actualIds3.size());
        System.assertEquals(0, noAllocsIds.size());

        List<Id> actualIds4 = mainIds.clone();
        List<Id> hasIds = MW_AllocationEngineHandler.filterByAllocationIds(actualIds4, true);

        System.assertEquals(2, hasIds.size());
        System.assertEquals(0, actualIds4.size());
    }

    /**
     * This executes trigger for receive coverage purposes only.
     * Functionality is tested in other test methods.
     *
     * MW_AllocationParterTrigger is covered as part of this test
     */
    @IsTest static void testTriggerCoverage() {

        Test.setMock(HttpCalloutMock.class, new AESSuccessMock());
        Test.startTest();

        /* fires: MW_AllocationParterTrigger */
        setManualPartner(false);
        Test.stopTest();
    }

    /**
     * Generate json corresponding to an ITB loan
     */
    @IsTest static void advp_canGenerateJson_ITB() {

        genesis__Applications__c app = getApp();
        app.Credit_Policy_Approval_Models__c = null;
        app.Risk_Model_Source__c = 'hm';
        update app;

        String actualJson = MW_AllocationEngineHandler.toJson(new List<Id> {app.Id},
                null,
                MW_AllocationEngineHandler.ADVP);

        Jsons actual = parseJsons(actualJson);
        assertTopLevelFields(actual);

        actual = actual.key('allocation-requests').index(0);
        assertCommonRequestFields(app, actual);
        assertAllocationRequestFields(app, actual, null);
    }

    @IsTest static void advp_canGenerateJson_ITB_nullProgramId() {

        genesis__Applications__c app = getApp();
        app.Credit_Policy_Approval_Models__c = null;
        app.Risk_Model_Source__c = 'hm';
        app.Program_id__c = null;
        update app;

        String actualJson = MW_AllocationEngineHandler.toJson(new List<Id> {app.Id},
                null,
                MW_AllocationEngineHandler.ADVP);

        Jsons actual = parseJsons(actualJson);
        assertTopLevelFields(actual);

        actual = actual.key('allocation-requests').index(0);
        assertCommonRequestFields(app, actual, true);
        assertAllocationRequestFields(app, actual, null);
    }

    /**
     * Generate json corresponding to an OTB loan
     */
    @IsTest static void advp_canGenerateJson_OTB() {

        genesis__Applications__c app = getApp();
        app.Credit_Policy_Approval_Models__c = 'crb_otb';
        app.Risk_Model_Source__c = 'hm';
        update app;

        String actualJson = MW_AllocationEngineHandler.toJson(new List<Id> {app.Id},
                null,
                MW_AllocationEngineHandler.ADVP);

        Jsons actual = parseJsons(actualJson);
        assertTopLevelFields(actual);

        actual = actual.key('allocation-requests').index(0);
        assertCommonRequestFields(app, actual);
        assertAllocationRequestFields(app, actual, 'crb_otb');
    }

    /**
     * Generate json corresponding to a turn down loan
     */
    @IsTest static void advp_canGenerateJson_CRB() {

        genesis__Applications__c app = getApp();
        app.Credit_Policy_Approval_Models__c = 'crb_otb';
        app.Risk_Model_Source__c = 'crb';
        update app;

        String actualJson = MW_AllocationEngineHandler.toJson(new List<Id> {app.Id},
                null,
                MW_AllocationEngineHandler.ADVP);

        Jsons actual = parseJsons(actualJson);
        assertTopLevelFields(actual);

        actual = actual.key('allocation-requests').index(0);
        assertCommonRequestFields(app, actual);
        assertAllocationRequestFields(app, actual, 'crb');
    }

    /**
     * When we pass in a list of app ids, if something fails validation, don't even send it.
     * Will send to review queue and mark as failed operation.
     * A log corresponding to the specific validation failures will appear on the cls application tab
     */
    @IsTest static void advp_handlesValidationFailure() {

        /*
        used to validate null status as well, but no longer since setup added til docs which triggers
        W_ApplicationService.UpdateApplicationFlags to send back to advp.
         */

        genesis__Applications__c app = getApp();
        app.genesis__Status__c = null;
        app.genesis__APR__c = null;
        app.genesis__Interest_Rate__c = null;
        app.Pricing_Tier__c = null;
        app.genesis__Term__c = null;
        app.FICO__c = null;
        app.Monthly_DTI__c = null;
        app.Net_Disposable_Income_NDI_Num__c = null;
        app.utm_medium__c = null;
        app.utm_source__c = null;
        app.utm_campaign__c = null;
        app.utm_content__c = null;
        app.genesis__Loan_Amount__c = null;
        app.Allocation_Operation_Error__c = null;
        app.Allocation_ID__c = null;
        update app;

        System.assertEquals(null, app.Allocation_Operation_Error__c);

        /* should not produce an error, just return */
        MW_AllocationEngineHandler.handleAdvp(null);

        /* trigger validation failure */
        MW_AllocationEngineHandler.handleAdvp(new List<Id> {app.Id});

        genesis__Applications__c actual = getApp();
        System.assertEquals(MW_AllocationEngineHandler.ADVP, actual.Allocation_Operation_Error__c);

        List<clcommon__Batch_Process_Log__c> logs = getCommonLogs();

        System.assertEquals(1, logs.size());
        clcommon__Batch_Process_Log__c log = logs.get(0);
        System.debug('clcommon__Batch_Process_Log__c: ' + log);

        System.assertEquals('INFO', log.clcommon__Log_Level__c);
        System.assertEquals('Info', log.clcommon__Type__c);
        System.assertEquals(actual.Id, log.clcommon__Batch_Id__c);

        System.assert(log.clcommon__Message__c.contains('Can not execute operation: advp for Lead Id: abc123'));
        /*
        invalid assertion now, see above
        System.assert(log.clcommon__Message__c.contains('Field: genesis__Status__c cannot be null'));
         */
        System.assert(log.clcommon__Message__c.contains('Field: genesis__APR__c cannot be null'));
        System.assert(log.clcommon__Message__c.contains('Field: genesis__Interest_Rate__c cannot be null'));
        System.assert(log.clcommon__Message__c.contains('Field: genesis__Term__c cannot be null'));
        System.assert(log.clcommon__Message__c.contains('Field: FICO__c cannot be null'));
        System.assert(log.clcommon__Message__c.contains('Field: Monthly_DTI__c cannot be null'));
        System.assert(log.clcommon__Message__c.contains('Field: Net_Disposable_Income_NDI_Num__c cannot be null'));
        System.assert(log.clcommon__Message__c.contains('Field: genesis__Loan_Amount__c cannot be null'));
    }

    @IsTest static void advp_handlesApiProductFlowValidationFailure() {

        List<genesis__Applications__c> apps = getApps();
        apps[0].Program_id__c = null;
        apps[0].utm_source__c = OFFERS_API;
        apps[1].Program_id__c = null;
        apps[1].utm_source__c = OFFERS_API;
        update apps;

        Test.setMock(HttpCalloutMock.class, new AESValidationFailureMock());
        Test.startTest();

        MW_AllocationEngineHandler.handleAdvp(toIds(apps));

        Test.stopTest();

        List<genesis__Applications__c> actual = getApps();
        System.assertEquals(2, actual.size());
        System.assertEquals(MW_AllocationEngineHandler.REALLOCATION, actual.get(0).Allocation_Operation_Error__c);
        System.assertEquals(MW_AllocationEngineHandler.ADVP, actual.get(1).Allocation_Operation_Error__c);

        List<clcommon__Batch_Process_Log__c> bpls = getCommonLogs();
        System.assertEquals(2, bpls.size(), 'Should have a log for each app');

        Map<Id, clcommon__Batch_Process_Log__c> logById = logsByBatchId(bpls);

        clcommon__Batch_Process_Log__c log1 = logById.get(actual.get(0).Id);
        clcommon__Batch_Process_Log__c log2 = logById.get(actual.get(1).Id);

        System.debug(bpls);

        System.assert(log1 != null);
        System.assert(log2 != null);

        System.debug('Complete LOG> ' + log1.clcommon__Message__c);
        System.assert(log1.clcommon__Message__c.contains('Can not execute operation: reallocation for Lead Id: abc123 due to: Program Id is null and default program id cannot be used due to utm_source__c: offers-api and api product flow: offers-api'));
        System.assert(log2.clcommon__Message__c.contains(OFFERS_API_ADVP_FAILURE_MSG_APP2));
    }

    @IsTest static void advp_handlesCalloutExceptionErrors() {

        List<genesis__Applications__c> apps = getApps();

        Test.setMock(HttpCalloutMock.class, new AESCalloutExceptionMock());
        Test.startTest();

        MW_AllocationEngineHandler.handleAdvp(toIds(apps));

        Test.stopTest();

        List<genesis__Applications__c> actual = getApps();
        System.assertEquals(2, actual.size());
        System.assertEquals(MW_AllocationEngineHandler.REALLOCATION, actual.get(0).Allocation_Operation_Error__c);
        System.assertEquals(MW_AllocationEngineHandler.ADVP, actual.get(1).Allocation_Operation_Error__c);

        List<clcommon__Batch_Process_Log__c> bpls = getCommonLogs();
        System.assertEquals(2, bpls.size(), 'Should have a log for each app');

        Map<Id, clcommon__Batch_Process_Log__c> logById = logsByBatchId(bpls);

        clcommon__Batch_Process_Log__c log1 = logById.get(actual.get(0).Id);
        clcommon__Batch_Process_Log__c log2 = logById.get(actual.get(1).Id);

        System.assert(log1 != null);
        System.assert(log2 != null);

        System.assert(log1.clcommon__Message__c.contains('Local exception'));
        System.assert(log2.clcommon__Message__c.contains('Local exception'));
    }

    @IsTest static void advp_handles500Errors() {

        List<genesis__Applications__c> apps = getApps();

        AESServerErrorMock errorMock = new AESServerErrorMock();
        Test.setMock(HttpCalloutMock.class, errorMock);
        Test.startTest();

        MW_AllocationEngineHandler.handleAdvp(toIds(apps));

        Test.stopTest();

        /* we should have two decision levels since one app has an allocation id, so 2 * 5 = 10 */
        System.assertEquals(10, errorMock.attempts);

        List<genesis__Applications__c> actual = getApps();
        System.assertEquals(2, actual.size());
        System.assertEquals(MW_AllocationEngineHandler.REALLOCATION, actual.get(0).Allocation_Operation_Error__c);
        System.assertEquals(MW_AllocationEngineHandler.ADVP, actual.get(1).Allocation_Operation_Error__c);

        List<clcommon__Batch_Process_Log__c> bpls = getCommonLogs();
        System.assertEquals(2, bpls.size(), 'Should have a log for each app');

        Map<Id, clcommon__Batch_Process_Log__c> logById = logsByBatchId(bpls);

        clcommon__Batch_Process_Log__c log1 = logById.get(actual.get(0).Id);
        clcommon__Batch_Process_Log__c log2 = logById.get(actual.get(1).Id);

        System.assert(log1 != null);
        System.assert(log2 != null);

        System.assert(log1.clcommon__Message__c.contains('5xx response, meaning unhandled AES error'));
        System.assert(log2.clcommon__Message__c.contains('5xx response, meaning unhandled AES error'));
    }

    @IsTest static void advp_handles400Errors() {

        List<genesis__Applications__c> apps = getApps();

        Test.setMock(HttpCalloutMock.class, new AESValidationFailureMock());
        Test.startTest();

        MW_AllocationEngineHandler.handleAdvp(toIds(apps));

        Test.stopTest();

        List<genesis__Applications__c> actual = getApps();
        System.assertEquals(2, actual.size());
        System.assertEquals(MW_AllocationEngineHandler.REALLOCATION, actual.get(0).Allocation_Operation_Error__c);
        System.assertEquals(MW_AllocationEngineHandler.ADVP, actual.get(1).Allocation_Operation_Error__c);

        List<clcommon__Batch_Process_Log__c> bpls = getCommonLogs();
        System.assertEquals(2, bpls.size(), 'Should have a log for each app');

        Map<Id, clcommon__Batch_Process_Log__c> logById = logsByBatchId(bpls);

        clcommon__Batch_Process_Log__c log1 = logById.get(actual.get(0).Id);
        clcommon__Batch_Process_Log__c log2 = logById.get(actual.get(1).Id);

        System.assert(log1 != null);
        System.assert(log2 != null);

        System.debug('Complete LOG> ' + log1.clcommon__Message__c);
        System.assert(log1.clcommon__Message__c.contains('4xx response'));
        System.assert(log1.clcommon__Message__c.contains('Check loan batch process logs and DataDog for more info'));
        System.assert(log2.clcommon__Message__c.contains('4xx response'));
        System.assert(log2.clcommon__Message__c.contains('Check loan batch process logs and DataDog for more info'));

        List<loan__Batch_Process_Log__c> loanLogs = getLoanLogs();
        System.debug(loanLogs);

        /* since apps are split into relloaction and advp, two loan logs should appear */
        System.assertEquals(2, loanLogs.size());

        System.debug('found logs: ' + loanLogs);
        System.assert(loanLogs.get(0).loan__Message__c.contains('Missing foo bar'));
    }

    @IsTest static void advp_handles200Success() {

        List<genesis__Applications__c> apps = getApps();
        apps[1].Program_id__c = null;
        update apps[1];

        AESSuccessMock aesSuccessMock = new AESSuccessMock();
        Test.setMock(HttpCalloutMock.class, aesSuccessMock);
        Test.startTest();

        MW_AllocationEngineHandler.handleAdvp(null);

        MW_AllocationEngineHandler.handleAdvp(toIds(apps));

        Test.stopTest();

        /*
        The advp call will convert into one advp,
        and one reallocation call because one app has a pre-existing allocation id
        */
        System.debug(getCommonLogs());
        System.debug(getLoanLogs());
        System.assertEquals(2, aesSuccessMock.requestCount);

        List<genesis__Applications__c> actual = getApps();
        System.assertEquals(2, actual.size());
        System.assert(actual.get(1).Program_id__c == null);

        System.assertEquals(0, getCommonLogs().size(), 'No common logs generated for success by CLS');
        System.assertEquals(0, getLoanLogs().size(), 'No loan logs generated for success by CLS');
    }

    @IsTest static void advp_nullPricingTier_handles200Success() {

        List<genesis__Applications__c> apps = getApps();
        for (genesis__Applications__c app : apps) {
            app.Pricing_Tier__c = null;
        }

        update apps;

        Test.setMock(HttpCalloutMock.class, new AESSuccessMock());
        Test.startTest();

        MW_AllocationEngineHandler.handleAdvp(toIds(apps));

        Test.stopTest();

        List<genesis__Applications__c> actual = getApps();
        System.assertEquals(2, actual.size());

        System.assertEquals(0, getCommonLogs().size(), 'No common logs generated for success by CLS');
        System.assertEquals(0, getLoanLogs().size(), 'No loan logs generated for success by CLS');
    }

    /**
     * Assert CustomTriggerOnApplication does not fire recursively after AES sets value
     */
    @IsTest static void advp_canHandleAESResponse() {

        MW_Settings__c settings = MW_Settings__c.getOrgDefaults();
        settings.Allocation_Engine_Deployment_Mode__c = 'FULL_MODE';
        update settings;

        genesis__Applications__c app = getNewApp();

        AESSuccessMock aesSuccessMock = new AESSuccessMock();
        Test.setMock(HttpCalloutMock.class, aesSuccessMock);
        Test.startTest();

        mockAESAllocationBehavior(app);

        Test.stopTest();

        System.assertEquals(0, aesSuccessMock.requestCount);
    }

    /**
     * Mimic an app reaching agent verified status and then allocating.
     * After completion of allocation, should be transitioned to docs sent status
     *
     * The flow is something like:
     * 1. App is in advp, and moved to agent_verify (either manually or via something like ztf)
     * 2. Custom Trigger on Application - with credit policy, Allocation Engine is called, and responds successfully assigning investor
     * 3. Custom Trigger on Application - Creates docusign envelope for av app and moves to docusign loan docs sent
     * 4. Custom Trigger on Application - Til is generated for docusign loan docs sent app
     */
    @IsTest static void agentverified_canHandleAESResponse() {

        MW_Settings__c settings = MW_Settings__c.getOrgDefaults();
        settings.Allocation_Engine_Deployment_Mode__c = 'FULL_MODE';
        settings.Allocation_Engine_At_Agent_Verified__c = true;
        update settings;

        genesis__Applications__c app = getNewApp();

        AESSuccessMock aesSuccessMock = new AESSuccessMock();
        Test.setMock(HttpCalloutMock.class, aesSuccessMock);
        Test.startTest();

        /* required to allocate.  (see CustomTriggerOnApplication) */
        Credit_Policy__c creditPolicy = makeCreditPolicyRecord(app, app.FICO__c, app.Net_Disposable_Income_NDI_Num__c);
        insert creditPolicy;

        /*
        following objects required to send docusign env and subsequent til generation.
        Partly taken from WSApplicationDocumentsTest as well as debugging
        */
        clcommon__Party_Type__c partyType = TestDataFactory.createTestPartyType('BORROWER');
        insert partyType;

        genesis__Document_Category__c docType = new genesis__Document_Category__c();
        docType.genesis__Category_Name__c='ESign Documents';
        docType.Application_Status__c = PayoffConstants.AGENT_VERIFIED;

        genesis__Document_Category__c docCat = TestDataFactory.createTestDocumentCategory(partyType.Id, 'til');

        insert new List<genesis__Document_Category__c>{ docType, docCat };

        genesis__Application_Document_Category__c appDocCat = TestDataFactory.createTestApplicationDocumentCategory('TIL Document',
                app.Id, docCat.Id, BOX_URL, 'CLEARED');
        insert appDocCat;

        DocuSign_Template__c docuSignTemplate = new DocuSign_Template__c();
        docuSignTemplate.Name = 'Test_DSTemplate';
        docuSignTemplate.Template_Id__c = '12345678';
        docuSignTemplate.State__c = 'Test_State,Test_state1';
        docuSignTemplate.Account__c = getInvestor().Id;
        docuSignTemplate.Document_Category__c = docType.Id;
        docuSignTemplate.Active__c = true;
        insert docuSignTemplate;

        app.genesis__Status__c = PayoffConstants.AGENT_VERIFIED;
        update app;

        /* history insert by managed packaged which appears to be disabled in test, so insert manually */
        genesis__Application_Status_History__c history = new genesis__Application_Status_History__c();
        history.genesis__Application__c = app.Id;
        history.genesis__New_Value__c = PayoffConstants.AGENT_VERIFIED;
        history.genesis__Old_value__c = PayoffConstants.AGENT_DOCUMENT_VERIFICATION_PENDING;
        history.IsADCDeleted__c = false;
        insert history;

        mockAESAllocationBehavior(app);

        Test.stopTest();

        genesis__Applications__c actual = getNewApp();

        System.assertEquals(PayoffConstants.DOCUSIGN_LOAN_DOCS_SENT, actual.genesis__Status__c);
        System.assertEquals(false, actual.DocuSignFlag__c); /* after sending, flag should be set to false */
        System.assertEquals(1, aesSuccessMock.requestCount);
    }

    @IsTest static void reallocation_canGenerateJson_ITB() {

        genesis__Applications__c app = getApp();
        app.Credit_Policy_Approval_Models__c = null;
        app.Risk_Model_Source__c = 'hm';
        update app;

        String actualJson = MW_AllocationEngineHandler.toJson(new List<Id> {app.Id},
                null,
                MW_AllocationEngineHandler.REALLOCATION);

        Jsons actual = parseJsons(actualJson);
        assertTopLevelFields(actual);

        actual = actual.key('allocation-requests').index(0);
        assertCommonRequestFields(app, actual);
        assertAllocationRequestFields(app, actual, null);
        assertReallocationRequestFields(app, actual);
    }

    @IsTest static void reallocation_canGenerateJson_ITB_nullProgramId() {

        genesis__Applications__c app = getApp();
        app.Credit_Policy_Approval_Models__c = null;
        app.Risk_Model_Source__c = 'hm';
        app.Program_id__c = null;
        update app;

        String actualJson = MW_AllocationEngineHandler.toJson(new List<Id> {app.Id},
                null,
                MW_AllocationEngineHandler.REALLOCATION);

        Jsons actual = parseJsons(actualJson);
        assertTopLevelFields(actual);

        actual = actual.key('allocation-requests').index(0);
        assertCommonRequestFields(app, actual, true);
        assertAllocationRequestFields(app, actual, null);
        assertReallocationRequestFields(app, actual);
    }

    @IsTest static void reallocation_canGenerateJson_OTB() {

        genesis__Applications__c app = getApp();
        app.Credit_Policy_Approval_Models__c = 'crb_otb';
        app.Risk_Model_Source__c = 'hm';
        update app;

        String actualJson = MW_AllocationEngineHandler.toJson(new List<Id> {app.Id},
                null,
                MW_AllocationEngineHandler.REALLOCATION);

        Jsons actual = parseJsons(actualJson);
        assertTopLevelFields(actual);

        actual = actual.key('allocation-requests').index(0);
        assertCommonRequestFields(app, actual);
        assertAllocationRequestFields(app, actual, 'crb_otb');
        assertReallocationRequestFields(app, actual);
    }

    /**
     * Turndown (currently only crb) loans
     */
    @IsTest static void reallocation_canGenerateJson_CRB() {

        genesis__Applications__c app = getApp();
        app.Credit_Policy_Approval_Models__c = 'crb_otb';
        app.Risk_Model_Source__c = 'crb';
        update app;

        String actualJson = MW_AllocationEngineHandler.toJson(new List<Id> {app.Id},
                null,
                MW_AllocationEngineHandler.REALLOCATION);

        Jsons actual = parseJsons(actualJson);
        assertTopLevelFields(actual);

        actual = actual.key('allocation-requests').index(0);
        assertCommonRequestFields(app, actual);
        assertAllocationRequestFields(app, actual, 'crb');
        assertReallocationRequestFields(app, actual);
    }

    @IsTest static void realloaction_handlesValidationFailures() {

        /* should not produce an error, just return */
        MW_AllocationEngineHandler.handleReallocation(null);

        genesis__Applications__c newApp = getNewApp();
        newApp.Allocation_ID__c = '123';
        update newApp;

        /* trigger validation failure */
        MW_AllocationEngineHandler.handleReallocation(toIds(getNewAppAsList()));

        genesis__Applications__c actual = getNewApp();
        System.assertEquals(MW_AllocationEngineHandler.REALLOCATION, actual.Allocation_Operation_Error__c);

        List<clcommon__Batch_Process_Log__c> logs = getCommonLogs();

        System.assertEquals(1, logs.size());
        clcommon__Batch_Process_Log__c log = logs.get(0);

        System.assertEquals('INFO', log.clcommon__Log_Level__c);
        System.assertEquals('Info', log.clcommon__Type__c);
        System.assertEquals(actual.Id, log.clcommon__Batch_Id__c);

        System.assert(log.clcommon__Message__c.contains('Can not execute operation: reallocation for Lead Id: ' + REALISTIC_UUID));
        System.assert(log.clcommon__Message__c.contains('Field: Allocation_Timestamp__c cannot be null'));
        System.assert(log.clcommon__Message__c.contains('No previously allocated partners were found'));

        System.debug(log.clcommon__Message__c);
    }

    @IsTest static void realloaction_handlesApiProductFlowValidationFailure() {

        List<genesis__Applications__c> apps = getApps();
        apps[0].Program_id__c = null;
        apps[0].utm_source__c = OFFERS_API;
        apps[1].Program_id__c = null;
        apps[1].utm_source__c = OFFERS_API;
        update apps;

        MW_AllocationEngineHandler.handleReallocation(toIds(apps));

        List<genesis__Applications__c> actual = getApps();
        System.assertEquals(MW_AllocationEngineHandler.REALLOCATION, actual[0].Allocation_Operation_Error__c);
        System.assertEquals(MW_AllocationEngineHandler.ADVP, actual[1].Allocation_Operation_Error__c);

        List<clcommon__Batch_Process_Log__c> logs = getCommonLogs();

        System.assertEquals(2, logs.size());

        Map<Id, clcommon__Batch_Process_Log__c> logById = logsByBatchId(logs);

        clcommon__Batch_Process_Log__c log1 = logById.get(actual.get(0).Id);
        clcommon__Batch_Process_Log__c log2 = logById.get(actual.get(1).Id);

        System.debug(logs);
        System.assert(log1 != null && log1.clcommon__Message__c.contains('Can not execute operation: reallocation for Lead Id: abc123 due to: Program Id is null and default program id cannot be used due to utm_source__c: offers-api and api product flow: offers-api'));
        System.assert(log2 != null && log2.clcommon__Message__c.contains(OFFERS_API_ADVP_FAILURE_MSG_APP2));
    }

    @IsTest static void realloaction_handlesCalloutExceptionErrors() {

        Test.setMock(HttpCalloutMock.class, new AESCalloutExceptionMock());
        Test.startTest();

        MW_AllocationEngineHandler.handleReallocation(toIds(getAppAsList()));

        Test.stopTest();

        genesis__Applications__c actual = getApp();
        System.assertEquals(MW_AllocationEngineHandler.REALLOCATION, actual.Allocation_Operation_Error__c);

        List<clcommon__Batch_Process_Log__c> bpls = getCommonLogs();
        System.assertEquals(1, bpls.size(), 'Should have a log for each app');

        Map<Id, clcommon__Batch_Process_Log__c> logById = logsByBatchId(bpls);

        clcommon__Batch_Process_Log__c log1 = logById.get(actual.Id);

        System.assert(log1 != null);
        System.assert(log1.clcommon__Message__c.contains('Local exception'));
    }

    @IsTest static void reallocation_handles500Errors() {
        List<genesis__Applications__c> apps = getAppAsList();

        AESServerErrorMock errorMock = new AESServerErrorMock();
        Test.setMock(HttpCalloutMock.class, errorMock);
        Test.startTest();

        MW_AllocationEngineHandler.handleReallocation(toIds(apps));

        Test.stopTest();

        System.assertEquals(5, errorMock.attempts);

        List<genesis__Applications__c> actual = getAppAsList();
        System.assertEquals(1, actual.size());
        System.assertEquals(MW_AllocationEngineHandler.REALLOCATION, actual.get(0).Allocation_Operation_Error__c);

        List<clcommon__Batch_Process_Log__c> bpls = getCommonLogs();
        System.assertEquals(1, bpls.size(), 'Should have a log for each app');

        Map<Id, clcommon__Batch_Process_Log__c> logById = logsByBatchId(bpls);

        clcommon__Batch_Process_Log__c log1 = logById.get(actual.get(0).Id);

        System.assert(log1 != null);

        System.assert(log1.clcommon__Message__c.contains('5xx response, meaning unhandled AES error'));
    }

    @IsTest static void reallocation_handles400Errors() {

        List<genesis__Applications__c> apps = getAppAsList();

        Test.setMock(HttpCalloutMock.class, new AESValidationFailureMock());
        Test.startTest();

        MW_AllocationEngineHandler.handleReallocation(toIds(apps));

        Test.stopTest();

        List<genesis__Applications__c> actual = getAppAsList();
        System.assertEquals(1, actual.size());
        System.assertEquals(MW_AllocationEngineHandler.REALLOCATION, actual.get(0).Allocation_Operation_Error__c);

        List<clcommon__Batch_Process_Log__c> bpls = getCommonLogs();
        System.assertEquals(1, bpls.size(), 'Should have a log for each app');

        Map<Id, clcommon__Batch_Process_Log__c> logById = logsByBatchId(bpls);

        clcommon__Batch_Process_Log__c log1 = logById.get(actual.get(0).Id);

        System.assert(log1 != null);
        System.assert(log1.clcommon__Message__c.contains('4xx response'));
        System.assert(log1.clcommon__Message__c.contains('Check loan batch process logs and DataDog for more info'));

        List<loan__Batch_Process_Log__c> loanLogs = getLoanLogs();
        System.assertEquals(1, loanLogs.size());
        System.assert(loanLogs.get(0).loan__Message__c.contains('Missing foo bar'));
    }

    @IsTest static void reallocation_handles200Success() {

        List<genesis__Applications__c> apps = getApps();
        apps[1].Program_id__c = null;
        update apps[1];

        Test.setMock(HttpCalloutMock.class, new AESSuccessMock());
        Test.startTest();

        MW_AllocationEngineHandler.handleReallocation(null);

        MW_AllocationEngineHandler.handleReallocation(toIds(apps));

        Test.stopTest();

        List<genesis__Applications__c> actual = getApps();
        System.assertEquals(2, actual.size());
        System.assert(actual.get(1).Program_id__c == null);

        System.assertEquals(0, getCommonLogs().size(), 'No common logs generated for success by CLS');
        System.assertEquals(0, getLoanLogs().size(), 'No loan logs generated for success by CLS');
    }

    /**
     * Assert CustomTriggerOnApplication does not fire recursively after AES sets value
     * Manual version will look identical, so no need to create a duplicate test.
     */
    @IsTest static void reallocation_canHandleAESResponse() {

        MW_Settings__c settings = MW_Settings__c.getOrgDefaults();
        settings.Allocation_Engine_Deployment_Mode__c = 'FULL_MODE';
        update settings;

        genesis__Applications__c app = getApp();

        AESSuccessMock aesSuccessMock = new AESSuccessMock();
        Test.setMock(HttpCalloutMock.class, aesSuccessMock);
        Test.startTest();

        mockAESAllocationBehavior(app);

        Test.stopTest();

        System.assertEquals(0, aesSuccessMock.requestCount);
    }

    /**
     * Assert CustomTriggerOnApplication does not fire recursively after AES sets value
     * Manual version will look identical, so no need to create a duplicate test.
     */
    @IsTest static void reallocation_afterAgentVerifiedEnabled_canHandleAESResponse() {

        MW_Settings__c settings = MW_Settings__c.getOrgDefaults();
        settings.Allocation_Engine_Deployment_Mode__c = 'FULL_MODE';
        settings.Allocation_Engine_At_Agent_Verified__c = true;
        update settings;

        genesis__Applications__c app = getApp();

        AESSuccessMock aesSuccessMock = new AESSuccessMock();
        Test.setMock(HttpCalloutMock.class, aesSuccessMock);
        Test.startTest();

        /* reallocate to an investor that is different that the setup assigned one */
        mockAESAllocationBehavior(app, getInvestor('USAFCU'));

        Test.stopTest();

        System.assertEquals(0, aesSuccessMock.requestCount);
    }

    @IsTest static void manual_canGenerateJson() {

        genesis__Applications__c app = getApp();

        List<Allocation_Partner__c> partners = MW_AllocationEngineHandler.getAllocationPartnersByAppIds(new List<Id> {app.Id});
        Allocation_Partner__c manualPartner = partners.get(0);

        String actualJson = MW_AllocationEngineHandler.toJson(new List<Id> {app.Id},
                new List<Id> {manualPartner.Id},
                MW_AllocationEngineHandler.MANUAL);

        Jsons actual = parseJsons(actualJson);
        assertTopLevelFields(actual);

        actual = actual.key('allocation-requests').index(0);
        assertCommonRequestFields(app, actual);
        assertAllocationRequestFields(app, actual);
        assertReallocationRequestFields(app, actual);

        actual = actual.key('manualInvestor');
        System.assertEquals(1, actual.size());
        actual = actual.index(0);

        System.assert(!actual.getBoolean('leadPartner'));
        System.assertEquals(manualPartner.Investor__r.Investor_Code__c, actual.get('investorCode'));
    }

    @IsTest static void manual_canGenerateJson_nullProgramId() {

        genesis__Applications__c app = getApp();
        app.Program_id__c = null;
        update app;

        List<Allocation_Partner__c> partners = MW_AllocationEngineHandler.getAllocationPartnersByAppIds(new List<Id> {app.Id});
        Allocation_Partner__c manualPartner = partners.get(0);

        String actualJson = MW_AllocationEngineHandler.toJson(new List<Id> {app.Id},
                new List<Id> {manualPartner.Id},
                MW_AllocationEngineHandler.MANUAL);

        Jsons actual = parseJsons(actualJson);
        assertTopLevelFields(actual);

        actual = actual.key('allocation-requests').index(0);
        assertCommonRequestFields(app, actual, true);
        assertAllocationRequestFields(app, actual);
        assertReallocationRequestFields(app, actual);

        actual = actual.key('manualInvestor');
        System.assertEquals(1, actual.size());
        actual = actual.index(0);

        System.assert(!actual.getBoolean('leadPartner'));
        System.assertEquals(manualPartner.Investor__r.Investor_Code__c, actual.get('investorCode'));
    }

    /**
     * The selected app for this test has no manually selected partners and should fail accordingly.
     */
    @IsTest static void manual_handlesValidationFailure() {

        /* should not produce an error, just return */
        MW_AllocationEngineHandler.handleManual(null);

        /* trigger validation failure
        * due to request mapping LSP-661,
        * at least an allocation id is required to get to validation */
        genesis__Applications__c newApp = getNewApp();
        newApp.Allocation_ID__c = '123';
        update newApp;

        MW_AllocationEngineHandler.handleManual(toIds(getNewAppAsList()));

        genesis__Applications__c actual = getNewApp();
        System.assertEquals(MW_AllocationEngineHandler.MANUAL, actual.Allocation_Operation_Error__c);

        List<clcommon__Batch_Process_Log__c> logs = getCommonLogs();

        System.assertEquals(1, logs.size());
        clcommon__Batch_Process_Log__c log = logs.get(0);

        System.assertEquals('INFO', log.clcommon__Log_Level__c);
        System.assertEquals('Info', log.clcommon__Type__c);
        System.assertEquals(actual.Id, log.clcommon__Batch_Id__c);

        System.assert(log.clcommon__Message__c.contains('Can not execute operation: manual for Lead Id: ' + REALISTIC_UUID));
        System.assert(log.clcommon__Message__c.contains('Field: Allocation_Timestamp__c cannot be null'));
        System.assert(log.clcommon__Message__c.contains('No previously allocated partners were found'));
        System.assert(log.clcommon__Message__c.contains('No manually selected partners were found'));
    }

    @IsTest static void manual_handlesApiProductFlowValidationFailure() {

        List<genesis__Applications__c> apps = getApps();
        apps[0].Program_id__c = null;
        apps[0].utm_source__c = OFFERS_API;
        apps[1].Program_id__c = null;
        apps[1].utm_source__c = OFFERS_API;
        update apps;

        MW_AllocationEngineHandler.handleManual(toIds(apps));

        List<genesis__Applications__c> actual = getApps();
        System.assertEquals(MW_AllocationEngineHandler.MANUAL, actual[0].Allocation_Operation_Error__c);
        System.assertEquals(MW_AllocationEngineHandler.ADVP, actual[1].Allocation_Operation_Error__c);

        List<clcommon__Batch_Process_Log__c> logs = getCommonLogs();

        System.assertEquals(2, logs.size());

        Map<Id, clcommon__Batch_Process_Log__c> logById = logsByBatchId(logs);

        clcommon__Batch_Process_Log__c log1 = logById.get(actual.get(0).Id);
        clcommon__Batch_Process_Log__c log2 = logById.get(actual.get(1).Id);

        System.debug(logs);
        System.assert(log1 != null && log1.clcommon__Message__c.contains('Can not execute operation: manual for Lead Id: abc123 due to: Program Id is null and default program id cannot be used due to utm_source__c: offers-api and api product flow: offers-api'));
        System.assert(log2 != null && log2.clcommon__Message__c.contains(OFFERS_API_ADVP_FAILURE_MSG_APP2));
    }

    @IsTest static void manual_handlesCalloutExceptionErrors() {

        setManualPartner();

        Test.setMock(HttpCalloutMock.class, new AESCalloutExceptionMock());
        Test.startTest();

        MW_AllocationEngineHandler.handleManual(toIds(getAppAsList()));

        Test.stopTest();

        genesis__Applications__c actual = getApp();
        System.assertEquals(MW_AllocationEngineHandler.MANUAL, actual.Allocation_Operation_Error__c);

        List<clcommon__Batch_Process_Log__c> bpls = getCommonLogs();
        System.assertEquals(1, bpls.size(), 'Should have a log for each app');

        Map<Id, clcommon__Batch_Process_Log__c> logById = logsByBatchId(bpls);

        clcommon__Batch_Process_Log__c log1 = logById.get(actual.Id);

        System.assert(log1 != null);
        System.assert(log1.clcommon__Message__c.contains('Local exception'));
    }

    @IsTest static void manual_handles500Errors() {

        List<genesis__Applications__c> apps = getAppAsList();

        setManualPartner();

        AESServerErrorMock errorMock = new AESServerErrorMock();
        Test.setMock(HttpCalloutMock.class, errorMock);
        Test.startTest();
        MW_AllocationEngineHandler.handleManual(toIds(apps));

        Test.stopTest();

        System.assertEquals(5, errorMock.attempts);

        genesis__Applications__c actual = getApp();
        System.assertEquals(MW_AllocationEngineHandler.MANUAL, actual.Allocation_Operation_Error__c);

        List<clcommon__Batch_Process_Log__c> bpls = getCommonLogs();
        System.assertEquals(1, bpls.size(), 'Should have a log for each app');

        Map<Id, clcommon__Batch_Process_Log__c> logById = logsByBatchId(bpls);

        clcommon__Batch_Process_Log__c log1 = logById.get(actual.Id);

        System.assert(log1 != null);
        System.assert(log1.clcommon__Message__c.contains('5xx response, meaning unhandled AES error'));
    }

    @IsTest static void manual_handles400Errors() {

        List<genesis__Applications__c> apps = getAppAsList();

        setManualPartner();

        Test.setMock(HttpCalloutMock.class, new AESValidationFailureMock());
        Test.startTest();

        MW_AllocationEngineHandler.handleManual(toIds(apps));

        Test.stopTest();

        genesis__Applications__c actual = getApp();
        System.assertEquals(MW_AllocationEngineHandler.MANUAL, actual.Allocation_Operation_Error__c);

        List<clcommon__Batch_Process_Log__c> bpls = getCommonLogs();
        System.assertEquals(1, bpls.size(), 'Should have a log for each app');

        Map<Id, clcommon__Batch_Process_Log__c> logById = logsByBatchId(bpls);

        clcommon__Batch_Process_Log__c log1 = logById.get(actual.Id);

        System.assert(log1 != null);
        System.assert(log1.clcommon__Message__c.contains('4xx response'));
        System.assert(log1.clcommon__Message__c.contains('Check loan batch process logs and DataDog for more info'));

        List<loan__Batch_Process_Log__c> loanLogs = getLoanLogs();
        System.assertEquals(1, loanLogs.size());
        System.assert(loanLogs.get(0).loan__Message__c.contains('Missing foo bar'));
    }

    @IsTest static void manual_handles200Success() {

        List<genesis__Applications__c> apps = getApps();
        apps[1].Program_id__c = null;
        update apps[1];

        setManualPartner();

        Test.setMock(HttpCalloutMock.class, new AESSuccessMock());
        Test.startTest();

        MW_AllocationEngineHandler.handleManual(null);

        MW_AllocationEngineHandler.handleManual(toIds(apps));

        Test.stopTest();

        List<genesis__Applications__c> actual = getApps();
        System.assertEquals(2, actual.size());
        System.assert(actual.get(1).Program_id__c == null);

        System.assertEquals(0, getCommonLogs().size(), 'No common logs generated for success by CLS');
        System.assertEquals(0, getLoanLogs().size(), 'No loan logs generated for success by CLS');
    }


    private static void setManualPartner() {
        setManualPartner(true);
    }

    /**
     * Sets the first allocation partner to assign to.
     * This allows the first app to pass validation in order to execute test manual requests.
     *
     * @param toggleDeploymentMode If true, toggles legacy mode on, then updates partner then dark mode no
     *                            This is to prevent the allocation partner trigger from firing as part of test setup.
     */
    private static void setManualPartner(Boolean toggleDeploymentMode) {

        MW_Settings__c mwSettings = MW_Settings__c.getOrgDefaults();

        if (toggleDeploymentMode) {
            mwSettings.Allocation_Engine_Deployment_Mode__c = 'LEGACY_MODE';
            update mwSettings;
        }

        List<Allocation_Partner__c> aps = getAllocationPartners();
        Allocation_Partner__c ap = aps.get(0);
        ap.Assign_To__c = true;
        update ap;

        if (toggleDeploymentMode) {
            mwSettings.Allocation_Engine_Deployment_Mode__c = 'DARK_MODE';
            update mwSettings;
        }
    }

    @IsTest static void cancelled_canGenerateJson() {
        genesis__Applications__c app = getApp();

        String actualJson = MW_AllocationEngineHandler.toJson(new List<Id> {app.Id},
                null,
                MW_AllocationEngineHandler.CANCELLED);

        System.debug('cancel json: ' + actualJson);

        Jsons actual = parseJsons(actualJson);
        assertTopLevelFields(actual);

        actual = actual.key('allocation-requests').index(0);
        assertCommonRequestFields(app, actual);

        System.assertEquals(app.Allocation_ID__c, actual.get('allocationId'));
        System.assertEquals(app.genesis__Status__c, actual.get('reason'));
    }

    @IsTest static void cancelled_canGenerateJson_nullProgramId() {
        genesis__Applications__c app = getApp();
        app.Program_id__c = null;
        update app;

        String actualJson = MW_AllocationEngineHandler.toJson(new List<Id> {app.Id},
                null,
                MW_AllocationEngineHandler.CANCELLED);

        System.debug('cancel json: ' + actualJson);

        Jsons actual = parseJsons(actualJson);
        assertTopLevelFields(actual);

        actual = actual.key('allocation-requests').index(0);
        assertCommonRequestFields(app, actual, true);

        System.assertEquals(app.Allocation_ID__c, actual.get('allocationId'));
        System.assertEquals(app.genesis__Status__c, actual.get('reason'));
    }

    /**
     * In-flight applications are identified by no allocation id
     */
    @IsTest static void cancelled_canGenerateJson_inFlight() {

        /*
        First assert for an in-flight with an investor
         */
        genesis__Applications__c app = getApp();
        app.Allocation_ID__c = null;
        app.Program_id__c = null;
        update app;

        String actualJson = MW_AllocationEngineHandler.toJson(new List<Id> {app.Id},
                null,
                MW_AllocationEngineHandler.CANCELLED);

        System.debug('in-flight w/ investor cancel json: ' + actualJson);

        Jsons actual = parseJsons(actualJson);
        assertTopLevelFields(actual);

        actual = actual.key('allocation-requests')
                .index(0)
                .key('previousInvestor')
                .index(0);

        System.assertEquals(app.Investor__r.Investor_Code__c, actual.get('investorCode'));
        System.assertEquals(true, actual.getBoolean('leadPartner'));

        /*
        Now assert for an in-flight with no investor selected
         */
        app.Investor__c = null;
        update app;

        actualJson = MW_AllocationEngineHandler.toJson(new List<Id> {app.Id},
                null,
                MW_AllocationEngineHandler.CANCELLED);

        System.debug('in-flight w/o investor cancel json:' + actualJson);

        actual = parseJsons(actualJson);
        assertTopLevelFields(actual);

        actual = actual.key('allocation-requests')
                .index(0)
                .key('previousInvestor');

        System.assert(actual.isNull());
    }

    @IsTest static void cancelled_handlesValidationFailures() {

        /*
        switched from status null to loan amount null.
        status no longer works since documents are valid
        (required docs 0 which bumps status back to advp)
        */
        genesis__Applications__c app = getApp();
        app.genesis__Loan_Amount__c = null;
        update app;

        /* should not produce an error, just return */
        MW_AllocationEngineHandler.handleCancelled(null);

        /* trigger validation failure */
        MW_AllocationEngineHandler.handleCancelled(new List<Id> {app.Id});

        genesis__Applications__c actual = getApp();
        System.assertEquals(MW_AllocationEngineHandler.CANCELLED, actual.Allocation_Operation_Error__c);

        List<clcommon__Batch_Process_Log__c> logs = getCommonLogs();

        System.assertEquals(1, logs.size());
        clcommon__Batch_Process_Log__c log = logs.get(0);

        System.assertEquals('INFO', log.clcommon__Log_Level__c);
        System.assertEquals('Info', log.clcommon__Type__c);
        System.assertEquals(actual.Id, log.clcommon__Batch_Id__c);

        System.assert(log.clcommon__Message__c.contains('Can not execute operation: cancel for Lead Id: abc123'));
        System.assert(log.clcommon__Message__c.contains('Field: genesis__Loan_Amount__c cannot be null'));
    }

    @IsTest static void cancelled_handlesCalloutExceptionErrors() {

        List<genesis__Applications__c> apps = getAppAsList();

        Test.setMock(HttpCalloutMock.class, new AESCalloutExceptionMock());
        Test.startTest();

        MW_AllocationEngineHandler.handleCancelled(toIds(apps));

        Test.stopTest();

        genesis__Applications__c actual = getApp();
        System.assertEquals(MW_AllocationEngineHandler.CANCELLED, actual.Allocation_Operation_Error__c);

        List<clcommon__Batch_Process_Log__c> bpls = getCommonLogs();
        System.assertEquals(1, bpls.size(), 'Should have a log for each app');

        Map<Id, clcommon__Batch_Process_Log__c> logById = logsByBatchId(bpls);

        clcommon__Batch_Process_Log__c log1 = logById.get(actual.Id);

        System.assert(log1 != null);
        System.assert(log1.clcommon__Message__c.contains('Local exception'));
    }

    @IsTest static void cancelled_handles500Errors() {

        AESServerErrorMock errorMock = new AESServerErrorMock();
        Test.setMock(HttpCalloutMock.class, errorMock);
        Test.startTest();

        MW_AllocationEngineHandler.handleCancelled(toIds(getAppAsList()));

        Test.stopTest();

        System.assertEquals(5, errorMock.attempts);

        genesis__Applications__c actual = getApp();
        System.assertEquals(MW_AllocationEngineHandler.CANCELLED, actual.Allocation_Operation_Error__c);

        List<clcommon__Batch_Process_Log__c> bpls = getCommonLogs();
        System.assertEquals(1, bpls.size(), 'Should have a log for each app');

        Map<Id, clcommon__Batch_Process_Log__c> logById = logsByBatchId(bpls);

        clcommon__Batch_Process_Log__c log1 = logById.get(actual.Id);
        System.assert(log1 != null);
        System.assert(log1.clcommon__Message__c.contains('5xx response, meaning unhandled AES error'));
    }

    @IsTest static void cancelled_handles400Errors() {

        Test.setMock(HttpCalloutMock.class, new AESValidationFailureMock());
        Test.startTest();

        MW_AllocationEngineHandler.handleCancelled(toIds(getAppAsList()));

        Test.stopTest();

        genesis__Applications__c actual = getApp();
        System.assertEquals(MW_AllocationEngineHandler.CANCELLED, actual.Allocation_Operation_Error__c);

        List<clcommon__Batch_Process_Log__c> bpls = getCommonLogs();
        System.assertEquals(1, bpls.size(), 'Should have a log for each app');

        Map<Id, clcommon__Batch_Process_Log__c> logById = logsByBatchId(bpls);

        clcommon__Batch_Process_Log__c log1 = logById.get(actual.Id);

        System.assert(log1 != null);
        System.assert(log1.clcommon__Message__c.contains('4xx response'));
        System.assert(log1.clcommon__Message__c.contains('Check loan batch process logs and DataDog for more info'));

        List<loan__Batch_Process_Log__c> loanLogs = getLoanLogs();
        System.assertEquals(1, loanLogs.size());
        System.assert(loanLogs.get(0).loan__Message__c.contains('Missing foo bar'));
    }

    @IsTest static void cancelled_handles200Success() {

        List<genesis__Applications__c> apps = getApps();
        apps[1].Program_id__c = null;
        update apps[1];

        Test.setMock(HttpCalloutMock.class, new AESSuccessMock());
        Test.startTest();

        MW_AllocationEngineHandler.handleCancelled(null);

        MW_AllocationEngineHandler.handleCancelled(toIds(apps));

        Test.stopTest();

        List<genesis__Applications__c> actual = getApps();
        System.assertEquals(2, actual.size());
        System.assert(actual.get(1).Program_id__c == null);

        System.assertEquals(0, getCommonLogs().size(), 'No common logs generated for success by CLS');
        System.assertEquals(0, getLoanLogs().size(), 'No loan logs generated for success by CLS');
    }

    @IsTest static void cancelled_validNulls_handles200Success() {

        Test.setMock(HttpCalloutMock.class, new AESSuccessMock());
        Test.startTest();

        List<genesis__Applications__c> apps = getAppAsList();
        for (genesis__Applications__c app : apps) {
            app.genesis__APR__c	= null;
            app.Pricing_Tier__c	= null;
            app.FICO__c = null;
            app.Monthly_DTI__c = null;
            app.Net_Disposable_Income_NDI_Num__c = null;
        }
        update apps;

        MW_AllocationEngineHandler.handleCancelled(toIds(apps));

        Test.stopTest();

        System.assertEquals(0, getCommonLogs().size(), 'No common logs generated for success by CLS');
        System.assertEquals(0, getLoanLogs().size(), 'No loan logs generated for success by CLS');
    }

    @IsTest static void cancelled_canHandleAESResponse() {

        MW_Settings__c settings = MW_Settings__c.getOrgDefaults();
        settings.Allocation_Engine_Deployment_Mode__c = 'FULL_MODE';
        update settings;

        AESSuccessMock aesSuccessMock = new AESSuccessMock();
        Test.setMock(HttpCalloutMock.class, aesSuccessMock);
        Test.startTest();

        /* skuid user would update the app to expired or similar decline status or maybe even by apex */
        genesis__Applications__c app = getApp();
        app.genesis__Status__c = 'Expired';
        update app;

        /* AES will update the related allocation engine fields */
        app.Allocation_Operation_Error__c = '';
        update app;

        Test.stopTest();

        /*
        We should have 1 callout.
        1. on status change to 'cancel' status list, the callout executes
        2. after the response, there should be no more
         */
        System.assertEquals(1, aesSuccessMock.requestCount);
        System.assert(aesSuccessMock.endpoints.get(0).contains('cancel'));
    }

    @IsTest static void final_canGenerateJson() {
        genesis__Applications__c app = getApp();

        String actualJson = MW_AllocationEngineHandler.toJson(new List<Id> {app.Id},
                null,
                MW_AllocationEngineHandler.FINALIZED);

        System.debug('final json: ' + actualJson);

        Jsons actual = parseJsons(actualJson);
        assertTopLevelFields(actual);

        actual = actual.key('allocation-requests').index(0);
        assertCommonRequestFields(app, actual);

        System.assertEquals(app.Allocation_ID__c, actual.get('allocationId'));
    }

    @IsTest static void final_canGenerateJson_nullProgramId() {
        genesis__Applications__c app = getApp();
        app.Program_id__c = null;
        update app;

        String actualJson = MW_AllocationEngineHandler.toJson(new List<Id> {app.Id},
                null,
                MW_AllocationEngineHandler.FINALIZED);

        System.debug('final json: ' + actualJson);

        Jsons actual = parseJsons(actualJson);
        assertTopLevelFields(actual);

        actual = actual.key('allocation-requests').index(0);
        assertCommonRequestFields(app, actual, true);

        System.assertEquals(app.Allocation_ID__c, actual.get('allocationId'));
    }

    @IsTest static void final_handlesCalloutExceptionErrors() {

        Test.setMock(HttpCalloutMock.class, new AESCalloutExceptionMock());
        Test.startTest();

        MW_AllocationEngineHandler.handleFinal(toIds(getAppAsList()));

        Test.stopTest();

        genesis__Applications__c actual = getApp();
        System.assertEquals(MW_AllocationEngineHandler.FINALIZED, actual.Allocation_Operation_Error__c);

        List<clcommon__Batch_Process_Log__c> bpls = getCommonLogs();
        System.assertEquals(1, bpls.size(), 'Should have a log for each app');

        Map<Id, clcommon__Batch_Process_Log__c> logById = logsByBatchId(bpls);

        clcommon__Batch_Process_Log__c bpl = logById.get(actual.Id);
        System.assert(bpl != null);
        System.assert(bpl.clcommon__Message__c.contains('Local exception'));
    }

    @IsTest static void final_handles500Errors() {

        AESServerErrorMock errorMock = new AESServerErrorMock();
        Test.setMock(HttpCalloutMock.class, errorMock);
        Test.startTest();

        MW_AllocationEngineHandler.handleFinal(toIds(getAppAsList()));

        Test.stopTest();

        System.assertEquals(5, errorMock.attempts);

        genesis__Applications__c actual = getApp();
        System.assertEquals(MW_AllocationEngineHandler.FINALIZED, actual.Allocation_Operation_Error__c);

        List<clcommon__Batch_Process_Log__c> bpls = getCommonLogs();
        System.assertEquals(1, bpls.size(), 'Should have a log for each app');

        Map<Id, clcommon__Batch_Process_Log__c> logById = logsByBatchId(bpls);

        clcommon__Batch_Process_Log__c bpl = logById.get(actual.Id);
        System.assert(bpl != null);
        System.assert(bpl.clcommon__Message__c.contains('5xx response, meaning unhandled AES error'));
    }

    @IsTest static void final_handles400Errors() {

        Test.setMock(HttpCalloutMock.class, new AESValidationFailureMock());
        Test.startTest();

        MW_AllocationEngineHandler.handleFinal(toIds(getAppAsList()));

        Test.stopTest();

        genesis__Applications__c actual = getApp();
        System.assertEquals(MW_AllocationEngineHandler.FINALIZED, actual.Allocation_Operation_Error__c);

        List<clcommon__Batch_Process_Log__c> bpls = getCommonLogs();
        System.assertEquals(1, bpls.size(), 'Should have a log for each app');

        Map<Id, clcommon__Batch_Process_Log__c> logById = logsByBatchId(bpls);

        clcommon__Batch_Process_Log__c bpl = logById.get(actual.Id);
        System.assert(bpl != null);
        System.assert(bpl.clcommon__Message__c.contains('4xx response'));
        System.assert(bpl.clcommon__Message__c.contains('Check loan batch process logs and DataDog for more info'));

        List<loan__Batch_Process_Log__c> loanLogs = getLoanLogs();
        System.assertEquals(1, loanLogs.size());
        System.assert(loanLogs.get(0).loan__Message__c.contains('Missing foo bar'));
    }

    @IsTest static void final_handles200Success() {

        List<genesis__Applications__c> apps = getApps();
        apps[1].Program_id__c = null;
        update apps[1];

        Test.setMock(HttpCalloutMock.class, new AESSuccessMock());
        Test.startTest();

        MW_AllocationEngineHandler.handleFinal(null);

        MW_AllocationEngineHandler.handleFinal(toIds(apps));

        Test.stopTest();

        List<genesis__Applications__c> actual = getApps();
        System.assertEquals(2, actual.size());
        System.assert(actual.get(1).Program_id__c == null);

        System.assertEquals(0, getCommonLogs().size(), 'No common logs generated for success by CLS');
        System.assertEquals(0, getLoanLogs().size(), 'No loan logs generated for success by CLS');
    }

    @IsTest static void final_nullPricingTier_handles200Success() {

        List<genesis__Applications__c> apps = getAppAsList();
        for (genesis__Applications__c app : apps) {
            app.Pricing_Tier__c = null;
        }
        update apps;

        Test.setMock(HttpCalloutMock.class, new AESSuccessMock());
        Test.startTest();


        MW_AllocationEngineHandler.handleFinal(toIds(apps));

        Test.stopTest();

        System.assertEquals(0, getCommonLogs().size(), 'No common logs generated for success by CLS');
        System.assertEquals(0, getLoanLogs().size(), 'No loan logs generated for success by CLS');
    }

    @IsTest static void final_canHandleAESResponse() {

        MW_Settings__c settings = MW_Settings__c.getOrgDefaults();
        settings.Allocation_Engine_Deployment_Mode__c = 'FULL_MODE';
        update settings;

        genesis__Applications__c app = getApp();
        app.genesis__Status__c = PayoffConstants.FUNDED;
        update app;

        AESSuccessMock aesSuccessMock = new AESSuccessMock();
        Test.setMock(HttpCalloutMock.class, aesSuccessMock);
        Test.startTest();

        /* AES will update the related allocation engine fields */
        app.Allocation_Operation_Error__c = '';
        update app;

        Test.stopTest();

        System.assertEquals(0, aesSuccessMock.requestCount);
    }

    @IsTest static void canGenerateMessageMap() {

        Map<String, Object> actual1 = MW_AllocationEngineHandler.message(null);
        System.assertEquals(false, actual1.get('isBatch'));
        System.assertEquals(false, actual1.get('isQueueable'));
        System.assertEquals(false, actual1.get('isFuture'));
        System.assertEquals(false, actual1.get('isScheduled'));
        System.assertEquals(false, actual1.get('triggerIsExecuting'));
        System.assertEquals(null, actual1.get('triggerOperationType'));
        System.assert(actual1.get('quiddity') != null);

        String transactionId = (String) actual1.get('requestId');
        System.assert(transactionId != null && transactionId.length() > 0);

        MW_AllocationEngineHandler.message(null, null);

        Map<String, Object> actual2 = MW_AllocationEngineHandler.message('A thing happened');
        System.assertEquals(9, actual2.size());
        System.assertEquals('A thing happened', actual2.get('message'));

        Map<String, Object> actual3 = MW_AllocationEngineHandler.message('Another thing happened', new Map<String, Object>{
                'extraKey1' => 'first value',
                'extraKey2' => true
        });

        System.assertEquals(11, actual3.size());
        System.assertEquals('Another thing happened', actual3.get('message'));
        System.assertEquals('first value', actual3.get('extraKey1'));
        System.assertEquals(true, actual3.get('extraKey2'));
    }

    /**
     * This is what the AES microservice will do on success response at ADVP, REALLOCATION and MANUAL
     * @param app Update the app as per an allocation from the java microservice
     * @param investor The investor to allocate to
     */
    static void mockAESAllocationBehavior(genesis__Applications__c app, Account investor) {

        /* AES will clear any existing allocation partners */
        delete [
                SELECT Id
                FROM Allocation_Partner__c
                WHERE Application__c = :app.Id
        ];

        /* AES will insert new allocation partners */
        Allocation_Partner__c ap = new Allocation_Partner__c();
        ap.Investor__c = investor.Id;
        ap.Application__c = app.Id;
        ap.Lead_Partner__c = true;
        insert ap;

        Datetime aesTimestamp = Datetime.now();

        /* AES will update the related allocation engine fields */
        app.Expected_Chargeoff__c = 111;
        app.Expected_Yield__c = 112;
        app.Allocation_ID__c = new Uuid().getValue();
        app.Allocation_Timestamp__c = aesTimestamp;
        app.Last_Investor_Assigned_On__c = aesTimestamp;
        app.Allocation_Engine_Version__c = '1.0';
        app.Allocation_Detail__c = '';
        app.Allocation_Operation_Error__c = '';
        app.Allocation_Status__c = 'success';
        app.Investor__c = investor.Id;

        update app;
    }

    static void mockAESAllocationBehavior(genesis__Applications__c app) {
        mockAESAllocationBehavior(app, getInvestor());
    }

    private static Account getInvestor(String investorCode) {
        Account investor = [
                SELECT Id
                FROM Account
                WHERE Investor_Code__c = :investorCode
                LIMIT 1
        ];
        return investor;
    }

    private static Account getInvestor() {
        return getInvestor('FCU');
    }

    static List<Allocation_Partner__c> getAllocationPartners() {
        return [SELECT Id,
                Application__c,
                Lead_Partner__c,
                Assign_To__c,
                Investor__c
        FROM   Allocation_Partner__c];
    }

    static List<loan__Batch_Process_Log__c> getLoanLogs() {
        return [SELECT Id,
                loan__Origin__c,
                loan__Message__c,
                loan__Type__c,
                loan__Time__c
        FROM   loan__Batch_Process_Log__c];
    }

    static List<clcommon__Batch_Process_Log__c> getCommonLogs() {
        return [SELECT Id,
                clcommon__Log_Level__c,
                clcommon__Type__c,
                clcommon__Batch_Id__c,
                clcommon__Message__c
        FROM   clcommon__Batch_Process_Log__c];
    }

    /**
     * @param logs cl common logs to convert to map by id
     *
     * @return A map of Id to bpl
     */
    static Map<Id, clcommon__Batch_Process_Log__c> logsByBatchId(List<clcommon__Batch_Process_Log__c> logs) {
        Map<Id, clcommon__Batch_Process_Log__c> logMap = new Map<Id, clcommon__Batch_Process_Log__c>();
        for (clcommon__Batch_Process_Log__c log : logs) {
            logMap.put(log.clcommon__Batch_Id__c, log);
        }
        return logMap;
    }

    /**
     * These are top level json fields
     * @param actual Jsons instance
     */
    static void assertTopLevelFields(Jsons actual) {
        System.assertEquals('DARK_MODE', actual.get('deploymentMode'));
        System.assert(regexMatches('[a-z0-9-]+', actual.get('batchID')));
        System.assertEquals(1, actual.key('allocation-requests').size());
    }

    /**
     * These are fields that are on all requests to AES
     * @param expected app
     * @param actual jsons instance
     */
    static void assertCommonRequestFields(genesis__Applications__c expected, Jsons actual) {
        assertCommonRequestFields(expected, actual, false);
    }

    /**
     * These are fields that are on all requests to AES
     *
     * Update: no request should send null program ids now, it will not pass validation in cls.
     * Code has the ability to write it, leaving in due to late requirements
     *
     * @param expected app
     * @param actual jsons instance
     * @param nullProgramId assert program id as null.  If false, json checked with equality to expected
     */
    static void assertCommonRequestFields(genesis__Applications__c expected, Jsons actual, Boolean nullProgramId) {
        System.assertEquals(expected.Lead_ID__c, actual.get('requestID'));
        System.assertEquals(expected.Lead_ID__c, actual.get('leadGuid'));
        if (nullProgramId) {
            System.assertEquals('test-program-id', actual.get('programId'));
        } else {
            System.assert(expected.Program_id__c != null);
            System.assertEquals(expected.Program_id__c, actual.get('programId'));
        }
        System.assert(actual.containsKey('timestamp'));
    }

    /**Fields for all allocation requests
     * @param expected Expected app
     * @param actual Jsons instance
     */
    static void assertAllocationRequestFields(genesis__Applications__c expected, Jsons actual) {
        assertAllocationRequestFields(expected, actual, expected.Credit_Policy_Approval_Models__c);
    }

    /**
     * These are fields for all allocation requests, advp, reallocation, manual
     * @param expected Expected app
     * @param actual Jsons instance
     * @param approvalModels The string field which will be wrapped in an array
     */
    static void assertAllocationRequestFields(genesis__Applications__c expected, Jsons actual, String approvalModels) {

        List<String> expectedApprovalModels = approvalModels == null ? null : new List<String> {approvalModels};

        System.assertEquals(expected.genesis__Account__r.State__c, actual.get('lendingState'));
        System.assertEquals(expected.genesis__APR__c, actual.getDecimal('APR'));
        System.assertEquals(expected.genesis__Interest_Rate__c, actual.getDecimal('interestRate'));
        System.assertEquals(expected.Pricing_Tier__c, actual.get('tier'));
        System.assertEquals(expected.FICO__c, actual.getDecimal('FICO'));
        System.assertEquals(expected.genesis__Account__r.ZIP_Code__c, actual.get('zipCode'));
        System.assertEquals(expected.Monthly_DTI__c, actual.getDecimal('debtToIncome'));
        System.assertEquals(expected.Net_Disposable_Income_NDI_Num__c, actual.getDecimal('netDisposableIncome'));
        System.assertEquals(expectedApprovalModels, actual.getList('approvalModels'));
        System.assertEquals(expected.genesis__Loan_Amount__c, actual.getDecimal('loanAmount'));
        System.assertEquals(expected.Loan_Purpose__c, actual.get('loanPurpose'));

        actual = actual.key('channel');
        System.assertEquals(expected.utm_medium__c, actual.get('utmMedium'));
        System.assertEquals(expected.utm_source__c, actual.get('utmSource'));
        System.assertEquals(expected.utm_campaign__c, actual.get('utmCampaign'));
    }

    /**
     * These are fields that are on reallocation requests, reallocation, manual
     * @param expected Expected app
     * @param actual Jsons instance
     */
    static void assertReallocationRequestFields(genesis__Applications__c expected, Jsons actual) {
        System.assertEquals(expected.Allocation_ID__c, actual.get('allocationId'));
        System.assertEquals(expected.Expected_Yield__c, actual.getDecimal('expectedYield'));
        System.assertEquals(expected.Expected_Chargeoff__c, actual.getDecimal('expectedChargeoff'));
        System.assert(actual.containsKey('previousTimestamp'));

        /* assert previous investors */
        actual = actual.key('previousInvestor');
        System.assertEquals(2, actual.size());

        Jsons inv1 = actual.index(0);
        System.assertEquals('FCU', inv1.get('investorCode'));
        System.assertEquals(false, inv1.getBoolean('leadPartner'));

        Jsons inv2 = actual.index(1);
        System.assertEquals('GCSU', inv2.get('investorCode'));
        System.assertEquals(true, inv2.getBoolean('leadPartner'));

        /* jsons traversal similar to javascript optional chaining */
        Jsons inv3 = actual.index(2);
        System.assert(inv3.isNull());
    }

    /**
     * @param regex Regex for assertion
     * @param actual Value to test
     *
     * @return Whether a string matches or contains the pattern
     */
    static Boolean regexMatches(String regex, String actual) {
        Pattern p = Pattern.compile(regex);
        return p.matcher(actual).find();
    }

    /**
     * @return App that has a previous allocation state and supporting fields
     */
    static genesis__Applications__c getApp() {
        for (genesis__Applications__c app : getApps()) {
            if (app.Lead_ID__c == 'abc123') {
                System.debug('found: ' + app.Lead_ID__c + ' ' + app.Allocation_ID__c);
                return app;
            }
        }
        return null;
    }

    static List<genesis__Applications__c> getAppAsList() {
        return new List<genesis__Applications__c> { getApp() };
    }

    /**
     * @return The app that doesn't have previously selected partners or allocation
     */
    static genesis__Applications__c getNewApp() {
        for (genesis__Applications__c app : getApps()) {
            if (app.Lead_ID__c == REALISTIC_UUID) {
                System.debug('found: ' + app.Lead_ID__c + ' ' + app.Allocation_ID__c);
                return app;
            }
        }
        return null;
    }

    static List<genesis__Applications__c> getNewAppAsList() {
        return new List<genesis__Applications__c> { getNewApp() };
    }

    /**
     * @return The app configured for this unit test
     */
    static List<genesis__Applications__c> getApps() {
        return [SELECT Id,
                        genesis__Status__c,
                        genesis__APR__c,
                        genesis__Interest_Rate__c,
                        Pricing_Tier__c,
                        Program_id__c,
                        genesis__Term__c,
                        FICO__c,
                        Monthly_DTI__c,
                        Net_Disposable_Income_NDI_Num__c,
                        utm_medium__c,
                        utm_source__c,
                        utm_campaign__c,
                        utm_offerCode__c,
                        Lead_ID__c,
                        genesis__Loan_Amount__c,
                        genesis__Account__c,
                        genesis__Account__r.State__c,
                        genesis__Account__r.ZIP_Code__c,
                        Loan_Purpose__c,
                        Investor__c,
                        Investor__r.Investor_Code__c,
                        Credit_Policy_Approval_Models__c,
                        DocuSignFlag__c,
                        Risk_Model_Source__c,
                        Expected_Yield__c,
                        Expected_Chargeoff__c,
                        Allocation_ID__c,
                        Allocation_Timestamp__c,
                        Allocation_Operation_Error__c
               FROM   genesis__Applications__c
               ORDER BY Id];
    }

    static Credit_Policy__c makeCreditPolicyRecord(genesis__Applications__c application, Decimal fico, Decimal ndi) {
        Credit_Policy__c creditPolicy = new Credit_Policy__c();
        creditPolicy.request_intent__c = 'application';
        creditPolicy.FICO__c = fico;
        creditPolicy.Net_Disposable_Income_NDI__c = ndi == null ? null : String.valueOf(ndi);
        creditPolicy.Application__c = application.Id;
        return creditPolicy;
    }

    /*
    Apex doesn't allow for inner class statics.
    If Jsons is broken out into its own class, it should take this
     */
    static Jsons parseJsons(String str) {
        return new Jsons(JSON.deserializeUntyped(str));
    }

    static List<Id> toIds(List<genesis__Applications__c> apps) {
        List<Id> ids = new List<Id>();
        for (genesis__Applications__c app : apps) {
            ids.add(app.Id);
        }
        return ids;
    }
}