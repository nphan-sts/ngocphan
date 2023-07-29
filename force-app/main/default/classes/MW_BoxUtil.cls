public with sharing class MW_BoxUtil {
    
    public static String s;
    public static String token;
    public static String refreshToken;
    public static String authId;
    public static String s1;
    public static String s2;
    public static String s3;
    public static HttpResponse res = new HttpResponse();
    public static Http http = new Http();
    public static HttpRequest req = new HttpRequest();
    Private Static String CreateFolder_Url = 'https://api.box.com/2.0/folders';
    public Static String body;
    public Static String leadFolderID;

    @InvocableMethod
    public static void invokeCheckBoxFolder(List<genesis__Applications__c> genid) 
    {
        system.debug('*******genesis Application*********'+genid);
        system.debug('*******genid[0].id*********'+genid[0].id);
        
         if(genid[0].BoxFolderID__c !=null  && genid[0].Lead_ID__c !=null){
                CheckBoxFolder(genid[0].id); 
          }       
    }
    
    @future(callout=true)     
    public Static void CheckBoxFolder(Id appID){
            String boxFolderID = Null;
            String appFolderID = Null, investorFolderID = Null;
            try{
                genesis__Applications__c app = [SELECT BoxFolderID__c, Investor__r.BoxFolderID__c, Lead_ID__c, LeadGUID_XX_BoxFolderID__c, LeadGUIDBoxFolderID__c FROM genesis__Applications__c WHERE Id =: appID LIMIT 1];
                if(app != null){
                    if(app.LeadGUID_XX_BoxFolderID__c==null && app.BoxFolderID__c!=null ){
                    for(Integer i=0;i<2000;i++){}
                    System.debug('TIME:::::::::'+DateTime.now().getTime());
                    SearchBoxFolderExist(app.id,app.BoxFolderID__c,app.Lead_ID__c.substring(0, 2));
                    }
                    if(app.LeadGUID_XX_BoxFolderID__c!=null && app.LeadGUIDBoxFolderID__c==null ){
                        for(Integer i=0;i<2000;i++){}
                        System.debug('TIME:::::::::'+DateTime.now().getTime());
                        SearchBoxFolderExist(app.id,app.LeadGUID_XX_BoxFolderID__c,app.Lead_ID__c);
                    }
                    
                 }
             }catch(exception ex){
                loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
                bplog.loan__Origin__c = 'BoxAPI_Integration.CheckBoxFolder';
                bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
                bplog.loan__Type__c = 'Exception';
                bplog.loan__Time__c = DateTime.now();
                insert bplog;
             }
    }

   public static boolean SearchBoxFolderExist(String appID, String parentFolderID, String folder_name){
          try{
                s  = BoX_Integ.getOldAccessToken();
                s1 = s.substringBetween('-');
                System.debug('*****s1*****'+s1);
                s2 = s.substringBefore('-');
                System.debug('*****s2*****'+s2);
                s3 = s.substringAfterLast('-');
                System.debug('****s3******'+s3);
                token = s2;
                refreshToken = s1;
                authId = s3;
                
                req.setEndPoint('https://api.box.com/2.0/search?query='+folder_name+'&type=folder');
                req.setMethod('GET');
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization', 'Bearer '+token);
                
                for(Integer i=0;i<2000;i++)
                {
                }
                System.debug('TIME:::::::::'+DateTime.now().getTime());

                res = http.send(req);
               
                if(res.getStatusCode() == 200){
                    MW_BoxUploadParser folderResp = MW_BoxUploadParser.parse(res.getBody());
                    if(folderResp!=null){
                      for(Integer i=0; i<folderResp.entries.size(); i++){
                           if(folder_name==folderResp.entries[i].name && folderResp.entries[i].parent.Id==parentFolderID){
                             InsertAppFolderID(folderResp.entries[i].Id,appID);
                             return true;
                           }
                      }
                    }
                    CreateAppFolder(appID, parentFolderID, folder_name, null);
                    return false;
                }
                if(res.getStatusCode() == 401 && res.getStatus() == 'Unauthorized')
                {
                    s  = BoX_Integ.getNewAccessToken();
                    s1 = s.substringBetween('-');
                    System.debug('*****s1*****'+s1);
                    s2 = s.substringBefore('-');
                    System.debug('*****s2*****'+s2);
                    s3 = s.substringAfterLast('-');
                    System.debug('****s3******'+s3);
                    token = s2;
                    refreshToken = s1;
                    authId = s3;
                    
                   req.setEndPoint('https://api.box.com/2.0/search?query='+folder_name+'&type=folder');
                   req.setMethod('GET');
                   req.setHeader('Content-Type', 'application/json');
                   req.setHeader('Authorization', 'Bearer '+token);
                   res = http.send(req);

                   System.debug('%%%%%%%%%%%%'+res.getStatus());

                   if(res.getStatusCode() == 200)
                   {    
                        System.debug(' >>>>>>>>>>>>>>>>>>>>> Resposne ' +res.getBody());
                        MW_BoxUploadParser folderResp = MW_BoxUploadParser.parse(res.getBody());
                        if(folderResp!=null){
                          for(Integer i=0; i<folderResp.entries.size(); i++){
                               if(folder_name==folderResp.entries[i].name && folderResp.entries[i].parent.Id==parentFolderID){
                                 InsertAppFolderID(folderResp.entries[i].Id,appID);
                                 BoX_Integ.insertBoxToken(authId,token,refreshToken);
                                 System.debug(' >>>>>>>>>>>>>>>>>>>>> Resposne true' +true);
                                 return true;
                               }
                          }
                        }
                       CreateAppFolder(appID, parentFolderID, folder_name, res.getStatusCode());
                        System.debug(' >>>>>>>>>>>>>>>>>>>>> Resposne true' +false);
                        return false;
                  }
                   
                }
            }catch(exception ex){
                 System.debug('*****folderResp*******'+ ex);
                loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
                bplog.loan__Origin__c = 'BoxAPI_Integration.CreateAppFolder';
                bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
                bplog.loan__Type__c = 'Exception';
                bplog.loan__Time__c = DateTime.now();
                insert bplog;
            }

            return false;
   }

   Public Static void CreateAppFolder(String appID, String investorFolderID, String leadID, Integer ErrorCode){
            try{
                
                req.setEndPoint(CreateFolder_Url);
                req.setMethod('POST');
                Folder folderInfo = new Folder(leadID, investorFolderID);
                body = JSON.Serialize(folderInfo);
                System.debug('...body...' +body);
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization', 'Bearer '+token);
                req.setBody(body);
                
               System.debug('TIME:::::::::'+DateTime.now().getTime());
                for(Integer i=0;i<2000;i++)
                {
                }
                System.debug('TIME:::::::::'+DateTime.now().getTime());
                res = http.send(req);
                System.debug('...res...' + res);
                System.debug('...res body...'+res.getBody());
                System.debug('****'+res.getStatus());
                
                /*if(res.getStatusCode() == 409 && res.getStatus() == 'Conflict')
                {
                
                     res = http.send(req);
                     System.debug('...res...' + res);
                     System.debug('...res body...'+res.getBody());
                     System.debug('****'+res.getStatus());
                }*/
               
                if(res.getStatusCode() == 201 && res.getStatus() == 'Created'){
                    FolderResponse folderResp = (FolderResponse)System.JSON.deserialize(res.getBody(), FolderResponse.class);
                    if(folderResp != Null && folderResp.id != Null){
                        leadFolderID = folderResp.id;
                        System.debug('*****leadFolderID*******'+leadFolderID);
                        InsertAppFolderID(leadFolderID,appID);
                        if(ErrorCode==200)   BoX_Integ.insertBoxToken(authId,token,refreshToken);
                    }
                }

                if(res.getStatusCode() == 401 && res.getStatus() == 'Unauthorized')
                {
                      s  = BoX_Integ.getNewAccessToken();
                      s1 = s.substringBetween('-');
                      System.debug('*****s1*****'+s1);
                      s2 = s.substringBefore('-');
                      System.debug('*****s2*****'+s2);
                      s3 = s.substringAfterLast('-');
                    System.debug('****s3******'+s3);
                    token = s2;
                    refreshToken = s1;
                    authId = s3;
                    
                    //req.setEndPoint(CreateFolder_Url+'?fields=id');
                    req.setEndPoint(CreateFolder_Url);
                    req.setMethod('POST');
                    Folder folderInfo1 = new Folder(leadID, investorFolderID);
                    body = JSON.Serialize(folderInfo1);
                    System.debug('...body...' +body);
                    req.setHeader('Content-Type', 'application/json');
                    req.setHeader('Authorization', 'Bearer '+token);
                    req.setBody(body);
                   
                    res = http.send(req);
                    System.debug('...res...' + res);
                    System.debug('...res body...'+res.getBody());
                    if(res.getStatusCode() != 201 && (token !=null && refreshToken !=null && authId !=null)){
                        BoX_Integ.insertBoxToken(authId,token,refreshToken);
                        
                    }
                    if(res.getStatusCode() == 201 && res.getStatus() == 'Created' && (token !=null && refreshToken !=null && authId !=null)){
                        BoX_Integ.insertBoxToken(authId,token,refreshToken);
                        FolderResponse folderResp = (FolderResponse)System.JSON.deserialize(res.getBody(), FolderResponse.class);
                        if(folderResp != Null && folderResp.id != Null){
                            leadFolderID = folderResp.id;
                            System.debug('*****leadFolderID*******'+leadFolderID);
                            InsertAppFolderID(leadFolderID,appID);
                        }
                    }
                    
                }
            }catch(exception ex){
                loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
                bplog.loan__Origin__c = 'BoxAPI_Integration.CreateAppFolder';
                bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
                bplog.loan__Type__c = 'Exception';
                bplog.loan__Time__c = DateTime.now();
                insert bplog;
            }
        }
        Public class FolderResponse{
            Private String type;
            Private String id;
            Private String etag;
            
            
        }
        
        private class fileFolder{
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

        public Static Void InsertAppFolderID(String folderID, String appID){
            System.debug('...AppID: ...'+appID);
            genesis__Applications__c app = [SELECT BoxFolderID__c, LeadGUID_XX_BoxFolderID__c, LeadGUIDBoxFolderID__c,Lead_ID__c FROM genesis__Applications__c WHERE Id =: appID LIMIT 1];
            if(app != Null && app.BoxFolderID__c!=null && app.LeadGUID_XX_BoxFolderID__c==null){
                //app.BoxFolderID__c              = folderID;
                app.LeadGUID_XX_BoxFolderID__c  = folderID; 
                update app;
            }
            else if(app != Null && app.LeadGUID_XX_BoxFolderID__c!=null && app.LeadGUIDBoxFolderID__c==null){
                 app.LeadGUIDBoxFolderID__c  = folderID; 
                 update app;
            }
        }
}