global with sharing class MWOriginationDocuments_OrgiDocs implements Database.Batchable<sObject>,Database.AllowsCallouts{

    public static CL_Document__c cs = CL_Document__c.getOrgDefaults();
    public static string credit = cs.Doc1__c;
    public string Til = cs.Doc2__c;
    public string Adverse = cs.Doc3__c;
    public string uploadbox = cs.UploadedBOX__c;
    public static String OrginaitionDocumentFolder =cs.OrginaitionDocumentFolder__C;

    //global final String query = 'Select Id, Code_FF__c, Application__c, Application__r.Lead_ID__c, Application__r.LeadGUIDBoxFolderID__c, Application__r.genesis__Status__c, Application__r.Investor__c, Application__r.LastModifiedDate, type__c, Application__r.DocuSign_Sign_Date__c, Application__r.Payment_Mode__c, BoxUrl__c, Lead_Id__c From Origination_Documents__c ' +
    //        'Where (Application__r.genesis__Status__c=\'pre_funding\' AND Application__r.DocuSign_Sign_Date__c=YESTERDAY AND BoxUrl__c=\'\') OR (Application__r.LastModifiedDate=YESTERDAY AND (Application__r.genesis__Status__c=\'Decline_Manual_Review\' OR Application__r.genesis__Status__c=\'Declined\') AND BoxUrl__c=\'\')';


    global final String query;

    global MWOriginationDocuments_OrgiDocs(String appType)
    {
        if(appType == 'PreFunding') {
            this.query = 'Select Id, Code_FF__c, Application__c, Application__r.Lead_ID__c, Application__r.LeadGUIDBoxFolderID__c, Application__r.genesis__Status__c, Application__r.Investor__c, Application__r.LastModifiedDate, type__c, Application__r.DocuSign_Sign_Date__c, Application__r.Payment_Mode__c, BoxUrl__c, Lead_Id__c ' +
                    'From Origination_Documents__c ' +
                    'Where ' +
                    '(Application__r.genesis__Status__c=\'pre_funding\' AND Application__r.DocuSign_Sign_Date__c=YESTERDAY AND BoxUrl__c=\'\')';
        } else if(appType =='Declined')
        {
            this.query = 'Select Id, Code_FF__c, Application__c, Application__r.Lead_ID__c, Application__r.LeadGUIDBoxFolderID__c, Application__r.genesis__Status__c, Application__r.Investor__c, Application__r.LastModifiedDate, type__c, Application__r.DocuSign_Sign_Date__c, Application__r.Payment_Mode__c, BoxUrl__c, Lead_Id__c ' +
                    'From Origination_Documents__c ' +
                    'Where ' +
                    '(Application__r.LastModifiedDate=YESTERDAY AND (Application__r.genesis__Status__c=\'Decline_Manual_Review\' OR Application__r.genesis__Status__c=\'Declined\') AND BoxUrl__c=\'\')';
        }

        System.debug('query=' + query);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('>>' +query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Origination_Documents__c> scope) {

        List<String> fileName               = new List<String>();
        Map<String, String> appMap          = new Map<String, String>();

        Set<String>  investorsIds           = new Set<String>();
        Map<String, Document> recordsUpdate = new Map<String, Document>();
        list<loan__Batch_Process_Log__c> logList = new list<loan__Batch_Process_Log__c>();
        string msgStr;

        try{
            for(Origination_Documents__c app:scope){
                fileName.add('preciseid_'+app.Lead_ID__c+'.xml');
                fileName.add('talx_'+app.Lead_ID__c+'.json');
                fileName.add('cbr_'+app.Lead_ID__c+'.xml');
                fileName.add('linked_acct_'+app.Lead_ID__c+'.json');
                appMap.put(app.Application__c,app.Application__r.LeadGUIDBoxFolderID__c);
                investorsIds.add(app.Application__r.Investor__c);
            }
    
            /*
              Investor Sepcific map
            */
            map<String,Attachment> investorMap = new map<String,Attachment>();
            for(Attachment atch:[SELECT id, Body, ParentId, Name FROM Attachment where ParentId IN : investorsIds and BodyLength > 0]){
                investorMap.put(atch.ParentId, atch);
            }
    
            System.debug('InvestorMap' +investorMap);
            /*
              Static Files Map
            */
            Map<String, Document> DocumentMap   =  new Map<String, Document>();
            for(Document doc :[SELECT id, DeveloperName, Body, FolderId FROM Document where FolderId =: OrginaitionDocumentFolder]){
                DocumentMap.put(doc.DeveloperName, doc);
            }
    
            /*
              Raw Response File Map
            */
            Boolean CbrAdded = false; //add old Cbr only once.
            Map<String, Attachment> AcctMap = new Map<String, Attachment>();
            for(Attachment attch:[SELECT id, Body, ParentId, Name FROM Attachment where Name IN : fileName and BodyLength > 0 ORDER BY CreatedDate]){
                String[] fleName = attch.name.split('_');
                if(fleName.size() > 0 && fleName[0] == 'linked') {
                    AcctMap.put(fleName[0] + '_' + fleName[1] + '_' + attch.ParentId, attch);
                }
                else if(fleName.size() > 0) {
                        if (fleName[0] != 'cbr') {
                            AcctMap.put(fleName[0] + '_' + attch.ParentId, attch);
                        }
                        if (fleName[0] == 'cbr' && CbrAdded == false) {
                            AcctMap.put(fleName[0] + '_' + attch.ParentId, attch);
                            CbrAdded = true;
                        }
                }
            }
    
            List<Origination_Documents__c> Docstoupdate = new List<Origination_Documents__c>();
            
            for(Origination_Documents__c orgdoc: scope){
                String boxUrl = null;
                msgStr = 'Type = '+orgdoc.type__c+' ; BOX URL = '+orgdoc.BoxUrl__c;
                    
                logList.add(getLogRecord('MWOrigDocs Queried Files Before BOX Upload',msgStr,'Info',orgDoc.Application__c,'',orgDoc.Id,'DEBUG'));    
                // Raw Reponse
                if(AcctMap.containsKey(orgdoc.type__c+'_'+orgdoc.Application__c)){
                    boxUrl = MW_BoxUtil1.uploadFileToBox(AcctMap.get(orgdoc.type__c+'_'+orgdoc.Application__c).body,AcctMap.get(orgdoc.type__c+'_'+orgdoc.Application__c).Name,appMap.get(orgdoc.Application__c),orgdoc.Application__c);
                
                    msgStr = 'FileName = ' + AcctMap.get(orgdoc.type__c+'_'+orgdoc.Application__c).Name + ' ; Folder Id = '+appMap.get(orgdoc.Application__c)+ '  ; BOX URL = '+boxUrl;
                    
                    logList.add(getLogRecord('MWOrigDocs RAW RESPONSE FILE',msgStr,'Info',orgDoc.Application__c,'',orgDoc.Id,'DEBUG'));
                }
                //Static File
                else if(DocumentMap.containsKey(orgdoc.Code_FF__c)){
                    boxUrl = MW_BoxUtil1.uploadFileToBox(DocumentMap.get(orgdoc.Code_FF__c).body,orgdoc.Code_FF__c+'_'+orgdoc.Lead_Id__c+'.pdf',appMap.get(orgdoc.Application__c),orgdoc.Application__c);
                
                    msgStr = 'FileName = ' + orgdoc.Code_FF__c+'_'+orgdoc.Lead_Id__c+'.pdf  ; Folder Id = '+appMap.get(orgdoc.Application__c)+' ; BOX URL = '+boxUrl;
                    
                    logList.add(getLogRecord('MWOrigDocs STATIC FILE',msgStr,'Info',orgDoc.Application__c,'',orgDoc.Id,'DEBUG'));
                }
                //Investor Specific
                else if(investorMap.get(orgdoc.Application__r.Investor__c)!=null && orgdoc.Application__r.Payment_Mode__c=='AutoPay' && orgdoc.Code_FF__c=='autopay_authorization'){
                    boxUrl = MW_BoxUtil1.uploadFileToBox(investorMap.get(orgdoc.Application__r.Investor__c).body,orgdoc.Code_FF__c+'_'+orgdoc.Lead_Id__c+'.pdf',appMap.get(orgdoc.Application__c),orgdoc.Application__c);
                
                    msgStr = 'FileName = ' + orgdoc.Code_FF__c+'_'+orgdoc.Lead_Id__c+'.pdf  ; Folder Id = '+appMap.get(orgdoc.Application__c)+' ; BOX URL = '+boxUrl;
                    
                    logList.add(getLogRecord('MWOrigDocs INVESTOR SPECIFIC FILE',msgStr,'Info',orgDoc.Application__c,'',orgDoc.Id,'DEBUG'));
                }
                if(boxUrl!=null) {
                    orgdoc.BoxUrl__c = boxUrl;
                    Docstoupdate.add(orgdoc);
                }
            }
    
            if(Docstoupdate.size()>0){ 
                update Docstoupdate;
            }
            MW_BoxUtil1.insertAccessToken();
        }catch(Exception ex){
            Origination_Documents__c orgDoc = scope[0];
            msgStr = 'Error= ' + ex.getLineNumber() + ' Desc= ' + ex.getMessage()+' Stack= '+ex.getStackTraceString();
            
            logList.add(getLogRecord('MWOrigDocs Exception',msgStr,'Exception',orgDoc.Application__c,'',orgDoc.type__c,'ERROR'));
            
            MW_LogUtility.error('MWOriginationDocuments_OrgiDocs', orgDoc.Application__c, '', 'uploadFileToBox', ex);
        }
        if(!logList.isEmpty())
            insert logList;
    }

    global void finish(Database.BatchableContext BC) {

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

}