@RestResource(urlMapping='/Application/Documents/getLoanDocuments')
global class MWSendLoanFilesToFundsFlow {

    public static CL_Document__c cs = CL_Document__c.getOrgDefaults();
    public static string credit = cs.Doc1__c;
    public static string Til = cs.Doc2__c;
    
    public static String OrginaitionDocumentFolder = cs.OrginaitionDocumentFolder__C;

    public class ApplicationDocumentBundle{
        public string leadGUID; 
        List<JSONResponseWrapper> files;
        
        public ApplicationDocumentBundle(string leadGUID,List<JSONResponseWrapper> files){
            this.leadGUID = leadGUID;
            this.files = files;
        }
    }
    
    public class JSONResponseWrapper{
        public string fileName;
        public string fileType;
        public string documentCategory;
        public string fileBody;
        public Integer file_size;
        
        public JSONResponseWrapper(string fileBody,string fileName,string fileType,string documentCategory,Integer file_size){
            this.fileName = fileName;
            this.fileType = fileType;
            this.documentCategory = documentCategory;
            this.fileBody = fileBody;
            this.file_size = file_size;
        }
    }
    @HttpGet
    global static void getLoanDocuments() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String applicationRecordId;
        String leadId = req.params.get('lead_id');
        
        if (String.isBlank(leadId)) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('lead_id is required');
            return;
        }
        string query =  'Select Id, Code_FF__c, Application__c, Application__r.Lead_ID__c, Application__r.LeadGUIDBoxFolderID__c, Application__r.genesis__Status__c, Application__r.Investor__c,' + 
                        'Application__r.LastModifiedDate, type__c, Application__r.DocuSign_Sign_Date__c, Application__r.Payment_Mode__c, BoxUrl__c, Lead_Id__c ' +
                        'From Origination_Documents__c where Application__r.Lead_ID__c = \'' +string.escapeSingleQuotes(leadId) + '\'';
        
        List<JSONResponseWrapper> jsonResponseList = new List<JSONResponseWrapper>();
        List<Origination_Documents__c> originationDocumentsList = Database.query(query);
        
        List<String> fileName = new List<String>();
        Set<String>  investorsIds = new Set<String>();
        Map<String, Document> recordsUpdate = new Map<String, Document>();
        list<loan__Batch_Process_Log__c> logList = new list<loan__Batch_Process_Log__c>();
        string msgStr;

        try{
            for(Origination_Documents__c app : originationDocumentsList){
                fileName.add('preciseid_'+app.Lead_ID__c+'.xml');
                fileName.add('talx_'+app.Lead_ID__c+'.json');
                fileName.add('cbr_'+app.Lead_ID__c+'.xml');
                fileName.add('linked_acct_'+app.Lead_ID__c+'.json');
                investorsIds.add(app.Application__r.Investor__c);
                applicationRecordId = app.Application__c;
            }
    
            /*
              Investor Sepcific map
            */
            map<String,Attachment> investorMap = new map<String,Attachment>();
            for(Attachment atch:[SELECT id, Body, ParentId, Name FROM Attachment where ParentId IN : investorsIds and BodyLength > 0]){
                investorMap.put(atch.ParentId, atch);
            }
    
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
            
            for(Origination_Documents__c orgdoc: originationDocumentsList){
                String boxUrl = null;
                msgStr = 'Type = '+orgdoc.type__c;
                    
                logList.add(getLogRecord('MWSendLoanFilesToFundsFlow',msgStr,'Info',orgDoc.Application__c,'',orgDoc.Id,'DEBUG'));    
                // Raw Reponse
                
                if(AcctMap.containsKey(orgdoc.type__c+'_'+orgdoc.Application__c)){
                    if(AcctMap.get(orgdoc.type__c+'_'+orgdoc.Application__c).Name != null){
                        Blob filebodyBlob = AcctMap.get(orgdoc.type__c+'_'+orgdoc.Application__c).body;
                        jsonResponseList.add(new JSONResponseWrapper(EncodingUtil.base64Encode(filebodyBlob),AcctMap.get(orgdoc.type__c+'_'+orgdoc.Application__c).Name,AcctMap.get(orgdoc.type__c+'_'+orgdoc.Application__c).Name.split('\\.')[1],orgdoc.type__c,filebodyBlob.size()));
                        msgStr = 'FileName = ' + AcctMap.get(orgdoc.type__c+'_'+orgdoc.Application__c).Name;
                        logList.add(getLogRecord('MWSendLoanFilesToFundsFlow RAW RESPONSE FILE',msgStr,'Info',orgDoc.Application__c,filebodyBlob.size()+'',orgDoc.Id,'DEBUG'));
                    }
                }
                //Static File
                else if(DocumentMap.containsKey(orgdoc.Code_FF__c)){
                    Blob filebodyBlob = DocumentMap.get(orgdoc.Code_FF__c).body;
                    jsonResponseList.add(new JSONResponseWrapper(EncodingUtil.base64Encode(filebodyBlob),orgdoc.Code_FF__c+'_'+orgdoc.Lead_Id__c+'.pdf','pdf',orgdoc.type__c,filebodyBlob.size()));
                    msgStr = 'FileName = ' + (orgdoc.Code_FF__c+'_'+orgdoc.Lead_Id__c+'.pdf');
                    logList.add(getLogRecord('MWSendLoanFilesToFundsFlow STATIC FILE',msgStr,'Info',orgDoc.Application__c,filebodyBlob.size()+'',orgDoc.Id,'DEBUG'));
                }
                //Investor Specific
                else if(investorMap.get(orgdoc.Application__r.Investor__c)!=null && orgdoc.Application__r.Payment_Mode__c=='AutoPay' && orgdoc.Code_FF__c=='autopay_authorization'){
                    Blob filebodyBlob = investorMap.get(orgdoc.Application__r.Investor__c).body;
                    jsonResponseList.add(new JSONResponseWrapper(EncodingUtil.base64Encode(filebodyBlob),orgdoc.Code_FF__c+'_'+orgdoc.Lead_Id__c+'.pdf','pdf',orgdoc.type__c,filebodyBlob.size()));
                    msgStr = 'FileName = ' + (orgdoc.Code_FF__c+'_'+orgdoc.Lead_Id__c+'.pdf');
                    logList.add(getLogRecord('MWSendLoanFilesToFundsFlow Investor FILE',msgStr,'Info',orgDoc.Application__c,filebodyBlob.size()+'',orgDoc.Id,'DEBUG'));
                 }
            }
            map<String,Attachment> generatedDocsMap = new map<String,Attachment>();
            query ='SELECT id, genesis__Application__c, genesis__Application__r.genesis__Status__c, Lead_Id__c, Doc_Code_FF__c, genesis__Application__r.id, genesis__Application__r.LeadGUIDBoxFolderID__c, Name, Box_URl__c FROM genesis__Application_Document_Category__c ' +
                        'WHERE genesis__Application__r.Lead_ID__c = \'' +string.escapeSingleQuotes(leadId) + '\' AND '+
                        '(Name=:credit OR Name=: Til)';
                        
            for(Attachment atch:[SELECT Name,body,ParentId,Description from Attachment where (Description =: credit OR Description =: Til)
                                 AND ParentId =:applicationRecordId AND BodyLength > 0 Order By CreatedDate ASC]) {
                generatedDocsMap.put((atch.ParentId + '_' + atch.Description), atch);
            }
    
            for(genesis__Application_Document_Category__c AppDocCategory : Database.query(query))
            {
                if(generatedDocsMap.size() > 0 && generatedDocsMap.get(AppDocCategory.genesis__Application__r.id+'_'+AppDocCategory.Name) != null) {
                    Blob filebodyBlob = generatedDocsMap.get(AppDocCategory.genesis__Application__r.id+'_'+AppDocCategory.Name).body;
                    jsonResponseList.add(new JSONResponseWrapper(EncodingUtil.base64Encode(filebodyBlob),AppDocCategory.Doc_Code_FF__c +'_'+AppDocCategory.Lead_Id__c+'.pdf','pdf',AppDocCategory.Doc_Code_FF__c,filebodyBlob.size()));
                    msgStr = 'FileName = ' + AppDocCategory.Doc_Code_FF__c +'_'+AppDocCategory.Lead_Id__c+'.pdf';
                    logList.add(getLogRecord('MWSendLoanFilesToFundsFlow RAW RESPONSE FILE',msgStr,'Info',AppDocCategory.genesis__Application__c,filebodyBlob.size()+'',AppDocCategory.Id,'DEBUG'));
                }
            }
            
            if(jsonResponseList.size() > 0){ 
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(new ApplicationDocumentBundle(leadId,jsonResponseList)));
                msgStr = 'Response body size';
                logList.add(getLogRecord('MWSendLoanFilesToFundsFlow Response Bundle',msgStr,'Info',applicationRecordId,res.responseBody.size()+'',leadId,'DEBUG'));
            }
        }catch(Exception ex){
            Origination_Documents__c orgDoc = originationDocumentsList[0];
            msgStr = 'Error= ' + ex.getLineNumber() + ' Desc= ' + ex.getMessage()+' Stack= '+ex.getStackTraceString();
            logList.add(getLogRecord('MWSendLoanFilesToFundsFlow',msgStr,'Exception',orgDoc.Application__c,'',orgDoc.type__c,'ERROR'));
            MW_LogUtility.error('MWSendLoanFilesToFundsFlow', orgDoc.Application__c, '', 'getLoanDocuments', ex);
        }
        if(!logList.isEmpty()){
            insert logList;
        }
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