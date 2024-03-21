/* ****************Modification History*****************************************************************
 * @author - Pallavi  CRM-65
 * Modified by      Date            JIRA number
 *     Pallavi      2020/10/21      CRM-65(DCP - Read and post the webhook response on payments from Arcus)
 ******************Modification History*****************************************************************/
@RestResource(urlMapping='/CallbackArcus/*')
global class ArcusWebhookAPI {
    
    global class errorResponse{	//pallavi
        public String errorCode {get;set;}
        public String message {get;set;}
     }
    
    global class Response{	//pallavi
       	public String transactionId {get;set;}
        public String status {get;set;}
     }
    
    @HttpPatch
    global static void arcusCallback() {	//pallavi
        //pallavi
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'text/plain');
        
        errorResponse errRes = new errorResponse();	//pallavi
        Response res = new Response();
        
        String status;
        
        try{
            String txnId = request.requestURI.substring(
            request.requestURI.lastIndexOf('/')+1);
        
        System.debug('txnId = ' + txnId);
                        
        if(txnId==null || txnId==''){
            //throw new ints.IntegrationException('Please send a transaction id');
            errRes.errorCode = 'Null_Id';
            errRes.message = 'Transaction Id is null';
            response.statusCode = 400;
        	response.responseBody = blob.valueOf(JSON.serialize(errRes));
            return;
        }
        
        List<loan__Disbursal_Txn_Distribution__c> DCPtransactionStatus = [Select id,Arcus_Transaction_Status__c FROM loan__Disbursal_Txn_Distribution__c
                                                  					WHERE Arcus_Transaction_Id__c =: txnId];
        if(DCPtransactionStatus.size()==0){
           //throw new ints.IntegrationException('Please send a valid transaction id');
            errRes.errorCode = 'Invalid_Id';
            errRes.message = 'Please send a valid transaction id';
            response.statusCode = 400;
        	response.responseBody = blob.valueOf(JSON.serialize(errRes));
            return;
        }
        List<DCp_Arcus_Transactions__c> DCPArcusStatus = [Select id,Status__c FROM DCp_Arcus_Transactions__c
                                                  					WHERE Transaction_Id__c =: txnId];
                   
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
        status = (String)(params.get('status'));
        for(String fieldName : params.keySet()) {
            System.debug(fieldName);
            System.debug(params.get(fieldName));
        }
        
        
        DCPtransactionStatus[0].Arcus_Transaction_Status__c = status;
        update DCPtransactionStatus;
        
         if(DCPArcusStatus.size() > 0){
            DCPArcusStatus[0].Status__c = status;
         	update DCPArcusStatus;
         }    
             
        res.status = status;
        res.transactionId = txnId;    
        
        String resString = JSON.serialize(res); 
        resString = resString.replace('transactionId', 'transaction');    
            
        response.statusCode = peer.Constants.HTTP_OK;
        response.responseBody = blob.valueOf(resString);
               
        //return 'hit succesfull';
        }
        catch(Exception e){
            errRes.errorCode = peer.Constants.UNKNOWN_EXCEPTION;
            errRes.message = e.getMessage()+' at line number'+e.getLineNumber();
            response.statusCode = peer.Constants.HTTP_INTERNAL_ERROR;
        	response.responseBody = blob.valueOf(JSON.serialize(errRes));
        }    
        
    }

}