/* ****************Modification History******************
*    Created By        	 Date			Version
*1. Bhavya Maliwal        2022/02/23     Initial Version

******************Modification History******************/
@isTest
public class TestCustomAutomatedPaymentSetupTrigger {
     /*Created By : Bhavya Maliwal
Method name : customAutomatedPaymentSetupTriggerInsert
Purpose : to cover code satisfying CustomAutomatedPaymentSetupTrigger before Insert case
*/ 
    Testmethod static void customAutomatedPaymentSetupTriggerInsert(){
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
        org.loan__Disable_Triggers__c = false;
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
        Account acc1 = new Account(
            Name = 'Test',
            loan__Investor__c = True,
            peer__Last_Name__c='TestLName2',
            Is_Funding_Partner__c = True,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123123123'
        );
        insert acc1;
        
        //Creating Account
        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c = False,
            loan__Collect_Service_Fees_on__c = 'Principal',
            Funding_Partner__c = acc1.id,
            peer__Last_Name__c='TestLName2',
            loan__Service_Rate_On_Investment__c =12.45,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123111123'
        );
        insert acc;
        
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
        Date systemDate =  new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
        
        loan__Bank_Account__c bnk1 = new loan__Bank_Account__c();
        bnk1.loan__Account__c = acc1.id;
        bnk1.loan__Bank_Name__c = 'TestBank';
        bnk1.Unmasked_Bank_Account_Number__c ='1244536753735';
        bnk1.loan__Active__c = true;
        bnk1.loan__Routing_Number__c='123456789';
        bnk1.loan__Account_Type__c = 'Savings';
        insert bnk1;
        //
        loan__Payment_Mode__c pm1 = new loan__Payment_Mode__c();
        pm1.name = 'ACH';
        insert pm1;
        
        loan__Automated_Payment_Configuration__c apc1 = new loan__Automated_Payment_Configuration__c();
        apc1.loan__Payment_Mode__c = pm1.id;
        apc1.loan__Bank_Account__c = bnk1.id;
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
            Investor__c=acc1.id,
            Loan_Origination_Date__c = systemDate.adddays(10),
            genesis__Account__c = acc.Id,
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
            loan__Account__c= acc.Id,
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
        bnk.loan__Account__c = acc.id;
        bnk.loan__Bank_Name__c = 'TestBank';
        bnk.Unmasked_Bank_Account_Number__c ='12344536753735';
        bnk.loan__Active__c = true;
        bnk.loan__Routing_Number__c='123456780';
        bnk.loan__Account_Type__c = 'Savings';
        insert bnk;
        //
        loan__Payment_Mode__c pm = new loan__Payment_Mode__c();
        pm.name = 'cash';
        insert pm;
        
        loan__Automated_Payment_Configuration__c apc = new loan__Automated_Payment_Configuration__c();
        apc.loan__Payment_Mode__c = pm.id;
        apc.loan__Bank_Account__c = bnk.id;
        apc.loan__Filegen_Class__c = 'Test';
        apc.loan__Folder_Name__c = 'TestFolder';
        insert apc;
        
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
        loan__Automated_Payment_Setup__c laps=[Select id from loan__Automated_Payment_Setup__c where loan__Recurring_ACH_Start_Date__c=:aps.loan__Debit_Date__c LIMIT 1];
        system.assertEquals(TRUE, laps!=null);
    }
    
}