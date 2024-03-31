public with sharing class MW_BoX_Integ {
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
    public static string type;
    public static string id;
    public static string url;
    public static string DocName;

    public static String getOldAccessToken(){  
        System.debug('...getBoxAccessToken...');
        String accessToken = Null, refreshToken = Null;
        
        try{
            ints__OAuth_Settings__c oAuthName = [SELECT Id,Name, ints__Access_Token_URL__c,ints__Consumer_Key__c, ints__Consumer_Secret__c 
                                     FROM ints__OAuth_Settings__c WHERE ints__Service_Name__c ='BoxSB.com' LIMIT 1];
            System.debug('... oAuthName...'+oAuthName );
                if(oAuthName != Null){              
                    ints__OAuth_Token__c authToken = [SELECT ints__Token__c, 
                                                            ints__Refresh_Token__c
                                                            FROM ints__OAuth_Token__c WHERE 
                                                            ints__OAuth_Settings__c =: oAuthName.Id and 
                                                      ints__Is_Valid__c = true Order By CreatedDate DESC LIMIT 1];
                    System.debug('... authToken...'+authToken);
                    if(authToken.ints__Token__c !=null){  
                        
                            System.debug('...Access Token...**'+authToken.ints__Token__c);
                            accessToken = authToken.ints__Token__c;
                            refreshToken = authToken.ints__Refresh_Token__c;
                            System.debug('...Tokens...' + accessToken + '...' + refreshToken);
                        }
                }
            }
            
        catch(exception ex){
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'BoX_Integ.getOldAccessToken';
            bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            insert bplog;
        } 
        return accessToken;
    }
    public static String getNewAccessToken(){  
    System.debug('...getBoxAccessToken...');
        String accessToken = Null, refreshToken = Null;
        ints__OAuth_Token__c authToken;
        
        try{
            ints__OAuth_Settings__c oAuthName = [SELECT Id,Name, ints__Access_Token_URL__c,ints__Consumer_Key__c, ints__Consumer_Secret__c 
                                     FROM ints__OAuth_Settings__c WHERE ints__Service_Name__c ='BoxSB.com' LIMIT 1];
            System.debug('... oAuthName...'+oAuthName );
            if(oAuthName != Null){              
                                     authToken = [SELECT id,
                                                         ints__Token__c, 
                                                         ints__Refresh_Token__c
                                                        FROM ints__OAuth_Token__c WHERE 
                                                        ints__OAuth_Settings__c =: oAuthName.Id and 
                                                  ints__Is_Valid__c = true Order By CreatedDate DESC LIMIT 1];
                System.debug('... authToken...'+authToken);
                if(authToken.ints__Refresh_Token__c !=null){  
                    Http http = new Http();
                    HttpRequest req = new HttpRequest();
                    //req.shouldAuthenticate = false;
                    req.setEndPoint(oAuthName.ints__Access_Token_URL__c);
                    req.setHeader('User-Agent', 'Box Apex SDK v1.0.0');
                    req.setBody('Content-Type=' + EncodingUtil.urlEncode('application/x-www-form-urlencoded', 'UTF-8') + 
                                '&charset=' + EncodingUtil.urlEncode('UTF-8', 'UTF-8') + 
                                '&grant_type=' + EncodingUtil.urlEncode('refresh_token', 'UTF-8') + 
                                '&refresh_token=' + EncodingUtil.urlEncode(authToken.ints__Refresh_Token__c, 'UTF-8') +
                                '&client_id=' + EncodingUtil.urlEncode(oAuthName.ints__Consumer_Key__c, 'UTF-8') + 
                                '&client_secret=' + EncodingUtil.urlEncode(oAuthName.ints__Consumer_Secret__c, 'UTF-8'));
                    req.setMethod('POST');
                    HttpResponse resp = http.send(req);
                    System.debug('...resp...'+resp);
                    String response = resp.getBody();
                    System.debug('...Resp Body...'+response);
                    //{"access_token":"VPTELvq1gYzJmgqaFFsSuAZfOwyBj4pk","expires_in":3975,"restricted_to":[],"refresh_token":"hWZu9ngpClDnlPIBPiHnUWvReBC87xKhIKhYImMaank9ZK7jCjY4wYP8fGH772uE","token_type":"bearer"}
                    
                    BOXTokenResponseParcer tokenRespObj = BOXTokenResponseParcer.parse(response);
                    System.debug('&&&'+tokenRespObj);
                    if(tokenRespObj.access_token != Null && tokenRespObj.refresh_token !=null){ 
                        System.debug('...Access Token...**'+tokenRespObj.access_token);
                        accessToken = tokenRespObj.access_token;
                        refreshToken = tokenRespObj.refresh_token;
                        System.debug('...Tokens...' + accessToken + '...' + refreshToken);
                        
                        //attachment att = [select name,body from attachment where name like '%TIL%' limit 1];
                        //uploadAdverseToBox(att,accesstoken);
                    }
                    if(tokenRespObj.error !=null || tokenRespObj.error_description != null){
                        System.debug('*****'+tokenRespObj.error+'*******'+tokenRespObj.error_description);
                    }
                    if(tokenRespObj.error_description == 'Refresh token has expired'){
                        System.debug('***call the authorization class****');
                    }
                }
            }
            
        }catch(exception ex){
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'BoX_Integ.getNewAccessToken';
            bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
            System.debug('******' +ex.getMessage());
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            insert bplog;
        } 
        return accessToken+'-'+refreshToken+'-'+authToken.id;
    }
      Public Static Void insertBoxToken(Id oAuthID, String accessToken, String refreshToken){
        try{
            if(accessToken != Null){
                List<ints__OAuth_Token__c> lstAuthToken = [SELECT ints__Token__c, ints__Refresh_Token__c, ints__Is_Valid__c 
                                                           FROM ints__OAuth_Token__c WHERE ID =: oAuthID 
                                                            ORDER BY CreatedDate DESC Limit 1];
                if(! lstAuthToken.isEmpty()){
                    lstAuthToken[0].ints__Token__c = accessToken;
                    lstAuthToken[0].ints__Refresh_Token__c = refreshToken;
                    lstAuthToken[0].ints__Is_Valid__c = true;
                    update lstAuthToken[0];
                }
                
                else{
                    ints__OAuth_Token__c authToken = new ints__OAuth_Token__c();
                    authToken.ints__OAuth_Settings__c = oAuthID;
                    authToken.Name = oAuthID;
                    authToken.ints__Token__c = accessToken;
                    authToken.ints__Refresh_Token__c = refreshToken;
                    authToken.ints__Is_Valid__c = true;
                    insert authToken;
                } 
                
                //CheckBoxFolder(applicationID, accessToken);
            }
        }catch(exception ex){
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'BoX_Integ.insertBoxToken';
            bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            insert bplog;
        }
    }
     Static Integer startTime; 

     public static String uploadFileToBox(Blob file_body,String filename,string folderid,string appId)
     {
     try{
        BoxUrl__c box = BoxUrl__c.getOrgDefaults();
        //String strFolderId ='47383466400';
        String strFolderId = folderid;
        if(strFolderId != null){
            s = getOldAccessToken();
            token = s;
            System.debug('******token*****'+token);
            
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
              req.setTimeout(60000);
              req.setHeader('Authorization', 'Bearer '+token);
              req.setHeader('Content-Length',String.valueof(req.getBodyAsBlob().size()));
          
              startTime = System.Now().millisecond();
              while(System.Now().millisecond()< startTime+10){ 
              }
              res = http.send(req);
              System.debug('*****res*****'+res);
              System.debug('*****res_grtbody****'+res.getBody());
              
              if(res.getStatusCode() == 201 && res.getStatus() == 'Created')
              {
                  BOXTokenResponseParcer tokenRespObj = BOXTokenResponseParcer.parse(res.getBody());
                  System.debug('****tokenRespObj*****'+tokenRespObj);
                  type = tokenRespObj.entries[0].type ;
                  id = tokenRespObj.entries[0].id ;
                  System.debug('*****tokenRespObj******'+type+'**********'+id);
                  //string urlbox = box.Boxurl__c;
                  url = box.Boxurl__c+type+'/'+id;
                  System.debug('*****url*****'+url);

                  return url;
                  /*if(appId != null && folderid != null)
                   { 
                           if(filename.contains('preciseid'))  DocName = 'preciseid';	 
                           if(filename.contains('talx'))  DocName = 'talx';
                           if(filename.contains('linked_acct'))  DocName = 'linked_acct';
                           if(filename.contains('cbr'))  DocName = 'cbr';
                           System.debug('>>>>>>>>>>>' +DocName);
                           Origination_Documents__c AppDocCategory = [SELECT id, Application__c, Name, BoxUrl__c 
                                                                              FROM Origination_Documents__c 
                                                                              WHERE Application__c =: appId AND Type__c =:DocName Limit 1];
                              
                           AppDocCategory.BoxUrl__c = url;
                           System.debug('******ur******'+url);
                           Update AppDocCategory;
                  }*/
              }
              
              if(res.getStatusCode() == 401 && res.getStatus() == 'Unauthorized')
              {
                  System.debug('****i entered into getNewAccessToken***********');
                  string Gentoken = getNewAccessToken();
                  s  = Gentoken;
                  s1 = s.substringBetween('-');
                  System.debug('*****s1*****'+s1);
                  s2 = s.substringBefore('-');
                  System.debug('*****s2*****'+s2);
                  s3 = s.substringAfterLast('-');
                  System.debug('****s3******'+s3);
                  String token = s2;
                  String refreshToken = s1;
                  String authId = s3;
              
                  req.setHeader('Content-Type','multipart/form-data;non_svg='+True+';boundary='+boundary);
                  req.setMethod('POST');
                  req.setEndpoint(sUrl);
                  req.setBodyAsBlob(bodyBlob);
                  req.setTimeout(60000);
                  req.setHeader('Authorization', 'Bearer '+token);
                  req.setHeader('Content-Length',String.valueof(req.getBodyAsBlob().size()));
              
                  res = http.send(req);
                  System.debug('*****res*****'+res);
                  System.debug('*****res_grtbody****'+res.getBody());
                  if(res.getStatusCode() != 201 || (token != null && refreshToken != null && authId != null)){
                  
                       insertBoxToken(authId,token,refreshToken);
                      
                    }
                  
                  if(res.getStatusCode() == 201 && res.getStatus() == 'Created')
                  {
                      insertBoxToken(authId,token,refreshToken);
                      BOXTokenResponseParcer tokenRespObj = BOXTokenResponseParcer.parse(res.getBody());
                      System.debug('****tokenRespObj*****'+tokenRespObj);
                      type = tokenRespObj.entries[0].type ;
                      id = tokenRespObj.entries[0].id ;
                      System.debug('*****tokenRespObj******'+type+'**********'+id);
                      //string urlbox = box.Boxurl__c;
                      url = box.Boxurl__c+type+'/'+id;
                      System.debug('*****url*****'+url);
                      return url;
                      /*if(appId != null && folderid != null)
                        {
                          DocName = filename.substringBefore(' a6h');
                          string DocumentName = '%' + DocName + '%';
                          System.debug('*****DocumentName*****'+DocumentName);
                           genesis__Application_Document_Category__c AppDocCategory = [SELECT id,
                                                                                   genesis__Application__c,
                                                                                   Name,
                                                                                   Box_URl__c 
                                                                              FROM genesis__Application_Document_Category__c 
                                                                              WHERE genesis__Application__r.id =: appId 
                                                                              AND Name like : DocumentName Limit 1];
                              
                              AppDocCategory.Box_URl__c = url;
                              System.debug('******ur******'+url);
                              Update AppDocCategory;

                        }*/
                  }
                  
                }
              }
          }
          catch(exception ex){
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'BoX_Integ.uploadFileToBox';
            bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            insert bplog;
        }    
          return null;  
    }  

   
}