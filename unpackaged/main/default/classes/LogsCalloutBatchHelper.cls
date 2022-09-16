/*
 * This class is serves as a helper class to LogsCalloutBatch class with success and failure messages to slack.
 */
public class LogsCalloutBatchHelper{
    public static string failedFiles = '';
    public static void sendNACHALogs(Integer successCount, Integer failureCount, Integer totalCount){
        Map<String, Object> msg = new Map<String, Object>();        
        msg = (successCount == totalCount) ? getSuccessMessage(successCount,totalCount) : getFailureMessage(failureCount,totalCount);        
        if(!Test.isRunningTest()) {
            MW_SlackCallOut.slackCallOut(MW_Settings__c.getInstance().lsp_team_slack_channel_webhook__c, JSON.serialize(msg));
        }         
    }
    public static Map<String, Object> getFailureMessage(Integer failureCount,Integer totalCount){
        Map<String, Object> msgMap = new Map<String, Object>();
        msgMap.put('text', '<!here>'+':alert::alert::alert::alert::alert: \n' + '*' + failureCount + '/'+ totalCount +' NACHA FILES FAILED to UPLOAD TO BOX*');        
        return msgMap;        
    }
    public static Map<String, Object> getSuccessMessage(Integer successCount,Integer totalCount){
        Map<String, Object> msgMap = new Map<String, Object>();        
        msgMap.put('text', '<!here>'+':white_check_mark: ' + '*' + successCount + '/'+ totalCount +' NACHA FILES UPLOADED TO BOX*');                      
        return msgMap;        
    }
}