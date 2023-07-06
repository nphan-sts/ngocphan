/*
 * This class is serves as a helper class to LogsCalloutBatch class with success and failure messages to slack.
 */
public class LogsCalloutBatchHelper{

    private static String hereStr = '<!here>';
    private static String whiteMark = ':white_check_mark: ';
    private static String alertSign = ':alert::alert::alert::alert::alert:';
    private static String timeFormat = 'yyyy-MM-dd h:mm a';
    private static String timezone = 'PST';
    private static String startTimeStr = 'Start time: ';
    private static String finishTimeStr = 'Finish time: ';
    private static String newLineStr = '\n';
    private static String ccStr = 'cc: ';

    public static void sendNACHALogs(Integer successCount, Integer failureCount, Integer totalCount){
        Map<String, Object> msg = new Map<String, Object>();        
        msg = (successCount == totalCount) ? getSuccessMessage(successCount,totalCount) : getFailureMessage(failureCount,totalCount);        
        sendSlackCallouts(JSON.serialize(msg));    
    }

    /**
     *
        @here:white_check_mark: *1 NACHA FILES were created today* | Nightly Jobs complete successfully:
        Start time: 2023-03-06 11:40 PM PST
        Finish time: 2023-03-06 11:46 PM PST
        cc @Abhijeet Thorat
    */
    public static void sendSlackMessage(String msg, Datetime startTime){
        string slackMentions = '';
        for(string userIds : MW_Settings__c.getInstance().Slack_mentions_for_Nacha_alert__c.split(',')){
            slackMentions += '<@' + userIds + '> ';
        }
        Map<String, Object> msgMap = new Map<String, Object>();        
        msgMap.put('text', hereStr + whiteMark + msg + newLineStr +
                                                startTimeStr + startTime.format(timeFormat,timezone) + ' ' + timezone + newLineStr + 
                                                finishTimeStr + System.now().format(timeFormat,timezone) + ' ' + timezone + newLineStr +
                                                ccStr + slackMentions);                      
        sendSlackCallouts(JSON.serialize(msgMap));
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
    public static void sendFailureNightlyJobAlerts(List<String> apexClassList, Datetime startTime){
        string slackMentions = '';
        for(string userIds : MW_Settings__c.getInstance().Slack_mentions_for_Nacha_alert__c.split(',')){
            slackMentions += '<@' + userIds + '> ';
        }

        Map<String, Object> msgMap = new Map<String, Object>();
        msgMap.put('text', hereStr + alertSign + ' Nightly jobs complete:\n' + 
                                                        startTimeStr + startTime.format(timeFormat,timezone) + ' ' + timezone + newLineStr+ 
                                                        finishTimeStr + System.now().format(timeFormat,timezone) + ' ' + timezone + newLineStr+ 
                                                        'Failed Jobs:' + String.join(apexClassList, ' , ') + newLineStr + 
                                                        ccStr + slackMentions);    
        sendSlackCallouts(JSON.serialize(msgMap)); 
    }

    public static Map<String, Object> getFailureMessage(Integer failureCount,Integer totalCount){
        Map<String, Object> msgMap = new Map<String, Object>();
        msgMap.put('text', hereStr + alertSign + newLineStr + '*' + failureCount + '/'+ totalCount +' NACHA FILES FAILED to UPLOAD TO BOX*');        
        return msgMap;        
    }
    public static Map<String, Object> getSuccessMessage(Integer successCount,Integer totalCount){
        Map<String, Object> msgMap = new Map<String, Object>();        
        msgMap.put('text', hereStr + whiteMark + '*' + successCount + '/'+ totalCount +' NACHA FILES UPLOADED TO BOX*');                      
        return msgMap;        
    }
    public static void sendSlackCallouts(String msg){
        if(!Test.isRunningTest()) {
            SlackCall sc = new SlackCall(msg);

            System.enqueueJob(sc);
        } 
    }
}