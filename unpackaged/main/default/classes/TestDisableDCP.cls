/*  Modification History
    Modified By          Jira ID                  Description
*   Shakul               LSP-515                  Refactored Test Class
*/
@isTest
public class TestDisableDCP {

    @TestSetup
    static void testSetup(){

        MW_Settings__c mwSettings = new MW_Settings__c();
        mwSettings.docCategoriesNamestoskip__c = 'skip1,skip2';
        mwSettings.FE_User_Filter__c ='abcUser@filtertest.com';
        insert mwSettings;
    }
    
    public static testMethod void testDisableDCP(){
        Account account_Obj = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__Last_Name__c = 'LastName',
            peer__First_Name__c = 'FirstName'
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

        Attachment attachment = new Attachment(
            ParentId = genesis_applications_Obj.id, 
            Name = 'TIL', 
            IsPrivate = false, 
            Body = Blob.valueOf('Unit Test Attachment Body Two'), 
            Description = '15');
        insert attachment;
        
        genesis__Application_Document_Category__c adc = new genesis__Application_Document_Category__c();
        adc.name = 'TIL Document';
        adc.genesis__Application__c = genesis_applications_Obj.id;
        
        insert adc;
        
        DCp_Arcus_Transactions__c DCP_obj = new DCp_Arcus_Transactions__c();
        DCP_obj.Account__c = account_Obj.Id;
        DCP_obj.Application__c = genesis_applications_Obj.Id;
        DCP_obj.Card_Number__c = '1234567';
        DCP_obj.Credit_Card_Name__c = 'Sample Card';
        DCP_obj.Braintree_Verification_Failed__c = true;
        DCP_obj.Pay_at_Funding__c = true;
        dcpList.add(DCP_obj);

        DCp_Arcus_Transactions__c DCP_obj2 = new DCp_Arcus_Transactions__c();
        DCP_obj2.Account__c = account_Obj.Id;
        DCP_obj2.Application__c = genesis_applications_Obj.Id;
        DCP_obj2.Card_Number__c = '123456778';
        DCP_obj2.Credit_Card_Name__c = 'Sample Card2';
        DCP_obj2.Braintree_Verification_Failed__c = true;
        DCP_obj2.Pay_at_Funding__c = true;
        dcpList.add(DCP_obj2);

        insert dcpList;
    }

    /* Created By : Shakul Siddharth
        Description : To test DCP Disable logic for 2 or more failed cards
     */
    public static testMethod void testDisableDCP(){
        Test.startTest();
        genesis__Applications__c app = [SELECT id FROM genesis__Applications__c];
        WF_DisableDCP.disableDCP(new List<Id>{app.id});
        Test.stopTest();
        
        DCp_Arcus_Transactions__c testdcp = [SELECT Id,Card_Number__c,Credit_Card_Name__c,Pay_at_Funding__c FROM DCp_Arcus_Transactions__c WHERE Id=:DCP_obj.Id LIMIT 1];
        System.assertEquals(testdcp.Pay_at_Funding__c,false);
        
    }
}