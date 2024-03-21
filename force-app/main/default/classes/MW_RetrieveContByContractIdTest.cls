@isTest
public with sharing class MW_RetrieveContByContractIdTest {
    static testMethod void MW_RetrieveContByContractIdWithInvalidId() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addParameter('invalid-param', 'test-id');
        req.requestURI = '/services/apexrest/contingency/contract-id/?invalid-param=test-id';    
        req.httpMethod = 'GET'; 
        RestContext.request = req;  
        RestContext.response= res;  
        Test.startTest();
        MW_RetrieveContByContractId.MW_RetrieveContByContractId();
        Test.stopTest();
        
        system.assertNotEquals(null, res.responseBody, 'response is not null');

    }


    static testMethod void MW_RetrieveContByContractIdWithValidId() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addParameter('contract-id', 'test-id');
        req.requestURI = '/services/apexrest/contingency/contract-id/?contract-id=test-id';    
        req.httpMethod = 'GET'; 
        RestContext.request = req;  
        RestContext.response= res;  
        Test.startTest();
        MW_RetrieveContByContractId.MW_RetrieveContByContractId();
        Test.stopTest();
        
        system.assertNotEquals(null, res.responseBody, 'response is not null');

    }
}