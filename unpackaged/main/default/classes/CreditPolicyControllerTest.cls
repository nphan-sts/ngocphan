@isTest
private class CreditPolicyControllerTest {
    @testSetup
    static void setup(){
       test.startTest();
    Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            peer__First_Name__c= 'Testfname',
            peer__Last_Name__c= 'Testlname',
            cnotify__Email__c = 'no-reply@testorganization.com',
            Annual_Individual_Income__c = 10000, 
            Income_Include_Bonuses_or_Commissions__c = false
        );
        Insert acc;
        genesis__Applications__c app = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Account__c = acc.Id,        
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'Default Documents',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c = 'Full Time',
            genesis__APR__c=10.2,
            Sift_Status__c=30
        );      
        Insert app;
        
        Account acc2 = new Account(
            Name = 'Test2',
            loan__Investor__c=False,
            peer__First_Name__c= 'Testfname',
            peer__Last_Name__c= 'Testlname',
            cnotify__Email__c = 'no-reply@testorganization.com',
            Annual_Individual_Income__c = 10000, 
            Income_Include_Bonuses_or_Commissions__c = false
        );
        Insert acc2;
        genesis__Applications__c app2 = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Account__c = acc2.Id,        
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'Default Documents',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c = 'Full Time',
            genesis__APR__c=10.2,
            Sift_Status__c=30
        );      
        Insert app2;
        Credit_Policy__c cPolicy = new Credit_Policy__c(
            Application__c=app.Id,
            FICO__C=10.20,
            final_decision__c='Approve',
            pricing_test_bucket__c='Test',
            request_intent__c='application'
        );
        Insert cPolicy;
        test.stopTest();
    }
    @isTest
    static void CreditPolicyControllerTest_UseCase1(){
        Account acc = [select Id from Account  where Name = 'Test' LIMIT 1];
        System.assertEquals(true, acc!=Null); 
        genesis__Applications__c app = [SELECT Id from genesis__Applications__c WHERE genesis__Account__c =: acc.Id LIMIT 1];
        
        System.assertEquals(true, app!=Null);
        
        
        PageReference pageRef = Page.CSNDocument;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('Id', String.valueOf(app.Id));
        CreditPolicyController cpCtrl = new CreditPolicyController();
        //Decimal ficoVal = cpCtrl.creditPolicyRec[0].FICO__C;
        //System.assertEquals(true, ficoVal==10);
    }
    
     @isTest
    static void CreditPolicyControllerTest_UseCase2(){
        Account acc2 = [select Id from Account  where Name = 'Test2' LIMIT 1];
        System.assertEquals(true, acc2!=Null); 
        genesis__Applications__c app2 = [SELECT Id from genesis__Applications__c WHERE genesis__Account__c =: acc2.Id LIMIT 1];
        
        System.assertEquals(true, app2!=Null);
        
        
        PageReference pageRef = Page.CSNDocument;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('Id', String.valueOf(app2.Id));
        CreditPolicyController cpCtrl = new CreditPolicyController();
        //Decimal ficoVal = cpCtrl.creditPolicyRec[0].FICO__C;
        //System.assertEquals(true, ficoVal==10);
    }
}