/*
 * This class is serves as a context separator between DML operations and callouts  
 * Currently it is being used in UploadNachaToBoxJob for sending out the logs to Slack.
 */

global class LogsCalloutBatch implements Database.batchable<sObject>,Database.AllowsCallouts{
    global String queryStr;
    global Integer totalCount = 0;
    global Integer successCount = 0;
    global Integer failureCount = 0;
    global List<String> folderName;
    global Boolean failed = false;
    global Integer remainingCount;
    global set<Id> qryIds;
    global List<loan__Automated_Payment_Configuration__c> apcList;
    global Datetime startTime;
    
    global LogsCalloutBatch(List<loan__Automated_Payment_Configuration__c> apcList, Datetime startTime){
        this.apcList = apcList; 
        this.startTime = startTime;
        folderName = new List<String>();

        for(loan__Automated_Payment_Configuration__c apc : apcList){
           folderName.add(apc.loan__Folder_Name__c);
       }
       queryStr = 'SELECT Id,Name,Description,FolderId,Folder.Name,Body FROM Document WHERE CreatedDate = TODAY and Folder.Name IN : folderName and Description = null'+(Test.isRunningTest()?' LIMIT 1':'');           
    }
    global LogsCalloutBatch(List<String> folderName,Integer totalCount,set<Id> successIds, set<Id> failedIds){
       this.totalCount = totalCount;
       this.folderName = folderName;
       successCount = successIds.size();
       failureCount = failedIds.size();
       qryIds = new set<Id>();
       qryIds = (successCount == totalCount) ? successIds : failedIds;
       queryStr = 'SELECT Id FROM Document WHERE Id IN : qryIds';
    }
        
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(queryStr);    
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        /* This was added just for sending Nacha file count alert */
        if(apcList != null && apcList.size() > 0){
            LogsCalloutBatchHelper.sendSlackMessage(String.valueOf(((List<Document>)scope).size()) +' NACHA FILES were created today ', startTime);
        }else{
            LogsCalloutBatchHelper.sendNACHALogs(successCount,failureCount,totalCount);
        }
    }

    global void finish(Database.BatchableContext bc) {
        if(failureCount > 0){
            UploadNachaToBoxJob upJob = new UploadNachaToBoxJob();
            if(!Test.IsRunningTest()){
                System.scheduleBatch(upJob, 'Retry UploadNachaToBoxJob', 5, 1); 
            } 
        } 
    }
}