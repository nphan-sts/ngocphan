global class MW_BackfillIncorrectTerminalStatuses implements Database.batchable<sObject>{
    global string whereClause;
    global string operatn;
    global MW_BackfillIncorrectTerminalStatuses(String whereClause, String operatn){
        this.whereClause = whereClause;
        this.operatn = operatn;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query =  'SELECT Id, Name, genesis__New_Value__c, genesis__Old_value__c, genesis__Is_Latest_Status__c, genesis__Changed_On__c, genesis__Application__c, '+
                        'genesis__Current_Status_Duration__c, UpdatedByHMMW__c FROM genesis__Application_Status_History__c '; 
                        
                        if(whereClause != null){
                           query += whereClause;
                        }
                        system.debug('query========>'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<genesis__Application_Status_History__c> scope) {
        map<Id,genesis__Applications__c> appMap = new map<Id,genesis__Applications__c>();
        list<genesis__Application_Status_History__c> ashList = new list<genesis__Application_Status_History__c>();
        for(genesis__Application_Status_History__c ash : scope){
            if(!appMap.containsKey(ash.genesis__Application__c)){
                ash.UpdatedByHMMW__c = true;
                ashList.add(ash);
                appMap.put(ash.genesis__Application__c,new genesis__Applications__c(Id=ash.genesis__Application__c,genesis__Status__c = ash.genesis__Old_value__c));
            }else if(operatn == 'Delete' && ash.UpdatedByHMMW__c == true){
                ashList.add(ash);
            }
        }
        system.debug('appMap========>'+appMap.size());
        if(operatn == 'Update'){
            update appMap.values();
            system.debug('ashList update size========>'+ashList.size());
            update ashList;
        }else if(operatn == 'Delete'){
            system.debug('ashList delete size========>'+ashList.size());
            delete ashList;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}