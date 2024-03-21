@isTest
private class MW_PostDocuSignDocsSchedulerTest {

    @testSetup
    static void setupTestData() {
        genesis__Applications__c app = MW_GlobalTestUtility.GetApplication();
        app.genesis__Status__c = 'Approved for Funding';
        app.DocuSign_Sign_Date__c = system.today();
        insert app;
        
        list<genesis__Application_Document_Category__c> adcList = new list<genesis__Application_Document_Category__c>();
        genesis__Application_Document_Category__c adc1 = MW_GlobalTestUtility.GetApplicationDocumentCategory();
        adc1.genesis__Application__c = app.id;
        adcList.add(adc1);
        
        genesis__Application_Document_Category__c adc2 = MW_GlobalTestUtility.GetApplicationDocumentCategory();
        adc2.genesis__Application__c = app.id;
        adc2.name = 'Payoff Member Agreement';
        adcList.add(adc2);
        
        insert adcList;
    }

    @isTest
    static void testMW_AlertsScheduler() {
        Test.startTest();
        String chron = '0 0 23 * * ?';
        MW_PostDocuSignDocsScheduler mpd = new MW_PostDocuSignDocsScheduler(5);
        Id scheduleId = System.schedule('Test MW_PostDocuSignDocsScheduler', chron, mpd);
        System.assertNotEquals(null, scheduleId);
        Test.stopTest();
    }
}