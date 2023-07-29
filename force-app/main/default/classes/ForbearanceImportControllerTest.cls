/*  Modification History
    Modified By          Jira ID                  Description
*   Shakul               LSP-529                  Refactored Test Class
*   Shakul               LSP-1104                 Added Repayment Schedules to the testsetup method (2022-12-08)
*/
@isTest
public class ForbearanceImportControllerTest {
    public static String[] csvFileLines;
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
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);

        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);

        //creating CL Product
        clcommon__CL_Product__c pr = new clcommon__CL_Product__c();
        pr.loan__Lending_Product__c = dummyLp.id;
        pr.clcommon__Product_Name__c = 'P1';
        insert pr;
        
        //STARt: LSP-1104
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
        loan__Loan_Account__c lAccOne = new loan__Loan_Account__c(loan__Account__c= account_Obj.Id,
                                                                loan__Product_Type__c='Flexible Amz Loan',
                                                                loan__Loan_Amount__c =1001,
                                                                loan__Loan_Product_Name__c=dummyLP.Id,
                                                                loan__Payment_Amount__c=101,
                                                                loan__Principal_Remaining__c = 501,
                                                                loan__Previous_Installment_Date__c= systemDate.addDays(-28),
                                                                application__c = application.id, 
                                                                loan__First_Installment_Date__c = systemDate.addDays(2),
                                                                loan__Next_Installment_Date__c = systemDate.addDays(32), 
                                                                loan__Maturity_Date_Current__c = systemDate.addYears(2), 
                                                                loan__Frequency_of_Loan_Payment__c = '7',  
                                                                loan__Last_Installment_Date__c = systemDate.addYears(2),
                                                                loan__Loan_Status__c = 'Active - Good Standing',
                                                                loan__Interest_Rate__c = 11,
                                                                loan__Term_Cur__c = 13,
                                                                Skipped_a_pay_Date__c = null,
                                                                Skipped_a_Pay__c = false
                                                                 );
        listLacc.add(lAccOne);
        insert listLacc; 
        
        List<loan__Repayment_Schedule__c> listRS = new List<loan__Repayment_Schedule__c>();
        
        loan__Repayment_Schedule__c rsOne = new loan__Repayment_Schedule__c();
        rsOne.loan__Archived__c = false;
        rsOne.loan__Due_Date__c = systemDate.addDays(1);
        rsOne.loan__Is_Billed__c = true;
        rsOne.loan__isPaid__c = false;
        rsOne.loan__Loan_Account__c = lacc.id;
        listRS.add(rsOne);
        
        loan__Repayment_Schedule__c rsTwo = new loan__Repayment_Schedule__c();
        rsTwo.loan__Archived__c = false;
        rsTwo.loan__Due_Date__c = systemDate.addDays(31);
        rsTwo.loan__Is_Billed__c = false;
        rsTwo.loan__isPaid__c = false;
        rsTwo.loan__Loan_Account__c = lacc.id;
        listRS.add(rsTwo);
        
        loan__Repayment_Schedule__c rsThree = new loan__Repayment_Schedule__c();
        rsThree.loan__Archived__c = false;
        rsThree.loan__Due_Date__c = systemDate.addDays(61);
        rsThree.loan__Is_Billed__c = false;
        rsThree.loan__isPaid__c = false;
        rsThree.loan__Loan_Account__c = lacc.id;
        listRS.add(rsThree);
        
        loan__Repayment_Schedule__c rsFour = new loan__Repayment_Schedule__c();
        rsFour.loan__Archived__c = false;
        rsFour.loan__Due_Date__c = systemDate.addDays(2);
        rsFour.loan__Is_Billed__c = true;
        rsFour.loan__isPaid__c = false;
        rsFour.loan__Loan_Account__c = lAccOne.id;
        listRS.add(rsFour);
        
        loan__Repayment_Schedule__c rsFive = new loan__Repayment_Schedule__c();
        rsFive.loan__Archived__c = false;
        rsFive.loan__Due_Date__c = systemDate.addDays(32);
        rsFive.loan__Is_Billed__c = false;
        rsFive.loan__isPaid__c = false;
        rsFive.loan__Loan_Account__c = lAccOne.id;
        listRS.add(rsFive);
        
        insert listRS;

    }

    /* Created By : Shakul Siddharth
       Description : To cover Skip a Pay logic having bad loans map and skip a pay process map from import csv Method
    */
    public static testMethod void testSkipaPay(){
        Test.startTest();
        List<loan__Loan_Account__c> testlacc = [SELECT id, Name, loan__Loan_Status__c FROM loan__Loan_Account__c];
        testlacc[0].loan__Loan_Status__c = 'Closed- Written Off';
        update testlacc[0];
        String str = testlacc[0].Name+',2\n'+testlacc[1].Name+',1';
        ForbearanceImportController cont = new ForbearanceImportController();
        cont.csvFileBody = Blob.valueOf(str);
        String csvAsString = cont.csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 
        cont.importCSVFile();
        cont.performSkipaPayLoan();
        Test.stopTest();
        List<clcommon__Repayment_Plan__c> testRepayPlan = [SELECT id FROM clcommon__Repayment_Plan__c];
        System.assertEquals(1, testRepayPlan.size());
    }
}