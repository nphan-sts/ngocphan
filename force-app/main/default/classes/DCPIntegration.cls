public class DCPIntegration {
    
    private static DCP_Arcus__c dcpParameters = DCP_Arcus__c.getOrgDefaults();
    public static String generateSHA1(String contentType, String md5, String endpoint, String dateTimestamp){
        
        
        String checksumString = contentType+','+md5+','+endpoint+','+dateTimestamp;
        //application/json,,/account,Wed, 02 Nov 2016 17:26:52 GMT';
        String key = dcpParameters.secret_key__c;
        Blob data = crypto.generateMac('HmacSHA1',Blob.valueOf(checksumString), Blob.valueOf(key));
        String checksum = EncodingUtil.base64encode(data);
        System.debug(checksum);
        
        return checksum;        
    }
    
    private static httpResponse httpCall(String body,String method,String endPoint,Map<String,String>headers) {
        Http http = new Http();
        httpResponse response = new httpResponse();
        httpRequest request = new httpRequest();
        //if(method.endsWithIgnoreCase('PATCH')) {
        //    request.setMethod('PUT');
            //request.setHeader('X-HTTP-Method-Override','PATCH');
        //} else {
            
        //}
        request.setMethod(method);
        if(!headers.isEmpty()) {
            for(string keys:headers.keySet()) {
                request.setHeader(keys, headers.get(keys));
            }
        }
        request.setEndpoint(endPoint);
        if(body!=null) {
            request.setBody(body);
        }
         try {
            response = http.send(request);
        }catch(Exception ex) {
            loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__Message__c='Error in DCPIntegration:  '+ex.getlinenumber()+'Error:: '+ex.getMessage() +'stack ::'+ex.getStackTraceString());
            insert logs;
            throw new ints.IntegrationException(ex.getMessage());
        }
        return response;
    } 
    
    public static httpResponse getAccounts() {
        if(dcpParameters == null) {
            throw new ints.IntegrationException('DCP_Arcus__c is empty');
        }
        String method = 'GET';
        DateTime myDateTime = DateTime.now();
        String formattedDate = myDateTime.formatGMT('EEE, dd MMM yyyy HH:mm:ss')+' GMT';
        String expected = 'Sun, 6 Jun 1993 10:03:03';
        //System.assertEquals(expected, formatted);
        String endPoint = dcpParameters.endpoint__c+'/account';
        String checksumString  = generateSHA1('application/json','','/account',formattedDate);
        Map<String,String> headers = new Map<String,String>();
        headers.put('Authorization','APIAuth '+dcpParameters.API_key__c+':'+checksumString);
        headers.put('Accept','application/vnd.regalii.v3.2+json');
        headers.put('X-Date',formattedDate);
        headers.put('Content-MD5','gft1UOgrwWQVv0cOSEK80A==');
        headers.put('Content-Type','application/json');
        
        httpResponse response = httpCall(null,method,endpoint,headers);
        System.debug(response.getBody());
        if(response.getStatusCode()==401) {
            throw new ints.IntegrationException('Please check the Authorisation header');
        }
        
        
        //DCPResponse deserialise = (DCPResponse)JSON.deserialize(response.getBody(), DCPResponse.class);
        return response;
        
    }
    
    public static httpResponse patchTransactions(String transactionId) {
        
        if(dcpParameters == null) {
            throw new ints.IntegrationException('DCP_Arcus__c is empty');
        }
        String method = 'PUT';
        DateTime myDateTime = DateTime.now();
        String formattedDate = myDateTime.formatGMT('EEE, dd MMM yyyy HH:mm:ss')+' GMT';
        //String expected = 'Sun, 6 Jun 1993 10:03:03';
        //System.assertEquals(expected, formatted);
        String endPoint = dcpParameters.endpoint__c+'transactions/'+transactionId/*+'?_HttpMethod=PATCH'*/;
        System.debug(endpoint);
        System.debug(formattedDate);
        String checksumString  = generateSHA1('application/json','','/transactions/'+transactionId,formattedDate);
        Map<String,String> headers = new Map<String,String>();
        headers.put('Authorization','APIAuth '+dcpParameters.API_key__c+':'+checksumString);
        //headers.put('Authorization','APIAuth 0683f8c05b4540f7f0ac0ca8a0046445:HcfgAwkqqZ0zDqBtzxZOENWALeo=');
        headers.put('Accept','application/vnd.regalii.v3.2+json');
        headers.put('X-Date',formattedDate);
        //headers.put('X-Date','Wed, 30 Jan 2019 23:44:16 GMT');
        //headers.put('Content-MD5','gft1UOgrwWQVv0cOSEK80A==');
        headers.put('Content-Type','application/json');
        String body = '{"status": "initialized"}';
        httpResponse response = httpCall(body,method,endpoint,headers);
        System.debug(response.getBody()+'....'+response.getStatusCode());
        if(response.getStatusCode()==401) {
            throw new ints.IntegrationException('Please check the Authorisation header');
        }
        
        
        //DCPResponse deserialise = (DCPResponse)JSON.deserialize(response.getBody(), DCPResponse.class);
        //return deserialise;
        //return null;
        return response;
    }
    
}