@isTest
private class MW_DeleteLastNDaysRecordsTest {
	@isTest static void DeleteLeadTest() {
		MW_Settings__c mwSetting = new MW_Settings__c();
		mwSetting.Leads_Clear_Days__c = 30;
		insert mwSetting;
		Lead testLead = new Lead(lastName = 'test', firstName = 'firstName', Company = 'test Company');
		insert testLead;
		Test.setCreatedDate(testLead.Id, DateTime.now().addDays(-31));
		Lead testLead2 = new Lead(lastName = 'test2', firstName = 'firstName2', Company = 'test2 Company');
		insert testLead2;
		Test.setCreatedDate(testLead2.Id, DateTime.now().addDays(-30));

		Test.startTest();

		//Run schedule jobs
		MW_DeleteLastNDaysRecords deleteSchedule = new MW_DeleteLastNDaysRecords();
		System.schedule('Delete Lead', '0 0 0 * * ?', deleteSchedule);

		//Run batch jobs
		MW_DeleteLastNDaysRecords BDel = new MW_DeleteLastNDaysRecords();
		Integer days = MW_Settings__c.getInstance().Leads_Clear_Days__c.intValue();
		BDel.query = 'SELECT id, CreatedDate FROM Lead WHERE CreatedDate < LAST_N_DAYS: ' + days;
		ID batchprocessid = Database.executeBatch(BDel, 75);
		Test.stopTest();

		List<Lead> remainingLead = [SELECT id FROM Lead];
		System.assertEquals(1, remainingLead.size());
	}
}