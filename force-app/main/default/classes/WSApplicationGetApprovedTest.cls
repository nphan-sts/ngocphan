@isTest
private class WSApplicationGetApprovedTest {

    static testMethod void testGetApproved() {
    	String leadId = '9ffffff9-9fff-f999-ff99-9f9f9f9f9f9f';
    	Date originationDate = Date.today().addDays(2);

        Account acct = TestDataFactory.createTestAccount();
        insert acct;

        Account inv = TestDataFactory.createTestInvestor();
        inv.Investor_Code__c = 'TEST';
        insert inv;

        genesis__Applications__c application = TestDataFactory.createTestApplication(acct.Id, inv.Id, leadId,
        	Date.today().addDays(2), 'Approved for funding');
        insert application;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Application/getApproved';
        req.addParameter('investor_id', 'TEST');
        req.addParameter('request_type', 'origination_package');
        req.addParameter('origination_date', originationDate.year() + '-' + originationDate.month() + '-' + originationDate.day());
        //req.setHeader('Content-Type', 'application/json');
		//req.setHeader('Accept','application/json');

        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;


        Test.startTest();
        WSApplicationGetApproved.getApproved();
        Test.stopTest();

        List<String> leadIds = (List<String>) JSON.deserialize(res.responseBody.toString(), List<String>.class);
        System.assert(leadIds.contains(leadId));
    }
    static testMethod void testGetApproved1() {
    	String leadId = '9ffffff9-9fff-f999-ff99-9f9f9f9f9f9f';
    	Date originationDate = Date.today().addDays(2);

        Account acct = TestDataFactory.createTestAccount();
        insert acct;

        Account inv = TestDataFactory.createTestInvestor();
        inv.Investor_Code__c = 'TEST';
        insert inv;

        genesis__Applications__c application = TestDataFactory.createTestApplication(acct.Id, inv.Id, leadId,
        	Date.today().addDays(2), 'pre_funding');
        insert application;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Application/getApproved';
        req.addParameter('investor_id', 'TEST');
        req.addParameter('request_type', 'prelim_origination_package');
        req.addParameter('origination_date', originationDate.year() + '-' + originationDate.month() + '-' + originationDate.day());
        //req.setHeader('Content-Type', 'application/json');
		//req.setHeader('Accept','application/json');

        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;


        Test.startTest();
        WSApplicationGetApproved.getApproved();
        Test.stopTest();

        List<String> leadIds = (List<String>) JSON.deserialize(res.responseBody.toString(), List<String>.class);
        
        System.assert(leadIds.contains(leadId));
    }

    static testMethod void testGetApprovedNoInvestorId() {
    	Date originationDate = Date.today().addDays(2);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Application/getApproved';
        req.addParameter('origination_date', originationDate.year() + '-' + originationDate.month() + '-' + originationDate.day());
        req.addParameter('request_type', 'prelim_origination_package');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        WSApplicationGetApproved.getApproved();
        Test.stopTest();

        System.assertEquals(400, res.statusCode);
        System.assertEquals('investor_id is required', res.responseBody.toString());
    }

    static testMethod void testGetApprovedNoOriginationDate() {
    	RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Application/getApproved';
        req.addParameter('investor_id', 'TEST');
        req.addParameter('request_type', 'prelim_origination_package');

        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        WSApplicationGetApproved.getApproved();
        Test.stopTest();

        System.assertEquals(400, res.statusCode);
        System.assertEquals('origination_date is required', res.responseBody.toString());
    }
}