public class FetchYodleeTransaction {

    
    @future(callout=true)
    public static void fetchTxn(Map<Id,Id> accApp,Map<Id,Integer> accDays) {
        for(Id acc:accApp.keySet()) {
            System.debug('Hello'+acc);
            String txnResult = YodleeTransactionAPICallOut.getTransactions(acc,accApp.get(acc),accDays.get(acc));
            String updateAccInfo = UpdateAccountInfo.getLastUpdate(acc);
        }
        
    }
    
    /*@InvocableMethod 
    public static void invoke(List<Id> ids) {
        Set<Id> accId = new Set<Id>();
        List<ints__Yodlee_User_Credentials__c > userCred = [select id,name,ints__account__c
                                                            from ints__Yodlee_User_Credentials__c 
                                                            where id in: ids ];
        System.debug('Hello');
        for(ints__Yodlee_User_Credentials__c yodleeUser :userCred) {
            accId.add(yodleeUser.ints__Account__c);
        }
        List<String> status = new List<String>{'funded','Declined','Expired'};
        list<genesis__applications__c> appLst= [select id,name,genesis__status__c,genesis__account__c 
                                                from genesis__applications__c
                                                where genesis__account__c in: accId
                                                and genesis__status__c not in :status];
        
        Map<Id,Id> accApp = new Map<Id,Id>();
        for(genesis__applications__c app:appLst) {
            accApp.put(app.genesis__account__c,app.Id);
        }
        
        System.debug('Hello');
        fetchTxn(accApp);
    }*/

}