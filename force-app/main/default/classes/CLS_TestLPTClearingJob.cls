@isTest
public class CLS_TestLPTClearingJob {
    
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
        test_LPT1.loan__Cleared__c = false;
        test_LPT1.Custom_Reverse__c = false;
        test_LPT1.loan__Reversed__c = false;
        insert test_LPT1;
        
        /*loan__Loan_Payment_Transaction__c test_LPT2 = new loan__Loan_Payment_Transaction__c();
        test_LPT2.loan__Loan_Account__c = lacc.Id;
        test_LPT2.loan__Transaction_Amount__c = 200;
        test_LPT2.loan__Transaction_Date__c = System.today();
        test_LPT2.loan__Receipt_Date__c = System.today();
        test_LPT2.loan__Payment_Mode__c = paymentMode.Id;
        test_LPT2.Custom_Reverse__c = false;
        test_LPT2.loan__Reversed__c = false;
        insert test_LPT2;*/

        
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
        test_IPT3.loan__Status__c = 'Open';
        test_IPT3.loan__Discarded__c = false;
        insert test_IPT3;
        
    }
    
    Testmethod static void method1(){
        
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
        test.startTest();
        CLS_LPTClearingHandler h = new CLS_LPTClearingHandler(new List<String>{LAList[0].Name});
        test.stopTest();
       
    }
    
    /*Testmethod static void method1(){
        
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
        test.startTest();
        CLS_LPTClearingHandler h = new CLS_LPTClearingHandler(new List<String>{LAList[0].Name});
        test.stopTest();
       
    }*/

}