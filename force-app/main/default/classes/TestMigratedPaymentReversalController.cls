/* ****************Modification History******************
 *      1. Pallavi       2021/07/09        LSP-261    
 *      2. Pallavi       2021/09/18        LSP-375
 ******************Modification History******************/
@isTest
public class TestMigratedPaymentReversalController{

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
        lacc.isMigrated__c = true;
        update lacc;
        
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
        test_LPT1.loan_Is_Migrated__c = true ;
        insert test_LPT1;
        
        loan__Loan_Payment_Transaction__c test_LPT2 = new loan__Loan_Payment_Transaction__c();
        test_LPT2.loan__Loan_Account__c = lacc.Id;
        test_LPT2.loan__Transaction_Amount__c = 400;
        test_LPT2.loan__Transaction_Date__c = System.today();
        test_LPT2.loan__Receipt_Date__c = System.today();
        test_LPT2.loan__Payment_Mode__c = paymentMode.Id;
        test_LPT2.loan__Cleared__c = true;
        test_LPT2.loan_Is_Migrated__c = true ;
        insert test_LPT2;
        
        //Create Bill
        loan__Loan_account_Due_Details__c test_bill1 = new loan__Loan_account_Due_Details__c();
        test_bill1.loan__Due_Type__c = 1;
        test_bill1.loan__Due_Type_Description__c = 'BILL / DUE DATE';
        test_bill1.loan__Loan_Account__c = lacc.Id;
        test_bill1.loan__Due_Date__c = Date.Today().addDays(-30);   //LSP-375
        insert test_bill1;
        
        loan__Loan_account_Due_Details__c test_bill2 = new loan__Loan_account_Due_Details__c();
        test_bill2.loan__Due_Type__c = 1;
        test_bill2.loan__Due_Type_Description__c = 'BILL / DUE DATE';
        test_bill2.loan__Loan_Account__c = lacc.Id;
        test_bill2.loan__DD_Primary_Flag__c = True;
        test_bill2.loan__Payment_Satisfied__c = false ;
        insert test_bill2;
        
        loan__Loan_account_Due_Details__c test_bill3 = new loan__Loan_account_Due_Details__c();
        test_bill3.loan__Due_Type__c = 1;
        test_bill3.loan__Due_Type_Description__c = 'BILL / DUE DATE';
        test_bill3.loan__Loan_Account__c = lacc.Id;
        insert test_bill3;
        
        loan__Due_Payment__c due = new loan__Due_Payment__c(loan__Fees__c = null,
                                                         loan__Payment_Amount__c = null,
                                                         loan__Principal__c = null,
                                                         External_Id__c = null,
                                                         loan__Interest__c = null,
                                                         loan__Loan_Payment_Transaction__c = test_LPT1.id,
                                                         loan__Due__c = test_bill1.id
                                                         );
                                                         
        insert due;
        
        //LSP-375 create AMZ
        loan__Repayment_Schedule__c repaySch = new loan__Repayment_Schedule__c();
        repaySch.loan__Loan_Account__c = lacc.Id;
        repaySch.loan__Due_Date__c = Date.Today().addDays(-30);
        repaySch.loan__Due_Interest__c = 40.00 ;
        repaySch.loan__Balance__c = 800;
        repaySch.loan__Paid_Principal__c=100;  
        repaySch.External_Id__C = '123';  
        repaySch.loan__Due_Principal__c = null;
        repaySch.loan__isPaid__c = true;
        insert repaySch;
    }
    
    
    Testmethod static void method1(){
    
    Date lastUnpaidDueDate = Date.newinstance(2020,04,01);
    Date lastPaidDueDate = Date.newinstance(2020,03,01);
    List<loan__Loan_Payment_Transaction__c> payments = new List<loan__Loan_Payment_Transaction__c>();
    loan__Due_Payment__c DPD = [select id,name,loan__Due__c,loan__Loan_Payment_Transaction__c from loan__Due_Payment__c];
    loan__Loan_account_Due_Details__c oldestDuet = [select id,name from loan__Loan_account_Due_Details__c where id =: DPD.loan__Due__c];
       
    List<loan__Loan_Account__c> LAList = [SELECT ID,Name,loan__Pre_Bill_Days__c,
                                            loan__Principal_Remaining__c,
                                            loan__Principal_Paid__c,
                                            loan__Interest_Paid__c,  
                                          loan__Previous_Installment_Date__c,
                                          loan__Account__r.cnotify__Email__c,
                                          loan__Loan_Product_Name__r.name, 
                                          loan__Payment_Amount__c, 
                                          loan__Next_Installment_Date__c,
                                          loan__Interest_Rate__c,               //LSP-261
                                          loan__Pay_Off_Amount_As_Of_Today__c,  //LSP-261
                                          (select id,name,loan_Is_Migrated__c,
                                          loan__Transaction_Date__c, 
                                          loan__Transaction_Time__c,
                                          loan__Principal__c,
                                          loan__Interest__c
                                          from loan__Loan_Payment_Transactions__r 
                                          where id =: DPD.loan__Loan_Payment_Transaction__c)                                         
                                          loan__Account__r.ID,Borrowers_First_Name__c,
                                          (select id,name,loan__Due_Date__c  
                                           from loan__Dues_Details__r)
                                          loan__Account__r.Borrower_s_Last_Name__c,
                                          loan__Loan_Product_Name__c 
                                          from loan__Loan_Account__c];
     Decimal initialPayoff = LAList[0].loan__Pay_Off_Amount_As_Of_Today__c; //LSP-261
    
     loan__Loan_Account__c loanAccount = LAList[0];
     payments = [select id,name,loan_Is_Migrated__c,
                                          loan__Transaction_Date__c, 
                                          loan__Transaction_Time__c,
                                          loan__Principal__c,loan__Interest__c, 
                                          (select id,name,
                                            loan__Due__c  
                                            from loan__Due_Payments__r)
                                           
                                          from loan__Loan_Payment_Transaction__c 
                                          where id =: DPD.loan__Loan_Payment_Transaction__c];
                                          
     System.debug(logginglevel.error, 'loanAccount ::'+loanAccount + 'payments ::'+payments);
     /*LSP-261*/   
     Decimal totalAmountReversed = 0.0;
        for(loan__Loan_Payment_Transaction__c pay : payments){
            totalAmountReversed = totalAmountReversed + pay.loan__Principal__c + pay.loan__Interest__c;
        }   
     /*LSP-261*/   
     MigratedPaymentReversalController ctl = new MigratedPaymentReversalController(new ApexPages.StandardController (loanAccount));     
     ctl.currentRecordId = loanAccount.Id;
     ctl.NumOfPayments = String.valueof(1);
     ctl.migratedLoan = loanAccount;
     ctl.getPayments();
     
     ctl.paymentsToBeReversed = payments;    
     Test.startTest();  //LSP-261
     ctl.reversePayments();
     /*LSP-261*/   
     List<Repayment_Txn_Reversal_Migrated_Payment__c> rev = [select id from Repayment_Txn_Reversal_Migrated_Payment__c
                                                            where Loan_Payment_Transaction__c in: payments];   
     System.assertEquals(rev.size(), payments.size());
     loan__loan_account__c contract = [select id,loan__Pay_Off_Amount_As_Of_Today__c from loan__loan_account__c
                                            where id =: LAList[0].id];
     System.assertEquals(initialPayoff + totalAmountReversed, contract.loan__Pay_Off_Amount_As_Of_Today__c); 
     Test.stopTest();
     /*LSP-261*/   
    }
    
    Testmethod static void method2(){
    
    Date lastUnpaidDueDate = Date.newinstance(2020,04,01);
    Date lastPaidDueDate = Date.newinstance(2020,03,01);
    List<loan__Loan_Payment_Transaction__c> payments = new List<loan__Loan_Payment_Transaction__c>();
    
    List<loan__Loan_Account__c> LAList = [SELECT ID,Name,loan__Pre_Bill_Days__c,
                                            loan__Principal_Remaining__c,
                                            loan__Principal_Paid__c,
                                            loan__Interest_Paid__c,  
                                          loan__Previous_Installment_Date__c,
                                          loan__Account__r.cnotify__Email__c,
                                          loan__Loan_Product_Name__r.name, 
                                          loan__Payment_Amount__c, 
                                          loan__Next_Installment_Date__c,
                                          loan__Interest_Rate__c,               //LSP-261
                                          loan__Pay_Off_Amount_As_Of_Today__c,  //LSP-261
                                          (select id,name,loan_Is_Migrated__c,
                                          loan__Transaction_Date__c, 
                                          loan__Transaction_Time__c,
                                          loan__Principal__c,
                                          loan__Interest__c
                                          from loan__Loan_Payment_Transactions__r 
                                          where loan__Transaction_Amount__c = 400)                                         
                                          loan__Account__r.ID,Borrowers_First_Name__c,
                                          (select id,name,loan__Due_Date__c  
                                           from loan__Dues_Details__r)
                                          loan__Account__r.Borrower_s_Last_Name__c,
                                          loan__Loan_Product_Name__c 
                                          from loan__Loan_Account__c];
    
     loan__Loan_Account__c loanAccount = LAList[0];
     payments = LAList[0].loan__Loan_Payment_Transactions__r;
     Decimal initialPayoff = LAList[0].loan__Pay_Off_Amount_As_Of_Today__c; //LSP-261   
                                          
     System.debug(logginglevel.error, 'loanAccount ::'+loanAccount + 'payments ::'+payments);
     /*LSP-261*/   
     Decimal totalAmountReversed = 0.0;
        for(loan__Loan_Payment_Transaction__c pay : payments){
            totalAmountReversed = totalAmountReversed + pay.loan__Principal__c + pay.loan__Interest__c;
        }   
     /*LSP-261*/     
     
     MigratedPaymentReversalController ctl = new MigratedPaymentReversalController(new ApexPages.StandardController (loanAccount));     
     ctl.currentRecordId = loanAccount.Id;
     ctl.NumOfPayments = String.valueof(1);
     ctl.migratedLoan = loanAccount;     
     ctl.getPayments();
     ctl.paymentsToBeReversed = payments;     
     Test.startTest();  //LSP-261   
     ctl.reversePayments();
     /*LSP-261*/   
     List<Repayment_Txn_Reversal_Migrated_Payment__c> rev = [select id from Repayment_Txn_Reversal_Migrated_Payment__c
                                                            where Loan_Payment_Transaction__c in: payments];   
     System.assertEquals(rev.size(), payments.size());
     loan__loan_account__c contract = [select id,loan__Pay_Off_Amount_As_Of_Today__c from loan__loan_account__c
                                            where id =: LAList[0].id];
     System.assertEquals(initialPayoff + totalAmountReversed, contract.loan__Pay_Off_Amount_As_Of_Today__c);   
     Test.stopTest();
     /*LSP-261*/      
        
    }
    
}