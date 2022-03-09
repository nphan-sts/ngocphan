/**
 * Created by ilazarte on 2/7/22.
 */

@IsTest
private class MW_AllocationEngineHandlerTest {

    public class AESCalloutExceptionMock implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest httpRequest) {
            throw new CalloutException('Callout Failure Simulation');
        }
    }

    public class AESServerErrorMock implements HttpCalloutMock {

        public Integer attempts = 0;

        public HttpResponse respond(HttpRequest httpRequest) {

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

        public HttpResponse respond(HttpRequest httpRequest) {

            String requestBody = httpRequest.getBody();
            System.debug(LoggingLevel.INFO, 'Request Body: ' + requestBody);

            String json = '{ "timestamp": "2022-02-18T21:27:24.509Z", "data": { "allocation-responses": [ { "timestamp": "2022-02-18T21:27:24.509Z", "status": "success", "detail": "string", "allocationId": "string", "allocationEngineVersion": "string", "requestID": "string", "capitalPartnerInfo": [ { "capitalPartnerName": "string", "investorCode": "string", "leadPartner": true } ] } ] }, "errors": [] }';

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(json);
            res.setStatusCode(201);
            return res;
        }
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

        Object obj;

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
        insert mwSettings;

        Account investor1 = MW_GlobalTestUtility.GetAccount('Investor');
        investor1.Investor_Code__c = 'FCU';

        Account investor2 = MW_GlobalTestUtility.GetAccount('Investor');
        investor2.Investor_Code__c = 'GCSU';

        Account member1 = MW_GlobalTestUtility.GetAccount('Member');
        member1.ZIP_Code__c = '12345';

        Account member2 = MW_GlobalTestUtility.GetAccount('Member');
        member2.ZIP_Code__c = '12346';

        insert new List<Account> {investor1, investor2, member1, member2};

        clcommon__CL_Purpose__c purpose = new clcommon__CL_Purpose__c();
        purpose.Name = 'debt_consolidation';
        insert purpose;

        /* Used for most tests, but typical app wont have all this data */
        genesis__Applications__c app1 = MW_GlobalTestUtility.GetApplication();
        app1.genesis__Account__c = member1.Id;
        app1.genesis__Status__c = MW_AllocationEngineHandler.ADVP;
        app1.Investor__c = investor1.Id;
        app1.Lead_ID__c = 'abc123';
        app1.genesis__APR__c = 7.00;
        app1.genesis__Interest_Rate__c = 10.00;
        app1.Pricing_Tier__c = 't1';
        app1.genesis__Term__c = 5;
        app1.FICO__c = 700.00;
        app1.Monthly_DTI__c = 12;
        app1.Net_Disposable_Income_NDI_Num__c = 1200;
        app1.genesis__CL_Purpose__c = purpose.Id;
        app1.Credit_Policy_Approval_Models__c = 'crb_otb';
        app1.genesis__Loan_Amount__c = 25000.00;
        app1.utm_medium__c = 'medium';
        app1.utm_source__c = 'source';
        app1.utm_campaign__c = 'campaign';
        app1.Allocation_ID__c = 'alloc1';
        app1.Allocation_Operation_Error__c = MW_AllocationEngineHandler.ADVP;
        app1.Allocation_Timestamp__c = Datetime.now();
        app1.Expected_Yield__c = 321.11;
        app1.Expected_Chargeoff__c = 432.0;

        /* fresh advp apps will look more like this */
        genesis__Applications__c app2 = MW_GlobalTestUtility.GetApplication();
        app2.genesis__Account__c = member2.Id;
        app2.genesis__Status__c = MW_AllocationEngineHandler.ADVP;
        app2.Lead_ID__c = 'def456';
        app2.genesis__APR__c = 7.99;
        app2.genesis__Interest_Rate__c = 10.00;
        app2.Pricing_Tier__c = 't2';
        app2.genesis__Term__c = 5;
        app2.FICO__c = 700.00;
        app2.Monthly_DTI__c = 12;
        app2.Net_Disposable_Income_NDI_Num__c = 1200;
        app2.genesis__CL_Purpose__c = purpose.Id;
        app2.Credit_Policy_Approval_Models__c = null;
        app2.genesis__Loan_Amount__c = 15000.00;

        insert new List<genesis__Applications__c> {app1, app2};

        /* insert allocation partners only for the first app for scenarios */
        Allocation_Partner__c  ap1 = new Allocation_Partner__c();
        ap1.Application__c = app1.Id;
        ap1.Investor__c = investor1.Id;

        Allocation_Partner__c  ap2 = new Allocation_Partner__c();
        ap2.Application__c = app1.Id;
        ap2.Lead_Partner__c = true;
        ap2.Investor__c = investor2.Id;

        insert new List<Allocation_Partner__c> {ap1, ap2};
    }

    @IsTest static void testHandleInvalidDecisionLevel() {

        List<Id> ids = toIds(getApps());

        MW_AllocationEngineHandler.handleInvalidDecisionLevel('testHandleInvalidDecisionLevel', ids, 'potato');

        List<loan__Batch_Process_Log__c> logs = getLoanLogs();
        System.assertEquals(1, logs.size());
        loan__Batch_Process_Log__c loanLog = logs.get(0);

        System.assertEquals(
                'MW_AllocationEngineHandler: Invalid decision level of "potato" attempted for lead ids: abc123, def456',
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

        MW_AllocationEngineHandler.handleExceptionHandler('testHandleExceptionHandler', new List<String> {app.Id}, MW_AllocationEngineHandler.ADVP, e);

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

    @IsTest static void advp_canGenerateJson() {

        genesis__Applications__c app = getApp();

        String actualJson = MW_AllocationEngineHandler.toJson(new List<Id> {app.Id},
                null,
                MW_AllocationEngineHandler.ADVP);

        Jsons actual = parseJsons(actualJson);
        assertTopLevelFields(actual);

        actual = actual.key('allocation-requests').index(0);
        assertCommonRequestFields(app, actual);
        assertAllocationRequestFields(app, actual);
    }

    /**
     * When we pass in a list of app ids, if something fails validation, don't even send it.
     * Will send to review queue and mark as failed operation.
     * A log corresponding to the specific validation failures will appear on the cls application tab
     */
    @IsTest static void advp_handlesValidationFailure() {

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

        System.assertEquals('INFO', log.clcommon__Log_Level__c);
        System.assertEquals('Info', log.clcommon__Type__c);
        System.assertEquals(actual.Id, log.clcommon__Batch_Id__c);

        System.assert(log.clcommon__Message__c.contains('Can not execute operation: advp for Lead Id: abc123'));
        System.assert(log.clcommon__Message__c.contains('Field: genesis__Status__c cannot be null'));
        System.assert(log.clcommon__Message__c.contains('Field: genesis__APR__c cannot be null'));
        System.assert(log.clcommon__Message__c.contains('Field: genesis__Interest_Rate__c cannot be null'));
        System.assert(log.clcommon__Message__c.contains('Field: Pricing_Tier__c cannot be null'));
        System.assert(log.clcommon__Message__c.contains('Field: genesis__Term__c cannot be null'));
        System.assert(log.clcommon__Message__c.contains('Field: FICO__c cannot be null'));
        System.assert(log.clcommon__Message__c.contains('Field: Monthly_DTI__c cannot be null'));
        System.assert(log.clcommon__Message__c.contains('Field: Net_Disposable_Income_NDI_Num__c cannot be null'));
        System.assert(log.clcommon__Message__c.contains('Field: genesis__Loan_Amount__c cannot be null'));
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

        /* since apps are split into relloaction and advp, two loan logs should appear */
        System.assertEquals(2, loanLogs.size());
        System.assert(loanLogs.get(0).loan__Message__c.contains('Missing foo bar'));
    }

    @IsTest static void advp_handles200Success() {

        List<genesis__Applications__c> apps = getApps();

        Test.setMock(HttpCalloutMock.class, new AESSuccessMock());
        Test.startTest();

        MW_AllocationEngineHandler.handleAdvp(toIds(apps));

        Test.stopTest();

        List<genesis__Applications__c> actual = getApps();
        System.assertEquals(2, actual.size());
        System.assertEquals(null, actual.get(0).Allocation_Operation_Error__c);
        System.assertEquals(null, actual.get(1).Allocation_Operation_Error__c);

        System.assertEquals(0, getCommonLogs().size(), 'No common logs generated for success by CLS');
        System.assertEquals(0, getLoanLogs().size(), 'No loan logs generated for success by CLS');
    }

    @IsTest static void reallocation_canGenerateJson() {

        genesis__Applications__c app = getApp();

        String actualJson = MW_AllocationEngineHandler.toJson(new List<Id> {app.Id},
                null,
                MW_AllocationEngineHandler.REALLOCATION);

        Jsons actual = parseJsons(actualJson);
        assertTopLevelFields(actual);

        actual = actual.key('allocation-requests').index(0);
        assertCommonRequestFields(app, actual);
        assertAllocationRequestFields(app, actual);
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

        System.assert(log.clcommon__Message__c.contains('Can not execute operation: reallocation for Lead Id: def456'));
        System.assert(log.clcommon__Message__c.contains('Field: Expected_Yield__c cannot be null'));
        System.assert(log.clcommon__Message__c.contains('Field: Expected_Chargeoff__c cannot be null'));
        System.assert(log.clcommon__Message__c.contains('Field: Allocation_Timestamp__c cannot be null'));
        System.assert(log.clcommon__Message__c.contains('No previously allocated partners were found'));

        System.debug(log.clcommon__Message__c);
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

        List<genesis__Applications__c> apps = getAppAsList();

        Test.setMock(HttpCalloutMock.class, new AESSuccessMock());
        Test.startTest();

        MW_AllocationEngineHandler.handleReallocation(toIds(apps));

        Test.stopTest();

        List<genesis__Applications__c> actual = getAppAsList();
        System.assertEquals(1, actual.size());
        System.assertEquals(null, actual.get(0).Allocation_Operation_Error__c);

        System.assertEquals(0, getCommonLogs().size(), 'No common logs generated for success by CLS');
        System.assertEquals(0, getLoanLogs().size(), 'No loan logs generated for success by CLS');
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

    @IsTest static void manual_handlesValidationFailure() {

        /* should not produce an error, just return */
        MW_AllocationEngineHandler.handleManual(null, null);

        /* trigger validation failure
        * due to request mapping LSP-661,
        * at least an allocation id is required to get to validation */
        genesis__Applications__c newApp = getNewApp();
        newApp.Allocation_ID__c = '123';
        update newApp;

        MW_AllocationEngineHandler.handleManual(toIds(getNewAppAsList()), null);

        genesis__Applications__c actual = getNewApp();
        System.assertEquals(MW_AllocationEngineHandler.MANUAL, actual.Allocation_Operation_Error__c);

        List<clcommon__Batch_Process_Log__c> logs = getCommonLogs();

        System.assertEquals(1, logs.size());
        clcommon__Batch_Process_Log__c log = logs.get(0);

        System.assertEquals('INFO', log.clcommon__Log_Level__c);
        System.assertEquals('Info', log.clcommon__Type__c);
        System.assertEquals(actual.Id, log.clcommon__Batch_Id__c);

        System.assert(log.clcommon__Message__c.contains('Can not execute operation: manual for Lead Id: def456'));
        System.assert(log.clcommon__Message__c.contains('Field: Expected_Yield__c cannot be null'));
        System.assert(log.clcommon__Message__c.contains('Field: Expected_Chargeoff__c cannot be null'));
        System.assert(log.clcommon__Message__c.contains('Field: Allocation_Timestamp__c cannot be null'));
        System.assert(log.clcommon__Message__c.contains('No previously allocated partners were found'));
        System.assert(log.clcommon__Message__c.contains('No manually selected partners were found'));
    }

    @IsTest static void manual_handlesCalloutExceptionErrors() {
        Test.setMock(HttpCalloutMock.class, new AESCalloutExceptionMock());
        Test.startTest();

        MW_AllocationEngineHandler.handleManual(toIds(getAppAsList()), toIds(getAllocationPartners()));

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

        AESServerErrorMock errorMock = new AESServerErrorMock();
        Test.setMock(HttpCalloutMock.class, errorMock);
        Test.startTest();

        MW_AllocationEngineHandler.handleManual(toIds(apps), toIds(getAllocationPartners()));

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

        Test.setMock(HttpCalloutMock.class, new AESValidationFailureMock());
        Test.startTest();

        MW_AllocationEngineHandler.handleManual(toIds(apps), toIds(getAllocationPartners()));

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

        List<genesis__Applications__c> apps = getAppAsList();

        Test.setMock(HttpCalloutMock.class, new AESSuccessMock());
        Test.startTest();

        MW_AllocationEngineHandler.handleManual(toIds(apps), toIds(getAllocationPartners()));

        Test.stopTest();

        List<genesis__Applications__c> actual = getAppAsList();
        System.assertEquals(1, actual.size());
        System.assertEquals(null, actual.get(0).Allocation_Operation_Error__c);

        System.assertEquals(0, getCommonLogs().size(), 'No common logs generated for success by CLS');
        System.assertEquals(0, getLoanLogs().size(), 'No loan logs generated for success by CLS');
    }

    @IsTest static void cancelled_canGenerateJson() {
        genesis__Applications__c app = getApp();

        String actualJson = MW_AllocationEngineHandler.toJson(new List<Id> {app.Id},
                null,
                MW_AllocationEngineHandler.CANCELLED);

        Jsons actual = parseJsons(actualJson);
        System.debug('Cancel json: ' + actualJson);

        assertTopLevelFields(actual);

        actual = actual.key('allocation-requests').index(0);
        assertCommonRequestFields(app, actual);

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
        update app;

        String actualJson = MW_AllocationEngineHandler.toJson(new List<Id> {app.Id},
                null,
                MW_AllocationEngineHandler.CANCELLED);

        Jsons actual = parseJsons(actualJson);
        System.debug('Cancel json: ' + actualJson);
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

        actual = parseJsons(actualJson);
        System.debug('Cancel json: ' + actualJson);
        assertTopLevelFields(actual);

        actual = actual.key('allocation-requests')
                .index(0)
                .key('previousInvestor');

        System.assert(actual.isNull());
    }

    @IsTest static void cancelled_handlesValidationFailures() {

        genesis__Applications__c app = getApp();
        app.Allocation_ID__c = null;
        app.genesis__Status__c = null;
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
        System.assert(log.clcommon__Message__c.contains('Field: genesis__Status__c cannot be null'));
        System.assert(log.clcommon__Message__c.contains('Field: Allocation_ID__c cannot be null'));
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

        Test.setMock(HttpCalloutMock.class, new AESSuccessMock());
        Test.startTest();

        MW_AllocationEngineHandler.handleCancelled(toIds(getAppAsList()));

        Test.stopTest();

        genesis__Applications__c actual = getApp();
        System.assertEquals(null, actual.Allocation_Operation_Error__c);

        System.assertEquals(0, getCommonLogs().size(), 'No common logs generated for success by CLS');
        System.assertEquals(0, getLoanLogs().size(), 'No loan logs generated for success by CLS');
    }

    @IsTest static void final_canGenerateJson() {
        genesis__Applications__c app = getApp();

        String actualJson = MW_AllocationEngineHandler.toJson(new List<Id> {app.Id},
                null,
                MW_AllocationEngineHandler.FINALIZED);

        Jsons actual = parseJsons(actualJson);
        assertTopLevelFields(actual);

        actual = actual.key('allocation-requests').index(0);
        assertCommonRequestFields(app, actual);

        System.assertEquals(app.Allocation_ID__c, actual.get('allocationId'));
    }

    @IsTest static void final_handlesValidationFailures() {

        /* should not produce an error, just return */
        MW_AllocationEngineHandler.handleFinal(null);

        /* trigger validation failure */
        MW_AllocationEngineHandler.handleFinal(toIds(getNewAppAsList()));

        genesis__Applications__c actual = getNewApp();
        System.assertEquals(MW_AllocationEngineHandler.FINALIZED, actual.Allocation_Operation_Error__c);

        List<clcommon__Batch_Process_Log__c> logs = getCommonLogs();
        System.assertEquals(1, logs.size());

        Map<Id, clcommon__Batch_Process_Log__c> logById = logsByBatchId(logs);
        clcommon__Batch_Process_Log__c log = logById.get(actual.Id);

        System.assertEquals('INFO', log.clcommon__Log_Level__c);
        System.assertEquals('Info', log.clcommon__Type__c);
        System.assertEquals(actual.Id, log.clcommon__Batch_Id__c);

        System.assert(log.clcommon__Message__c.contains('Can not execute operation: final for Lead Id: def456'));
        System.assert(log.clcommon__Message__c.contains('Field: Allocation_ID__c cannot be null'));
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

        Test.setMock(HttpCalloutMock.class, new AESSuccessMock());
        Test.startTest();

        MW_AllocationEngineHandler.handleFinal(toIds(getAppAsList()));

        Test.stopTest();

        genesis__Applications__c actual = getApp();
        System.assertEquals(null, actual.Allocation_Operation_Error__c);

        System.assertEquals(0, getCommonLogs().size(), 'No common logs generated for success by CLS');
        System.assertEquals(0, getLoanLogs().size(), 'No loan logs generated for success by CLS');
    }

    static List<Allocation_Partner__c> getAllocationPartners() {
        return [SELECT Id,
                Application__c,
                Lead_Partner__c,
                Investor__c
        FROM   Allocation_Partner__c];
    }

    static List<Id> toIds(List<Allocation_Partner__c> allocationPartners) {
        List<Id> ids = new List<Id>();
        for (Allocation_Partner__c ap : allocationPartners) {
            ids.add(ap.Id);
        }

        return ids;
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
        System.assertEquals(expected.Lead_ID__c, actual.get('requestID'));
        System.assertEquals(expected.Lead_ID__c, actual.get('leadGuid'));
        System.assert(actual.containsKey('timestamp'));
    }

    /**
     * These are fields for all allocation requests, advp, reallocation, manual
     * @param expected Expected app
     * @param actual Jsons instance
     */
    static void assertAllocationRequestFields(genesis__Applications__c expected, Jsons actual) {
        System.assertEquals(expected.genesis__Status__c, actual.get('lendingState'));
        System.assertEquals(expected.genesis__APR__c, actual.getDecimal('APR'));
        System.assertEquals(expected.genesis__Interest_Rate__c, actual.getDecimal('interestRate'));
        System.assertEquals(expected.Pricing_Tier__c, actual.get('tier'));
        System.assertEquals(expected.FICO__c, actual.getDecimal('FICO'));
        System.assertEquals(expected.genesis__Account__r.ZIP_Code__c, actual.get('zipCode'));
        System.assertEquals(expected.Monthly_DTI__c, actual.getDecimal('debtToIncome'));
        System.assertEquals(expected.Net_Disposable_Income_NDI_Num__c, actual.getDecimal('netDisposableIncome'));
        System.assertEquals(new List<String> {expected.Credit_Policy_Approval_Models__c}, actual.getList('approvalModels'));
        System.assertEquals(expected.genesis__Loan_Amount__c, actual.getDecimal('loanAmount'));
        System.assertEquals(expected.genesis__CL_Purpose__r.Name, actual.get('loanPurpose'));

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
            if (app.Lead_ID__c == 'def456') {
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
                        genesis__Account__r.ZIP_Code__c,
                        genesis__CL_Purpose__r.Name,
                        Investor__c,
                        Investor__r.Investor_Code__c,
                        Credit_Policy_Approval_Models__c,
                        Expected_Yield__c,
                        Expected_Chargeoff__c,
                        Allocation_ID__c,
                        Allocation_Timestamp__c,
                        Allocation_Operation_Error__c
               FROM   genesis__Applications__c];
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