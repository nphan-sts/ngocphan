public with sharing class MW_BoxUtil1 {

    public static String completeSecurityToken;
    public static String token;
    public static String refreshToken;
    public static String authId;

    public static String s1;
    public static String s2;
    public static String s3;

    // create the XX_Folder_ID (Folder 1)
    public Static genesis__Applications__c createLeadGUIDXXBoxFolder(Id appID)
    {
        genesis__Applications__c app = MW_BoxUtilHelper.getAppDetails(appID);

        if(app != null && app.LeadGUID_XX_BoxFolderID__c==null && app.BoxFolderID__c!=null) {
            app.LeadGUID_XX_BoxFolderID__c = CreateAppFolder(app.BoxFolderID__c, app.Lead_ID__c.substring(0, 2));
            return app;
        }
        else{
            return null;
        }
    }

    // create the BOX_Folder_ID (Folder 2)
    public Static genesis__Applications__c createLeadGUIDBoxFolderID(Id appID)
    {
        genesis__Applications__c app = MW_BoxUtilHelper.getAppDetails(appID);
        if(app != null && app.LeadGUID_XX_BoxFolderID__c!=null && app.LeadGUIDBoxFolderID__c==null) {
            app.LeadGUIDBoxFolderID__c = CreateAppFolder(app.LeadGUID_XX_BoxFolderID__c, app.Lead_ID__c);
            return app;
        }
        else{
            return null;
        }
    }

    public class CreateNewFolderCustomException extends Exception {}

    public class FolderResponse {
        Private String type;
        Private String id;
        Private String etag;
        Private ContextInfo context_info;
        Private String help_url;
        Private String message;
        Private String request_id;
    }

    public class ContextInfo {
        Private List<Conflicts> conflicts;
    }

    public class Conflicts {
        Private String type;
        Private String id;
        Private String sequence_id;
        Private String etag;
        Private String name;
    }

    private class fileFolder {
        public blob file;
        Folder fileFolder;
        public fileFolder(blob file, String fName, String parentID){
            this.file = file;
            this.fileFolder = new Folder(fName, parentID);
        }
    }
    private class ParentFolder {
        public String id;
        public ParentFolder(String id) {
            this.id = id;
        }
    }
    private class Folder {
        public String name;
        ParentFolder parent;

        public Folder(String name, String parentId) {
            this.name = name;
            this.parent = new ParentFolder(parentId);
        }
    }

    public static BoxUrl__c box     = BoxUrl__c.getOrgDefaults();
    public static String BoxService = box.BoxService__c;

    // Old Access Token
    public static String getOldAccessToken(){

        String accessToken = Null, refreshToken = Null;

        try {
            ints__OAuth_Settings__c oAuthName = [SELECT Id,Name, ints__Access_Token_URL__c,ints__Consumer_Key__c, ints__Consumer_Secret__c
                                                 FROM ints__OAuth_Settings__c WHERE ints__Service_Name__c =:BoxService LIMIT 1];

            if(oAuthName != Null) {
                ints__OAuth_Token__c authToken = [SELECT ints__Token__c, ints__Refresh_Token__c FROM ints__OAuth_Token__c WHERE
                                                  ints__OAuth_Settings__c =: oAuthName.Id and ints__Is_Valid__c = true Order
                                                                                                                  By CreatedDate DESC LIMIT 1];

                if(authToken.ints__Token__c != null && authToken.ints__Token__c != 'null' && authToken.ints__Refresh_Token__c != null && authToken.ints__Refresh_Token__c != 'null') {
                    accessToken  = authToken.ints__Token__c;
                    refreshToken = authToken.ints__Refresh_Token__c;
                }
            }
        }catch(Exception ex){
            MW_LogUtility.error('MW_BoxUtil1', '', '', 'getOldAccessToken', ex);
        }
        return accessToken + '-' + refreshToken;
    }


    public static void insertAccessToken(){

        try {
            ints__OAuth_Settings__c oAuthName = [SELECT Id,Name, ints__Access_Token_URL__c,ints__Consumer_Key__c, ints__Consumer_Secret__c
                                                 FROM ints__OAuth_Settings__c WHERE ints__Service_Name__c =:BoxService LIMIT 1];

            if(oAuthName != Null) {
                ints__OAuth_Token__c authToken = [SELECT ints__Token__c, ints__Refresh_Token__c FROM ints__OAuth_Token__c
                                                  WHERE ints__OAuth_Settings__c =: oAuthName.Id AND ints__Is_Valid__c = true
                                                  Order By CreatedDate DESC LIMIT 1];

                boolean upd= false;

                if(s1 != null && s1 != 'null' && authToken.ints__Token__c != s1) {
                    authToken.ints__Token__c = s1;
                    upd = true;
                }

                if(s2 != null && s2 != 'null' && authToken.ints__Refresh_Token__c != s2) {
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

    // Create a new Folder.
    private static Integer createFolderCount = 1;
    Public Static String CreateAppFolder(String investorFolderID, String leadID){
        try {
            String body;
            if(completeSecurityToken==null) {
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
            String CreateFolder_Url = 'https://api.box.com/2.0/folders';
            req.setTimeout(120000);
            req.setEndPoint(CreateFolder_Url);
            req.setMethod('POST');
            Folder folderInfo = new Folder(leadID, investorFolderID);
            body = JSON.Serialize(folderInfo);
            System.debug('...body...' +body);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer '+ token);
            req.setBody(body);
            res = http.send(req);

            if(res.getStatusCode() == 201 && res.getStatus() == 'Created') {
                MW_LogUtility.info('MW_BoxUtil1', '', leadID, 'CreateAppFolder', res.getBody(), res);
                FolderResponse folderResp = (FolderResponse)System.JSON.deserialize(res.getBody(), FolderResponse.class);
                if(folderResp != null && folderResp.id != null) {
                    return folderResp.id;
                }
            }
            else if(res.getStatusCode() == 409 && res.getStatus() == 'Conflict') {
                MW_LogUtility.info('MW_BoxUtil1', '', leadID, 'CreateAppFolder Status 409 Conflict', res.getBody());
                try {
                    FolderResponse folderResp = (FolderResponse)System.JSON.deserialize(res.getBody(), FolderResponse.class);
                    if(folderResp != null && folderResp.context_info != null && folderResp.context_info.conflicts[0] != null) {
                        return folderResp.context_info.conflicts[0].id;
                    }
                }
                catch(exception ex){
                    MW_LogUtility.error('MW_BoxUtil1', '', leadID, 'CreateAppFolder Status 409 Conflict', ex);
                }
            }
            else if(res.getStatusCode() == 401 && res.getStatus() == 'Unauthorized') {
                MW_LogUtility.info('MW_BoxUtil1', '', leadID, 'CreateAppFolder', res.getBody(), res);
                completeSecurityToken = null;
                token = null;
                refreshToken = null;
                authId = null;

                if(completeSecurityToken==null) {
                    createFolderCount++;
                    completeSecurityToken =  MW_BoxUtilHelper.getNewAccessToken();
                    s1 = completeSecurityToken.split('-')[0];
                    s2 = completeSecurityToken.split('-')[1];
                    s3 = completeSecurityToken.split('-')[2];
                    token = s1;
                    refreshToken = s2;
                    authId = s3;
                    if(createFolderCount<5) {
                        return CreateAppFolder(investorFolderID, leadID);
                    }
                    else{
                        MW_LogUtility.error('MW_BoxUtil1', '', leadID, 'CreateAppFolder Box Changed Response', new CreateNewFolderCustomException(res.getBody()));
                        return null;
                    }
                }
            }
        } catch(exception ex){
            MW_LogUtility.error('MW_BoxUtil1', '', leadID, 'CreateAppFolder', ex);
        }
        return null;
    }

    private static Integer count =1;

    public static String uploadFileToBox(Blob file_body,String filename,string folderid,string appId)
    {
        list<loan__Batch_Process_Log__c> logList = new list<loan__Batch_Process_Log__c>();
        string url,id, type, DocName;
        String msgStr;

        try {
            MW_LogUtility.info('MW_BoxUtil1', appId, filename, 'uploadFileToBox', folderid);
            String strFolderId = folderid;
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

            if(strFolderId != null)
            {
                String boundary = '----------------------------741e90d31eff';
                String header = '--'+boundary+'\nContent-Disposition: form-data; name="file"; filename="'+filename+'";\nContent-Type: multipart/form-data;'+'\nnon-svg='+True;
                String footer = '--'+boundary+'--';
                String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
                String sUrl = 'https://upload.box.com/api/2.0/files/content?parent_id='+strFolderId;

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
                req.setTimeout(120000);
                req.setHeader('Authorization', 'Bearer '+token);
                req.setHeader('Content-Length',String.valueof(req.getBodyAsBlob().size()));


                res = http.send(req);

                /*******For CLS-1297 Debug only will remove after issue resolved********/
                String requestURLLog = '\n *Request* *URL:* ' + sUrl;
                String parentFolderIDLog = '\n *ParentFolder* *ID:* ' + strFolderId;
                /******END HERE*******/
                MW_LogUtility.info('MW_BoxUtil1', appId, '' + requestURLLog + parentFolderIDLog, 'uploadFileToBox', res.getBody(), res);
                msgStr = 'requestURLLog= ' + requestURLLog + ' parentFolderIDLog= ' + parentFolderIDLog + ' res='+res+' res body= '+res.getBody();

                logList.add(MWOriginationDocuments_OrgiDocs.getLogRecord('MW_BoxUtil1 uploadFileToBox',msgStr,'Info',appId,'','','DEBUG'));

                if(res.getStatusCode() == 201 && res.getStatus() == 'Created')
                {
                    BOXTokenResponseParcer tokenRespObj = BOXTokenResponseParcer.parse(res.getBody());
                    type = tokenRespObj.entries[0].type;
                    id = tokenRespObj.entries[0].id;
                    url = box.Boxurl__c+type+'/'+id;
                    System.debug('*****url*****'+url);
                    if(logList.size() > 0){
                        insert logList;
                    }
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
                    if(count < 5) {
                        return uploadFileToBox(file_body, filename, folderid, appId);
                    }
                    else{
                        MW_LogUtility.error('MW_BoxUtil1', 'uploadFileToBox', '5 Retries Exceeded For:'+folderid+'='+filename);
                        if(logList.size() > 0){
                            insert logList;
                        }
                        return url;
                    }
                }
                if(res.getStatusCode() == 409  && res.getStatus() == 'Conflict') {
                    if(logList.size() > 0){
                        insert logList;
                    }
                    return url;
                }
            }

        } Catch(Exception ex){
            MW_LogUtility.error('MW_BoxUtil1', appId, '', 'uploadFileToBox', ex);

            msgStr = 'Error= ' + ex.getLineNumber() + ' Desc= ' + ex.getMessage()+' Stack= '+ex.getStackTraceString();

            logList.add(MWOriginationDocuments_OrgiDocs.getLogRecord('MW_BoxUtil1 uploadFileToBox',msgStr,'Exception',appId,'','','ERROR'));
        }
        System.debug('url' +url);
        if(logList.size() > 0){
            insert logList;
        }
        return url;
    }
}