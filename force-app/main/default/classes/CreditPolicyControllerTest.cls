/* ****************Modification History******************
 *    Created By        	 Date			Version
 *1. Bhavya Maliwal        2022/01/31     Initial Version
Comment : Increased coverage from 80 to 100
 ******************Modification History******************/
@isTest
private class CreditPolicyControllerTest {
    @testSetup
    static void setup(){
        //Account creation
        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            peer__Last_Name__c='scenario',
            cnotify__Email__c = 'no-reply@testorganization.com',
            Annual_Individual_Income__c = 10000,
            Income_Include_Bonuses_or_Commissions__c = false
        );
        Insert acc;
        
        //Application creation
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
        
    }
      /*Created By : Bhavya Maliwal
    Method name : CreditPolicyControllerTest_FicoNotNull
    Purpose : to cover code satisfying if condition for CreditPolicyController where in FICO should not be null
    */
    @isTest
    static void CreditPolicyControllerTest_FicoNotNull(){
        test.startTest();
        Account acc = [select Id from Account  where peer__Last_Name__c='scenario' LIMIT 1];
        System.assertEquals(true, acc!=Null); 
        genesis__Applications__c app = [SELECT Id from genesis__Applications__c WHERE genesis__Account__c =: acc.Id LIMIT 1];
        System.assertEquals(true, app!=Null);
        Credit_Policy__c cPolicy = new Credit_Policy__c(
            Application__c=app.Id,
            FICO__c=10.20
        );
        insert cPolicy;
        
        PageReference pageRef = Page.CSNDocument;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('Id', String.valueOf(app.Id));
        CreditPolicyController cpCtrl = new CreditPolicyController();
        
        Decimal ficoVal = cpCtrl.fico;
        System.assertEquals(true, ficoVal==10);
        test.stopTest();
    }
    
     /*Created By : Bhavya Maliwal
    Method name : CreditPolicyControllerTest_FicoNotNull
    Purpose : to cover code satisfying else condition for CreditPolicyController where in FICO should be null
    */
    @isTest
    static void CreditPolicyControllerTest_FicoNull(){
        test.startTest();
        Account acc = [select Id from Account  where peer__Last_Name__c='scenario' LIMIT 1];
        System.assertEquals(true, acc!=Null); 
        genesis__Applications__c app = [SELECT Id from genesis__Applications__c WHERE genesis__Account__c =: acc.Id LIMIT 1];
        System.assertEquals(true, app!=Null);
        
        PageReference pageRef = Page.CSNDocument;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('Id', String.valueOf(app.Id));
        CreditPolicyController cpCtrl = new CreditPolicyController();
        
        Decimal ficoVal = cpCtrl.fico;
        System.assertEquals(true, ficoVal==null);
        test.stopTest();
    }
}