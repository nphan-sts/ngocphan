/*
 * This class is serves as a bridge between ApptoContractConverterBatchJob which converts the applications to contracts 
 * and MW_AllocationEngineHandler which sends the final callouts to Allocation Engine.
 * This class isolates the execution contexts between callout and DMLs from both the classes. Better logic separation.
 * Also it provides better control over the governor limits for Allocation Engine
 * For the constructor with String query parameter, you can pass any query to send final calls to a specific set of applications
 * This will help in case there's a failure and a final Allocation call is to be sent for some set of applications 
 * A sample query :  SELECT Id,genesis__status__c FROM genesis__applications__c WHERE Id IN 
 *                   (SELECT genesis__Application__c FROM genesis__Application_Status_History__c WHERE CreatedDate = TODAY AND 
 *                   genesis__New_Value__c = 'funded')
 */

global class AllocationEngineCalloutBatch implements Database.batchable<sObject>,Database.AllowsCallouts{
    public Set<Id> appIdList;
    public String queryStr;
    public String decisionLevel;

    global AllocationEngineCalloutBatch(String query, String decisionLevel){
        this.queryStr = query;
        this.decisionLevel = decisionLevel;
    }
    
    global AllocationEngineCalloutBatch(Set<Id> appIdList, String decisionLevel){
        this.appIdList = appIdList;
        this.decisionLevel = decisionLevel;
        if(appIdList != null){
            queryStr = 'SELECT Id FROM genesis__Applications__c WHERE Id IN : appIdList';
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){                              
        return Database.getQueryLocator(queryStr);    
    }
    
    global void execute(Database.BatchableContext bc, List<genesis__Applications__c> scope) {
        List<Id> appIds = new List<Id>();
        if (MW_AllocationEngineHandler.isAllocationEngineServiceEnabled()) {
            for (genesis__Applications__c app : scope) {
                appIds.add(app.Id);
            }
            if (MW_AllocationEngineHandler.FINALIZED == decisionLevel) {
                MW_AllocationEngineHandler.handleFinal(appIds);
            } else if (MW_AllocationEngineHandler.CANCELLED == decisionLevel) {
                MW_AllocationEngineHandler.handleCancelled(appIds);
            } else {
                MW_LogUtility.error('AllocationEngineCalloutBatch', 'Execute', 'Unsupported decision level ' + decisionLevel);
            }
        }else{
            MW_LogUtility.info('AllocationEngineCalloutBatch','Execute','Allocation Engine is NOT enabled');
        }
    }
    public void finish(Database.BatchableContext bc) {
        
    }
}