@isTest
public class DM_SpecificObjects_MigrationJob_Test {

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
        Account a2 = new Account(Name = 'Bull', loan__Undeployed_Funds__c = 999999,loan__Investor__c = true);
        insert a2;

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
                                                    loan__Is_Branch__c=true
                                                                   );
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
        
        loan__Bank_Account__c bankAccount = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12', 
                                                 loan__Bank_Name__c = 'Some Bank', 
                                                 loan__Routing_Number__c = '999999999', 
                                                 loan__Account_Type__c = 'Savings', 
                                                 loan__Account_Usage__c = 'Borrower/Investor Account', 
                                                 loan__Account__c = b1.id,
                                                 Unmasked_Bank_Account_Number__c = '12345');    
        insert bankAccount;
        
        List<Loan__Loan_Account__c> primaryLoanList = new List<Loan__Loan_Account__c>();
        
        Loan__loan_Account__c primaryLoan = new Loan__loan_Account__c(loan__Account__c= b1.Id,
                                            loan__Product_Type__c=simpleLP.Name,
                                            Loan__loan_Amount__c = 100000,
                                            loan__Principal_Remaining__c = 10000,
                                            loan__Loan_Product_Name__c= simpleLP.Id,
                                            //loan__product__c = simpleLP.Id,
                                            //loan__contact__c = b1.Id,
                                            loan__Payment_Amount__c= 100000,
                                            loan__Previous_Installment_Date__c= system.today(),
                                            loan__First_Installment_Date__c = Date.newInstance(2020, 01, 19),
                                            loan__Next_Installment_Date__c = Date.newInstance(2020, 02, 19), 
                                            loan__Maturity_Date_Current__c = Date.newInstance(2022, 01, 19), 
                                            loan__Frequency_of_Loan_Payment__c = 'Monthly', 
                                            loan__Last_Installment_Date__c = Date.newInstance(2020, 01, 19) ,
                                            loan__Draw_Period_End_Date__c = Date.newInstance(2020, 01, 09),
                                            loan__Expected_Disbursal_Date__c = Date.newInstance(2019, 01, 09),
                                            //loan__Expected_Repayment_Start_Date__c = Date.newInstance(20120, 01, 09),
                                            //loan__Rate_Change_Dt_Next__c = Date.newInstance(20120, 01, 09),
                                            loan__Is_Rescheduled__c = false, 
                                            Loan__loan_Status__c = 'Active - Bad Standing',
                                            lead_Guid__c = '',
                                            loan__Oldest_Due_Date__c = Date.newInstance(2020, 01, 19),
                                            loan__Last_Payment_Date__c = Date.newInstance(2020, 01, 19),
                                            loan__Accrual_Start_Date__c = Date.newInstance(2020, 01, 19),
                                            loan__Interest_Rate__c = 10,
                                            loan__Pmt_Amt_Cur__c = 100,
                                            //Migration_status__c = 'Success',
                                            //Migrated_CL_Contract__c = dmloan.Id
                                            loan__Term_Cur__c = 100,
                                            loan__Last_Accrual_Date__c = Date.newInstance(2020, 01, 19),
                                            loan__Disbursal_Date__c = Date.newInstance(2019, 12, 19),
                                            loan__Payment_Application_Mode__c ='Deposit',
                                            loan__Number_of_Installments__c = 10,
                                            loan__Next_Due_Generation_Date__c = Date.newInstance(2020, 01, 19),
                                            loan__Due_Day__c = 1,
                                            loan__LA_Amortization_Enabled__c = true,
                                            loan__la_amortization_frequency__c = 'Monthly',
                                            loan__LA_Amortized_Balance_Type__c = 'abc',
                                            loan__Fees_Remaining__c = 10000  
                                            );
        primaryLoanList.add(primaryLoan);
        
        insert primaryLoanList;
        
        loan__Loan_Payment_Transaction__c primaryLPT = new loan__Loan_Payment_Transaction__c();
        primaryLPT.ToBeDeleted__c = false;
        primaryLPT.loan__Transaction_Date__c = Date.today();
        primaryLPT.loan__Transaction_Amount__c = 10000.00;
        primaryLPT.loan__Loan_Account__c = primaryLoan.Id;
        primaryLPT.External_Id__c = '1234';
        primaryLPT.loan__Receipt_Date__c= Date.today();                                                       
        primaryLPT.loan__Skip_Validation__c = true;
        
        List<DM_Loan_Account__c> loanList = new List<DM_Loan_Account__c>();
        DM_Loan_Account__c dmLoan = new DM_Loan_Account__c(dm_Account__c= b1.Id,
                                            dm_Product_Type__c=simpleLP.Name,
                                            dm_Loan_Amount__c = 100000,
                                            dm_Principal_Remaining__c = 10000,
                                            dm_Product_Name__c= simpleLP.Name,
                                            dm_product__c = simpleLP.Id,
                                            //dm_contact__c = b1.Id,
                                            dm_Payment_Amount__c= 100000,
                                            dm_Previous_Installment_Date__c= system.today(),
                                            dm_First_Installment_Date__c = Date.newInstance(2020, 01, 19),
                                            dm_Next_Installment_Date__c = Date.newInstance(2020, 02, 19), 
                                            dm_Maturity_Date_Current__c = Date.newInstance(2022, 01, 19), 
                                            dm_Frequency_of_Loan_Payment__c = 'Monthly', 
                                            dm_Last_Installment_Date__c = Date.newInstance(2020, 01, 19) ,
                                            dm_Draw_Period_End_Date__c = Date.newInstance(2020, 01, 09),
                                            dm_Expected_Disbursal_Date__c = Date.newInstance(2019, 01, 09),
                                            //dm_Expected_Repayment_Start_Date__c = Date.newInstance(20120, 01, 09),
                                            //dm_Rate_Change_Dt_Next__c = Date.newInstance(20120, 01, 09),
                                            dm_Is_Rescheduled__c = false, 
                                            dm_Loan_Status__c = 'Active - Bad Standing',
                                            lead_Guid__c = '',
                                            dm_Oldest_Due_Date__c = Date.newInstance(2020, 01, 19),
                                            dm_Last_Payment_Date__c = Date.newInstance(2020, 01, 19),
                                            dm_Accrual_Start_Date__c = Date.newInstance(2020, 01, 19),
                                            dm_Interest_Rate__c = 10,
                                            dm_Pmt_Amt_Cur__c = 100,
                                            Migration_status__c = 'Success',
                                            Migrated_cl_contract__c = primaryLoan.Id,
                                            dm_Term_Cur__c = 100,
                                            dm_Last_Accrual_Date__c = Date.newInstance(2020, 01, 19),
                                            dm_Disbursal_Date__c = Date.newInstance(2019, 12, 19),
                                            dm_Payment_Application_Mode__c ='Deposit',
                                            dm_Number_of_Installments__c = 10,
                                            dm_Next_Due_Generation_Date__c = Date.newInstance(2020, 01, 19),
                                            dm_Due_Day__c = 1,
                                            dm_LA_Amortization_Enabled__c = true,
                                            dm_la_amortization_frequency__c = 'Monthly',
                                            dm_LA_Amortized_Balance_Type__c = 'abc',
                                            dm_Fees_Remaining__c = 10000      
                                            );
        loanList.add(dmLoan);
        insert loanList;
        
        DM_Loan_Disbursal_Transaction__c ldt =  DM_TestHelper.fundLoan(dmLoan, Date.Today(), pmode,bankAccount);
        insert ldt;
                
        DM_Disbursal_Transaction_Distribution__c ddt = DM_TestHelper.createDDTD();
        insert ddt;
        
        DM_Multi_Step_Loan_Setup__c rss = DM_TestHelper.createRSS(dmLoan);
        insert rss;
        
                                                        
        DM_Bill__c bill =  DM_TestHelper.createUnpaidDue(dmLoan, 6500.00);
        insert bill;
   
        DM_Repayment_Schedule_Summary__c dm_RSS = DM_TestHelper.CreateRSSData(dmLoan, 600.00);
        insert dm_RSS;
        
        DM_Charge__c charge =  DM_TestHelper.createUnpaidCharge(dmLoan, dummyFee, 100.00 );
        insert charge;
        
        DM_Repayment_Schedule__c AmzSchedule = DM_TestHelper.CreateAmzScheduleData(dmLoan, 1000.00);
        AmzSchedule.Migration_Status__c = 'Success';
        insert AmzSchedule;
        
        DM_Automated_Payment_Setup__c aps =  DM_TestHelper.createAutomatedPaymentSetup('DO it later', '', bankAccount,
                                                         dmLoan, '', pMode, Date.Today(),1);
        insert aps;
        
        DM_Loan_Payment_Transaction__c lpt = DM_TestHelper.createLoanPayment(dmLoan.Id, 10000.00,Date.today(),aPS, pMode, null);
        insert lpt;
        
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
        
        MigrationPhase__c phase = new MigrationPhase__c();
        phase.name = 'phase1';
        phase.phase__c = 'phase1';
        insert phase;
        
        DM_Due_Payment__c dmDuePayment = new DM_Due_Payment__c();
        dmDuePayment.DM_Loan_Payment_Transaction__c = lpt.Id;
        insert dmDuePayment;
    }
    @isTest
    public static void testDMSpecificObjectsMigrationJobBatch(){
        User u = [Select Id from User limit 1];
        system.runAs(u){
        try{
            List<MigrationPhase__c> mPhase = [select id,name from MigrationPhase__c];       
            Test.startTest();
            DM_SpecificObjects_MigrationJob dmspm = new DM_SpecificObjects_MigrationJob(mPhase[0].name);
            Database.executeBatch(dmspm,2);
            }catch(Exception e){
                system.assert(false, 'This is to check exception scenario');
            }
            Test.stopTest();
        }
    }
 }