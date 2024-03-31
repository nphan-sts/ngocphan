@isTest
public class DM_Validation_JOB_stagingObjects_Test {
    @testSetup static void setup() {
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
        
        Account a2 = new Account(Name = 'Bull', loan__Undeployed_Funds__c = 999999,loan__Investor__c = true);
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
        
        insert loanProductList;
                     
        loan__Payment_Mode__c pMode = new loan__Payment_Mode__c(name='Cash');
       // insert pMode;
        
        loan__Bank_Account__c bankAccount = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12', 
                                                 loan__Bank_Name__c = 'Some Bank', 
                                                 loan__Routing_Number__c = '999999999', 
                                                 loan__Account_Type__c = 'Savings', 
                                                 loan__Account_Usage__c = 'Borrower/Investor Account', 
                                                 loan__Account__c = b1.id,
                                                 Unmasked_Bank_Account_Number__c = '12345');    
        insert bankAccount;
        
        DM_Loan_Account__c dmLoan = new DM_Loan_Account__c(dm_Account__c= null,//b1.Id,
                                            dm_Product_Type__c=null,//dummyLP.Id,
                                            dm_Loan_Amount__c = 1000,//null,//100000,
                                            dm_Principal_Remaining__c = 100,//10000,
                                            dm_Product_Name__c= null,//dummyLP.Id,
                                            dm_product__c = null,//dummyLP.Id,
                                            dm_contact__c = null,//acc.Id,
                                            dm_Payment_Amount__c=null,//100000,
                                            dm_Previous_Installment_Date__c= null,// system.today(),
                                            dm_First_Installment_Date__c = null,//Date.newInstance(2020, 01, 19),
                                            dm_Next_Installment_Date__c = null,//Date.newInstance(2020, 02, 19), 
                                            dm_Maturity_Date_Current__c = null,//Date.newInstance(2022, 01, 19), 
                                            dm_Frequency_of_Loan_Payment__c = null,//'Monthly', 
                                            dm_Last_Installment_Date__c = null,//Date.newInstance(2020, 01, 19) ,
                                            dm_Draw_Period_End_Date__c = null,//Date.newInstance(2020, 01, 09),
                                            dm_Expected_Disbursal_Date__c = null,//Date.newInstance(2019, 01, 09),
                                            dm_Expected_Repayment_Start_Date__c = null,//Date.newInstance(20120, 01, 09),
                                            dm_Rate_Change_Dt_Next__c = null,//Date.newInstance(20120, 01, 09),
                                            dm_Is_Rescheduled__c = false, 
                                            dm_Loan_Status__c = 'Active - Bad Standing',
                                            lead_Guid__c = '',
                                            dm_Oldest_Due_Date__c = null,//Date.newInstance(2020, 01, 19),
                                            dm_Last_Payment_Date__c = null,//Date.newInstance(2020, 01, 19),
                                            dm_Accrual_Start_Date__c = null,//Date.newInstance(2020, 01, 19),
                                            dm_Interest_Rate__c = null,//10,
                                            dm_Pmt_Amt_Cur__c = null,//100,
                                            dm_Term_Cur__c = null,//100,
                                            dm_Last_Accrual_Date__c = null,//Date.newInstance(2020, 01, 19),
                                            dm_Disbursal_Date__c = null,// Date.newInstance(2019, 12, 19),
                                            dm_Payment_Application_Mode__c = null,//'Deposit',
                                            dm_Number_of_Installments__c = null,//10,
                                            dm_Next_Due_Generation_Date__c = null,//Date.newInstance(2020, 01, 19),
                                            dm_Due_Day__c = 0,
                                            dm_LA_Amortization_Enabled__c = true,
                                            dm_la_amortization_frequency__c = null,//'Monthly',
                                            dm_LA_Amortized_Balance_Type__c = null,//'abc',
                                            dm_Fees_Remaining__c = -1,//10000   
                                            dm_Principal_Paid__c = 100,
                                            dm_Principal_Adjustment__c = 0,
                                            dm_Principal_Adjustment_Subtract__c = 0,
                                            dm_Disbursed_Amount__c = 1000
                                            );
        insert dmLoan;
                       
        dm_Loan_Disbursal_Transaction__c disbursalTransaction = new dm_Loan_Disbursal_Transaction__c();
        //disbursalTransaction.Id = 'LDTIName';
        disbursalTransaction.DM_CL_Contract__c = dmLoan.Id;
        disbursalTransaction.dm_ACH_Filename__c = null;//'abcd';
            //disbursalTransaction.dm_Bank_Account__c = null;//acc.Id;
            disbursalTransaction.dm_Disbursal_Date__c = null;//dmLoan.dm_Disbursal_Date__c;//Date.newInstance(2020, 01, 19);
            disbursalTransaction.dm_Disbursal_Time__c = null;//Date.newInstance(2020, 01, 19);
            disbursalTransaction.dm_Disbursed_Amt__c = null;//100000;
            disbursalTransaction.dm_External_Id__c = null;//'EXT12345';
            disbursalTransaction.dm_Loan_Disbursal_Transaction_Type__c = null;//'With Fee';
            disbursalTransaction.dm_Financed_Amount__c = null;//100000;
            disbursalTransaction.dm_Interest_Rate__c = null;//10;
            disbursalTransaction.dm_Loan_Snapshot__c = null;//'Snapshot';
            disbursalTransaction.dm_Mode_of_Payment__c = null;//pMode.Id;//'ACH';
            disbursalTransaction.dm_Number_Of_Interest_Only_Payments__c = null;//8;
            disbursalTransaction.dm_Pre_Paid_Fee__c = null;//1000;
            disbursalTransaction.dm_Refinanced_Amount__c = null;//1000;
            disbursalTransaction.DM_bank_Account__c = null;//bankAccount.id;
            //disbursalTransaction.DM_External_Id__c = '123';
        insert disbursalTransaction;
        
        DM_Disbursal_Transaction_Distribution__c ddt = DM_TestHelper.createDDTD();
        ddt.DM_Loan_Disbursal_Transaction__c = disbursalTransaction.Id;
        ddt.dm_Distribution_Type__c = null;
        ddt.dm_Distribution_Amount__c =null;
        ddt.dm_Name_of_Entity__c =null;
        ddt.dm_ACH_Filename__c = null;
        ddt.dm_External_Id__c=null;
        
        insert ddt;

        DM_Multi_Step_Loan_Setup__c rss = DM_TestHelper.createRSS(dmLoan);
        rss.DM_Next_Rate_Change_Date__c =null;
        rss.dm_Loan_Account__c = null;
        rss.dm_Interest_Rate__c = null;
        rss.dm_Sequence__c = null;
        rss.dm_External_Id__c = null;
        rss.dm_Start_Date__c = null;
        insert rss;
                                                        
        DM_Bill__c bill =  DM_TestHelper.createUnpaidDue(dmLoan, 6500.00);
        bill.DM_CL_Contract__c = dmLoan.Id;
        bill.DM_External_Id__c = null;
        bill.DM_Due_Date__c = null;
        bill.DM_Due_Amt__c = 0;
        bill.dm_Transaction_Date__c = null;
        bill.dm_Payment_Amt__c = null;//100000;
        bill.dm_Interest_Billed__c = null;//true;                     
                    bill.dm_Principal_Billed__c = null;//true;                        
                    bill.dm_Interest_Paid__c = null;//10;
                    bill.dm_Principal_Paid__c = null;//100000;
        bill.dm_Payment_Date__c = null;//Date.newInstance(2020, 01, 19); 
        bill.DM_Due_Type_Description__c = null;
        bill.DM_Interest_Billed__c = null;
        bill.dm_Principal_Billed__c =null;
        bill.DM_Payment_Satisfied__c = true;
        
        insert bill;
                
        DM_Repayment_Schedule_Summary__c dm_RSS = DM_TestHelper.CreateRSSData(dmLoan, 600.00);
        dm_RSS.DM_RSS_Repayment_Dt__c = null;
        dm_RSS.DM_RSS_Seq__c = null;
        dm_RSS.DM_CL_Contract__c = dmLoan.Id;
        dm_RSS.DM_External_Id__c = null;
        dm_RSS.DM_RSS_Repayment_Amt__c = null;
        dm_RSS.dm_RSS_No_Of_Pmts__c = -1;
        
        
        insert dm_RSS;
        
        dm_Multi_Step_Loan_Setup__c msl = new dm_Multi_Step_Loan_Setup__c(DM_Loan_Account__c = dmLoan.Id,
                                                                         DM_Start_Date__c = null,
                                                                         DM_Interest_Rate__c = null,
                                                                         DM_Sequence__c = null);
        insert msl;
        
        DM_Charge__c charge =  DM_TestHelper.createUnpaidCharge(dmLoan, dummyFee, 100.00 );
        insert charge;
        
        DM_Repayment_Schedule__c AmzSchedule = DM_TestHelper.CreateAmzScheduleData(dmLoan, 1000.00);
        insert AmzSchedule;
        AmzSchedule.dm_Due_Principal__c = null;
        AmzSchedule.dm_Due_Interest__c = null;
        AmzSchedule.dm_Balance__c = null;
        update AmzSchedule;
       
        DM_Automated_Payment_Setup__c aps =  DM_TestHelper.createAutomatedPaymentSetup('DO it later', '', bankAccount,
                                                         dmLoan, '', pMode, Date.Today(),1);
        aps.dm_Transaction_Amount__c = null;
        aps.dm_Debit_Day__c = null;
        aps.dm_Bank_Account__c = null;
        aps.dm_Debit_Date__c = null;
        aps.dm_External_Id__c = null;
        aps.dm_Type__c = null;
        aps.dm_Amount_Type__c = null;
        aps.dm_Payment_Mode__c= null;
        aps.dm_Frequency__c = null;
        aps.dm_Recurring_ACH_Start_Date__c = null;
        insert aps;
        
        DM_Loan_Payment_Transaction__c lpt = DM_TestHelper.createLoanPayment(dmLoan.Id, 10000.00,Date.today(),aPS, pMode, null);
        lpt.dm_Payment_Mode__c = null;
        lpt.dm_Principal__c = null;
        lpt.dm_Interest__c = null;
        lpt.dm_transaction_time__c = null;
        lpt.dm_transaction_Creation_Date__c = null;
        lpt.DM_LAPro_Posted_Date__c = null;
        lpt.dm_Clearing_Date__c = null;
        lpt.dm_External_Id__c = null;
        insert lpt;
        
        DM_Repayment_Plan__c rep = new DM_Repayment_Plan__c(DM_CL_Contract__c = dmLoan.Id,
                                                           DM_Due_Day__c = 5,
                                                           DM_Effective_Date__c = Date.today().addDays(1),
                                                           DM_Number_of_Payments__c = 2,
                                                           DM_Payment_Start_Date__c = Date.today().addDays(2),
                                                           DM_Frequency__c = 'Monthly');
        insert rep;
        
             
        DM_Interest_Posting_Transaction__c IPT = DM_TestHelper.create_DMInterestPostingTransaction(dmLoan.Id,system.Today(),12758.00,1598.00,8900.90,890.00,false,system.Today(),234500.00,system.Today().addDays(-5),
                                        'Regular',true,false,system.today().addDays(-10),system.today().addDays(30));
        ipt.dm_Amortization_Schedule__c = null;
        ipt.dm_Balance__c = null;
        ipt.dm_Capitalization_Date__c = null;
        ipt.dm_Current_Interest_Accrued__c = null;
        ipt.dm_Due_Amount__c = null;
        ipt.dm_External_Id__c= null;
        ipt.dm_Interest_Paid__c = null;
        ipt.dm_Interest_Posted__c = null;
        ipt.dm_Accrued_To_Investor__c = true;
        ipt.dm_Interest_Posting_Transaction_Snapshot__c = null;
        ipt.dm_Interest_Rate__c = null;
        ipt.dm_Interest_Posting_Type__c = null;
        ipt.dm_Interest_Remaining__c = null;
        ipt.dm_Interest_UnPaid__c = null;
        ipt.dm_Last_Accrual_Date__c = null;
        ipt.dm_Level__c = null;
        ipt.dm_Payment_Amount__c = null;
        ipt.dm_Payment_Date__c = null;
        ipt.dm_Principal_Paid__c = null;
        ipt.dm_Principal_Posted__c = null;
        ipt.dm_Principal_Remaining__c = null;
        ipt.dm_Status__c = null;
        ipt.dm_Transaction_Creation_Date__c = null;
        ipt.dm_Transaction_Due_Date__c = null;
        ipt.dm_Transaction_Posting_Date__c = null;
        ipt.dm_Transaction_Time__c = null;
        insert IPT;
        
        clcommon__Accounting_Entry__c accountingEntry = new clcommon__Accounting_Entry__c(clcommon__Transaction_Creation_Date__c=System.Today(),clcommon__Transaction_Date__c=System.Today());
        insert accountingEntry;
        
        DM_Accrual_Entry__c dmAccr = DM_TestHelper.create_DMAccruals(dmLoan.Id,accountingEntry.Id,System.Today(),10500.00,true,true,true,false,false);
        insert dmAccr;
        
        DM_Investment_Order__c dmInvOrder = DM_TestHelper.createInvestmentOrder(a2,dmLoan,70000);
        dmInvOrder.DM_Accrued_Interest__c =  null;
                     
                    dmInvOrder.dm_Amortization_Schedule_Generation_time__c =  null;
                     
                    dmInvOrder.dm_Approval_Date__c =  null;
                     
                    dmInvOrder.dm_Buying_Price__c =  null;
                     
                    dmInvOrder.dm_Charged_Off_Date__c =  null;
                     
                    dmInvOrder.dm_Charged_Off_Fees__c =  null;
                     
                    dmInvOrder.dm_Charged_Off_Interest__c =  null;
                     
                    dmInvOrder.dm_Charged_Off_Principal__c =  null;
                     
                    dmInvOrder.dm_Collect_Service_Fees_On__c =  null;
                     
                    dmInvOrder.DM_Created_Loan_Delinquent_Days__c =  null;
                                          
                    dmInvOrder.DM_Created_Loan_Status__c =  null;
                     
                    dmInvOrder.dm_Discount_Percent__c =  null;
                     
                    dmInvOrder.DM_End_Date__c =  null;
                     
                    dmInvOrder.DM_Fees_Amount_Paid__c =  null;
                     
                    dmInvOrder.dm_Interest_Amount_Paid__c =  null;
                     
                    dmInvOrder.dm_Interest_Exempted_From_Service_Fee__c =  null;
                     
                    dmInvOrder.DM_Interest_Posted__c =  null;
                     
                    dmInvOrder.dm_Interest_Rate_On_Due_Interest__c =  null;
                    
                    dmInvOrder.dm_Interest_Rate_On_Due_IOA__c =  null;
                     
                    dmInvOrder.dm_Interest_Rate_On_Due_Principal__c =  null;
                     
                    dmInvOrder.DM_Interest_Rate_On_Loan__c =  null;
                     
                    dmInvOrder.dm_Interest_Rounding_Error__c =  null;
                                        
                    dmInvOrder.dm_IOA_Amount_Paid__c =  null;
                    
                    dmInvOrder.DM_IOA_Posted__c =  null;
                  
                    dmInvOrder.DM_Last_Interest_Accrual_Date__c =  null;
                                          
                    dmInvOrder.dm_Minimum_Service_Fee__c =  null;
                     
                    dmInvOrder.dm_Principal_Amount_Paid__c =  null;
                     
                    dmInvOrder.dm_Rebate_Amount_Paid__c =  null;
                     
                    dmInvOrder.dm_Share__c =  null;
                                                              
                    dmInvOrder.dm_Summary__c =  true;
                     
                    dmInvOrder.dm_Summary_Record_Id__c =  null;
                     
                    dmInvOrder.dm_Total_Amount_Paid__c =  null;

                    dmInvOrder.dm_Write_Off_Amount__c =  null;
                    dmInvOrder.DM_Interest_Service_Rate__c = null;
                    dmInvOrder.dm_Investment_Amount__c = null;
                    dmInvOrder.DM_Start_Date__c = null;
                    dmInvOrder.dm_Status__c = 'Sold';
                    dmInvOrder.dm_External_Id__c = null;
                    dmInvOrder.DM_Buyer__c = null;

        insert dmInvOrder;
        
        DM_Investor_Loan_Transaction__c dmILT = DM_TestHelper.createDMInvestorPaymentTxn(dmInvOrder,11000.00,1100,300,lpt.Id);
        insert dmILT;
        
        dm_Due_Payment__c duePayment = new dm_Due_Payment__c();
        duePayment.DM_Payment_Amount__c = 1000;
        duePayment.DM_Loan_Payment_Transaction__c = lpt.Id;
        duePayment.dm_Fees__c = null;
        duePayment.dm_Principal__c = null;                  
        duePayment.dm_External_Id__c = null;                       
        duePayment.dm_Interest__c = null;                        
        duePayment.dm_Loan_Payment_Transaction__c = lpt.Id;                        
        duePayment.dm_Due__c = null;
        duePayment.dm_Payment_Amount__c = null;
        insert duePayment;
        
        List<DM_StagingObject_Query_Generator__c> insertsec = new List<DM_StagingObject_Query_Generator__c>();
        
        DM_StagingObject_Query_Generator__c sec = DM_TestHelper.stagingObjGen(true,true,false,'DM_Investor_Loan_Transaction__c','',
                                                                               'id','DM_Investment_Order__c');
        insertsec.add(sec);
        
        sec = DM_TestHelper.stagingObjGen(true,true,false,'DM_Repayment_Transaction_Reversal__c','',
                                                                              'id,DM_Adjustment_Txn_Date__c,DM_Archive__c,DM_Balance__c,DM_Cleared__c,DM_Custom_Funding_Logic__c,DM_Interest_Rate__c,DM_Loan_Snapshot__c,DM_Reason_Code__c,DM_Reference__c,DM_Transaction_Time__c,DM_External_Id__c,DM_Loan_Payment_Transaction__c',
                                                                              'DM_Loan_Payment_Transaction__c');
        insertsec.add(sec);
        
        sec = DM_TestHelper.stagingObjGen(true,false,true,'DM_Investment_Order__c','DM_Loan__c',
                                          'id,DM_Account__c,DM_Accrued_Interest__c,DM_Buyer__c,DM_Amortization_Schedule_Generation_time__c,DM_Approval_Date__c,DM_Archive__c,DM_Buying_Price__c,DM_Certificate_Rate__c,DM_Charged_Off_Date__c,DM_Charged_Off_Fees__c,DM_Charged_Off_Interest__c,DM_Charged_Off_Principal__c,DM_Collect_Service_Fees_On__c,DM_Created_Loan_Delinquent_Days__c,DM_Created_Loan_Principal_Remaining__c,DM_Created_Loan_Status__c,DM_Discount_Percent__c,DM_Enabled__c,DM_End_Date__c,DM_Fees_Amount_Paid__c,DM_Generate_Amortization_Schedule__c,DM_Interest_Amount_Paid__c,DM_Interest_Exempted_From_Service_Fee__c,DM_Interest_Posted__c,DM_Interest_Rate_On_Due_Interest__c,DM_Interest_Rate_On_Due_IOA__c,DM_Interest_Rate_On_Due_Principal__c,DM_Interest_Rate_On_Loan__c,DM_Interest_Rounding_Error__c,DM_Investment_Amount__c,DM_IOA_Accrued__c,DM_IOA_Amount_Paid__c,DM_IOA_Posted__c,DM_Last_Interest_Accrual_Date__c,DM_Master_Archive_Object__c,DM_Minimum_Service_Fee__c,DM_Principal_Amount_Paid__c,DM_Rebate_Amount_Paid__c,DM_Reinvest_Interest__c,DM_Reinvest_Principal__c,DM_Service_Charge_On_Full_Payment_Amount__c,DM_Share__c,DM_Start_Date__c,DM_Status__c,DM_Summary__c,DM_Summary_Record_Id__c,DM_Total_Amount_Paid__c,DM_Write_Off_Amount__c,DM_Investor_Amortization_Schedule_Genera__c,DM_External_Id__c,DM_Loan__c,DM_Interest_Service_Rate__c',
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
                                          'id','');
        insertsec.add(sec);
        
        sec = DM_TestHelper.stagingObjGen(true,false,true,'dm_Loan_Payment_Transaction__c','CL_Contract__c',
                                          'id,DM_Payment_Mode__c,DM_Transaction_Amount__c,DM_Receipt_Date__c,DM_Cleared__c,DM_Rejected__c,DM_Reversed__c,DM_Principal__c,DM_Interest__c,DM_Fees__c,DM_Is_Migrated__c,DM_Migrated_Reversal_Date__c,DM_Transaction_Date__c,DM_Transaction_time__c,DM_Transaction_Creation_Date__c,DM_LAPro_Posted_Date__c,DM_External_Id__c,DM_clearing_date__c,CL_Contract__c,DM_Write_Off_Recovery_Payment__c',
                                          '');
        insertsec.add(sec);
        
        sec = DM_TestHelper.stagingObjGen(true,false,true,'dm_Loan_Disbursal_Transaction__c','DM_CL_Contract__c',
                                          'id,DM_ACH_Filename__c,DM_Archived__c,DM_Bank_Account__c,DM_Check__c,DM_Cleared__c,DM_Contribution_From_Excess__c,DM_Custom_Logic__c,DM_Disbursal_Date__c,DM_Disbursal_Time__c,DM_Disbursed_Amt__c,DM_External_Id__c,DM_Loan_Disbursal_Transaction_Type__c,DM_Financed_Amount__c,DM_Interest_Rate__c,DM_Internal_Accounting_Generated__c,DM_Loan_Snapshot__c,DM_Master_Archive_Object__c,DM_Mode_Of_Payment__c,DM_Number_Of_Interest_Only_Payments__c,DM_Reference__c,DM_Rejected__c,DM_Reversed__c,DM_Sent_To_ACH__c,DM_Sent_To_ACH_On__c,DM_Summary__c,DM_Summary_Record_Id__c,DM_Pre_Paid_Fee__c,DM_Refinanced_Amount__c,DM_CL_Contract__c',
                                          '');
        insertsec.add(sec);
        
        sec = DM_TestHelper.stagingObjGen(true,false,true,'dm_Interest_Posting_Transaction__c','DM_CL_Contract__c',
                                          'id',
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
                                          'id,DM_Account__c,DM_Overdue_Principal__c,DM_Overdue_Interest__c,DM_Contract_Type__c,DM_Product__c,DM_Loan_Status__c,DM_Application_Date__c,DM_Disbursal_Date__c,DM_Expected_Disbursal_Date__c,DM_Loan_Account_External_Id__c,DM_Loan_Amount__c,DM_Expected_Repayment_Start_Date__c,DM_Number_of_Installments__c,DM_Frequency_of_Loan_Payment__c,DM_Next_Installment_Date__c,DM_Contractual_Interest_Rate__c,DM_Fees_Remaining__c,DM_Principal_Remaining__c,DM_Principal_Paid__c,DM_Last_Installment_Date__c,DM_Payment_Amount__c,DM_Disbursal_Amount__c,DM_Disbursed_Amount__c,DM_Interest_Only_Period__c,DM_Interest_Type__c,DM_Payment_Application_Mode__c,DM_Time_Counting_Method__c,DM_Interest_Calculation_Method__c,DM_Next_Due_Generation_Date__c,DM_Term_Cur__c,DM_AMZ_isBilled_check__c,DM_AMZ_isPaid_check__c,DM_Consolidated_Errors__c,DM_Due_Day__c,DM_Maturity_Date_Current__c,DM_Contractual_Due_Day__c,DM_First_Installment_Date__c,DM_Second_Installment_Date__c,DM_Accrual_Start_Date__c,DM_Rate_Change_Dt_Last__c,DM_Oldest_Due_Date__c,DM_Pmt_Amt_Cur__c,DM_Disbursal_Status__c,DM_Fee_Set__c,DM_Interest_Rate__c,DM_Application__c,lead_Guid__c,DM_thread_number__c,DM_U_LoanModExtDt__c,DM_U_LoanModForbearance__c,DM_U_LoanModForbearDt__c,DM_U_LoanModRate__c,DM_U_LoanModRateEffDt__c,DM_U_LoanModRateLengt__c,DM_U_LoanModTermExt__c,DM_Fees_Paid__c,DM_Interest_Paid__c,DM_Interest_Accrued_Not_Due__c,DM_Balloon_Payment__c,DM_Reschedule_Option_On_Excess_Payment__c,DM_Pre_Bill_Days__c,Product_Type__c,DM_Data_Error__c,DM_Product_Type__c,DM_Funding_in_Tranches__c,DM_Principal_Adjustment__c,DM_Principal_Adjustment_Subtract__c,DM_Rate_Change_Dt_Next__c,DM_Last_Accrual_Date__c,DM_LA_Amortization_Enabled__c,dm_la_amortization_frequency__c,dm_LA_Amortized_Balance_Type__c',
        								   '');
        insertsec.add(sec);
        
        sec = DM_TestHelper.stagingObjGen(true,false,true,'DM_Charge__c','DM_CL_Contract__c',
                                          'id','');
        insertsec.add(sec);
		
		insert insertsec;
        
    }
    @isTest
    public static void testValidationJobStagingObjectsNullCheck(){
        System.debug('Testing DM_Validation_JOB_stagingObjects..');
        User u = [Select Id from User limit 1];
        system.runAs(u){
            Test.startTest();
            DM_Validation_JOB_stagingObjects dm = new DM_Validation_JOB_stagingObjects();
            Database.executeBatch(dm,1);
            Test.stopTest();
            List<DM_Error_On_Staging__c> error = [select Id, DM_obj_and_Field_Name__c, DM_object_name__c from DM_Error_On_Staging__c]; 
            //there is a check in DM_Validation_stagingObjects_Handler class to see if the it a testRun.. is true, then DM_Error_On_Staging__c object is not loaded with any errors 
            System.assert(error.isEmpty());
         }
    }
    
    @isTest
    public static void testValidationStagingJobsObjectsWithThread(){
        System.debug('Testing DM_Validation_JOB_stagingObjects..');
        User u = [Select Id from User limit 1];
        system.runAs(u){
            Test.startTest();
            Integer thread = 0;
            DM_Validation_JOB_stagingObjects dm = new DM_Validation_JOB_stagingObjects();
            Database.executeBatch(dm,1);
            Test.stopTest();
         }
    }
    
}