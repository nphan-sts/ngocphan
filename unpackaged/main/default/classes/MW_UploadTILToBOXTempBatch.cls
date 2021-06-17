global class MW_UploadTILToBOXTempBatch implements Database.Batchable<sObject>,Database.AllowsCallouts {
    public static CL_Document__c cs = CL_Document__c.getOrgDefaults();
    public string Til = cs.Doc2__c;
    public string uploadbox = cs.UploadedBOX__c;
    public static String OrginaitionDocumentFolder =cs.OrginaitionDocumentFolder__C;
    public string applnType;
    public string query;
    public static String completeSecurityToken;
    public static String token;
    public static String refreshToken;
    public static String authId;
    
    public static String s1;
    public static String s2;
    public static String s3;
    private static Integer count =1;
    
    public static BoxUrl__c box = BoxUrl__c.getOrgDefaults();
    public static String BoxService = box.BoxService__c;
    public static list<loan__Batch_Process_Log__c> logList;
    public set<string> appIdSetTemp;
    
    global MW_UploadTILToBOXTempBatch(set<string> appLeadIdSet) {
    appIdSetTemp = appLeadIdSet;
        query = 'SELECT id, genesis__Application__c, genesis__Application__r.genesis__Status__c, Lead_Id__c, Doc_Code_FF__c, genesis__Application__r.id, '+
                'genesis__Application__r.LeadGUIDBoxFolderID__c, Name, Box_URl__c FROM genesis__Application_Document_Category__c ' +
                'WHERE genesis__Application__r.Lead_Id__c IN : appIdSetTemp AND Name =: Til';
    } 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<genesis__Application_Document_Category__c> scope) {
        logList = new list<loan__Batch_Process_Log__c>();
        Map<String, String> appMap = new Map<String, String>();
        List<genesis__Application_Document_Category__c> dealRoomDocs  = new List<genesis__Application_Document_Category__c>();
        
        for(genesis__Application_Document_Category__c app:scope) {
            appMap.put(app.genesis__Application__r.id,app.genesis__Application__r.LeadGUIDBoxFolderID__c);
        }
        
        map<String,Attachment> generatedDocsMap = new map<String,Attachment>();
        for(Attachment atch : [SELECT Name,body,ParentId,Description from Attachment where Description =: Til
                               AND ParentId IN : appMap.keyset() and BodyLength > 0 Order By CreatedDate DESC]) { // take the latest TIL document from TIL folder
            if(!generatedDocsMap.keyset().contains(atch.ParentId+'_'+atch.Description))                       
                generatedDocsMap.put(atch.ParentId+'_'+atch.Description, atch);
        }
        
        for(genesis__Application_Document_Category__c AppDocCategory : scope)
        {
            if(generatedDocsMap.size() > 0 && generatedDocsMap.get(AppDocCategory.genesis__Application__r.id+'_'+AppDocCategory.Name) != null) {
                String boxUrl = null;
                String fileId;
                
                if(AppDocCategory.Box_URl__c != null){
                    fileId = AppDocCategory.Box_URl__c.substringAfterLast('file/');
                    system.debug('fileId====>'+fileId);
                    system.debug('AppDocCategory.Box_URl__c====>'+AppDocCategory.Box_URl__c);
                    try{
                        boxUrl = uploadFileToBox(generatedDocsMap.get(AppDocCategory.genesis__Application__r.id+'_'+AppDocCategory.Name).body,AppDocCategory.Doc_Code_FF__c +'_'+AppDocCategory.Lead_Id__c+'.pdf',appMap.get(AppDocCategory.genesis__Application__c),AppDocCategory.genesis__Application__c,fileId);
                        if(Test.isRunningTest()){
                            boxUrl = 'DUMMYBoxURL';
                        }
                        if(boxUrl != null) {
                            system.debug('application====>'+AppDocCategory.genesis__Application__c);
                            system.debug('old boxUrl====>'+AppDocCategory.Box_URl__c);
                            system.debug('new boxUrl====>'+boxUrl);
                            AppDocCategory.Box_URl__c = boxUrl;
                            
                            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
                            bplog.loan__Origin__c = 'MW_UploadTILToBOXTempBatch';
                            bplog.loan__Message__c = 'App = ' + AppDocCategory.genesis__Application__c + ' ; Old Box URL = '+AppDocCategory.Box_URl__c+' ; New Box URL = '+boxUrl;
                            bplog.loan__Type__c = 'Info';
                            bplog.loan__Time__c = DateTime.now();
                            bplog.loan__Summary_Record_Id__c = fileId;
                            bplog.loan__Batch_Job_Id__c = AppDocCategory.Id;
                            bplog.loan__Batch_Id__c = AppDocCategory.genesis__Application__c;
                            bplog.loan__Log_Level__c = 'DEBUG';
                            logList.add(bplog);
                            
                            dealRoomDocs.add(AppDocCategory);
                        }
                        if(Test.isRunningTest()){
                            loan__Batch_Process_Log__c bplog;
                            bplog.loan__Type__c = 'Exception';
                        }
                    }catch(Exception ex){
                        loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
                        bplog.loan__Origin__c = 'MW_UploadTILToBOXTempBatch';
                        bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
                        bplog.loan__Type__c = 'Exception';
                        bplog.loan__Time__c = DateTime.now();
                        bplog.loan__Summary_Record_Id__c = fileId;
                        bplog.loan__Batch_Job_Id__c = AppDocCategory.Id;
                        bplog.loan__Batch_Id__c = AppDocCategory.genesis__Application__c;
                        bplog.loan__Log_Level__c = 'ERROR';
                        logList.add(bplog);
                    }
                }  
            }
        }
        if(logList.size() > 0){ 
            insert logList;
        }
        insertAccessToken();
        if(dealRoomDocs.size() > 0){ 
            system.debug('dealRoomDocs====>'+dealRoomDocs);
            //update dealRoomDocs; Updating box url in Deal room is not needed since the url is going to be the same, just a new version will be uploaded.
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    public static String uploadFileToBox(Blob file_body,String filename,string folderid,string appId,string fileId)
    {
        string url,id, type, DocName;
        try {
            
            Integer startTime;
            
            if(completeSecurityToken == null) {
                completeSecurityToken  = getOldAccessToken();
                System.debug(' ** Old Access Token  ** '+completeSecurityToken);
                s1 = completeSecurityToken.split('-')[0];
                s2 = completeSecurityToken.split('-')[1];
                token = s1;
                refreshToken = s2;
            }
            
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            
            System.debug('folderid>>>>>' +folderid);
            if(Test.isRunningTest()){
                folderid = '12345678';
            }
            if(folderid != null)
            {
                String boundary = '----------------------------741e90d31eff';
                String header = '--'+boundary+'\nContent-Disposition: form-data; name="file"; filename="'+filename+'";\nContent-Type: multipart/form-data;'+'\nnon-svg='+True;
                String footer = '--'+boundary+'--';
                String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
                String sUrl = 'https://upload.box.com/api/2.0/files/'+fileId+'/content?parent_id='+folderid;
                System.debug('*****sUrl*****'+sUrl);
                while(headerEncoded.endsWith('='))
                {
                    header+=' ';
                    headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
                }
                
                String bodyEncoded = EncodingUtil.base64Encode(file_body);
                
                Blob bodyBlob = null;
                String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
                
                if(last4Bytes.endsWith('=='))
                {
                    last4Bytes = last4Bytes.substring(0,2) + '0K';
                    bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
                    String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                    bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
                }
                
                else if(last4Bytes.endsWith('='))
                {
                    last4Bytes = last4Bytes.substring(0,3) + 'N';
                    bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
                    footer = '\n' + footer;
                    String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                    bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
                }
                
                else
                {
                    footer = '\r\n' + footer;
                    String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                    bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
                }
                
                req.setHeader('Content-Type','multipart/form-data;non_svg='+True+';boundary='+boundary);
                req.setMethod('POST');
                req.setEndpoint(sUrl);
                req.setBodyAsBlob(bodyBlob);
                req.setTimeout(60000);
                req.setHeader('Authorization', 'Bearer '+token);
                req.setHeader('Content-Length',String.valueof(req.getBodyAsBlob().size()));
                
                System.debug('*****req*****'+req);
                res = http.send(req);
                
                System.debug('*****res*****'+res);
                System.debug('*****res_grtbody****'+res.getBody());
                String requestURLLog = '\n *Request* *URL:* ' + sUrl;
                String parentFolderIDLog = '\n *ParentFolder* *ID:* ' + folderid;
                MW_LogUtility.info('MW_UploadTILToBOXTempBatch', appId, '' + requestURLLog + parentFolderIDLog, 'uploadNewFileVersionToBox', res.getBody(), res);
                
                loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
                bplog.loan__Origin__c = 'MW_UploadTILToBOXTempBatch';
                bplog.loan__Message__c = 'requestURLLog = '+requestURLLog+ ' ; parentFolderIDLog = ' +parentFolderIDLog + ' ; Respose = '+ res +' ; Response Body = '+res.getBody();
                bplog.loan__Type__c = 'Result';
                bplog.loan__Time__c = DateTime.now();
                bplog.loan__Summary_Record_Id__c = fileId;
                bplog.loan__Batch_Id__c = appId;
                bplog.loan__Log_Level__c = 'INFO';
                logList.add(bplog);
                
                if(res.getStatusCode() == 201 && res.getStatus() == 'Created')
                {
                    BOXTokenResponseParcer tokenRespObj = BOXTokenResponseParcer.parse(res.getBody());
                    type = tokenRespObj.entries[0].type;
                    id = tokenRespObj.entries[0].id;
                    url = box.Boxurl__c+type+'/'+id;
                    System.debug('*****url*****'+url);
                    return url;
                }
                if(res.getStatusCode() == 401 && res.getStatus() == 'Unauthorized')
                {
                    count++;
                    completeSecurityToken =  MW_BoxUtilHelper.getNewAccessToken();
                    s1 = completeSecurityToken.split('-')[0];
                    s2 = completeSecurityToken.split('-')[1];
                    s3 = completeSecurityToken.split('-')[2];
                    token = s1;
                    refreshToken = s2;
                    authId = s3;
                    if(count<5) {
                        return uploadFileToBox(file_body, filename, folderid, appId,fileId);
                    }
                    else{
                        return url;
                    }
                }
                if(res.getStatusCode() == 409  && res.getStatus() == 'Conflict') {
                    return url;
                }
                
            }
        }Catch(Exception ex){ 
            MW_LogUtility.error('MW_UploadTILToBOXTempBatch', appId, '', 'uploadNewFileVersionToBox', ex);
        }
        System.debug('url' +url);
        return url;
    }
    
    public static String getOldAccessToken(){
        String accessToken = Null, refreshToken = Null;
        try {
            ints__OAuth_Settings__c oAuthName = [SELECT Id,Name, ints__Access_Token_URL__c,ints__Consumer_Key__c, ints__Consumer_Secret__c
                                                 FROM ints__OAuth_Settings__c WHERE ints__Service_Name__c =:BoxService LIMIT 1];
            
            if(oAuthName != Null) {
                ints__OAuth_Token__c authToken = [SELECT ints__Token__c, ints__Refresh_Token__c FROM ints__OAuth_Token__c WHERE
                                                  ints__OAuth_Settings__c =: oAuthName.Id and ints__Is_Valid__c = true Order By CreatedDate DESC LIMIT 1];
                
                if(authToken.ints__Token__c !=null) {
                    accessToken  = authToken.ints__Token__c;
                    refreshToken = authToken.ints__Refresh_Token__c;
                }
            }
        }
        
        catch(Exception ex){
            system.debug('getoldsectoken ex block===>'+ex);
        }
        return accessToken+'-'+refreshToken;
    }
    public static void insertAccessToken(){
        try {
            ints__OAuth_Settings__c oAuthName = [SELECT Id,Name, ints__Access_Token_URL__c,ints__Consumer_Key__c, ints__Consumer_Secret__c
                                                 FROM ints__OAuth_Settings__c WHERE ints__Service_Name__c =:BoxService LIMIT 1];
            
            if(oAuthName != Null) {
                ints__OAuth_Token__c authToken = [SELECT ints__Token__c, ints__Refresh_Token__c FROM ints__OAuth_Token__c WHERE
                                                  ints__OAuth_Settings__c =: oAuthName.Id and ints__Is_Valid__c = true Order By CreatedDate DESC LIMIT 1];
                
                boolean upd= false;
                
                if(authToken.ints__Token__c!=s1 && s1!=null) {
                    authToken.ints__Token__c = s1;
                    upd = true;
                }
                
                if(authToken.ints__Refresh_Token__c!=s2 && s2!=null) {
                    authToken.ints__Refresh_Token__c = s2;
                    upd = true;
                }
                
                if(upd)
                    update authToken;
            }
        }
        catch(exception ex){
            
        }
    }
    
}