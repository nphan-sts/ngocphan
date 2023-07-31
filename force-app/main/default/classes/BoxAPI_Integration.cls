public with Sharing class BoxAPI_Integration
{ 
    Private Static String CreateFolder_Url = 'https://api.box.com/2.0/folders';
    Private Static String CreateFile_Url = 'https://httpbin.org/anything';
  
    
    public static Void getBoxToken(String applicationID, String oAuthSettingsID, String authCode){  
        System.debug('...getBoxToken...');
        //AppID = applicationID;
        System.debug('...authId...'+ oAuthSettingsID);
        System.debug('...authCode...'+ authCode);
        String accessToken = Null, refreshToken = Null;
        
        try{
            if(oAuthSettingsID != Null){
                ints__OAuth_Settings__c authSettings = [SELECT ints__Consumer_Key__c, 
                                                            ints__Consumer_Secret__c, 
                                                            ints__Access_Token_URL__c, 
                                                            ints__Request_Token_URL__c 
                                                        FROM ints__OAuth_Settings__c WHERE ID =: oAuthSettingsID];
                    
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndPoint(authSettings.ints__Access_Token_URL__c);
                req.setBody('Content-Type=' + EncodingUtil.urlEncode('application/x-www-form-urlencoded', 'UTF-8') + 
                            '&charset=' + EncodingUtil.urlEncode('UTF-8', 'UTF-8') + 
                            '&grant_type=' + EncodingUtil.urlEncode('authorization_code', 'UTF-8') + 
                            '&code=' + EncodingUtil.urlEncode(authCode, 'UTF-8') + 
                            '&client_id=' + EncodingUtil.urlEncode(authSettings.ints__Consumer_Key__c, 'UTF-8') + 
                            '&client_secret=' + EncodingUtil.urlEncode(authSettings.ints__Consumer_Secret__c, 'UTF-8'));
                req.setMethod('POST');
                HttpResponse resp = http.send(req);
                System.debug('...resp...'+resp);
                String response = resp.getBody();
                System.debug('...Resp Body...'+response);
                
                BOXTokenResponseParcer tokenRespObj = BOXTokenResponseParcer.parse(response);
                System.debug('&&&'+tokenRespObj);
                if(tokenRespObj != Null){ 
                    System.debug('...Access Token...**'+tokenRespObj.access_token);
                    accessToken = tokenRespObj.access_token;
                    refreshToken = tokenRespObj.refresh_token;
                    System.debug('...Tokens...' + accessToken + '...' + refreshToken);
                    insertBoxToken(oAuthSettingsID, accessToken, refreshToken);
                }
            }
        }catch(exception ex){
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'BoxAPI_Integration.getBoxToken';
            bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            insert bplog;
        }    
    }
    
    public static String getAccessToken(){  
        System.debug('...getBoxAccessToken...');
        String accessToken = Null, refreshToken = Null;
        
        try{
            ints__OAuth_Settings__c oAuthName = [SELECT Id,Name, ints__Access_Token_URL__c,ints__Consumer_Key__c, ints__Consumer_Secret__c 
                                     FROM ints__OAuth_Settings__c WHERE ints__Service_Name__c ='BoxSB.com' LIMIT 1];
    System.debug('... oAuthName...');
            if(oAuthName != Null){              
                ints__OAuth_Token__c authToken = [SELECT ints__Token__c, 
                                                        ints__Refresh_Token__c
                                                        FROM ints__OAuth_Token__c WHERE 
                                                        ints__OAuth_Settings__c =: oAuthName.Id and 
                                                  ints__Is_Valid__c = true Order By CreatedDate DESC LIMIT 1];
                System.debug('... authToken...');
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
                    if(tokenRespObj != Null){ 
                        System.debug('...Access Token...**'+tokenRespObj.access_token);
                        accessToken = tokenRespObj.access_token;
                        refreshToken = tokenRespObj.refresh_token;
                        System.debug('...Tokens...' + accessToken + '...' + refreshToken);
                        insertBoxToken(authToken.Id, accessToken, refreshToken);
                    }
                }
            }
            
        }catch(exception ex){
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'BoxAPI_Integration.getBoxToken';
            bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            insert bplog;
        } 
        return accessToken;
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
            bplog.loan__Origin__c = 'BoxAPI_Integration.insertBoxToken';
            bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            insert bplog;
        }
    }
}