/*
 * author: Anusha
 * This is test class for all classes related to CorrectLastBilledAmount* (for LASp-284)
 * 
 *****************Modification History*****************************************************************
 * 
 ******************Modification History*****************************************************************/
@isTest
public class CorrectLastBilledAmountTest {
    @testSetup static void setup(){
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
                        
        //Creating Account
        Account acc = new Account(
            Name = 'Test',
            peer__Last_Name__c = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123456789'
        );
        insert acc;
                
        loan__Loan_Product__c loanProdObj = new loan__Loan_Product__c(name='TestProduct'); 
        insert loanProdObj;
        
        //Creating Conpany
        genesis__Company__c comp = genesis.TestHelper.createCompany(); 
        comp.Name = 'payoff';
        update comp;
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        
        //creating CL Product
        clcommon__CL_Product__c pr = new clcommon__CL_Product__c();
        pr.loan__Lending_Product__c = dummyLp.id;
        pr.clcommon__Product_Name__c = 'P1';
        insert pr;
        
        Account account_Obj = new Account(
            Name = 'Test',
            peer__Last_Name__c = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com'
        );
        Insert account_Obj;
        
        Contact a1 = new Contact(LastName='TestACH');
        a1.AccountId = acc.Id;
        insert a1;
        
        loan__Bank_Account__c ba = new loan__Bank_Account__c(loan__Bank_Account_Number__c = 'XXXXXXXX1212',
                                                             loan__Bank_Name__c = 'Some Bank',
                                                             loan__Routing_Number__c = '999999999',
                                                             loan__Account_Type__c = 'Checking',
                                                             Unmasked_Bank_Account_Number__c = '123456',
                                                             loan__Account_Usage__c = 'Borrower/Investor Account',
                                                             loan__Contact__c = a1.id,
                                                             loan__Account__c = acc.id,
                                                             loan__Active__c = True);
        insert ba;
        
        loan__Payment_Mode__c pMode1 = new loan__Payment_Mode__c(Name = 'ACH');
        insert pMode1;
        
        loan__Bank_Account__c bank = [select id from loan__Bank_Account__c where loan__Account_usage__c= 'Borrower/Investor Account' limit 1];
        
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        loan__Loan_Account__c lacc = new loan__Loan_Account__c(
            loan__Account__c= acc.Id,
            loan__Contact__c= a1.ID,
            loan__Product_Type__c='Flexible Amz Loan',
            loan__Loan_Amount__c =5000,
            loan__Loan_Product_Name__c=loanProdObj.Id,
            loan__Payment_Amount__c=439.70, 
            loan__Principal_Remaining__c = 4243.60,
            loan__First_Installment_Date__c = Date.newInstance(2020,06,30),
            loan__Next_Installment_Date__c = Date.newInstance(2020,07,30), 
            loan__Maturity_Date_Current__c = Date.newInstance(2021,06,30), 
            loan__Frequency_of_Loan_Payment__c = 'Monthly',
            loan__last_billed_amount__c = null,
            loan__Last_Installment_Date__c = Date.newInstance(2021,06,30),
            loan__Loan_Status__c = 'Active - Good Standing',
            loan__Interest_Rate__c = 10,
            loan__Term_Cur__c = 12,
            Skipped_a_pay_Date__c = null,
            Skipped_a_Pay__c = false,
            lead_guid__c = 'TestClassGuid0',
            loan__Disbursal_Date__c = Date.newInstance(2020,05,30),
            loan__Pmt_Amt_Cur__c = 500,
            loan__Pre_Bill_Days__c = 3
        );
        insert lacc; 
    }
	@isTest
    public static void testLBAFirstPaymentDue(){
        Date fromDate = Date.newInstance(2020,07,27);
        Date toDate = Date.newInstance(2020,07,31);
        Test.startTest();
        CorrectLastBilledAmountBatch batch = new CorrectLastBilledAmountBatch(fromDate,toDate);
        Database.executeBatch(batch,200);
        Test.stopTest();
        loan__loan_account__c la = [select id, name,loan__Last_Billed_Amount__c,loan__Payment_Amount__c 
                                             from loan__loan_account__c where lead_guid__c = 'TestClassGuid0' limit 1];
        System.assertEquals(la.loan__Last_Billed_Amount__c, la.loan__Payment_Amount__c);
    }
    
    @isTest
    public static void testLBALastPaymentDue(){
        Date fromDate = Date.newInstance(2020,07,27);
        Date toDate = Date.newInstance(2020,07,31);
        loan__loan_account__c la = [select id, name,loan__Last_Billed_Amount__c,loan__Last_Installment_Date__c,loan__Maturity_Date_Current__c,loan__Pmt_Amt_Cur__c,loan__next_installment_date__c 
                                             from loan__loan_account__c where lead_guid__c = 'TestClassGuid0' limit 1];
        la.loan__Next_Installment_Date__c = Date.newInstance(2020, 07, 30);
        la.loan__Last_Installment_Date__c = Date.newInstance(2020, 07, 30);
        la.loan__Maturity_Date_Current__c = Date.newInstance(2020, 07, 30);
        la.loan__Last_Billed_Amount__c = 490;
        la.loan__Pmt_Amt_Cur__c = 500;
        update la;
        
        Test.startTest();
        CorrectLastBilledAmountBatch batch = new CorrectLastBilledAmountBatch(fromDate,toDate);
        Database.executeBatch(batch,200);
        Test.stopTest();
        loan__loan_account__c laUpdated = [select id, name,loan__Last_Billed_Amount__c,loan__Pmt_Amt_Cur__c 
                                             from loan__loan_account__c where lead_guid__c = 'TestClassGuid0' limit 1];
        System.assertEquals(laUpdated.loan__Last_Billed_Amount__c, laUpdated.loan__Pmt_Amt_Cur__c);
    }
    
    @isTest
    public static void testLBANeitherFirstNorLastPaymentDue(){
        Date fromDate = Date.newInstance(2020,07,27);
        Date toDate = Date.newInstance(2020,07,31);
        loan__loan_account__c la = [select id, name,loan__Last_Billed_Amount__c,loan__Last_Installment_Date__c,loan__Maturity_Date_Current__c,loan__Pmt_Amt_Cur__c,loan__next_installment_date__c 
                                             from loan__loan_account__c where lead_guid__c = 'TestClassGuid0' limit 1];
        la.loan__Next_Installment_Date__c = Date.newInstance(2020, 07, 30);
        la.loan__Last_Installment_Date__c = Date.newInstance(2021, 07, 30);
        la.loan__Maturity_Date_Current__c = Date.newInstance(2021, 07, 30);
        la.loan__Last_Billed_Amount__c = 490;
        la.loan__Pmt_Amt_Cur__c = 600;
        update la;
        Test.startTest();
        CorrectLastBilledAmountBatch batch = new CorrectLastBilledAmountBatch(fromDate,toDate);
        Database.executeBatch(batch,200);
        Test.stopTest();
        loan__loan_account__c laUpdated = [select id, name,loan__Last_Billed_Amount__c,loan__Pmt_Amt_Cur__c 
                                             from loan__loan_account__c where lead_guid__c = 'TestClassGuid0' limit 1];
        System.assertEquals(laUpdated.loan__Last_Billed_Amount__c, laUpdated.loan__Pmt_Amt_Cur__c);
    }
    
    @isTest
    public static void testLBAController(){
        CorrectLastBilledAmountController contrl = new CorrectLastBilledAmountController();
        contrl.fromDate = Date.newInstance(2020,07,27);
        contrl.toDate = Date.newInstance(2020,07,31);
        Test.startTest();
        contrl.performAmountCorrection();
        PageReference pageRef = Page.CorrectLastBilledAmount;
        Test.setCurrentPage(pageRef);
        contrl.reset();
        Test.stopTest();
        loan__loan_account__c laUpdated = [select id, name,loan__Last_Billed_Amount__c,loan__Payment_Amount__c 
                                             from loan__loan_account__c where lead_guid__c = 'TestClassGuid0' limit 1];
        System.assertEquals(laUpdated.loan__Last_Billed_Amount__c, laUpdated.loan__Payment_Amount__c);
    }
}