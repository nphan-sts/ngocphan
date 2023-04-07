public class MW_ADCTriggerHandler {
    
    final List<genesis__Application_Document_Category__c> newRecords;
    final Map<Id, genesis__Application_Document_Category__c> oldMap;
    
    public static boolean avoidrecursive = true; 
    
    public MW_ADCTriggerHandler(List<genesis__Application_Document_Category__c> newRecords, Map<Id, genesis__Application_Document_Category__c> oldMap)
    {
        this.newRecords = newRecords;
        this.oldMap = oldMap;
    }
    
    public void beforeInsert()
    {
       
    }

    public void beforeUpdate()
    {  
      MW_ADCServicehandler.updateADCStatus(newRecords, oldMap);
    }
    
    public void afterUpdate()
    { 
       if(avoidrecursive){
        MW_ADCServicehandler.postDealRoomStructure(newRecords, oldMap);
        MW_ADCServicehandler.countRequiredDocs(newRecords);
        avoidrecursive = false; 
        }
    }
    
    public void afterInsert()
    { 
       
    }

    /**
     * Add logging to at least be aware document categories are being changed in some way.
     * Should handle insert, update and delete.
     */
    public void log() {
        Set<String> names = new Set<String>();
        Set<Id> appIds = new Set<Id>();
        for (genesis__Application_Document_Category__c adc : newRecords) {
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

        MW_LogUtility.infoMessage('MW_ADCTriggerHandler', 'TriggerLogger', new Map<String, Object>{
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

        System.debug('MW_ADCTriggerHandler: ' + message);
    }
}