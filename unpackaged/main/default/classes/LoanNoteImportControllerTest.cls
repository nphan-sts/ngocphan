/*
 * author: Vitor
 * The controller is to parse CSV file thats uploaded for note creation
 *
 *****************Modification History*****************************************************************
 * Modified by      Date            JIRA number
 * 	  Vitor		  2023/06/05	    LPC-798 Automate bulk note creation for ACU notes daily
 ******************Modification History*****************************************************************/

@isTest
public class LoanNoteImportControllerTest 
{
    static final String header = 'LOANID,Call Outcome,Comments\r\n';

    @TestSetup
    public static void testSetup(){
        MW_Settings__c mwSetting = new MW_Settings__c();
        mwSetting.ExcludeLoansForSkipAPay__c = 'Closed- Written Off';
        insert mwSetting;
        
        loan.TestHelper.createSeedDataForTesting();
        //Creating Conpany
        genesis__Company__c comp = genesis.TestHelper.createCompany(); 
        comp.Name = 'payoff';
        update comp;

        Account account_Obj = new Account(Name = 'Test',
                                         peer__Last_Name__c = 'Test',
                                         loan__Investor__c=False,
                                         cnotify__Email__c = 'no-reply@testorganization.com'
                                         );
        insert account_Obj;

        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
        loan__Currency__c curr = loan.TestHelper.createCurrency();

        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);                                    
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);

        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);

        //creating CL Product
        clcommon__CL_Product__c pr = new clcommon__CL_Product__c();
        pr.loan__Lending_Product__c = dummyLp.id;
        pr.clcommon__Product_Name__c = 'P1';
        insert pr;
        
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        Date systemDate = util.getCurrentSystemDate();

        genesis__applications__c application = new genesis__applications__c();
        application.genesis__Product_Type__c = 'LOAN';
        application.genesis__Loan_Amount__c = 6700;
        application.genesis__status__c = 'NEW - ENTERED';
        application.genesis__Term__c = 12;
        application.genesis__Payment_Frequency__c = 'MONTHLY';
        application.genesis__Interest_Rate__c = 10;
        application.genesis__Days_Convention__c = 'ACTUAL/ACTUAL';
        application.genesis__Expected_Start_Date__c = systemDate.addDays(-29);
        application.genesis__Expected_First_Payment_Date__c = systemDate.addDays(1);
        application.genesis__Expected_Close_Date__c = systemDate.addYears(2);
        application.genesis__Interest_Calculation_Method__c = 'Declining Balance';
        application.genesis__Interest_Only_Period__c = 0;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Account__c = account_Obj.Id;
        application.genesis__Total_Estimated_Interest__c=500;
        application.genesis__Valid_Pricing_Flag__c=false;
        application.genesis__Probability__c=100.00;
        application.genesis__Payment_Amount__c=523.80;
        application.genesis__Company__c = comp.id;
        application.genesis__CL_Product__c = pr.id;
        insert application;

        List<loan__loan_account__c> listLacc = new List<loan__loan_Account__c>();
        loan__Loan_Account__c lacc = new loan__Loan_Account__c(loan__Account__c= account_Obj.Id,
                                                               loan__Product_Type__c='Flexible Amz Loan',
                                                               loan__Loan_Amount__c =1000,
                                                               loan__Loan_Product_Name__c=dummyLP.Id,
                                                               loan__Payment_Amount__c=100,
                                                               loan__Principal_Remaining__c = 500,
                                                               loan__Previous_Installment_Date__c= systemDate.addDays(-29),
                                                               application__c = application.id, 
                                                               loan__First_Installment_Date__c = systemDate.addDays(1),
                                                               loan__Next_Installment_Date__c = systemDate.addDays(31), 
                                                               loan__Maturity_Date_Current__c = systemDate.addYears(2), 
                                                               loan__Frequency_of_Loan_Payment__c = '6',  
                                                               loan__Last_Installment_Date__c = systemDate.addYears(2),
                                                               loan__Loan_Status__c = 'Active - Good Standing',
                                                               loan__Interest_Rate__c = 10,
                                                               loan__Term_Cur__c = 12,
                                                               Skipped_a_pay_Date__c = null,
                                                               Skipped_a_Pay__c = false
                                                                );
        listLacc.add(lacc);

        insert listLacc; 
    }

    /* Created By : Vitor
       Description : Test scenario for a note correctly filled.
    */
    public static testMethod void testCorrectNoteCreation(){
        Test.startTest();
            List<loan__Loan_Account__c> testlacc = [SELECT Id, Payoff_Loan_ID__c FROM loan__Loan_Account__c];
        
        	String str = header + testlacc[0].Payoff_Loan_ID__c + ',No Commitment,Test\r\n';
            LoanNoteImportController cont = new LoanNoteImportController();
        
            cont.csvFileBody = Blob.valueOf(str);
            cont.importCSVFile();
        Test.stopTest();
        
        List<Note> testNoteNumber = [SELECT ParentId FROM Note];
        
        System.assertEquals(1, testNoteNumber.size());
        System.assertEquals(testlacc[0].Id, testNoteNumber[0].ParentId);
    }
    
    /* Created By : Vitor
       Description : Test scenario for a note with Description bigger than 80 characters and no Title.
    */
    public static testMethod void testMisfilledNoteCreation(){
        Test.startTest();
            List<loan__Loan_Account__c> testlacc = [SELECT Id, Payoff_Loan_ID__c FROM loan__Loan_Account__c];
        
        	String str = header + testlacc[0].Payoff_Loan_ID__c + ',,TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest\r\n';
            LoanNoteImportController cont = new LoanNoteImportController();
        
            cont.csvFileBody = Blob.valueOf(str);
            cont.importCSVFile();
        Test.stopTest();
        
        List<Note> testNoteNumber = [SELECT ParentId FROM Note];
        
        System.assertEquals(1, testNoteNumber.size());
        System.assertEquals(testlacc[0].Id, testNoteNumber[0].ParentId);
    }
    
    /* Created By : Vitor
       Description : Test scenario for incorrect line format.
    */
    public static testMethod void testExceptionNoteCreation(){
        Test.startTest();
            List<loan__Loan_Account__c> testlacc = [SELECT Payoff_Loan_ID__c FROM loan__Loan_Account__c];
        
        	String str = header + testlacc[0].Payoff_Loan_ID__c + ',\r\n';
            LoanNoteImportController cont = new LoanNoteImportController();
        
            cont.csvFileBody = Blob.valueOf(str);
            cont.importCSVFile();
        Test.stopTest();
        
        List<Note> testNoteNumber = [SELECT id FROM Note];
        
        System.assertEquals(0, testNoteNumber.size());
    }
}