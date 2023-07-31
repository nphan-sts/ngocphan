global class UpdateAccountInfo {

    public static String cobSession;
    public static String userToken;
        
    webservice static String getLastUpdate(id accountId){
        
        cobSession = YodleeTransactionAPICallOut.getCobSession();
        UserToken = YodleeTransactionAPICallOut.UserToken(accountId);
        
        Account acc = [select id, 
                            Last_Update_Date__c
                            FROM Account 
                            WHERE id =: accountId];
        System.debug('_____AcCount _____'+acc);
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
                system.debug(LoggingLevel.ERROR,response);
                response = response.replace('"currency":', '"currencyAmount":');
                
                GetAccountContainer getAccount = GetAccountContainer.parse(response);
                System.debug('******getAccount*****'+getAccount);
                
                if(getAccount!=null && getAccount.account!=null) {
                    For(GetAccountContainer.cls_account getAcc : getAccount.account){
                        //if(String.valueOf(getAcc.id).equals(accId)){
                            lastUpdate = getAcc.refreshinfo.lastRefreshed.format('yyyy-MM-dd');
                            System.debug('&&&'+lastUpdate);
                        //}
                    }
                }
                if(lastUpdate != null)
                    acc.Last_Update_Date__c = lastUpdate;
                System.debug('******lastUp*****'+lastUpdate);
                update acc;
                return lastUpdate;
            } catch(Exception e){
                System.debug('Error --> ' + e.getMessage() + ' ' + e.getStackTraceString());
                return e.getMessage();
            }
            
        }
        catch(Exception ex){
            System.debug('Error --> ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            return ex.getMessage();                  
        }
    }
    
    
}