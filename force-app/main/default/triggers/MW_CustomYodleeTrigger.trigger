trigger MW_CustomYodleeTrigger on ints__Yodlee_User_Credentials__c (before update, after update, before insert, after insert) {
    if(!genesis.CustomSettingsUtil.getOrgParameters().genesis__Disable_Triggers__c) {
          MW_YodleeUserCredTriggerHandler handle = new MW_YodleeUserCredTriggerHandler(trigger.new, trigger.oldMap);
    
          if (trigger.isBefore)
          {
            if (trigger.isInsert) handle.beforeInsert();
            if (trigger.isUpdate) handle.beforeUpdate();
          }
         // CLS - CLS-1031
          if (trigger.isAfter)
          {
            if (trigger.isUpdate) handle.afterUpdate();
            if (trigger.isInsert) handle.afterInsert();
          }
    }
}