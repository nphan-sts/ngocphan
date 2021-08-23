@isTest
public class Test_CLS_ProcessCPDJob {
    
    @testSetup
    public static void testSetupData() {
        loan__Org_Parameters__c loanParam = new loan__Org_Parameters__c(loan__Disable_Triggers__c = true);
        insert loanParam;
        
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


        Account acc = new Account(Name = 'SF');
        insert acc;
        

        loan__Payment_Mode__c paymentMode = new loan__Payment_Mode__c(name='ACH');
        insert paymentMode;
        
        
        //Create a dummy Loan Account
        loan__Loan_Account__c loanAccount = loan.TestHelper.createLoanAccountForAccountObj(dummyLP,
                                                    acc,
                                                    dummyFeeSet,
                                                    dummyLoanPurpose,
                                                    dummyOffice);
       
    } 
    
    @isTest
    static void testMehod1(){
               
        //Create a dummy Loan Account
        loan__Loan_Account__c loanAccount = [SELECT ID FROM loan__Loan_Account__c LIMIT 1];
        

        Date systemDate = TestHelper.getCurrentSystemDate();
        
        loanAccount.loan__Loan_Status__c = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        loanAccount.loan__Contact__c = null;
        loanAccount.lead_Guid__c = 'qwertt';
        loanAccount.loan__Last_Installment_Date__c = systemDate;
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
        loanAccount.CPD_Unpaid_Due_Date__c = systemdate.addDays(-1);    //pallavi
        update loanAccount;
        
        loan__Org_Parameters__c loanParam = loan__Org_Parameters__c.getOrgDefaults();
        loanParam.loan__Disable_Triggers__c = false;
        update loanParam;
        
        Test.startTest();
        CLS_ProcessCPDJob dm = new CLS_ProcessCPDJob(); //pallavi
        Database.executeBatch(dm);
        Test.stopTest();
    }
    //pallavi
     @isTest
    static void testMehod2(){
       
        //Create a dummy Loan Account
        loan__Loan_Account__c loanAccount = [SELECT ID FROM loan__Loan_Account__c LIMIT 1];
        

        Date systemDate = TestHelper.getCurrentSystemDate();
        
        loanAccount.loan__Loan_Status__c = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        loanAccount.loan__Contact__c = null;
        loanAccount.lead_Guid__c = 'qwertt';
        loanAccount.loan__Last_Installment_Date__c = null;
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
        
        loan__Org_Parameters__c loanParam = loan__Org_Parameters__c.getOrgDefaults();
        loanParam.loan__Disable_Triggers__c = false;
        update loanParam;
        
        Test.startTest();
        List<String> contract = new List<String>();
        contract.add(loanAccount.id);
        CLS_ProcessCPDJob dm = new CLS_ProcessCPDJob(contract);
        Database.executeBatch(dm);
        Test.stopTest();
    }

}