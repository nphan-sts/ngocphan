trigger MW_PublishApplicationDocumentCategory1 on genesis__Application_Document_Category__c (after insert, after update, after delete, before insert,before update)
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

            Set<String> names = new Set<String>();
            Set<Id> appIds = new Set<Id>();
            for (genesis__Application_Document_Category__c adc : Trigger.new) {
                appIds.add(adc.genesis__Application__c);
                names.add(adc.Name);
            }

            List<String> leadIds = new List<String>();
            for (genesis__Applications__c app : [
                    SELECT Id,
                            Lead_ID__c,
                            genesis__Status__c
                    FROM   genesis__Applications__c
                    WHERE Id IN :appIds
            ]) {
                leadIds.add(app.Lead_ID__c);
            }

            String leadIdStr = String.join(new List<String>(leadIds), ', ');
            String categories = String.join(new List<String>(names), ', ');
            String message = String.format('{0} genesis__Application_Document_Category__c {1} ({2}): {3}',
                    new List<Object>{
                            leadIdStr,
                            Trigger.operationType,
                            Trigger.new.size(),
                            categories
                    });

            MW_LogUtility.infoMessage('MW_PublishApplicationDocumentCategory1', 'TriggerLogger', new Map<String, Object>{
                    'context.isBatch' => System.isBatch(),
                    'context.isQueueable' => System.isQueueable(),
                    'context.isFuture' => System.isFuture(),
                    'context.isScheduled' => System.isScheduled(),
                    'context.leadIds' => leadIdStr,
                    'context.categories' => categories,
                    'context.triggerOperationType' => Trigger.operationType,
                    'context.quiddity' => Request.getCurrent().getQuiddity().name(),
                    'context.requestId' => Request.getCurrent().getRequestId(),
                    'message' => message
            });

            System.debug('MW_PublishApplicationDocumentCategory1: ' + message);

          if (trigger.isUpdate) handle.afterUpdate();
          if (trigger.isInsert) handle.afterInsert();
        }
    }
}