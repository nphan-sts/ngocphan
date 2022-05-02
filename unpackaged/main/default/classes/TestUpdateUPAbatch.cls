/* ****************Modification History******************
 * Last Modified by        Date          JIRA number
 *      1. Shakul         2022/04/18     LSP-544 (Refactored Test Class)
 ******************Modification History******************/
@isTest
public class TestUpdateUPAbatch {
    static final String AUTO_PAYER = 'Auto Payer';
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
        
        Account a2 = new Account(peer__First_Name__c = 'TestFName', peer__Last_Name__c='TestLName', loan__Undeployed_Funds__c = 999999,loan__Investor__c = true);   //pallavi
        insert a2;
        loan.CustomSettingsUtil.getNS();

        loan.TestHelper.systemDate = Date.today(); 
        Id rtId = Schema.SObjectType.loan__Office_Name__c.getRecordTypeInfosByDeveloperName().get('Root_Branch').getRecordTypeId();
        
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
        
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, a1, dummyAccount); 
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet(); 
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        
        loan__Loan_Product__c prod = new loan__Loan_Product__c(Name=AUTO_PAYER,
                                                               loan__Loan_Product_Type__c = 'Loan',
                                                               loan__Currency__c = (curr != null) ? curr.ID : null,
                                                               loan__Fee_Set__c = (dummyFeeSet != null) ? dummyFeeSet.ID : null,
                                                               loan__Accrual_Based_Accounting__c=true,
                                                               loan__Accrue_Income_On_Suspended_Account__c=true,
                                                               loan__Cash_Based_Accounting__c=false,
                                                               loan__Maximum_Gap_Between_Installments__c=1,
                                                               loan__Minimum_Gap_Between_Installments__c=1,
                                                               loan__Max_Loan_Amount__c=30000,
                                                               loan__Max_Overdue_Interest_Rate__c=24,
                                                               loan__Minimum_Installment_Amount__c=100,
                                                               loan__Min_Interest_Rate__c=1,
                                                               loan__Min_Loan_Amount__c=0,
                                                               loan__Min_Number_of_Installments__c=0,
                                                               loan__Min_Overdue_Interest_Rate__c=10,
                                                               loan__Product_Interest_Income_Account__c=dummyAccount.Id,
                                                               loan__Product_Int_On_Overdue_Income_Acc__c=dummyAccount.Id,
                                                               loan__Product_Loan_Control_Account__c=dummyAccount.Id,
                                                               loan__Product_Loan_Loss_Provision_Account__c=dummyAccount.Id,
                                                               loan__Product_Loan_Loss_Reserve_Account__c=dummyAccount.Id,
                                                               loan__Product_Overdue_Interest_Account__c=dummyAccount.Id,
                                                               loan__Product_Suspended_Interest_Account__c=dummyAccount.Id,
                                                               loan__Product_Suspended_Int_On_Overdue_Acc__c=dummyAccount.Id,
                                                               loan__Product_Write_Off_Recovery_Account__c=dummyAccount.Id,
                                                               loan__Product_Interest_Amortization_Account__c=dummyAccount.Id,
                                                               loan__Product_Excess_Account__c=dummyAccount.Id,
                                                               loan__Status__c='Active');
        
        insert prod;
        
        List<loan__Payment_Mode__c> pmList = new List<loan__Payment_Mode__c>();
        loan__Payment_Mode__c pMode = new loan__Payment_Mode__c(name='Cash');
        pmList.add(pMode);

        loan__Payment_Mode__c pm = new loan__Payment_Mode__c();
        pm.name = 'ACH';
        pmList.add(pm);
        insert pmList;
        
        loan__Bank_Account__c bankAccount = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12', 
                                                                      loan__Bank_Name__c = 'Some Bank', 
                                                                      loan__Routing_Number__c = '999999999', 
                                                                      loan__Account_Type__c = 'Savings', 
                                                                      loan__Account_Usage__c = 'Borrower/Investor Account', 
                                                                      loan__Account__c = a2.id,
                                                                      Unmasked_Bank_Account_Number__c = '12345');   //pallavi
        insert bankAccount;
        
        List<loan__Loan_Account__c> lacList = new List<loan__Loan_Account__c>();
        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        loanAccount.loan__Product_Type__c = AUTO_PAYER;
        loanAccount.loan__Loan_Amount__c = 0;
        loanAccount.loan__Credit_Limit__c = 50000;
        loanAccount.loan__Credit_Limit_Current__c = 50000;
        loanAccount.loan__Account__c= a2.Id; 
        loanAccount.loan__Number_of_Installments__c = 12;
        loanAccount.loan__Contractual_Interest_Rate__c = loanAccount.loan__Interest_Rate__c;
        loanAccount.loan__Fee_Set__c = (dummyFeeSet != null) ? dummyFeeSet.ID : null;
        loanAccount.loan__Loan_Product_Name__c = prod.ID;
        loanAccount.loan__Overdue_Interest_Rate__c = 12;
        loanAccount.loan__Expected_Disbursal_Date__c = null;
        loanAccount.loan__Repayment_Tied_to_Meeting_Schedule__c = false;
        loanAccount.loan__Repayment_Procedure__c = 'Equal Monthly Installments';
        loanAccount.loan__Expected_Repayment_Start_Date__c = null; //pallavi(test class was failing)
        loanAccount.loan__Branch__c = dummyOffice.ID;
        loanAccount.loan__Oldest_Due_Date__c = loanAccount.loan__Expected_Repayment_Start_Date__c;
        loanAccount.loan__First_Installment_Date__c = null;
        loanAccount.loan__Next_Installment_Date__c = null;
        loanAccount.loan__Disbursal_Date__c = Date.today().addDays(-20);
        loanAccount.loan__Term_Cur__c = 0;
        loanAccount.loan__Principal_Remaining__c = 0;
        Integer dueday = 0;
        loanAccount.loan__Due_Day__c = dueday;
        loanAccount.loan__Contractual_Due_Day__c = dueday;
        loanAccount.loan__Interest_Only_Period__c = 0;
        loanAccount.loan__Interest_Only_Payment_Amt__c = 0;
        loanAccount.loan__Loan_Account_External_Id__c = string.valueOf(math.random()).right(4);
        loanAccount.loan__Loan_Status__c = 'Active - Good Standing';
        loanAccount.loan__Payment_Mode__c = pmode.id;
        loanAccount.loan__la_amortization_frequency__c = '';
        loanAccount.loan__LA_Amortized_Balance_Type__c = '';
        loanAccount.loan__Fees_Remaining__c = 0;
        loanAccount.loan__Uncleared_Repayment_Amount__c = 10;
        loanAccount.datafixupb__c = true;
        loanAccount.loan__Principal_paid__c = 1000;
        loanAccount.loan__Last_Accrual_Date__c = System.today() - 1;
        lacList.add(loanAccount);
        
        //Saryu 
        loan__Loan_Account__c loanAccount1 = new loan__Loan_Account__c();
        loanAccount1.loan__Product_Type__c = AUTO_PAYER;
        loanAccount1.loan__Loan_Amount__c = 0;
        loanAccount1.loan__Credit_Limit__c = 50000;
        loanAccount1.loan__Credit_Limit_Current__c = 50000;
        loanAccount1.loan__Account__c= a2.Id; 
        loanAccount1.loan__Number_of_Installments__c = 12;
        loanAccount1.loan__Contractual_Interest_Rate__c = loanAccount1.loan__Interest_Rate__c;
        loanAccount1.loan__Fee_Set__c = (dummyFeeSet != null) ? dummyFeeSet.ID : null;
        loanAccount1.loan__Loan_Product_Name__c = prod.ID;
        loanAccount1.loan__Overdue_Interest_Rate__c = 12;
        loanAccount1.loan__Expected_Disbursal_Date__c = null;
        loanAccount1.loan__Repayment_Tied_to_Meeting_Schedule__c = false;
        loanAccount1.loan__Repayment_Procedure__c = 'Equal Monthly Installments';
        loanAccount1.loan__Expected_Repayment_Start_Date__c = null;//pallavi(test class was failing)
        loanAccount1.loan__Branch__c = dummyOffice.ID;
        loanAccount1.loan__Oldest_Due_Date__c = loanAccount1.loan__Expected_Repayment_Start_Date__c;
        loanAccount1.loan__First_Installment_Date__c = null;
        loanAccount1.loan__Next_Installment_Date__c = null;
        loanAccount1.loan__Disbursal_Date__c = Date.today().addDays(-20);
        loanAccount1.loan__Term_Cur__c = 0;
        loanAccount1.loan__Principal_Remaining__c = 0;
        Integer dueday1 = 0;
        loanAccount1.loan__Due_Day__c = dueday1;
        loanAccount1.loan__Contractual_Due_Day__c = dueday1;
        loanAccount1.loan__Interest_Only_Period__c = 0;
        loanAccount1.loan__Interest_Only_Payment_Amt__c = 0;
        loanAccount1.loan__Loan_Account_External_Id__c = string.valueOf(math.random()).right(4);
        loanAccount1.loan__Loan_Status__c = 'Active - Good Standing';
        loanAccount1.loan__Payment_Mode__c = pmode.id;
        loanAccount1.loan__la_amortization_frequency__c = '';
        loanAccount1.loan__LA_Amortized_Balance_Type__c = '';
        loanAccount1.loan__Fees_Remaining__c = 0;
        loanAccount1.loan__Uncleared_Repayment_Amount__c = null;
        loanAccount1.datafixupb__c = true;
        loanAccount1.loan__Principal_paid__c = 1000;
        loanAccount1.loan__Last_Accrual_Date__c = System.today() - 1;
        lacList.add(loanAccount1);
        insert lacList;
        
        List<loan__Loan_Payment_Transaction__c> lapList = new List<loan__Loan_Payment_Transaction__c>();
        loan__Loan_Payment_Transaction__c payment = new loan__Loan_Payment_Transaction__c();
        payment.loan__Transaction_Amount__c = 2000.00;
        payment.loan__Loan_Account__c = loanAccount.id;
        payment.loan__Skip_Validation__c = true;
        payment.loan__Principal__c = 2000;
        payment.loan__Interest__c = 0;
        payment.loan__Reversed__c = false;
        payment.loan__Cleared__c = false;
        payment.loan__Rejected__c = false;    
        payment.loan__Payment_Mode__c = pm.Id;
        lapList.add(payment);
        
        //Saryu
        loan__Loan_Payment_Transaction__c payment1 = new loan__Loan_Payment_Transaction__c();
        payment1.loan__Transaction_Amount__c = 500.00;
        payment1.loan__Loan_Account__c = loanAccount.id;
        payment1.loan__Skip_Validation__c = true;
        payment1.loan__Principal__c = null;
        payment1.loan__Interest__c = 0;
        payment1.loan__Reversed__c = false;
        payment1.loan__Cleared__c = false;
        payment1.loan__Rejected__c = false;    
        payment1.loan__Payment_Mode__c = pm.Id; 
        lapList.add(payment1); 
        insert lapList;
    }

    /*Created By: Shakul Siddharth
      Purpose: To test updateUPAbatch constructor*/
    static testMethod void testBatchNoParams(){ 
        Test.startTest();
        updateUPAbatch dm = new updateUPAbatch();
        Database.executeBatch(dm);
        Test.stopTest();
        loan__loan_Account__c testAssertContract = [SELECT id, UPAfixed__c FROM loan__loan_Account__c LIMIT 1];
        System.assertEquals(testAssertContract.UPAfixed__c, true);
    }

    /*Created By: Shakul Siddharth
      Purpose: To test updateUPAbatch constructor passing contract id as a parameter*/
    static testMethod void testBatchSingleParam(){ 
        Set<id> a = new Set<Id>();
        list<Loan__loan_account__c>lacc = [select id from Loan__loan_account__c];
        for(loan__loan_Account__c la : lacc)
        {
            a.add(la.id);
        }
        Test.startTest();
        updateUPAbatch dm = new updateUPAbatch(a);
        Database.executeBatch(dm);
        Test.stopTest();
        loan__loan_Account__c testAssertContract = [SELECT id, UPAfixed__c FROM loan__loan_Account__c LIMIT 1];
        System.assertEquals(testAssertContract.UPAfixed__c, true);
    }
}