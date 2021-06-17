global class AdverseScoreIntegration {
    String endpoint = '';
    global AdverseScoreIntegration(){  }
    
    //Setting EndPoint and the request For the Call
    global AdverseScoreResponse getAdvScData(String payoff_uid,String accountID,String appId) { 
        
        Http http = new Http();
        
        HttpRequest Reques = new HttpRequest();
        Reques.setMethod('GET');
        
        Reques.setHeader('Content-Type', 'application/json');
        Reques.setHeader('Accept', 'application/json');
       Reques.setEndpoint('https://sfapi-dev.payoff.com/cp/api/v1/credit_policy/decisions?payoff_uid='+ payoff_uid);
        
       system.debug('### Earlier string 1'+Reques.getEndpoint());
       system.debug(Reques.getEndpoint());
        
        HttpResponse res = http.send(Reques);
        system.debug(res.getBody());
        AdverseScoreResponse resp=parseAdvScResponse(res,accountID,appId);
        
        return resp;
    }
    //Parsing The Response    
    global AdverseScoreResponse parseAdvScResponse(HttpResponse response,String accountID,String appId) {
        
        AdverseScoreResponse responseCB=null;
        if(response.getStatusCode() == 200) {
            
            try {
                AdverseScoreResponse responseC = new AdverseScoreResponse().parse(response.getBody(),accountID,appId);
                responseC.responseBody = response.getBody();  
                System.Debug('....Adverse Score Response:...' + responseC); 
                return responseC;
            }
            
            catch (JSONException e) { 
                throw new ints.IntegrationException('Something went wrong wile parsing response. ' + e.getMessage());
            }
        }
        else {
            AdverseScoreResponse responseC= new AdverseScoreResponse().parse(response.getBody(),accountID,appId);
            responseC.integrationErrorStatus = response.getStatus();
            responseC.integrationErrorStatusCode = String.valueOf(response.getStatusCode());
            return responseC;
        }
        
        return responseCB;
    }
    

}