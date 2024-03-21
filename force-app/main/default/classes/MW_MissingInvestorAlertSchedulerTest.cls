@isTest
public class MW_MissingInvestorAlertSchedulerTest {
  @testSetup
    static void setupTestData() {
        genesis__Applications__c setting = MW_GlobalTestUtility.GetApplication();
        insert setting;
}
    
  @isTest
    static void testMW_InvestorAlertsScheduler() {
        Test.startTest();
        String chron = '0 59 * * * ?';
        Id scheduleId = System.schedule('Test testMW_AlertsScheduler', chron, new MW_MissingInvestorAlertScheduler(200));
        System.assertNotEquals(null, scheduleId);
        Test.stopTest();
    }

 }