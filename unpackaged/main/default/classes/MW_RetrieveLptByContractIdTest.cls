@isTest
public with sharing class MW_RetrieveLptByContractIdTest {
    static testMethod void MW_RetrieveLptsByContractIdWithInvalidId() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addParameter('invalid-param', 'test-id');
        req.requestURI = '/services/apexrest/lpt/contract-id/?invalid-param=test-id';    
        req.httpMethod = 'GET'; 
        RestContext.request = req;  
        RestContext.response= res;  
        Test.startTest();
        MW_RetrieveLptByContractId.MW_RetrieveLptByContractId();
        Test.stopTest();
        
        system.assertNotEquals(null, res.responseBody, 'response is not null');

    }


    static testMethod void MW_RetrieveLptsByContractIdWithValidId() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addParameter('contract-id', 'test-id');
        req.requestURI = '/services/apexrest/lpt/contract-id/?contract-id=test-id';    
        req.httpMethod = 'GET'; 
        RestContext.request = req;  
        RestContext.response= res;  
        Test.startTest();
        MW_RetrieveLptByContractId.MW_RetrieveLptByContractId();
        Test.stopTest();
        
        system.assertNotEquals(null, res.responseBody, 'response is not null');

    }
}
