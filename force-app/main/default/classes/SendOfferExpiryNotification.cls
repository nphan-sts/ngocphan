/* ****************Modification History******************
* Modified By       Date                    JIRA Number
*   Shakul        15/3/2022          LSP-601 (Added Test.isRunningTest()in the query)	
******************Modification History******************/
global class SendOfferExpiryNotification implements Database.batchable<sObject>,Schedulable{
            
    String query;
       
    global SendOfferExpiryNotification(){
        //LSP-601-- Modified the query
        query = 'select id from genesis__Applications__c where X14day_s_Before_Expiration_Date__c = True '+(Test.isRunningTest()?' LIMIT 1':'');
                // 'and genesis__Status__c !=\''+String.escapeSingleQuotes(Status1)+'\' and genesis__Status__c !=\''+String.escapeSingleQuotes(Status2)+'\'';
        
        System.debug(logginglevel.error,'query+++'+query); 
                
    }
    
    global SendOfferExpiryNotification(String query){
        
        this.query = query; 
    }
    
    global void execute(SchedulableContext sc) {
        
        SendOfferExpiryNotification b = new SendOfferExpiryNotification();
        Database.executeBatch(b,1);
    
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
                              
        System.debug('Query'+query);    
        return Database.getQueryLocator(query);
    
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        System.debug('----Method execute(+)scope----'+ scope);
        List<genesis__Applications__c > listOfApp = (List<genesis__Applications__c >)scope;
        List<genesis__Applications__c > listOfAppTobeUpdated = new List<genesis__Applications__c> ();
       
                
        for(genesis__Applications__c  app : listOfApp){
            
            app.Send_Offer_expiry_notification__c = true;
            listOfAppTobeUpdated.add(app);
            
        }
        
        update listOfAppTobeUpdated ;
    } 
    
    public void finish(Database.BatchableContext BC){

    }
    
}