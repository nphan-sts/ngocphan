@isTest
public with sharing class MW_RetrieveEmpInfobyAppIdTest {
    static testMethod void MW_RetrieveEmpInfobyAppIdTestWithInvalidId() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addParameter('invalid-param', 'test-id');
        req.requestURI = '/services/apexrest/employment-information/application-id/?invalid-param=test-id';    
        req.httpMethod = 'GET'; 
        RestContext.request = req;  
        RestContext.response= res;  
        Test.startTest();
        MW_RetrieveEmpInfobyAppId.MW_RetrieveEmpInfobyAppId();
        Test.stopTest();
        
        system.assertNotEquals(null, res.responseBody, 'response is not null');
    }

    static testMethod void MW_RetrieveEmpInfobyAppIdTestWithValidId() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addParameter('application-id', 'test-id');
        req.requestURI = '/services/apexrest/employment-information/application-id/?contract-id=test-id';    
        req.httpMethod = 'GET'; 
        RestContext.request = req;  
        RestContext.response= res;  
        Test.startTest();
        MW_RetrieveEmpInfobyAppId.MW_RetrieveEmpInfobyAppId();
        Test.stopTest();
        
        system.assertNotEquals(null, res.responseBody, 'response is not null');

    }
}