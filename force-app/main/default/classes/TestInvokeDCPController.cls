@isTest
public class TestInvokeDCPController {
    
	@isTest
    public static void test_InvokeDCPControllee(){
        QueueSobject financeQue = [Select queue.id,queue.name,QueueID 
                                            from QueueSobject 
                                            where SobjectType ='genesis__Applications__c'                                   
                                            AND queue.DeveloperName =: 'Funding_Queue'];
        
        genesis__Applications__c genesis_applications_Obj = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Status__c = 'funded',
            genesis__Draw_Period_End_Date__c = system.Today(),
            OwnerId = financeQue.Queue.Id,
            Application_Start_DateV2__c = system.Today(),
            Employment_Status__c    = 'Full Time',
            genesis__Loan_Amount__c = 1000,
            genesis__APR__c = 173
        );
        Insert genesis_applications_Obj;
        genesis_applications_Obj.OwnerId = financeQue.Queue.Id;
        update genesis_applications_Obj;
        
        List<genesis__Applications__c> applist = new List<genesis__Applications__c>();
        applist.add(genesis_applications_Obj);
        
        Test.startTest();
        Test.setCurrentPage(Page.InvokeDCP);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(applist);
        stdSetController.setSelected(applist);
        InvokeDCPController obj = new InvokeDCPController(stdSetController);
        obj.invokeDCP();
        obj.callDCP();
        Test.stopTest();
    }
    
}