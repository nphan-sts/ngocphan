@isTest

public class TestLoanApplicationUpdateJob{
     public static String CRON_EXP = '0 0 0 15 3 ? 2022';
   @testSetup static void setup() {
   
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
        
        //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            //Borrower_s_Last_Name__c='Testborrower',
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
        //Creating Application
        genesis__Applications__c app= new genesis__Applications__c(
                                        genesis__Due_Day__c = 20,
                                        genesis__Expected_First_Payment_Date__c = system.Today(),
                                        genesis__Expected_Start_Date__c = system.Today(),
                                        genesis__Funding_in_Tranches__c = true,
                                        Borrower_s_Email__c = null,
                                        genesis__Account__c = acc.Id,
                                        genesis__Expected_Close_Date__c =Date.newInstance(2017,10,11),
                                        Application_Start_DateV2__c = system.Today(),
                                        DocuSignFlag__c=true,
                                        genesis__Status__c = 'agent_verified',
                                        genesis__Draw_Period_End_Date__c = system.Today()
                                        );
        List<genesis__Applications__c> applist = new List<genesis__Applications__c>();
        appList.add(app);
        insert appList;
        System.debug('==============='+applist);
        
   }
    Testmethod static void method1(){
        List<genesis__Applications__c> applist1 = [select Id,name,genesis__Status__c,CreatedDate,genesis__Expected_Close_Date__c From genesis__Applications__c Where genesis__Status__c!='LOAN APPROVED'];
        Test.startTest();
        LoanApplicationUpdateJob job = new LoanApplicationUpdateJob();
        job.doStart(null);
        job.doExecute(null,appList1);
        ID batchprocessid = Database.executeBatch(job);
     //   job.finish(null);
        String jobIdLDTAdd = System.schedule('LoanApplicationUpdateJob',
                        CRON_EXP, 
                        new LoanApplicationUpdateJob());
        System.assert(batchprocessid!=null); 
        Test.stopTest();
    }
    Testmethod static void method2(){
    
        List<genesis__Applications__c> applist1 = [select Id,name,genesis__Status__c,CreatedDate,genesis__Expected_Close_Date__c From genesis__Applications__c Where genesis__Status__c!='LOAN APPROVED'];        
        String Query = 'select Id,name,genesis__Status__c,CreatedDate,genesis__Expected_Close_Date__c From genesis__Applications__c';
        Test.startTest();
        LoanApplicationUpdateJob job = new LoanApplicationUpdateJob(Query);
        job.doStart(null);
        job.doExecute(null,appList1);
        ID batchprocessid = Database.executeBatch(job);
        //job.finish(null);
        String jobIdLDTAdd = System.schedule('LoanApplicationUpdateJob',
                        CRON_EXP, 
                        new LoanApplicationUpdateJob());
        System.assert(batchprocessid!=null); 
        
        Test.stopTest();
    }
}