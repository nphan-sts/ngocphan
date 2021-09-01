@RestResource(urlMapping='/CL_MiddleWare/*')
global with sharing class MW_WebhookControlHandler {

    @HttpPost
    global static String handleRequest(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        return ServiceHelper(req, res);
    }

    @HttpGet
    global static String handleGetRequest(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        return ServiceGetHelper(req, res);
    }

    global static String ServiceGetHelper(RestRequest req, RestResponse res){
        try
        {
            Map <String, String> params      = req.params;

            if(params.size()>0)
            {

                if(params.get('RequestType')=='ECA') {
                    List<Document> ecaAttachment = new List<Document>([select Id, Body, Name from Document where name ='eca' order by CreatedDate desc limit 1]);
                    if(ecaAttachment.size()>0)
                        return EncodingUtil.base64Encode(ecaAttachment[0].Body);
                }

                if(params.get('Lead_ID')!=null)
                {
                    String Lead_Id                         = params.get('Lead_ID');
                    List<genesis__Applications__c> app     = new List<genesis__Applications__c>([select Id, genesis__Account__c, genesis__Status__c from genesis__Applications__c where Lead_ID__c=: Lead_Id limit 1]);

                    if(params.get('RequestType')=='Til') {
                        List<Attachment> tilAttachment = new List<Attachment>([select Id, Body, NAme from Attachment where parentid=: app[0].Id and name like 'TIL Document%'  order by CreatedDate desc limit 1]);
                        if(tilAttachment.size()>0)
                            return EncodingUtil.base64Encode(tilAttachment[0].Body);
                    }

                    if(params.get('RequestType')=='AAN') {
                        List<Attachment> aanAttachment = new List<Attachment>([select Id,Body, Name from Attachment where parentid=: app[0].Id and Name like 'Adverse Action Document%' order by CreatedDate desc limit 1]);
                        if(aanAttachment.size()>0 && (app[0].genesis__Status__c=='declined' || app[0].genesis__Status__c=='Decline_Manual_Review'))
                            return EncodingUtil.base64Encode(aanAttachment[0].Body);
                    }

                    if(params.get('RequestType')=='CSN') {
                        List<Attachment> csnAttachment = new List<Attachment>([select Id, Body, Name from Attachment where parentid=: app[0].Id and Name like 'Credit Score notice%' order by CreatedDate desc limit 1]);
                        if(csnAttachment.size()>0)
                            return EncodingUtil.base64Encode(csnAttachment[0].Body);
                    }
                }

                else{
                    res.statusCode = 500;
                    return 'In Correct LeadID';
                }
            }
        }
        catch (Exception e)
        {
            ApexPages.addMessages(e);
            Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'cpalapala@happymoney.com'};
            mail.setToAddresses(toAddresses);
            mail.setReplyTo('stiwari@happymoney.com');
            mail.setSenderDisplayName('MW: Apex error message');
            mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
            mail.setPlainTextBody('TIL Document Exception' +e.getMessage());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            res.statusCode = 500;
            return e.getStackTraceString();
        }
        res.statusCode = 200;
        return 'Success';
    }


    global static String ServiceHelper(RestRequest req, RestResponse res){
        try
        {
            Map <String, String> params      = req.params;
            String requestBody = req.requestBody.toString();


            if(params.size()>0 && params.get('Lead_ID')!=null)
            {
                String Lead_Id                         = params.get('Lead_ID');
                List<genesis__Applications__c> app     = new List<genesis__Applications__c>([select Id, genesis__Account__c, Lead_ID__c, genesis__Status__c, owner.name from genesis__Applications__c where Lead_ID__c=: Lead_Id limit 1]);

                Map<String, Object> log = new Map<String, Object>();
                log.put('RequestType', params.get('RequestType'));
                log.put('apps', MW_LogUtility.toLoggableApps(app));
                MW_LogUtility.infoMessage('MW_WebhookControlHandler', 'Invocation Entry', log);

                if(app.size() > 0)
                {
                    /* credit_optic */
                    if(params.get('RequestType')=='credit_optic'){
                        MW_CreditOptic.CreditOptic co =  MW_CreditOptic.ParseCreditOptic(requestBody);
                        MW_CreditOptic.UpdateApplication(new genesis__Applications__c(id=app[0].Id), co);
                    }
                    /*
                       KBA_06
                     */
                    if(params.get('RequestType')=='KBA_06') {
                        String json =  MW_KBAResponse.KBAResponse(requestBody,'KBA_06');
                        if(json!=null) {
                            KBAResponseParser.parse(json, String.valueOf(app[0].genesis__Account__c), String.valueOf(app[0].Id), 'KBA_06', req.requestBody.toString(), Lead_Id);
                        }
                    }
                    /*
                       KBA_18
                     */
                    if(params.get('RequestType')=='KBA_18') {
                        String json                  =  MW_KBAResponse.KBAResponse(requestBody,'KBA_18');
                        if(json!=null) {
                            KBAResponseParser.parse(json, String.valueOf(app[0].genesis__Account__c), String.valueOf(app[0].Id), 'KBA_18', null, null);
                        }
                    }
                    /*
                       Sift Data SCORE
                     */
                    if(params.get('RequestType')=='sift_score') {
                        SiftIntegrationJSONBean resData  = (SiftIntegrationJSONBean)JSON.deserialize(requestBody, SiftIntegrationJSONBean.class);
                        if(resData.score_response.score!=null) {
                            genesis__Applications__c appRec = new genesis__Applications__c(id=app[0].Id);
                            appRec.Sift_Status__c           = (resData.score_response.score) * 100;
                            //appRec.Sift_Status__c           = (resData.score_response.status);
                            System.debug(' ** Updated Information ** '+ resData.score);
                            update appRec;
                        }
                    }
                    /*
                       ID Analytics
                     */
                    if(params.get('RequestType')=='Id_analytics') {
                        IDAnalyticsIntegrationJSONBean IdDataanly = (IDAnalyticsIntegrationJSONBean)JSON.deserialize(requestBody, IDAnalyticsIntegrationJSONBean.class);
                        if(IdDataanly!=null) {
                            WSKBAUpdateInfo.WSKBARequestParcer wskb   = new WSKBAUpdateInfo.WSKBARequestParcer();
                            if(IdDataanly.Result.id_score!=null)
                                wskb.IDScore                              = Integer.valueOf(IdDataanly.Result.id_score);
                            if(IdDataanly.Result.snapd!=null)
                                wskb.ConsistencySNAPD                     = Integer.valueOf(IdDataanly.Result.snapd);
                            if(IdDataanly.Result.snapd!=null)
                                wskb.PublicRecords                        = Integer.valueOf(IdDataanly.Result.snapd);
                            WSKBAUpdateInfo.updateKBAInfo(app[0].Id, JSON.serialize(wskb, true));
                        }
                    }
                    /*
                       Adverse Action
                     */
                    if(params.get('RequestType')=='credit_policy_decline') {
                        //https://sfapi-dev.payoff.com/cp/api/v1/credit_policy/decisions?payoff_uid=4fff568a-f330-4e8d-be33-82312ccf2ac7
                        //AdverseScoreResponse responseC = new AdverseScoreResponse().parse(requestBody,String.valueOf(app[0].genesis__Account__c),String.valueOf(app[0].Id));
                        //System.Debug('....Adverse Score Response:...' + responseC);
                        //return String.valueOf(responseC);
                    }
                    /*
                       Soft Pull
                     */
                    if(params.get('RequestType')=='soft_pull') {
                        System.debug('******SOFTPULLRESPONSE'+requestBody);
                        String LeadID = params.get('Lead_ID');
                        CreditPolicyResponse responseCP = new CreditPolicyResponse().parse(requestBody,String.valueOf(app[0].genesis__Account__c),String.valueOf(app[0].Id),LeadID);

                    }
                    /*
                       Credit policy
                     */
                    if(params.get('RequestType')=='credit_policy') {
                        System.debug('******CPRESPONSE'+requestBody);
                        String LeadID = params.get('Lead_ID');
                        CreditPolicyResponse responseCP = new CreditPolicyResponse().parse(requestBody,String.valueOf(app[0].genesis__Account__c),String.valueOf(app[0].Id),LeadID);
                    }
                    /*
                       Hard Credit pull Infromation.
                     */
                    if(params.get('RequestType')=='hard_pull') {
                        HardCreditPullResponse hardCreditpull = new HardCreditPullResponse();
                        HardCreditPullResponse.All_attributes allatri = new HardCreditPullResponse.All_attributes();
                        hardCreditpull.all_attributes  = allatri;
                        HardCreditPullResponse.Bureau_report bureaReport = new HardCreditPullResponse.Bureau_report();
                        bureaReport.raw_response = requestBody;
                        hardCreditpull.all_attributes.bureau_report =bureaReport;
                        HardCreditPullResponse.parse(JSON.serialize(hardCreditpull),app[0].genesis__Account__c, app[0].Id);
                    }
                    /*
                       Cut Copy count
                     */
                    if(params.get('RequestType')=='paste_count') {
                        MW_CopypasteJsonBean.parse(requestBody, String.valueOf(app[0].genesis__Account__c), String.valueOf(app[0].Id));
                    }
                    //OLN Stacker Response CLS-1065
                    if(params.get('RequestType') == 'oln_stacker') {
                        MW_OLNStacker.parseOLNStacker(app, requestBody);
                    }
                    //DCP Transactions
                    if(params.get('RequestType') == 'dcp_transactions') {
                        MW_DCPTransactions.storeDCPTransactions(app, requestBody);
                    }

                }else{
                    res.statusCode = 500;
                    return 'No Application exist with this lead id' + Lead_Id;
                }
            }
        }
        catch (Exception e)
        {
            //ApexPages.addMessages(e);
            Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'cpalapala@happymoney.com'};
            mail.setToAddresses(toAddresses);
            mail.setReplyTo('stiwari@happymoney.com');
            mail.setSenderDisplayName('MW: Apex error message');
            mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
            mail.setPlainTextBody(e.getMessage());
            if(!Test.IsRunningTest()){
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            res.statusCode = 500;
            return e.getStackTraceString();
        }
        res.statusCode = 200;
        return 'Success';
    }

}