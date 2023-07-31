@isTest
private class MW_AlertsSchedulerTest {

    @testSetup
    static void setupTestData() {
        MW_Settings__c setting = MW_GlobalTestUtility.GetSettings();
        insert setting;

        Account acct = MW_GlobalTestUtility.GetAccount('Investor');
        insert acct;
    }

    @isTest
    static void testMW_AlertsScheduler() {
        Test.startTest();
        String chron = '0 0 23 * * ?';
        Id scheduleId = System.schedule('Test testMW_AlertsScheduler', chron, new MW_AlertsScheduler());
        System.assertNotEquals(null, scheduleId);
        Test.stopTest();
    }
}