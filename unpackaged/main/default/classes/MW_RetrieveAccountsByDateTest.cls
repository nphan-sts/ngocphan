@isTest 
private class MW_RetrieveAccountsByDateTest {
    @testSetup static void setup(){	
        list<account> accList = MW_DataFactoryTest.createAccounts(1);
        insert accList;

        contact newContact = new contact();
        newContact.lastName = 'test';
        newContact.AccountID = accList[0].id;
        newContact.Application__c = null;
        newContact.Application_Status_New__c = null;
        insert newContact;

        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;
    }
    //test get account endpoint
    static testMethod void MW_RetrieveAccountsByDateTestWithInvalidDate() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addParameter('invalid-param', '2019-10-28');
        req.requestURI = '/services/apexrest/application/date/?invalid-param=2019-10-28';    
        req.httpMethod = 'GET'; 
        RestContext.request = req;  
        RestContext.response= res;  
        MW_RetrieveAccountsByDate.MW_RetrieveAccountsByDate();
        
        
        system.assertNotEquals(null, res.responseBody, 'request is not null');
    }

    //test get account endpoint
    static testMethod void MW_RetrieveAccountsByDateTestWithValidDate() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addParameter('origination-date', '2019-10-28');
        req.requestURI = '/services/apexrest/application/date/?origination-date=2019-10-28';

        req.httpMethod = 'GET'; 
        RestContext.request = req;  
        RestContext.response= res;  
        Test.startTest();
        MW_RetrieveAccountsByDate.MW_RetrieveAccountsByDate();
        Test.stopTest(); 
        
        
        
        system.assertNotEquals(null, res.responseBody, 'request is not null');
    }
}