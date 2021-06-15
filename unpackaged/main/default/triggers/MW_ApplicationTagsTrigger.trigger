trigger MW_ApplicationTagsTrigger on Application_Tags__c (before insert, before update) {

    if(!genesis.CustomSettingsUtil.getOrgParameters().genesis__Disable_Triggers__c) { 
        MW_ApplicationTagsTriggerHandler handler = new MW_ApplicationTagsTriggerHandler(trigger.new, trigger.newMap, trigger.oldMap);
        if (trigger.isBefore)
        {
            if(trigger.isInsert){
                handler.beforeInsert();
            }    
            if(trigger.isUpdate){
                handler.beforeUpdate();
            }
        }        
        /*
        if (trigger.isAfter)
        {
            //if (trigger.isUpdate) handle.afterUpdate();
            //if (trigger.isInsert) handle.afterInsert();
        }
        */
    }
}