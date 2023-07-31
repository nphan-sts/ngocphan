public with sharing class MW_WebhookHelper {

    public Static Map<Id,Credit_Policy__c> selectedCreditPolicyDetails(Set<String> appList){
         Map<Id,Credit_Policy__c> cpMap = new Map<Id,Credit_Policy__c>();
         for(Credit_Policy__c cp : [Select Id, Loan_amount_counteroffer__c, Application__c from Credit_Policy__c
                                            where Application__c IN:appList limit 199]) {
                cpMap.put(cp.Application__c, cp);
         }
         return cpMap;
   }

   public Static map<String,String> appQueueDetails(){
        map<String,String> queuMap = new map<String,String>();
        for(QueueSobject qobj:[Select queue.name,QueueID from QueueSobject where SobjectType ='genesis__Applications__c' Limit 199]){
            queuMap.put(qobj.queue.name, qobj.QueueID);
        }
        return queuMap;
   }

    public Static boolean isHardpullDone(id applicationid){
         List<Hard_Credit_Pull__c> hardCreditDetials= new List<Hard_Credit_Pull__c>([SELECT Id from Hard_Credit_Pull__c where Application__c=:applicationid Limit 199]);
         if(hardCreditDetials.size()>0) return true;
         return false;
   }


    public static Map<Id, Integer> applicationDocumentCat(List<String> appList){

        Map<Id, Integer> requiredDocs = new Map<Id, Integer>();

        for(genesis__Application_Document_Category__c adc:[SELECT Id,genesis__Application__c, genesis__Required__c, Box_URl__c from genesis__Application_Document_Category__c
                                                           where genesis__Application__c in:appList
                                                           AND genesis__Parent_Application_Document_Category__r.name != 'ESign Documents'
                                                           AND genesis__Parent_Application_Document_Category__r.name != 'Root'
                                                           AND genesis__Parent_Application_Document_Category__r.name != 'Generated Documents'
                                                           AND Name!='Root' AND Name!='Bank Statements' AND Name!='Paystubs'
                                                           AND genesis__Required__c = true AND Box_URl__c = null
                                                           AND genesis__Application__r.agentVerificationPendingFlag__c=false]){
                  if(requiredDocs.get(adc.genesis__Application__c)==null)
                       requiredDocs.put(adc.genesis__Application__c, 1);
                  else
                      requiredDocs.put(adc.genesis__Application__c, requiredDocs.get(adc.genesis__Application__c)+1);
         }

         return requiredDocs;
    }

    public static  Map<Id, boolean> applicationHasYodleeDetails(List<String> accList){
        Map<Id, boolean> accMapList = new Map<Id, boolean>();
        for(ints__Yodlee_User_Credentials__c yodlist:[select Id, ints__Account__c from ints__Yodlee_User_Credentials__c
                                                      where ints__Account__c IN:accList limit 1]){
              if(accMapList.get(yodlist.ints__Account__c)==null)
                 accMapList.put(yodlist.ints__Account__c, true);
        }
        return accMapList;
    }

    
    public static void updateAccountCont(List<ints__Yodlee_User_Credentials__c > newList, Map<Id, ints__Yodlee_User_Credentials__c> oldMap){
        
        List<Id> accList = new List<id>();
        
        for (ints__Yodlee_User_Credentials__c yodleeUser : newList) {
            if(yodleeUser.yodlee_Account_count__c!=oldMap.get(yodleeUser.Id).yodlee_Account_count__c){
                accList.add(yodleeUser.ints__Account__c);
            
            }    
        }
        
        if(accList.size()>0){
            MW_WebhookHelper.updateBankApplicationDocCat(accList);
        }
    }
    
    
    public static void updateBankApplicationDocCat(LIst<Id> accId){
        
        List<string> appStatustoavoid = new List<string>{'agent_document_verification_pending'};
        
        List<genesis__Application_Document_Category__c> updateAdc = new List<genesis__Application_Document_Category__c>();
        
        for(genesis__Application_Document_Category__c apdoc:[select Id, Name, genesis__Application__c, genesis__Application__r.genesis__Account__c, 
                                                              genesis__Status__c, genesis__Parent_Application_Document_Category__c, genesis__Application__r.genesis__Status__c 
                                                              from genesis__Application_Document_Category__c where 
                                                              genesis__Parent_Application_Document_Category__r.name='Bank Statements' and 
                                                              genesis__Application__r.genesis__Account__c =:accId and 
                                                              genesis__Application__r.genesis__Status__c IN:appStatustoavoid and 
                                                              genesis__Status__c='REJECT']){
             apdoc.genesis__Status__c='OPEN';
             updateAdc.add(apdoc);                                                 
       }
       
       if(updateAdc.size()>0){
           update updateAdc;
       }
    }
    
}