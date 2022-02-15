/* ****************Modification History*****************************************************************
 * 
 * Modified by              Date        JIRA number
 * 1.   Pallavi/Neha      2021/01/29  LSP-1/CRM-1056 CPD issue/Reverting issue (short-term fix) - Case #02430069 
 * 2.	Bhavya			  2022/02/09  Test class modification as per standards and covering the update case for the trigger
 ******************Modification History*****************************************************************/
@isTest
public class TestUpdateAPSTrigger {
     @testSetup
    static void setup(){
          
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn(); 
        
        List<filegen__File_Metadata__c> metadata = Test.loadData(filegen__File_Metadata__c.sObjectType,'CustomTestMetaData');
        loan.TestHelper.setupACHParameters();
        loan.TestHelper2.createFileGenMetaData();
        //loan.TestHelper2.createOrgBankAccounts();
        
        /*LSP-1*/
        Account acc = new Account(Name = 'Test Account',peer__Last_Name__c='TestLName2', loan__Undeployed_Funds__c = 10000);
        insert acc;
        /*LSP-1*/
        
        loan__Bank_Account__c collectionTrustBA = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
                                                 loan__Bank_Name__c = 'Some Bank',
                                                 loan__account__c = acc.id, //LSP-1                           
                                                 loan__Routing_Number__c = '999999999', //LSP-1
                                                 loan__Account_Type__c = 'Checking',
                                                 loan__Account_Usage__c = 'Collections Trust Account',
                                                 //loan__Contact__c = con.id,
                                                 Unmasked_Bank_Account_Number__c = '123234324',
                                                 loan__Active__c = True);
        insert collectionTrustBA ;
                
        loan__Transaction_Approval_Config__c c = loan.CustomSettingsUtil.getApprovalConfig();
        c.loan__Payment__c = false;
        upsert c;
        
        loan__ACH_Parameters__c ach = loan.CustomSettingsUtil.getACHParameters();
        ach.loan__Days_In_Advance_To_Create_File__c = 0;
        ach.loan__Multiple_Payment_Method_Support__c =true;
        upsert ach;
        
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        loan__Payment_Mode__c pMode = [select id from loan__Payment_Mode__c where Name= 'ACH'];
        loan__Payment_Mode__c pMode1 = [select id from loan__Payment_Mode__c where Name = 'Cash'];
        
        loan__Bank_Account__c bank = [select id from loan__Bank_Account__c where loan__Account_usage__c=:loan.FractionalizationConstants.COLLECTIONS_TRUST_ACCOUNT limit 1];
        
        loan.TestHelper2.createAutomatedPaymentConfiguration(loan.LoanConstants.LOAN_PAYMENT,pMode,bank,'CustomLoanPaymentTxnNACHAGen');
        loan.TestHelper2.createAutomatedPaymentConfiguration(loan.LoanConstants.LOAN_PAYMENT,pMode1,bank,'CustomLoanPaymentTxnNACHAGen');
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
                            dummyAccount, 
                            curr, 
                            dummyFeeSet);
        
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
             
        loan__Bank_Account__c ba = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
                                                 loan__Bank_Name__c = 'Some Bank',
                                                 loan__account__c = acc.id, //LSP-1            
                                                 loan__Routing_Number__c = '999999999', //LSP-1
                                                 loan__Account_Type__c = 'Checking',
                                                 Unmasked_Bank_Account_Number__c = '123234324');
        insert ba;
        
      
        loan__Loan_Account__c dummylaMonthly = loan.TestHelper.createLoanAccountForAccountObj(dummyLP,  //LSP-1
                                                    acc,
                                                    dummyFeeSet,
                                                    dummyLoanPurpose,
                                                    dummyOffice);
        
         loan__Loan_Disbursal_Transaction__c disbTxn = new loan__Loan_Disbursal_Transaction__c();
        disbTxn.loan__Disbursal_Date__c = loan.TestHelper.systemDate;
        disbTxn.loan__Disbursed_Amt__c = dummylaMonthly.loan__Loan_Amount__c;
        disbTxn.loan__Loan_Account__c = dummylaMonthly.id;
        disbTxn.loan__Mode_of_Payment__c =  pMode.id;
        
        insert disbTxn;
        disbTxn.loan__Cleared__c =true;
        update disbTxn;
        
        loan__Automated_Payment_Setup__c aPS = loan.TestHelper2.createAutomatedPaymentSetup(loan.LoanConstants.RECURRING,loan.LoanConstants.FIXED_AMOUNT,ba,dummylaMonthly,'Monthly',pMode);
        loan__Automated_Payment_Setup__c aPS1 = loan.TestHelper2.createAutomatedPaymentSetup(loan.LoanConstants.ONE_TIME,loan.LoanConstants.FIXED_AMOUNT,ba,dummylaMonthly,'Monthly',pMode1);
       
        loan__Loan_Payment_Transaction__c dummyPmt = new loan__Loan_Payment_Transaction__c();
        dummyPmt.loan__Cleared__c = false;
        dummyPmt.loan__Payment_Mode__c = pMode.id;
        dummyPmt.loan__Transaction_Amount__c  = 100;
        dummyPmt.loan__Transaction_Date__c = loan.TestHelper.systemDate;
        dummyPmt.loan__Loan_Account__c  = dummylaMonthly.id;
        dummyPmt.loan__Automated_Payment_Setup__c = aPS.id;
        insert dummyPmt;
        
         loan__Loan_Payment_Transaction__c dummyPmt2 = new loan__Loan_Payment_Transaction__c();
        dummyPmt2.loan__Cleared__c = false;
        dummyPmt2.loan__Payment_Mode__c = pMode.id;
        dummyPmt2.loan__Transaction_Amount__c  = 100;
        dummyPmt2.loan__Transaction_Date__c = loan.TestHelper.systemDate;
        dummyPmt2.loan__Loan_Account__c  = dummylaMonthly.id;
        dummyPmt2.loan__Automated_Payment_Setup__c = null;
        insert dummyPmt2;
       
    }
      /*Created By : Bhavya Maliwal
Method name : testOtherTransaction
Purpose : to cover code satisfying after and update case for other transaction (UpdateAPSTrigger)
*/
    testMethod static void testOtherTransaction(){
      test.startTest();
                                        
       loan__Loan_Account__c dummylaMonthly=[Select id from loan__Loan_Account__c LIMIT 1];
                
        loan__Other_Transaction__c otherTxn = new loan__Other_Transaction__c();
        otherTxn.loan__Transaction_Type__c = 'Reschedule';
        otherTxn.loan__new_due_day__c = 12;
        otherTxn.loan__repayment_start_date__c = Date.today();
        otherTxn.loan__Loan_Account__c = dummylaMonthly.id;
        insert otherTxn;
        
         otherTxn.loan__new_due_day__c = 15;
        update otherTxn;
        test.stopTest();
        List<loan__Other_Transaction__c> OT=[Select id,loan__new_due_day__c from loan__Other_Transaction__c];
        system.assertEquals(True, OT.size()>0);
        system.assertEquals(True, OT[0].loan__new_due_day__c==15);
    }
     /*Created By : Bhavya Maliwal
Method name : testOtherTransactionWhenLPTExists
Purpose : to cover code satisfying after case for other transaction (UpdateAPSTrigger)
*/
    testMethod static void testOtherTransactionWhenLPTExists(){
        
       test.startTest();   
         loan__Loan_Account__c dummylaMonthly=[Select id from loan__Loan_Account__c LIMIT 1];
       
        loan__Other_Transaction__c otherTxn = new loan__Other_Transaction__c();
        otherTxn.loan__Transaction_Type__c = 'Reschedule';
        otherTxn.loan__new_due_day__c = 12;
        otherTxn.loan__repayment_start_date__c = loan.TestHelper.systemDate;//Date.newInstance(2020, 01, 01);
        otherTxn.loan__Loan_Account__c = dummylaMonthly.id;
        insert otherTxn;
        test.stopTest();
        List<loan__Other_Transaction__c> OT=[Select id from loan__Other_Transaction__c];
        system.assertEquals(True, OT.size()>0);
    }
   
}