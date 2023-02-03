/******************Modification History*****************************************
 * Punith          2022-10-07          LSP-452**
 * ****************************************************************************/
@isTest
public class TestInterestLossCalcJob {
    
    private static testMethod void testInterestLossCalcJob() {
        loan.TestHelper.systemDate = Date.newInstance(2016, 08, 01);
        loan.TestHelper.createSeedDataForTesting();
        //Create a Currency
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        
        //Create a MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        
        //Create a Office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice('TestOffice', false);
        insert loan.TestHelper.createMultipleDayProcessRecs(loan.TestHelper.systemDate, dummyOffice, 90, loan.TestHelper.systemDate);
        //Create a Client
        loan__Client__c dummyClient = loan.TestHelper.createClient(dummyOffice);

        Account account = new Account(Name = 'dummyAccount', peer__First_Name__c = 'dummy', peer__Last_Name__c = 'Account');
        insert account;
        
        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProductwithProductType('TestLoanProductXXX',
                                                                              dummyOffice,
                                                                              dummyAccount,
                                                                              curr,
                                                                              dummyFeeSet,
                                                                              'Declining Balance',
                                                                              12,
                                                                              24,
                                                                              loan.LoanConstants.LOAN_ATTRIBUTES_SAME_FOR_ALL_LOANS,
                                                                              loan.LoanConstants.FLEXIBLE_AMZ);
        dummyLP.loan__Excess_Threshold_For_Reschedule__c = 30;
        dummyLP.loan__Reschedule_Option_on_Excess_Payment__c = loan.LoanConstants.LOAN_RESCHEDULE_PAYMENT_CHANGE;
        update dummyLP;
        
        //Create a Loan Purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();

        loan__Loan_Account__c dummyLoanAccount = loan.TestHelper.createLoanAccount(dummyLP,
                                                                                   dummyClient,
                                                                                   dummyFeeSet,
                                                                                   dummyLoanPurpose,
                                                                                   dummyOffice);

        dummyLoanAccount.loan__Time_Counting_Method__c = loan.LoanConstants.TIME_COUNTING_ACTUAL_DAYS;
        dummyLoanAccount.loan__Account__c = account.Id;
        dummyLoanAccount.loan__Reschedule_Option_on_Excess_Payment__c = loan.LoanConstants.LOAN_RESCHEDULE_PAYMENT_CHANGE;
        update dummyLoanAccount;
        
        loan__Payment_Mode__c cash = [SELECT Id
                                      FROM loan__Payment_Mode__c
                                      WHERE Name = 'Cash'
                                     ];
        
        loan__Loan_Disbursal_Transaction__c distxn = new loan__Loan_Disbursal_Transaction__c();
        distxn.loan__Loan_Account__c = dummyLoanAccount.Id;
        distxn.loan__Mode_of_Payment__c = cash.Id;
        distxn.loan__Disbursed_Amt__c = 10000;
        loan.LoanDisbursalActionAPI a = new loan.LoanDisbursalActionAPI(distxn);
        a.disburseLoanAccount();
        
        //org parameters
        loan__Org_Parameters__c orgParam = loan.CustomSettingsUtil.getOrgParameters();
        orgParam.loan__Enable_New_Spread_Option__c = true;
        upsert orgParam;
        
        loan__Loan_Account__c loanAccount = [SELECT Id,
                                                  Name,
                                                  loan__Loan_Status__c,
                                                  loan__Loan_Product_Name__c,
                                                  loan__Loan_Amount__c,
                                                  loan__Interest_Rate__c,
                                                  loan__Principal_Remaining__c,
                                                  loan__Interest_Remaining__c,
                                                  loan__Fees_Remaining__c,
                                                  loan__Loan_Balance__c,
                                                  loan__Interest_Posted__c,
                                                  loan__Capitalized_Interest__c,
                                                  loan__Capitalized_Fee__c,
                                                  loan__Excess__c,
                                                  loan__Client__c,
                                                  loan__Number_of_Installments__c,
                                                  loan__Last_Transaction_Type__c,
                                                  loan__Last_Transaction_Timestamp__c,
                                                  loan__Last_Transaction_Id__c,
                                                  loan__Interest_Accrued_Not_Due__c,
                                                  loan__Next_Interest_Posting_Date__c,
                                                  loan__Accrual_Stop_Indicator__c,
                                                  loan__Time_Counting_Method__c,
                                                  loan__Interest_Calculation_Method__c,
                                                  loan__Frequency_of_Loan_Payment__c,
                                                  loan__Term_Cur__c,
                                                  loan__Pmt_Amt_Cur__c,
                                                  loan__Reschedule_Status__c,
                                                  loan__Last_Accrual_Date__c
                                           FROM loan__Loan_Account__c
                                          ];
        loanAccount.loan__Is_Interest_Posting_Enabled__c = true;
        loanAccount.loan__Interest_Posting_Frequency__c = loan.LoanConstants.LOAN_PAYMENT_FREQ_MONTHLY;
        loanAccount.loan__Last_Accrual_Date__c = loan.TestHelper.systemDate.addMonths(2).addDays(-1);
        loanAccount.loan__Next_Installment_Date__c = loan.TestHelper.systemDate.addMonths(3).addDays(-1);
        loanAccount.loan__Previous_Installment_Date__c = loan.TestHelper.systemDate.addMonths(2).addDays(-1);
        loanAccount.loan__Number_Of_Days_Overdue__c = 40;
        loanAccount.loan__Interest_Accrued_Not_Due__c = 13.76;
        loanAccount.loan__Interest_Remaining__c = 94.63;
        loanAccount.loan__Fees_Remaining__c = 300;
        loanAccount.loan__Delinquent_Amount__c = 1721.08;
        loanAccount.loan__Principal_Posted__c = 1626.45;
        loanAccount.loan__Pay_off_Amount_As_Of_Today__c = loanAccount.loan__Principal_Remaining__c + loanAccount.loan__Interest_Remaining__c
                                                    + loanAccount.loan__Interest_Accrued_Not_Due__c + loanAccount.loan__Fees_Remaining__c;
        update loanAccount;
        
        Date systemDate = loan.TestHelper.systemDate.addMonths(2).addDays(6);
        loan.GlobalProcessFacade.moveSystemToDate(systemDate, false);
        
        Test.startTest();
        
        loan__Loan_Payment_Transaction__c loanPayTxn1 = new loan__Loan_Payment_Transaction__c(loan__Transaction_Date__c = systemDate,
                                                                                 loan__Payment_Mode__c = cash.id,
                                                                                 loan__Transaction_Amount__c = 5,
                                                                                 loan__Loan_Account__c = loanAccount.id);
        insert loanPayTxn1;
        
        loan__Loan_Payment_Transaction__c loanPayTxn = new loan__Loan_Payment_Transaction__c(loan__Transaction_Date__c = systemDate,
                                                                                 loan__Payment_Mode__c = cash.id,
                                                                                 loan__Transaction_Amount__c = 5000,
                                                                                 loan__Loan_Account__c = loanAccount.id);
        insert loanPayTxn;
        
        loanAccount = loan.TestHelper2.getLoanAccount(loanAccount.Id);
        system.assertEquals('Pending', loanAccount.loan__Reschedule_Status__c);
        
        loan.LoanRescheduleJob job = new loan.LoanRescheduleJob(systemDate, false, 50, null);
        Database.executeBatch(job, 200);

        Test.stopTest();
        loanAccount = loan.TestHelper2.getLoanAccount(loanAccount.Id);
        system.assertEquals('Success', loanAccount.loan__Reschedule_Status__c);
        
        loanAccount.loan__Interest_Remaining__c = 100;
        loanAccount.Interest_Loss__c = true;
        update loanAccount;
        
        List<loan__Loan_Account__c> loanAccountList = (List<loan__Loan_Account__c>)Database.query(InterestLossCalcJob.getQuery());
        InterestLossCalcHandler handler = new InterestLossCalcHandler(loanAccountList);
        handler.process();
        
        loanAccount = [SELECT Id,
                              Interest_Amount_Loss__c
                       FROM loan__Loan_Account__c
                       WHERE Id = :loanAccount.Id
                      ];
        
        system.debug('*****' + loanAccount);
        
        InterestLossCalcJob intJob = new InterestLossCalcJob();
        Database.executeBatch(intJob);
        
        intJob.getRuntimeQuery();
        intJob.getRuntimeQueryForPipelinedExecution(null);
        intJob.doInitialize();
    }

}