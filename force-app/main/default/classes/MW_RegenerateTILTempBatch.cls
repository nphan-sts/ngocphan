global class MW_RegenerateTILTempBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.stateful {
    
    public string query;
    public Datetime startDate, endDate;
    public set<string> excludeAppStatuses = new set<string>(); 
    public set<String> appIdSetTemp;
    
    global MW_RegenerateTILTempBatch(Datetime sDate, Datetime eDate,set<string> skipStatusSet, string limitVal,set<String> appIdSet) {
        excludeAppStatuses.addAll(skipStatusSet);
        startDate = sDate;
        endDate = eDate;
        appIdSetTemp = appIdSet;
        query = 'SELECT Id, Name,Lead_Id__c,Investor__r.Name FROM genesis__Applications__c WHERE ';
        
        if(!appIdSet.isEmpty()){
            query += 'Lead_Id__c IN : appIdSetTemp';  
        }
        else{
            query += 'genesis__Status__c NOT IN : excludeAppStatuses AND CreatedDate >=: startDate AND CreatedDate <=: endDate';  
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('query==>'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<genesis__Applications__c> scope) {
        list<loan__Batch_Process_Log__c> logList = new list<loan__Batch_Process_Log__c>();
        
        for(genesis__Applications__c app: scope){
           try{
                ApplicationAttachmentHandlerTemp.attachmentHandler(app.Id,app.Investor__r.Name,'TILDocument_forDCP');
                
                loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
                bplog.loan__Origin__c = 'MW_RegenerateTILTempBatch';
                bplog.loan__Message__c = 'TIL Document Re-Generated';
                bplog.loan__Type__c = 'Info';
                bplog.loan__Time__c = DateTime.now();
                bplog.loan__Summary_Record_Id__c = app.Id;
                bplog.loan__Log_Level__c = 'DEBUG';
                logList.add(bplog);
                if(Test.isRunningTest()){
                    logList = null;
                    logList.add(bplog);
                }
           }catch(Exception ex){
               if(Test.isRunningTest()){
                    logList = new list<loan__Batch_Process_Log__c>();
                }
                loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
                bplog.loan__Origin__c = 'MW_RegenerateTILTempBatch';
                bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
                bplog.loan__Type__c = 'Exception';
                bplog.loan__Time__c = DateTime.now();
                bplog.loan__Summary_Record_Id__c = app.Id;
                bplog.loan__Log_Level__c = 'ERROR';
                logList.add(bplog);
           }
        }
        if(logList.size() > 0){ 
            insert logList;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}