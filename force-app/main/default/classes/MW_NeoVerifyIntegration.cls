global with sharing class MW_NeoVerifyIntegration
{

    public class neoVerify {
        public string report_id;
        public String url;
    }

    //@future(callout=true)
    public Static void postRegNeoVerify(Set<Id> applist){
        for(Id appid:applist) {
            postCreateRegisterUserRequest(appid);
        }
    }

    // Step 1 : Register the user
    public Static String postCreateRegisterUserRequest(Id appId){
        try {
            NeoVeifyRequestDetails nvd = new NeoVeifyRequestDetails();

            String requestbody = JSON.serialize(nvd.CreateRegisterUserRequest(appId));
            String resBody     = NeoVerifyCall('https://api.neoverify.com/v1/register_user', 'POST', requestbody);

            if(resBody!=null) {
                neoVerify neData  = (neoVerify)JSON.deserialize(resBody, neoVerify.class);

                if(neData.report_id!=null)
                    return postlinkAccountTransactions(appId, neData.report_id);
            }

        }
        catch (JSONException e) {
            throw new ints.IntegrationException('Something went wrong wile parsing response. ' + e.getMessage());
        }
        return null;
    }

    //2. Add all accounts and transactions from the linked accounts
    public Static String postlinkAccountTransactions(Id appId, String reportId)
    {
        try {
            NeoVeifyRequestDetails nvd = new NeoVeifyRequestDetails();

            String requestbody  = nvd.linkAccountTransactions(appId, reportId);
            String resBody      = NeoVerifyCall('https://api.neoverify.com/v1/add_accounts_and_transactions', 'POST', requestbody);
            System.debug('...resBody....' + resBody);
            if(resBody == '202') {
                List<genesis__Applications__c> applist = new List<genesis__Applications__c>([select Id,
                                                                                             Neoverify_Report_Id__c,
                                                                                             Neoverify_Application_Date__c
                                                                                             from
                                                                                             genesis__Applications__c where Id=: appId Limit 1]);
                if(applist.size()>0) {
                    applist[0].Neoverify_Report_Id__c = reportId;
                    update applist;
                }

                return 'Accepted';
            }
        }

        catch (JSONException e) {
            throw new ints.IntegrationException('Something went wrong wile parsing response. ' + e.getMessage());
        }

        return null;
    }

    // Check if the summary report is available. It might take a while to generate so we need to keep checking
    @InvocableMethod
    public static void processNeoVerifyReport(List<Id> appList) {
        for(ID appId :appList) {
            getReportStatus(appId);
        }
    }

    @future(callout=true)
    public Static void getReportStatus(Id appId){

        try {
            NeoVeifyRequestDetails nvd = new NeoVeifyRequestDetails();

            String requestbody = nvd.CheckApplicationStatus(appId);
            System.debug(' ** Request body ***' +requestbody);
            String resBody      = NeoVerifyCall('https://api.neoverify.com/v1/report_status', 'GET', requestbody);
            if(resBody !=null) {
                MW_NeoVerifyStatus neVerifyStatus  = (MW_NeoVerifyStatus)JSON.deserialize(resBody, MW_NeoVerifyStatus.class);
                if(neVerifyStatus.Report_status.status=='Report Ready') {
                    Neoverifyfuturemethod(appId);
                }
            }
        }
        catch (JSONException e) {
            throw new ints.IntegrationException('Something went wrong wile parsing response. ' + e.getMessage());
        }
    }
   
    webservice static String Neoverifyfuturemethod(Id appId)
    {
        System.debug('*******'+appId);
        
        List<mfiflexUtil.ParentChildWrapper> wrappers    = new List<mfiflexUtil.ParentChildWrapper>();
        List<genesis__Employment_Information__c> empList = new List<genesis__Employment_Information__c>();
        NeoVerifyResponse res                            = new NeoVerifyResponse();

        List<genesis__Applications__c> appList               = [SELECT Id,genesis__Account__c, genesis__Account__r.Payoff_UID__c,
                                                                Neoverify_Report_Id__c, genesis__Status__c,
                                                                Neoverify_Application_Date__c,
                                                                Neoverify_Report_Ready__c
                                                                FROM genesis__Applications__c WHERE genesis__Status__c!='REJECTED'
                                                                and id=:AppId LIMIT 1];


        if(appList.size()>0) {

            for (genesis__Applications__c a : appList) {

                res=getneoVerifyTransactions(a.Neoverify_Report_Id__c,a.genesis__Account__c,a.id);
                System.debug('>>>>>>>response'+ res);
                if(res!=null && res.employments!=null && res.employments.size()>0)
                {
                    for(NeoVerifyResponse.Employments ee : res.employments) {

                        genesis__Employment_Information__c emp = new genesis__Employment_Information__c();
                        emp.genesis__Application__c = a.id;

                        if(ee.avg_paycheck!=null) emp.Avg_Paycheck__c=Decimal.valueof(ee.avg_paycheck);
                        if(ee.next_day_date1!=null) emp.Next_Paydate_estimate__c=ee.next_day_date1;
                        if(ee.paychecks!=null) emp.No_of_Paychecks__c=ee.paychecks;
                        if(ee.pay_cycle!=null) emp.Pay_Frequency__c=ee.pay_cycle;
                        if(ee.first_pay_date1!=null && ee.last_pay_date1!=null)
                            emp.Payroll_Dates__c    =ee.first_pay_date1+' to '+ee.last_pay_date1;
                        if(ee.employer!=null) emp.Payroll_Source_Company__c=ee.employer;
                        if(ee.total_earnings!=null) emp.Total_Earnings__c=Decimal.valueof(ee.total_earnings);

                        empList.add(emp);
                    }
                }

                System.debug('res ' +empList);
                wrappers.add(new mfiflexUtil.ParentChildWrapper(res.neo, empList, 'Neo_Verify__c'));
            }

            appList[0].Neoverify_Report_Ready__c = true;
            update appList;

            mfiflexUtil.ParentChildWrapper.insertWrappers(wrappers);
        }
        return '';
    }

    public Static NeoVerifyResponse getneoVerifyTransactions(String reportId, String accountID, String appId){

        try {
            NeoVerifyResponse resp = new NeoVerifyResponse();
            NeoVerifyResponse NeoVerifyResponseData = new NeoVerifyResponse();

            String resBody      = NeoVerifyCall('https://api.neoverify.com/v1/summary_report/'+reportId, 'GET', null);

            if(resBody!=null) {
                resp = new NeoVerifyResponse().parse(resBody,accountID,appId);
                resp.responseBody = resBody;
                return resp;
            }
        }
        catch (JSONException e) {
            throw new ints.IntegrationException('Something went wrong wile parsing response. ' + e.getMessage());
        }
        return null;
    }

    public Static string NeoVerifyCall(String Endpoint, String ReqMethod, String requestbody){
        String neoverify_apikey = MW_Settings__c.getInstance().Neoverify_APIkey__c;
        try {
            Http http                  = new Http();
            HttpRequest Req            = new HttpRequest();
            Req.setMethod(ReqMethod);
            Req.setHeader('Content-Type','application/json');
            Req.setHeader('Accept','application/json');
            Req.setHeader('Access-Token',neoverify_apikey);
            if(requestbody!=null)
                Req.setBody(requestbody);
            Req.setEndpoint(Endpoint);
            HttpResponse res = http.send(Req);

            if(res.getStatusCode() == 200) {
                return res.getBody();
            }
            
            if(res.getStatusCode() == 201) {
                return res.getBody();
            }

            if(res.getStatusCode() == 202) {
                return '202';
            }
        }
        catch(Exception ex){
            system.debug('exception::'+ex);
        }
        return null;
    }


}