@isTest
public class TestApproveAppForFundingController {
    static testMethod void test_ApproveAppForFundingController(){
         loan.TestHelper.createSeedDataForTesting();
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        QueueSobject financeQue = [Select queue.id,queue.name,QueueID 
                                            from QueueSobject 
                                            where SobjectType ='genesis__Applications__c'                                   
                                            AND queue.Name =: 'Pre-Funding Queue'];
        genesis__Applications__c genesis_applications_Obj = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Status__c = 'pre_funding',
            genesis__Draw_Period_End_Date__c = system.Today(),
            OwnerId = financeQue.Queue.Id,
            genesis__APR__c = 173
        );
        Insert genesis_applications_Obj;
        genesis_applications_Obj.OwnerId = financeQue.Queue.Id;
        update genesis_applications_Obj;
        
        List<genesis__Applications__c> applist = new List<genesis__Applications__c>();
        applist.add(genesis_applications_Obj);
        
         Test.startTest();
        Test.setCurrentPage(Page.ApproveAppForFunding);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(applist);
        stdSetController.setSelected(applist);
        ApproveAppForFundingController ctopc = new ApproveAppForFundingController(stdSetController);
        ctopc.changeAppStatus();
        ctopc.updateApps();
        Test.stopTest();
    }
}