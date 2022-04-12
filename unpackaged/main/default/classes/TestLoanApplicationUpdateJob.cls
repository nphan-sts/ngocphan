/* ****************Modification History******************
* Updated By        Date			 Jira Number
*1. Bhanupriya       2022/03/08     LSP-607(Adding required fields, add comments and assert statements)
******************Modification History******************/
@isTest

public class TestLoanApplicationUpdateJob{
    public static String CRON_EXP = '0 0 0 15 3 ? ';
    //create testsetup()
    @testSetup static void testSetup() {
        
        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);                                    
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        system.debug('Dummy Fee Junction'+dummyFeeJunction);
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        system.debug('Office'+dummyOffice.name);
        //Creating Account
        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            peer__Last_Name__c = 'Test Last Name',						//LSP-607 Required
            loan__SOCIAL_SECURITY_NUMBER__c = '123456789'				//LSP-607 must be 9 digit
        );
        insert acc;
        
        //Creating Application
        genesis__Applications__c app= new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            Borrower_s_Email__c = null,
            genesis__Account__c = acc.Id,
            genesis__Expected_Close_Date__c =Date.newInstance(2022,10,11),	//LSP-607
            Application_Start_DateV2__c = system.Today(),
            DocuSignFlag__c=true,
            genesis__Status__c = 'Agent Verified',
            genesis__Draw_Period_End_Date__c = system.Today()
        );
        List<genesis__Applications__c> applist = new List<genesis__Applications__c>();
        appList.add(app);
        insert appList;
        System.debug('==============='+applist);
        
    }
    //Test method 1 for batch processing
    Testmethod static void loanappBatchJobprocessing(){
        List<genesis__Applications__c> applist1 = [select Id,
                                                   name,
                                                   genesis__Status__c,
                                                   CreatedDate,
                                                   genesis__Expected_Close_Date__c 
                                                   From genesis__Applications__c 
                                                   Where genesis__Status__c!='LOAN APPROVED'];
        Test.startTest();
        LoanApplicationUpdateJob job = new LoanApplicationUpdateJob();
        job.doStart(null);
        job.doExecute(null,appList1);
        ID batchprocessid = Database.executeBatch(job);
        Test.stopTest();
        genesis__Applications__c app = [select Id,
                                        genesis__Status__c 
                                        From genesis__Applications__c];
        System.assert(batchprocessid!=null); 
        system.assertEquals('agent verified',app.genesis__Status__c);
        
    }
    //test method 2 batch processing query execute
    Testmethod static void loanappBatchQuery_parameterizedconstructor(){
        
        List<genesis__Applications__c> applist1 = [select Id,
                                                   name,
                                                   genesis__Status__c,
                                                   CreatedDate,
                                                   genesis__Expected_Close_Date__c 
                                                   From genesis__Applications__c 
                                                   Where genesis__Status__c!='LOAN APPROVED'];        
        String query = 'select Id,name,genesis__Status__c,CreatedDate,genesis__Expected_Close_Date__c From genesis__Applications__c';
        Test.startTest();
        LoanApplicationUpdateJob job = new LoanApplicationUpdateJob(query);
        job.doStart(null);
        job.doExecute(null,appList1);
        ID batchprocessid = Database.executeBatch(job);
        
        Test.stopTest();
        genesis__Applications__c app = [select Id,
                                        name,
                                        genesis__Status__c 
                                        From genesis__Applications__c];
        
        System.assert(batchprocessid!=null); 
        system.assertEquals('agent verified', app.genesis__Status__c);
        system.assert(!String.isEmpty(query));
    }
    //test method 3 for batch job for schedule  
    Testmethod static void scheduleBatch(){
        Test.startTest();
        
        String jobIdLDTAdd = System.schedule('LoanApplicationUpdateJob',
                                             CRON_EXP, 
                                             new LoanApplicationUpdateJob());
        Test.stopTest();
        system.assert(jobIdLDTAdd!=null);
    }
    
}