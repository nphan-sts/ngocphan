/* ****************Modification History******************
* Created By        Date          JIRA number
*1. Pallavi        2020/01/29     LOS-243(Create CL Loan Current Loan Statement)
*2. Bhanupriya		2022/03/02		LSP-555(craete testsetup() and add required fields,assert statements)  
******************Modification History******************/
@isTest
public class TestLoanStatementController {
    
    //create testsetup() method
    @testsetup()
    public static void testsetup(){
        
        //Creating Account
        Account acc1 = new Account(
            Name = 'TestAccount',
            loan__Investor__c=False,
            loan__Undeployed_Funds__c = 11000,
            cnotify__Email__c = 'abc@test.com',
            peer__Last_Name__c = 'TestAccount Last Name',			//LSP-555
            loan__SOCIAL_SECURITY_NUMBER__c = '123456789'			//LSP-555
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
        system.debug('Dummy fee junction'+dummyFeeJunction);
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
        org.loan__Disable_Triggers__c = true;
        upsert org;
        
        //Create Loan Product
        loan__Loan_Product__c loanProdObj = loan.TestHelper.createLoanProduct(dummyOffice,
                                                                              dummyAccount, 
                                                                              curr, 
                                                                              dummyFeeSet);
        loanProdObj.name = 'Auto Payer';
        loanProdObj.loan__Minimum_Amount_Due_Type__c = 'Percent';
        loanProdObj.loan__Pre_Bill_Days__c = 5;
        upsert loanProdObj;    
        
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        //create dummy Loan Account
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
        
        //create new contact
        Contact a1 = new Contact(LastName='TestACH');
        insert a1;
        
        
        //create Payment mode
        loan__Payment_Mode__c pMode = [select id from loan__Payment_Mode__c where Name= 'ACH'];
        system.debug('Payment Mode'+pMode);
        //create a dummy Loan Account
        loan__Loan_Account__c dummylaMonthly = loan.TestHelper.createLoanAccountForContactObj(loanProdObj,
                                                                                              a1,
                                                                                              dummyFeeSet,
                                                                                              dummyLoanPurpose,
                                                                                              dummyOffice);
        system.debug('Dummy Loan Account' +dummylaMonthly);
        Date systemDate = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
        //create Repayment Schedule
        loan__Repayment_Schedule__c amz = new loan__Repayment_Schedule__c(loan__Due_Principal__c = 1000,
                                                                          loan__Due_Interest__c = 10,
                                                                          loan__isPaid__c = true,
                                                                          loan__Archived__c = false,
                                                                          loan__Due_Date__c = systemDate-1,
                                                                          loan__Paid_Interest__c = 0,
                                                                          loan__Loan_Account__c = lacc.id);
        insert amz;
        
        Date prevYearDate = Date.newInstance(systemDate.year()-1, 1, 1);
        
        loan__Repayment_Schedule__c amz1 = new loan__Repayment_Schedule__c(loan__Due_Principal__c = 1000,
                                                                           loan__Due_Interest__c = 10,
                                                                           loan__isPaid__c = false,
                                                                           loan__Archived__c = false,
                                                                           loan__Due_Date__c = prevYearDate,
                                                                           loan__Paid_Interest__c = 0,
                                                                           loan__Loan_Account__c = lacc.id,
                                                                           loan__Is_Billed__c = true);
        
        insert amz1; 
    }
    
    @isTest
    public static void generateLoanStatement(){
        
        loan__Loan_Account__c lacc = [select id,
                                      loan__Account__c,
                                      loan__Loan_Amount__c,
                                      loan__Loan_Status__c
                                      from loan__Loan_Account__c
                                      where loan__Loan_Status__c = 'Active - Good Standing'];
        
        loan__Repayment_Schedule__c repy1 =  [Select id,loan__Due_Principal__c,loan__Due_Interest__c,loan__Total_Installment__c 
                                              from loan__Repayment_Schedule__c
                                              where loan__isPaid__c = false and loan__Is_Billed__c = true];
        system.debug('before repyment ' +repy1);
        
        test.startTest();
        PageReference pageRef = Page.GenerateLoanStatement;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(lacc.Id));
        LoanStatementController state = new LoanStatementController();
        test.stopTest();
        system.debug('LoanStatementController' +state);
        list<loan__Repayment_Schedule__c> repy =  [Select id,loan__Due_Principal__c,loan__Due_Interest__c,loan__Total_Installment__c 
                                                   from loan__Repayment_Schedule__c
                                                   where loan__isPaid__c=false];
        
        
        system.debug('After Repayment' +repy);
        system.assert(repy1.loan__Due_Interest__c!=repy[0].loan__Due_Interest__c);
        system.assert(repy1.loan__Due_Principal__c!=repy[0].loan__Due_Principal__c);
        system.assert(repy1.loan__Total_Installment__c!=repy[0].loan__Total_Installment__c);
        
        
    }
    
}