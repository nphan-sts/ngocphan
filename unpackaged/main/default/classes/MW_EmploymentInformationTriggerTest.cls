@isTest
private class MW_EmploymentInformationTriggerTest {

    static testMethod void TestUpdateApplications() {
        Test.startTest();
        try {

            //-----------------------------------------
            //Test Verification_Complexity__c = Hard
            //-----------------------------------------
            Account act = MW_GlobalTestUtility.GetAccount('Member');
            act.Annual_Individual_Income__c = 100;
            insert act;

            genesis__Applications__c app = MW_GlobalTestUtility.GetApplication();
            app.genesis__Account__c = act.Id;
            insert app;

            genesis__Employment_Information__c empInfo = MW_GlobalTestUtility.GetEmploymentInformation();
            empInfo.genesis__Application__c = app.Id;
            insert empInfo;

            Talx__c talx = MW_GlobalTestUtility.GetTalx();
            talx.Application__c = app.Id;
            insert talx;

            KBA_Details__c kbaHard = MW_GlobalTestUtility.GetKbaDetails();
            kbaHard.Application__c = app.Id;
            insert kbaHard;

            System.assertEquals('Hard', [SELECT Id, Verification_Complexity__c FROM genesis__Applications__c WHERE Id=: app.Id].Verification_Complexity__c);

            delete kbaHard;

            //---------------------------------------------
            //Test Verification_Complexity__c = Very Easy
            //---------------------------------------------
            app.Pricing_Tier__c = 't1';
            app.Employment_Status__c = 'Full Time';
            Update app;

            KBA_Details__c kbaVe = MW_GlobalTestUtility.GetKbaDetails();
            kbaVe.Application__c = app.Id;
            kbaVe.Precise_ID_Overall_SCore__c = 705;
            kbaVe.Precise_ID_Decision_KIQ__c = 'Accept';
            insert kbaVe;

            System.assertEquals('Very Easy', [SELECT Id, Verification_Complexity__c FROM genesis__Applications__c WHERE Id=: app.Id].Verification_Complexity__c);

            delete kbaVe;
            //---------------------------------------------
            //Test Verification_Complexity__c = Easy
            //---------------------------------------------
            act.Monthly_Housing_Payment__c = 400;
            update act;

            KBA_Details__c kbaEasy = MW_GlobalTestUtility.GetKbaDetails();
            kbaEasy.Application__c = app.Id;
            kbaEasy.Precise_ID_Overall_SCore__c = 705;
            kbaEasy.Precise_ID_Decision_KIQ__c = 'Accept';
            insert kbaEasy;

            System.assertEquals('Easy', [SELECT Id, Verification_Complexity__c FROM genesis__Applications__c WHERE Id=: app.Id].Verification_Complexity__c);

            delete kbaEasy;
            //---------------------------------------------
            //Test Verification_Complexity__c = Regular
            //---------------------------------------------
            empInfo.Income_Include_Bonuses_or_Commissions__c = true;
            update empInfo;

            KBA_Details__c kbaReg = MW_GlobalTestUtility.GetKbaDetails();
            kbaReg.Application__c = app.Id;
            kbaReg.Precise_ID_Overall_SCore__c = 705;
            kbaReg.Precise_ID_Decision_KIQ__c = 'Accept';
            insert kbaReg;

            System.assertEquals('Regular', [SELECT Id, Verification_Complexity__c FROM genesis__Applications__c WHERE Id=: app.Id].Verification_Complexity__c);

            /*
            delete kbaReg;
            //---------------------------------------------
            //cover code for missing employment information.
            //---------------------------------------------
            delete empInfo;

            KBA_Details__c kbaEmpInfoMissing = MW_GlobalTestUtility.GetKbaDetails();
            kbaEmpInfoMissing.Application__c = app.Id;
            kbaEmpInfoMissing.Precise_ID_Overall_SCore__c = 705;
            kbaEmpInfoMissing.Precise_ID_Decision_KIQ__c = 'Accept';
            insert kbaEmpInfoMissing;

            //System.assertEquals('Easy', [SELECT Id, Verification_Complexity__c FROM genesis__Applications__c WHERE Id=: app.Id].Verification_Complexity__c);

            delete kbaEmpInfoMissing;
            */

        } catch (exception e) {
            System.debug('****** Exception Caught :   '+e.getMessage());
        }

        Test.stopTest();
    }
}