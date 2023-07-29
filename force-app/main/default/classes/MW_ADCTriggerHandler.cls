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
}