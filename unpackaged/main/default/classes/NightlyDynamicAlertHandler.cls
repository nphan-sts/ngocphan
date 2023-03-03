public with sharing class NightlyDynamicAlertHandler {

    public static void sendSlackCallout(List<clcommon__DAG_Logging__c> dagLogList) {

        if(dagLogList.get(0).clcommon__Status__c == 'Success') {

            LogsCalloutBatchHelper.sendSuccesNightlyJobAlerts();
        }
        else {
            List<clcommon__Job_Logging__c> failedJobLogging = getJobLogging(dagLogList.get(0).Id);

            if (failedJobLogging != null && failedJobLogging.size() > 0) {

                List<clcommon__Thread_Logging__c> failedThreadLogging = getThreadLogging(failedJobLogging.get(0).Id);

                String apexClass = failedJobLogging.get(0).clcommon__Label__c;
                String log = failedThreadLogging.get(0).clcommon__Batch_Loggings__r.get(0).clcommon__Log__c;

                LogsCalloutBatchHelper.sendFailureNightlyJobAlerts(log, apexClass);
            }


        }

    }

    private static List<clcommon__Job_Logging__c> getJobLogging(String dagLogId) {

        List<clcommon__Job_Logging__c> jobLoggingList = [SELECT Id, clcommon__Status__c, clcommon__Label__c 
                                                        FROM clcommon__Job_Logging__c 
                                                        WHERE clcommon__DAG_Logging__c =: dagLogId AND clcommon__Status__c = 'Failure'
                                                        WITH SECURITY_ENFORCED
                                                        LIMIT 1];

        return jobLoggingList;

    }

    private static List<clcommon__Thread_Logging__c> getThreadLogging(String jobLoggingId) {
        List<clcommon__Thread_Logging__c> threadLogging = [SELECT Id,clcommon__Status__c,
                                                                        (SELECT Id, clcommon__Log__c, clcommon__Status__c FROM clcommon__Batch_Loggings__r WHERE clcommon__Status__c = 'Failure' LIMIT 1) 
                                                                    FROM clcommon__Thread_Logging__c
                                                                    WHERE  clcommon__Job_Logging__c =: jobLoggingId
                                                                    AND clcommon__Status__c = 'Failure'
                                                                    WITH SECURITY_ENFORCED
                                                                    LIMIT 1];
        return threadLogging;
    }

}