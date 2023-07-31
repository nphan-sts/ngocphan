@isTest
public with sharing class MW_WebhookHandlerTest {
    
    static testmethod void testGenerateJson() {
        Test.startTest();
        String result = MW_WebhookHandler.generateJSONContent('test', 'test', 'c9149473-e69f-ee12-38a7-d18b0cba847d', 'test');
        System.assert(result=='{"type":"test","data":[{"status":"test","envelope_id":"test"}]}', 'Ran successfully.');
        Test.stopTest();
    }

    static testmethod void testSoftPullNullJson() {
        Test.startTest();
        Boolean result = MW_WebhookHandler.generateSoftPullJson('test-id');
        System.assert(result, 'Ran successfully.');
        Test.stopTest();
    }
}
