/* ****************Modification History*****************************************************************
* Modified by      Date            JIRA number
*     Anusha        2021/08/09    LSP-339 fix tests for ForBearanceLoanBatchTest
******************Modification History*****************************************************************/

@isTest
public class ForBearanceLoanBatchTest {
    @testSetup static void setup(){
        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);                                    
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
        org.loan__Disable_Triggers__c = true;
        upsert org;  
        
        loan__trigger_Parameters__c triggerParams = loan.CustomSettingsUtil.getTriggerParameters();
        triggerParams.loan__Disable_PostRpmtAccBalUpd_Trigger__c = true;
        triggerParams.loan__Disable_Rpmt_Schedule_Trigger__c = true;
        upsert triggerParams;
        
        genesis__Org_Parameters__c genorg = genesis__Org_Parameters__c.getOrgDefaults();
        genorg.genesis__Disable_Triggers__c = true;
        upsert genorg;
        
        
        //Creating Account
        Account acc = new Account(
            Name = 'Test',
            peer__Last_Name__c = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123456789'
        );
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
        LoanPaymentDays__c lpdays = new LoanPaymentDays__c();
        lpdays.AutoPaymentRemainder__c= 3;
        lpdays.ManualPaymentRemainder__c= 5;
        insert lpdays;
        
        loan__Loan_Product__c loanProdObj = new loan__Loan_Product__c(name='TestProduct'); 
        insert loanProdObj;
        System.assertEquals('TestProduct', loanProdObj.Name,'Wrong Loan Product');
        
        //Creating Conpany
        genesis__Company__c comp = genesis.TestHelper.createCompany(); 
        comp.Name = 'payoff';
        update comp;
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        
        //creating CL Product
        clcommon__CL_Product__c pr = new clcommon__CL_Product__c();
        pr.loan__Lending_Product__c = dummyLp.id;
        pr.clcommon__Product_Name__c = 'P1';
        insert pr;
        
        Account account_Obj = new Account(
            Name = 'Test',
            peer__Last_Name__c = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com'
        );
        Insert account_Obj;
        
        Contact a1 = new Contact(LastName='TestACH');
        a1.AccountId = acc.Id;
        insert a1;
        
        loan__Bank_Account__c ba = new loan__Bank_Account__c(loan__Bank_Account_Number__c = 'XXXXXXXX1212',
                                                             loan__Bank_Name__c = 'Some Bank',
                                                             loan__Routing_Number__c = '999999999',
                                                             loan__Account_Type__c = 'Checking',
                                                             Unmasked_Bank_Account_Number__c = '123456',
                                                             loan__Account_Usage__c = 'Borrower/Investor Account',
                                                             loan__Contact__c = a1.id,
                                                             loan__Account__c = acc.id,
                                                             loan__Active__c = True);
        insert ba;
        
        loan__Payment_Mode__c pMode = new loan__Payment_Mode__c(Name = 'CASH');
        insert pMode;
        loan__Payment_Mode__c pMode1 = new loan__Payment_Mode__c(Name = 'ACH');
        insert pMode1;
        
        loan__Bank_Account__c bank = [select id from loan__Bank_Account__c where loan__Account_usage__c= 'Borrower/Investor Account' limit 1];
        
        genesis__applications__c application = new genesis__applications__c();
        application.genesis__Product_Type__c = 'LOAN';
        application.genesis__Loan_Amount__c = 6700;
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
        application.genesis__Account__c = account_Obj.Id;
        application.genesis__Total_Estimated_Interest__c=500;
        application.genesis__Valid_Pricing_Flag__c=false;
        application.genesis__Probability__c=100.00;
        application.genesis__Payment_Amount__c=523.80;
        application.genesis__Company__c = comp.id;
        application.genesis__CL_Product__c = pr.id;
        insert application;
        
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        Date systemDate = util.getCurrentSystemDate();
        loan__Loan_Account__c lacc = new loan__Loan_Account__c(
            loan__Account__c= acc.Id,
            loan__Contact__c= a1.ID,
            loan__Product_Type__c='Flexible Amz Loan',
            loan__Loan_Amount__c =5000,
            loan__Loan_Product_Name__c=loanProdObj.Id,
            loan__Payment_Amount__c=439.70, 
            loan__Principal_Remaining__c = 4243.60,
            loan__Previous_Installment_Date__c= system.today(),
            application__c = application.id, 
            loan__First_Installment_Date__c = systemDate.addMonths(1),
            loan__Next_Installment_Date__c = systemDate.addMonths(2), 
            loan__Maturity_Date_Current__c = systemDate.addMonths(12), 
            loan__Frequency_of_Loan_Payment__c = 'Monthly',  
            loan__Last_Installment_Date__c = systemDate.addMonths(12),
            loan__Loan_Status__c = 'Active - Good Standing',
            loan__Interest_Rate__c = 10,
            loan__Term_Cur__c = 12,
            Skipped_a_pay_Date__c = null,
            Skipped_a_Pay__c = false,
            lead_guid__c = 'TestClassGuid0',
            loan__Disbursal_Date__c = systemDate
        );
        insert lacc; 
        
        loan__Automated_Payment_Setup__c aPS = loan.TestHelper2.createAutomatedPaymentSetup(loan.LoanConstants.RECURRING,loan.LoanConstants.FIXED_AMOUNT,bank,lacc,'Monthly',pMode);
        
        loan__Automated_Payment_Configuration__c lap=new loan__Automated_Payment_Configuration__c();
        lap.loan__Trace_Number_Prefix__c='testteasdf';
        lap.loan__Filegen_Class__c='testtest';
        lap.loan__Folder_Name__c='Test';
        lap.loan__Immediate_Destination__c='Test';
        lap.loan__Immediate_Origin__c='Test';
        lap.loan__Immediate_Origin_Name__c='Test';
        lap.loan__Reference_Code__c='test';
        lap.loan__Company_Identification__c='Test';
        lap.loan__Originating_DFI_Identification__c='Test';
        
        Insert lap;
        
        loan__Repayment_Schedule_Summary__c repaymentScheduleSummary = new loan__Repayment_Schedule_Summary__c();
        repaymentScheduleSummary.loan__RSS_No_Of_Pmts__c = 12;
        repaymentScheduleSummary.loan__Archived__c = false;
        repaymentScheduleSummary.loan__RSS_Loan_Account__c = lacc.Id;
        insert repaymentScheduleSummary;
        
        //LSP-3 start (added because test cases were failing because of failure in fetching repaymentplan) - Anusha
        loan__Repayment_Schedule__c loanRepaymentSchedule7 = new loan__Repayment_Schedule__c();
        loanRepaymentSchedule7.loan__Due_Date__c = systemDate.addMonths(1);
        loanRepaymentSchedule7.loan__Loan_Account__c = lacc.Id;
        loanRepaymentSchedule7.loan__Is_Archived__c = false;
        loanRepaymentSchedule7.loan__Balance__c = 2188.70;
        loanRepaymentSchedule7.loan__Due_Amount__c = 2188.70;
        loanRepaymentSchedule7.loan__isPaid__c = false;
        loanRepaymentSchedule7.loan__Is_Billed__c = false;
        insert loanRepaymentSchedule7;
        
        loan__Repayment_Schedule__c loanRepaymentSchedule8 = new loan__Repayment_Schedule__c();
        loanRepaymentSchedule8.loan__Due_Date__c = systemDate.addMonths(2);
        loanRepaymentSchedule8.loan__Loan_Account__c = lacc.Id;
        loanRepaymentSchedule8.loan__Is_Archived__c = false;
        loanRepaymentSchedule8.loan__Balance__c = 2188.70;
        loanRepaymentSchedule8.loan__Due_Amount__c = 2188.70;
        loanRepaymentSchedule8.loan__isPaid__c = false;
        loanRepaymentSchedule8.loan__Is_Billed__c = false;
        insert loanRepaymentSchedule8;
        
        loan__Repayment_Schedule__c loanRepaymentSchedule9 = new loan__Repayment_Schedule__c();
        loanRepaymentSchedule9.loan__Due_Date__c = systemDate.addMonths(3);
        loanRepaymentSchedule9.loan__Loan_Account__c = lacc.Id;
        loanRepaymentSchedule9.loan__Is_Archived__c = false;
        loanRepaymentSchedule9.loan__Balance__c = 2188.70;
        loanRepaymentSchedule9.loan__Due_Amount__c = 2188.70;
        loanRepaymentSchedule9.loan__isPaid__c = false;
        loanRepaymentSchedule9.loan__Is_Billed__c = false;
        insert loanRepaymentSchedule9;
        //LSP-3 end
        
        List<loan__Loan_Payment_Transaction__c> lptList = new List<loan__Loan_Payment_Transaction__c>();
        loan__Loan_Payment_Transaction__c lpt = new loan__Loan_Payment_Transaction__c();
        lpt.loan__Cleared__c = false;
        lpt.loan__Rejected__c = false;
        lpt.loan__Reversed__c = false;
        lpt.loan__Sent_to_ACH__c = true;
        lpt.loan__Loan_Account__c = lacc.Id;
        lpt.loan__Transaction_Date__c = systemDate;
        lpt.loan__Transaction_Amount__c = 439.70;
        lpt.loan__Payment_Mode__c = pMode.Id;
        lpt.loan__Automated_Payment_Setup__c = aPS.id;
        lptList.add(lpt);
        insert lptList;
    }
    
    @isTest
    public static void testForberanceBatchWithNoLPT(){//reschedules the loan when there is no LPT
        List<loan__Loan_Account__c> LAList = [Select id,name,lead_Guid__c,loan__First_Installment_Date__c, 
                                              Application__r.genesis__Monthly_Debt_Payments__c,
                                              loan__Payment_Amount__c,
                                              loan__Loan_Status__c,
                                              loan__Accrual_Start_Date__c,
                                              Application__r.Loan_Origination_Date__c,
                                              loan__Last_Installment_Date__c,
                                              loan__Interest_Rate__c,
                                              loan__Frequency_of_Loan_Payment__c,
                                              loan__Pmt_Amt_Cur__c,
                                              loan__Next_Installment_Date__c,
                                              loan__Previous_Installment_Date__c,
                                              loan__Maturity_Date_Current__c,
                                              loan__Disbursal_Date__c,
                                              loan__Term_Cur__c,
                                              Skipped_a_pay_Date__c,
                                              Skipped_a_Pay__c,
                                              loan__Is_Rescheduled__c,
                                              (Select id,name,
                                               loan__Is_Archived__c,
                                               loan__Due_Date__c,
                                               loan__isPaid__c,
                                               loan__Is_Billed__c
                                               from loan__Repayment_Schedule__r),
                                              (select id,name from loan__Repayment_Plan__r),
                                              CPD_Reason__c,
                                              CPD_Expire_Date__c
                                              from loan__Loan_Account__c where lead_guid__c = 'TestClassGuid0'
                                             ];      
        test.startTest();
        Set<Id> loanIdset = new Set<Id>();
        for(loan__Loan_Account__c lc : LAList){
            loanIdset.add(lc.id);
        }  
        List<loan__Loan_Payment_Transaction__c> lpts = [select id, name from loan__Loan_Payment_Transaction__c where
                                                        loan__Loan_Account__c in :loanIdset];
        delete lpts;
        
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();//LSP-339
        Date systemDate = util.getCurrentSystemDate();//LSP-339
        List<loan__Repayment_Schedule__c> amortScheduleUpdate = new List<loan__Repayment_Schedule__c>();
        List<loan__Repayment_Schedule__c> amortSchedule = [select id, name,
                                                           loan__Due_Date__c,
                                                           loan__is_Archived__c,
                                                           loan__isPaid__c,
                                                           loan__Is_Billed__c
                                                           from loan__Repayment_Schedule__c 
                                                           where loan__Loan_Account__r.Id in :loanIdset
                                                           AND loan__is_Archived__c = false
                                                           AND loan__due_date__c >= :systemDate
                                                           order by loan__Due_Date__c asc];
        for(loan__Repayment_Schedule__c sch:amortSchedule){
            if(sch.loan__isPaid__c == true){
                sch.loan__isPaid__c = false;
                amortScheduleUpdate.add(sch);
            }
        }
        update amortScheduleUpdate;
        
        ForBearanceLoanBatch job = new ForBearanceLoanBatch(loanIdset);
        Database.executeBatch(job,1);      
        test.stopTest();
        loan__loan_account__c loan = [Select id,name,lead_Guid__c,loan__First_Installment_Date__c, 
                                      Application__r.genesis__Monthly_Debt_Payments__c,
                                      loan__Payment_Amount__c,
                                      loan__Loan_Status__c,
                                      loan__Accrual_Start_Date__c,
                                      Application__r.Loan_Origination_Date__c,
                                      loan__Last_Installment_Date__c,
                                      loan__Interest_Rate__c,
                                      loan__Frequency_of_Loan_Payment__c,
                                      loan__Pmt_Amt_Cur__c,
                                      loan__Next_Installment_Date__c,
                                      loan__Previous_Installment_Date__c,
                                      loan__Maturity_Date_Current__c,
                                      loan__Disbursal_Date__c,
                                      loan__Term_Cur__c,
                                      Skipped_a_pay_Date__c,
                                      Skipped_a_Pay__c,
                                      loan__Oldest_Due_Date__c,
                                      loan__Is_Rescheduled__c,
                                      U_LoanModForbearance__c,
                                      Hardship_New_Maturity_Date__c,
                                      U_LoanModForbearDt__c,
                                      Hardship_Request_Date__c,
                                      U_LoanModTermExt__c
                                      from loan__loan_account__c  where lead_guid__C = 'TestClassGuid0'];
        //LSP-339 added asserts
        System.assertEquals(true, loan.Skipped_a_Pay__c);
        System.assertEquals(Date.today(), loan.Skipped_a_pay_Date__c);
        System.assertEquals('Active - Good Standing', loan.loan__Loan_Status__c);
        System.assertEquals(systemDate.addMonths(2),loan.loan__Next_Installment_Date__c);
        System.assertEquals(systemDate.addMonths(2), loan.loan__Oldest_Due_Date__c);
        System.assertEquals(systemDate.addMonths(12+1), loan.loan__Maturity_Date_Current__c);
        System.assert(loan.loan__Is_Rescheduled__c);
        System.assertEquals(1, loan.U_LoanModForbearance__c);
        System.assertEquals(systemDate.addMonths(1), loan.U_LoanModForbearDt__c);
        System.assertEquals(loan.loan__Maturity_Date_Current__c, loan.Hardship_New_Maturity_Date__c);
        System.assertEquals(systemDate, loan.Hardship_Request_Date__c);
        System.assertEquals(1, loan.U_LoanModTermExt__c);
    }
    
    //LSP-339
    @isTest
    public static void testForberanceBatchExtensiontoPreviousSAP(){//extension to previous SAP
        List<loan__Loan_Account__c> LAList = [Select id,name,lead_Guid__c,loan__First_Installment_Date__c, 
                                              Application__r.genesis__Monthly_Debt_Payments__c,
                                              loan__Payment_Amount__c,
                                              loan__Loan_Status__c,
                                              loan__Accrual_Start_Date__c,
                                              Application__r.Loan_Origination_Date__c,
                                              loan__Last_Installment_Date__c,
                                              loan__Interest_Rate__c,
                                              loan__Frequency_of_Loan_Payment__c,
                                              loan__Pmt_Amt_Cur__c,
                                              loan__Next_Installment_Date__c,
                                              loan__Previous_Installment_Date__c,
                                              loan__Maturity_Date_Current__c,
                                              loan__Disbursal_Date__c,
                                              loan__Term_Cur__c,
                                              Skipped_a_pay_Date__c,
                                              Skipped_a_Pay__c,
                                              loan__Is_Rescheduled__c,
                                              loan__Oldest_Due_Date__c,
                                              (Select id,name,
                                               loan__Is_Archived__c,
                                               loan__Due_Date__c,
                                               loan__isPaid__c,
                                               loan__Is_Billed__c
                                               from loan__Repayment_Schedule__r),
                                              (select id,name from loan__Repayment_Plan__r),
                                              CPD_Reason__c,
                                              CPD_Expire_Date__c
                                              from loan__Loan_Account__c where lead_guid__c = 'TestClassGuid0'
                                             ];      
        test.startTest();
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        Date systemDate = util.getCurrentSystemDate();
        List<loan__Loan_Account__c> updateLoan = new List<loan__Loan_Account__c>();
        Set<Id> loanIdset = new Set<Id>();
        for(loan__Loan_Account__c lc : LAList){
            lc.U_LoanModForbearance__c = 1;
            lc.U_LoanModForbearDt__c = systemDate;
            lc.Hardship_New_Maturity_Date__c = systemDate.addMonths(12);
            lc.Hardship_Request_Date__c = systemDate;
            lc.U_LoanModTermExt__c = 1;
            lc.loan__Oldest_Due_Date__c = systemDate.addMonths(1);
            lc.Skipped_a_Pay__c = true;
            lc.Skipped_a_pay_Date__c = systemDate.addDays(-2);
            updateLoan.add(lc);
            loanIdset.add(lc.id);
        } 
        update updateLoan;
        List<loan__Loan_Payment_Transaction__c> lpts = [select id, name from loan__Loan_Payment_Transaction__c where
                                                        loan__Loan_Account__c in :loanIdset];
        delete lpts;
        
        List<loan__Repayment_Schedule__c> amortScheduleUpdate = new List<loan__Repayment_Schedule__c>();
        List<loan__Repayment_Schedule__c> amortSchedule = [select id, name,
                                                           loan__Due_Date__c,
                                                           loan__is_Archived__c,
                                                           loan__isPaid__c,
                                                           loan__Is_Billed__c
                                                           from loan__Repayment_Schedule__c 
                                                           where loan__Loan_Account__r.Id in :loanIdset
                                                           AND loan__is_Archived__c = false
                                                           AND loan__due_date__c >= :systemDate
                                                           order by loan__Due_Date__c asc];
        for(loan__Repayment_Schedule__c sch:amortSchedule){
            if(sch.loan__isPaid__c == true){
                sch.loan__isPaid__c = false;
                amortScheduleUpdate.add(sch);
            }
        }
        update amortScheduleUpdate;
        
        ForBearanceLoanBatch job = new ForBearanceLoanBatch(loanIdset);
        Database.executeBatch(job,1);      
        test.stopTest();
        loan__loan_account__c loan = [Select id,name,lead_Guid__c,loan__First_Installment_Date__c, 
                                      Application__r.genesis__Monthly_Debt_Payments__c,
                                      loan__Payment_Amount__c,
                                      loan__Loan_Status__c,
                                      loan__Accrual_Start_Date__c,
                                      Application__r.Loan_Origination_Date__c,
                                      loan__Last_Installment_Date__c,
                                      loan__Interest_Rate__c,
                                      loan__Frequency_of_Loan_Payment__c,
                                      loan__Pmt_Amt_Cur__c,
                                      loan__Next_Installment_Date__c,
                                      loan__Previous_Installment_Date__c,
                                      loan__Maturity_Date_Current__c,
                                      loan__Disbursal_Date__c,
                                      loan__Term_Cur__c,
                                      Skipped_a_pay_Date__c,
                                      Skipped_a_Pay__c,
                                      loan__Oldest_Due_Date__c,
                                      loan__Is_Rescheduled__c,
                                      U_LoanModForbearance__c,
                                      Hardship_New_Maturity_Date__c,
                                      U_LoanModForbearDt__c,
                                      Hardship_Request_Date__c,
                                      U_LoanModTermExt__c
                                      from loan__loan_account__c  where lead_guid__C = 'TestClassGuid0'];
        //LSP-339 added asserts
        System.assertEquals(true, loan.Skipped_a_Pay__c);
        System.assertEquals(Date.today(), loan.Skipped_a_pay_Date__c);
        System.assertEquals('Active - Good Standing', loan.loan__Loan_Status__c);
        System.assertEquals(systemDate.addMonths(2),loan.loan__Next_Installment_Date__c);
        System.assertEquals(systemDate.addMonths(2), loan.loan__Oldest_Due_Date__c);
        System.assertEquals(systemDate.addMonths(12+1), loan.loan__Maturity_Date_Current__c);
        System.assert(loan.loan__Is_Rescheduled__c);
        System.assertEquals(2, loan.U_LoanModForbearance__c);
        System.assertEquals(systemDate, loan.U_LoanModForbearDt__c);
        System.assertEquals(loan.loan__Maturity_Date_Current__c, loan.Hardship_New_Maturity_Date__c);
        System.assertEquals(systemDate, loan.Hardship_Request_Date__c);
        System.assertEquals(2, loan.U_LoanModTermExt__c);
    }
    
    @isTest
    public static void testForberanceBatchWithUnprocessedLPTWhentxnDateGreaterthanSystemDate(){//rejects the LPT and reschedules the loan
        List<loan__Loan_Account__c> lAList = [Select id,name,lead_Guid__c,loan__First_Installment_Date__c, 
                                              Application__r.genesis__Monthly_Debt_Payments__c,
                                              loan__Payment_Amount__c,
                                              loan__Loan_Status__c,
                                              loan__Accrual_Start_Date__c,
                                              Application__r.Loan_Origination_Date__c,
                                              loan__Last_Installment_Date__c,
                                              loan__Interest_Rate__c,
                                              loan__Frequency_of_Loan_Payment__c,
                                              loan__Pmt_Amt_Cur__c,
                                              loan__Next_Installment_Date__c,
                                              loan__Previous_Installment_Date__c,
                                              loan__Maturity_Date_Current__c,
                                              loan__Disbursal_Date__c,
                                              loan__Term_Cur__c,
                                              Skipped_a_pay_Date__c,
                                              Skipped_a_Pay__c,
                                              loan__Reschedule_Status__c,
                                              (Select id,name,
                                               loan__Is_Archived__c,
                                               loan__Due_Date__c,
                                               loan__Is_Billed__c,
                                               loan__isPaid__c
                                               from loan__Repayment_Schedule__r),
                                              (select id,name from loan__Repayment_Plan__r),
                                              (select id,loan__Transaction_Date__c,
                                               loan__Transaction_Amount__c,loan__Payment_Mode__c,
                                               loan__Cleared__c,loan__Sent_to_ACH__c from loan__Loan_Payment_Transactions__r),
                                              CPD_Reason__c,
                                              CPD_Expire_Date__c
                                              from loan__Loan_Account__c where lead_guid__c = 'TestClassGuid0'
                                             ];
        
        test.startTest();  
        Map<String,String> loanNameMap = new Map<String,String>();
        for(loan__Loan_Account__c lc : lAList){
            loanNameMap.put(lc.Name, '1');
        }
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();//LSP-339
        Date systemDate = util.getCurrentSystemDate();//LSP-339
        List<loan__Repayment_Schedule__c> amortScheduleUpdate = new List<loan__Repayment_Schedule__c>();
        List<loan__Repayment_Schedule__c> amortSchedule = [select id, name,
                                                           loan__Due_Date__c,
                                                           loan__is_Archived__c,
                                                           loan__isPaid__c,
                                                           loan__Is_Billed__c
                                                           from loan__Repayment_Schedule__c 
                                                           where loan__Loan_Account__r.name in :loanNameMap.keySet()
                                                           AND loan__is_Archived__c = false
                                                           AND loan__due_date__c >= :systemDate
                                                           order by loan__Due_Date__c asc];
        for(loan__Repayment_Schedule__c sch:amortSchedule){
            if(sch.loan__isPaid__c == true){
                sch.loan__isPaid__c = false;
                amortScheduleUpdate.add(sch);
            }
        }
        update amortScheduleUpdate;
        List<loan__Loan_Payment_Transaction__c> updatelpts = new List<loan__Loan_Payment_Transaction__c>();
        List<loan__Loan_Payment_Transaction__c> lpts = [select id, name,loan__Sent_to_ACH__c,loan__Cleared__c,loan__Rejected__c,loan__Reversed__c from loan__Loan_Payment_Transaction__c where
                                                        loan__Loan_Account__r.name in :loanNameMap.keySet() 
                                                        order by loan__Transaction_Date__c desc limit 1];
        for(loan__Loan_Payment_Transaction__c lpt:lpts){
            lpt.loan__Sent_to_ACH__c = false;
            lpt.loan__Cleared__c = false;
            updatelpts.add(lpt);
        }
        update updatelpts;
        Map<String,String> badLoans = new Map<String,String>();//LSP-3
        ForBearanceLoanBatch job = new ForBearanceLoanBatch(loanNameMap,badLoans);//LSP-3
        Database.executeBatch(job,1);    
        test.stopTest();
        loan__loan_account__c loan = [Select id,name,lead_Guid__c,loan__First_Installment_Date__c, 
                                      Application__r.genesis__Monthly_Debt_Payments__c,
                                      loan__Payment_Amount__c,
                                      loan__Loan_Status__c,
                                      loan__Accrual_Start_Date__c,
                                      Application__r.Loan_Origination_Date__c,
                                      loan__Last_Installment_Date__c,
                                      loan__Interest_Rate__c,
                                      loan__Frequency_of_Loan_Payment__c,
                                      loan__Pmt_Amt_Cur__c,
                                      loan__Next_Installment_Date__c,
                                      loan__Previous_Installment_Date__c,
                                      loan__Maturity_Date_Current__c,
                                      loan__Disbursal_Date__c,
                                      loan__Term_Cur__c,
                                      Skipped_a_pay_Date__c,
                                      Skipped_a_Pay__c,
                                      loan__Oldest_Due_Date__c,
                                      loan__Is_Rescheduled__c,
                                      U_LoanModForbearance__c,
                                      Hardship_New_Maturity_Date__c,
                                      U_LoanModForbearDt__c,
                                      Hardship_Request_Date__c,
                                      U_LoanModTermExt__c
                                      from loan__loan_account__c where lead_guid__C = 'TestClassGuid0'];
        //LSP-339 added asserts
        System.assertEquals(true, loan.Skipped_a_Pay__c);
        System.assertEquals(Date.today(), loan.Skipped_a_pay_Date__c);
        System.assertEquals('Active - Good Standing', loan.loan__Loan_Status__c);
        System.assertEquals(systemDate.addMonths(2),loan.loan__Next_Installment_Date__c);
        System.assertEquals(systemDate.addMonths(2), loan.loan__Oldest_Due_Date__c);
        System.assertEquals(systemDate.addMonths(12+1), loan.loan__Maturity_Date_Current__c);
        System.assert(loan.loan__Is_Rescheduled__c);
        System.assertEquals(1, loan.U_LoanModForbearance__c);
        System.assertEquals(systemDate.addMonths(1), loan.U_LoanModForbearDt__c);
        System.assertEquals(loan.loan__Maturity_Date_Current__c, loan.Hardship_New_Maturity_Date__c);
        System.assertEquals(systemDate, loan.Hardship_Request_Date__c);
        System.assertEquals(1, loan.U_LoanModTermExt__c);
    }
    
    //LSP-339
    @isTest
    public static void testForberanceBatchWithUnprocessedLPTWhentxnDateLessthanSystemDate(){//system doesn't process the loans for SAP when there is unprocessedLPT
        List<loan__Loan_Account__c> lAList = [Select id,name,lead_Guid__c,loan__First_Installment_Date__c, 
                                              Application__r.genesis__Monthly_Debt_Payments__c,
                                              loan__Payment_Amount__c,
                                              loan__Loan_Status__c,
                                              loan__Accrual_Start_Date__c,
                                              Application__r.Loan_Origination_Date__c,
                                              loan__Last_Installment_Date__c,
                                              loan__Interest_Rate__c,
                                              loan__Frequency_of_Loan_Payment__c,
                                              loan__Pmt_Amt_Cur__c,
                                              loan__Next_Installment_Date__c,
                                              loan__Previous_Installment_Date__c,
                                              loan__Maturity_Date_Current__c,
                                              loan__Disbursal_Date__c,
                                              loan__Term_Cur__c,
                                              Skipped_a_pay_Date__c,
                                              Skipped_a_Pay__c,
                                              loan__Reschedule_Status__c,
                                              (Select id,name,
                                               loan__Is_Archived__c,
                                               loan__Due_Date__c,
                                               loan__Is_Billed__c,
                                               loan__isPaid__c
                                               from loan__Repayment_Schedule__r),
                                              (select id,name from loan__Repayment_Plan__r),
                                              (select id,loan__Transaction_Date__c,
                                               loan__Transaction_Amount__c,loan__Payment_Mode__c,
                                               loan__Cleared__c,loan__Sent_to_ACH__c from loan__Loan_Payment_Transactions__r),
                                              CPD_Reason__c,
                                              CPD_Expire_Date__c
                                              from loan__Loan_Account__c where lead_guid__c = 'TestClassGuid0'
                                             ];
        
        test.startTest();  
        Map<String,String> loanNameMap = new Map<String,String>();
        for(loan__Loan_Account__c lc : lAList){
            loanNameMap.put(lc.Name, '1');
        }
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();//LSP-339
        Date systemDate = util.getCurrentSystemDate();//LSP-339
        List<loan__Repayment_Schedule__c> amortScheduleUpdate = new List<loan__Repayment_Schedule__c>();
        List<loan__Repayment_Schedule__c> amortSchedule = [select id, name,
                                                           loan__Due_Date__c,
                                                           loan__is_Archived__c,
                                                           loan__isPaid__c,
                                                           loan__Is_Billed__c
                                                           from loan__Repayment_Schedule__c 
                                                           where loan__Loan_Account__r.name in :loanNameMap.keySet()
                                                           AND loan__is_Archived__c = false
                                                           AND loan__due_date__c >= :systemDate
                                                           order by loan__Due_Date__c asc];
        for(loan__Repayment_Schedule__c sch:amortSchedule){
            if(sch.loan__isPaid__c == true){
                sch.loan__isPaid__c = false;
                amortScheduleUpdate.add(sch);
            }
        }
        update amortScheduleUpdate;
        List<loan__Loan_Payment_Transaction__c> updatelpts = new List<loan__Loan_Payment_Transaction__c>();
        List<loan__Loan_Payment_Transaction__c> lpts = [select id, name,loan__Sent_to_ACH__c,loan__Cleared__c,loan__Rejected__c,loan__Reversed__c from loan__Loan_Payment_Transaction__c where
                                                        loan__Loan_Account__r.name in :loanNameMap.keySet() 
                                                        order by loan__Transaction_Date__c desc limit 1];
        for(loan__Loan_Payment_Transaction__c lpt:lpts){
            lpt.loan__Sent_to_ACH__c = false;
            lpt.loan__Cleared__c = false;
            lpt.loan__Transaction_Date__c = systemDate.addDays(-3);
            updatelpts.add(lpt);
        }
        update updatelpts;
        Map<String,String> badLoans = new Map<String,String>();//LSP-3
        ForBearanceLoanBatch job = new ForBearanceLoanBatch(loanNameMap,badLoans);//LSP-3
        Database.executeBatch(job,1);    
        test.stopTest();
        loan__loan_account__c loan = [Select id,name,lead_Guid__c,loan__First_Installment_Date__c, 
                                      Application__r.genesis__Monthly_Debt_Payments__c,
                                      loan__Payment_Amount__c,
                                      loan__Loan_Status__c,
                                      loan__Accrual_Start_Date__c,
                                      Application__r.Loan_Origination_Date__c,
                                      loan__Last_Installment_Date__c,
                                      loan__Interest_Rate__c,
                                      loan__Frequency_of_Loan_Payment__c,
                                      loan__Pmt_Amt_Cur__c,
                                      loan__Next_Installment_Date__c,
                                      loan__Previous_Installment_Date__c,
                                      loan__Maturity_Date_Current__c,
                                      loan__Disbursal_Date__c,
                                      loan__Term_Cur__c,
                                      Skipped_a_pay_Date__c,
                                      Skipped_a_Pay__c,
                                      loan__Oldest_Due_Date__c,
                                      loan__Is_Rescheduled__c,
                                      U_LoanModForbearance__c,
                                      Hardship_New_Maturity_Date__c,
                                      U_LoanModForbearDt__c,
                                      Hardship_Request_Date__c,
                                      U_LoanModTermExt__c
                                      from loan__loan_account__c where lead_guid__C = 'TestClassGuid0'];
        
        System.assertEquals(false, loan.Skipped_a_Pay__c);
        System.assert(!loan.loan__Is_Rescheduled__c);
        System.assertEquals(null, loan.Skipped_a_pay_Date__c);
        System.assertEquals('Active - Good Standing', loan.loan__Loan_Status__c);
        System.assertEquals(systemDate.addMonths(2),loan.loan__Next_Installment_Date__c);
        System.assertEquals(systemDate.addMonths(12), loan.loan__Maturity_Date_Current__c);
    }
    
    @isTest
    public static void testForberanceBatchWithUnprocessedLPTNachaSent(){//system doesn't reschedule the loan when NACHA is already sent
        List<loan__Loan_Account__c> LAList = [Select id,name,lead_Guid__c,loan__First_Installment_Date__c, 
                                              Application__r.genesis__Monthly_Debt_Payments__c,
                                              loan__Payment_Amount__c,
                                              loan__Loan_Status__c,
                                              loan__Accrual_Start_Date__c,
                                              Application__r.Loan_Origination_Date__c,
                                              loan__Last_Installment_Date__c,
                                              loan__Interest_Rate__c,
                                              loan__Frequency_of_Loan_Payment__c,
                                              loan__Pmt_Amt_Cur__c,
                                              loan__Next_Installment_Date__c,
                                              loan__Previous_Installment_Date__c,
                                              loan__Maturity_Date_Current__c,
                                              loan__Disbursal_Date__c,
                                              loan__Term_Cur__c,
                                              Skipped_a_pay_Date__c,
                                              Skipped_a_Pay__c,
                                              loan__Reschedule_Status__c,
                                              (Select id,name,
                                               loan__Is_Archived__c,
                                               loan__Due_Date__c
                                               from loan__Repayment_Schedule__r),
                                              (select id,name from loan__Repayment_Plan__r),
                                              (select id,loan__Transaction_Date__c,
                                               loan__Transaction_Amount__c,loan__Payment_Mode__c,
                                               loan__Cleared__c,loan__Sent_to_ACH__c from loan__Loan_Payment_Transactions__r),
                                              CPD_Reason__c,
                                              CPD_Expire_Date__c
                                              from loan__Loan_Account__c where lead_guid__c = 'TestClassGuid0'
                                             ];   
        loan__Payment_Mode__c pMode = new loan__Payment_Mode__c(Name = 'CASH');
        insert pMode;
        
        Set<String> loanNameset = new Set<String>();
        for(loan__Loan_Account__c lc : LAList){
            loanNameset.add(lc.Name);
        }
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();//LSP-339
        Date systemDate = util.getCurrentSystemDate();//LSP-339
        List<loan__Repayment_Schedule__c> amortScheduleUpdate = new List<loan__Repayment_Schedule__c>();
        List<loan__Repayment_Schedule__c> amortSchedule = [select id, name,
                                                           loan__Due_Date__c,
                                                           loan__is_Archived__c,
                                                           loan__isPaid__c,
                                                           loan__Is_Billed__c
                                                           from loan__Repayment_Schedule__c 
                                                           where loan__Loan_Account__r.name in :loanNameset
                                                           AND loan__is_Archived__c = false
                                                           AND loan__due_date__c >= :systemDate
                                                           order by loan__Due_Date__c asc];
        for(loan__Repayment_Schedule__c sch:amortSchedule){
            if(sch.loan__isPaid__c == true){
                sch.loan__isPaid__c = false;
                amortScheduleUpdate.add(sch);
            }
        }
        update amortScheduleUpdate;
        List<loan__Loan_Payment_Transaction__c> updatelpts = new List<loan__Loan_Payment_Transaction__c>();
        List<loan__Loan_Payment_Transaction__c> lpts = [select id, name,loan__Sent_to_ACH__c,loan__Cleared__c,loan__Rejected__c,loan__Reversed__c from loan__Loan_Payment_Transaction__c where
                                                        loan__Loan_Account__r.name in :loanNameset 
                                                        order by loan__Transaction_Date__c desc limit 1];
        for(loan__Loan_Payment_Transaction__c lpt:lpts){
            lpt.loan__Sent_to_ACH__c = true;
            lpt.loan__Cleared__c = false;
            updatelpts.add(lpt);
        }
        update updatelpts;
        
        test.startTest();           
        ForBearanceLoanBatch job = new ForBearanceLoanBatch(loanNameset);
        Database.executeBatch(job,1);    
        test.stopTest();
        loan__loan_account__c loan = [Select id,name,lead_Guid__c,loan__First_Installment_Date__c, 
                                      Application__r.genesis__Monthly_Debt_Payments__c,
                                      loan__Payment_Amount__c,
                                      loan__Loan_Status__c,
                                      loan__Accrual_Start_Date__c,
                                      Application__r.Loan_Origination_Date__c,
                                      loan__Last_Installment_Date__c,
                                      loan__Interest_Rate__c,
                                      loan__Frequency_of_Loan_Payment__c,
                                      loan__Pmt_Amt_Cur__c,
                                      loan__Next_Installment_Date__c,
                                      loan__Previous_Installment_Date__c,
                                      loan__Maturity_Date_Current__c,
                                      loan__Disbursal_Date__c,
                                      loan__Term_Cur__c,
                                      Skipped_a_pay_Date__c,
                                      Skipped_a_Pay__c,
                                      loan__Oldest_Due_Date__c,
                                      loan__Is_Rescheduled__c,
                                      U_LoanModForbearance__c,
                                      Hardship_New_Maturity_Date__c,
                                      U_LoanModForbearDt__c,
                                      Hardship_Request_Date__c,
                                      U_LoanModTermExt__c
                                      from loan__loan_account__c where lead_guid__C = 'TestClassGuid0'];
        //LSP-339 added asserts
        System.assertEquals(false, loan.Skipped_a_Pay__c);//when the NACHA is alreay sent, then that loan isnt rescheduled
        System.assert(!loan.loan__Is_Rescheduled__c);
        System.assertEquals(null, loan.Skipped_a_pay_Date__c);
        System.assertEquals('Active - Good Standing', loan.loan__Loan_Status__c);
        System.assertEquals(systemDate.addMonths(2),loan.loan__Next_Installment_Date__c);
        System.assertEquals(systemDate.addMonths(12), loan.loan__Maturity_Date_Current__c);
    }
    
    //LSP-339
    @isTest
    public static void forBearanceHelperConstructorRescheduleWithLeadId(){
        ForBearanceLoanHelper helper = new ForBearanceLoanHelper('TestClassGuid0',null);
        Test.startTest();
        List<loan__Loan_Payment_Transaction__c> lpts = [select id, name from loan__Loan_Payment_Transaction__c where
                                                        loan__Loan_Account__r.lead_guid__c = 'TestClassGuid0'];
        delete lpts;
        
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        Date systemDate = util.getCurrentSystemDate();
        List<loan__Repayment_Schedule__c> amortScheduleUpdate = new List<loan__Repayment_Schedule__c>();
        List<loan__Repayment_Schedule__c> amortSchedule = [select id, name,
                                                           loan__Due_Date__c,
                                                           loan__is_Archived__c,
                                                           loan__isPaid__c,
                                                           loan__Is_Billed__c
                                                           from loan__Repayment_Schedule__c 
                                                           where loan__Loan_Account__r.lead_guid__c = 'TestClassGuid0'
                                                           AND loan__is_Archived__c = false
                                                           AND loan__due_date__c >= :systemDate
                                                           order by loan__Due_Date__c asc];
        for(loan__Repayment_Schedule__c sch:amortSchedule){
            if(sch.loan__isPaid__c == true){
                sch.loan__isPaid__c = false;
                amortScheduleUpdate.add(sch);
            }
        }
        update amortScheduleUpdate;
        helper.rescheduleLoan(null);
        Test.stopTest();
        loan__loan_account__c loan = [Select id,name,lead_Guid__c,loan__First_Installment_Date__c, 
                                      Application__r.genesis__Monthly_Debt_Payments__c,
                                      loan__Payment_Amount__c,
                                      loan__Loan_Status__c,
                                      loan__Accrual_Start_Date__c,
                                      Application__r.Loan_Origination_Date__c,
                                      loan__Last_Installment_Date__c,
                                      loan__Interest_Rate__c,
                                      loan__Frequency_of_Loan_Payment__c,
                                      loan__Pmt_Amt_Cur__c,
                                      loan__Next_Installment_Date__c,
                                      loan__Previous_Installment_Date__c,
                                      loan__Maturity_Date_Current__c,
                                      loan__Disbursal_Date__c,
                                      loan__Term_Cur__c,
                                      Skipped_a_pay_Date__c,
                                      Skipped_a_Pay__c,
                                      loan__Oldest_Due_Date__c,
                                      loan__Is_Rescheduled__c,
                                      U_LoanModForbearance__c,
                                      Hardship_New_Maturity_Date__c,
                                      U_LoanModForbearDt__c,
                                      Hardship_Request_Date__c,
                                      U_LoanModTermExt__c
                                      from loan__loan_account__c where lead_guid__C = 'TestClassGuid0'];
        
        System.assertEquals(true, loan.Skipped_a_Pay__c);
        System.assertEquals(Date.today(), loan.Skipped_a_pay_Date__c);
        System.assertEquals('Active - Good Standing', loan.loan__Loan_Status__c);
        System.assertEquals(systemDate.addMonths(2),loan.loan__Next_Installment_Date__c);
        System.assertEquals(systemDate.addMonths(2), loan.loan__Oldest_Due_Date__c);
        System.assertEquals(systemDate.addMonths(12+1), loan.loan__Maturity_Date_Current__c);
        System.assert(loan.loan__Is_Rescheduled__c);
        System.assertEquals(1, loan.U_LoanModForbearance__c);
        System.assertEquals(systemDate.addMonths(1), loan.U_LoanModForbearDt__c);
        System.assertEquals(loan.loan__Maturity_Date_Current__c, loan.Hardship_New_Maturity_Date__c);
        System.assertEquals(systemDate, loan.Hardship_Request_Date__c);
        System.assertEquals(1, loan.U_LoanModTermExt__c);
    }
    
    //LSP-339
    @isTest
    public static void forBearanceHelperConstructorWithIncorrectleadId(){
        Boolean exceptionThrown = false;
        Map<String, String> errorMap = new Map<String, String>();
        try{
            ForBearanceLoanHelper helper = new ForBearanceLoanHelper('TestClassGuid1',null);
            helper.rescheduleLoan(errorMap);
        }catch(Exception e){
            exceptionThrown = true;
        }
        System.assert(exceptionThrown);
    }
    
    @isTest
    public static void forBearanceHelperLAisNull(){
        Boolean exceptionThrown = false;
        try{
            ForBearanceLoanHelper helper = new ForBearanceLoanHelper(null,2);
        }catch(Exception e){
            exceptionThrown = true;
        }
        System.assert(exceptionThrown);
    }
    
    @isTest
    public static void skipAPaysecondTime(){//system doesn't process SAP if SAP is already done on the same day
        List<loan__Loan_Account__c> lAList = [Select id,name,lead_Guid__c,loan__First_Installment_Date__c, 
                                              Application__r.genesis__Monthly_Debt_Payments__c,
                                              loan__Payment_Amount__c,
                                              loan__Loan_Status__c,
                                              loan__Accrual_Start_Date__c,
                                              Application__r.Loan_Origination_Date__c,
                                              loan__Last_Installment_Date__c,
                                              loan__Interest_Rate__c,
                                              loan__Frequency_of_Loan_Payment__c,
                                              loan__Pmt_Amt_Cur__c,
                                              loan__Next_Installment_Date__c,
                                              loan__Previous_Installment_Date__c,
                                              loan__Maturity_Date_Current__c,
                                              loan__Disbursal_Date__c,
                                              loan__Term_Cur__c,
                                              Skipped_a_pay_Date__c,
                                              Skipped_a_Pay__c,
                                              loan__Is_Rescheduled__c,
                                              (Select id,name,
                                               loan__Is_Archived__c,
                                               loan__Due_Date__c,
                                               loan__isPaid__c,
                                               loan__Is_Billed__c
                                               from loan__Repayment_Schedule__r),
                                              (select id,name from loan__Repayment_Plan__r),
                                              CPD_Reason__c,
                                              CPD_Expire_Date__c
                                              from loan__Loan_Account__c where lead_guid__c = 'TestClassGuid0'
                                             ];
        lAList.get(0).Skipped_a_Pay__c = true;
        lAList.get(0).Skipped_a_pay_Date__c = Date.today();
        update lAList;
        test.startTest();  
        Set<Id> loanIdset = new Set<Id>();
        for(loan__Loan_Account__c lc : lAList){
            loanIdset.add(lc.id);
        }    
        ForBearanceLoanBatch job = new ForBearanceLoanBatch(loanIdset);
        Database.executeBatch(job,1);      
        test.stopTest();
        List<loan__Batch_Process_Log__c> batch = [select id,loan__Batch_Id__c,loan__Message__c from loan__Batch_Process_Log__c where loan__Batch_Id__c = 'ForBearanceLoanHelper'];
        System.assert(batch.get(0).loan__Message__c.contains('Pay is already skipped for this contract'));
    }
    
    @isTest
    public static void forBearanceRescheduleFails(){
        List<loan__Loan_Account__c> LAList = [Select id,name,lead_Guid__c,loan__First_Installment_Date__c, 
                                              Application__r.genesis__Monthly_Debt_Payments__c,
                                              loan__Payment_Amount__c,
                                              loan__Loan_Status__c,
                                              loan__Accrual_Start_Date__c,
                                              Application__r.Loan_Origination_Date__c,
                                              loan__Last_Installment_Date__c,
                                              loan__Interest_Rate__c,
                                              loan__Frequency_of_Loan_Payment__c,
                                              loan__Pmt_Amt_Cur__c,
                                              loan__Next_Installment_Date__c,
                                              loan__Previous_Installment_Date__c,
                                              loan__Maturity_Date_Current__c,
                                              loan__Disbursal_Date__c,
                                              loan__Term_Cur__c,
                                              loan__Reschedule_Status__c,
                                              (Select id,name,
                                               loan__Is_Archived__c,
                                               loan__Due_Date__c
                                               from loan__Repayment_Schedule__r),
                                              (select id,name from loan__Repayment_Plan__r),
                                              (select id,loan__Transaction_Date__c,
                                               loan__Transaction_Amount__c,loan__Payment_Mode__c,
                                               loan__Cleared__c,loan__Sent_to_ACH__c from loan__Loan_Payment_Transactions__r),
                                              CPD_Reason__c,
                                              CPD_Expire_Date__c
                                              from loan__Loan_Account__c where lead_guid__c = 'TestClassGuid0'
                                             ];            
        LAList.get(0).loan__Principal_Remaining__c = 0;
        update LAList;
        test.startTest();
        Set<String> loanNameset = new Set<String>();
        for(loan__Loan_Account__c lc : LAList){
            loanNameset.add(lc.Name);
        }    
        ForBearanceLoanBatch job = new ForBearanceLoanBatch(loanNameset);
        Database.executeBatch(job,1);    
        test.stopTest();
        
        loan__loan_account__c loan = [Select id,name,lead_Guid__c,loan__First_Installment_Date__c, 
                                      Application__r.genesis__Monthly_Debt_Payments__c,
                                      loan__Payment_Amount__c,
                                      loan__Loan_Status__c,
                                      loan__Accrual_Start_Date__c,
                                      Application__r.Loan_Origination_Date__c,
                                      loan__Last_Installment_Date__c,
                                      loan__Interest_Rate__c,
                                      loan__Frequency_of_Loan_Payment__c,
                                      loan__Pmt_Amt_Cur__c,
                                      loan__Next_Installment_Date__c,
                                      loan__Previous_Installment_Date__c,
                                      loan__Maturity_Date_Current__c,
                                      loan__Disbursal_Date__c,
                                      loan__Term_Cur__c,
                                      Skipped_a_pay_Date__c,
                                      Skipped_a_Pay__c,
                                      loan__Oldest_Due_Date__c,
                                      loan__Is_Rescheduled__c,
                                      U_LoanModForbearance__c,
                                      Hardship_New_Maturity_Date__c,
                                      U_LoanModForbearDt__c,
                                      Hardship_Request_Date__c,
                                      U_LoanModTermExt__c
                                      from loan__loan_account__c where lead_guid__C = 'TestClassGuid0'];
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();//LSP-339
        Date systemDate = util.getCurrentSystemDate();//LSP-339
        //LSP-339 added asserts
        System.assertEquals(false, loan.Skipped_a_Pay__c);
        System.assert(!loan.loan__Is_Rescheduled__c);
        System.assertEquals(null, loan.Skipped_a_pay_Date__c);
        System.assertEquals('Active - Good Standing', loan.loan__Loan_Status__c);
        System.assertEquals(systemDate.addMonths(2),loan.loan__Next_Installment_Date__c);
        System.assertEquals(systemDate.addMonths(12), loan.loan__Maturity_Date_Current__c);
    }
    
    //LSP-339
    @isTest
    public static void testForberanceBatchWithNumberofSkipsSent(){//Skips those many number of skips
        Map<String, String> errorMap = new Map<String, String>();
        List<loan__Loan_Account__c> lAList = [Select id,name,lead_Guid__c,loan__First_Installment_Date__c, 
                                              Application__r.genesis__Monthly_Debt_Payments__c,
                                              loan__Payment_Amount__c,
                                              loan__Loan_Status__c,
                                              loan__Accrual_Start_Date__c,
                                              Application__r.Loan_Origination_Date__c,
                                              loan__Last_Installment_Date__c,
                                              loan__Interest_Rate__c,
                                              loan__Frequency_of_Loan_Payment__c,
                                              loan__Pmt_Amt_Cur__c,
                                              loan__Next_Installment_Date__c,
                                              loan__Previous_Installment_Date__c,
                                              loan__Maturity_Date_Current__c,
                                              loan__Disbursal_Date__c,
                                              loan__Term_Cur__c,
                                              Skipped_a_pay_Date__c,
                                              Skipped_a_Pay__c,
                                              loan__Reschedule_Status__c,
                                              (Select id,name,
                                               loan__Is_Archived__c,
                                               loan__Due_Date__c,
                                               loan__Is_Billed__c,
                                               loan__isPaid__c
                                               from loan__Repayment_Schedule__r),
                                              (select id,name from loan__Repayment_Plan__r),
                                              (select id,loan__Transaction_Date__c,
                                               loan__Transaction_Amount__c,loan__Payment_Mode__c,
                                               loan__Cleared__c,loan__Sent_to_ACH__c from loan__Loan_Payment_Transactions__r),
                                              CPD_Reason__c,
                                              CPD_Expire_Date__c,
                                              loan__Oldest_Due_Date__c,
                                              U_LoanModForbearance__c,
                                              Hardship_New_Maturity_Date__c,
                                              U_LoanModForbearDt__c,
                                              Hardship_Request_Date__c,
                                              U_LoanModTermExt__c
                                              from loan__Loan_Account__c where lead_guid__c = 'TestClassGuid0'
                                             ];
        
        test.startTest();
        ForBearanceLoanHelper helper = new ForBearanceLoanHelper(lAList.get(0), 2);
        List<loan__Loan_Payment_Transaction__c> lpts = [select id, name,loan__Sent_to_ACH__c,loan__Cleared__c,loan__Rejected__c,loan__Reversed__c from loan__Loan_Payment_Transaction__c where
                                                        loan__Loan_Account__r.lead_guid__c = 'TestClassGuid0'];
        delete lpts;
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        Date systemDate = util.getCurrentSystemDate();
        List<loan__Repayment_Schedule__c> amortScheduleUpdate = new List<loan__Repayment_Schedule__c>();
        List<loan__Repayment_Schedule__c> amortSchedule = [select id, name,
                                                           loan__Due_Date__c,
                                                           loan__is_Archived__c,
                                                           loan__isPaid__c,
                                                           loan__Is_Billed__c
                                                           from loan__Repayment_Schedule__c 
                                                           where loan__Loan_Account__r.lead_guid__c = 'TestClassGuid0'
                                                           AND loan__is_Archived__c = false
                                                           AND loan__due_date__c >= :systemDate
                                                           order by loan__Due_Date__c asc];
        for(loan__Repayment_Schedule__c sch:amortSchedule){
            if(sch.loan__isPaid__c == true){
                sch.loan__isPaid__c = false;
                amortScheduleUpdate.add(sch);
            }
        }
        update amortScheduleUpdate;
        helper.rescheduleLoan(errorMap);
        test.stopTest();
        loan__loan_account__c loan = [Select id,name,lead_Guid__c,loan__First_Installment_Date__c, 
                                      Application__r.genesis__Monthly_Debt_Payments__c,
                                      loan__Payment_Amount__c,
                                      loan__Loan_Status__c,
                                      loan__Accrual_Start_Date__c,
                                      Application__r.Loan_Origination_Date__c,
                                      loan__Last_Installment_Date__c,
                                      loan__Interest_Rate__c,
                                      loan__Frequency_of_Loan_Payment__c,
                                      loan__Pmt_Amt_Cur__c,
                                      loan__Next_Installment_Date__c,
                                      loan__Previous_Installment_Date__c,
                                      loan__Maturity_Date_Current__c,
                                      loan__Disbursal_Date__c,
                                      loan__Term_Cur__c,
                                      Skipped_a_pay_Date__c,
                                      Skipped_a_Pay__c,
                                      loan__Oldest_Due_Date__c,
                                      loan__Is_Rescheduled__c,
                                      U_LoanModForbearance__c,
                                      Hardship_New_Maturity_Date__c,
                                      U_LoanModForbearDt__c,
                                      Hardship_Request_Date__c,
                                      U_LoanModTermExt__c
                                      from loan__loan_account__c where lead_guid__C = 'TestClassGuid0'];
        
        System.assertEquals(true, loan.Skipped_a_Pay__c);
        System.assertEquals(Date.today(), loan.Skipped_a_pay_Date__c);
        System.assertEquals('Active - Good Standing', loan.loan__Loan_Status__c);
        System.assertEquals(systemDate.addMonths(3),loan.loan__Next_Installment_Date__c);
        System.assertEquals(systemDate.addMonths(3), loan.loan__Oldest_Due_Date__c);
        System.assertEquals(systemDate.addMonths(12+2), loan.loan__Maturity_Date_Current__c);
        System.assert(loan.loan__Is_Rescheduled__c);
        System.assertEquals(2, loan.U_LoanModForbearance__c);
        System.assertEquals(systemDate.addMonths(1), loan.U_LoanModForbearDt__c);
        System.assertEquals(loan.loan__Maturity_Date_Current__c, loan.Hardship_New_Maturity_Date__c);
        System.assertEquals(systemDate, loan.Hardship_Request_Date__c);
        System.assertEquals(2, loan.U_LoanModTermExt__c);
    }
    
}