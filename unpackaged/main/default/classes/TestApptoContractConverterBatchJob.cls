/* ****************Modification History*****************************************************************
* Modified by      Date            JIRA number
*  Bhanupriya      2022/03/18       LSP- 629(Add comments, Add required fields and assert statement)
*
******************Modification History*****************************************************************/

@isTest
private class TestApptoContractConverterBatchJob{
    
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    //create testsetup()
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
        system.debug('Dummy Fee Junction'+dummyFeeJunction);
        //create dummy office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        system.debug('Office' +dummyOffice);
        loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
        org.loan__Disable_Triggers__c = true;
        upsert org;  
        
        //Creating Account
        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            peer__Last_Name__c = 'Test Last Name',		//LSP-629 Required field
            loan__SOCIAL_SECURITY_NUMBER__c = '123456789'		//LSP-629 must be 9 digit	
        );
        insert acc;
        //Creating Application
        genesis__Applications__c app= new genesis__Applications__c(
            genesis__Due_Day__c = 10,
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
    //testmethod for Batch processing
    @istest static void apptocontractBatchjob_ParametrizedConstructor(){
        
        List<genesis__Applications__c> applist1 = [select Id,
                                                   name,Send_Offer_expiry_notification__c,
                                                   X14day_s_Before_Expiration_Date__c,
                                                   genesis__Status__c,
                                                   genesis__Expected_Close_Date__c, 
                                                   CL_Contract_Status__c 
                                                   From genesis__Applications__c];
        Set<Id> appId = new Set<Id>();
        for(genesis__Applications__c app : applist1){
            appId.add(app.id);
        }
        
        Test.startTest();
        ApptoContractConverterBatchJob job = new ApptoContractConverterBatchJob(appId);
        job.Start(null);
        job.Execute(null,appList1);
        ID batchprocessid = Database.executeBatch(job);
        job.finish(null);
        Test.stopTest();
        system.assert(batchprocessid!=null);
        system.assertEquals(true,appList1!=null);       
    }
    
}