/* ****************Modification History*****************************************************************
 * Modified by      Date         JIRA number  Description
 * Mohan Kiran   2021/08/11       LSP-327     Used the endpoint CL_WebhookControlHandler to get Payoff parameters and pass the payoff quote back and save it in salesforce
 
 *******************Modification History*****************************************************************/

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
    
    public static List<String> agentVerify(ID appId){

        List<identity_verification__C> identityVerifications = [select id, application__r.Owner.Name, 
        application__R.lead_id__C, application__r.genesis__Status__c, application__r.Stacker_Reviewed__c, application__r.SSNMatch__c,
        Credit_Policy_Verification_Flag__c, Bank_Verification_Flag__c, Deal_room_Verification_Flag__c, Identity_Verification__c, Income_Verification_Flag__c
        from identity_verification__C where Application__c =:appId order by lastmodifieddate desc limit 1];
        
        //do we need credit policy check because if there are now rows it ignores the condition

        List<String> results = new List<String>();
        
        System.debug(identityVerifications);
        if (identityVerifications.size()>0){
            
            for (Identity_verification__C v : identityVerifications){
                if(v.application__r.Owner.Name !='Final_Verification') results.add('Not assigned : Application owner is not Final_Verification');
                
                if(v.Credit_Policy_Verification_Flag__c !='PASS') results.add('Not assigned : Credit_Policy_Verification_Flag__c is not PASS');
                
                if(v.Bank_Verification_Flag__c != 'PASS') results.add('Not assigned : Bank_Verification_Flag__c is not PASS');
                if(v.Deal_room_Verification_Flag__c != 'PASS') results.add('Not assigned : Deal_room_Verification_Flag__c is not PASS');
                if(v.Identity_Verification__c !='PASS') results.add('Not assigned : Identity_Verification__c  is not PASS');
                if(v.Income_Verification_Flag__c != 'PASS') results.add('Not assigned : Income_Verification_Flag__c  is not PASS');

                if(v.application__r.genesis__Status__c == 'agent_verified') results.add('Not assigned : Application status is agent_verified');
                if(v.application__r.Stacker_Reviewed__c != true) results.add('Not assigned : Application Stacker_Reviewed__c is false');
                if(v.application__r.SSNMatch__c != true) results.add('Not assigned : Application SSNMatch__c is false');

                
            }//end for loop
        
        }
        else results.add('Not assigned : No identity verification records/App Id found');

        if(results.size()==0) {//if no fail results call assign to agent verified
         
            results.add(PayOffUtilities.AssignToAgentVerifiedQueue(appID));
        }

        return results;
     

    }

    public static List<String> stackerCheck(ID appId){

        List<identity_verification__C> identityVerifications = [select id, application__r.Owner.Name, Credit_Policy_Verification_Flag__c, Bank_Verification_Flag__c, Deal_room_Verification_Flag__c, Identity_Verification__c, Income_Verification_Flag__c
        from identity_verification__C where Application__c =:appId order by lastmodifieddate desc limit 1];
        
        List<String> results = new List<String>();
        
        System.debug(identityVerifications);
        if (identityVerifications.size()>0){
            
            for (Identity_verification__C v : identityVerifications){
                if(v.application__r.Owner.Name !='Final_Verification') results.add('Application owner is not Final_Verification');
                
                if(v.Credit_Policy_Verification_Flag__c !='PASS') results.add('Credit_Policy_Verification_Flag__c is not PASS');
                
                if(v.Bank_Verification_Flag__c != 'PASS') results.add('Bank_Verification_Flag__c is not PASS');
                if(v.Deal_room_Verification_Flag__c != 'PASS') results.add('Deal_room_Verification_Flag__c is not PASS');
                if(v.Identity_Verification__c !='PASS') results.add(' Identity_Verification__c  is not PASS');
                if(v.Income_Verification_Flag__c != 'PASS') results.add(' Income_Verification_Flag__c  is not PASS');
                
            }//end for loop
        
        }
        else results.add('No identity verification records/App Id found');

        if(results.size()==0) {//if no fail results call stackercheck

            results.add(PayOffUtilities.createAppTagforSoftpull(appID));
        }

        return results;
        
    }

    global static String ServiceGetHelper(RestRequest req, RestResponse res){
        try
        {
            Map <String, String> params      = req.params;
            List<String> results = new List<String>();

            if(params.size()>0)
            {
               //RequestType == 'StackerCheck' //ztf-235
               if(params.get('RequestType') == 'StackerCheck'){
                    
                    Id appId = (ID)(params.get('ApplicationId'));

                    results = stackerCheck(appID);

               }
               
                //RequestType == 'AgentVerified' //ztf-236
                if(params.get('RequestType') ==  'AgentVerified'){

                    Id appId = (ID)(params.get('ApplicationId'));

                    results = agentVerify(appId);
                }

                if(results.size()>0){
                res.statusCode = 200;
                return String.join(results, '\n');
               }
               

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
            system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>Entering exception'+e);
            ApexPages.addMessages(e);
            Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'salesforceapi@happymoney.com'};
            mail.setToAddresses(toAddresses);
            mail.setReplyTo('salesforceapi@happymoney.com');
            mail.setSenderDisplayName('MW: Apex error message');
            mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
            mail.setPlainTextBody('TIL Document Exception' +e.getMessage());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            res.statusCode = 500;
            //data dog exception handling
            MW_LogUtility.ExceptionDO expRex = new MW_LogUtility.ExceptionDO(e);
            MW_DataDogCallOut.futureSend(JSON.serialize(expRex), new List<String>());

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
                List<genesis__Applications__c> app     = new List<genesis__Applications__c>([select Id, genesis__Account__c, genesis__Status__c, owner.name from genesis__Applications__c where Lead_ID__c=: Lead_Id limit 1]);

                if(app.size() > 0)
                {
                    /*START - Mohan Kiran Added the code block to generate payoff quote - LSP-327*/
                    // Pass the parameters to the MW_PayoffQuote if the request type is payoff_quote. 
                    
                    if(params.get('RequestType')=='payoff_quote') {
                    String loanId = params.get('LoanId');
                    String payOffDate = params.get('PayOffDate');
                        
                    return MW_PayOffQuote.Save(loanId, payOffDate);
                }
                    /*END- Code change LSP-327*/
                    
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
            String[] toAddresses = new String[] {'salesforceapi@happymoney.com'};
            mail.setToAddresses(toAddresses);
            mail.setReplyTo('salesforceapi@happymoney.com');
            mail.setSenderDisplayName('MW: Apex error message');
            mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
            mail.setPlainTextBody(e.getStackTraceString());
            if(!Test.IsRunningTest()){
                //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            res.statusCode = 500;
            return e.getStackTraceString();
        }
        res.statusCode = 200;
        return 'Success';
    }

}