@isTest
private class TestActivateFractionalization{
    
     @testSetup static void setup() {
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
         }
     Testmethod static void method1(){
        //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=True,
            loan__Total_Invested_Amount__c = null,
            loan__Total_Principal_Remaining__c = null,
            loan__Deployed_Funds__c = null,
            loan__Undeployed_Funds__c = 12000,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123',
            no_of_shares_to_be_Sold__c = 100 
            );
        insert acc;
        
        //Creating Account
         Account acc1 = new Account(
            Name = 'TestAccount',
            loan__Investor__c=true,
            loan__Undeployed_Funds__c = 11000,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert acc1;
       /*RecordType rd = new RecordType();
       rd.Name = 'test recoprd type';
       rd.developerName ='IO_Deactivated';
       insert rd;*/ 
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
        
        loan__Loan_Product__c loanProdObj = new loan__Loan_Product__c(name='TestProduct1',
                                                    loan__Higher_Investor_Certificate_Rate_Allowed__c = true); 
        insert loanProdObj;
        System.assertEquals('TestProduct1', loanProdObj.Name,'Wrong Loan Product');
        
        
        loan__Loan_Account__c lacc = new loan__Loan_Account__c(
                                            loan__Account__c= acc1.Id,
                                            loan__Product_Type__c='line of credit',
                                            loan__Loan_Amount__c =1000,
                                            loan__Principal_Remaining__c = 1000,
                                            loan__Loan_Balance__c = 100,
                                            loan__Interest_Remaining__c = 100,
                                            loan__Last_Accrual_Date__c = loan.LoanConstants.DT_MAX,
                                            loan__Interest_rate__c = 10,
                                            loan__Active_Investor__c =true,
                                            loan__Number_of_Days_Overdue__c = 12,
                                            loan__Loan_Status__c = 'Active - Good Standing',
                                            loan__Approval_Date__c = system.today(),
                                            loan__Protect_fee_amount__c = 50,
                                            loan__Protect_Split_Charged_To_Investor__c = 5,
                                            loan__Fractionalization_Status__c = 'Active',
                                            loan__Loan_Product_Name__c=loanProdObj.Id,
                                            loan__Payment_Amount__c=100, 
                                            loan__Next_Installment_Date__c=system.today(), 
                                            loan__Previous_Installment_Date__c= system.today()
                                            );
        insert lacc; 
        
        loan__Investor_Loan__c investmentOrder = new loan__Investor_Loan__c(
                                                            loan__Investment_Amount__c = 10000,
                                                            loan__Certificate_Rate__c = 12,
                                                            loan__Enabled_Flag__c = false,
            												//loan__Summary__c = true,
                                                            loan__Service_Rate__c = 2,
                                                            loan__Share__c = 100,
                                                            loan__Investor_Start_Date__c = Date.newinstance(2015,05,09),
                                                            loan__Generate_Amortization_Schedule__c = true,
                                                            loan__Status__c = 'Sold',
                                                            loan__Principal_Amount_Paid__c = 1200,
                                                            loan__Loan_Principal_Remaining__c =100,
                                                            loan__Discount_Percent__c = null,
                                                            loan__Account__c = acc.id,
                                                            loan__Loan__c = lacc.id,
            												Buyer__c = acc1.id,
            												loan__Investor_End_Date__c = System.today()
                                                            );
        insert investmentOrder;
        //investmentOrder.loan__Enabled_Flag__c = false;
        //update investmentOrder;
        
        //loan__Loan_Account__c lacc = [select id,loan__Active_Investor__c from loan__Loan_Account__c where loan__Active_Investor__c =true Limit 1];
        //loan__Investor_Loan__c io = [select id,loan__Enabled_Flag__c from loan__Investor_Loan__c where loan__Enabled_Flag__c = true Limit 1];
        Test.StartTest();
        ActivateFractionalization obj = new ActivateFractionalization();
        obj.ActivateFractionalizationm(lacc.id);
        Test.stopTest();        
    }
    
  Testmethod static void method2(){
         //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=True,
            loan__Total_Invested_Amount__c = null,
            loan__Total_Principal_Remaining__c = null,
            loan__Deployed_Funds__c = null,
            loan__Undeployed_Funds__c = 12000,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert acc;
        
        //Creating Account
         Account acc1 = new Account(
            Name = 'TestAccount',
            loan__Investor__c=False,
            loan__Undeployed_Funds__c = 11000,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert acc1;
       /*RecordType rd = new RecordType();
       rd.Name = 'test recoprd type';
       rd.developerName ='IO_Deactivated';
       insert rd;*/ 
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
        
        loan__Loan_Product__c loanProdObj = new loan__Loan_Product__c(name='TestProduct1',
                                                    loan__Higher_Investor_Certificate_Rate_Allowed__c = true); 
        insert loanProdObj;
        System.assertEquals('TestProduct1', loanProdObj.Name,'Wrong Loan Product');
        
        
        loan__Loan_Account__c lacc = new loan__Loan_Account__c(
                                            loan__Account__c= acc1.Id,
                                            loan__Product_Type__c='line of credit',
                                            loan__Loan_Amount__c =1000,
                                            loan__Principal_Remaining__c = 1000,
                                            loan__Loan_Balance__c = 100,
                                            loan__Interest_Remaining__c = 100,
                                            loan__Last_Accrual_Date__c = loan.LoanConstants.DT_MAX,
                                            loan__Interest_rate__c = 10,
                                            loan__Active_Investor__c =true,
                                            loan__Number_of_Days_Overdue__c = 12,
                                            loan__Loan_Status__c = 'Active - Good Standing',
                                            loan__Approval_Date__c = system.today(),
                                            loan__Protect_fee_amount__c = 50,
                                            loan__Protect_Split_Charged_To_Investor__c = 5,
                                            loan__Fractionalization_Status__c = 'Active',
                                            loan__Loan_Product_Name__c=loanProdObj.Id,
                                            loan__Payment_Amount__c=100, 
                                            loan__Next_Installment_Date__c=system.today(), 
                                            loan__Previous_Installment_Date__c= system.today()
                                            );
        insert lacc; 
        
        loan__Investor_Loan__c investmentOrder = new loan__Investor_Loan__c(
                                                            loan__Investment_Amount__c = 10000,
                                                            loan__Certificate_Rate__c = 12,
                                                            loan__Enabled_Flag__c = false,
            												//loan__Summary__c = true,
                                                            loan__Service_Rate__c = 2,
                                                            loan__Share__c = 100,
                                                            //loan__Investor_Start_Date__c = Date.newinstance(2015,05,09),
                                                            loan__Generate_Amortization_Schedule__c = true,
                                                            loan__Status__c = 'Pending',
                                                            loan__Principal_Amount_Paid__c = 1200,
                                                            loan__Loan_Principal_Remaining__c =100,
                                                            loan__Discount_Percent__c = null,
                                                            loan__Account__c = acc.id,
                                                            loan__Loan__c = lacc.id            												
                                                            );
        insert investmentOrder;
        //investmentOrder.loan__Enabled_Flag__c = false;
        //update investmentOrder;
        
        //loan__Loan_Account__c lacc = [select id,loan__Active_Investor__c from loan__Loan_Account__c where loan__Active_Investor__c =true Limit 1];
        //loan__Investor_Loan__c io = [select id,loan__Enabled_Flag__c from loan__Investor_Loan__c where loan__Enabled_Flag__c = true Limit 1];
        Test.StartTest();
        ActivateFractionalization obj = new ActivateFractionalization();
        obj.ActivateFractionalizationm(lacc.id);
        Test.stopTest();
        
    }
}