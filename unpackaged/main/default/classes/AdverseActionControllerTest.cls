@isTest
private class AdverseActionControllerTest {
    @isTest static Void AdverseActionTest_Usecase1(){
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
            genesis__Loan_Amount__c=1000
        );      
        Insert app;         
        Adverse__c adv = new Adverse__c(
            No_Hit__c=False,
          Application__c=app.Id
        );
        Insert adv;
        Credit_Policy__c creditObj = new Credit_Policy__c(
          Application__c=app.Id,
            FICO__C=10,
            Bureau_Inquiry_Date__c= '10/10/2010',
            final_decision__c='Approve',
            pricing_test_bucket__c='Test',
            request_intent__c='application'
        );
        Insert creditObj;
        Adverse_Actions__c advAc_Obj = new Adverse_Actions__c(
          Description__c='Test_Description', 
            Adverse_action_name__c='post_bureau_fico_score_below_min', 
            Reason__c='Test_AdverseReason',
            Application__c=app.Id
        );
        Insert advAc_Obj;
        Score_Factors__c score = new Score_Factors__c(
          Application__c=app.Id,
            Code__c=01, 
            Description__c='Test_Description', 
            Rank__c=01
        );
        Insert score;
        
        List<Credit_union_list__c> cunList = new List<Credit_union_list__c>{
        new Credit_union_list__c(Name='CUN1',Credit_Union_Names__c='CUN1 c/o HM',Credit_Unions_Address__c='CUNHMAddress1'),
        new Credit_union_list__c(Name='CUN2',Credit_Union_Names__c='CUN2 c/o HM',Credit_Unions_Address__c='CUNHMAddress2')};
        Insert cunList;
        
        Test.stopTest();
                        
        PageReference pageRef = Page.AdverseActionDocument;        
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('Id', String.valueOf(app.Id));
        AdverseActionController advAcCtrl = new AdverseActionController();
        List<Adverse_Actions__c> lstAdverseReasons = advAcCtrl.getAdverseActionReasons();
        System.AssertEquals(true, !lstAdverseReasons.isEmpty());
        
        List<Score_Factors__C> lstScoreFactors = advAcCtrl.getScoreFactors();
        System.assertEquals(true, !lstScoreFactors.isEmpty());
        AdverseActionController testApplication = new AdverseActionController();
        testApplication.getmanualDecline();
        testApplication.getScoreFactorsPart1();
    }
    
    @isTest static Void AdverseActionTest_Usecase2(){
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
            genesis__Loan_Amount__c=1000
        );      
        Insert app;         
        
        
        Test.stopTest();
                        
        PageReference pageRef = Page.AdverseActionDocument;        
        Test.setCurrentPage(pageRef);
        
        //pageRef.getParameters().put('Id', String.valueOf(app.Id));
        AdverseActionController advAcCtrl = new AdverseActionController();
        List<Adverse_Actions__c> lstAdverseReasons = advAcCtrl.getAdverseActionReasons();
        //System.AssertEquals(true, !lstAdverseReasons.isEmpty());
        
        List<Score_Factors__C> lstScoreFactors = advAcCtrl.getScoreFactors();
        //System.assertEquals(true, !lstScoreFactors.isEmpty());
        AdverseActionController testApplication = new AdverseActionController();
        testApplication.getadverseResults(app.Id);
    }
}