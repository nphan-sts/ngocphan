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
        for(genesis__Applications__c app : listOfApp){
            appId = app.id;
            ApplicationToContractConverter.callDCPIntegration(appId);
            String res = genesis.ConvertApplicationCtrl.convertApplicationToContract(appId);
        }
        
        
                
    }
    
    public void Finish(Database.BatchableContext bc) {
        
    }

}