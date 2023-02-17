/* ****************Modification History******************
* Modified By       Date                    JIRA Number
*   Shakul        09/02/2023     LPC-239(Test class for InterestAccrualFebMonthBatch)  
******************Modification History******************/
@isTest
public class InterestAccrualFebMonthBatchTest {
    @TestSetup
    public static void testSetup(){
        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        
        //dummy account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        //dummy office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        //dummy fee
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        
        //dummy contact 
        Contact a1 = new Contact(LastName='TestACH');
        insert a1;
        
        //dummy purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        //dummy contract
        loan__Loan_Account__c lacc = loan.TestHelper.createLoanAccountForContactObj(dummyLP,
                                                                                    a1,
                                                                                    dummyFeeSet,
                                                                                    dummyLoanPurpose,
                                                                                    dummyOffice);
        lacc.loan__Loan_Status__c = 'Active - Good Standing';
        lacc.loan__Product_Type__c = 'Flexible Amz Loan';
        lacc.loan__Last_Accrual_Date__c = Date.newInstance(2020, 2, 15);
        update lacc;
        
        //Create Bill
        loan__Loan_account_Due_Details__c test_bill1 = new loan__Loan_account_Due_Details__c();
        test_bill1.loan__Due_Type__c = 1;
        test_bill1.loan__Due_Type_Description__c = 'BILL / DUE DATE';
        test_bill1.loan__Loan_Account__c = lacc.Id;
        insert test_bill1;
    }
    /*Created By: Shakul Siddharth
    Purpose: To test interest accrual calculation on 28th Feb*/
    public static testMethod void testAccrualNonLeapYear(){
        Test.startTest();
        User u = [SELECT Id, loan__Current_Branch_s_System_Date__c, loan__Current_Branch__c FROM User WHERE Id =: UserInfo.getUserId()];
        loan__Office_Name__c testOffice = [SELECT Id, loan__Current_System_Date__c FROM loan__Office_Name__c LIMIT 1];
        loan.GlobalProcessFacade.setUsersDateAndBranch(u,Date.newInstance(2020, 2, 28),testOffice);
        System.runAs(u){
            InterestAccrualFebMonthBatch iaFeb = new InterestAccrualFebMonthBatch();
            Database.executeBatch(iaFeb);
        }
        Test.stopTest();
        loan__Loan_Account__c testLacc = [SELECT id, loan__Interest_Rate__c, loan__Principal_Remaining__c, loan__Interest_Accrued_Not_Due__c, Interest_Accrued_Feb30__c FROM loan__Loan_Account__c LIMIT 1];
        Decimal forecastedInterest = (testLacc.loan__Principal_Remaining__c * testLacc.loan__Interest_Rate__c * 2)/36000.00;
        System.assertEquals((testLacc.loan__Interest_Accrued_Not_Due__c+forecastedInterest), testLacc.Interest_Accrued_Feb30__c);
    }
    
    /*Created By: Shakul Siddharth
    Purpose: To test interest accrual calculation on 29th Feb*/
    public static testMethod void testAccrualLeapYear(){
        Test.startTest();
        User u = [SELECT Id, loan__Current_Branch_s_System_Date__c, loan__Current_Branch__c FROM User WHERE Id =: UserInfo.getUserId()];
        loan__Office_Name__c testOffice = [SELECT Id, loan__Current_System_Date__c FROM loan__Office_Name__c LIMIT 1];
        loan.GlobalProcessFacade.setUsersDateAndBranch(u,Date.newInstance(2020, 2, 29),testOffice);
        System.runAs(u){
            InterestAccrualFebMonthBatch iaFeb = new InterestAccrualFebMonthBatch();
            Database.executeBatch(iaFeb);
        }
        Test.stopTest();
        loan__Loan_Account__c testLacc = [SELECT id, loan__Interest_Rate__c, loan__Principal_Remaining__c, loan__Interest_Accrued_Not_Due__c, Interest_Accrued_Feb30__c FROM loan__Loan_Account__c LIMIT 1];
        Decimal forecastedInterest = (testLacc.loan__Principal_Remaining__c * testLacc.loan__Interest_Rate__c * 1)/36000.00;
        System.assertEquals((testLacc.loan__Interest_Accrued_Not_Due__c+forecastedInterest), testLacc.Interest_Accrued_Feb30__c);
    }
    
    /*Created By: Shakul Siddharth
    Purpose: To test scheduler context of the batch job*/
    public static testMethod void testschedule() {
        Test.StartTest();
        InterestAccrualFebMonthBatch sh1 = new InterestAccrualFebMonthBatch();
        String sch = '0 0 23 * * ?'; 
        String jobId = System.schedule('Test Batch Job', sch, sh1); 
        Test.stopTest(); 
        CronTrigger ct = [SELECT Id, CronExpression FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
    }
}