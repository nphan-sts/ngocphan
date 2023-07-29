public class CongaAutomation {
    @Future(callout=true)
    public static void CongaBackgroundMode(Id applicationId) {
        
        String body = 'grant_type=password&client_id=3MVG9PerJEe9i8iKxKFsK7WXUEqAmH04tFGoEmLzJBpRNNXEif0jB4oeobUq3CujhSlJky9q3sUS8WuPGUwBz&client_secret=2015175035949871663&username=vericode@96trialforce.com.payoff&password=Welcome12345iwkTBqLiisiw4vAmssTOpm3h';
        
        system.debug('body ' + body);
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://cs30.salesforce.com/services/oauth2/token');
        req.setMethod('POST');
        req.setBody(body);
        Http http = new Http();
        HttpResponse res = http.send(req);
              
        WrapperSecurityToken resData = (WrapperSecurityToken)JSON.deserialize(res.getBody(),WrapperSecurityToken.class);
        
        String servUrl = Url.getSalesforceBaseUrl().toExternalForm()+'/services/Soap/u/29.0/'+UserInfo.getOrganizationId();
        
        
        system.debug('url:' + servUrl);
        String url2 = 'https://composer.congamerge.com/composer8/index.html'+
            '?SolMgr=1&sessionId='+resData.access_token+
            '&serverUrl='+EncodingUtil.urlEncode(servUrl, 'UTF-8')+
            '&id='+applicationId+
            '&TemplateId=aAWn00000009JFr'+
            '&APIMode=1';
        
        System.debug('URL:' +url2);
        
        Http http2 = new Http();
        HttpRequest req2 = new HttpRequest();
        req2.setEndpoint(url2);
        req2.setMethod('GET');
        req2.setTimeout(60000);
        
        // Send the request, and return a response
        HttpResponse res2 = http2.send(req2);
        
        System.debug('Respone :::'+res2);
        
        system.debug (res2.getStatus() + ' => ' + res2);
        
    }
    
}