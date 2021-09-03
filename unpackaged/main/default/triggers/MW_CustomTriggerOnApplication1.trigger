trigger MW_CustomTriggerOnApplication1 on genesis__Applications__c (after insert, after update,before insert,before update)
{
    if(!genesis.CustomSettingsUtil.getOrgParameters().genesis__Disable_Triggers__c) {

		Map<String, Object> logs = new Map<String, Object>();
		logs.put('isUpdate', Trigger.isUpdate);
		logs.put('isInsert', Trigger.isInsert);
		logs.put('isAfter', Trigger.isAfter);
		logs.put('isBefore', Trigger.isBefore);
		logs.put('isExecuting', Trigger.isExecuting);
		logs.put('isUndelete', Trigger.isUndelete);
		logs.put('trigger.new', MW_LogUtility.toLoggableApps(Trigger.new));
		logs.put('trigger.old', MW_LogUtility.toLoggableApps(Trigger.old));
		MW_LogUtility.infoMessage('MW_CustomTriggerOnApplication1', 'Invocation Entry', logs);

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