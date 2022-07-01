@isTest
public class ApplicationControllerTest {
    static testMethod void test_ApplicationController_UseCase1(){
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.createOffice();
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
        genesis__Amortization_Schedule__c amortSchedule = new genesis__Amortization_Schedule__c();
        amortSchedule.genesis__Due_Date__c = Date.today();
        amortSchedule.genesis__Total_Due_Amount__c = 120;
        amortSchedule.genesis__Due_Principal__c = 100;
        amortSchedule.genesis__Due_Interest__c = 20;
        amortSchedule.genesis__Payment_Number__c=1;
        amortSchedule.genesis__Application__c = genesis_applications_Obj.id;
        insert amortSchedule;
        ApplicationController testApplication = new ApplicationController();
    }
}