@isTest
public with sharing class MW_RetrieveBillsbyContractIdTest {
    static testMethod void MW_RetrieveBillsByContractIdWithInvalidId() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addParameter('invalid-param', 'test-id');
        req.requestURI = '/services/apexrest/bill/contract-id/?invalid-param=test-id';    
        req.httpMethod = 'GET'; 
        RestContext.request = req;  
        RestContext.response= res;  
        Test.startTest();
        MW_RetrieveBillsbyContractId.MW_RetrieveBillsbyContractId();
        Test.stopTest();
        
        system.assertNotEquals(null, res.responseBody, 'response is not null');

    }


    static testMethod void MW_RetrieveBillsByContractIdWithValidId() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addParameter('contract-id', 'test-id');
        req.requestURI = '/services/apexrest/bill/contract-id/?contract-id=test-id';    
        req.httpMethod = 'GET'; 
        RestContext.request = req;  
        RestContext.response= res;  
        Test.startTest();
        MW_RetrieveBillsbyContractId.MW_RetrieveBillsbyContractId();
        Test.stopTest();
        
        system.assertNotEquals(null, res.responseBody, 'response is not null');

    }
}
