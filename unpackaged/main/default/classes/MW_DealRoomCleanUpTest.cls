@isTest
private class MW_DealRoomCleanUpTest {

	@isTest static void DeleteADCTest() {
		//Data Setup
		String leadId = '9ffffff9-9fff-f999-ff99-9f9f9f9f9f9f';
		String boxUrl = 'https://test.app.box.com/file/00000000000';
		Account acct = TestDataFactory.createTestAccount();
		insert acct;

		Account inv = TestDataFactory.createTestInvestor();
		inv.Investor_Code__c = 'TEST';
		insert inv;

		//Path One Default Documents -> Declined
		genesis__Applications__c application = TestDataFactory.createTestApplication(acct.Id, inv.Id, leadId, Date.today().addDays(2), 'Declined');
		insert application;

		genesis__Application_Status_History__c defaultHistory = new genesis__Application_Status_History__c();
		defaultHistory.genesis__Application__c = application.id;
		defaultHistory.genesis__New_Value__c = 'Default Documents';
		defaultHistory.IsADCDeleted__c = false;
		insert defaultHistory;

		genesis__Application_Status_History__c declinedHistory = new genesis__Application_Status_History__c();
		declinedHistory.genesis__Application__c = application.id;
		declinedHistory.genesis__New_Value__c = 'Declined';
		declinedHistory.genesis__Old_value__c = 'Default Documents';
		defaultHistory.IsADCDeleted__c = false;
		insert declinedHistory;

		//Path Two Default Documents -> Declined -> Expired
		genesis__Applications__c application2 = TestDataFactory.createTestApplication(acct.Id, inv.Id, leadId, Date.today().addDays(2), 'Declined');
		insert application2;

		genesis__Application_Status_History__c defaultHistory2 = new genesis__Application_Status_History__c();
		defaultHistory2.genesis__Application__c = application2.id;
		defaultHistory2.genesis__New_Value__c = 'Default Documents';
		defaultHistory2.IsADCDeleted__c = false;
		insert defaultHistory2;

		genesis__Application_Status_History__c declinedHistory2 = new genesis__Application_Status_History__c();
		declinedHistory2.genesis__Application__c = application2.id;
		declinedHistory2.genesis__New_Value__c = 'Declined';
		declinedHistory2.genesis__Old_value__c = 'Default Documents';
		declinedHistory2.IsADCDeleted__c = false;
		insert declinedHistory2;

		genesis__Application_Status_History__c expiredHistory = new genesis__Application_Status_History__c();
		expiredHistory.genesis__Application__c = application2.id;
		expiredHistory.genesis__New_Value__c = 'Expired';
		expiredHistory.genesis__Old_value__c = 'Declined';
		expiredHistory.IsADCDeleted__c = false;
		insert expiredHistory;

		clcommon__Party_Type__c partyType = TestDataFactory.createTestPartyType('BORROWER');
		insert partyType;

		genesis__Document_Category__c docCat = TestDataFactory.createTestDocumentCategory(partyType.Id, 'Verification Documents');
		insert docCat;

		genesis__Application_Document_Category__c appDocCat = TestDataFactory.createTestApplicationDocumentCategory('Verification Documents', application.Id, docCat.Id, boxUrl, 'OPEN');
		insert appDocCat;

		genesis__Application_Document_Category__c appDocChild = TestDataFactory.createTestApplicationDocumentCategory('PayStub', application.Id, docCat.Id, boxUrl, 'OPEN');
		appDocChild.genesis__Parent_Application_Document_Category__c = appDocCat.id;
		insert appDocChild;

		Test.startTest();

		MW_DealRoomCleanUp asyncJobSchedule = new MW_DealRoomCleanUp();
		System.schedule('DealRoomCleanUpTest', '0 0 0 * * ?', asyncJobSchedule);
		asyncJobSchedule.execute(null, new List<genesis__Applications__c>{application, application2});
		Test.stopTest();
		List<genesis__Application_Document_Category__c> deletedDocs = [Select id, name, genesis__Application__c From genesis__Application_Document_Category__c Where genesis__Application__c =: application.id];
		System.assertEquals(0, deletedDocs.size());
	}

}