/* Created By Nupur */
public class BorrowerEmail {
/*@invocablemethod()
public static List<genesis__Applications__c> getBorrowerEmail(List<ID> ids) {

    List<String> BorrowerEmial = new List<String>();

    List<genesis__Applications__c> applist = [SELECT id,Borrower_s_Email__c,
                                                        genesis__Account__c,
                                                        genesis__Account__r.cnotify__Email__c,
                                                        Application_Email__c FROM genesis__Applications__c WHERE Id in :ids];

    for (genesis__Applications__c app : applist) {

      app.Borrower_s_Email__c = app.genesis__Account__r.cnotify__Email__c;

    }

    update applist;
    return appList;
  }

}*/
@InvocableMethod()
public static void getBorrowerEmail(List<Id> appId) {
    genesis__Applications__c applist = [SELECT Id, Borrower_s_Email__c,
                                                        genesis__Account__r.cnotify__Email__c,
                                                        Application_Email__c FROM genesis__Applications__c WHERE Id IN:appId LIMIT 1];

     if(applist != Null && applist.Borrower_s_Email__c == Null){                                                                  
             applist.Borrower_s_Email__c = applist.genesis__Account__r.cnotify__Email__c;   
             update applist;
             System.debug('Borrower Email...' +   applist.Borrower_s_Email__c);    
     }    
  }

}