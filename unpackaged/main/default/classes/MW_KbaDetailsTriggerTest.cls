@isTest
private class MW_KbaDetailsTriggerTest {
    private static genesis__Org_Parameters__c cso;
    
    
    @testSetup
    public static void testSetup(){
        cso = new genesis__Org_Parameters__c(genesis__Disable_Triggers__c = true);
        insert cso;
        
        List<Account> accountList = new List<Account>();
        Account act = MW_GlobalTestUtility.GetAccount('Member');
        act.Name = 'Common Account';
        act.peer__First_Name__c = 'FirstName';
        act.peer__Last_Name__c = 'LastName';
        act.loan__Investor__c = true;
        act.loan__SOCIAL_SECURITY_NUMBER__c = '987654345';
        accountList.add(act);
        
        Account act1 = MW_GlobalTestUtility.GetAccount('Member');
        act1.Name = 'Monthly Housing Account';
        act1.peer__First_Name__c = 'FirstName1';
        act1.peer__Last_Name__c = 'LastName1';
        act1.loan__Investor__c = true;
        act1.loan__SOCIAL_SECURITY_NUMBER__c = '987654342';
        accountList.add(act1);
        
        insert accountList;
        
        List<genesis__Applications__c> genApplicationList = new List<genesis__Applications__c>();
        
        genesis__Applications__c app = MW_GlobalTestUtility.GetApplication();
        app.genesis__Account__c = act.Id;
        genApplicationList.add( app );
        
        genesis__Applications__c app1 = MW_GlobalTestUtility.GetApplication();
        app1.genesis__Account__c = act1.Id;
        app1.Pricing_Tier__c = 't1';
        app1.Employment_Status__c = 'Full Time';
        app1.Annual_Individual_Income_App__c = 100;
        app1.Monthly_Housing_Payment_App__c = 600;
        genApplicationList.add( app1 );
        
        genesis__Applications__c app2 = MW_GlobalTestUtility.GetApplication();
        app2.genesis__Account__c = act.Id;
        app2.Pricing_Tier__c = 't1';
        app2.Employment_Status__c = 'Full Time';
        app2.Annual_Individual_Income_App__c = 100;
        app2.Monthly_Housing_Payment_App__c = 600;
        genApplicationList.add( app2 );
        
         genesis__Applications__c app3 = MW_GlobalTestUtility.GetApplication();
        app3.genesis__Account__c = act.Id;
        app3.Pricing_Tier__c = 't4';
        app3.Employment_Status__c = 'Full Time';
        app3.Annual_Individual_Income_App__c = 100;
        app3.Monthly_Housing_Payment_App__c = 600;
        genApplicationList.add( app3 );
        
        insert genApplicationList;
                
        List<genesis__Employment_Information__c> empList = new List<genesis__Employment_Information__c>();
        genesis__Employment_Information__c empInfo = MW_GlobalTestUtility.GetEmploymentInformation();
        empInfo.genesis__Application__c = app1.Id;
        empList.add(empInfo);
        
        genesis__Employment_Information__c empInfo1 = MW_GlobalTestUtility.GetEmploymentInformation();
        empInfo1.genesis__Application__c = app2.Id;
        empList.add(empInfo1);
        
        insert empList;
        
        Talx__c talx = MW_GlobalTestUtility.GetTalx();
        talx.Application__c = app1.Id;
        insert talx;
        
         genesis__Document_Category__c docCat = new genesis__Document_Category__c(
            genesis__Category_Name__c = 'Test_Paystub_ID',
            genesis__Required__c = true
        );
        Insert docCat;
        genesis__Application_Document_Category__c appDocCat = new genesis__Application_Document_Category__c(
            Name = 'Primary ID',
            genesis__Document_Category__c = docCat.Id,
            genesis__Application__c = app.Id
        );
        Insert appDocCat;
        cso.genesis__Disable_Triggers__c = false;
        update cso;
    }
    
    @isTest
    public static void PrimaryID9012(){
        Test.startTest();
        
        genesis__Applications__c app = [SELECT Id From genesis__Applications__c LIMIT 1];
        
        KBA_Details__c kba9012 = MW_GlobalTestUtility.GetKbaDetails();
        kba9012.Application__c = app.Id;
        kba9012.Precise_ID_Overall_SCore__c = 9012;
        insert kba9012;
        
        Test.stopTest();
              
        System.assertEquals(TRUE, [SELECT ID, genesis__Required__c FROM genesis__Application_Document_Category__c where genesis__Application__c=:app.Id AND name='Primary ID'].genesis__Required__c);
    }
    
    @isTest
    public static void updateApplicationsHardTest(){
        Test.startTest();
        
        genesis__Applications__c app = [SELECT Id From genesis__Applications__c LIMIT 1];
        
        KBA_Details__c kbaHard = MW_GlobalTestUtility.GetKbaDetails();
        kbaHard.Application__c = app.Id;
        insert kbaHard;
        
        Test.stopTest();
              
        System.assertEquals('Hard', [SELECT Id, Verification_Complexity__c FROM genesis__Applications__c WHERE Id=: app.Id].Verification_Complexity__c);
    }
    
    @isTest
    public static void updateApplicationsVeryEasyTest(){
        
        Test.startTest();
        
        List<genesis__Applications__c> app = [SELECT Id,Pricing_Tier__c,Employment_Status__c From genesis__Applications__c];
        System.debug( app[1]);
        
        KBA_Details__c kbaVe = MW_GlobalTestUtility.GetKbaDetails();
        kbaVe.Application__c = app[1].Id;
        kbaVe.Precise_ID_Overall_SCore__c = 705;
        kbaVe.Precise_ID_Decision_KIQ__c = 'Accept';
        insert kbaVe;
        
        Test.stopTest();
        System.assertEquals('Very Easy', [SELECT Id, Verification_Complexity__c FROM genesis__Applications__c WHERE Id=: app[1].Id].Verification_Complexity__c);
    }
    
    @isTest
    public static void updateApplicationsEasyTest(){
        Test.startTest();
        
        Account act = [SELECT Id From Account WHERE Name = 'Monthly Housing Account' LIMIT 1];
        
        List<genesis__Applications__c> app = [SELECT Id From genesis__Applications__c];
        
        KBA_Details__c kbaEasy = MW_GlobalTestUtility.GetKbaDetails();
        kbaEasy.Application__c = app[2].Id;
        kbaEasy.Precise_ID_Overall_SCore__c = 705;
        kbaEasy.Precise_ID_Decision_KIQ__c = 'Accept';
        kbaEasy.Precise_ID_First_Payment_Default__c = 100;
        insert kbaEasy;
        
        Test.stopTest();
        
        System.assertEquals('Easy', [SELECT Id, Verification_Complexity__c FROM genesis__Applications__c WHERE Id=: app[2].Id].Verification_Complexity__c);
        
    }
    
    @isTest
    public static void updateApplicationsRegularTest(){
        
        Test.startTest();
        
        genesis__Employment_Information__c empInfo = [SELECT Id From genesis__Employment_Information__c LIMIT 1];
        empInfo.Income_Include_Bonuses_or_Commissions__c = true;
        update empInfo;
        
        Account act = [SELECT Id From Account WHERE Name = 'Monthly Housing Account' LIMIT 1];
        
        List<genesis__Applications__c> app = [SELECT Id From genesis__Applications__c];
        
        KBA_Details__c kbaReg = MW_GlobalTestUtility.GetKbaDetails();
        kbaReg.Application__c = app[3].Id;
        kbaReg.Precise_ID_Overall_SCore__c = 705;
        kbaReg.Precise_ID_Decision_KIQ__c = 'Accept';
        kbaReg.Precise_ID_First_Payment_Default__c = 100;
        insert kbaReg;
        
        Test.stopTest();
        
        System.assertEquals('Regular', [SELECT Id, Verification_Complexity__c FROM genesis__Applications__c WHERE Id=: app[3].Id].Verification_Complexity__c);
    }
    
     @isTest
    public static void updateApplicationsrUpdateTest(){
        List<genesis__Applications__c> app = [SELECT Id From genesis__Applications__c];
        
        Test.startTest();

        KBA_Details__c kbaReg = MW_GlobalTestUtility.GetKbaDetails();
        kbaReg.Application__c = app[3].Id;
        kbaReg.Precise_ID_Overall_SCore__c = 705;
        kbaReg.Precise_ID_Decision_KIQ__c = 'Accept';
        kbaReg.Precise_ID_First_Payment_Default__c = 100;
        insert kbaReg;
        
        kbaReg.Precise_ID_Overall_SCore__c = 710;
        update kbaReg;
        
        Test.stopTest();
        
    }
}