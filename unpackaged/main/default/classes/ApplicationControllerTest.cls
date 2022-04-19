/* ****************Modification History******************
* Updated By        Date			 Jira Number
*1. Bhanupriya       2022/03/07     LSP-589 (add comments,add test.start() and test.stop() methods and add assert statement)
******************Modification History******************/
@isTest
public class ApplicationControllerTest {
    static testMethod void appController(){
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.createOffice();
        //create application
        genesis__Applications__c genesis_applications_Obj = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Draw_Period_End_Date__c = system.Today(),
            genesis__APR__c = 173,
            Origination_fee__c = 100.2345
        );
        Insert genesis_applications_Obj;
       
        PageReference pageRef = Page.TILDocument;
        Test.setCurrentPage(pageRef);
        List<Id> applist = new List<Id>();
        applist.add(genesis_applications_Obj.Id);
        pageRef.getParameters().put('Id', String.valueOf(genesis_applications_Obj.Id));
        //genesis.AutoGenerateSchedule.generateSchedule(applist);
        //create Amortization Schedule
        genesis__Amortization_Schedule__c amortSchedule = new genesis__Amortization_Schedule__c();
        amortSchedule.genesis__Due_Date__c = Date.today();
        amortSchedule.genesis__Total_Due_Amount__c = 120;
        amortSchedule.genesis__Due_Principal__c = 100;
        amortSchedule.genesis__Due_Interest__c = 20;
        amortSchedule.genesis__Payment_Number__c=1;
        amortSchedule.genesis__Application__c = genesis_applications_Obj.id;
        insert amortSchedule;
        
        test.startTest();
        ApplicationController testApplication = new ApplicationController();
        test.stopTest();
        system.debug('Application'+testApplication);
        list<genesis__Applications__c> app = [select id, 
                                              Origination_fee__c,
                                              genesis__APR__c 
                                              from genesis__Applications__c];
        system.debug('after genis' +app[0].Origination_fee__c);
        system.debug('pag'+pageRef);
        system.assert(app[0].genesis__APR__c!=null);
        system.assertEquals(app.size(),1);
        
    }
}