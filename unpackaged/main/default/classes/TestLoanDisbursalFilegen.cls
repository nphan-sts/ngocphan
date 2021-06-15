@isTest
public class TestLoanDisbursalFilegen {
    
    testMethod static void testLoanDisbursalFilegenJobNACHA(){
        
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn(); // 3 day lock period
        
        List<filegen__File_Metadata__c> metadata = Test.loadData(filegen__File_Metadata__c.sObjectType,'CustomTestMetaData');
        loan.TestHelper.setupACHParameters();
        loan.TestHelper2.createFileGenMetaData();
        //loan.TestHelper2.createOrgBankAccounts();
         loan__Bank_Account__c collectionTrustBA = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
                                                 loan__Bank_Name__c = 'Some Bank',
                                                 loan__Routing_Number__c = '99999999',
                                                 loan__Account_Type__c = 'Checking',
                                                 loan__Account_Usage__c = 'Advance Trust Account',
                                                 //loan__Contact__c = con.id,
                                                 Unmasked_Bank_Account_Number__c = '123234324',
                                                 loan__Active__c = True);
        insert collectionTrustBA ;
       
        
        loan__Transaction_Approval_Config__c c = loan.CustomSettingsUtil.getApprovalConfig();
        c.loan__Payment__c = false;
        c.loan__Funding__c = false;
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
        
        loan__Bank_Account__c bank = [select id from loan__Bank_Account__c where loan__Account_usage__c=:loan.FractionalizationConstants.ADVANCE_TRUST_ACCOUNT limit 1];
        
        loan.TestHelper2.createAutomatedPaymentConfiguration(loan.LoanConstants.LOAN_DISBURSAL,pMode,bank,'CustomDisbursalDistributionTxnNACHAGen');
        loan.TestHelper2.createAutomatedPaymentConfiguration(loan.LoanConstants.LOAN_DISBURSAL,pMode1,bank,'CustomDisbursalDistributionTxnNACHAGen');
        
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
       
        loan__Bank_Account__c ba = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
                                                 loan__Bank_Name__c = 'Some Bank',
                                                 loan__Routing_Number__c = '99999999',
                                                 Unmasked_Bank_Account_Number__c = '99999999',
                                                 loan__Account_Type__c = 'Checking',
                                                 loan__Contact__c = a1.id);
        insert ba;
        
        Test.startTest();
        loan__Loan_Account__c dummylaMonthly = loan.TestHelper.createLoanAccountForContactObj(dummyLP,
                                        a1,
                                        dummyFeeSet,
                                        dummyLoanPurpose,
                                        dummyOffice);
        dummylaMonthly.loan__Accrual_Start_Date__c  = loan.TestHelper.systemDate;
        update dummylaMonthly;
        
        loan__Loan_Disbursal_Transaction__c disbTxn = new loan__Loan_Disbursal_Transaction__c();
        disbTxn.loan__Disbursal_Date__c = loan.TestHelper.systemDate;
        disbTxn.loan__Disbursed_Amt__c = dummylaMonthly.loan__Loan_Amount__c;
        disbTxn.loan__Loan_Account__c = dummylaMonthly.id;
        disbTxn.loan__Bank_Account__c = ba.Id;
        disbTxn.loan__Mode_of_Payment__c =  pMode.id;
        
        loan.LoandisbursalActionAPI api = new loan.LoanDisbursalActionAPI(disbTxn);
        api.disburseLoanAccount();
        
        loan.DisbursalDistributionFilegenJob lpJob = new loan.DisbursalDistributionFilegenJob(false);
        Database.executeBatch(lpJob, 200);
        Test.stopTest();
        
    }
    
}