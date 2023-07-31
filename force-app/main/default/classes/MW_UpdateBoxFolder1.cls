global class MW_UpdateBoxFolder1 implements Database.Batchable<sObject>,Database.AllowsCallouts{

  global final String query = 'select Id, Lead_ID__c, LeadGUID_XX_BoxFolderID__c, Investor__c, DocuSign_Sign_Date__c from genesis__Applications__c where LeadGUID_XX_BoxFolderID__c=\'\' and Lead_ID__c!=\'\' and BoxFolderID__c!=\'\'';

  global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<genesis__Applications__c> scope) {

        List<genesis__Applications__c> appsList  = new List<genesis__Applications__c>();

        for(genesis__Applications__c app:scope)
        {
           genesis__Applications__c apps  = MW_BoxUtil1.createLeadGUIDXXBoxFolder(app.Id);
           if(apps!= null && apps.LeadGUID_XX_BoxFolderID__c !=null)
           appsList.add(apps);
        }

        /*
           Update All Applications at a time
        */
        if(appsList.size()>0){
            update appsList;
        }

        MW_BoxUtil1.insertAccessToken();

    }

    global void finish(Database.BatchableContext BC) {

    }
}