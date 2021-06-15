@isTest
public class TestDisableDCP {
    
    public static testMethod void testDisableDCP(){
        Account account_Obj = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com'
        );
        Insert account_Obj;
        
        genesis__Applications__c genesis_applications_Obj = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Account__c = account_Obj.Id,        
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'Default Documents',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c = 'Full Time'
        );      
        Insert genesis_applications_Obj; 
        
        DCp_Arcus_Transactions__c DCP_obj = new DCp_Arcus_Transactions__c();
        DCP_obj.Account__c = account_Obj.Id;
        DCP_obj.Application__c = genesis_applications_Obj.Id;
        DCP_obj.Card_Number__c = '1234567';
        DCP_obj.Credit_Card_Name__c = 'Sample Card';
        DCP_obj.Braintree_Verification_Failed__c = true;
        DCP_obj.Pay_at_Funding__c = true;
        Insert DCP_obj;
        
        CL_Document__c document = new CL_Document__c();
         document.Doc1__c = 'Credit Score Notice';
         document.Doc2__c = 'TIL Document';
         document.Doc3__c = 'Adverse Action Notice';
         insert document;
        
        
        
        Test.startTest();
        
        
        Account acc = new Account(
            Name = 'Test1',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName1', 
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
        /*genesis__Applications__c app1 = [select id,name from genesis__Applications__c];
        Delete app1;*/
        try{
            DCp_Arcus_Transactions__c DCP_obj2 = new DCp_Arcus_Transactions__c();
            DCP_obj2.Account__c = account_Obj.Id;
            DCP_obj2.Application__c = genesis_applications_Obj.Id;
            DCP_obj2.Card_Number__c = '123456778';
            DCP_obj2.Credit_Card_Name__c = 'Sample Card2';
            DCP_obj2.Braintree_Verification_Failed__c = true;
            DCP_obj2.Pay_at_Funding__c = true;
            Insert DCP_obj2;
            InvestorAllocation inv = new InvestorAllocation(true);
            InvestorAllocation.runInvestorRule(app.id);
        }
        Catch(Exception e){
        }
        WF_DisableDCP.disableDCP(new List<Id>{genesis_applications_Obj.Id});
        Test.stopTest();
        
        DCp_Arcus_Transactions__c testdcp = [SELECT Id,Card_Number__c,Credit_Card_Name__c,Pay_at_Funding__c FROM DCp_Arcus_Transactions__c WHERE Id=:DCP_obj.Id LIMIT 1];
        System.assertEquals(testdcp.Pay_at_Funding__c,false);
        
    }

}