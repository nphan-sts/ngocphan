@isTest
public class TestInvestorReportingJob {
    
     @isTest static Void resetInvestor(){
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
        loan.GlobalProcessFacade.moveSystemToDate(Date.newInstance(2018, 12, 1), false);
        systemDate = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
         System.debug(systemDate);
        Test.startTest();
         InvestorReportingJob j = new InvestorReportingJob();
         Database.executeBatch(j, 200);
         Test.stoptest();
         
     }
    
    @isTest static Void resetInvestor2(){
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
        loan.GlobalProcessFacade.moveSystemToDate(Date.newInstance(2018, 1, 1), false);
        systemDate = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
         System.debug(systemDate);
        Test.startTest();
         InvestorReportingJob j = new InvestorReportingJob();
         Database.executeBatch(j, 200);
         Test.stoptest();
         
     }

}