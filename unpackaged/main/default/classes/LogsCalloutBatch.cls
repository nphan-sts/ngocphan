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
        LogsCalloutBatchHelper.sendNACHALogs(successCount,failureCount,totalCount);
    }
    global void finish(Database.BatchableContext bc) {
    }
}