@isTest
private class WSApplicationDocumentsTest {

    static testMethod void testGetDocuments() {
        String leadId = '9ffffff9-9fff-f999-ff99-9f9f9f9f9f9f';
    	String boxUrl = 'https://test.app.box.com/file/00000000000';
    	
        Account acct = TestDataFactory.createTestAccount();
        insert acct;
        
        Account inv = TestDataFactory.createTestInvestor();
        insert inv;
        
        genesis__Applications__c application = TestDataFactory.createTestApplication(acct.Id, inv.Id, leadId, 
        	Date.today().addDays(2), 'Approved for funding');
        insert application;
           
        clcommon__Party_Type__c partyType = TestDataFactory.createTestPartyType('BORROWER');
        insert partyType;
        
        genesis__Document_Category__c docCat = TestDataFactory.createTestDocumentCategory(partyType.Id, 'til');
        insert docCat;
        
        genesis__Application_Document_Category__c appDocCat = TestDataFactory.createTestApplicationDocumentCategory('TIL Document', 
        	application.Id, docCat.Id, boxUrl, 'CLEARED');
        insert appDocCat;
        
        List<Origination_Documents__c> documents = new List<Origination_Documents__c>();   
        for(Origination_Documents__c document: [select id, Code_FF__c, Application__c, type__c 
        										from Origination_Documents__c 
        										where Application__c = :application.Id and BoxUrl__c = null]) {
		   	document.BoxUrl__c = boxUrl;
		   	documents.add(document);
		}
		update documents;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/Application/Documents/getForDelivery';
        req.addParameter('lead_id', leadId);
       
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        WSApplicationDocuments.getDocuments();
        Test.stopTest();
        
        Map<String, List<String>> jsonRes = (Map<String, List<String>>) JSON.deserialize(res.responseBody.toString(), Map<String, List<String>>.class);
        
        System.assertEquals(boxUrl, jsonRes.get('preciseid').get(0));
        System.assertEquals(boxUrl, jsonRes.get('terms_of_use').get(0));
        System.assertEquals(boxUrl, jsonRes.get('eca').get(0));
        System.assertEquals(boxUrl, jsonRes.get('payoff_privacy_policy').get(0));
        System.assertEquals(boxUrl, jsonRes.get('credit_authorization').get(0));
        System.assertEquals(boxUrl, jsonRes.get('privacy_notice').get(0));
        System.assertEquals(boxUrl, jsonRes.get('til').get(0));
    }
    
    static testMethod void testGetDocumentsNoLeadId() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/Application/Documents/getForDelivery';
        
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        WSApplicationDocuments.getDocuments();
        Test.stopTest();
        
        System.assertEquals(400, res.statusCode);
        System.assertEquals('lead_id is required', res.responseBody.toString());
    }
}