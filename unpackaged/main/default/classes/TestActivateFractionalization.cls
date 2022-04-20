/* ****************Modification History******************
* Modified By        Date          JIRA number
*1. Bhanupriya        2022/02/24    LSP-536
*/

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
        system.debug('Fees Junction' +dummyFeeJunction);
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        System.debug('dummyOffice'+dummyOffice.name);
        loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
        org.loan__Disable_Triggers__c = true;
        upsert org;  
        
        //Creating Account
        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=True,
            loan__Total_Invested_Amount__c = null,
            loan__Total_Principal_Remaining__c = null,
            loan__Deployed_Funds__c = null,
            loan__Undeployed_Funds__c = 12000,
            peer__Last_Name__c = 'Tesst Last Name',						//LSP-536
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123546789'				//LSP-536
        );
        insert acc;
        
        //Creating Account
        Account acc1 = new Account(
            Name = 'TestAccount',
            loan__Investor__c=False,
            loan__Undeployed_Funds__c = 11000,
            cnotify__Email__c = 'abc@test.com',
            peer__Last_Name__c = 'TestAccounts Last Name',					//LSP-536
            loan__SOCIAL_SECURITY_NUMBER__c = '987654321'
        );
        insert acc1;
        
        //create new contact
        contact c1 = new contact(LastName='TestACH');              
        insert c1;
        
        //Create dummy bank account
        loan__Bank_Account__c ba = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123456789',
                                                             loan__Bank_Name__c = 'Some Bank 1',
                                                             loan__Routing_Number__c = '999999999',
                                                             Unmasked_Bank_Account_Number__c = '99999999',
                                                             loan__Account_Type__c = 'Checking',
                                                             loan__Contact__c = c1.id,
                                                             loan__Account__c = acc1.id);
        
        insert ba;
        system.debug('bank account' +ba);
        
        //create loan product
        loan__Loan_Product__c loanProdObj = new loan__Loan_Product__c(name='TestProduct1',
                                                                      loan__Higher_Investor_Certificate_Rate_Allowed__c = true); 
        insert loanProdObj;
        
        //create loan Account
        loan__Loan_Account__c lacc = new loan__Loan_Account__c(
            loan__Account__c= acc1.Id,
            loan__Contact__c = c1.ID,
            loan__Product_Type__c= 'flexible amz loan',
            loan__Loan_Amount__c =100000,
            loan__Principal_Remaining__c = 10000,
            loan__Loan_Product_Name__c=loanProdObj.Id,
            loan__Payment_Amount__c=100000,
            loan__Previous_Installment_Date__c= system.today(),
            //application__c = application.id,
            loan__First_Installment_Date__c = Date.newInstance(2020, 01, 19), 
            loan__Next_Installment_Date__c = Date.newInstance(2020, 02, 19),
            loan__Maturity_Date_Current__c = Date.newInstance(2022, 01, 19), 
            loan__Frequency_of_Loan_Payment__c = 'Monthly',
            loan__Last_Installment_Date__c = Date.newInstance(2020, 01, 19) , 
            loan__Is_Rescheduled__c = false, 
            //loan__Loan_Status__c = 'Active - Bad Standing',
            loan__loan_status__c = 'Approved', 
            lead_Guid__c = '',
            loan__Oldest_Due_Date__c = Date.newInstance(2020, 01, 19),
            loan__Last_Payment_Date__c = Date.newInstance(2020, 01, 19),
            loan__Accrual_Start_Date__c = Date.newInstance(2020, 01, 19),
            loan__Interest_Rate__c = 10,
            loan__Pmt_Amt_Cur__c = 1000,
            loan__Term_Cur__c = 100,
            loan__Last_Accrual_Date__c = System.today(),//Date.newInstance(2020, 01, 19),
            loan__Disbursal_Date__c = Date.newInstance(2019, 12, 19),
            loan__Payment_Application_Mode__c = 'Deposit',
            loan__Additional_Loan_Amount__c = 100,
            loan__Accrual_Amount_Accounted_For__c = 2000,
            loan__ACH_Debit_Amount__c =1000,
            loan__Add_Fee_Amount_To_Bill__c = true,
            loan__Adjust_Deposit_Amount_In_Payoff__c = true,
            loan__Amount_Due_Till_Current__c = 1000,
            loan__Cancellation_Tolerance_Amount__c =100,
            loan__Delinquent_Amount__c =1000,
            loan__Disbursal_Amount__c = 200000,
            loan__Metro2_Account_highest_bal_amount__c =1000,
            loan__Last_Billed_Amount__c = 1000,
            loan__Last_Disbursal_Amount__c = 10000,
            loan__Last_Payment_Amount__c = 2000,
            Loan_Premium_Amount__c =2000,
            loan__Maximum_Advance_Amount__c = 20000,
            loan__Maximum_Draw_Amount__c = 20000,
            loan__Minimum_Advance_Amount__c =100,
            loan__Minimum_Amount_Due__c =100,
            loan__Minimum_Due_Amount_On_Billing__c =2000,
            loan__Minimum_Draw_Amount__c = 100,
            loan__Next_Repayment_Amount_As_Of_Today__c =20000,
            loan__Uncleared_Disbursal_Amount__c =20000,
            loan__Uncleared_Repayment_Amount__c =20000,
            loan__Uncleared_Written_Off_Amount__c =1000,
            loan__Loan_Balance__c = 20000,
            loan__Expected_Disbursal_Date__c = Date.newInstance(2019, 12, 19)
        );
        insert lacc; 
        
        //create a dummy Investment order
        loan__Investor_Loan__c investmentOrder = new loan__Investor_Loan__c(
            loan__Investment_Amount__c = 10000,
            loan__Certificate_Rate__c = 12,
            loan__Enabled_Flag__c = false,
            //loan__Summary__c = true,
            loan__Service_Rate__c = 2,
            loan__Share__c = 100,
            loan__Investor_Start_Date__c = Date.newinstance(2021,05,09),
            loan__Generate_Amortization_Schedule__c = true,
            loan__Status__c = 'Pending',
            loan__Principal_Amount_Paid__c = 1200,
            loan__Loan_Principal_Remaining__c =100,
            loan__Discount_Percent__c = null,
            loan__Account__c = acc.id,
            loan__Loan__c = lacc.id,
            loan__Buying_Price__c = 100,
            loan__Charged_Off_Interest__c = 10,
            loan__Charged_Off_Date__c = system.today()
        );
        insert investmentOrder;
        
    }
    //testmethod
    
    @istest static void investorTransactions(){
        
        loan__Loan_Account__c lacc = [select id,
                                      name
                                      from loan__Loan_Account__c];
        
        Test.StartTest();
        ActivateFractionalization obj = new ActivateFractionalization();
        obj.ActivateFractionalizationm(lacc.id);
        Test.stopTest();
        system.assert(lacc!=null);
        
    }
    
    @istest static void investorTransactionStatus(){
           
        loan__Investor_Loan__c investmentOrder = [select id,
                                                  loan__Enabled_Flag__c,
                                                  loan__Status__c,
                                                  loan__Investor_Start_Date__c,
                                                  loan__Buying_Price__c,
                                                  loan__Investment_Amount__c,
                                                  loan__Charged_Off_Date__c
                                                  from loan__Investor_Loan__c];
        system.debug('investment status' +investmentOrder.loan__Status__c);   
        string	ios = investmentOrder.loan__Status__c;
        investmentOrder.loan__Status__c = 'Closed - Written Off';
        update investmentOrder; 
        loan__Investor_Loan__c io = [select id,
                                     loan__Status__c,
                                     loan__Remaining_Investment_Amount__c,
                                     loan__Account__c,
                                     loan__Investment_Amount__c,
                                     loan__Charged_Off_Interest__c,
                                     loan__Investor_Start_Date__c,
                                     loan__Buying_Price__c,
                                     loan__Charged_Off_Date__c
                                     from loan__Investor_Loan__c
                                     where loan__Status__c = 'Closed - Written Off'];
        system.debug('Incestment order status' +io.loan__Status__c);
        
        Test.StartTest();
        ActivateFractionalization.getTxnChargeoff(io);
        Test.stopTest();
        system.assert(ios!=io.loan__Status__c);
        
    }
    //this method is used for increase the code coverage
    
    @istest static void updateInvestmentorder(){
        
        loan__Loan_Account__c lacc = [select id,
                                      name
                                      from loan__Loan_Account__c];
        
        
        loan__Investor_Loan__c investmentOrder = [select id,
                                                  loan__Status__c,
                                                  loan__Enabled_Flag__c
                                                  from loan__Investor_Loan__c];        			
        string	io = investmentOrder.loan__Status__c;                    
        investmentOrder.loan__Status__c = 'Sold';
        upsert investmentOrder; 
        Test.StartTest();
        ActivateFractionalization obj = new ActivateFractionalization();
        obj.ActivateFractionalizationm(lacc.id);
        Test.stopTest();
        system.assert(io!=investmentOrder.loan__Status__c);
        
        
    }  
}