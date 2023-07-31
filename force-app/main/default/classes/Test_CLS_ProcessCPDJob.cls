/* ****************Modification History******************
*    Created By        	 Date			Version
*1. Bhavya Maliwal        2022/02/01     Initial Version

******************Modification History******************/
@isTest
public class Test_CLS_ProcessCPDJob {
    
    static loan__Loan_Account__c createLoanAccount() {
        //Creating Seed Data for Testing
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
        
        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct('Loan Product',
                                                                          dummyOffice,
                                                                          dummyAccount,
                                                                          curr,
                                                                          dummyFeeSet,
                                                                          'Interest Only',
                                                                          40,
                                                                          12,
                                                                          null);
        
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        Account acc = new Account(Name = 'SF',peer__Last_Name__c='scenario');
        insert acc;
        
        loan__Payment_Mode__c paymentMode = new loan__Payment_Mode__c(name='ACH');
        insert paymentMode;
        Date systemDate = TestHelper.getCurrentSystemDate();
        
        //Create a dummy Loan Account
        loan__Loan_Account__c loanAccount = loan.TestHelper.createLoanAccountForAccountObj(dummyLP,
                                                                                           acc,
                                                                                           dummyFeeSet,
                                                                                           dummyLoanPurpose,
                                                                                           dummyOffice);
        loanAccount.loan__Loan_Status__c = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        loanAccount.loan__Contact__c = null;
        loanAccount.lead_Guid__c = 'qwertt';
        loanAccount.loan__Interest_Rate__c = 10;
        loanAccount.loan__Frequency_of_Loan_Payment__c = 'Monthly';
        loanAccount.loan__Pmt_Amt_Cur__c = 1000;
        loanAccount.loan__Next_Installment_Date__c = systemDate;
        loanAccount.loan__Maturity_Date_Current__c = systemDate;
        loanAccount.loan__Term_Cur__c = 36;
        loanAccount.CPD_Reason__c = 'Other';
        loanAccount.CPD_Expire_Date__c = Date.newInstance(2019, 12, 4);
        loanAccount.Future_Bill_Pending__c = true;
        loanAccount.loan__Due_Day__c = 3;
        loanAccount.CPD_Date__c = systemDate;
        loanAccount.CPD_Unpaid_Due_Date__c = systemdate.addDays(-1);
        update loanAccount;
        
        return loanAccount;
    } 
    /*Created By : Bhavya Maliwal
Method name : CLS_ProcessCPDJob_ExceptionSenario
Purpose : to cover code satisfying Exception scenario/test case for CLS_ProcessCPDJob
*/
    @isTest
    static void CLS_ProcessCPDJob_ExceptionSenario(){
       loan__Loan_Account__c loanAccount = createLoanAccount();
        Date systemDate = TestHelper.getCurrentSystemDate();
        loanAccount.loan__Last_Installment_Date__c = systemDate;
        update loanAccount;
        
        Test.startTest();
        CLS_ProcessCPDJob dm = new CLS_ProcessCPDJob(); 
        Database.executeBatch(dm);
        Test.stopTest();
        
        List<loan__Loan_Account__c> llc=[select id from loan__Loan_Account__c ];
        system.assertEquals(True, llc.size()==1);
    }
    /*Created By : Bhavya Maliwal
Method name : CLS_ProcessCPDJob_PositiveSenario
Purpose : to cover code satisfying Positive scenario/test case for CLS_ProcessCPDJob
*/
    @isTest
    static void CLS_ProcessCPDJob_PositiveSenario(){
        loan__Loan_Account__c loanAccount = createLoanAccount();
        loanAccount.loan__Last_Installment_Date__c = null;
        update loanAccount;
        
        Test.startTest();
        List<String> contract = new List<String>();
        contract.add(loanAccount.id);
        CLS_ProcessCPDJob dm = new CLS_ProcessCPDJob(contract);
        Database.executeBatch(dm);
        Test.stopTest();
        List<loan__Loan_Account__c> llc=[select id from loan__Loan_Account__c ];
        system.assertEquals(True, llc.size()==1);
    }
    
}