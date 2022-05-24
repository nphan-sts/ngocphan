/* ****************Modification History******************
 * Last Modified by     Date          JIRA number
 * 1. Shakul         2022/04/19     LSP-693 (Added test methods for interest remaining total)
 ******************Modification History******************/
@isTest
private class MW_LoanAccountTest {
    @testSetup 
    static void setup(){
        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();

        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
        
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);                                    
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
        org.loan__Disable_Triggers__c = true;
        upsert org;  
        
        genesis__Org_Parameters__c genorg = genesis__Org_Parameters__c.getOrgDefaults();
        genorg.genesis__Disable_Triggers__c = true;
        upsert genorg;
        
        LoanPaymentDays__c lpdays = MW_GlobalTestUtility.GetLoanPaymentDays();
        insert lpdays;
        
        loan__Loan_Product__c loanProdObj = MW_GlobalTestUtility.GetLoanProduct(); 
        insert loanProdObj;
        
        genesis__Company__c comp = genesis.TestHelper.createCompany(); 
        comp.Name = 'payoff';
        update comp;        
        
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        
        clcommon__CL_Product__c pr = new clcommon__CL_Product__c();
        pr.loan__Lending_Product__c = dummyLp.id;
        pr.clcommon__Product_Name__c = 'P1';
        insert pr;
        
        List<Account> listAcc = new List<Account>();
        Account account_Obj = new Account(
            peer__First_Name__c = 'TestFName',
            peer__Last_Name__c='TestLName',
            loan__Investor__c= false,
            cnotify__Email__c = 'no-reply@testorganization.com'
        );
        listAcc.add(account_Obj);
        
        Account acc = MW_GlobalTestUtility.GetAccount('Member');
        listAcc.add(acc);
        insert listAcc;
        
        Contact a1 = MW_GlobalTestUtility.GetContact();
        insert a1;
        
        loan__Bank_Account__c ba = MW_GlobalTestUtility.GetBankAccount();
        ba.Unmasked_Bank_Account_Number__c = acc.Id;
        ba.loan__Contact__c = a1.id;
        ba.loan__Account__c = account_Obj.id;
        
        insert ba;
        
        List<loan__Payment_Mode__c> listPM = new List<loan__Payment_Mode__c>();
        loan__Payment_Mode__c pMode  =  MW_GlobalTestUtility.GetPMode();
        listPM.add(pMode);
        
        
        loan__Payment_Mode__c pMode1  =  MW_GlobalTestUtility.GetPMode1();
        listPM.add(pMode1);
        insert listPM;
        
        genesis__applications__c objApp = MW_GlobalTestUtility.GetApplication();
        objApp.genesis__Account__c = account_Obj.Id;
        objApp.genesis__Company__c = comp.id;
        objApp.genesis__CL_Product__c = pr.id;
        objApp.bank_account__c = ba.id;
        insert objApp;
        
        Date systemDate = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
        loan__Loan_Account__c lacc = MW_GlobalTestUtility.GetCLContract();
        lacc.loan__Account__c= acc.Id;
        lacc.loan__Contact__c= a1.ID;
        lacc.loan__Loan_Product_Name__c=dummyLP.Id;
        lacc.application__c = objApp.id;
        lacc.loan__Product_Type__c = 'Flexible Amz Loan';
        lacc.loan__Draw_Billing_Method__c = 'Interest Only';
        lacc.loan__Loan_Status__c = 'Active - Good Standing';
        lacc.loan__Last_Accrual_Date__c = systemDate;
        lacc.loan__Interest_Remaining__c = 200;
        lacc.loan__Interest_Accrued_Not_Due__c = 275;
        insert lacc;
        
    }
    
    /*Created By: Shakul Siddharth
      Purpose: To test Bank Account's loan active flag*/
    static testmethod void updateLoanAcc(){
        Test.startTest();
        loan__loan_account__c loanAcc = [Select id,name,
                                         loan__Loan_Status__c
                                         from loan__loan_account__c where lead_guid__C = 'TestClassGuid0'];
        
        try{
            loanAcc.loan__Loan_Status__c = 'Closed - obligations met';
            update loanAcc;
        }
        catch(exception e) {
            System.debug('****** Exception Caught :   '+e.getMessage());
            
        }
        
        Test.stopTest();
        loan__Bank_Account__c testBA = [SELECT id, loan__Active__c FROM loan__Bank_Account__c LIMIT 1];
        System.assertEquals(false, testBA.loan__Active__c);
    }

    /*Created By: Shakul Siddharth
      Purpose: To test Interest Remaining Total when LAD is updated*/
    static testMethod void testIntRemTotalLADChange(){
        Test.startTest();
        Date systemDateTest = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
        loan__Loan_Account__c lacc = [SELECT id, loan__Last_Accrual_Date__c, loan__Interest_Remaining__c FROM loan__Loan_Account__c LIMIT 1];
        lacc.loan__Last_Accrual_Date__c = systemDateTest.addDays(9);
        lacc.loan__Interest_Remaining__c = 0;
        lacc.Interest_Remaining_Total__c = 275;
        update lacc;
        Test.stopTest();
        loan__Loan_Account__c laccTest = [SELECT id, Interest_Remaining_Total__c FROM loan__Loan_Account__c WHERE Id =:lacc.Id];
        System.assertEquals(550, laccTest.Interest_Remaining_Total__c);
    }

    /*Created By: Shakul Siddharth
      Purpose: To test Interest Remaining Total when billed amount is paid*/
    static testMethod void testIntRemTotalWithoutLADChange(){
        Test.startTest();
        loan__Loan_Account__c lacc = [SELECT id, loan__Last_Accrual_Date__c, loan__Interest_Remaining__c FROM loan__Loan_Account__c LIMIT 1];
        lacc.loan__Interest_Remaining__c = 400;
        update lacc;
        Test.stopTest();
        loan__Loan_Account__c laccTest = [SELECT id, Interest_Remaining_Total__c FROM loan__Loan_Account__c WHERE Id =:lacc.Id];
        System.assertEquals(400, laccTest.Interest_Remaining_Total__c);
    }
}