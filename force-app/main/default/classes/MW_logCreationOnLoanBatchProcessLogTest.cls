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

    @isTest
    static void testChangeLogLevel() {
        // Create test data
        List<loan__Batch_Process_Log__c> newRecords = new List<loan__Batch_Process_Log__c>();
        loan__Batch_Process_Log__c record1 = new loan__Batch_Process_Log__c(
            loan__message__c = 'Message: Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, This repayment transaction has already been reversed.: []'
        );
        record1.loan__Message__c = 'this is a test';
        record1.loan__Type__c = 'Error';
        loan__Batch_Process_Log__c record2 = new loan__Batch_Process_Log__c(
            loan__message__c = 'This is a test message containing the word Expected_logs for testing do not delete'
        );
        record2.loan__Message__c = 'this is a test';
        record2.loan__Type__c = 'Error';
        loan__Batch_Process_Log__c record3 = new loan__Batch_Process_Log__c(
            loan__message__c = 'This is a test message containing the word unexpected_logs for testing DO NOT delete'
        );
        record3.loan__Message__c = 'this is a test';
        record3.loan__Type__c = 'Error';
        newRecords.add(record1);
        newRecords.add(record2);
        newRecords.add(record3);

        // Call the function
        Test.startTest();
        Database.insert(newRecords, false);
        Test.stopTest();

        // Verify the results
        for (loan__Batch_Process_Log__c log : [
            SELECT id, loan__message__c, loan__Type__c
            FROM loan__Batch_Process_Log__c
        ]) {
            if (
                log.loan__message__c ==
                'This is a test message containing the word expected_logs for testing DO NOT delete'
            ) {
                System.assertEquals('Warning', log.loan__Type__c);
            }
            if (
                log.loan__message__c ==
                'This is a test message containing the word Expected_logs for testing do not delete'
            ) {
                System.assertEquals('Warning', log.loan__Type__c);
            }
            if (
                log.loan__message__c ==
                'This is a test message containing the word unexpected_logs for testing DO NOT delete'
            ) {
                System.assertEquals('Error', log.loan__Type__c);
            }
        }
    }
}