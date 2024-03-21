@isTest
public class MW_DCPArcusTransactionTriggerHandlerTest  {
    @testSetup
    static void setupTestData() {
        MW_Settings__c mwSetting = new MW_Settings__c();
        mwSetting.FE_User_Filter__c ='abcUser@filtertest.com';
        mwSetting.Enable_DcpTransaction_Sync__c = true;
        mwSetting.Use_DcpTransaction__c = false;
        insert mwSetting;
        
        Account objAcct = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com'
        );
        Insert objAcct;
        
        genesis__Applications__c objApp = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Account__c = objAcct.Id,        
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'Default Documents',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c = 'Full Time'
        );      
        Insert objApp; 
        
        genesis__Application_Document_Category__c appDoc = new genesis__Application_Document_Category__c();
        appDoc.name = 'TIL Document';
        appDoc.genesis__Application__c = objApp.id;
        insert appDoc;
        
        DCp_Arcus_Transactions__c objArcus = new DCp_Arcus_Transactions__c(
            Account__c = objAcct.Id,
            Application__c = objApp.Id,
            Card_Number__c = '12345674234',
            Credit_Card_Name__c = 'Sample Card',
            Braintree_Verification_Failed__c = true,
            Account_Number__c = 'Account_Number',
            Bank_Name__c = 'Bank_Name',
            Date_Opened__c = Date.ValueOf('2023-10-26'),
            DCP_Callout_done__c = true,
            DCP_Callout_successful__c = true,
            Arcus_Eligible__c = true,
            Member_Code__c = 'Member_Code',
            Paid_Amount__c = 10000,
            Pay_at_Funding__c = true,
            Portfolio_Type__c = 'Portfolio_Type',
            Requested_Amount__c = 5000,
            Status__c = 'Status__c',
            FE_Id__c = 'FE_Id',
            Transaction_Id__c = 'Transaction_Id',
            Arcus_Failed_Message__c = 'Arcus_Failed_Message',
            Arcus_Failure_Response__c = 'Arcus_Failure_Response'
        );
        Insert objArcus;
    }
    
    static testMethod void testTilRequest(){
        DCp_Arcus_Transactions__c objArcus = [SELECT Id, Transaction_Id__c, Pay_at_Funding__c FROM DCp_Arcus_Transactions__c WHERE FE_Id__c = 'FE_Id' LIMIT 1];
        objArcus.Pay_at_Funding__c = true;
        update objArcus;
    }

    @isTest
    static void testDcpTransactionAddUpdate(){
        Test.startTest();
        DCp_Arcus_Transactions__c arcus = [SELECT Id, FE_Id__c, Transaction_Id__c, Pay_at_Funding__c FROM DCp_Arcus_Transactions__c WHERE FE_Id__c = 'FE_Id' LIMIT 1];
        DCP_Transaction__c dcp = [SELECT Id, Transaction_Id__c, Pay_at_Funding__c FROM DCP_Transaction__c WHERE Transaction_Id__c = 'FE_Id' LIMIT 1];

        //check if dcp transaction added
        System.assertEquals(arcus.FE_Id__c, dcp.Transaction_Id__c);

        //check if dcp transaction updated
        arcus.Pay_at_Funding__c = false;
        update arcus;
        System.assertEquals(arcus.Pay_at_Funding__c, dcp.Pay_at_Funding__c);
        
        Test.stopTest();
    }
}