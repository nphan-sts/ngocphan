@isTest(seealldata=false)
global class schedulelptclearjobtestclass {
    @testSetup
    static void setup() {
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.systemDate = Date.today();
        //List<filegen__File_Metadata__c> metadata = Test.loadData(filegen__File_Metadata__c.sObjectType,'TestMetaData');
        loan.TestHelper.setupMultiplePaymentModeACH();
        loan.TestHelper2.createFileGenMetaData();        
        loan__Org_Parameters__c orgParams = loan.CustomSettingsUtil.getOrgParameters();
        orgParams.loan__Enable_New_Spread_Option__c = true;
        orgParams.loan__Draw_Amortization_Schedule__c = true;
        orgParams.loan__Rounding_Mode__c = loan.LoanConstants.ROUNDING_MODE_NEAREST;
        orgParams.loan__Concurrent_BatchJobs__c = 8;
        /*orgParams.LPT_Creation_Thread_Number__c = 8;
        orgParams.loan__LPT_Clearing_Thread_Number__c =8;
        orgParams.loan__Payment_Job_Days__c = 20;*/
        upsert orgParams;
        loan__Transaction_Approval_Config__c txnApprovalParams = loan.CustomSettingsUtil.getApprovalConfig();
        txnApprovalParams.loan__Payment__c = true;
        upsert txnApprovalParams;
        loan__ACH_Parameters__c achParams = loan.CustomSettingsUtil.getACHParameters(); 
        achParams.loan__Multiple_Payment_Method_Support__c = true;
        upsert achParams;
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');

        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        insert (loan.TestHelper.createMultipleDayProcessRecs(loan.TestHelper.systemDate, dummyOffice, 365, loan.TestHelper.systemDate));
        loan__Client__c dummyClient = loan.TestHelper.createClient(dummyOffice);
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
                                                               dummyAccount,
                                                               curr,
                                                               dummyFeeSet);
        loan__Payment_Mode__c pMode = [SELECT id 
                                 FROM loan__Payment_Mode__c 
                                 WHERE Name = 'ACH'];
        Account account = loan.TestHelper2.createBorrower('Bull');
        loan__Bank_Account__c bankAccount = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
                                                          loan__Bank_Name__c = 'Some Bank',
                                                          loan__Account_Type__c = 'Checking',
                                                         loan__Account_usage__c = 'Collections Trust Account',
                                                          loan__routing_number__c = '111111111',
                                                          loan__active__c = true,
                                                          Unmasked_Bank_Account_Number__c = '1234');
        insert bankAccount;
        loan.TestHelper2.createAutomatedPaymentConfiguration(loan.LoanConstants.LOAN_PAYMENT,pMode,bankAccount,'LoanPaymentTxnNACHAGen');
        
        loan__Loan_Account__c loanAccount1 = loan.TestHelper.createLoanAccountForAccountObj(dummyLP,
                                                                                 account,
                                                                                 dummyFeeSet,
                                                                                 dummyLoanPurpose,
                                                                                 dummyOffice);
        loanAccount1.loan__thread_number__c = 1;
        loanAccount1.loan__Due_Day__c = 1;
        update loanAccount1;
        loan__Loan_Disbursal_Transaction__c disbTxn1 = new loan__Loan_Disbursal_Transaction__c();
        disbTxn1.loan__Disbursal_Date__c = loan.TestHelper.systemDate;
        disbTxn1.loan__Disbursed_Amt__c = loanAccount1.loan__Loan_Amount__c;
        disbTxn1.loan__Loan_Account__c = loanAccount1.id;
        disbTxn1.loan__Mode_of_Payment__c =  pMode.id;
        insert disbTxn1;
        
        loan__Loan_Account__c loanAccount2 = loan.TestHelper.createLoanAccountForAccountObj(dummyLP,
                                                                                 account,
                                                                                 dummyFeeSet,
                                                                                 dummyLoanPurpose,
                                                                                 dummyOffice);
        loanAccount2.loan__thread_number__c = 2;
        loanAccount2.loan__Due_Day__c = 1;
        update loanAccount2;
        loan__Loan_Disbursal_Transaction__c disbTxn2 = new loan__Loan_Disbursal_Transaction__c();
        disbTxn2.loan__Disbursal_Date__c = loan.TestHelper.systemDate;
        disbTxn2.loan__Disbursed_Amt__c = loanAccount2.loan__Loan_Amount__c;
        disbTxn2.loan__Loan_Account__c = loanAccount2.id;
        disbTxn2.loan__Mode_of_Payment__c =  pMode.id;
        insert disbTxn2;
    }
    @isTest
    static void lptclearingjobScheduler () {        
         
         schedulelptclearjob batchSch=new schedulelptclearjob(); 
         String sch='0 30 15 * * ?'; 
        //System.schedule(String jobName, String cronExp, APEX_OBJECT schedulable);
          
         test.starttest();
         System.schedule('Loan Payment TXN clearing job 1', sch , batchSch); 
         test.stopTest();
    }
}