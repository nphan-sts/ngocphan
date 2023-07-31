@isTest
public with sharing class MW_DeliveryStatusHandlerTest {

    @isTest static void testHandleStatus() {
        Account acct = TestDataFactory.createTestAccount();
        insert acct;

        Account inv = TestDataFactory.createTestInvestor();
        inv.Investor_Code__c = 'TEST';
        insert inv;

        genesis__Applications__c app = TestDataFactory.createTestApplication(acct.Id, inv.Id, '9ffffff9-9fff-f999-ff99-9f9f9f9f9f9f',
        Date.today().addDays(2), 'agent_document_verification_pending');

        app.Delivery_Partner_Code__c = 'CRB';
        app.Delivery_Id__c = '1234567890';
        app.Delivery_Status__c = 'Approved';
        app.Delivery_Processed_Date__c = null;
        insert app;

        Test.startTest();
        MW_DeliveryStatusHandler.handleStatus(app);
        Test.stopTest();

        System.assert(app.Delivery_Processed_Date__c != null);
    }
}