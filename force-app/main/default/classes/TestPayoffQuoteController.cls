/* ****************Modification History******************
 * Created By        Date          JIRA number
 *1. Pallavi        2020/01/29     LOS-242(Generate CL Loan Payoff Quote PDF Document)
 *   Bhavya  		2022/2/15		LSP-545 test class been set as per standards and increased the coverage
 ******************Modification History******************/
@isTest
public class TestPayoffQuoteController {
 /*Created By : Bhavya Maliwal
Method name : payoffQuoteControllerPayoffQuote
Purpose : to cover PayoffQuoteController
*/
    @isTest
    
    public static void payoffQuoteControllerPayoffQuote (){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        loan__Trigger_Parameters__c triggerParam = new loan__Trigger_Parameters__c();
        triggerParam.loan__Disable_Loan_Account_Trigger__c=true;
        insert triggerParam;
        
        Account acc1 = new Account(
            Name = 'TestAccount',
            loan__Investor__c=False,
            peer__Last_Name__c='TestLName2',
            loan__Undeployed_Funds__c = 11000,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123123123'
            );
        insert acc1;
        
        Account acc2 = new Account(
            Name = 'TestInvestorAccount',
            loan__Investor__c = true,
            peer__Last_Name__c='TestLName2',
            loan__Undeployed_Funds__c = 11000,
            cnotify__Email__c = 'abcd@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123456789'
            );
        
            acc2.Billingstreet = 'testStreet';
            acc2.BillingCity = 'testCity';
            acc2.BillingState = 'testState';
            acc2.BillingPostalCode = 'testPostalCode';
            acc2.BillingCountry = 'US';
            acc2.Shippingstreet = 'sStreet';
            acc2.ShippingCity = 'sCity';
            acc2.ShippingState = 'sState';
            acc2.ShippingPostalCode = 'sCode';
            acc2.ShippingCountry = 'US';
        insert acc2;
        
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
        
        
        loan__Loan_Product__c loanProdObj = loan.TestHelper.createLoanProduct(dummyOffice,
                                            dummyAccount, 
                                            curr, 
                                            dummyFeeSet);
        loanProdObj.name = 'Auto Payer';
        loanProdObj.loan__Minimum_Amount_Due_Type__c = 'Percent';
        loanProdObj.loan__Pre_Bill_Days__c = 5;
        upsert loanProdObj;        
        
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
                                            loan__Previous_Installment_Date__c= system.today(),
                                            lead_Guid__c = 'testpayoff'
                                            );
        insert lacc; 
        
        loan__Payoff_Quote__c payoff = new loan__Payoff_Quote__c(loan__Loan_Account__c = lacc.id,
                                                                loan__Poq_Total_Payoff_Amount__c = 1000,
                                                                loan__Poq_Transaction_Date__c = system.today(),
                                                                loan__Poq_Principal_Bal__c = 2000,
                                                                loan__Poq_Accrued_Interest__c = 100,
                                                                loan__Interest_Posted__c = 90);
        insert payoff;
        
        loan__Investor_Loan__c investor = new loan__Investor_Loan__c();
        investor.loan__Loan__c = lacc.id;
        investor.loan__Investment_Amount__c = 1000;
        investor.loan__Account__c = acc2.Id;
        investor.loan__Loan_Principal_Remaining__c = 100;
        investor.loan__Status__c = 'Active';
        insert investor;
        
        test.startTest();
        PageReference pageRef = Page.GeneratePayoffQuote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(payoff.Id));
        PayoffQuoteController quote = new PayoffQuoteController();
        test.stopTest();
    }
}