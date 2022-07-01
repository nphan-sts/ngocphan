/*  Test class covering CustomAutomatedPaymentSetupTrigger  and apsTriggerHandler 
/* ****************Modification History*****************************************************************
* Last modified by      Date            JIRA ticket number
* Mohan Kiran        06/07/2022          LSP-473
******************Modification History*****************************************************************
******************************************************************************/
@isTest
public class TestCustomAutomatedPaymentSetupTrigger {
    
    Testmethod static void recurringapsValidation(){
        
        String accountBorrowerName = 'Borrower/Investor Account';
        
        loan__Org_Parameters__c loanorg = loan.CustomSettingsUtil.getOrgParameters();
        loanorg.Manual_Payer_Lending_product_name__c = 'Manual Payer';
        loanorg.Auto_Payer_Lending_Product_Name__c = 'Auto Payer';
        upsert loanorg;
        
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
        
        loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
        org.loan__Disable_Triggers__c = true;
        upsert org;  
        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP1 = loan.TestHelper.createLoanProduct(dummyOffice,
                                                                           dummyAccount, 
                                                                           curr, 
                                                                           dummyFeeSet);
        dummyLP1.name = 'Auto Payer';
        dummyLP1.loan__Minimum_Amount_Due_Type__c = 'Percent';
        dummyLP1.loan__Pre_Bill_Days__c = 5;
        upsert dummyLP1;
        
        ///CL Product...........
        clcommon__CL_Product__c dummyCLPRoduct = new clcommon__CL_Product__c();
        dummyCLPRoduct.clcommon__Product_Name__c = 'Auto Payer';            
        dummyCLPRoduct.loan__Lending_Product__c = dummyLP1.id;
        
        insert dummyCLPRoduct;
        
        //Creating Account
        Account investorAccount = new Account(
            Name = 'TestInvestorAccount',
            loan__Investor__c = True,
            Is_Funding_Partner__c = True,
            cnotify__Email__c = 'acc1Test@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123456789',
            peer__First_Name__c = 'Investor First Name',
            peer__Last_Name__c = 'Investor  Last Name'
        );
        insert investorAccount;
        
        //Creating Account
        Account noninvestorAccount = new Account(
            Name = 'TestNonInvestorAccount',
            loan__Investor__c = False,
            loan__Collect_Service_Fees_on__c = 'Principal',
            Funding_Partner__c = investorAccount.id,
            loan__Service_Rate_On_Investment__c =12.45,
            cnotify__Email__c = 'accTest@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123456788',
            peer__First_Name__c = 'Noninvestor First Name',
            peer__Last_Name__c = 'Noninvestor Last Name'
        );
        insert noninvestorAccount;
        
        System.assertEquals('TestNonInvestorAccount',noninvestorAccount.Name,'Wrong Account');
        
        Date systemDate =  new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
        
        loan__Bank_Account__c savingsBankAccount = new loan__Bank_Account__c();
        savingsBankAccount.loan__Account__c = investorAccount.id;
        savingsBankAccount.loan__Bank_Name__c = 'TestBank';
        savingsBankAccount.Unmasked_Bank_Account_Number__c ='1244536753735';
        savingsBankAccount.loan__Active__c = true;
        savingsBankAccount.loan__Account_Type__c = 'Savings';
        savingsBankAccount.loan__Account_Usage__c = accountBorrowerName ;
        savingsBankAccount.loan__Routing_Number__c = '123456789';
        
        insert savingsBankAccount;
        
        loan__Payment_Mode__c ach_PaymentMode = new loan__Payment_Mode__c();
        ach_PaymentMode.name = 'ACH';
        insert ach_PaymentMode;
        
        loan__Automated_Payment_Configuration__c apc1 = new loan__Automated_Payment_Configuration__c();
        apc1.loan__Payment_Mode__c = ach_PaymentMode.id;
        apc1.loan__Bank_Account__c = savingsBankAccount.id;
        apc1.loan__Filegen_Class__c = 'Test';
        apc1.loan__Folder_Name__c = 'TestFolder';
        insert apc1;
        
        //Creating Application
        genesis__Applications__c app= new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Payment_Frequency__c ='Monthly',
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Loan_Amount__c = 12000,
            genesis__Interest_Rate__c = 12,
            genesis__Monthly_Debt_Payments__c = 100,
            genesis__CL_Product__c = dummyCLPRoduct.id,
            Borrower_s_Email__c = null,
            Investor__c=investorAccount.id,
            Loan_Origination_Date__c = systemDate.adddays(10),
            genesis__Account__c = noninvestorAccount.Id,
            Anniversary_Date__c = systemDate.adddays(20),
            genesis__Expected_Close_Date__c =Date.newInstance(2017,10,11),
            Application_Start_DateV2__c = system.Today(),
            DocuSignFlag__c=true,
            genesis__Status__c = 'Approved for Funding',
            genesis__Draw_Period_End_Date__c = system.Today()
        );
        insert app;
        
        peer__Note_Type__c nt = new peer__Note_Type__c();
        insert nt;
        
        LoanPaymentDays__c lpdays = new LoanPaymentDays__c();
        lpdays.AutoPaymentRemainder__c= 3;
        lpdays.ManualPaymentRemainder__c= 5;
        insert lpdays;
        
        loan__Loan_Product__c loanProdObj = new loan__Loan_Product__c(name='TestProduct'); 
        insert loanProdObj;
        System.assertEquals('TestProduct', loanProdObj.Name,'Wrong Loan Product');
        
        loan__Loan_Account__c lacc = new loan__Loan_Account__c(
            loan__Account__c= noninvestorAccount.Id,
            loan__Product_Type__c='Flexible Amz Loan',
            loan__Loan_Amount__c =1000,
            loan__Loan_Product_Name__c=loanProdObj.Id,
            loan__Payment_Amount__c=100, 
            loan__Next_Installment_Date__c=system.today(), 
            loan__Previous_Installment_Date__c= system.today()
        );
        insert lacc; 
        SObject lacobj = lacc;
        //insert lacobj;
        loan__Bank_Account__c bnk = new loan__Bank_Account__c();
        bnk.loan__Account__c = noninvestorAccount.id;
        bnk.loan__Bank_Name__c = 'TestBank';
        bnk.Unmasked_Bank_Account_Number__c ='12344536753735';
        bnk.loan__Active__c = true;
        bnk.loan__Account_Type__c = 'Savings';
        bnk.loan__Account_Usage__c = accountBorrowerName ;
        bnk.loan__Routing_Number__c = '123456978';
        insert bnk;
        
        loan__Payment_Mode__c pm = new loan__Payment_Mode__c();
        pm.name = 'cash';
        insert pm;
        
        loan__Automated_Payment_Configuration__c apc = new loan__Automated_Payment_Configuration__c();
        apc.loan__Payment_Mode__c = pm.id;
        apc.loan__Bank_Account__c = bnk.id;
        apc.loan__Filegen_Class__c = 'Test';
        apc.loan__Folder_Name__c = 'TestFolder';
        insert apc;
        
        org.loan__Disable_Triggers__c = false;
        upsert org;
        
        loan__Automated_Payment_Setup__c aps = new loan__Automated_Payment_Setup__c();
        aps.loan__Type__c = 'RECURRING';
        aps.loan__Amount_Type__c= loan.LoanConstants.FIXED_AMOUNT;
        //aps.loan__Transaction_Amount__c=loanApplication.genesis__Payment_Amount__c; No need to set transaction because 
        aps.loan__CL_Contract__c=lacc.Id;
        aps.loan__Payment_Mode__c = apc.loan__Payment_Mode__c;
        aps.loan__Active__c = true;                
        aps.loan__Bank_Account__c = bnk.ID;
        aps.loan__Debit_Date__c = system.Today();
        aps.loan__Frequency__c = 'Monthly';
        aps.loan__Setup_Date__c=system.Today();
        aps.loan__Installment_Payment__c = false;
        aps.loan__Recurring_ACH_Start_Date__c = aps.loan__Debit_Date__c;
        aps.loan__Retry__c = 'Disabled'; 
        
        insert aps; 
        
        loan__Automated_Payment_Setup__c aps1 = new loan__Automated_Payment_Setup__c();
        aps1.loan__Type__c = 'ONE-TIME';
        aps1.loan__Amount_Type__c= loan.LoanConstants.CURRENT_PAYMENT_AMOUNT;
        //aps.loan__Transaction_Amount__c=loanApplication.genesis__Payment_Amount__c; No need to set transaction because 
        aps1.loan__CL_Contract__c=lacc.Id;
        aps1.loan__Payment_Mode__c = apc.loan__Payment_Mode__c;
        aps1.loan__Active__c = true;                
        aps1.loan__Bank_Account__c = bnk.ID;
        aps1.loan__Debit_Date__c = system.Today();
        aps1.loan__Setup_Date__c=system.Today();
        aps1.loan__Installment_Payment__c = false;
        aps1.loan__Recurring_ACH_Start_Date__c = aps.loan__Debit_Date__c;
        aps1.loan__Retry__c = 'Disabled';
        
        Test.startTest();
        insert aps1; 
        Test.stopTest();
    }
    
    Testmethod static void investorAccountTest(){
        
        String accountBorrowerName = 'Borrower/Investor Account';
        String paymentModeAcu = 'Acu Ach';
        
        loan__Org_Parameters__c loanorg = loan.CustomSettingsUtil.getOrgParameters();
        loanorg.Manual_Payer_Lending_product_name__c = 'Manual Payer';
        loanorg.Auto_Payer_Lending_Product_Name__c = 'Auto Payer';
        upsert loanorg;
        
        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);                                    
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
        org.loan__Disable_Triggers__c = true;
        upsert org;  
        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP1 = loan.TestHelper.createLoanProduct(dummyOffice,
                                                                           dummyAccount, 
                                                                           curr, 
                                                                           dummyFeeSet);
        dummyLP1.name = 'Auto Payer';
        dummyLP1.loan__Minimum_Amount_Due_Type__c = 'Percent';
        dummyLP1.loan__Pre_Bill_Days__c = 5;
        upsert dummyLP1;
        
        ///CL Product...........
        clcommon__CL_Product__c dummyCLPRoduct = new clcommon__CL_Product__c();
        dummyCLPRoduct.clcommon__Product_Name__c = 'Auto Payer';            
        dummyCLPRoduct.loan__Lending_Product__c = dummyLP1.id;
        
        insert dummyCLPRoduct;
        
        //Creating investor Account
        Account investorAccount = new Account(
            Name = 'TestInvestorAcc',
            loan__Investor__c = True,
            Investor_Code__c = paymentModeAcu, 
            Is_Funding_Partner__c = True,
            cnotify__Email__c = 'investorAcc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123456798',
            peer__First_Name__c = 'peer First InvName',
            peer__Last_Name__c = 'peer Last InvName',
            loan__Undeployed_Funds__c = 9000
        );
        insert investorAccount;
       
        //Creating Account
        Account validationAccount = new Account(
            Name = 'paymentModeTest',
            Investor_Code__c = 'paymentModeTest', 
            loan__Investor__c = true,
            loan__Collect_Service_Fees_on__c = 'Principal',
            Funding_Partner__c = investorAccount.id,
            loan__Service_Rate_On_Investment__c =12.45,
            cnotify__Email__c = 'validationAcc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123456789',
            peer__First_Name__c = 'peer First nonInv',
            peer__Last_Name__c = 'peer Last nonInv',
            loan__Undeployed_Funds__c = 9000
            
        );
        insert validationAccount;
        
        System.assertEquals('paymentModeTest',validationAccount.Name, 'Acu Account');
        
        Date systemDate =  new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
        
        loan__Bank_Account__c savingsbankAccount = new loan__Bank_Account__c();
        savingsbankAccount.loan__Account__c = investorAccount.id;
        savingsbankAccount.loan__Bank_Name__c = 'TestSavingsBank';
        savingsbankAccount.Unmasked_Bank_Account_Number__c ='1244536753735';
        savingsbankAccount.loan__Active__c = true;
        savingsbankAccount.loan__Account_Type__c = 'Savings';
        savingsbankAccount.loan__Account_Usage__c = accountBorrowerName ;
        savingsbankAccount.loan__Routing_Number__c = '123456789';
        insert savingsbankAccount;
        system.assertEquals('TestSavingsBank',savingsbankAccount.loan__Bank_Name__c);
        
        
        loan__Payment_Mode__c paymentmodeACH = new loan__Payment_Mode__c();
        paymentmodeACH.name = 'paymentModeTest';
        insert paymentmodeACH;
        
        loan__Automated_Payment_Configuration__c savingsAPC = new loan__Automated_Payment_Configuration__c();
        savingsAPC.loan__Payment_Mode__c = paymentmodeACH.id;
        savingsAPC.loan__Bank_Account__c = savingsbankAccount.id;
        savingsAPC.loan__Filegen_Class__c = 'Test';
        savingsAPC.loan__Folder_Name__c = 'TestFolder';
        insert savingsAPC;
        
        //Creating Application
        genesis__Applications__c app= new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Payment_Frequency__c ='Monthly',
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Loan_Amount__c = 12000,
            genesis__Interest_Rate__c = 12,
            genesis__Monthly_Debt_Payments__c = 100,
            genesis__CL_Product__c = dummyCLPRoduct.id,
            Borrower_s_Email__c = null,
            Investor__c=investorAccount.id,
            Loan_Origination_Date__c = systemDate.adddays(10),
            genesis__Account__c = validationAccount.Id,
            Anniversary_Date__c = systemDate.adddays(20),
            genesis__Expected_Close_Date__c =Date.newInstance(2017,10,11),
            Application_Start_DateV2__c = system.Today(),
            DocuSignFlag__c=true,
            genesis__Status__c = 'Approved for Funding',
            genesis__Draw_Period_End_Date__c = system.Today()
        );
        insert app;
        
        peer__Note_Type__c nt = new peer__Note_Type__c();
        insert nt;
        
        LoanPaymentDays__c lpdays = new LoanPaymentDays__c();
        lpdays.AutoPaymentRemainder__c= 3;
        lpdays.ManualPaymentRemainder__c= 5;
        insert lpdays;
        
        loan__Loan_Product__c loanProdObj = new loan__Loan_Product__c(name='TestProduct'); 
        insert loanProdObj;
        System.assertEquals('TestProduct', loanProdObj.Name,'Wrong Loan Product');
        
        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c(
            loan__Account__c= validationAccount.Id,
            loan__Product_Type__c='Flexible Amz Loan',
            loan__Loan_Amount__c =1000,
            loan__Loan_Product_Name__c=loanProdObj.Id,
            loan__Payment_Amount__c=100, 
            loan__Next_Installment_Date__c=system.today(), 
            loan__Previous_Installment_Date__c= system.today()
        );
        insert loanAccount; 
        
        loan__Bank_Account__c bankAccount = new loan__Bank_Account__c();
        bankAccount.loan__Account__c = validationAccount.id;
        bankAccount.loan__Bank_Name__c = 'TestBank';
        bankAccount.Unmasked_Bank_Account_Number__c ='12344536753735';
        bankAccount.loan__Active__c = true;
        bankAccount.loan__Account_Type__c = 'Savings';
        bankAccount.loan__Account_Usage__c = accountBorrowerName;
        bankAccount.loan__Routing_Number__c = '123456978';
        
        insert bankAccount;
        
        loan__Payment_Mode__c pm = new loan__Payment_Mode__c();
        pm.name = 'paymentModeTest';
        insert pm;
        
        loan__Automated_Payment_Configuration__c apc = new loan__Automated_Payment_Configuration__c();
        apc.loan__Payment_Mode__c = pm.id;
        apc.loan__Bank_Account__c = bankAccount.id;
        apc.loan__Filegen_Class__c = 'Test';
        apc.loan__Folder_Name__c = 'TestFolder';
        insert apc;
        
        
        org.loan__Disable_Triggers__c = false;
        upsert org;
        
        //Insert IO record 
        loan__Investor_Loan__c investorLoan = new loan__Investor_Loan__c();
        investorLoan.loan__Account__c  = validationAccount.Id;
        investorLoan.loan__Loan__c = loanAccount.Id;
        investorLoan.loan__Investment_Amount__c = 90;
        investorLoan.loan__Loan_Principal_Remaining__c = 500;
        investorLoan.loan__Status__c = 'Active';
        
        insert investorLoan;
        
        loan__Automated_Payment_Setup__c apsInvestorLoan = new loan__Automated_Payment_Setup__c();
        apsInvestorLoan.loan__Type__c = 'RECURRING';
        apsInvestorLoan.loan__Amount_Type__c= loan.LoanConstants.CURRENT_PAYMENT_AMOUNT;
        apsInvestorLoan.loan__CL_Contract__c=loanAccount.Id;
        apsInvestorLoan.loan__Frequency__c = 'Monthly';
        apsInvestorLoan.loan__Payment_Mode__c = apc.loan__Payment_Mode__c;
        apsInvestorLoan.loan__Active__c = true;                
        apsInvestorLoan.loan__Bank_Account__c = bankAccount.ID;
        apsInvestorLoan.loan__Debit_Date__c = system.Today();
        apsInvestorLoan.loan__Setup_Date__c=system.Today();
        apsInvestorLoan.loan__Installment_Payment__c = false;
        apsInvestorLoan.loan__Recurring_ACH_Start_Date__c = apsInvestorLoan.loan__Debit_Date__c;
        apsInvestorLoan.loan__Retry__c = 'Disabled';
        
        Test.startTest();
        insert apsInvestorLoan;
        apsInvestorLoan.loan__Installment_Payment__c = true;
        update apsInvestorLoan;
        Test.stopTest();
    }
    
}