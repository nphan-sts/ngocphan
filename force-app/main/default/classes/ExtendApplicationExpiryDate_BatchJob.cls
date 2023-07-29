/* ****************Modification History******************
 * Created by       Date        JIRA number
 *     Pallavi      2020/07/13  CRM-744 Batch Job to Extend Expiration Date for All Applications in ADVP Status
 ******************Modification History******************/
Global class ExtendApplicationExpiryDate_BatchJob implements Database.Batchable<sObject>  {

    String query = '';
    String status = 'agent_document_verification_pending';
    
    Global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'select id,Application_Start_DateV2__c from genesis__applications__c where StartDate_Matches_CreatedDate__c = true and genesis__status__c = \'' + status +'\'';
        System.debug('query ' + query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<genesis__Applications__c> applications){
        
        List<genesis__Applications__c> app = new List<genesis__Applications__c>();
        for(genesis__Applications__c appl : applications){
            appl.Application_Start_DateV2__c = appl.Application_Start_DateV2__c.addDays(7);
            app.add(appl);
        } 
        update app;
    }
    global void finish(Database.BatchableContext BC){
        System.debug('In finish Method');
    }
}