/*
 * This class is serves as a helper class to LogsCalloutBatch class with success and failure messages to slack.
 */
public class LogsCalloutBatchHelper{

    private static String hereStr = '<!here>';
    private static String whiteMark = ':white_check_mark: ';
    private static String alertSign = ':alert::alert::alert::alert::alert:';

    public static string failedFiles = '';
    public static void sendNACHALogs(Integer successCount, Integer failureCount, Integer totalCount){
        Map<String, Object> msg = new Map<String, Object>();        
        msg = (successCount == totalCount) ? getSuccessMessage(successCount,totalCount) : getFailureMessage(failureCount,totalCount);        
        sendSlackCallouts(JSON.serialize(msg));        
    }
    public static void sendNachaAlerts(List<Document> nachaDocs){
        string slackMentions = '';
        for(string userIds : MW_Settings__c.getInstance().Slack_mentions_for_Nacha_alert__c.split(',')){
            slackMentions += '<@' + userIds + '> ';
        }
        Map<String, Object> msgMap = new Map<String, Object>();        
        msgMap.put('text', hereStr + whiteMark + '*' + nachaDocs.size() +' NACHA FILES were created today * cc ' + slackMentions);                      
        sendSlackCallouts(JSON.serialize(msgMap));
    }

    public static void sendSuccesNightlyJobAlerts(Datetime startTime){
        string slackMentions = '';
        for(string userIds : MW_Settings__c.getInstance().Slack_mentions_for_Nacha_alert__c.split(',')){
            slackMentions += '<@' + userIds + '> ';
        }
        Map<String, Object> msgMap = new Map<String, Object>();        
        msgMap.put('text', hereStr + whiteMark +' Nightly Jobs complete successfully:\n'+ 
                                                'Start time: ' + String.valueOf(startTime) + '\n' + 
                                                'Finish time: ' + String.valueOf(System.now()) + '\n' + 
                                                'cc ' + slackMentions);                      
        sendSlackCallouts(JSON.serialize(msgMap));
    }

    public static void sendFailureNightlyJobAlerts(List<String> apexClassList, Datetime startTime){
        string slackMentions = '';
        for(string userIds : MW_Settings__c.getInstance().Slack_mentions_for_Nacha_alert__c.split(',')){
            slackMentions += '<@' + userIds + '> ';
        }

        Map<String, Object> msgMap = new Map<String, Object>();
        msgMap.put('text', hereStr + alertSign + ' Nightly jobs complete:\n' + 
                                                        'Start time: ' + String.valueOf(startTime) + '\n'+ 
                                                        'Finish time: ' + String.valueOf(System.now()) + '\n'+ 
                                                        'Failed Jobs:' + String.join(apexClassList, ' , ') + '\n'+ 
                                                        'cc: ' + slackMentions);    
        sendSlackCallouts(JSON.serialize(msgMap)); 
    }

    public static Map<String, Object> getFailureMessage(Integer failureCount,Integer totalCount){
        Map<String, Object> msgMap = new Map<String, Object>();
        msgMap.put('text', hereStr + alertSign + '\n' + '*' + failureCount + '/'+ totalCount +' NACHA FILES FAILED to UPLOAD TO BOX*');        
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