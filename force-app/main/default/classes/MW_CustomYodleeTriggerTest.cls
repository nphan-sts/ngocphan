@isTest
public class MW_CustomYodleeTriggerTest {
    
    static testMethod void test_ApplicationController_UseCase1(){
        
        ints__Yodlee_Cobrand_Credentials__c ycc = new ints__Yodlee_Cobrand_Credentials__c();
        ycc.ints__APP_ID__c = '10003600';
        ycc.ints__Cobrand_id__c = '4410018556';
        ycc.ints__Cobrand_Password__c = 'fpoie176bPIOY!T';
        ycc.ints__Cobrand_Username__c = 'payoff';
        ycc.FromDate_Attribute_value__c = 1100;
        ycc.ints__Node_URL__c = 'https://yieapnodestage.yodlee.com/authenticate/payoff/?channelAppName=yisandbox';
        ycc.ints__Rest_URL__c = 'https://stage.api.yodlee.com/ysl/payoff/v1/';
        ycc.ints__Soap_URL__c = 'https://stage.api.yodlee.com/ysl/payoff/v1/';
        
        insert  ycc;
        
        Account acc = new Account();
        acc.name = 'Test Yodlee Account';
        acc.peer__Last_Name__c = 'LastName';
        acc.Account_External_ID__c = 'Yodlee';
        acc.cnotify__Email__c = 'no-reply@testorganization.com';
        insert acc;
        
        ints__Yodlee_User_Credentials__c userCred = new ints__Yodlee_User_Credentials__c();
        userCred.ints__Account__c = acc.Id;
        userCred.ints__Yodlee_Username__c = 'testuserName';
        userCred.ints__Yodlee_Password__c = 'testpassword';
        userCred.yodlee_Account_count__c =1;
        insert userCred;
        
        Test.startTest();
        
    }
}