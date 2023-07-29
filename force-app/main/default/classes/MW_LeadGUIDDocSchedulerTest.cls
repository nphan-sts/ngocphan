@isTest
private class MW_LeadGUIDDocSchedulerTest {

	@isTest static void testMW_LeadGUIDBoxFolderScheduler(){
		Test.startTest();
		String chron = '0 0 23 * * ?';
		Id scheduleId = System.schedule('Test MW_LeadGUIDBoxFolderScheduler', chron, new MW_LeadGUIDBoxFolderScheduler());
		System.assertNotEquals(null, scheduleId);
		Test.stopTest();
	}

	@isTest static void testMW_LeadGUID_XXScheduler(){
		Test.startTest();
		String chron = '0 0 23 * * ?';
		Id scheduleId = System.schedule('Test MW_LeadGUIDBoxFolderScheduler', chron, new MW_LeadGUID_XXScheduler());
		System.assertNotEquals(null, scheduleId);
		Test.stopTest();
	}

	@isTest static void testMW_OriginationDocuments_AppDocsScheduler(){
		Test.startTest();
		String chron = '0 0 23 * * ?';
		Id scheduleId = System.schedule('Test MW_LeadGUIDBoxFolderScheduler', chron, new MW_OriginationDocs_AppScheduler());
		System.assertNotEquals(null, scheduleId);
		Test.stopTest();
	}
	
	@isTest static void testMW_OriginationDocuments_AppDocsScheduler_Manual(){
		Test.startTest();
		Set<String> appStatus = new Set<String>{'Decline_Manual_Review', 'Declined'};
		String selectAppsBy = 'AppCreatedDate';
		String appStartDate = 'YESTERDAY';
		String appEndDate = 'YESTERDAY';
		String chron = '0 0 23 * * ?';
		Id scheduleId = System.schedule('Test MW_OriginationDocuments_AppDocsScheduler_Manual', chron, new MW_OriginationDocs_AppScheduler_Manual(selectAppsBy, appStartDate, appEndDate, appStatus));
		System.assertNotEquals(null, scheduleId);
		Test.stopTest();
	}

	@isTest static void testMW_OriginationDocuments_AppDocsDeclinedScheduler(){
		Test.startTest();
		String chron = '0 0 23 * * ?';
		Id scheduleId = System.schedule('Test MW_LeadGUIDBoxFolderScheduler', chron, new MW_OriginationDocs_AppDeclnScheduler());
		System.assertNotEquals(null, scheduleId);
		Test.stopTest();
	}

	@isTest static void testMW_OriginationDocuments_OrgiDocScheduler(){
		Test.startTest();
		String chron = '0 0 23 * * ?';
		Id scheduleId = System.schedule('Test MW_LeadGUIDBoxFolderScheduler', chron, new MW_OriginationDocs_OrgiScheduler());
		System.assertNotEquals(null, scheduleId);
		Test.stopTest();
	}

	@isTest static void testMW_OriginationDocuments_OrgiDocDeclinedScheduler(){
		Test.startTest();
		String chron = '0 0 23 * * ?';
		Id scheduleId = System.schedule('Test MW_LeadGUIDBoxFolderScheduler', chron, new MW_OriginationDocs_OrgiDeclnScheduler());
		System.assertNotEquals(null, scheduleId);
		Test.stopTest();
	}
}