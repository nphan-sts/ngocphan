public with sharing class MW_BoxUtilHelper 
{

    public static genesis__Applications__c getAppDetails(Id appID){

       genesis__Applications__c app = [SELECT BoxFolderID__c,  Investor__r.BoxFolderID__c, Lead_ID__c, 
                                                      LeadGUID_XX_BoxFolderID__c, LeadGUIDBoxFolderID__c FROM genesis__Applications__c WHERE Id =: appID LIMIT 1];

         return app;                                              
    }

  // Create a new Access Token. 
    public static String getNewAccessToken(){  
     String accessToken, refreshToken;

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
                                                         ints__OAuth_Settings__c =: oAuthName.Id AND
                                                         ints__Is_Valid__c = true Order By CreatedDate DESC LIMIT 1];


                if(authToken.ints__Refresh_Token__c != null && authToken.ints__Refresh_Token__c != 'null')
                {  
                    Http http = new Http();
                    HttpRequest req = new HttpRequest();
                    req.setEndPoint(oAuthName.ints__Access_Token_URL__c);
                    req.setHeader('User-Agent', 'Box Apex SDK v1.0.0');
                    req.setBody('Content-Type=' + EncodingUtil.urlEncode('application/x-www-form-urlencoded', 'UTF-8') + 
                                '&charset=' + EncodingUtil.urlEncode('UTF-8', 'UTF-8') + 
                                '&grant_type=' + EncodingUtil.urlEncode('refresh_token', 'UTF-8') + 
                                '&refresh_token=' + EncodingUtil.urlEncode(authToken.ints__Refresh_Token__c, 'UTF-8') +
                                '&client_id=' + EncodingUtil.urlEncode(oAuthName.ints__Consumer_Key__c, 'UTF-8') + 
                                '&client_secret=' + EncodingUtil.urlEncode(oAuthName.ints__Consumer_Secret__c, 'UTF-8'));
                    req.setMethod('POST');
                    System.debug('Req Body>>>'+req);
                    HttpResponse resp = http.send(req);
                    String response = resp.getBody();
                    System.debug('Resp Body>>>'+response);
                    
                    BOXTokenResponseParcer tokenRespObj = BOXTokenResponseParcer.parse(response);
                   
                    if(tokenRespObj.access_token != null  && tokenRespObj.access_token != 'null' && tokenRespObj.refresh_token != null && tokenRespObj.refresh_token != 'null'){
                        accessToken = tokenRespObj.access_token;
                        refreshToken = tokenRespObj.refresh_token;
                    }

                    if(tokenRespObj.error != null || tokenRespObj.error_description != null){
                        MW_LogUtility.error('MW_BoxUtilHelper', 'getNewAccessToken', tokenRespObj.error_description);
                    }
                }else{
                    MW_LogUtility.error('MW_BoxUtilHelper', 'getNewAccessToken', 'BOX Refresh Token is NULL. Manual refresh is required.');
                }
            }
            
        }catch(exception ex){
            MW_LogUtility.error('MW_BoxUtil1', '', '', 'getNewAccessToken', ex);
        } 

        return accessToken+'-'+refreshToken+'-'+authToken.id;
    }
}