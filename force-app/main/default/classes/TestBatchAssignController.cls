@isTest
public class TestBatchAssignController {
    
    static testMethod void test_BatchAssignController(){
        loan.TestHelper.createSeedDataForTesting();
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        genesis__Applications__c genesis_applications_Obj = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Status__c = 'pre_funding',
            genesis__Draw_Period_End_Date__c = system.Today(),
            genesis__APR__c = 173
        );
        Insert genesis_applications_Obj;
        List<genesis__Applications__c> applist = new List<genesis__Applications__c>();
        applist.add(genesis_applications_Obj);
        
        User loggedUser = [select Id, Name,username, 
                           CompanyName,
                           loan__Current_Branch__c
                           from User where Id = :UserInfo.getUserId()];
        genesis__Applications__c app = new genesis__Applications__c();
        app.User_PreChecker__c = loggedUser.Id;
        app.User_Outbounder__c = loggedUser.Id;
        app.User_Processor__c = loggedUser.Id;
        app.User_Approver__c = loggedUser.Id;
        app.OwnerId = loggedUser.Id;
        app.genesis__Due_Day__c = 20;
        app.genesis__Expected_First_Payment_Date__c = system.Today();
        app.genesis__Expected_Start_Date__c = system.Today();
        app.genesis__Funding_in_Tranches__c = true;
        app.genesis__Status__c = 'pre_funding';
        app.genesis__Draw_Period_End_Date__c = system.Today();
        app.genesis__APR__c = 173;
        insert app;
        
        Test.startTest();
        Test.setCurrentPage(Page.ApproveAppForFunding);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(applist);
        stdSetController.setSelected(applist);
        BatchAssignController ctopc = new BatchAssignController(stdSetController);
        ctopc.app = app;
        ctopc.addUser();
        ctopc.updateApps();
        Test.stopTest();
    }

}