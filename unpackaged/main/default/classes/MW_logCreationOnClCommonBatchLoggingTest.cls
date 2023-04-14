@isTest
public class MW_logCreationOnClCommonBatchLoggingTest {
	@isTest
	static void insertInfo() {
		// Test data setup
		clcommon__DAG_Logging__c dagLogging = new clcommon__DAG_Logging__c(
			clcommon__Status__c = 'Success'
		);
		insert dagLogging;

		clcommon__Job_Logging__c jobLogging = new clcommon__Job_Logging__c(
			clcommon__Status__c = 'Success',
			clcommon__DAG_Logging__c = dagLogging.Id
		);
		insert jobLogging;

		clcommon__Thread_Logging__c threadLogging = new clcommon__Thread_Logging__c(
			clcommon__Status__c = 'Success',
			clcommon__Job_Logging__c = jobLogging.Id
		);
		insert threadLogging;

		clcommon__Batch_Logging__c log = new clcommon__Batch_Logging__c();
		log.clcommon__Status__c = 'Success';
		log.clcommon__Thread_Logging__c = threadLogging.Id;

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
		clcommon__DAG_Logging__c dagLogging = new clcommon__DAG_Logging__c(
			clcommon__Status__c = 'Success'
		);
		insert dagLogging;

		clcommon__Job_Logging__c jobLogging = new clcommon__Job_Logging__c(
			clcommon__Status__c = 'Success',
			clcommon__DAG_Logging__c = dagLogging.Id
		);
		insert jobLogging;

		clcommon__Thread_Logging__c threadLogging = new clcommon__Thread_Logging__c(
			clcommon__Status__c = 'Success',
			clcommon__Job_Logging__c = jobLogging.Id
		);
		insert threadLogging;

		clcommon__Batch_Logging__c log = new clcommon__Batch_Logging__c();
		log.clcommon__Status__c = 'Failure';
		log.clcommon__Thread_Logging__c = threadLogging.Id;

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
		clcommon__DAG_Logging__c dagLogging = new clcommon__DAG_Logging__c(
			clcommon__Status__c = 'Success'
		);
		insert dagLogging;

		clcommon__Job_Logging__c jobLogging = new clcommon__Job_Logging__c(
			clcommon__Status__c = 'Success',
			clcommon__DAG_Logging__c = dagLogging.Id
		);
		insert jobLogging;

		clcommon__Thread_Logging__c threadLogging = new clcommon__Thread_Logging__c(
			clcommon__Status__c = 'Success',
			clcommon__Job_Logging__c = jobLogging.Id
		);
		insert threadLogging;

		clcommon__Batch_Logging__c log = new clcommon__Batch_Logging__c();
		log.clcommon__Thread_Logging__c = threadLogging.Id;

		// Perform test
		Test.startTest();
		Database.SaveResult result = Database.insert(log, false);

		Test.stopTest();
		// Verify
		System.assert(result.isSuccess(), 'inserted');
		System.assert(result.getErrors().size() == 0, 'no errors');
	}
}