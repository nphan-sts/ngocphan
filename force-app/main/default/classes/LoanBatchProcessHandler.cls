public with sharing class LoanBatchProcessHandler {
    final List<loan__Batch_Process_Log__c> newRecords;
    final Map<Id, loan__Batch_Process_Log__c> oldMap;
    final Map<Id, loan__Batch_Process_Log__c> newMap;

    private static String apexClass = 'loan__Batch_Process_Log__c';
    private static String label = 'Batch Process Log';

    private final static List<String> EXPECTED_LOGS = System.Label.ChangeLogLevelList.split(';');

    public LoanBatchProcessHandler(
        List<loan__Batch_Process_Log__c> newRecords,
        Map<Id, loan__Batch_Process_Log__c> newMap,
        Map<Id, loan__Batch_Process_Log__c> oldMap
    ) {
        this.newRecords = newRecords;
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

    public void beforeInsert() {
        changeLogLevel(newRecords);
    }
    public void afterInsert() {
        sendLog(newRecords);
    }
    public void afterUpdate() {
        sendLog(newRecords);
    }

    public void sendLog(List<loan__Batch_Process_Log__c> newRecords) {
        for (loan__Batch_Process_Log__c entry : newRecords) {
            String type = '';
            if (entry.loan__Type__c == 'Exception') {
                type = 'Error';
            } else if (entry.loan__Type__c == 'Warning') {
                type = entry.loan__Type__c;
            } else if (String.isBlank(entry.loan__Type__c) == true) {
                type = 'Warning';
            } else {
                type = 'Info';
            }

            new MW_LogTriggerHelper().construct(entry.Name, apexClass, label, type, JSON.serialize(entry));
        }
    }

    public void changeLogLevel(List<loan__Batch_Process_Log__c> newRecords) {
        String joinedExpectedLogs = '(?i)' + String.join(EXPECTED_LOGS, '|'); //case in-sensitive;
        Pattern p = Pattern.compile(joinedExpectedLogs);

        for (loan__Batch_Process_Log__c entry : newRecords) {
            if (p.matcher(entry.loan__message__c).find()) {
                entry.loan__Type__c = 'Warning';
            }
        }
    }
}