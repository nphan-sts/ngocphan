/* ****************Modification History******************
* Modified By       Date                    JIRA Number
*   Shakul        15/3/2022          LSP-601 (Refactored Test Class)	
******************Modification History******************/
@isTest

public class TestSendOfferExpiryNotification{
    public static String CRON_EXP = '0 0 0 15 3 ? 2025';
    @TestSetup
    public static void testSetup(){
        Expiry_Date__c exp = new Expiry_Date__c();
        exp.No_of_days_for_Expiration__c = 30;
        exp.Alert_Before_Expiration_Date__c = 14;
        insert exp;
        
        loan.TestHelper.createSeedDataForTesting();
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        //Creating Account
        Account acc = new Account(
            peer__First_Name__c ='Account',
            peer__Last_Name__c = 'Test',
            loan__Investor__c= false,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = String.valueOf(math.random()).right(9)
        );
        insert acc;
        
        //Creating Application
        genesis__Applications__c app= new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            Borrower_s_Email__c = null,
            //X14day_s_Before_Expiration_Date__c =true,
            genesis__Account__c = acc.Id,
            genesis__Expected_Close_Date__c =Date.newInstance(2017,10,11),
            Application_Start_DateV2__c = system.Today(),
            DocuSignFlag__c=true,
            genesis__Status__c = 'agent_verified',
            genesis__Draw_Period_End_Date__c = system.Today()
        );
        insert app;
    }
    
    /*Created By: Shakul Siddharth
    Purpose: To verify logic for send offer expiry notification using schedulable context*/
    public static testMethod void sendOffExpNotifWithoutParam(){
        Id cronTriggerId;
        User testUsr = [SELECT id, loan__Current_Branch_s_System_Date__c FROM User WHERE Id =: UserInfo.getUserId()];
        genesis__Applications__c testApp = [SELECT id, Expiry_Date__c FROM genesis__Applications__c LIMIT 1];
        testUsr.loan__Current_Branch_s_System_Date__c = testApp.Expiry_Date__c.addDays(-14);
        update testUsr;
        Test.startTest();
        System.runAs(testUsr){
            SendOfferExpiryNotification soffExp = new SendOfferExpiryNotification();
            cronTriggerId = System.schedule('TestSendOfferExpiry', CRON_EXP, soffExp);
        }
        Test.stopTest();
        CronTrigger ct = [SELECT id, State FROM CronTrigger WHERE id =: cronTriggerId];
        System.assertEquals('WAITING', ct.State);
    }
    
    /*Created By: Shakul Siddharth
    Purpose: To verify logic for send offer expiry notification using batchable context*/
    public static testMethod void sendOffExpNotifOneParam(){
        String query = 'select Id,name,genesis__Status__c,Send_Offer_expiry_notification__c,X14day_s_Before_Expiration_Date__c,genesis__Expected_Close_Date__c From genesis__Applications__c LIMIT 1';
        Test.startTest();
        SendOfferExpiryNotification job = new SendOfferExpiryNotification(query);
        Database.executeBatch(job, 1);
        Test.stopTest();
        genesis__Applications__c assertApp = [SELECT id, Send_Offer_expiry_notification__c FROM genesis__Applications__c LIMIT 1];
        System.assertEquals(true, assertApp.Send_Offer_expiry_notification__c);
    }
}