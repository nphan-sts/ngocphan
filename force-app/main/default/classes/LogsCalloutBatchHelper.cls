/*
 * This class is serves as a helper class to LogsCalloutBatch class with success and failure messages to slack.
 */
public without sharing class LogsCalloutBatchHelper {
    private static String hereStr = '<!here>';
    private static String whiteMark = ':white_check_mark: ';
    private static String alertSign = ':alert::alert::alert::alert::alert:';
    private static String timeFormat = 'yyyy-MM-dd h:mm a';
    private static String timezone = 'PST';
    private static String startTimeStr = 'Start time: ';
    private static String finishTimeStr = 'Finish time: ';
    private static String newLineStr = '\n';
    private static String ccStr = 'cc: ';

    public static void sendNACHALogs(
        Integer successCount,
        Integer failureCount,
        Integer totalCount
    ) {
        Map<String, Object> msg = new Map<String, Object>();
        msg = (successCount == totalCount)
            ? getSuccessMessage(successCount, totalCount)
            : getFailureMessage(failureCount, totalCount);
        sendSlackCallouts(
            new Map<String, String>{
                MW_Settings__c.getOrgDefaults()
                    .lsp_team_slack_channel_webhook__c => JSON.serialize(msg)
            }
        );
    }

    /**
     *
        @here:white_check_mark: *1 NACHA FILES were created today* | Nightly Jobs complete successfully:
        Start time: 2023-03-06 11:40 PM PST
        Finish time: 2023-03-06 11:46 PM PST
        cc @Abhijeet Thorat
    */
    public static void sendSlackMessage(String msg, Datetime startTime) {
        string slackMentions = '';
        for (
            string userIds : MW_Settings__c.getOrgDefaults()
                .Slack_mentions_for_Nacha_alert__c.split(',')
        ) {
            slackMentions += '<@' + userIds + '> ';
        }

        String message = '<!here> :white_check_mark: {0} \n Start time: {1} PST \n Finish time: {2} PST \n cc: {3}';

        String output = String.format(
            message,
            new List<String>{
                msg, // {0}
                startTime.format(timeFormat, timezone), // {1}
                System.now().format(timeFormat, timezone), // {2}
                slackMentions // {3}
            }
        );
        System.debug(output);

        Map<String, Object> msgMap = new Map<String, Object>();
        msgMap.put('text', output);
        sendSlackCallouts(
            new Map<String, String>{
                MW_Settings__c.getOrgDefaults()
                    .lsp_team_slack_channel_webhook__c => JSON.serialize(msg)
            }
        );
    }

    /**
     * 
        @here:alert::alert::alert::alert::alert: Nightly jobs complete:
        Start time: 2023-03-06 11:40 PM PST
        Finish time: 2023-03-06 11:46 PM PST
        Failed Jobs:StartOfDayDynamicJob,InterestPostingAmzDynamicJob,LoanPayoffPaymentTxnClearingDynamicJob
        cc: 
        @Abhijeet Thorat
     */
    public static void sendFailureNightlyJobAlerts(
        List<clcommon__Job_Logging__c> failedJobLogging,
        Datetime startTime
    ) {
        Map<String, String> mapThreadLogClassName = new Map<String, String>();

        List<String> apexClassList = new List<String>();

        for (clcommon__Job_Logging__c jobLog : failedJobLogging) {
            apexClassList.add(jobLog.clcommon__Label__c);
            if (
                jobLog.clcommon__Thread_Loggings__r != null &&
                jobLog.clcommon__Thread_Loggings__r.size() > 0
            ) {
                for (
                    clcommon__Thread_Logging__c threadLog : jobLog.clcommon__Thread_Loggings__r
                ) {
                    mapThreadLogClassName.put(
                        threadLog.Id,
                        jobLog.clcommon__Label__c
                    );
                }
            }
        }

        List<clcommon__Batch_Logging__c> batchLogList = [
            SELECT Id, clcommon__Log__c, clcommon__Thread_Logging__c
            FROM clcommon__Batch_Logging__c
            WHERE
                clcommon__Thread_Logging__c IN :mapThreadLogClassName.keySet()
                AND clcommon__Status__c = 'Failure'
            WITH SECURITY_ENFORCED
        ];

        Map<String, Object> msgMap = getMessageLPCchannel(
            apexClassList,
            startTime
        );

        Map<String, Object> msgMapForLoanOps = getMessageLoanOpschannel(
            batchLogList,
            mapThreadLogClassName
        );

        sendSlackCallouts(
            new Map<String, String>{
                MW_Settings__c.getOrgDefaults()
                    .lsp_team_slack_channel_webhook__c => JSON.serialize(
                    msgMap
                ),
                MW_Settings__c.getOrgDefaults()
                    .loan_ops_slack_channel_webhook__c => JSON.serialize(
                    msgMapForLoanOps
                )
            }
        );
    }

    public static Map<String, Object> getFailureMessage(
        Integer failureCount,
        Integer totalCount
    ) {
        String message = '<!here> :alert::alert::alert::alert::alert:* {0}/{1}  NACHA FILES FAILED to UPLOAD TO BOX*';

        String output = String.format(
            message,
            new List<String>{
                String.valueOf(failureCount), // {0}
                String.valueOf(totalCount) // {1},
            }
        );
        System.debug(output);

        Map<String, Object> msgMap = new Map<String, Object>();
        msgMap.put('text', output);

        return msgMap;
    }
    public static Map<String, Object> getSuccessMessage(
        Integer successCount,
        Integer totalCount
    ) {
        String message = '<!here> :white_check_mark:* {0}/{1} NACHA FILES UPLOADED TO BOX*';

        String output = String.format(
            message,
            new List<String>{
                String.valueOf(successCount), // {0}
                String.valueOf(totalCount) // {1},
            }
        );
        System.debug(output);

        Map<String, Object> msgMap = new Map<String, Object>();
        msgMap.put('text', output);

        return msgMap;
    }
    public static void sendSlackCallouts(Map<String, String> mapChannelMsg) {
        if (!Test.isRunningTest()) {
            SlackCall sc = new SlackCall(mapChannelMsg);

            System.enqueueJob(sc);
        }
    }

    private static Map<String, Object> getMessageLPCchannel(
        List<String> apexClassList,
        Datetime startTime
    ) {
        string slackMentions = '';
        for (
            string userIds : MW_Settings__c.getOrgDefaults()
                .Slack_mentions_for_Nacha_alert__c.split(',')
        ) {
            slackMentions += '<@' + userIds + '> ';
        }

        String message = '<!here> :alert::alert::alert::alert::alert: Nightly jobs complete: \n Start time: {0} PST \n Finish time: {1} PST \n Failed Jobs: {2} cc: {3}';

        String output = String.format(
            message,
            new List<String>{
                startTime.format(timeFormat, timezone), // {0}
                System.now().format(timeFormat, timezone), // {1},
                String.join(apexClassList, ' , '), // {2},
                slackMentions // {3}
            }
        );
        System.debug(output);

        Map<String, Object> msgMap = new Map<String, Object>();
        msgMap.put('text', output);

        return msgMap;
    }
    private static Map<String, Object> getMessageLoanOpschannel(
        List<clcommon__Batch_Logging__c> batchLogList,
        Map<String, String> mapThreadLogClassName
    ) {
        string slackMentions = '';
        for (
            string userIds : MW_Settings__c.getOrgDefaults()
                .Slack_mentions_for_loan_ops__c.split(',')
        ) {
            slackMentions += '<@' + userIds + '> ';
        }

        String errorLog = '';

        for (clcommon__Batch_Logging__c batchLog : batchLogList) {
            String message = 'Job {0} : Error {1}  \n -------------------- \n ';

            String output = String.format(
                message,
                new List<String>{
                    mapThreadLogClassName.get(
                        batchLog.clcommon__Thread_Logging__c
                    ), // {0}
                    batchLog.clcommon__Log__c // {1},
                }
            );
            errorLog += output;
        }

        String message = '<!here> Error(s):\n {0} cc: {1}';

        String output = String.format(
            message,
            new List<String>{
                errorLog, // {0}
                slackMentions // {1}
            }
        );
        System.debug(output);

        Map<String, Object> msgMap = new Map<String, Object>();
        msgMap.put('text', output);

        return msgMap;
    }
}