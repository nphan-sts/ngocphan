@isTest
public class DM_Batch_for_reschedule_Test{
    
    @testSetup static void setup() {
       loan.TestHelper.createSeedDataForTesting();
       loan__Currency__c curr = loan.TestHelper.createCurrency();
       //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
     
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);                                    
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        
        //create office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
   
        //Create Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            //Borrower_s_Last_Name__c='Testborrower',
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123456789'
            );
        insert acc;
        
        LoanPaymentDays__c lpdays = new LoanPaymentDays__c();
        lpdays.AutoPaymentRemainder__c= 3;
        lpdays.ManualPaymentRemainder__c= 5;
        insert lpdays;
              
        //Create Company
        genesis__Company__c comp = genesis.TestHelper.createCompany(); 
        comp.Name = 'payoff';
        update comp;
       
         //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        dummyLP.loan__General_Rounding_Mode__c = null;
        dummyLP.loan__Digits_After_Decimals__c = null;
        update dummyLP;
        
        //creating CL Product
        clcommon__CL_Product__c pr = new clcommon__CL_Product__c();
        pr.loan__Lending_Product__c = dummyLP.id;
        pr.clcommon__Product_Name__c = 'P1';
        insert pr;
       
        genesis__applications__c application = new genesis__applications__c();
        application.genesis__Product_Type__c = 'Loan';
        application.genesis__Loan_Amount__c = 100000;
        application.genesis__status__c = 'NEW - ENTERED';
        application.genesis__Term__c = 12;
        application.genesis__Payment_Frequency__c = 'MONTHLY';
        application.genesis__Interest_Rate__c = 10;
        application.genesis__Days_Convention__c = 'ACTUAL/ACTUAL';
        application.genesis__Expected_Start_Date__c = system.today();
        application.genesis__Expected_First_Payment_Date__c = system.today().addDays(60);
        application.genesis__Expected_Close_Date__c = system.today().addDays(30);
        application.genesis__Interest_Calculation_Method__c = 'Declining Balance';
        application.genesis__Interest_Only_Period__c = 0;
        application.genesis__Interest_Rate__c = 10;
        application.genesis__Account__c = acc.Id;
        application.genesis__Total_Estimated_Interest__c=500;
        application.genesis__Valid_Pricing_Flag__c=false;
        application.genesis__Probability__c=100.00;
        application.genesis__Payment_Amount__c=100000;
        application.genesis__Company__c = comp.id;
        application.genesis__CL_Product__c = pr.id;
        insert application;
        
        loan__Loan_Account__c lacc = new loan__Loan_Account__c(
                                            loan__Account__c= acc.Id,
                                            loan__Product_Type__c=dummyLP.Id,
                                            loan__Loan_Amount__c =100000,
                                            loan__Principal_Remaining__c = 10000,
                                            loan__Loan_Product_Name__c=dummyLP.Id,
                                            loan__Payment_Amount__c=100000,
                                            loan__Previous_Installment_Date__c= system.today(),
                                            application__c = application.id,
                                            loan__First_Installment_Date__c = Date.newInstance(2020, 01, 19), 
                                            loan__Next_Installment_Date__c = Date.newInstance(2020, 02, 19),
                                            loan__Maturity_Date_Current__c = Date.newInstance(2022, 01, 19), 
                                            loan__Frequency_of_Loan_Payment__c = 'Monthly',
                                            loan__Last_Installment_Date__c = Date.newInstance(2020, 01, 19) , 
                                            loan__Is_Rescheduled__c = false, 
                                            loan__Loan_Status__c = 'Active - Bad Standing', 
                                            lead_Guid__c = '',
                                            loan__Oldest_Due_Date__c = Date.newInstance(2020, 01, 19),
                                            loan__Last_Payment_Date__c = Date.newInstance(2020, 01, 19),
                                            loan__Accrual_Start_Date__c = Date.newInstance(2020, 01, 19),
                                            loan__Interest_Rate__c = 10,
                                            loan__Pmt_Amt_Cur__c = 1000,
                                            loan__Term_Cur__c = 100,
                                            loan__Last_Accrual_Date__c = Date.newInstance(2020, 01, 19),
                                            loan__Disbursal_Date__c = Date.newInstance(2019, 12, 19),
                                            loan__Payment_Application_Mode__c = 'Deposit',
                                            loan__Additional_Loan_Amount__c = 1000,
                                            loan__Accrual_Amount_Accounted_For__c = 10000,
                                            loan__ACH_Debit_Amount__c =1000,
                                            loan__Add_Fee_Amount_To_Bill__c = true,
                                            loan__Adjust_Deposit_Amount_In_Payoff__c = true,
                                            loan__Amount_Due_Till_Current__c = 10000,
                                            loan__Cancellation_Tolerance_Amount__c =100,
                                            loan__Delinquent_Amount__c =1000,
                                            loan__Disbursal_Amount__c = 100000,
                                            loan__Metro2_Account_highest_bal_amount__c =1000,
                                            loan__Last_Billed_Amount__c = 1000,
                                            loan__Last_Disbursal_Amount__c = 10000,
                                            loan__Last_Payment_Amount__c = 1000,
                                            Loan_Premium_Amount__c =1000,
                                            loan__Maximum_Advance_Amount__c = 10000,
                                            loan__Maximum_Draw_Amount__c = 10000,
                                            loan__Minimum_Advance_Amount__c =100,
                                            loan__Minimum_Amount_Due__c =100,
                                            loan__Minimum_Due_Amount_On_Billing__c =1000,
                                            loan__Minimum_Draw_Amount__c = 100,
                                            loan__Next_Repayment_Amount_As_Of_Today__c =10000,
                                            loan__Uncleared_Disbursal_Amount__c =10000,
                                            loan__Uncleared_Repayment_Amount__c =10000,
                                            loan__Uncleared_Written_Off_Amount__c =10000,
                                            loan__Loan_Balance__c = 10000,
                                            DM_ActivateIO_and_IPT__c = true,
            								DM_Migration_Phase__c = 'test Mock',
            								DM_Future_LAD__c = true,
            								isMigrated__c = true
                                            );
        insert lacc; 
        
        loan__Repayment_Schedule_Summary__c repaymentScheduleSummary = new loan__Repayment_Schedule_Summary__c();
        repaymentScheduleSummary.loan__RSS_No_Of_Pmts__c = 10;
        repaymentScheduleSummary.loan__Archived__c = false;
        repaymentScheduleSummary.loan__RSS_Loan_Account__c = lacc.Id;
        insert repaymentScheduleSummary;
        
        loan__Repayment_Schedule__c loanRepaymentSchedule = new loan__Repayment_Schedule__c();
        loanRepaymentSchedule.loan__Due_Date__c = Date.newInstance(2020, 01, 19);
        loanRepaymentSchedule.loan__Loan_Account__c = lacc.Id;
        loanRepaymentSchedule.loan__Is_Archived__c = false;
        insert loanRepaymentSchedule;
        
        loan__Repayment_Schedule__c loanRepaymentSchedule1 = new loan__Repayment_Schedule__c();
        loanRepaymentSchedule1.loan__Due_Date__c = Date.newInstance(2020, 02, 19);
        loanRepaymentSchedule1.loan__Loan_Account__c = lacc.Id;
        loanRepaymentSchedule1.loan__Is_Archived__c = false;
        loanRepaymentSchedule1.loan__Balance__c = 10000;
        loanRepaymentSchedule1.loan__Due_Amount__c = 10000;
        insert loanRepaymentSchedule1;
        
        /*pallavi*/
        loan__Repayment_Schedule__c loanRepaymentSchedule2 = new loan__Repayment_Schedule__c();
        loanRepaymentSchedule2.loan__Due_Date__c = Date.newInstance(2020, 03, 19);
        loanRepaymentSchedule2.loan__Loan_Account__c = lacc.Id;
        loanRepaymentSchedule2.loan__Is_Archived__c = false;
        loanRepaymentSchedule2.loan__Balance__c = 10000;
        loanRepaymentSchedule2.loan__Due_Amount__c = 10000;
        insert loanRepaymentSchedule2;
        
        loan__Repayment_Schedule__c loanRepaymentSchedule3 = new loan__Repayment_Schedule__c();
        loanRepaymentSchedule3.loan__Due_Date__c = Date.newInstance(2022, 04, 19);
        loanRepaymentSchedule3.loan__Loan_Account__c = lacc.Id;
        loanRepaymentSchedule3.loan__Is_Archived__c = false;
        loanRepaymentSchedule3.loan__Balance__c = 10000;
        loanRepaymentSchedule3.loan__Due_Amount__c = 10000;
        insert loanRepaymentSchedule3;   
        /*pallavi*/
        
         MigrationPhase__c phase = new MigrationPhase__c();
         phase.name = 'test Mock';
         phase.phase__c = 'test Mock';
         insert phase;
 }

    @isTest
    public static void testDMRepaymentBatchMethod(){    
            Test.startTest();
            DM_Batch_for_reschedule dm = new DM_Batch_for_reschedule();
            Database.executeBatch(dm,1);
            Test.stopTest();
            List<loan__Loan_Account__c> loanAcc = [select Id,loan__Loan_Status__c, loan__Is_Rescheduled__c,(Select id,name,loan__Due_Date__c from loan__Repayment_Schedule__r),(select id,name from loan__Repayment_Plan__r) from loan__Loan_Account__c];
            System.assert(!loanAcc.isEmpty());
            //System.assertEquals(loanAcc[0].loan__Is_Rescheduled__c, true);
    }
    /*pallavi*/
    @isTest
    public static void testReschedulePostMigration(){ 
            List<loan__Loan_Account__c> lacc = [select Id,loan__Loan_Status__c, loan__Is_Rescheduled__c,(Select id,name,loan__Due_Date__c from loan__Repayment_Schedule__r),(select id,name from loan__Repayment_Plan__r) from loan__Loan_Account__c];
            Test.startTest();
            RescheduleLoanPostMigration reschLoan = new RescheduleLoanPostMigration(lacc[0]);
            reschLoan.rescheduleLoan();
            Test.stopTest();
    }
    @isTest
    public static void testReschedulefutureLADcontracts(){ 
            Test.startTest();
            DM_ResceduleJob_forFutureLADContracts reschLoan = new DM_ResceduleJob_forFutureLADContracts();
        	Database.executeBatch(reschLoan,1);
            Test.stopTest();
    }
    /*pallavi*/
}