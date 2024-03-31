@isTest
private class MW_BackfillIncorrectTerminalStatusesTest {
    @testSetup
	private static void testData() {
        String leadId = '9ffffff9-9fff-f999-ff99-9f9f9f9f9f9f';
		Account acct = TestDataFactory.createTestAccount();
		insert acct;

		Account inv = TestDataFactory.createTestInvestor();
		inv.Investor_Code__c = 'TEST';
		insert inv;

		//Path One Default Documents -> Declined
		genesis__Applications__c application = TestDataFactory.createTestApplication(acct.Id, inv.Id, leadId, Date.today().addDays(2), 'Expired');
		insert application;

		genesis__Application_Status_History__c defaultHistory = new genesis__Application_Status_History__c();
		defaultHistory.genesis__Application__c = application.id;
		defaultHistory.genesis__New_Value__c = 'Expired';
		defaultHistory.genesis__Old_value__c = 'Withdrawn';
		defaultHistory.UpdatedByHMMW__c = true;
		insert defaultHistory;
		
		genesis__Application_Status_History__c defaultHistory1 = new genesis__Application_Status_History__c();
		defaultHistory1.genesis__Application__c = application.id;
		defaultHistory1.genesis__New_Value__c = 'Withdrawn';
		defaultHistory1.genesis__Old_value__c = 'Expired';
		insert defaultHistory1;
		
		genesis__Application_Status_History__c defaultHistory2 = new genesis__Application_Status_History__c();
		defaultHistory2.genesis__Application__c = application.id;
		defaultHistory2.genesis__New_Value__c = 'Expired';
		defaultHistory2.genesis__Old_value__c = 'Withdrawn';
		defaultHistory2.UpdatedByHMMW__c = true;
		insert defaultHistory2;

	}
	private static testMethod void testUpdate(){
	    
	    Test.startTest();
	    String whereClause = 'where genesis__Old_value__c IN (\'Withdrawn\',\'Decline_Manual_Review\',\'Declined\') AND genesis__New_Value__c = \'Expired\' order by CreatedDate DESC';
        MW_BackfillIncorrectTerminalStatuses mb = new MW_BackfillIncorrectTerminalStatuses(whereClause,'Update');
        Database.executeBatch(mb,200);
	    Test.stopTest();
	    
	}
	private static testMethod void testDelete(){
	    
	    Test.startTest();
	    String whereClause = 'where (genesis__Old_value__c = \'Expired\' AND genesis__New_Value__c IN (\'Withdrawn\',\'Decline_Manual_Review\',\'Declined\') AND CreatedbyId = \''+UserInfo.getUserId()+'\' AND CreatedDate = TODAY) OR UpdatedByHMMW__c = true order by CreatedDate DESC';
        MW_BackfillIncorrectTerminalStatuses mb = new MW_BackfillIncorrectTerminalStatuses(whereClause,'Delete');
        Database.executeBatch(mb,200);
	    Test.stopTest();
	    
	}

}