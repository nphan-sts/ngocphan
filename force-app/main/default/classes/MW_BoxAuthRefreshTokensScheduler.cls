global class MW_BoxAuthRefreshTokensScheduler implements Schedulable{

    global void execute(SchedulableContext SC) {
        String tokenDetails = MW_BoxAuthRefreshTokensScheduler.getNewAccessToken();
    }


    public static String getNewAccessToken()
    {
        System.debug('...getBoxAccessToken...');
        String accessToken = Null, refreshToken = Null;
        Integer expireTime=0;
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
                        expireTime   = tokenRespObj.expires_in;
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

        List<ints__OAuth_Token__c> lstAuthToken = [SELECT ints__Token__c, ints__Refresh_Token__c, ints__Is_Valid__c FROM ints__OAuth_Token__c WHERE ID =:authToken.Id
                                                            ORDER BY CreatedDate DESC Limit 1];
        if(!lstAuthToken.isEmpty() && lstAuthToken!=null)
        {
             lstAuthToken[0].ints__Token__c = accessToken;
             lstAuthToken[0].ints__Refresh_Token__c = refreshToken;
             lstAuthToken[0].ints__Is_Valid__c = true;
             lstAuthToken[0].Valid_Time__c = expireTime/60;
             update lstAuthToken[0];
       }

        return String.valueOf(expireTime/60)+'-'+accessToken+'-'+refreshToken+'-'+authToken.id;
    }
}