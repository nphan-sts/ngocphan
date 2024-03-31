global class LastUpdateDate {

    webservice static String getLastUpdate(String cobSession, String userToken, string accId){
        
        ints__Yodlee_Cobrand_Credentials__c cobrand = ints__Yodlee_Cobrand_Credentials__c.getInstance();
        
        String url = cobrand.ints__Rest_URL__c + 'accounts?status=ACTIVE&container=bank';
        String response;    
        String lastUpdate;
        
        try{
            HttpRequest req = new HttpRequest();
            
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', '{cobSession=' + cobSession + ',userSession=' + userToken + '}');
            
            req.setEndpoint(url);
            
            //To return fake response in case of Test.
            if(Test.isRunningTest()){
                System.debug('Test: Fake Response');
            }
            try{
                // Create a new http object to send the request object
                // A response object is generated as a result of the request  
                Http http = new Http();
                HTTPResponse res = http.send(req);
                response = res.getBody();
                
                system.debug('__________________USER ACCOUNT DETAILS RESPONSE BODY___________________________');
                system.debug(LoggingLevel.ERROR, response);
                
                GetAccountContainer getAccount = GetAccountContainer.parse(response);
                
                For(GetAccountContainer.cls_account getAcc : getAccount.account){
                    //if(String.valueOf(getAcc.id).equals(accId)){
                        lastUpdate = String.valueof(getAcc.refreshinfo.lastRefreshed);
                        System.debug('Last Update Date ---> ' + lastUpdate);
                    //}
                }
                return lastUpdate;
            } catch(Exception e){
                System.debug('Erro --> ' + e.getMessage() + ' ' + e.getStackTraceString());
                return e.getMessage();
            }
            
        }
        catch(Exception ex){
            System.debug('Error --> ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            return ex.getMessage();                  
        }
    }
}