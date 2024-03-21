/* ****************Modification History******************
* Modified By       Date                    JIRA Number
*   Shakul        18/11/2022     LSP-1047(Test class for CustomQueryLoanPaymentFilegen)  
******************Modification History******************/
@isTest

public class CustomQueryLoanPaymentFilegenTest{
    @TestSetup
    public static void testSetup(){
        loan.TestHelper.createSeedDataForTesting();
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        dummyOffice.loan__Is_Branch__c=true;
        upsert dummyOffice;
        
        loan__ACH_Parameters__c achParam = new loan__ACH_Parameters__c();
        achParam.loan__Multiple_Payment_Method_Support__c = true;
        achParam.loan__Organization_Name__c = 'testPayoff';
        insert achParam;
        
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        
        String name = 'loan product';
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(Name, dummyOffice, dummyAccount, curr, dummyFeeSet);
        dummyLP.loan__Loan_Product_Type__c='Loan';
        dummyLp.loan__Accrual_Start_Basis__c='Disbursal';
        upsert dummyLp;
        
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        loan__Client__c client=Loan.TestHelper.createClient();
        loan.TestHelper.createLoanAccount(dummyLP, client, dummyFeeSet, dummyLoanPurpose, dummyOffice);
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Account_External_ID__c = 'Test';
        acc.peer__Last_Name__c = 'Account';
        insert acc;
        
        Contact a1 = new Contact(LastName='TestACH');
        insert a1;
        
        loan__Payment_Mode__c pMode = [select id, name from loan__Payment_Mode__c where Name= 'ACH'];
        
        loan__Bank_Account__c ba = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
                                                             loan__Bank_Name__c = 'Some Bank',
                                                             loan__Routing_Number__c = '999999999',
                                                             loan__Account_Type__c = 'Checking',
                                                             loan__Account_Usage__c = 'Collections Trust Account',
                                                             Unmasked_Bank_Account_Number__c = '123234324',
                                                             loan__Contact__c = a1.id,
                                                             loan__Account__c = acc.id,
                                                             loan__Active__c = true);
        insert ba;
        
        loan__Automated_Payment_Configuration__c aPC = loan.TestHelper2.createAutomatedPaymentConfiguration(loan.LoanConstants.LOAN_PAYMENT,pMode,ba,'CustomLoanPaymentTxnNACHAGen');
        apc.loan__Immediate_Destination__c = '2222222222';
        update apc;
    }
    
    /*Created By: Shakul Siddharth
    Purpose: To test custom LoanPaymentFilegenDynamicJob logic*/
    public static testMethod void testLoanPaymentFilegenDynamicJobQuery(){
        Test.startTest();
    	CustomQueryLoanPaymentFilegen custJob = new CustomQueryLoanPaymentFilegen();
        custJob.getCustomQuery('loan.LoanPaymentFilegenDynamicJob');
        Test.stopTest();

    }
}