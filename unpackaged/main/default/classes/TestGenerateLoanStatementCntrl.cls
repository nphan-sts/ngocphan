/* ****************Modification History******************
* Created By        Date          JIRA number
*1. Pallavi        2020/01/29     LOS-243(Create CL Loan Current Loan Statement)
*2. Bhanupriya		2022/03/01		LSP-554 (create setup method and add comments) 
******************Modification History******************/
@isTest
public class TestGenerateLoanStatementCntrl {
    
    //Create testsetup() method
    @testsetup()
    public static void testsetup(){
        
        //Creating Account
        Account acc1 = new Account(
            Name = 'TestAccount',
            loan__Investor__c=False,
            loan__Undeployed_Funds__c = 11000,
            cnotify__Email__c = 'abc@test.com',
            peer__Last_Name__c = 'TestAccount Last Name',					//LSP-554
            loan__SOCIAL_SECURITY_NUMBER__c = '123456789'			//LSP-554
        );
        insert acc1;
        
        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);                                    
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        system.debug('Dummy Fee Junction' +dummyFeeJunction);
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
        org.loan__Disable_Triggers__c = true;
        upsert org;
        
        //Create dummy Loan product
        loan__Loan_Product__c loanProdObj = loan.TestHelper.createLoanProduct(dummyOffice,
                                                                              dummyAccount, 
                                                                              curr, 
                                                                              dummyFeeSet);
        loanProdObj.name = 'Auto Payer';
        loanProdObj.loan__Minimum_Amount_Due_Type__c = 'Percent';
        loanProdObj.loan__Pre_Bill_Days__c = 3;
        upsert loanProdObj;        
        
        //Create Loan Account
        loan__Loan_Account__c lacc = new loan__Loan_Account__c(
            loan__Account__c= acc1.Id,
            loan__Product_Type__c='line of credit',
            loan__Loan_Amount__c =10000,
            loan__Principal_Remaining__c = 1000,
            loan__Loan_Balance__c = 100,
            loan__Interest_Remaining__c = 100,
            loan__Last_Accrual_Date__c = loan.LoanConstants.DT_MAX,
            loan__Interest_rate__c = 12,
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
        
    }
    
    @isTest
    public static void generateLoanStatement(){
        
        loan__Loan_Account__c lacc = [select id,
                                      loan__Account__c,
                                      loan__Payment_Amount__c
                                      from loan__Loan_Account__c];
        test.startTest();
        GenerateLoanStatementCntrl.GenerateLoanStatementCntrl(lacc.id);
        test.stopTest();
        list<loan__loan_account__c> contract = [Select id,name 
                                                from loan__loan_account__c 
                                                where id =: lacc.id];
        system.assertEquals([select name,Description from Attachment].size(),1);
        system.assertEquals(1,contract.size());
        
    }
    
    
}