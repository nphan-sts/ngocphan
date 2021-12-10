@isTest
public with sharing class MW_RetrieveBankAcctbyContractIdTest {
    static testMethod void MW_RetrieveBAbyContractIdWithInvalidId() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addParameter('invalid-param', 'test-id');
        req.requestURI = '/services/apexrest/bank-account/contract-id/?invalid-param=test-id';    
        req.httpMethod = 'GET'; 
        RestContext.request = req;  
        RestContext.response= res;  
        Test.startTest();
        MW_RetrieveBankAcctbyContractId.MW_RetrieveBankAcctbyContractId();
        Test.stopTest();
        
        system.assertNotEquals(null, res.responseBody, 'response is not null');

    }


    static testMethod void MW_RetrieveBAbyContractIdWithValidId() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addParameter('contract-id', 'test-id');
        req.requestURI = '/services/apexrest/bank-account/contract-id/?contract-id=test-id';    
        req.httpMethod = 'GET'; 
        RestContext.request = req;  
        RestContext.response= res;  
        Test.startTest();
        MW_RetrieveBankAcctbyContractId.MW_RetrieveBankAcctbyContractId();
        Test.stopTest();
        
        system.assertNotEquals(null, res.responseBody, 'response is not null');

    }
}
