global class MW_WebhookHandler {
    public static String SendDetailstoUI(String Jsonres, String LeadId) {
        List<genesis__Applications__c> applist = [
            SELECT id, Lead_ID__c, LEAD_ID_ExtKey__c, Member_ID__c
            FROM genesis__Applications__c
            WHERE Lead_ID__c = :LeadId
            LIMIT 1
        ];

        String lead_id = null;
        String member_id = null;

        if (applist != null && applist.size() > 0) {
            lead_id = applist[0].LEAD_ID_ExtKey__c;
            member_id = applist[0].Member_ID__c;
        }

        MW_DocuResponse dr = MW_DocuResponse.Parse(Jsonres);
        String gen = null;
        if (dr.envelopeId != null) {
            List<DocuSignEnv> listDocSign = new List<DocuSignEnv>();
            listDocSign.add(new DocuSignEnv(dr.envelopeId, LeadId, lead_ID, member_id, dr.status.toLowerCase()));
            sync_DocuSignEnv synDocuSign = new sync_DocuSignEnv('docusign', listDocSign);
            gen = JSON.serialize(synDocuSign, true);
            CallWebHookIntegration(gen, String.valueOf(applist[0].id), LeadId);
            return gen;
        }

        return null;
    }

    public class DocuSignEnv {
        String lead_guid;
        String member_id;
        String lead_id;
        String envelope_id;
        String status;
        public DocuSignEnv(String EnvelopeId, String lead_guid, String lead_ID, String member_id, String status) {
            this.lead_guid = lead_guid;
            this.lead_id = lead_ID;
            this.member_id = member_id;
            this.envelope_id = EnvelopeId;
            this.status = status;
        }
    }

    class sync_DocuSignEnv {
        String type;
        DocuSignEnv[] data;
        public sync_DocuSignEnv(String type, DocuSignEnv[] appInfo) {
            this.type = type;
            this.data = appInfo;
        }
    }

    class cls_docusign {
        public String status;
        public cls_documents[] documents;
    }

    class cls_documents {
        public String id;
        public String type;
        public String folder_id;
    }

    public static String generateJSONContent(String RequestType, String EnvelopeID, String LeadId, String status) {
        List<genesis__Applications__c> applist = [
            SELECT id, Lead_ID__c, LEAD_ID_ExtKey__c, Member_ID__c
            FROM genesis__Applications__c
            WHERE id = :LeadId
            LIMIT 1
        ];

        String lead_id = null;
        String member_id = null;
        String lead_guid = null;

        if (applist != null && applist.size() > 0) {
            lead_id = applist[0].LEAD_ID_ExtKey__c;
            member_id = applist[0].Member_ID__c;
            lead_guid = applist[0].Lead_ID__c;
        }
        List<DocuSignEnv> listDocSign = new List<DocuSignEnv>();
        listDocSign.add(new DocuSignEnv(EnvelopeID, lead_guid, lead_ID, member_id, status));
        sync_DocuSignEnv synDocuSign = new sync_DocuSignEnv(RequestType, listDocSign);
        String gen = JSON.serialize(synDocuSign, true);
        if (applist != null && applist.size() > 0) {
            CallWebHookIntegration(gen, String.valueOf(applist[0].id), LeadId);
        }
        return gen;
    }
    /* Send soft pull response request to LEADS FE*/
    public class softPullReq {
        softPullLeads[] data;
        public String type;
        public softPullReq(softPullLeads[] leads, String type) {
            this.data = leads;
            this.type = type;
        }
    }

    public class softPullLeads {
        String lead_guid;
        String member_id;
        String lead_id;
    }

    public static Boolean generateSoftPullJson(String appId) {
        List<genesis__Applications__c> applist = [
            SELECT id, Lead_ID__c, LEAD_ID_ExtKey__c, Member_ID__c
            FROM genesis__Applications__c
            WHERE id = :appId
            LIMIT 1
        ];
        List<softPullLeads> sfLeads = new List<softPullLeads>();
        softPullLeads sfobj = new softPullLeads();
        if (applist.size() > 0) {
            sfobj.lead_guid = applist[0].Lead_ID__c;
            sfobj.lead_id = applist[0].LEAD_ID_ExtKey__c;
            sfobj.member_id = applist[0].Member_ID__c;

            sfLeads.add(sfobj);
            softPullReq softPullReq = new softPullReq(sfLeads, 'soft_pull');
            MW_WebhookHandler.CallWebHookIntegration(JSON.serialize(softPullReq, true), appId, applist[0].Lead_ID__c);
        }
        return true;
    }

    webService static String CallWebHookIntegration(String reqbody, String appId, String leadId) {
        try {
            String leadsEndPoint = MW_Settings__c.getInstance().LEADS_FE_EndpointURL__c;

            if (String.isBlank(leadsEndPoint)) {
                return 'Success';
            }
            String certName = MW_Settings__c.getInstance().CertificateNameForLEADS__c;

            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Cache-Control', 'no-cache');
            if (certName != null)
                req.setClientCertificateName(certName);
            System.debug('WebHook request :: >>' + reqbody);

            String maskedReqbody = MW_SynchronizeHandler.maskingFields(reqbody);
            MW_LogUtility.info('MW_WebhookHandler', appId, leadId, 'CallWebHookIntegration', maskedReqbody);

            req.setEndpoint(leadsEndPoint);
            req.setbody(reqbody);
            Http http = new Http();
            req.setTimeout(120000);
            System.debug('Request:: >>' + req);
            HTTPResponse res = http.send(req);
            System.debug('Response :: >> ' + res);
            String response;

            MW_LogUtility.info('MW_WebhookHandler', appId, leadId, 'CallWebHookIntegration', res.getBody(), res);

            if (res.getStatusCode() == 200) {
                response = res.getBody();
            }
        } catch (Exception e) {
            MW_LogUtility.error('MW_WebhookHandler', appId, leadId, 'CallWebHookIntegration', e);
            System.debug(
                'Error: ' + e.getLineNumber() + ' Desc. ' + e.getMessage() + ' Stack: ' + e.getStackTraceString()
            );
            return 'Fail';
        }
        return 'Success';
    }

    @future(callout=true)
    webService static void CallWebHookIntegration1(String reqbody, String appId, String leadId) {
        CallWebHookIntegration(reqbody, appId, leadId);
    }
}