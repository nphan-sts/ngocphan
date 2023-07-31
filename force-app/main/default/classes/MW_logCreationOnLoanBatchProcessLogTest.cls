@isTest
public class MW_logCreationOnLoanBatchProcessLogTest {
	@isTest
	static void insertInfo() {
		// Test data setup
		loan__Batch_Process_Log__c log = new loan__Batch_Process_Log__c();
		log.loan__Message__c = 'this is a test';
		log.loan__Type__c = 'Info';

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
		loan__Batch_Process_Log__c log = new loan__Batch_Process_Log__c();
		log.loan__Message__c = 'this is a test';
		log.loan__Type__c = 'Failure';

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
		loan__Batch_Process_Log__c log = new loan__Batch_Process_Log__c();
		log.loan__Message__c = 'this is a test';
		log.loan__Type__c = 'Warning';

		// Perform test
		Test.startTest();
		Database.SaveResult result = Database.insert(log, false);

		Test.stopTest();
		// Verify
		System.assert(result.isSuccess(), 'inserted');
		System.assert(result.getErrors().size() == 0, 'no errors');
	}
}