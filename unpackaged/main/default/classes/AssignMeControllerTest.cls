@isTest
public with sharing class AssignMeControllerTest {
    @isTest static void controllerTest(){

        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName',
            peer__Last_Name__c='TestLName', 
            City__c='TestCity',
            State__c='TestState',
            ZIP_Code__c='123456789'
            );
        insert acc;
        

        List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
        genesis__Applications__c app= new genesis__Applications__c(
                                            genesis__Due_Day__c = 20,
                                            genesis__Expected_First_Payment_Date__c = system.Today(),
                                            genesis__Expected_Start_Date__c = system.Today(),
                                            genesis__Funding_in_Tranches__c = true,
                                            Borrower_s_Email__c = null,
                                           
                                            Application_Start_DateV2__c = system.Today(),
                                            DocuSignFlag__c=true,
                                            genesis__Status__c = 'agent_verified',
                                            genesis__Draw_Period_End_Date__c = system.Today()
                                            );
        appList.add(app);
        insert appList;
        
        
        test.startTest();
        PageReference pageRef = page.AssignTome;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(appList);
        AssignMeController ct = new AssignMeController(sc);
        ct.onLoad();
        test.stopTest();
  
    }
   

}