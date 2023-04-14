@isTest
public with sharing class MW_SynchronizeHandlerTest {

    public static void mwSettingSetup() {
        MW_Settings__c mwSetting = new MW_Settings__c();
        mwSetting.API_User_Filter__c = 'test@example.com';
        insert mwSetting;     
    }

    static testMethod void TestPostToWebhookOnAppupdate()
    {
        mwSettingSetup();
        list<account> accList = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;
        appList[0].genesis__Loan_Amount__c = 25000;
        appList[0].genesis__Status__c = 'offer_shown';
        appList[0].Annual_Individual_Income_App__c = 95000;
        update appList;
        System.assertEquals(25000, appList[0].genesis__Loan_Amount__c);
    }

    //LPC-182
    static testMethod void testPostToWebhookOnExpiryDateAppupdate()
    {
        mwSettingSetup();
        list<account> accList = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;
        appList[0].Application_Start_DateV2__c = System.today().addDays(10);
        update appList;
        System.assertEquals(Limits.getFutureCalls(), 1);
    }

    static testMethod void TestPostToWebhookOnAccupdate()
    {
        mwSettingSetup();
        list<account> accList = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        accList[0].Alternate_Phone__c ='9087654321';
        Update accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;
    }
    static testMethod void testPostBankAccountDetailsOnWebHook(){
    
        mwSettingSetup();
        list<account> accList = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        accList[0].Alternate_Phone__c ='9087654321';
        Update accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;
        
        loan__Bank_Account__c collectionTrustBA = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
                                                                        loan__Bank_Name__c = 'Some Bank',
                                                                        loan__Routing_Number__c = '999999999',
                                                                        loan__Account_Type__c = 'Checking',
                                                                        loan__Account_Usage__c = 'Collections Trust Account',
                                                                        Unmasked_Bank_Account_Number__c = '123234324',
                                                                        loan__Active__c = True,
                                                                        loan__Account__c = accList[0].Id);
        insert collectionTrustBA;
        
        collectionTrustBA.loan__Bank_Name__c = 'Updated Bank Name';
        collectionTrustBA.Unmasked_Bank_Account_Number__c = '1152486415';
        collectionTrustBA.loan__Routing_Number__c = '135515258';
        collectionTrustBA.loan__Account_Type__c = 'Updated Account Type';
        collectionTrustBA.First_Name__c = 'Updated First Name';
        collectionTrustBA.Last_Name__c = 'Updated Last Name';
        update collectionTrustBA;
    
    }

}