@isTest
public class MW_DCPArcusTransactionTriggerHandlerTest  {
    static testMethod void TestTilRequest(){
        MW_Settings__c mwSetting = new MW_Settings__c();
        mwSetting.FE_User_Filter__c ='abcUser@filtertest.com';
        insert mwSetting;
        
        Account account_Obj = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com'
        );
        Insert account_Obj;
        
        genesis__Applications__c genesis_applications_Obj = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Account__c = account_Obj.Id,        
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'Default Documents',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c = 'Full Time'
        );      
        Insert genesis_applications_Obj; 
        
        genesis__Application_Document_Category__c appDoc = new genesis__Application_Document_Category__c();
        appdoc.name = 'TIL Document';
        appdoc.genesis__Application__c = genesis_applications_Obj.id;
        insert appdoc;
        
        DCp_Arcus_Transactions__c DCP_obj = new DCp_Arcus_Transactions__c();
        DCP_obj.Account__c = account_Obj.Id;
        DCP_obj.Application__c = genesis_applications_Obj.Id;
        DCP_obj.Card_Number__c = '12345674234';
        DCP_obj.Credit_Card_Name__c = 'Sample Card';
        DCP_obj.Braintree_Verification_Failed__c = true;
        Insert DCP_obj;
        
        DCP_obj.Pay_at_Funding__c = true;
        update DCP_obj;
    }
}