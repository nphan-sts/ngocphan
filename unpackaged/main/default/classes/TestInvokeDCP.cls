@isTest
public class TestInvokeDCP {

    @isTest
    public static void TestInvokeDCP_usecase(){
        test.startTest();
        
       CL_Document__c document = new CL_Document__c();
         document.Doc1__c = 'Credit Score Notice';
         document.Doc2__c = 'TIL Document';
         document.Doc3__c = 'Adverse Action Notice';
         insert document;
        
       Account acco = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName2',
            peer__Last_Name__c='TestLName2', 
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456'
        );
        Insert acco;
        
        genesis__Applications__c app = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = false,
            genesis__Account__c = acco.Id,
            Invested_Amount__c  = 1000,       
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'offer_accepted',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c    = 'Full Time',
            genesis__Loan_Amount__c = 1000,
            DCP_Investor_Eligibility__c = false
        );      
        Insert app;
        
            DCp_Arcus_Transactions__c DCP_obj = new DCp_Arcus_Transactions__c();
            DCP_obj.Application__c = app.Id;
            DCP_obj.Card_Number__c = '1234568';
            DCP_obj.Bank_Name__c = 'CITI';
            DCP_obj.Pay_at_Funding__c = true;
            DCP_obj.Requested_Amount__c = 200;
            DCP_obj.Transaction_id__c = '87007jj798889';
            insert DCP_obj;
        
       		InvokeDCP.InvokeDCP(app.Id);
        	test.stopTest();
       
    }
}