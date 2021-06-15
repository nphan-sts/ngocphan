global class UpdatePromissoryFieldsDocusignJob implements Database.Batchable<sObject>,Database.AllowsCallouts,Schedulable {

    List<String> skipLoanStatus = System.Label.skip_docusign_job.split(',');
    String query;
    DateTime systemDate = DateTime.now();
    List<Id> dsfsStatusTime = new List<Id>();
    set<Id> appIds = new set<Id>();
    global UpdatePromissoryFieldsDocusignJob() {
        //query = 'Select id,name,DocuSign_EnvelopeId__c,lead_id__c,DocuSign_Envelope_ID__c,DocuSign_Envelope_Status__c from genesis__applications__c where DocuSign_Envelope_Status__c=\'Sent\' and DocuSign_Envelope_ID__c!=null';
        List<dsfs__DocuSign_Status__c> dsfsStatus = [select id, name, Application__c, dsfs__Envelope_Status__c, dsfs__Sent_Date_Time__c,Application__r.name, dsfs__DocuSign_Envelope_ID__c,Application__r.genesis__Status__c
                                                     from dsfs__DocuSign_Status__c
                                                     where (dsfs__Envelope_Status__c='Sent' Or dsfs__Envelope_Status__c='Delivered') and Application__c!=null and Application__r.genesis__Status__c not in : skipLoanStatus order by createddate desc];
        
         
        for(dsfs__DocuSign_Status__c d : dsfsStatus) {
        if(!appIds.contains(d.Application__c)){ //added by Saryu to get the recent docusign status record linked to one application
            DateTime t = d.dsfs__Sent_Date_Time__c ;
            //String s = String.valueOf(t); Can also use instead of myDate
            String myDate = t.format('yyyy-MM-dd HH:mm:ss', 'PST');
            t = DateTime.valueOfGmt(myDate);
            if(t<systemDate) {
                dsfsStatusTime.add(d.id);
            }

        }
        
        }
        
        /*query = 'select id, name, Application__c, dsfs__Envelope_Status__c, dsfs__Sent_Date_Time__c,Application__r.name, dsfs__DocuSign_Envelope_ID__c '+
                'from dsfs__DocuSign_Status__c '+
                'where dsfs__Envelope_Status__c=\'Sent\' and dsfs__Sent_Date_Time__c<:systemDate and Application__c!=null';*/
        query = 'select id, name, Application__c, dsfs__Envelope_Status__c, dsfs__Sent_Date_Time__c,Application__r.name, dsfs__DocuSign_Envelope_ID__c '+
                'from dsfs__DocuSign_Status__c '+
                'where id in:dsfsStatusTime';

    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
       System.debug(query);
       return Database.getQueryLocator(query);
    }
    global void execute(SchedulableContext sc) {
       UpdatePromissoryFieldsDocusignJob j =new UpdatePromissoryFieldsDocusignJob();
       Database.executebatch(j,1);
    }
    global void execute(Database.BatchableContext BC, List<dsfs__DocuSign_Status__c> scope) {
        System.debug(scope.size());
        list<loan__batch_process_log__c> errorLogs = new list<loan__batch_process_log__c>();
        for(dsfs__DocuSign_Status__c app:scope) {
            //String envelopeStatus = SendEnvDocuSignAPI.getEnvelopeStatus(app.dsfs__Envelope_Status__c);
            //if(envelopeStatus!=null && !envelopeStatus.equalsIgnoreCase('completed')) {
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
            /*} else {
                loan__batch_process_log__c log = new loan__batch_process_log__c();
                log.loan__Message__c='Please check the envelope status or the docusign envelope id for the application:'+app.name;
                log.loan__Origin__c ='UpdatePromissoryFieldsDocusignJob';
                errorLogs.add(log);
            }*/
        }
        if(errorLogs!=null && errorLogs.size()>0)
            insert errorlogs;
    }
    
    global void finish(Database.BatchableContext BC) {
        // update job's last run time in custom         
    } 
}