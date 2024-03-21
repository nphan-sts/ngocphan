/**
 * Test Class for post migration validation
 *
 * 
 * @author - Pallavi
 * **/
@isTest
public class Test_Post_actualObj_ValidationJob {

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
        Account a2 = MW_GlobalTestUtility.GetAccount('Investor');
        a2.peer__First_Name__c = 'Bull';
        a2.peer__Last_Name__c = 'Frank';
        a2.loan__Undeployed_Funds__c = 999999;
        a2.loan__Investor__c = true;
        insert a2;
        loan.CustomSettingsUtil.getNS();
        //Create Borrower
        //Account b1 = loan.TestHelper2.createBorrower('ShoeString');
        Account b1 = MW_GlobalTestUtility.GetAccount('Member');
        b1.peer__First_Name__c = 'ShoeString';
        b1.peer__Last_Name__c = 'Budget';
        insert b1;

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

        DM_PrimaryObject_Query_Generator__c prim = Post_actualObj_TestHelper.primaryObjGen(true,true,false,'loan__Due_Payment__c','',
                                                                                           'id,loan__Fees__c,loan__Payment_Amount__c,loan__Principal__c,External_Id__c,loan__Interest__c,loan__Loan_Payment_Transaction__c,loan__Due__c',
                                                                                          'loan__Loan_Payment_Transaction__c');
        insert prim;

        prim = Post_actualObj_TestHelper.primaryObjGen(true,false,true,'loan__Loan_Disbursal_Transaction__c','loan__Loan_Account__c',
                                                       'id,loan__Disbursed_Amt__c,External_Id__c,loan__Loan_Disbursal_Transaction_Type__c,loan__Financed_Amount__c,loan__Mode_of_Payment__c,loan__Refinanced_Amount__c',
                                                      '');
        insert prim;

        prim = Post_actualObj_TestHelper.primaryObjGen(true,false,true,'loan__Investor_Loan__c','loan__Loan__c',
                                                       'id,loan__Inv_Accrued_Interest_Amt__c,loan__Buying_Price__c,loan__Charged_Off_Date__c,loan__Charged_Off_Fees__c,loan__Charged_Off_Interest__c,loan__Charged_Off_Principal__c,loan__Discount_Percent__c,loan__Late_Fees_Amount_Paid__c,loan__Interest_Amount_Paid__c,loan__Inv_Interest_Posted_Amt__c,loan__Interest_Rate_On_Loan_Account__c,loan__Inv_Last_Interest_Accrual_Post_Date__c,loan__Minimum_Service_Fee__c,loan__Principal_Amount_Paid__c,loan__Rebate_Amount_Paid__c,loan__Share__c,loan__Investor_Start_Date__c,loan__Status__c,loan__Total_Amount_Paid__c,loan__Write_Off_Amount__c,External_Id__c,loan__Account__c',
                                                      '');
        insert prim;

        prim = Post_actualObj_TestHelper.primaryObjGen(true,false,true,'loan__Multi_Step_Loan_Setup__c','loan__Loan_Account__c',
                                                       'id,loan__Interest_Rate__c,loan__Rate_Change_Date_Next__c,External_Id__c',
                                                      '');
        insert prim;

        prim = Post_actualObj_TestHelper.primaryObjGen(true,false,false,'loan__loan_account__c','',
                                                       'id,lead_Guid__c,Last_RSS_date__c,loan__Product_Type__c,loan__Loan_Amount__c,loan__Account__c,loan__Contact__c,loan__Pmt_Amt_Cur__c,loan__Payment_Amount__c,loan__Funding_in_Tranches__c,loan__Principal_Remaining__c,Post_Migration_Error__c,Post_Migration_Validation_Status__c,loan__Draw_Period_End_Date__c,loan__Expected_Disbursal_Date__c,loan__Expected_Repayment_Start_Date__c,loan__Disbursal_Date__c,loan__First_Installment_Date__c,loan__Number_of_Installments__c,loan__Term_Cur__c,loan__Maturity_Date_Current__c,loan__Last_Installment_Date__c,loan__Due_Day__c,loan__Next_Installment_Date__c,loan__Next_Due_Generation_Date__c,loan__Rate_Change_Dt_Next__c,loan__Loan_Status__c,loan__Pre_Bill_Days__c,loan__Last_Accrual_Date__c,loan__LA_Amortization_Enabled__c,loan__la_amortization_frequency__c,loan__LA_Amortized_Balance_Type__c,loan__Fees_Remaining__c,DM_Post_Migration_Validation_Status__c,loan__Principal_Paid__c,loan__Principal_Adjustment__c,loan__Principal_Adjustment_Subtract__c,loan__Interest_Paid__c,loan__Interest_Remaining__c,loan__invalid_data__c,loan__Is_Rescheduled__c,DM_Future_LAD__c,loan__Metro2_Account_Status_Code__c',
                                                      '');
        insert prim;

        prim = Post_actualObj_TestHelper.primaryObjGen(true,false,true,'loan__Repayment_Schedule_Summary__c','loan__RSS_Loan_Account__c',
                                                       'id,loan__RSS_Seq__c,loan__RSS_Repayment_Dt__c,loan__RSS_Repayment_Amt__c,loan__RSS_No_Of_Pmts__c',
                                                      '');
        insert prim;

        prim = Post_actualObj_TestHelper.primaryObjGen(true,false,true,'loan__Repayment_Schedule__c','loan__Loan_Account__c',
                                                       'id,loan__Due_Principal__c,loan__Due_Interest__c,loan__Balance__c,loan__Due_Date__c,loan__Is_Billed__c,loan__isPaid__c,loan__Is_Posted__c,name',
                                                      '');
        insert prim;

        prim = Post_actualObj_TestHelper.primaryObjGen(true,false,true,'loan__Loan_account_Due_Details__c','loan__Loan_Account__c',
                                                       'id,External_Id__c,loan__Transaction_Date__c,loan__Due_Date__c,loan__Payment_Satisfied__c,loan__Payment_Date__c,loan__Due_Type_Description__c,loan__Interest_Billed__c,loan__Principal_Billed__c,loan__Interest_Paid__c,loan__Principal_Paid__c,loan__Due_Amt__c',
                                                      '');
        insert prim;

        prim = Post_actualObj_TestHelper.primaryObjGen(true,false,true,'loan__Loan_Payment_Transaction__c','loan__Loan_Account__c',
                                                       'id,loan__Payment_Mode__c,loan__Principal__c,loan__Interest__c,loan__transaction_time__c,LAPro_Posted_Date__c,External_Id__c,loan__Clearing_Date__c,loan__Reversed__c',
                                                      '');
        insert prim;

        prim = Post_actualObj_TestHelper.primaryObjGen(true,true,false,'loan__Disbursal_Txn_Distribution__c','',
                                                       'id,loan__Loan_Disbursal_Transaction__c,loan__Distribution_Type__c,loan__Distribution_Amount__c,loan__Name_of_Entity__c,External_Id__c',
                                                      'loan__Loan_Disbursal_Transaction__c');
        insert prim;

        prim = Post_actualObj_TestHelper.primaryObjGen(true,false,true,'loan__Interest_Posting_Transaction__c','loan__Loan_Contract__c',
                                                       'id,loan__Status__c,loan__Principal_Paid__c,loan__Interest_Paid__c,loan__Transaction_Due_Date__c,loan__Interest_Remaining__c,loan__Interest_Posted__c',
                                                      '');
        insert prim;

        prim = Post_actualObj_TestHelper.primaryObjGen(true,false,true,'DM_Primary_Objects_Validation__c','CL_Contract__c',
                                                       'id,DM_Validation_Status__c,DM_Validation_Error__c',
                                                      '');
        insert prim;

        prim = Post_actualObj_TestHelper.primaryObjGen(true,false,true,'clcommon__Repayment_Plan__c','loan__Loan_Account__c',
                                                       'id,clcommon__Number_Of_Payments__c,clcommon__Sequence_Number__c',
                                                       '');
        insert prim;

        prim = Post_actualObj_TestHelper.primaryObjGen(true,false,true,'loan__Automated_Payment_Setup__c','loan__CL_Contract__c',
                                                       'id,loan__Bank_Account__c,loan__Transaction_Amount__c,loan__Debit_Date__c,External_Id__c,loan__Amount_Type__c,loan__Frequency__c,loan__Debit_Day__c,loan__Recurring_ACH_Start_Date__c',
                                                       '');
        insert prim;

        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        List<loan__Loan_Product__c> loanProductList = new List<loan__Loan_Product__c>();
        loan__Loan_Product__c simpleLP = Post_actualObj_TestHelper.createLoanProduct('Auto Payer',dummyOffice,
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
        insert pMode;

        loan__Bank_Account__c bankAccount = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
                                                                      loan__Active__c = true,
                                                                      loan__Bank_Name__c = 'Some Bank',
                                                                      loan__Routing_Number__c = '999999999',
                                                                      loan__Account_Type__c = 'Savings',
                                                                      loan__Account_Usage__c = 'Borrower/Investor Account',
                                                                      loan__Account__c = b1.id,
                                                                      Unmasked_Bank_Account_Number__c = '12345');   //pallavi
        insert bankAccount;


        List<loan__Loan_Account__c> dmLoanList = new List<loan__Loan_Account__c>();
        loan__Loan_Account__c dmloan = Post_actualObj_TestHelper.createDMLOC(simpleLP,0.0,b1,dummyFeeSet,dummyOffice,pMode,5);
        dmloan.loan__Principal_Paid__c = 600;
        dmloan.loan__Principal_Remaining__c = 500;
        dmloan.loan__Loan_Amount__c = 1000;
        dmLoanList.add(dmloan);


       /* DM_Loan_Account__c dmloan2 = DM_TestHelper.createDMLOC(difficultLP,0.0,b1,dummyFeeSet,dummyOffice,5,'Declining Balance');
        dmLoanList.add(dmloan2);

        DM_Loan_Account__c dmloan3 = DM_TestHelper.createDMLOC(errorLp,0.0,b1,dummyFeeSet,dummyOffice,5,'Error');
        dmLoanList.add(dmloan3);
        System.debug('dmLoanList----' + dmLoanList);*/  //remove
        insert dmLoanList;

        DM_Primary_Objects_Validation__c ab = new DM_Primary_Objects_Validation__c(CL_Contract__c = dmloan.id,
                                                                                  DM_Validation_Status__c = 'Pending');
        insert ab;

        dmloan.DM_Primary_Objects_Validation__c = ab.id;
        update dmloan;
        loan__Loan_Disbursal_Transaction__c ldt =  Post_actualObj_TestHelper.fundLoan(dmLoan, Date.Today(), pmode,bankAccount);
        insert ldt;

        /*loan__Loan_Disbursal_Transaction__c ldt1 =  Post_actualObj_TestHelper.fundLoan1(dmLoan2, Date.Today(), pmode,bankAccount);
        insert ldt1;*/

        loan__Disbursal_Txn_Distribution__c dtd = Post_actualObj_TestHelper.createDTD(ldt);
        insert dtd;

        loan__Loan_account_Due_Details__c bill =  Post_actualObj_TestHelper.createUnpaidDue(dmLoan, 6500.00);
        insert bill;

        /*loan__Bill__c bill1 =  Post_actualObj_TestHelper.createUnpaidDue1(dmLoan2, 6500.00);
        insert bill1;*/

        loan__Repayment_Schedule_Summary__c dm_RSS = Post_actualObj_TestHelper.CreateRSSData(dmLoan, 600.00);
        insert dm_RSS;

        loan__Charge__c charge =  Post_actualObj_TestHelper.createUnpaidCharge(dmLoan, dummyFee, 100.00 );
        insert charge;

        loan__Repayment_Schedule__c AmzSchedule = Post_actualObj_TestHelper.CreateAmzScheduleData(dmLoan, 1000.00);
        insert AmzSchedule;

        /*loan__Repayment_Schedule__c AmzSchedule1 = Post_actualObj_TestHelper.CreateAmzScheduleData1(dmLoan2, 1000.00);
        insert AmzSchedule1;*/

        loan__Automated_Payment_Setup__c aps =  Post_actualObj_TestHelper.createAutomatedPaymentSetup('DO it later', '', bankAccount,
                                                         dmLoan, '', pMode, Date.Today(),1);
        insert aps;
        System.debug('aps----' + aps);

        loan__Loan_Payment_Transaction__c lpt = Post_actualObj_TestHelper.createLoanPayment(dmLoan.Id, 10000.00,Date.today(),aPS, pMode, null);
        insert lpt;

        loan__Due_Payment__c due = Post_actualObj_TestHelper.createDP(lpt);
        insert due;

        /*loan__Loan_Payment_Transaction__c lpt1 = Post_actualObj_TestHelper.createLoanPayment1(dmLoan2.Id, 10000.00,Date.today(),aPS, pMode, null);
        insert lpt1;*/

        loan__Interest_Posting_Transaction__c IPT = Post_actualObj_TestHelper.create_InterestPostingTransaction(dmLoan.Id,system.Today(),12758.00,1598.00,8900.90,890.00,false,system.Today(),234500.00,system.Today().addDays(-5),
                                        'Regular',true,false,system.today().addDays(-10),system.today().addDays(30));
        insert IPT;

        clcommon__Accounting_Entry__c accountingEntry = new clcommon__Accounting_Entry__c(clcommon__Transaction_Creation_Date__c=System.Today(),clcommon__Transaction_Date__c=System.Today());
        insert accountingEntry;

        loan__Accrual_Entry__c dmAccr = Post_actualObj_TestHelper.create_DMAccruals(dmLoan.Id,accountingEntry.Id,System.Today(),10500.00,true,true,true,false,false);
        insert dmAccr;

        loan__Investor_Loan__c dmInvOrder = Post_actualObj_TestHelper.createInvestmentOrder(a2,dmLoan,70000);
        insert dmInvOrder;

        loan__Investor_Loan_Account_Txns__c dmILT = Post_actualObj_TestHelper.createDMInvestorPaymentTxn(dmInvOrder,11000.00,1100,300,lpt.Id);
        insert dmILT;

        loan__Multi_Step_Loan_Setup__c dmRate = Post_actualObj_TestHelper.createMSLS(dmLoan);
        insert dmRate;

    }//END testData
    @isTest
    static void testMehod_1(){
        //List<DM_Loan_Account__c> dmList = [select id from DM_Loan_Account__c];
        User u = [Select Id from User limit 1];
        system.runAs(u){
            Test.startTest();
            Post_actualObj_ValidationJob dm = new Post_actualObj_ValidationJob();
            Database.executeBatch(dm,1);
            Test.stopTest();
        }//END system.runAs(u)
    }//END RunJobTemp_IsTest
}