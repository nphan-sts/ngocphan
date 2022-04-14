/* ****************Modification History******************
*    Created By        	 Date			Version
*1. Bhavya Maliwal        2022/02/28     LSP-574, Initial Version, updated code, added comments, removed unwanted code, increased coverage

******************Modification History******************/
@isTest
public class CLS_TestBillUpdate {
    
    @testSetup static void setup() {
        
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //dummy account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        //dummy office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        //dummy fee
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        
        //dummy purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        //dummy contact 
        Contact a1 = new Contact(LastName='TestACH');
        insert a1;
        
        //dummy contract
        loan__Loan_Account__c lacc = loan.TestHelper.createLoanAccountForContactObj(dummyLP,
                                                                                    a1,
                                                                                    dummyFeeSet,
                                                                                    dummyLoanPurpose,
                                                                                    dummyOffice); 
        
        loan__Payment_Mode__c paymentMode = [select id from loan__Payment_Mode__c where Name= 'Cash'];
        
        //loan Disbursal Txn
        loan__Loan_Disbursal_Transaction__c disTxn = new loan__Loan_Disbursal_Transaction__c();
        disTxn.loan__Disbursed_Amt__c = lacc.loan__Loan_Amount__c;
        disTxn.loan__Mode_of_Payment__c = paymentMode.Id;
        disTxn.loan__Loan_Account__c = lacc.Id;
        disTxn.loan__Disbursal_Date__c = loan.TestHelper.systemDate;
        insert disTxn;
        disTxn.loan__Cleared__c = true;
        update disTxn;
        
        //LPT for LS Contract
        loan__Loan_Payment_Transaction__c test_LPT1 = new loan__Loan_Payment_Transaction__c();
        test_LPT1.loan__Loan_Account__c = lacc.Id;
        test_LPT1.loan__Transaction_Amount__c = 200;
        test_LPT1.loan__Transaction_Date__c = System.today();
        test_LPT1.loan__Receipt_Date__c = System.today();
        test_LPT1.loan__Payment_Mode__c = paymentMode.Id;
        test_LPT1.loan__Cleared__c = true;
        insert test_LPT1;
        
        loan__Loan_Payment_Transaction__c test_LPT2 = new loan__Loan_Payment_Transaction__c();
        test_LPT2.loan__Loan_Account__c = lacc.Id;
        test_LPT2.loan__Transaction_Amount__c = 200;
        test_LPT2.loan__Transaction_Date__c = System.today();
        test_LPT2.loan__Receipt_Date__c = System.today();
        test_LPT2.loan__Payment_Mode__c = paymentMode.Id;
        test_LPT2.loan__Cleared__c = true;
        insert test_LPT2;
        
        //IPT creation
        loan__Interest_Posting_Transaction__c test_IPT1 = new loan__Interest_Posting_Transaction__c();
        test_IPT1.loan__Payment_Amount__c = 40;
        test_IPT1.loan__Interest_Posted__c = 0;
        test_IPT1.loan__Loan_Contract__c = lacc.Id;
        test_IPT1.loan__Transaction_Posting_Date__c = System.today();
        test_IPT1.loan__Transaction_Creation_Date__c = System.today();
        test_IPT1.loan__Transaction_Due_Date__c = System.today();
        insert test_IPT1;
        
        loan__Interest_Posting_Transaction__c test_IPT2 = new loan__Interest_Posting_Transaction__c();
        test_IPT2.loan__Payment_Amount__c = 40;
        test_IPT2.loan__Interest_Posted__c = 0;
        test_IPT2.loan__Loan_Contract__c = lacc.Id;
        test_IPT2.loan__Transaction_Posting_Date__c = System.today();
        test_IPT2.loan__Transaction_Creation_Date__c = System.today();
        test_IPT2.loan__Transaction_Due_Date__c = System.today();
        test_IPT2.loan__Status__c = 'Closed';
        insert test_IPT2;
        
        loan__Interest_Posting_Transaction__c test_IPT3 = new loan__Interest_Posting_Transaction__c();
        test_IPT3.loan__Payment_Amount__c = 40;
        test_IPT3.loan__Interest_Posted__c = 0;
        test_IPT3.loan__Loan_Contract__c = lacc.Id;
        test_IPT3.loan__Transaction_Posting_Date__c = System.today();
        test_IPT3.loan__Transaction_Creation_Date__c = System.today();
        test_IPT3.loan__Transaction_Due_Date__c = System.today();
        test_IPT3.loan__Status__c = 'Closed';
        insert test_IPT3;
        
        
    }
    /*Created By : Bhavya Maliwal
Method name : billJobTest
Purpose : to cover code satisfying below apex classes
CLS_RepostLPTxnHandler
CLS_RepostLPTxnJOB
CLS_GenerateBillHandler
CLS_DiscardBillJobHandler 
CLS_DiscardBillJob
*/
    Testmethod static void billJobTest(){
        
        List<loan__Loan_Account__c> LAList = [SELECT ID,Name,
                                              loan__Previous_Installment_Date__c,
                                              loan__Account__r.cnotify__Email__c,
                                              loan__Loan_Product_Name__r.name, 
                                              loan__Payment_Amount__c, 
                                              loan__Next_Installment_Date__c, 
                                              loan__Account__r.ID,Borrowers_First_Name__c,
                                              loan__Account__r.Borrower_s_Last_Name__c,
                                              loan__Loan_Product_Name__c 
                                              from loan__Loan_Account__c];
        System.debug(LAList[0].Name);
        loan__Automated_Payment_Setup__c laps=new loan__Automated_Payment_Setup__c();
        laps.loan__CL_Contract__c=LAList[0].Id;
        laps.loan__Active__c=true ;
        laps.loan__Type__c='RECURRING';
        laps.loan__Frequency__c='Monthly';
        insert laps;
        loan__Loan_Payment_Transaction__c lpt=new loan__Loan_Payment_Transaction__c();
        lpt.loan__Loan_Account__c = LAList[0].Id ;
        lpt.loan__Reversed__c = true ;
        lpt.Custom_Reverse__c = true ;
        lpt.loan__Transaction_Date__c=system.today();
        lpt.loan__Transaction_Amount__c=2345;
        insert lpt;
        //Create Bill
        loan__Loan_account_Due_Details__c test_bill1 = new loan__Loan_account_Due_Details__c();
        test_bill1.loan__Due_Type__c = 1;
        test_bill1.loan__Due_Type_Description__c = 'BILL / DUE DATE';
        test_bill1.loan__Loan_Account__c = LAList[0].Id;
        insert test_bill1;
        
        loan__Loan_account_Due_Details__c test_bill2 = new loan__Loan_account_Due_Details__c();
        test_bill2.loan__Due_Type__c = 1;
        test_bill2.loan__Due_Type_Description__c = 'BILL / DUE DATE';
        test_bill2.loan__Loan_Account__c = LAList[0].Id;
        insert test_bill2;
        
        loan__Loan_account_Due_Details__c test_bill3 = new loan__Loan_account_Due_Details__c();
        test_bill3.loan__Due_Type__c = 1;
        test_bill3.loan__Due_Type_Description__c = 'BILL / DUE DATE';
        test_bill3.loan__Loan_Account__c = LAList[0].Id;
        insert test_bill3;
        
        test.startTest();
        CLS_DiscardBillJob job = new CLS_DiscardBillJob(new List<String>{LAList[0].Name});
        Database.executeBatch(job, 1);
        test.stopTest();
        List<loan__Loan_account_Due_Details__c> billList = [SELECT Id,Name,loan__DD_Primary_Flag__c,loan__Transaction_Date__c 
                                                            FROM loan__Loan_account_Due_Details__c 
                                                            WHERE loan__Loan_Account__c=:LAList[0].Id];
        system.assert(!billList[0].loan__DD_Primary_Flag__c);
        
        
    }
    
    
}