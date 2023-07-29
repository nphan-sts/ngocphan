/* ****************Modification History******************
 * Created By        Date          JIRA number
 *1. Pallavi        2020/01/29     LOS-242(Generate CL Loan Payoff Quote PDF Document)
 *2. Shakul         2022/03/01     LSP-558(Added asserts and testSetup methods)      
 ******************Modification History******************/
@isTest
public class TestGeneratePayoffQuoteCntrl {

    @TestSetup
    public static void testSetup(){
        //Creating Account
        //LSP-558 (Added peer__First_Name__c, peer__Last_Name__c and changed the value of loan__SOCIAL_SECURITY_NUMBER__c)
         Account acc1 = new Account(peer__First_Name__c ='Account',
                                    peer__Last_Name__c = 'Test',
                                    loan__Investor__c= false,
                                    loan__Undeployed_Funds__c = 11000,
                                    cnotify__Email__c = 'abc@test.com',
                                    loan__SOCIAL_SECURITY_NUMBER__c = String.valueOf(math.random()).right(9)
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
         
         loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();

        loan__Loan_Product__c loanProdObj = loan.TestHelper.createLoanProduct(dummyOffice,
                                                                              dummyAccount, 
                                                                              curr, 
                                                                              dummyFeeSet);
        loanProdObj.name = 'Auto Payer';
        loanProdObj.loan__Minimum_Amount_Due_Type__c = 'Percent';
        loanProdObj.loan__Pre_Bill_Days__c = 5;
        upsert loanProdObj;

        loan__Loan_Account__c lacc = new loan__Loan_Account__c(loan__Account__c= acc1.Id,
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
    }
    
    
    public static testMethod void testInsertAttachments(){ // Renamed method name (LSP-558)
        loan__Payoff_Quote__c testPayoff = [SELECT id FROM loan__Payoff_Quote__c LIMIT 1];
        
        Test.startTest();
        GeneratePayoffQuoteCntrl.GeneratePayoffQuoteCntrl(testPayoff.id);
        Test.stopTest();
        //START:LSP-558
        Attachment testAtt = [SELECT id, Description FROM Attachment LIMIT 1];
        System.assertEquals('test', testAtt.Description);
        //END:LSP-558
    }
}