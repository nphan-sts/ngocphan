@isTest
public with sharing class MW_RetrieveBankAcctbyAccountIdTest {
    static testMethod void MW_RetrieveBAbyAccountIdWithInvalidId() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addParameter('invalid-param', 'test-id');
        req.requestURI = '/services/apexrest/bank-account/account-id/?invalid-param=test-id';    
        req.httpMethod = 'GET'; 
        RestContext.request = req;  
        RestContext.response= res;  
        Test.startTest();
        MW_RetrieveBankAcctbyAccountId.MW_RetrieveBankAcctbyAccountId();
        Test.stopTest();
        
        system.assertNotEquals(null, res.responseBody, 'response is not null');

    }


    static testMethod void MW_RetrieveBAbyAccountIdWithValidId() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addParameter('account-id', 'test-id');
        req.requestURI = '/services/apexrest/bank-account/account-id/?account-id=test-id';    
        req.httpMethod = 'GET'; 
        RestContext.request = req;  
        RestContext.response= res;  
        Test.startTest();
        MW_RetrieveBankAcctbyAccountId.MW_RetrieveBankAcctbyAccountId();
        Test.stopTest();
        
        system.assertNotEquals(null, res.responseBody, 'response is not null');

    }
}