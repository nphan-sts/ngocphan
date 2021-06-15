trigger MW_DCPArcusTransactionTrigger on DCp_Arcus_Transactions__c (after update) {

    if(trigger.isUpdate && Trigger.isAfter){
        MW_DCPArcusTransactionTriggerHandler.processUpdateTriggers(trigger.new,trigger.oldMap,trigger.newMap);
    }
}