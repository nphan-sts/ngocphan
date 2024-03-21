trigger MW_DCPArcusTransactionTrigger on DCp_Arcus_Transactions__c (after insert, after update) {
    if(!genesis.CustomSettingsUtil.getOrgParameters().genesis__Disable_Triggers__c){
       Boolean EnableDcpTransactionSync = MW_Settings__c.getInstance().Enable_DcpTransaction_Sync__c;
       Boolean UseDcpTransaction = MW_Settings__c.getInstance().Use_DcpTransaction__c;
    
    	if(trigger.isUpdate && Trigger.isAfter){
        	MW_DCPArcusTransactionTriggerHandler.processUpdateTriggers(trigger.new,trigger.oldMap,trigger.newMap);

            if(EnableDcpTransactionSync == true && UseDcpTransaction == false){
        	    MW_DCPArcusTransactionTriggerHandler.updateDcpTransaction(trigger.new,trigger.oldMap,trigger.newMap);
            }
    	}

    	if(trigger.isInsert && Trigger.isAfter){
            if(EnableDcpTransactionSync == true){
        	    MW_DCPArcusTransactionTriggerHandler.addDcpTransaction(trigger.new);
            }
    	}
    }
}