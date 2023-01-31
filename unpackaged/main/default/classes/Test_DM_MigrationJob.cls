@isTest
public class Test_DM_MigrationJob {
    @testSetup
    static void testData(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        loan__Trigger_Parameters__c triggerParam = new loan__Trigger_Parameters__c();
        triggerParam.loan__Disable_Loan_Account_Trigger__c=true;
        insert triggerParam;
        
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();  
        /*Account a2 = loan.TestHelper2.createInvestor('Bull', 1000);   //pallavi(commented)
        a2.loan__Undeployed_Funds__c=999999;
        update a2;*/
        Account a2 = new Account(Name = 'Bull', loan__Undeployed_Funds__c = 999999,loan__Investor__c = true);   //pallavi
        insert a2;
        loan.CustomSettingsUtil.getNS();
        //Create Borrower 
        Account b1 = loan.TestHelper2.createBorrower('ShoeString'); 
        loan.TestHelper.systemDate = Date.today(); 
        Id rtId = Schema.SObjectType.loan__Office_Name__c.getRecordTypeInfosByName().get('Root Branch').getRecordTypeId();
        Id prodRTId = Schema.SObjectType.loan__Loan_Product__c.getRecordTypeInfosByName().get('Loan Product Record Type').getRecordTypeId();

        loan__Currency__c curr = loan.TestHelper.createCurrency();
        loan__office_Type__c testBranchType = new loan__Office_Type__c(Name='Data Migration',
                                                        loan__Office_Type_Short_Code__c='TestSC' );
        insert testBranchType;
                                                               
        loan__MF_Account__c a1 = loan.TestHelper.createMFAccount('TestAccountForOffice', '10000 - ASSETS');
    
        loan__Branch_Location__c testLoc = new loan__Branch_Location__c(Name='Data Migration',
                                            loan__Address_Line_1__c = 'Add1',
                                            loan__Address_Line_2__c = 'Add2',
                                            loan__State__c = 'MH',
                                            loan__Phone__C = '32323232',
                                            loan__Zip_code__c = 33333
                                            );
        insert testLoc;
        
        loan__Office_Name__c dummyOffice = new loan__Office_Name__c(Name='PayOff Inc.',
                                                    loan__Office_Location__c = testLoc.ID,
                                                    loan__Office_Short_Name__c = 'XXXCSN',
                                                    loan__Cash_Account__c = a1.Id,
                                                    loan__Check_Account__c = a1.Id,
                                                    loan__Bank_Account_Checks__c = a1.Id,
                                                    loan__Inward_Check_Clearance_Account__c = a1.Id,
                                                    loan__Outward_Check_Clearance_Account__c= a1.Id,
                                                    loan__Profit_and_Loss_Account__c = a1.Id,
                                                    loan__Loan_Schedule_tied_to_Meeting_Schedule__c = false,
                                                    loan__Mark_Suspended_After_Days__c = 180,
                                                    loan__State__c = 'Active',
                                                    loan__Write_Off_Suggestion_Days__c = 90,
                                                    loan__Office_Type__c = testBranchType.ID,
                                                    loan__Days_in_advance_to_create_Collection_Rep__c=1,
                                                    loan__Current_System_Date__c = Date.Today().addDays(-30),
                                                    RecordTypeId = rtId,
                                                    loan__Is_Branch__c=true);
        insert dummyOffice;
                
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount); 
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet(); 
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        List<loan__Loan_Product__c> loanProductList = new List<loan__Loan_Product__c>();
        loan__Loan_Product__c simpleLP = DM_TestHelper.createLoanProduct('Simple Loan',dummyOffice, 
                                              dummyAccount, curr, dummyFeeSet, 'Loan'); 
        loanProductList.add(simpleLP);
        
        loan__Loan_Product__c difficultLP = DM_TestHelper.createLoanProduct('Difficult Loan',dummyOffice, 
                                              dummyAccount, curr, dummyFeeSet, 'Loan');
        loanProductList.add(difficultLP);
        
        loan__Loan_Product__c errorLp = DM_TestHelper.createLoanProduct('Simple Loan',dummyOffice,  
                                              dummyAccount, curr, dummyFeeSet, 'Loan');
        loanProductList.add(errorLp);
        
        
        insert loanProductList;
                     
        loan__Payment_Mode__c pMode = new loan__Payment_Mode__c(name='Cash');
       	//insert pMode;
        
        loan__Bank_Account__c bankAccount = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12', 
                                                 loan__Bank_Name__c = 'Some Bank', 
                                                 loan__Routing_Number__c = '999999999', 
                                                 loan__Account_Type__c = 'Savings', 
                                                 loan__Account_Usage__c = 'Borrower/Investor Account', 
                                                 loan__Account__c = b1.id,
                                                 Unmasked_Bank_Account_Number__c = '12345');    //pallavi
        insert bankAccount;
        
        List<DM_Loan_Account__c> dmLoanList = new List<DM_Loan_Account__c>();
        DM_Loan_Account__c dmloan = DM_TestHelper.createDMLOC(simpleLP,0.0,b1,dummyFeeSet,dummyOffice,5,'Declining Balance');
        dmloan.dm_thread_number__c = 1;
        dmloan.dm_loan_status__c = 'Active - Good Standing';
        dmLoanList.add(dmloan);
        
        DM_Loan_Account__c dmloan2 = DM_TestHelper.createDMLOC(difficultLP,0.0,b1,dummyFeeSet,dummyOffice,5,'Declining Balance');
        dmloan2.dm_thread_number__c = 2;
        dmloan2.dm_loan_status__c = 'Active - Bad Standing';
        dmLoanList.add(dmloan2);
        
        DM_Loan_Account__c dmloan3 = DM_TestHelper.createDMLOC(errorLp,0.0,b1,dummyFeeSet,dummyOffice,5,'Error');
        dmloan3.dm_thread_number__c = 3;
        dmLoanList.add(dmloan3);
        System.debug('dmLoanList----' + dmLoanList);    //remove
        insert dmLoanList;
        
        DM_Loan_Disbursal_Transaction__c ldt =  DM_TestHelper.fundLoan(dmLoan, Date.Today(), pmode,bankAccount);
        insert ldt;
        
        /*pallavi*/
        DM_Loan_Disbursal_Transaction__c ldt1 =  DM_TestHelper.fundLoan1(dmLoan2, Date.Today(), pmode,bankAccount);
        insert ldt1;
        
        DM_Disbursal_Transaction_Distribution__c ddt = DM_TestHelper.createDDTD();
        ddt.DM_Loan_Disbursal_Transaction__c = ldt.id;
        insert ddt;
        
        DM_Multi_Step_Loan_Setup__c rss = DM_TestHelper.createRSS(dmLoan);
        insert rss;
        /*pallavi*/
                                                        
        DM_Bill__c bill =  DM_TestHelper.createUnpaidDue(dmLoan, 6500.00);
        bill.DM_Due_Date__c = Date.today().addDays(1);
        bill.DM_DD_Primary_Flag__c = true;
        insert bill;
        
        /*pallavi*/
        DM_Bill__c bill1 =  DM_TestHelper.createUnpaidDue1(dmLoan2, 6500.00);
        bill1.DM_DD_Primary_Flag__c = true;
        bill1.DM_Due_Date__c = Date.Today().addDays(1);
        insert bill1;
        
        DM_Bill__c bill2 =  DM_TestHelper.createUnpaidDue1(dmLoan2, 6500.00);
        bill2.DM_DD_Primary_Flag__c = true;
        bill2.DM_External_Id__c='12345';
        insert bill2;
        /*pallavi*/
        
        DM_Repayment_Schedule_Summary__c dm_RSS = DM_TestHelper.CreateRSSData(dmLoan, 600.00);
        insert dm_RSS;
        
        DM_Charge__c charge =  DM_TestHelper.createUnpaidCharge(dmLoan, dummyFee, 100.00 );
        insert charge;
        
        DM_Repayment_Schedule__c AmzSchedule = DM_TestHelper.CreateAmzScheduleData(dmLoan, 1000.00);
        AmzSchedule.DM_Due_Date__c = Date.today().addDays(1);
        AmzSchedule.DM_Is_Billed__c = true;
        AmzSchedule.DM_isPaid__c = true;
        insert AmzSchedule;
        /*pallavi*/
        DM_Repayment_Schedule__c AmzSchedule1 = DM_TestHelper.CreateAmzScheduleData1(dmLoan2, 1000.00);
        insert AmzSchedule1;
        /*pallavi*/
        DM_Automated_Payment_Setup__c aps =  DM_TestHelper.createAutomatedPaymentSetup('DO it later', '', bankAccount,
                                                         dmLoan, '', pMode, Date.Today(),1);
        insert aps;
        
        DM_Loan_Payment_Transaction__c lpt = DM_TestHelper.createLoanPayment(dmLoan.Id, 10000.00,Date.today(),aPS, pMode, null);
        insert lpt;
        
        /*pallavi*/
        DM_Loan_Payment_Transaction__c lpt1 = DM_TestHelper.createLoanPayment1(dmLoan2.Id, 10000.00,Date.today(),aPS, pMode, null);
        insert lpt1;
        
        DM_Repayment_Plan__c rep = new DM_Repayment_Plan__c(DM_CL_Contract__c = dmLoan.Id,
                                                           DM_Due_Day__c = 5,
                                                           DM_Effective_Date__c = Date.today(),
                                                           DM_Number_of_Payments__c = 2,
                                                           DM_Payment_Start_Date__c = Date.today().addDays(1));
        insert rep;
        
        DM_Repayment_Plan__c rep1 = new DM_Repayment_Plan__c(DM_CL_Contract__c = dmLoan2.Id,
                                                           DM_Due_Day__c = 5,
                                                           DM_Effective_Date__c = Date.today(),
                                                           DM_Number_of_Payments__c = 2,
                                                           DM_Payment_Start_Date__c = Date.today().addDays(1));
        insert rep1;
        /*pallavi*/
        
        DM_Interest_Posting_Transaction__c IPT = DM_TestHelper.create_DMInterestPostingTransaction(dmLoan.Id,system.Today(),12758.00,1598.00,8900.90,890.00,false,system.Today(),234500.00,system.Today().addDays(-5),
                                        'Regular',true,false,system.today().addDays(-10),system.today().addDays(30));
        insert IPT;
        
        clcommon__Accounting_Entry__c accountingEntry = new clcommon__Accounting_Entry__c(clcommon__Transaction_Creation_Date__c=System.Today(),clcommon__Transaction_Date__c=System.Today());
        insert accountingEntry;
        
        DM_Accrual_Entry__c dmAccr = DM_TestHelper.create_DMAccruals(dmLoan.Id,accountingEntry.Id,System.Today(),10500.00,true,true,true,false,false);
        insert dmAccr;
        
        DM_Investment_Order__c dmInvOrder = DM_TestHelper.createInvestmentOrder(a2,dmLoan,70000);
        insert dmInvOrder;
        
        DM_Investor_Loan_Transaction__c dmILT = DM_TestHelper.createDMInvestorPaymentTxn(dmInvOrder,11000.00,1100,300,lpt.Id);
        insert dmILT;
        List<DM_StagingObject_Query_Generator__c> insertsec = new List<DM_StagingObject_Query_Generator__c>();
        
        DM_StagingObject_Query_Generator__c sec = DM_TestHelper.stagingObjGen(true,true,false,'DM_Investor_Loan_Transaction__c','',
                                                                               'id,DM_Accrued_Interest_Snapshot__c','DM_Investment_Order__c');
        insertsec.add(sec);
        
        sec = DM_TestHelper.stagingObjGen(true,true,false,'DM_Repayment_Transaction_Reversal__c','',
                                                                              'id,DM_Adjustment_Txn_Date__c,DM_Archive__c,DM_Balance__c,DM_Cleared__c,DM_Custom_Funding_Logic__c,DM_Interest_Rate__c,DM_Loan_Snapshot__c,DM_Reason_Code__c,DM_Reference__c,DM_Transaction_Time__c,DM_External_Id__c,DM_Loan_Payment_Transaction__c',
                                                                              'DM_Loan_Payment_Transaction__c');
        insertsec.add(sec);
        
        sec = DM_TestHelper.stagingObjGen(true,false,true,'DM_Investment_Order__c','DM_Loan__c',
                                          'id,DM_Account__c,DM_Accrued_Interest__c,DM_Amortization_Schedule_Generation_time__c,DM_Approval_Date__c,DM_Archive__c,DM_Buying_Price__c,DM_Certificate_Rate__c,DM_Charged_Off_Date__c,DM_Charged_Off_Fees__c,DM_Charged_Off_Interest__c,DM_Charged_Off_Principal__c,DM_Collect_Service_Fees_On__c,DM_Created_Loan_Delinquent_Days__c,DM_Created_Loan_Principal_Remaining__c,DM_Created_Loan_Status__c,DM_Discount_Percent__c,DM_Enabled__c,DM_End_Date__c,DM_Fees_Amount_Paid__c,DM_Generate_Amortization_Schedule__c,DM_Interest_Amount_Paid__c,DM_Interest_Exempted_From_Service_Fee__c,DM_Interest_Posted__c,DM_Interest_Rate_On_Due_Interest__c,DM_Interest_Rate_On_Due_IOA__c,DM_Interest_Rate_On_Due_Principal__c,DM_Interest_Rate_On_Loan__c,DM_Interest_Rounding_Error__c,DM_Investment_Amount__c,DM_IOA_Accrued__c,DM_IOA_Amount_Paid__c,DM_IOA_Posted__c,DM_Last_Interest_Accrual_Date__c,DM_Master_Archive_Object__c,DM_Minimum_Service_Fee__c,DM_Principal_Amount_Paid__c,DM_Rebate_Amount_Paid__c,DM_Reinvest_Interest__c,DM_Reinvest_Principal__c,DM_Service_Charge_On_Full_Payment_Amount__c,DM_Share__c,DM_Start_Date__c,DM_Status__c,DM_Summary__c,DM_Summary_Record_Id__c,DM_Total_Amount_Paid__c,DM_Write_Off_Amount__c,DM_Investor_Amortization_Schedule_Genera__c,DM_External_Id__c,DM_Loan__c,DM_Interest_Service_Rate__c',
                                          '');
        insertsec.add(sec);
        
        sec = DM_TestHelper.stagingObjGen(true,false,true,'dm_Automated_Payment_Setup__c','DM_CL_Contract__c',
                                          'id,DM_Bank_Account__c,DM_Debit_Date__c,DM_Transaction_Amount__c,DM_External_Id__c,DM_Type__c,DM_Amount_Type__c,DM_Payment_Mode__c,DM_Active__c,DM_Frequency__c,DM_Debit_Day__c,DM_Recurring_ACH_Start_Date__c,DM_CL_Contract__c',
                                          '');
        insertsec.add(sec);
        
        sec = DM_TestHelper.stagingObjGen(true,false,true,'DM_Repayment_Schedule_Summary__c','DM_CL_Contract__c',
                                          'id,DM_RSS_Seq__c,DM_External_Id__c,DM_RSS_Repayment_Dt__c,DM_RSS_Repayment_Amt__c,DM_RSS_No_Of_Pmts__c,DM_CL_Contract__c',
                                          '');
        insertsec.add(sec);
        
        sec = DM_TestHelper.stagingObjGen(true,false,true,'DM_Repayment_Plan__c','DM_CL_Contract__c',
                                          'id,DM_Application__c,DM_External_Id__c,DM_Effective_Date__c,DM_Frequency__c,DM_Frequency_Multiplier__c,DM_Number_Of_Payments__c,DM_Payment_Amount__c,DM_Payment_Start_Date__c,DM_Payment_Type__c,DM_Sequence_Number__c,DM_CL_Contract__c',
                                          '');
        insertsec.add(sec);
        
        sec = DM_TestHelper.stagingObjGen(true,false,true,'DM_Bill__c','DM_CL_Contract__c',
                                          'id,DM_External_Id__c,DM_Transaction_Date__c,DM_Due_Date__c,DM_Due_Amt__c,DM_Payment_Amt__c,DM_Payment_Satisfied__c,DM_Due_Type__c,DM_Payment_Date__c,DM_DD_Primary_Flag__c,DM_Due_Type_Description__c,DM_Interest_Billed__c,DM_Principal_Billed__c,DM_Interest_Paid__c,DM_Principal_Paid__c,DM_CL_Contract__c',
                                          '');
        insertsec.add(sec);
        
        sec = DM_TestHelper.stagingObjGen(true,false,true,'dm_Multi_Step_Loan_Setup__c','DM_Loan_Account__c',
                                          'id,DM_Start_Date__c,DM_Interest_Rate__c,DM_Sequence__c,DM_External_Id__c,dm_Loan_Account__c',
                                          '');
        insertsec.add(sec);
        
        sec = DM_TestHelper.stagingObjGen(true,false,true,'DM_Accrual_Entry__c','DM_CL_Contract__c',
                                          'id,DM_CL_Contract__c,DM_Accounting_Entry__c,DM_Transaction_Date__c,DM_GL_Posted__c,DM_Master_Archive_Object__c,DM_Amount__c,DM_Archive__c,DM_Internal_Accounting_Generated__c,Internal_Accounting_Reversal_Generated__c,DM_External_id__c','');
        insertsec.add(sec);
        
        sec = DM_TestHelper.stagingObjGen(true,false,true,'dm_Loan_Payment_Transaction__c','CL_Contract__c',
                                          'id,DM_Payment_Mode__c,DM_Transaction_Amount__c,DM_Receipt_Date__c,DM_Cleared__c,DM_Rejected__c,DM_Reversed__c,DM_Principal__c,DM_Interest__c,DM_Fees__c,DM_Is_Migrated__c,DM_Migrated_Reversal_Date__c,DM_Transaction_Date__c,DM_Transaction_time__c,DM_Transaction_Creation_Date__c,DM_LAPro_Posted_Date__c,DM_External_Id__c,DM_clearing_date__c,CL_Contract__c',
                                          '');
        insertsec.add(sec);
        
        sec = DM_TestHelper.stagingObjGen(true,false,true,'dm_Loan_Disbursal_Transaction__c','DM_CL_Contract__c',
                                          'id,DM_ACH_Filename__c,DM_Archived__c,DM_Bank_Account__c,DM_Check__c,DM_Cleared__c,DM_Contribution_From_Excess__c,DM_Custom_Logic__c,DM_Disbursal_Date__c,DM_Disbursal_Time__c,DM_Disbursed_Amt__c,DM_External_Id__c,DM_Loan_Disbursal_Transaction_Type__c,DM_Financed_Amount__c,DM_Interest_Rate__c,DM_Internal_Accounting_Generated__c,DM_Loan_Snapshot__c,DM_Master_Archive_Object__c,DM_Mode_Of_Payment__c,DM_Number_Of_Interest_Only_Payments__c,DM_Reference__c,DM_Rejected__c,DM_Reversed__c,DM_Sent_To_ACH__c,DM_Sent_To_ACH_On__c,DM_Summary__c,DM_Summary_Record_Id__c,DM_Pre_Paid_Fee__c,DM_Refinanced_Amount__c,DM_CL_Contract__c',
                                          '');
        insertsec.add(sec);
        
        sec = DM_TestHelper.stagingObjGen(true,false,true,'dm_Interest_Posting_Transaction__c','DM_CL_Contract__c',
                                          'id,DM_CL_Contract__c,DM_Transaction_Time__c,DM_Summary__c,DM_Summary_Record_Id__c,DM_Status__c,DM_Principal_Posted__c,DM_Principal_Paid__c,DM_Interest_Posted__c,DM_Interest_Paid__c,DM_Capitalization_Date__c,DM_Reversed__c,DM_Payment_Amount__c,DM_Payment_Date__c,DM_Transaction_Creation_Date__c,DM_Transaction_Posting_Date__c,DM_Transaction_Due_Date__c,DM_Principal_Remaining__c,DM_Is_Billed__c,DM_Interest_Posting_Type__c,DM_External_Id__c,DM_Due_Amount__c,DM_Accrued_to_Investor__c,DM_Amortization_Schedule__c,DM_Archive__c,DM_Balance__c,DM_Capitalized__c,DM_Current_Interest_Accrued__c,DM_Current_Interest_Accrued_On_Principal__c,DM_Discarded__c,DM_Interest_Posting_Transaction_Snapshot__c,DM_Interest_Rate__c,DM_Interest_Remaining__c,DM_Interest_unPaid__c,DM_Interest_Waived__c,DM_IOA_Summary__c,DM_Last_Accrual_Date__c,DM_Level__c,DM_Master_Archive_Object__c,DM_Paid__c,Parent_Interest_Posting_Transaction__c,DM_Posted__c',
                                          '');
        insertsec.add(sec);
        
        sec = DM_TestHelper.stagingObjGen(true,false,true,'dm_Repayment_Schedule__c','DM_Loan_Product__c',
                                          'id,DM_Due_Date__c,DM_Due_Principal__c,DM_Due_Interest__c,DM_Balance__c,DM_External_Id__c,DM_Is_Billed__c,DM_isPaid__c,DM_Paid_Interest__c,DM_Paid_Principal__c,DM_isBilledwasUnchecked__c,DM_Loan_Product__c',
                                          '');
        insertsec.add(sec);
        
        sec = DM_TestHelper.stagingObjGen(true,true,false,'DM_Disbursal_Transaction_Distribution__c','',
                                          'id,DM_Loan_Disbursal_Transaction__c,DM_Distribution_Type__c,DM_Distribution_Amount__c,DM_Name_of_Entity__c,DM_External_Id__c,DM_Reversed__c,DM_Sent_To_ACH_On__c,DM_Sent_To_ACH__c,DM_ACH_Filename__c',
                                          'DM_Loan_Disbursal_Transaction__c');
        insertsec.add(sec);
        
        sec = DM_TestHelper.stagingObjGen(true,true,false,'DM_Due_Payment__c','',
                                          'id,DM_Fees__c,DM_Payment_Amount__c,DM_Principal__c,DM_External_Id__c,DM_Interest__c,DM_Loan_Payment_Transaction__c,DM_Due__c,DM_Archived__c,DM_Master_Archive_Object__c,DM_Summary__c,DM_Summary_Record_Id__c,DM_TDS__c',
                                          'DM_Loan_Payment_Transaction__c');
        insertsec.add(sec);
        
        sec = DM_TestHelper.stagingObjGen(true,false,false,'DM_Loan_Account__c','',
                                          'id,DM_Account__c,Batch_Type__c,DM_Overdue_Principal__c,DM_Overdue_Interest__c,DM_Contract_Type__c,DM_Product__c,DM_Loan_Status__c,DM_Application_Date__c,DM_Disbursal_Date__c,DM_Expected_Disbursal_Date__c,DM_Loan_Account_External_Id__c,DM_Loan_Amount__c,DM_Expected_Repayment_Start_Date__c,DM_Number_of_Installments__c,DM_Frequency_of_Loan_Payment__c,DM_Next_Installment_Date__c,DM_Contractual_Interest_Rate__c,DM_Fees_Remaining__c,DM_Principal_Remaining__c,DM_Principal_Paid__c,DM_Last_Installment_Date__c,DM_Payment_Amount__c,DM_Disbursal_Amount__c,DM_Disbursed_Amount__c,DM_Interest_Only_Period__c,DM_Interest_Type__c,DM_Payment_Application_Mode__c,DM_Time_Counting_Method__c,DM_Interest_Calculation_Method__c,DM_Next_Due_Generation_Date__c,DM_Term_Cur__c,DM_AMZ_isBilled_check__c,DM_AMZ_isPaid_check__c,DM_Consolidated_Errors__c,DM_Due_Day__c,DM_Maturity_Date_Current__c,DM_Contractual_Due_Day__c,DM_First_Installment_Date__c,DM_Second_Installment_Date__c,DM_Accrual_Start_Date__c,DM_Rate_Change_Dt_Last__c,DM_Oldest_Due_Date__c,DM_Pmt_Amt_Cur__c,DM_Disbursal_Status__c,DM_Fee_Set__c,DM_Interest_Rate__c,DM_Application__c,lead_Guid__c,DM_thread_number__c,DM_U_LoanModExtDt__c,DM_U_LoanModForbearance__c,DM_U_LoanModForbearDt__c,DM_U_LoanModRate__c,DM_U_LoanModRateEffDt__c,DM_U_LoanModRateLengt__c,DM_U_LoanModTermExt__c,DM_Fees_Paid__c,DM_Interest_Paid__c,DM_Interest_Accrued_Not_Due__c,DM_Balloon_Payment__c,DM_Reschedule_Option_On_Excess_Payment__c,DM_Pre_Bill_Days__c,Product_Type__c,DM_Data_Error__c,DM_Product_Type__c,DM_Funding_in_Tranches__c,DM_Principal_Adjustment__c,DM_Principal_Adjustment_Subtract__c,DM_Rate_Change_Dt_Next__c,DM_Last_Accrual_Date__c,DM_LA_Amortization_Enabled__c,dm_la_amortization_frequency__c,dm_LA_Amortized_Balance_Type__c',
        								   '');
        insertsec.add(sec);
        
        sec = DM_TestHelper.stagingObjGen(true,false,true,'DM_Charge__c','DM_CL_Contract__c',
                                          'id,DM_CL_Contract__c,DM_Original_Amount__c,DM_Date__c,DM_Calculated_Interest3__c,DM_Fee__c,DM_External_Id__c,DM_Paid__c,DM_Waive__c,DM_payment_Amount__c','');
        insertsec.add(sec);
		
		insert insertsec;
        
        //pallavi
        MigrationPhase__c phase = new MigrationPhase__c();
        phase.name = 'phase1';
        phase.phase__c = 'phase1';
        insert phase;
        //pallavi
        
    }//END testData
    
    @isTest
    static void JobForSimpleLoanAndStrategyZero_IsTest(){ 
        //List<DM_Loan_Account__c> dmList = [select id from DM_Loan_Account__c];
        User u = [Select Id from User limit 1];
        system.runAs(u){
            Test.startTest();
            DM_MigrationJob dm1 = new Dm_MigrationJob();
            DM_MigrationJob dm2 = new Dm_MigrationJob(2);
            
            DM_MigrationJob dm = new Dm_MigrationJob('Simple Loan',1);
            Database.executeBatch(dm,1);
            Test.stopTest();
            List<loan__Loan_Account__c> loanAcc = [select Id,custesting__c,custesting2__c,custesting3__c,custesting4__c,cusTesting5__c,cusTesting6__c from loan__Loan_Account__c];
            System.assert(!loanAcc.isEmpty());
            /*system.assert(loanAcc[0].custesting__c<>null);
            system.assert(loanAcc[0].custesting2__c<>null);
            system.assert(loanAcc[0].custesting3__c<>null);
            system.assert(loanAcc[0].custesting4__c<>null);
            system.assertEquals(loanAcc[0].cusTesting5__c,false);
            system.assertEquals(loanAcc[0].cusTesting6__c,false);*/
            List<DM_Loan_Account__c> DMAcc = [select Id,migration_Status__c,DM_Error__c,DM_Is_Migrated__c,Migrated_CL_Contract__c from DM_Loan_Account__c where Batch_Type__c='Simple Loan'];
            system.assert(DMAcc[0].migration_Status__c=='Success');
            system.assert(DMAcc[0].DM_Is_Migrated__c);
            system.assert(DMAcc[0].Migrated_CL_Contract__c<>null);
        }//END system.runAs(u)
    }//END RunJobTemp_IsTest 
    
    @isTest
    static void JobForDifficultLoanAndStrategy1000_IsTest(){ 
        User u = [Select Id from User limit 1];
        system.runAs(u){
            Test.startTest();
            DM_MigrationJob dm = new Dm_MigrationJob('Difficult Loan',2);
            Database.executeBatch(dm,1);
            Test.stopTest();
            List<loan__Loan_Account__c> loanAcc = [select Id,custesting__c from loan__Loan_Account__c];
            System.assert(!loanAcc.isEmpty());
            List<DM_Loan_Account__c> DMAcc = [select Id,migration_Status__c,DM_Error__c,DM_Is_Migrated__c,Migrated_CL_Contract__c from DM_Loan_Account__c where dm_thread_number__c=2];
            System.debug('DM_Error__c----' + DMAcc[0].DM_Error__c);
            system.assert(DMAcc[0].migration_Status__c=='Success');
            system.assert(DMAcc[0].DM_Is_Migrated__c);
            system.assert(DMAcc[0].Migrated_CL_Contract__c<>null);
        }//END system.runAs(u) 
    }//END RunJobTemp_IsTest 
    
    @isTest
    static void JobForFailedCustomValidation_IsTest(){ 
        List<DM_Loan_Account__c> dmList = [select id from DM_Loan_Account__c];
        User u = [Select Id from User limit 1];
        system.runAs(u){
            Test.startTest();
            DM_MigrationJob dm = new Dm_MigrationJob('Error',3);
            Database.executeBatch(dm,1);
            Test.stopTest();
            List<loan__Loan_Account__c> loanAcc = [select Id,custesting__c from loan__Loan_Account__c];
            System.assert(loanAcc.isEmpty());
            List<DM_Loan_Account__c> DMAcc = [select Id,migration_Status__c,DM_Error__c,DM_Is_Migrated__c,Migrated_CL_Contract__c from DM_Loan_Account__c where Batch_Type__c='Error'];
            system.assert(DMAcc[0].migration_Status__c=='Failed');
            system.assert(!DMAcc[0].DM_Is_Migrated__c);
            system.assert(DMAcc[0].Migrated_CL_Contract__c==null);
        }//END system.runAs(u)
    }//END RunJobTemp_IsTest
}//END Test_DM_MigrationJob