/* ****************Modification History******************
*    Created By        	 Date			Version
*1. Bhavya Maliwal        2022/02/24     Initial Version, created setup method, added new method for schedule,assert

******************Modification History******************/
@isTest
public class TestInvestorReportingJob {
    @testSetup
    static void setup(){
        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr1 = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','20000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','40000 - INCOME');
        
        //Create a Fee Set
        loan__Fee__c dummyFee1 = loan.TestHelper.createFee(curr1,dummyIncAccount ,dummyAccount);                                    
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        Date systemDate =  new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
        Account acc1 = new Account(
            Name = 'Test1',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Number_Of_Applications_Invested__c = 3, 
            Total_No_of_Application_Limit__c = 30,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName2',
            loan__Active__c = 'YES', 
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456',
            Investor_Alloted_Weight__c = 2,
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0
        );
        insert acc1;
        systemDate = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
        System.debug(systemDate);
        
    }
    /*Created By : Bhavya Maliwal
Method name : investorReportingDateas1
Purpose : to cover code satisfying Date as 1 for InvestorReportingJob
*/
    @isTest static Void investorReportingDateas1(){
        loan.GlobalProcessFacade.moveSystemToDate(Date.newInstance(2018, 12, 1), false);
        Test.startTest();
        InvestorReportingJob j = new InvestorReportingJob();
        Database.executeBatch(j, 200);
        Test.stoptest();
        List<Account> acc=[Select id from Account where peer__Last_Name__c='TestLName2' LIMIT 1];
        system.assertEquals(true, acc.size()<=0);
    }
    /*Created By : Bhavya Maliwal
Method name : investorReportingDateMonthas1
Purpose : to cover code satisfying Date and Month as 1 for InvestorReportingJob
*/
    @isTest static Void investorReportingDateMonthas1(){
        loan.GlobalProcessFacade.moveSystemToDate(Date.newInstance(2018, 1, 1), false);
        Test.startTest();
        InvestorReportingJob j = new InvestorReportingJob();
        Database.executeBatch(j, 200);
        Test.stoptest();
        List<Account> acc=[Select id from Account where peer__Last_Name__c='TestLName2' LIMIT 1];
        system.assertEquals(true, acc.size()<=0);
    }
    /*Created By : Bhavya Maliwal
Method name : investorReportingScheduleMethod
Purpose : to cover code satisfying Schedule Method for InvestorReportingJob
*/
    @isTest static Void investorReportingScheduleMethod(){
        loan.GlobalProcessFacade.moveSystemToDate(Date.newInstance(2018, 1, 1), false);
        InvestorReportingJob batchSch=new InvestorReportingJob(); 
        String sch='0 30 15 * * ?'; 
        test.starttest();
        System.schedule('InvestorReportingJob', sch , batchSch); 
        test.stopTest(); 
        List<Account> acc=[Select id from Account where peer__Last_Name__c='TestLName2' LIMIT 1];
        system.assertEquals(true, acc.size()>=1);
    }
}