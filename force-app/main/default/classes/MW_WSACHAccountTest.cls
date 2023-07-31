@isTest
public with sharing class MW_WSACHAccountTest  {
    
   static testMethod void TestACHAccount()
    {   
        list<account> accList                  = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        RestRequest req    = new RestRequest(); 
        RestResponse res   = new RestResponse();

        String xmlString ='{\"genesis__Applications__c\":\"'+appList[0].id+'",\"loan__Bank_Account_Number__c\": \"1111110099\", \"loan__Routing_Number__c\": \"9900099\", \"loan__Account_Type__c\": \"Saving\",\"loan__Bank_Name__c\": \"BankName\",\"Unmasked_Bank_Account_Number__c\": \"Hello\", "Payment_Mode__c": "Auto", "First_Name__c": "Auto", "Last_Name__c": "Auto"}';
            
        req.requestURI     = '/services/apexrest/ACHAccount';  
        req.requestBody = Blob.valueof(xmlString);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        MW_WSACHAccount.ACHAccount();
        Test.stopTest();
    }
}