@isTest 
//MW_RetrieveApplicationDocumentCategoryByLeadGuidTest
private class MW_RetrieveADCByLeadGuidTest {
    
    //test get application document category endpoint
    static testMethod void MW_RetrieveADCByLeadGuidTestWithInvalidDate() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addParameter('invalid-param', 'test-id');
        req.requestURI = '/services/apexrest/application-document-category/lead-guid/?invalid-param=test-guid';    
        req.httpMethod = 'GET'; 
        RestContext.request = req;  
        RestContext.response= res;  
        Test.startTest();
        MW_RetrieveADCByLeadGuid.MW_RetrieveADCByLeadGuid();
        Test.stopTest();
        
        system.assertNotEquals(null, res.responseBody, 'response is not null');
    }

    //test get application document category endpoint
    static testMethod void MW_RetrieveADCByLeadGuidTestWithValidDate() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addParameter('lead-guid', 'test-guid');
        req.requestURI = '/services/apexrest/application-document-category/lead-guid/?lead-guid=test-guid';

        req.httpMethod = 'GET'; 
        RestContext.request = req;  
        RestContext.response= res;  
        Test.startTest();
        MW_RetrieveADCByLeadGuid.MW_RetrieveADCByLeadGuid();
        Test.stopTest(); 
        
        
        
        system.assertNotEquals(null, res.responseBody, 'response is not null');
    }
}
