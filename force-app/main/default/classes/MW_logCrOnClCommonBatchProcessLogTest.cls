@isTest
public class MW_logCrOnClCommonBatchProcessLogTest {
	@isTest
	static void insertInfo() {
		// Test data setup

		clcommon__Batch_Process_Log__c log = new clcommon__Batch_Process_Log__c();
		log.clcommon__Type__c = 'Info';

		// Perform test
		Test.startTest();
		Database.SaveResult result = Database.insert(log, false);
		Test.stopTest();
		// Verify
		System.assert(result.isSuccess(), 'inserted');
		System.assert(result.getErrors().size() == 0, 'no errors');
	}

	@isTest
	static void insertError() {
		// Test data setup

		clcommon__Batch_Process_Log__c log = new clcommon__Batch_Process_Log__c();
		log.clcommon__Type__c = 'Exception';

		// Perform test
		Test.startTest();
		Database.SaveResult result = Database.insert(log, false);

		Test.stopTest();
		// Verify
		System.assert(result.isSuccess(), 'inserted');
		System.assert(result.getErrors().size() == 0, 'no errors');
	}

	@isTest
	static void insertWarning() {
		// Test data setup
		clcommon__Batch_Process_Log__c log = new clcommon__Batch_Process_Log__c();
		log.clcommon__Type__c = 'Warning';

		// Perform test
		Test.startTest();
		Database.SaveResult result = Database.insert(log, false);

		Test.stopTest();
		// Verify
		System.assert(result.isSuccess(), 'inserted');
		System.assert(result.getErrors().size() == 0, 'no errors');
	}
}