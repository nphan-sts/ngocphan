global class ApptoContractConverterBatchJob implements Database.batchable<sObject>,Schedulable,Database.AllowsCallouts {

    global Integer batchSize = 1;
    String query;
    Id appId;
    Set<Id> applicationIdSet = new Set<Id>();
    
    global ApptoContractConverterBatchJob(Set<Id> appIdSet) {
        
        applicationIdSet = appIdSet;
        query = 'select id from genesis__Applications__c where id in : applicationIdSet ' ; 
        System.debug(logginglevel.error,'applicationIdSet ++++' +applicationIdSet );
                 
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
                              
        System.debug('Query'+query);    
        return Database.getQueryLocator(query);
    
    }
     
    global void execute(SchedulableContext sc) {
        ApptoContractConverterBatchJob j = new ApptoContractConverterBatchJob(null);
        Database.executeBatch(j, batchSize);
    }
    
    global void Execute(Database.BatchableContext bc, List<sObject> scope) {
        
        if (scope.size() == 0) {
            return;
        }
        
        List<genesis__Applications__c > listOfApp = (List<genesis__Applications__c >)scope;
        System.debug(logginglevel.error,'listOfApp ++++' +listOfApp );

        /*
        Per the rules of callouts, we have to execute the callouts before dml begins.
        Errors should not bubble up if the final statements fails.
        Executing one at a time because this class is currently batch size one anyway
         */
        for (genesis__Applications__c app : listOfApp) {
            if (MW_AllocationEngineHandler.isAllocationEngineServiceEnabled()) {
                MW_AllocationEngineHandler.handleFinal(new List<Id> {app.Id});
            }
        }

        for(genesis__Applications__c app : listOfApp){
            appId = app.id;
            ApplicationToContractConverter.callDCPIntegration(appId);
            String res = genesis.ConvertApplicationCtrl.convertApplicationToContract(appId);
        }
    }
    
    public void Finish(Database.BatchableContext bc) {
        
    }

}