public without sharing class NightlyDynamicAlertHandler implements Queueable {
    private String dagLogId;

    public NightlyDynamicAlertHandler(String dagLogId) {
        this.dagLogId = dagLogId;
    }

    public void execute(QueueableContext context) {
        List<clcommon__DAG_Logging__c> dagLogList = [
            SELECT
                id,
                name,
                clcommon__status__c,
                clcommon__start_time__c,
                clcommon__finish_time__c
            FROM clcommon__DAG_Logging__c
            WHERE Id = :dagLogId
            WITH SECURITY_ENFORCED
        ];

        sendSlackCallout(dagLogList);
    }

    public static void sendSlackCallout(
        List<clcommon__DAG_Logging__c> dagLogList
    ) {
        try {
            if (dagLogList.get(0).clcommon__Status__c == 'Success') {
                LogsCalloutBatchHelper.sendSlackMessage(
                    'Nightly Jobs complete successfully',
                    dagLogList.get(0).clcommon__Start_Time__c
                );
            } else {
                List<clcommon__Job_Logging__c> failedJobLogging = getJobLogging(
                    dagLogList.get(0).Id
                );

                if (failedJobLogging != null && failedJobLogging.size() > 0) {
                    List<String> apexClassList = new List<String>();

                    for (clcommon__Job_Logging__c jobLog : failedJobLogging) {
                        apexClassList.add(jobLog.clcommon__Label__c);
                    }

                    LogsCalloutBatchHelper.sendFailureNightlyJobAlerts(
                        failedJobLogging,
                        dagLogList.get(0).clcommon__Start_Time__c
                    );
                }
            }
        } catch (Exception e) {
            LogsCalloutBatchHelper.sendSlackCallouts(
                new Map<String, String>{
                    MW_Settings__c.getOrgDefaults()
                        .lsp_team_slack_channel_webhook__c => 'NightlyDynamicAlertHandler: ' +
                    String.valueOf(System.now() + ' ' + e.getMessage())
                }
            );
        }
    }

    private static List<clcommon__Job_Logging__c> getJobLogging(
        String dagLogId
    ) {
        List<clcommon__Job_Logging__c> jobLoggingList = [
            SELECT
                Id,
                clcommon__Status__c,
                clcommon__Label__c,
                (SELECT Id FROM clcommon__Thread_Loggings__r LIMIT 1)
            FROM clcommon__Job_Logging__c
            WHERE clcommon__DAG_Logging__c = :dagLogId
            WITH SECURITY_ENFORCED
        ];

        return jobLoggingList;
    }
}