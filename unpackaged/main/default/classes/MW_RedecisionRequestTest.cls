@isTest
private class MW_RedecisionRequestTest {

    @isTest static void accountRedecisionRequestTest() {
        Test.startTest();

        List<account> accList = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        
        
        
        List<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        appList[0].genesis__status__c = 'agent_document_verification_pending';
        insert appList;
        
        accList[0].peer__Date_of_Birth__c = accList[0].peer__Date_of_Birth__c.addDays(2);
        update accList[0];
        
        Redecision_Request__c rr = [SELECT Id,Application__c,Triggered_From__c FROM Redecision_Request__c WHERE Application__c =: appList[0].Id LIMIT 1];
        system.assertEquals('Account',rr.Triggered_From__c);

        Test.stopTest();
    }

    @isTest static void applicationRedecisionRequestTest() {
        Test.startTest();

        List<account> accList = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        
        List<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        appList[0].genesis__status__c = 'agent_document_verification_pending';
        insert appList;
        
        appList[0].Annual_Individual_Income_App__c = appList[0].Annual_Individual_Income_App__c + 500;
        update appList[0];

        Redecision_Request__c rr = [SELECT Id,Application__c,Triggered_From__c FROM Redecision_Request__c WHERE Application__c =: appList[0].Id LIMIT 1];
        system.assertEquals('Application',rr.Triggered_From__c);

        Test.stopTest();
    }
}