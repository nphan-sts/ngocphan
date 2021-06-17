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
        
        Account account_Obj = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com'
        );
        Insert account_Obj;
        
        Account acc = MW_GlobalTestUtility.GetAccount('Member');
        insert acc;
        
        Contact a1 = MW_GlobalTestUtility.GetContact();
        insert a1;
        
        loan__Bank_Account__c ba = MW_GlobalTestUtility.GetBankAccount();
        ba.Unmasked_Bank_Account_Number__c = acc.Id;
        ba.loan__Contact__c = a1.id;
        ba.loan__Account__c = acc.id;
        
        insert ba;
        
        loan__Payment_Mode__c pMode  =  MW_GlobalTestUtility.GetPMode();
        insert pMode;
        
        
        loan__Payment_Mode__c pMode1  =  MW_GlobalTestUtility.GetPMode1();
        insert pMode1;
        
        genesis__applications__c objApp = MW_GlobalTestUtility.GetApplication();
        objApp.genesis__Account__c = account_Obj.Id;
        objApp.genesis__Company__c = comp.id;
        objApp.genesis__CL_Product__c = pr.id;
        insert objApp;
        
        
        loan__Loan_Account__c lacc = MW_GlobalTestUtility.GetCLContract();
        lacc.loan__Account__c= acc.Id;
        lacc.loan__Contact__c= a1.ID;
        lacc.loan__Loan_Product_Name__c=loanProdObj.Id;
        lacc.application__c = objApp.id;
        insert lacc;
        
    }
    
    static testmethod void updateLoanAcc(){
        test.startTest();
        loan__loan_account__c LoanAcc = [Select id,name,
                                         loan__Loan_Status__c
                                         from loan__loan_account__c where lead_guid__C = 'TestClassGuid0'];
        
        try{
            LoanAcc.loan__Loan_Status__c = 'Closed - obligations met';
            update LoanAcc;
        }
        catch(exception e) {
            System.debug('****** Exception Caught :   '+e.getMessage());
            
        }
        
        test.stopTest();
    }
}