global class UpdatePromissoryFieldsDocusignJob implements Database.Batchable<sObject>,Database.AllowsCallouts,Schedulable {

List<String> skipLoanStatus = System.Label.skip_docusign_job.split(',');
Public Static boolean DocusignIntgnBoolean = MW_Settings__c.getInstance().CLSDSIntgnTurnOff__c;
String query;
global UpdatePromissoryFieldsDocusignJob() {
    query = 'SELECT id, name, Application__c, dsfs__Envelope_Status__c, dsfs__Sent_Date_Time__c, Application__r.name, dsfs__DocuSign_Envelope_ID__c, Application__r.genesis__Status__c '+
            'FROM dsfs__DocuSign_Status__c '+
            'WHERE dsfs__Envelope_Status__c IN (\'Sent\',\'Delivered\') AND Application__c!=null AND Application__r.genesis__Status__c NOT IN : skipLoanStatus ORDER BY createddate DESC';
  }

global Database.QueryLocator start(Database.BatchableContext BC) {
    System.debug('query=' + query);
    return Database.getQueryLocator(query);
}
global void execute(SchedulableContext sc) {
   UpdatePromissoryFieldsDocusignJob j =new UpdatePromissoryFieldsDocusignJob();
    if(DocusignIntgnBoolean==false){
   Database.executebatch(j,1);
    }
}
global void execute(Database.BatchableContext BC, List<dsfs__DocuSign_Status__c> scope) {
    System.debug(scope.size());
    list<loan__batch_process_log__c> errorLogs = new list<loan__batch_process_log__c>();
    for(dsfs__DocuSign_Status__c app:scope) {
            String documentId = SendEnvDocuSignAPI.getDocumentId(app.dsfs__DocuSign_Envelope_ID__c);
            if(documentId!=null) {
                String result = SendEnvDocuSignAPI.updateDocumentFields(app.dsfs__DocuSign_Envelope_ID__c,documentId);
                if(result==null || !result.equalsIgnoreCase('Succesfully Updated the Document Tabs !!')) {
                    loan__batch_process_log__c log = new loan__batch_process_log__c();
                    log.loan__Message__c='Please check the field tag names being sent for the application:'+app.Application__r.name+': '+result;
                    log.loan__Origin__c ='UpdatePromissoryFieldsDocusignJob';
                    errorLogs.add(log);
                }
            } else {
                loan__batch_process_log__c log = new loan__batch_process_log__c();
                log.loan__Message__c='No Document exists for the PayOff Promissory Note for the application:'+app.Application__r.name;
                log.loan__Origin__c ='UpdatePromissoryFieldsDocusignJob';
                errorLogs.add(log);
            }
    }
    if(errorLogs!=null && errorLogs.size()>0)
        insert errorlogs;
}

global void finish(Database.BatchableContext BC) {
    // update job's last run time in custom         
} 
}