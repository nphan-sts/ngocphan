/*
* author: Anusha
* This is test class for all classes related to CorrectLastBilledAmount* (for LASp-284)
* 
*****************Modification History*****************************************************************
* Name 				Date			JIRA
Bhavya Maliwal  	2022-07-15 		LSP-284 : Updated all the methods and the test data
******************Modification History*****************************************************************/
@isTest
public class CorrectLastBilledAmountTest {
    //setup Method
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
        system.debug(' Fee Junctions' +dummyFeeJunction);
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
        system.debug('Bank Account' +bank);
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        system.debug('Global Loan util' +util);
        
   
        loan__Loan_Account__c lacc = new loan__Loan_Account__c(
            loan__Account__c= acc.Id,
            loan__Contact__c= a1.ID,
            loan__Product_Type__c='Flexible Amz Loan',
            loan__Loan_Amount__c =5000,
            loan__Loan_Product_Name__c=loanProdObj.Id,
            loan__Payment_Amount__c=439.70, 
            loan__Principal_Remaining__c = 4243.60,
            loan__First_Installment_Date__c = util.getCurrentSystemDate()+1,
            loan__Next_Installment_Date__c = util.getCurrentSystemDate()+1, 
            loan__Maturity_Date_Current__c = util.getCurrentSystemDate()+365, 
            loan__Frequency_of_Loan_Payment__c = 'Monthly',
            loan__Last_Installment_Date__c =util.getCurrentSystemDate()+365,
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
        loan__Loan_Account__c lacc1 = new loan__Loan_Account__c(
            loan__Account__c= acc.Id,
            loan__Contact__c= a1.ID,
            loan__Product_Type__c='Flexible Amz Loan',
            loan__Loan_Amount__c =5000,
            loan__Loan_Product_Name__c=loanProdObj.Id,
            loan__Payment_Amount__c=439.70, 
            loan__Principal_Remaining__c = 4243.60,
            loan__First_Installment_Date__c = Date.newInstance(2020,06,30),
            loan__Next_Installment_Date__c = util.getCurrentSystemDate()+1,
            loan__Last_Installment_Date__c = util.getCurrentSystemDate()+365,
            loan__Maturity_Date_Current__c = util.getCurrentSystemDate()+365,
            loan__Last_Billed_Amount__c = 490,
            loan__Pmt_Amt_Cur__c = 600,
            loan__Frequency_of_Loan_Payment__c = 'Monthly',
            loan__Loan_Status__c = 'Active - Good Standing',
            loan__Interest_Rate__c = 10,
            loan__Term_Cur__c = 12,
            Skipped_a_pay_Date__c = null,
            Skipped_a_Pay__c = false,
            lead_guid__c = 'TestClassGuid1',
            loan__Disbursal_Date__c = Date.newInstance(2020,05,30),
            loan__Pre_Bill_Days__c = 3
        );
        insert lacc1; 
        loan__Loan_Account__c lacc2 = new loan__Loan_Account__c(
            loan__Account__c= acc.Id,
            loan__Contact__c= a1.ID,
            loan__Product_Type__c='Flexible Amz Loan',
            loan__Loan_Amount__c =5000,
            loan__Loan_Product_Name__c=loanProdObj.Id,
            loan__Payment_Amount__c=439.70, 
            loan__Principal_Remaining__c = 4243.60,
            loan__Next_Installment_Date__c = util.getCurrentSystemDate()+1,
            loan__Last_Installment_Date__c = util.getCurrentSystemDate()+1,
            loan__Maturity_Date_Current__c = util.getCurrentSystemDate()+1,
            loan__Last_Billed_Amount__c = 490,
            loan__Pmt_Amt_Cur__c = 500,
            loan__First_Installment_Date__c = Date.newInstance(2020,06,30),
            loan__Frequency_of_Loan_Payment__c = 'Monthly',
            loan__Loan_Status__c = 'Active - Good Standing',
            loan__Interest_Rate__c = 10,
            loan__Term_Cur__c = 12,
            Skipped_a_pay_Date__c = null,
            Skipped_a_Pay__c = false,
            lead_guid__c = 'TestClassGuid2',
            loan__Disbursal_Date__c = Date.newInstance(2020,05,30),
            
            loan__Pre_Bill_Days__c = 3
        );
        insert lacc2; 
        
    }
    /*Created By : Bhavya Maliwal
Method name : testLBAFirstPaymentDue
Purpose : to cover code satisfying if the first payment is due and the holiday lies on the due date.
*/
    @isTest
    public static void testLBAFirstPaymentDue(){
        
        Test.startTest();
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        Date currentDate = util.getCurrentSystemDate();
        HolidaySetup__c holiday=new HolidaySetup__c();
        holiday.End_Date__c=currentDate+5;
        holiday.Start_Date__c=currentDate+1;
        holiday.Name='test 1';
        insert holiday;
        
        CorrectLastBilledAmountBatch batch = new CorrectLastBilledAmountBatch();
        Database.executeBatch(batch,200);
       Test.stopTest();
        loan__loan_account__c la = [select id, name,loan__Last_Billed_Amount__c,loan__Payment_Amount__c ,loan__Pmt_Amt_Cur__c
                                    from loan__loan_account__c where lead_guid__c = 'TestClassGuid0' limit 1];
        System.assertEquals(la.loan__Last_Billed_Amount__c , la.loan__Payment_Amount__c);
    }
    /*Created By : Bhavya Maliwal
Method name : testLBALastPaymentDue
Purpose : to cover code satisfying if the last payment is due and the holiday lies on the due date.
*/  
    @isTest
    public static void testLBALastPaymentDue(){
        loan__loan_account__c la = [select id, name,loan__Last_Billed_Amount__c,loan__Last_Installment_Date__c,loan__Maturity_Date_Current__c,loan__Pmt_Amt_Cur__c,loan__next_installment_date__c 
                                    from loan__loan_account__c where lead_guid__c = 'TestClassGuid2' limit 1];
        
        
        Test.startTest();
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        Date currentDate = util.getCurrentSystemDate();
        
        HolidaySetup__c holiday=new HolidaySetup__c();
        holiday.End_Date__c=currentDate+2;
        holiday.Start_Date__c=currentDate+1;
        holiday.Name='test 2';
        insert holiday;
        
        CorrectLastBilledAmountBatch batch = new CorrectLastBilledAmountBatch();
        Database.executeBatch(batch,200);
        Test.stopTest();
        loan__loan_account__c laUpdated = [select id, name,loan__Last_Billed_Amount__c,loan__Pmt_Amt_Cur__c,loan__Payment_Amount__c 
                                           from loan__loan_account__c where lead_guid__c = 'TestClassGuid2' limit 1];
        System.assertEquals(laUpdated.loan__Last_Billed_Amount__c,laUpdated.loan__Pmt_Amt_Cur__c);
    }
    /*Created By : Bhavya Maliwal
Method name : testLBANeitherFirstNorLastPaymentDue
Purpose : to cover code satisfying if any payment between first and last payment is due and the holiday lies on the due date.
*/ 
    @isTest
    public static void testLBANeitherFirstNorLastPaymentDue(){
        loan__loan_account__c la = [select id, name,loan__Last_Billed_Amount__c,loan__Last_Installment_Date__c,loan__Maturity_Date_Current__c,loan__Pmt_Amt_Cur__c,loan__next_installment_date__c 
                                    from loan__loan_account__c where lead_guid__c = 'TestClassGuid1' limit 1];
        
        
        Test.startTest();
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        Date currentDate = util.getCurrentSystemDate();
        
        HolidaySetup__c holiday=new HolidaySetup__c();
        holiday.End_Date__c=currentDate+5;
        holiday.Start_Date__c=currentDate+1;
        holiday.Name='test 3';
        insert holiday;
        
        CorrectLastBilledAmountBatch batch = new CorrectLastBilledAmountBatch();
        Database.executeBatch(batch,200);
        Test.stopTest();
        loan__loan_account__c laUpdated = [select id, name,loan__Last_Billed_Amount__c,loan__Pmt_Amt_Cur__c ,loan__Payment_Amount__c
                                           from loan__loan_account__c where lead_guid__c = 'TestClassGuid1' limit 1];
        System.assertEquals(laUpdated.loan__Last_Billed_Amount__c ,laUpdated.loan__Pmt_Amt_Cur__c);
    }
    /*Created By : Bhavya Maliwal
Method name : testSchedulableMethod
Purpose : to cover code satisfying execution of Schedulable method
*/
    @isTest 
    public static void testSchedulableMethod(){
        
        Test.startTest();
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        Date currentDate = util.getCurrentSystemDate();
        
        HolidaySetup__c holiday=new HolidaySetup__c();
        holiday.End_Date__c=currentDate+5;
        holiday.Start_Date__c=currentDate+1;
        holiday.Name='test 3';
        insert holiday;
        
        CorrectLastBilledAmountBatch sh1 = new CorrectLastBilledAmountBatch();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test CorrectLastBilledAmountBatchSchedule', sch, sh1);
        Test.stopTest();
         }
}