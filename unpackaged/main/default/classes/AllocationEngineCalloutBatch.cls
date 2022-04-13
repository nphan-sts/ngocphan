/**
 * For the constructor with String query parameter, you can pass any query to send final calls to a specific set of applications
 * This will help in case there's a failure and a final Allocation call is to be sent for some set of applications 
 * A sample query :  SELECT Id,genesis__status__c FROM genesis__applications__c WHERE Id IN 
 *                   (SELECT genesis__Application__c FROM genesis__Application_Status_History__c WHERE CreatedDate = TODAY AND 
 *                   genesis__New_Value__c = 'funded')
 */

global class AllocationEngineCalloutBatch implements Database.batchable<sObject>,Database.AllowsCallouts{
    public set<Id> appIdList;
    public String queryStr;
    
    global AllocationEngineCalloutBatch(String query){
       queryStr = query;
    }
    
    global AllocationEngineCalloutBatch(set<Id> appIdList){
        this.appIdList = appIdList;
        if(appIdList != null){
            queryStr = 'SELECT Id FROM genesis__Applications__c WHERE Id IN : appIdList AND genesis__status__c = \'funded\''; 
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){                              
        return Database.getQueryLocator(queryStr);    
    }
    
    global void Execute(Database.BatchableContext bc, List<genesis__Applications__c> scope) {
        List<Id> appIds = new List<Id>();
        if (MW_AllocationEngineHandler.isAllocationEngineServiceEnabled()) {
            for (genesis__Applications__c app : scope) {
                appIds.add(app.Id);
            }   
            MW_AllocationEngineHandler.handleFinal(appIds);
        }else{
            MW_LogUtility.info('AllocationEngineCalloutBatch','Execute','Allocation Engine is NOT enabled');
        }
    }
    public void finish(Database.BatchableContext bc) {
        
    }
}