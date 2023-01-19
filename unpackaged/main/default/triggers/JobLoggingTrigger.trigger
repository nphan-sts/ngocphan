trigger JobLoggingTrigger on clcommon__Job_Logging__c (after insert,after update) {

  if(!loan.CustomSettingsUtil.getOrgParameters().loan__Disable_Triggers__c) { 
  
        JobLoggingTriggerHandler handler = new JobLoggingTriggerHandler(trigger.new, trigger.newMap);
       
        if (trigger.isAfter){
            handler.afterInsertUpdate();
        }
    }
}