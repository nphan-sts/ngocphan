/* ****************Modification History******************
 *Created By       Pallavi          2021-04-15
 ******************Modification History******************/
@isTest
global class Testcustomlptclearingdagjob_1 implements loan.IQueryBuilder {
    String query;
    @testSetup
    static void createData() {
        loan.TestHelper.systemDate = Date.newInstance(2013, 03, 31);
        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');

        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);

        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();

        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
                                                               dummyAccount,
                                                               curr,
                                                               dummyFeeSet);

        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();

        loan__Client__c dummyClient = loan.TestHelper.createClient(dummyOffice);
        
        loan.TestHelper.createDayProcessForFullYear(loan.TestHelper.systemDate);

        //Create a dummy Loan Account
        loan__Loan_Account__c loanAccount = loan.TestHelper.createLoanAccount(dummyLP,
                                                                   dummyClient,
                                                                   dummyFeeSet,
                                                                   dummyLoanPurpose,
                                                                   dummyOffice);
        
        //Disburse the loan.
        loan.TestHelper.setupMultiplePaymentModeACH();
        //loan.TestHelper2.createFileGenMetaData();        
        loan__Org_Parameters__c orgParams = loan.CustomSettingsUtil.getOrgParameters();
        orgParams.loan__Enable_New_Spread_Option__c = true;
        orgParams.loan__Draw_Amortization_Schedule__c = true;
        orgParams.loan__Rounding_Mode__c = loan.LoanConstants.ROUNDING_MODE_NEAREST;
        orgParams.loan__Concurrent_BatchJobs__c = 8;
        update orgParams;
        loan__Transaction_Approval_Config__c txnApprovalParams = loan.CustomSettingsUtil.getApprovalConfig();
        txnApprovalParams.loan__Payment__c = true;
        upsert txnApprovalParams;
        loan__Payment_Mode__c cash = [SELECT Id
                                FROM loan__Payment_Mode__c
                                WHERE Name = 'ACH'
                               ];
        loan.TestHelper.setupMultiplePaymentModeACH();
        loan__ACH_Parameters__c achParams = loan.CustomSettingsUtil.getACHParameters();
        achParams.loan__Query_For_Loan_Payment_Clearing__c = 'Testcustomlptclearingdagjob_1';	
        achParams.loan__Multiple_Payment_Method_Support__c = true;
        upsert achParams;
                
        loan__Loan_Payment_Transaction__c pmt = new loan__Loan_Payment_Transaction__c();
        pmt.loan__Loan_Account__c = loanAccount.Id;
        pmt.loan__Transaction_Date__c = loan.TestHelper.systemDate;
        pmt.loan__Transaction_Amount__c =100;
        pmt.loan__Payment_Mode__c = cash.Id;
        pmt.loan__sent_to_ach__c = true;
        pmt.loan__sent_to_ach_on__c = Date.newInstance(2013, 03, 30);
        insert pmt;
    }
    @isTest
    static void testCustomDag() {
        
        Map<String, List<Object>> jobs = new Map<String, List<Object>>(); //All Jobs of the SOD will be recorded here
        Map<String, Set<String>> dependencyList = new Map<String, Set<String>>();// Dependency list of all the SOD jobs will be here
        clcommon.DynamicJobAPI2 apiHandle = clcommon.APIFactory.getDynamicJobAPI2();
        String dagName = 'Custom DAG';
        //String ns = CommonUtil.getMyNameSpace();
        /*if (ns != null && ns != '') {
            ns = ns + '.';
        }*/
        
        jobs.put('CustomLoanPaymentTxnClearingDynamicJob',
                new List<Object>{
                'CustomLoanPaymentTxnClearingDynamicJob',	//ns + 
                1,
                null,
                'Logging',
                200,
                false,
                false,
                false
                }
               );
        dependencyList.put('CustomLoanPaymentTxnClearingDynamicJob', new Set<String>());
        apiHandle.addDag(dagName, jobs, dependencyList);
        
        Test.StartTest();
        
        clcommon.DynamicJobAPI2 apiHandle2 = clcommon.APIFactory.getDynamicJobAPI2();
        apiHandle2.runOnce(dagName);
                               
        Test.StopTest();
    }
    @isTest
    static void testCustomDag1() {
        Test.StartTest();
        
        String query1 = 'select id, name, loan__cleared__c, loan__clearing_date__c, loan__loan_account__c, loan__payment_mode__r.name FROM loan__loan_payment_transaction__c WHERE loan__rejected__c = false and loan__cleared__c = false and loan__sent_to_ach__c = true';
        CustomLoanPaymentTxnClearingDynamicJob a = new CustomLoanPaymentTxnClearingDynamicJob(query1,1);
        
        Set<String> paymentModes = new Set<String>();
        CustomLoanPaymentTxnClearingDynamicJob b = new CustomLoanPaymentTxnClearingDynamicJob(loan.TestHelper.systemDate,paymentModes);
        b.getInstance();
        Test.StopTest();
    }    
    global String getQuery(){
        	query = 'select id, name, loan__cleared__c, loan__clearing_date__c, loan__loan_account__c, loan__payment_mode__r.name FROM loan__loan_payment_transaction__c WHERE loan__rejected__c = false and loan__cleared__c = false and loan__sent_to_ach__c = true';         
            System.Debug('LoanPaymentTxnClearingJob ***Custom Query2***' + query);
            return query;
   }    
}