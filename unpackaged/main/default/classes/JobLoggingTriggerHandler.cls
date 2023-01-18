public without sharing class JobLoggingTriggerHandler{
 final List<clcommon__Job_Logging__c> newRecords;
    final Map<Id, clcommon__Job_Logging__c> oldMap;
    final Map<Id, clcommon__Job_Logging__c> newMap;
    List<String> folderName = new List<String>();

    public JobLoggingTriggerHandler(List<clcommon__Job_Logging__c> pNewRecords, Map<Id, clcommon__Job_Logging__c> pNewMap) {
        this.newRecords = pNewRecords;
        this.newMap = pNewMap;
    }
    public void afterInsertUpdate() {
        checkAndSendNachaJobNotifications(newRecords[0]);
    }

    public void checkAndSendNachaJobNotifications(clcommon__Job_Logging__c newRecord){
        String msg = '';
        clcommon__Job_Logging__c jobLog = newRecord;
        if(jobLog.clcommon__Label__c == 'Loan Payment Filegen' && jobLog.clcommon__Status__c == 'Success'){
            for(loan__Automated_Payment_Configuration__c apc : [ SELECT Id,name,loan__Folder_Name__c,Box_Folder_ID__c  FROM loan__Automated_Payment_Configuration__c
                                                            WHERE loan__Folder_Name__c != null and Box_Folder_ID__c != null])
           {
               folderName.add(apc.loan__Folder_Name__c);           
           }
           
           String queryString = 'SELECT count() FROM Document WHERE Folder.Name IN : folderName AND CreatedDate = Today'; 
           Integer totalCount = Database.countQuery(queryString);
           
            msg += '@here Loan Payment Filegen completed successfully with ' + totalCount + ' files';
            
            string slackMentions = '';
            for(string userIds : MW_Settings__c.getInstance().Slack_mentions_for_Nacha_alert__c.split(',')){
                slackMentions += '<@' + userIds + '> ';
            }
            
            Map<String, Object> msgMap = new Map<String, Object>();
            msgMap.put('text', '<!here>' + ':white_check_mark: ' + '*' + totalCount +' NACHA FILES created today*' + slackMentions);                      
        
            String msgStr = JSON.serialize(msgMap);
            sendSlackCalls(msgStr);
        }
    }
    @future(callout=true)
    public static void sendSlackCalls(String msg){
        if(!Test.isRunningTest()) { 
            MW_SlackCallOut.slackCallOut(MW_Settings__c.getInstance().lsp_team_slack_channel_webhook__c, msg);
        }
    }
    
}