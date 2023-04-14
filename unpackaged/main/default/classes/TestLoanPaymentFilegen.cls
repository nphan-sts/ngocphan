/* ****************Modification History******************
 * Modified By        Date          JIRA number
 *1. Galla        2020/04/21     CRM-467
 *Inserted Account
 *Updated loan Account value and loan Routing Number with 9 digits to loan Bank Account
Bhavya: updated the last name field for Account : 07/02/2022
 ******************Modification History******************/
@isTest
public class TestLoanPaymentFilegen {
    
    testMethod static void testLoanPaymentFilegenJobNACHA(){
        
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn(); 
        
        List<filegen__File_Metadata__c> metadata = Test.loadData(filegen__File_Metadata__c.sObjectType,'CustomTestMetaData');
        loan.TestHelper.setupACHParameters();
        loan.TestHelper2.createFileGenMetaData();
        //loan.TestHelper2.createOrgBankAccounts();
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Account_External_ID__c = 'Test';
        acc.peer__Last_Name__c = 'TestFName1';
        insert acc;
        // Updated loan Account value and loan Routing Number with 9 digits to loan Bank Account
        loan__Bank_Account__c collectionTrustBA = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
                                                 loan__Bank_Name__c = 'Some Bank',
                                                 loan__Routing_Number__c = '999999999',
                                                 loan__Account_Type__c = 'Checking',
                                                 loan__Account_Usage__c = 'Collections Trust Account',
                                                 //loan__Contact__c = con.id,
                                                 Unmasked_Bank_Account_Number__c = '123234324',
                                                 loan__Active__c = True,loan__Account__c = acc.id);
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
        
        loan__Bank_Account__c bank = [select id,loan__Active__c from loan__Bank_Account__c where loan__Account_usage__c=:loan.FractionalizationConstants.COLLECTIONS_TRUST_ACCOUNT limit 1];
        bank.loan__Active__c=true;
        update bank;
        
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
        
        Contact a1 = new Contact(LastName='TestACH');
        insert a1;
       // Updated loan Account value and loan Routing Number with 9 digits to loan Bank Account
        loan__Bank_Account__c ba = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
                                                 loan__Bank_Name__c = 'Some Bank',
                                                 loan__Routing_Number__c = '999999999',
                                                 loan__Account_Type__c = 'Checking',
                                                 Unmasked_Bank_Account_Number__c = '123234324',loan__Active__c=true,
                                                 loan__Contact__c = a1.id,loan__Account__c = acc.id);
        insert ba;
        
        Test.startTest();
        //Updated loan Loan Account
        loan__Loan_Account__c dummylaMonthly = loan.TestHelper.createLoanAccountForContactObj(dummyLP,
                                        a1,
                                        dummyFeeSet,
                                        dummyLoanPurpose,
                                        dummyOffice);
        
        dummylaMonthly.loan__Account__c = acc.Id;
        dummylaMonthly.loan__Loan_Status__c = 'Active - Good Standing';
        dummylaMonthly.loan__ACH_On__c=True;
        
        update dummylaMonthly;
        
                                        
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
        
      
        loan.LoanPaymentFilegenJob lpJob = new loan.LoanPaymentFilegenJob(false);
        Database.executeBatch(lpJob, 200);
        Test.stopTest();
        system.assertEquals([select Id from loan__Loan_Payment_Transaction__c].size(),1);
        //system.assertEquals([select Id from Document].size(),1);
    }
}