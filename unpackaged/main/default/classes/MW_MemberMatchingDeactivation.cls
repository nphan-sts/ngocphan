global with sharing class MW_MemberMatchingDeactivation {
    webservice static Boolean makeCallout(String leadId){
        Lead ld = new Lead();
        Boolean isSuccess = false;
        try{
            ld = [SELECT id, Member_Matching_Deactivation_Response__c,lead_guid__c FROM LEad where id=:leadId LIMIT 1];
            String certName = MW_Settings__c.getInstance().CertificateNameForLEADS__c;
            String leadsEndPoint = MW_Settings__c.getInstance().MemberMatchingDeactivationTool__c;

            
            system.debug('leadsEndPoint -->'+leadsEndPoint);
            system.debug('certName -->'+certName);
            HTTPRequest req = new HTTPRequest();
            HTTP http = new HTTP();
            req.setEndpoint(leadsEndPoint);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Cache-Control', 'no-cache');
            if(certName!=null) {
                req.setClientCertificateName(certName) ;
            }
            req.setBody('{"lead_guid": "'+ld.lead_guid__c+'"}');
    
            system.debug('Request  -->'+ req);
            HTTPResponse res = new HTTPResponse();
            res = http.send(req);
            system.debug('Status -->'+ res.getStatusCode());
            ld.Member_Matching_Deactivation_Response__c= res.getBody();
            system.debug('Response body -->'+ res.getBody());
            if(res.getStatusCode() == 200) isSuccess = true;
            update ld;
        }
        catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            MW_LogUtility.error('leadExtension', 'lead_guid__c', ld.lead_guid__c, 'makeCallout', e);
        }
          return isSuccess;
    }
}