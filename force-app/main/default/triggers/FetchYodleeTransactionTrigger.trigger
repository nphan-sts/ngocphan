trigger FetchYodleeTransactionTrigger on ints__Yodlee_User_Credentials__c (after insert,after update) {
    if (!genesis.CustomSettingsUtil.getOrgParameters().genesis__Disable_Triggers__c) {
    if(trigger.isAfter) {
        Set<Id> accId = new Set<Id>();
        
        System.debug('Hello');
        for(ints__Yodlee_User_Credentials__c yodleeUser :trigger.new) {
            accId.add(yodleeUser.ints__Account__c);
        }
        list<genesis__applications__c> appLst = new list<genesis__applications__c>();
        if(trigger.isInsert) {
            List<String> status = new List<String>{'funded','Declined','Expired'};
        	appLst= [select id,name,genesis__status__c,genesis__account__c,
                                                Number_of_days__c 
                                                from genesis__applications__c
                                                where genesis__account__c in: accId
                                                and genesis__status__c not in :status];
        } else if(trigger.isUpdate){
            List<String> status = System.Label.DontFetchYodleeStatuses.split(',');
        	appLst= [select id,name,genesis__status__c,genesis__account__c,
                                                Number_of_days__c 
                                                from genesis__applications__c
                                                where genesis__account__c in: accId
                                                and genesis__status__c not in :status];
        }
        
        
        Map<Id,Id> accApp = new Map<Id,Id>();
        Map<Id,Integer> accDays = new Map<Id,Integer>();
        if(appLst!=null && appLst.size()>0) {
            for(genesis__applications__c app:appLst) {
                accApp.put(app.genesis__account__c,app.id);
                accDays.put(app.genesis__account__c,(app.Number_of_days__c!=null)?Integer.valueOf(app.Number_of_days__c):null);
            }
            
            System.debug('Hello');
            FetchYodleeTransaction.fetchTxn(accApp,accDays);
        }
    }
    }
}