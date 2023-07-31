@isTest
private class MW_UpdateBoxFolderTest {

        static testmethod void MW_UpdateBoxFolder1()
        {

           test.startTest();
           Account acc = new Account(
                Name = 'Test',
                loan__Investor__c=False,
                cnotify__Email__c = 'no-reply@testorganization.com',
                peer__First_Name__c = 'TestFName',
                peer__Last_Name__c='TestLName',
                City__c='TestCity',
                State__c='TestState',
                ZIP_Code__c='123456'
            );
            Insert acc;

            genesis__Applications__c app = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Account__c = acc.Id,
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'REJECTED',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c = 'Full Time',
            genesis__Loan_Amount__c=1000,
            BoxFolderID__c='123321',
            Lead_ID__c='123123123',
            LeadGUID_XX_BoxFolderID__c =null
            );
            insert app;

            Database.executeBatch(new MW_UpdateBoxFolder1(), 1);

            Test.stopTest();
        }

         static testmethod void MW_UpdateBoxFolder2()
        {

            test.startTest();
            Account acc = new Account(
                Name = 'Test',
                loan__Investor__c=False,
                cnotify__Email__c = 'no-reply@testorganization.com',
                peer__First_Name__c = 'TestFName',
                peer__Last_Name__c='TestLName',
                City__c='TestCity',
                State__c='TestState',
                ZIP_Code__c='123456'
            );
            Insert acc;

            genesis__Applications__c app = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Account__c = acc.Id,
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'REJECTED',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c = 'Full Time',
            genesis__Loan_Amount__c=1000,
            BoxFolderID__c='123321',
            Lead_ID__c='123123123',
            LeadGUID_XX_BoxFolderID__c='123123'
            );
            insert app;

            Database.executeBatch(new MW_UpdateBoxFolder2(), 1);

           Test.stopTest();
        }
}