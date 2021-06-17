trigger MW_CustomTriggerOnApplication1 on genesis__Applications__c (after insert, after update,before insert,before update)
{
    if(!genesis.CustomSettingsUtil.getOrgParameters().genesis__Disable_Triggers__c) {
    	MW_ApplicationTriggerHandler handle = new MW_ApplicationTriggerHandler(trigger.new, trigger.newMap, trigger.oldMap);
    
    	if (trigger.isBefore)
    	{
    		if (trigger.isInsert) handle.beforeInsert();
    		if (trigger.isUpdate) handle.beforeUpdate();
    	}
    
    	if (trigger.isAfter)
    	{
    		if (trigger.isUpdate) handle.afterUpdate();
    		if (trigger.isInsert) handle.afterInsert();
    	}
    }
}