@isTest
private class MW_LogUtilityTest {
    @testSetup
    static void setupTestData() {
        mwSettingDataSetup();
    }

    @isTest
    static void testLogUtility() {
        DmlException ex = new DmlException();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BasicCalloutMock());
        MW_LogUtility.error('class', 'appId', 'leadId', 'errorMethod', ex);

        MW_LogUtility.info('classInfo', 'appId info', 'leadId', 'info method', 'good message');
        Map<String, String> v = new Map<String, String>();
        v.put('data', 'test data');
        MW_LogUtility.warn('classInfo', 'appId info', 'leadId', 'warn method', v);

        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        MW_LogUtility.info('classInfo', 'appId info', 'leadId', 'info method', 'good message', response);

        response.setStatusCode(400);
        MW_LogUtility.info('classInfo', 'appId info', 'leadId', 'info method', 'bad message', response);

        MW_LogUtility.errorMessage('classInfo', 'label', new Map<String, String>());
        Test.stopTest();
    }

    @isTest
    static void testSlackCallout() {
        Test.startTest();
        String errorUrl = MW_SlackCallOut.logLevelChannels('Error');
        System.assertEquals(
            'https://hooks.slack.com/services/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',
            errorUrl,
            'Error URL set correctly.'
        );
        String otherUrl = MW_SlackCallOut.logLevelChannels('other url');
        System.assertEquals(
            'https://hooks.slack.com/services/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',
            otherUrl,
            'Other URL set correctly.'
        );
        Test.setMock(HttpCalloutMock.class, new BasicCalloutMock());
        MW_SlackCallOut.slackCallOut(otherUrl, 'message');
        Test.stopTest();
    }

    @isTest
    static void testSlackCallout2() {
        MW_LogUtility.Log log = new MW_LogUtility.Log();
        log.apexClass = 'apexClass';
        log.applicationId = 'applicationId';
        log.leadId = 'leadId';
        log.method = 'method';
        log.type = 'type';
        log.statusCode = 200;
        log.data = new MW_LogUtility.ExceptionDO(new DmlException());
        Test.startTest();
        MW_SlackCallOut.callSlack(log);
        Test.stopTest();
    }

    @isTest
    static void testDataDogCallout() {
        MW_LogUtility.Log log = new MW_LogUtility.Log();
        log.apexClass = 'apexClass';
        log.applicationId = 'applicationId';
        log.leadId = 'leadId';
        log.method = 'method';
        log.data = 'message';
        log.type = 'type';
        log.statusCode = 200;
        Test.startTest();
        TestCallOutMock mock = new TestCallOutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        mock.setExpected('message');
        MW_DataDogCallOut.send('message');
        mock.setExpected(log);
        MW_DataDogCallOut.send(log);
        Test.stopTest();
    }

    @IsTest
    static void testSendAllocationRulesetErrorsTest() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BasicCalloutMock());

        genesis__Checklist__c checkListWithDesc = new genesis__Checklist__c(
                genesis__Description__c = 'Exception, unable to do foo',
                genesis__Message__c = 'error123'
        );

        MW_LogUtility.sendAllocationRulesetErrors('myClass', 'appid123', 'leadid123', checkListWithDesc);

        List<clcommon__Batch_Process_Log__c> logs =
            [SELECT clcommon__Type__c,
                    clcommon__Batch_Id__c,
                    clcommon__Message__c
            FROM clcommon__Batch_Process_Log__c];

        System.assertEquals(1, logs.size());

        clcommon__Batch_Process_Log__c batchProcessLog = logs.get(0);
        System.assertEquals('Exception', batchProcessLog.clcommon__Type__c);
        System.assertEquals('appid123', batchProcessLog.clcommon__Batch_Id__c);
        System.assert(batchProcessLog.clcommon__Message__c.contains(checkListWithDesc.genesis__Message__c));

        Test.stopTest();
    }

    @isTest
    static void testBatchLogs() {
        Test.startTest();
        TestCallOutMock mock = new TestCallOutMock();
        mock.setBatch(true);
        mock.setExpected('test');
        Test.setMock(HttpCalloutMock.class, mock);

        MW_LogUtility.beginBatch();
        System.assertEquals(MW_LogUtility.isBatch, true);
        MW_LogUtility.info('MW_LogUtilityTest', 'testBatchLogs', 'test');
        System.assertEquals(MW_LogUtility.batchLogs.size(), 1);
        MW_LogUtility.sendBatch();

        Test.stopTest();
    }
    @isTest
    static void testWarnDagError() {
        Test.startTest();
        MW_LogUtility.dagError('TestDagErrorJob','TestDagJobClass','TestDagData');
        MW_LogUtility.warn('MW_LogUtility','warn','TestStr');
        Test.stopTest();
    }
    @isTest
    static void testgetLogRecord() {
        Test.startTest();
        MW_LogUtility.getLogRecord('MW_LogUtility','TestAppId','TestLeadId','getLogRecord','TestDagData','Log',null);       
        Test.stopTest();
    }
    
    public static void mwSettingDataSetup(){
        //data Setup
        MW_Settings__c mwSetting = new MW_Settings__c();
        mwSetting.Slack_Alert_Channels__c = 'https://hooks.slack.com/services/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';
        mwSetting.Slack_Info_Channels__c = 'https://hooks.slack.com/services/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';
        mwSetting.Slack_Alert_Icon__c = 'Alert';
        mwSetting.Slack_Info_Icon__c = 'Info';
        mwSetting.DataDogApiKey__c = 'testApiKey';
        mwSetting.DataDogTags__c = 'env:testing';
        mwSetting.DataDogApiURL__c = 'https://http-intake.logs.datadoghq.com/v1/input';
        insert mwSetting;
    }

    public class BasicCalloutMock implements HTTPCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/JSON');
            res.setStatusCode(200);
            return res;
        }
    }

    public class TestCallOutMock implements HTTPCalloutMock {
        private object expected;
        private boolean batch = false;

        public void setBatch(boolean e) {
            batch = e;
        }

        public void setExpected(object e) {
            expected = e;
        }

        private void expectObject(string j) {
            Map<string, object> body =
                (Map<string, object>) JSON.deserialize(j, Map<string, object>.class);
            object actual = body.get('message');
            string ddsource = (string) body.get('ddsource');
            System.assertEquals(actual, expected, 'Message should match excpected');
            System.assertEquals('Salesforce', ddsource, 'Ddsource should be Salesforce');
        }

        private void expectBatch(string j) {
            List<Map<string, object>> body =
                (List<Map<string, object>>) JSON.deserialize(j, List<Map<string, object>>.class);
            for (Map<string, object> obj : body) {
                object actual = obj.get('message');
                string ddsource = (string) obj.get('ddsource');
                System.assertEquals(actual, expected, 'Message should match excpected');
                System.assertEquals('Salesforce', ddsource, 'Ddsource should be Salesforce');
            }
        }

        public HttpResponse respond(HttpRequest req) {
            if (batch) {
                expectBatch(req.getBody());
            } else {
                expectObject(req.getBody());
            }
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/JSON');
            res.setStatusCode(200);
            return res;
        }
    }
}