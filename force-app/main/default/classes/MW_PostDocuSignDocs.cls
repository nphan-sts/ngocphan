global class MW_PostDocuSignDocs implements Database.AllowsCallouts, Database.batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query =  'SELECT id, genesis__Application__c, Name, Doc_Code_FF__c, Investor_Code__c,' + 
                        'genesis__Application__r.genesis__Account__r.State__c, genesis__Application__r.Investor__r.Investor_Code__c,' +
                        'genesis__Application__r.genesis__Status__c, Lead_Id__c, genesis__Application__r.DocuSign_EnvelopeId__c,'+
                        'Box_URl__c FROM genesis__Application_Document_Category__c ';
        query += Label.MW_Docusign_Doc_Check_Job_WHERE_Clause;
        system.debug('query===>'+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<genesis__Application_Document_Category__c> scope) {
        system.debug('scope===>'+scope);
        for (genesis__Application_Document_Category__c adc : scope) {
            If (!Test.IsRunningTest()) {
                MW_DocuSigneSignedDocuments.postDocumentDetailsWithoutCallout(adc.genesis__Application__r.DocuSign_EnvelopeId__c, adc.genesis__Application__c, adc.Lead_Id__c);
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        String query =  'SELECT id, genesis__Application__c, Name, Doc_Code_FF__c, Investor_Code__c, genesis__Application__r.Name,'+
                        'genesis__Application__r.genesis__Account__r.State__c, genesis__Application__r.Investor__r.Investor_Code__c,'+
                        'genesis__Application__r.genesis__Status__c, Lead_Id__c, genesis__Application__r.DocuSign_EnvelopeId__c,'+
                        'Box_URl__c FROM genesis__Application_Document_Category__c ';
        query += Label.MW_Docusign_Doc_Check_Job_WHERE_Clause;
        String missingDocs ='';
        map<Id,String> appMissindDocStrMap = new map<Id,String>();
        for (genesis__Application_Document_Category__c adc : Database.query(query)) {
            if(adc.genesis__Application__c != null && !appMissindDocStrMap.containskey(adc.genesis__Application__c)){
                String strHeaderLine =   
                                        'Application Name = '+ adc.genesis__Application__r.Name + '\n' + 
                                        'Application Id = ' + adc.genesis__Application__c + '\n' +
                                        'Application Status = '+ adc.genesis__Application__r.genesis__Status__c +
                                        '\n Missing Documents = \n';
                appMissindDocStrMap.put(adc.genesis__Application__c, (strHeaderLine + '* ' + adc.Name + '\n'));
            }else{
                String updatedDocStr = appMissindDocStrMap.get(adc.genesis__Application__c) + ('* ' + adc.Name + '\n');
                appMissindDocStrMap.put(adc.genesis__Application__c,updatedDocStr) ;
            }
        }
        for(Id appId : appMissindDocStrMap.keyset()){
            missingDocs += appMissindDocStrMap.get(appId);
        }
        system.debug('missingDocs====>'+missingDocs);
        if(missingDocs != ''){
            Map<String, Object> msg = new Map<String, Object>();
            msg.put('text', ':alert::alert::alert::alert::alert: \n' +
                    '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' + '\n' +
                    '         MISSING Docusign DOCUMENT ALERT ' + '\n' +
                    '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' + '\n' +
                    missingDocs);
            system.debug('msg===>'+msg);
            if(!Test.isRunningTest()) {
                MW_SlackCallOut.slackCallOut(MW_Settings__c.getInstance().Slack_Middleware_System_Alert_Channel__c, JSON.serialize(msg));
            }
        }
    }
}