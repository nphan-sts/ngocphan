@isTest
private class MC_ContactHandlerTest {

    @isTest static void test_contact_status_update() {
        list<account> accList = MW_DataFactoryTest.createAccounts(1);
        insert accList;

        contact newContact = new contact();
        newContact.lastName = 'test';
        newContact.AccountID = accList[0].id;
        newContact.Application__c = null;
        newContact.Application_Status_New__c = null;
        insert newContact;

        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;
        newContact.Application__c = appList[0].id;
        newContact.Application_Status_New__c = appList[0].genesis__Status__c;
        update newContact;
        contact updatedContact = [Select id, lastName, AccountID, Application__c, Application_Status_New__c From contact Where id =: newContact.id];
        System.assertEquals(appList[0].id, updatedContact.Application__c);
        System.assertEquals(appList[0].genesis__Status__c, updatedContact.Application_Status_New__c);

        appList[0].genesis__Status__c = 'REJECTED';
        update appList[0];

        contact updatedContact2 = [Select id, lastName, AccountID, Application__c, Application_Status_New__c From contact Where id =: newContact.id];
        System.assertEquals(appList[0].id, updatedContact2.Application__c);
        //System.assertEquals('REJECTED', updatedContact2.Application_Status_New__c);

    }
}