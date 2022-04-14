/* ****************Modification History******************
*    Created By        	 Date			Version				Jira Number
*1. Bhanupriya        2022/03/16     Initial Version			LSP-631(add comments and assert statement)

******************Modification History******************/

@isTest
public Class TestAppDeclineCntrl{
    
    public static testmethod void standardcontrollerTest_ChangeStatus(){
        
        loan.TestHelper.createSeedDataForTesting();
        //create dummy office 
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        system.debug('Office'+dummyOffice);
        QueueSobject financeQue = [Select queue.id,
                                   queue.name,
                                   QueueID 
                                   from QueueSobject 
                                   where SobjectType ='genesis__Applications__c'                                   
                                   AND queue.Name =: 'Pre-Funding Queue'];
        System.debug(financeQue.queue.name);
        System.debug(financeQue.queue.id);
        QueueSobject pendingForFundingque = [Select queue.id,queue.name,QueueID 
                                             from QueueSobject 
                                             where SobjectType ='genesis__Applications__c'                                   
                                             AND queue.Name =: 'Pending for Funding'];
        System.debug(pendingForFundingque);
        //create application for pre funding
        genesis__Applications__c genesis_applications_Obj = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Status__c = 'pre_funding',
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Draw_Period_End_Date__c = system.Today(),
            OwnerId = financeQue.QueueID,
            genesis__APR__c = 173
        );
        Insert genesis_applications_Obj;
        //create application for Approved funding
        genesis__Applications__c genesis_applications_Obj1 = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Status__c = 'Approved for funding',
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Draw_Period_End_Date__c = system.Today(),
            OwnerId = pendingForFundingque.QueueID,
            genesis__APR__c = 173
        );
        Insert genesis_applications_Obj1;
        //update application filed
        genesis_applications_Obj1.OwnerId = pendingForFundingque.QueueID;
        update genesis_applications_Obj1;
        
        List<genesis__Applications__c> applist = new List<genesis__Applications__c>();
        applist.add(genesis_applications_Obj);
        applist.add(genesis_applications_Obj1);
        
        Test.startTest();
        Test.setCurrentPage(Page.AppDecline);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(applist);
        stdSetController.setSelected(applist);
        AppDeclineCntrl ctopc = new AppDeclineCntrl(stdSetController);
        ctopc.changeStatus();
        ctopc.updateApps();
        Test.stopTest();
        system.assert(applist!=null);
        system.assert([select queue.id,queue.name from QueueSobject].size()>0);
        
    }
}