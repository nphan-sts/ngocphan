trigger MW_PublishApplicationDocumentCategory1 on genesis__Application_Document_Category__c (after insert, after update,before insert,before update) 
{
    // //This is temporary code related DataArchiva and CRM-955 where we need to restore archived application and following code would take care of known errors.
    // Boolean isTriggerActive = CEPARC__DataArchiva_App_Setting__c.getOrgDefaults().Is_Trigger_Active__c;
    // if (isTriggerActive || Test.isRunningTest()) {
    //     if (trigger.isInsert && trigger.isBefore) {
    //         Set<Id> selfLookupIdSet = new Set<Id>();        // To store selflookup Id's of  deleted/non deleted Application category records.
    //         Set<Id> selfLookupPresentIdSet = new Set<Id>(); // To store selflookup Id's of non deleted Application category records.

    //         for (genesis__Application_Document_Category__c ac : Trigger.new) {
    //             selfLookupIdSet.add(ac.genesis__Parent_Application_Document_Category__c);
    //         }

    //         for (genesis__Application_Document_Category__c act : [SELECT Id FROM genesis__Application_Document_Category__c WHERE Id IN :selfLookupIdSet]) {
    //             selfLookupPresentIdSet.add(act.Id);
    //         }

    //         for (genesis__Application_Document_Category__c ac : Trigger.new) {

    //             if (ac.genesis__Parent_Application_Document_Category__c != null
    //                     && !selfLookupPresentIdSet.contains(ac.genesis__Parent_Application_Document_Category__c)) {
    //                 ac.genesis__Parent_Application_Document_Category__c = null;
    //             }
    //         }
    //     }
    // }

    // if (trigger.isInsert && trigger.isBefore) {
    //     for (genesis__Application_Document_Category__c ac : Trigger.new) {
    //         if(String.IsEmpty(ac.DataArchiva_Old_Id__c) == false)
    //         {
    //             return;
    //         } 
    //     }
    // }
    //End of - This is temporary code related DataArchiva and CRM-955 where we need to restore archived application and following code would take care of known errors.

    if (!genesis.CustomSettingsUtil.getOrgParameters().genesis__Disable_Triggers__c) {
        MW_ADCTriggerHandler handle = new MW_ADCTriggerHandler(trigger.new, trigger.oldMap);
        
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