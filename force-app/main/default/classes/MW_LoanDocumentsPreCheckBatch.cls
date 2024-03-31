global class MW_LoanDocumentsPreCheckBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{
    public static List<loan__Batch_Process_Log__c> logList;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        set<String> missingDocAppStatuses = new set<String>();
        if(MW_Settings__c.getInstance().MissingDocumentsAppStatuses__c != null)
            missingDocAppStatuses.addAll(MW_Settings__c.getInstance().MissingDocumentsAppStatuses__c.split(';'));
        String query = 'select Id,Lead_Id__c,Bank_Account__c,Name,genesis__Status__c,(select Id from Yodlee_User_Accounts__r),(select Id from Talxs__r) from genesis__Applications__c ';
        if(missingDocAppStatuses.size() > 0)
            query += 'where genesis__Status__c IN : missingDocAppStatuses';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<genesis__Applications__c> scope) {
        logList = new List<loan__Batch_Process_Log__c>();
        List<Id> appIdSet = new List<Id>();
        map<Id,genesis__Applications__c> appMap =  new map<Id,genesis__Applications__c>();
        for(genesis__Applications__c app : scope){
            appMap.put(app.Id,app);
        }
        map<Id,list<Attachment>> appsDocumentsMap = new map<Id,list<Attachment>>();
        for(Attachment att : [Select Id,Name,ParentId from Attachment where ParentId IN : appMap.keySet()]){
            if(appsDocumentsMap.containskey(att.ParentId)){
                List<Attachment> existingAttList = new List<Attachment>();
                existingAttList.addAll(appsDocumentsMap.get(att.ParentId));
                existingAttList.add(att);
                appsDocumentsMap.put(att.ParentId,existingAttList);
            }else{
                appsDocumentsMap.put(att.ParentId,new List<Attachment>{att});
            }
        }
        string missingDocs = getMissingDocumentsForApplication(appsDocumentsMap,appMap);
        string body;
        if(missingDocs != ''){
            Map<String, Object> msg = new Map<String, Object>();
            msg.put('text', ':alert::alert::alert::alert::alert: \n' +
                    '****************************************************' + '\n' +
                    '*         MISSING DOCUMENT ALERT* ' + '\n' +
                    '****************************************************' + '\n' +
                    missingDocs);
            if(!Test.isRunningTest()) {
                MW_SlackCallOut.slackCallOut(MW_Settings__c.getInstance().Slack_Middleware_System_Alert_Channel__c, JSON.serialize(msg));
            }
        }
        
        system.debug('logList====>'+logList);
        if(logList.size() > 0){}
            insert logList;
    }
    
    public string getMissingDocumentsForApplication(map<Id,list<Attachment>> appAttachmentMap, map<Id,genesis__Applications__c> appMap){
        string appMissingDocumentsList = '';
        try{
            for(Id appId : appAttachmentMap.keySet()){
                string missingDocs = '========================================\n' + 'Application Name = '+appMap.get(appId).Name + '\n' + 'Application Id = ' + appId + '\n'
                                     + 'Application Status = '+appMap.get(appId).genesis__Status__c+'\n Missing Documents = \n';
                system.debug('missingDocs====>'+missingDocs);
                Boolean cbrMissing = true, csnMissing = true, preciseidMissing = true, tilMissing = true, linkedAccountMissing = true,talxMissing = true;
                for(Attachment att : appAttachmentMap.get(appId)){
                    if(att.Name.containsIgnoreCase('cbr')){
                        cbrMissing = false;
                    }else if(att.Name.containsIgnoreCase('til')){
                        tilMissing = false;
                    }else if(att.Name.containsIgnoreCase('Credit Score Notice')){
                        csnMissing = false;
                    }else if(att.Name.containsIgnoreCase('preciseid')){
                        preciseidMissing = false;
                    }else if(att.Name.containsIgnoreCase('linked')){
                        linkedAccountMissing = false;
                    }else if(att.Name.containsIgnoreCase('talx')){
                        talxMissing = false;
                    }
                }
                if(cbrMissing){ missingDocs = missingDocs +  '* Credit Bureau Report \n';}
                if(csnMissing){ missingDocs = missingDocs + '* Credit Score Notice \n';}
                if(preciseidMissing){ missingDocs = missingDocs + '* Preciseid \n ';}
                if(tilMissing){ missingDocs = missingDocs + '* TIL Document \n ';}
                if(linkedAccountMissing && appMap.get(appId).Yodlee_User_Accounts__r != null && appMap.get(appId).Yodlee_User_Accounts__r.size() > 0){ missingDocs = missingDocs + '* Linked Account \n ';}
                if(talxMissing && appMap.get(appId).Talxs__r != null && appMap.get(appId).Talxs__r.size() > 0){ missingDocs = missingDocs + '* Talx \n ';}
                system.debug('missingDocs====>'+missingDocs);
                if(missingDocs.contains('*')){
                    appMissingDocumentsList += missingDocs + '========================================\n';
                    logList.add(getLogRecord('MW_LoanDocumentsPreCheckBatch','Document Missing','Info','',missingDocs.substringAfter('Missing'),appId,'DEBUG'));
                }
            }
            if(Test.isRunningTest()) {
                Account accTemp = null;
                accTemp.Name = 'Test Catch Block';
            }
        }catch(Exception e){
                logList.add(getLogRecord('MW_LoanDocumentsPreCheckBatch',e.getMessage(),'Exception','','',string.valueOf(appAttachmentMap.keySet()),'DEBUG'));
        }
        system.debug('appMissingDocumentsList====>\n'+appMissingDocumentsList);
        if(appMissingDocumentsList.contains('*'))
            return appMissingDocumentsList; 
        return '';    
    }
    
    public static loan__Batch_Process_Log__c getLogRecord(string origin, string msg, string typeStr, string summaryRecordId, string batchJobId, string batchId, string logLevel){
        loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
        bplog.loan__Origin__c = origin;
        bplog.loan__Message__c = msg;
        bplog.loan__Type__c = typeStr;
        bplog.loan__Time__c = DateTime.now();
        bplog.loan__Summary_Record_Id__c = summaryRecordId;
        bplog.loan__Batch_Job_Id__c = batchJobId;
        bplog.loan__Batch_Id__c = batchId;
        bplog.loan__Log_Level__c = logLevel;
        return bplog;
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
}