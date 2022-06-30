/* ****************Modification History*****************************************************************
* Modified by      		Date            JIRA number
* 1. Bhanupriya		 2022/03/18			LSP- 630(add comments , assert statement)
******************Modification History*****************************************************************/

@isTest
public class TestApproveAppForFundingController {
    //testmethod
    static testMethod void test_ApproveAppForFundingController(){
        
         	loan.TestHelper.createSeedDataForTesting();
        	loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        	system.debug('Dummy Office'+dummyOffice);
        	QueueSobject financeQue = [Select queue.id,queue.name,QueueID 
                                            from QueueSobject 
                                            where SobjectType ='genesis__Applications__c'                                   
                                            AND queue.Name =: 'Pre-Funding Queue'];
        		
        	//create dummy application 
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
        	//Update Application field
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
        	system.assertEquals(true,applist!=null);
        	
    }
}