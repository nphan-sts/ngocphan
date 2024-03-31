@isTest
public with sharing class MW_WSMemberAccountUpdateTest{

    static testMethod void TestACHAccount()
    {   
        list<account> accList                  = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        
        String jsonString ='{"leadID":"'+appList[0].LEAD_ID__C+'", "cnotify__Email__c":"snehal@gg.com"}';
               
        System.debug('***'+jsonString);
        RestRequest req    = new RestRequest(); 
        RestResponse res   = new RestResponse();
             
        req.requestURI  = '/services/apexrest/MemberAccountUpdate';
        req.requestBody = Blob.valueof(jsonString);
        req.httpMethod = 'POST';
         System.debug('***'+req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        MW_WSMemberAccountUpdate.MemberAccountUpdate();
        Test.stopTest();
    }
        
    static testMethod void TestACHAccount2()
    {   
        list<account> accList                  = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        RestRequest req    = new RestRequest(); 
        RestResponse res   = new RestResponse();

        String xmlString ='{"leadID":"'+appList[0].LEAD_ID__C+'" , "Phone":"3129124464"}';
             
        req.requestURI     = '/services/apexrest/MemberAccountUpdate';  
        req.requestBody = Blob.valueof(xmlString);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        MW_WSMemberAccountUpdate.MemberAccountUpdate();
        Test.stopTest();
    }
     static testMethod void TestACHAccount3()
    {   
        list<account> accList                  = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        RestRequest req    = new RestRequest(); 
        RestResponse res   = new RestResponse();

        String xmlString ='{"leadID":"'+appList[0].LEAD_ID__C+'" , "Address_1__c":"12633"}';
             
        req.requestURI     = '/services/apexrest/MemberAccountUpdate';  
        req.requestBody = Blob.valueof(xmlString);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        MW_WSMemberAccountUpdate.MemberAccountUpdate();
        Test.stopTest();
    }
     static testMethod void TestACHAccount4()
    {   
        list<account> accList                  = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        RestRequest req    = new RestRequest(); 
        RestResponse res   = new RestResponse();

        String xmlString ='{"leadID":"'+appList[0].LEAD_ID__C+'" , "Address_2__c":"1A"}';
             
        req.requestURI     = '/services/apexrest/MemberAccountUpdate';  
        req.requestBody = Blob.valueof(xmlString);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        MW_WSMemberAccountUpdate.MemberAccountUpdate();
        Test.stopTest();
    }
     static testMethod void TestACHAccount5()
    {   
        list<account> accList                  = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        RestRequest req    = new RestRequest(); 
        RestResponse res   = new RestResponse();

        String xmlString ='{"leadID":"'+appList[0].LEAD_ID__C+'" , "City__c":"LA"}';
             
        req.requestURI     = '/services/apexrest/MemberAccountUpdate';  
        req.requestBody = Blob.valueof(xmlString);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        MW_WSMemberAccountUpdate.MemberAccountUpdate();
        Test.stopTest();
    }
     static testMethod void TestACHAccount6()
    {   
        list<account> accList                  = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        RestRequest req    = new RestRequest(); 
        RestResponse res   = new RestResponse();

        String xmlString ='{"leadID":"'+appList[0].LEAD_ID__C+'" , "State__c":"CA"}';
             
        req.requestURI     = '/services/apexrest/MemberAccountUpdate';  
        req.requestBody = Blob.valueof(xmlString);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        MW_WSMemberAccountUpdate.MemberAccountUpdate();
        Test.stopTest();
    }
     static testMethod void TestACHAccount7()
    {   
        list<account> accList                  = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        RestRequest req    = new RestRequest(); 
        RestResponse res   = new RestResponse();

        String xmlString ='{"leadID":"'+appList[0].LEAD_ID__C+'" , "ZIP_Code__c":"91653"}';
             
        req.requestURI     = '/services/apexrest/MemberAccountUpdate';  
        req.requestBody = Blob.valueof(xmlString);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        MW_WSMemberAccountUpdate.MemberAccountUpdate();
        Test.stopTest();
    }
}