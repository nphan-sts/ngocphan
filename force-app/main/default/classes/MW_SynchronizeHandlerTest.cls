@isTest
public with sharing class MW_SynchronizeHandlerTest {
    @TestSetup
    static void mwSettingSetup() {
        MW_Settings__c mwSetting = new MW_Settings__c();
        mwSetting.API_User_Filter__c = 'test@example.com';
        insert mwSetting;
    }

    static testMethod void testPostToWebhookOnAppupdate() {
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

    static testMethod void testPostToWebhookOnAccupdate() {
        mwSettingSetup();
        list<account> accList = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        accList[0].Alternate_Phone__c = '9087654321';
        update accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;
    }
    static testMethod void testPostBankAccountDetailsOnWebHook() {
        mwSettingSetup();
        list<account> accList = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        accList[0].Alternate_Phone__c = '9087654321';
        update accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        loan__Bank_Account__c collectionTrustBA = new loan__Bank_Account__c(
            loan__Bank_Account_Number__c = '123234324',
            loan__Bank_Name__c = 'Some Bank',
            loan__Routing_Number__c = '999999999',
            loan__Account_Type__c = 'Checking',
            loan__Account_Usage__c = 'Collections Trust Account',
            Unmasked_Bank_Account_Number__c = '123234324',
            loan__Active__c = true,
            loan__Account__c = accList[0].Id
        );
        insert collectionTrustBA;

        collectionTrustBA.loan__Bank_Name__c = 'Updated Bank Name';
        collectionTrustBA.Unmasked_Bank_Account_Number__c = '1152486415';
        collectionTrustBA.loan__Routing_Number__c = '135515258';
        collectionTrustBA.loan__Account_Type__c = 'Updated Account Type';
        collectionTrustBA.First_Name__c = 'Updated First Name';
        collectionTrustBA.Last_Name__c = 'Updated Last Name';
        update collectionTrustBA;
    }

    static testMethod void testMaskingField() {
        String email = 'testEmail@abc.com';
        String maskedEmail = MW_SynchronizeHandler.maskingEmail(
            email,
            email.subString(1, String.valueOf(email).indexOf('@')).length()
        );
        System.assertEquals('t********@abc.com', maskedEmail, 'unmatched masking');

        String email2 = 'test@abc.com';
        String maskedEmail2 = MW_SynchronizeHandler.maskingEmail(
            email2,
            email2.subString(1, String.valueOf(email2).indexOf('@')).length()
        );
        System.assertEquals('t***@abc.com', maskedEmail2, 'unmatched masking');
    }

    @isTest
    static void testmMaskingFields() {
        User admin = TestDataFactory.createSysAdmin();

        Test.startTest();
        System.runAs(admin) {
            TestDataFactory factory = new TestDataFactory();
            factory.createApplications();

            TestDataFactory.Dataset dataset = retrieveTestData();

            MW_SynchronizeHandler.Sync_application(
                new Set<String>{ dataset.applications[0].Id },
                'test_sync_application'
            );

            MW_SynchronizeHandler.sync_application syncApp = new MW_SynchronizeHandler.sync_application(
                'test_sync_application',
                MW_SynchronizeHandler.getApplicaitonInfo(new Set<String>{ dataset.applications[0].Id })
            );
            String syncAppMasked = MW_SynchronizeHandler.maskingFields(JSON.serialize(syncApp, true));

            Map<String, Object> maskedSyncApp = (Map<String, Object>) JSON.deserializeUntyped(syncAppMasked);

            List<Object> appList = (List<Object>) maskedSyncApp.get('data');

            Map<String, Object> appSerilialized = (Map<String, Object>) appList[0];

            System.assert(appSerilialized.get('bank_account_number') == '0********0');
            System.assert(appSerilialized.get('bank_account_type') == 'C******g');
            System.assert(appSerilialized.get('bank_name') == 'T**********k');
            System.assert(appSerilialized.get('borrower_s_email') == 'n********@testorganization.com');
            System.assert(appSerilialized.get('borrower_s_first_name') == 'T********0');
            System.assert(appSerilialized.get('borrower_s_lastname') == 'T********0');
            System.assert(appSerilialized.get('borrowers_work_email') == 'b*****************@testorganization.com');
            System.assert(String.valueOf(appSerilialized.get('payment_amount')).contains('*'));
        }
        Test.stopTest();
    }

    private static TestDataFactory.Dataset retrieveTestData() {
        TestDataFactory.Dataset dataset = new TestDataFactory.Dataset();
        dataset.applications = [SELECT Id, Name FROM genesis__Applications__c ORDER BY CreatedDate LIMIT 10];

        return dataset;
    }
}