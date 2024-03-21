public class MW_YodleeUserCredTriggerHandler {
    
    // Right now built for CLS-1031; Revisit during optimization
    final List<ints__Yodlee_User_Credentials__c> newRecords;
    final Map<Id, ints__Yodlee_User_Credentials__c> oldMap;
    
    public static boolean avoidrecursive = true; 
    
    public MW_YodleeUserCredTriggerHandler(List<ints__Yodlee_User_Credentials__c> newRecords, Map<Id, ints__Yodlee_User_Credentials__c> oldMap)
    {
        this.newRecords = newRecords;
        this.oldMap = oldMap;
    }
    
    public void beforeInsert()
    {
        
    }

    public void beforeUpdate()
    {
        MW_WebhookHelper.updateAccountCont(newRecords,oldMap);
    }
    
    public void afterUpdate()
    { 
       
    }
    
    public void afterInsert()
    { 
      if(avoidrecursive){
        MW_ADCServicehandler.updateADCStructure(newRecords);
       }
    }
}