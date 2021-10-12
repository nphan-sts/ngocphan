/*
Purpose: Just for running one time, this batch has been created to Send isExpired flag for existing Manual Decline for ticket CRM-535.
This class is replica of 'MWBatchPostExpiryApplication' and modified for this ticket purpose.
How to call this batch?
For CRM-535, we would pass appStatus = 'Decline_Manual_Review' and expiryDate = current date(yyyy-mm-dd). But same can be use again in future by passing different status and expiry date.
Example:
Set<String> appStatus = new Set<String>{'Decline_Manual_Review'}; //{'Expired','Declined','Decline_Manual_Review'};
String expiryDate = '2020-05-21';
MWBatchPostExpiryApplication_Manual b = new MWBatchPostExpiryApplication_Manual(expiryDate, appStatus);
Database.executeBatch(b,1);
*/

global class MWBatchPostExpiryApplication_Manual implements Database.batchable<sObject>, Database.AllowsCallouts {
    //Date currentSystemDate = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
    global final String query;
    global final String expiryDate;
    global final Set<String> appStatus;

    global MWBatchPostExpiryApplication_Manual(String pExpiryDate, Set<String> pAppStatus) {
        //String CSD = String.valueof(new loan.GlobalLoanUtilFacade().getCurrentSystemDate());

        //SELECT Id, Expiry_Date__c, genesis__Status__c,CreatedById, owner.Name, LEAD_ID_ExtKey__c, Member_ID__c, Lead_ID__c, DocuSign_EnvelopeId__c, Expiration_Tag__c FROM genesis__Applications__c WHERE Expiry_Date__c <= '2020-05-21' AND genesis__Status__c IN ('Decline_Manual_Review')
        expiryDate = pExpiryDate;
        appStatus = pAppStatus;
        query = 'SELECT Id, Expiry_Date__c, genesis__Status__c, CreatedById, owner.Name, LEAD_ID_ExtKey__c, Member_ID__c, Lead_ID__c, DocuSign_EnvelopeId__c, Expiration_Tag__c FROM genesis__Applications__c WHERE Expiry_Date__c <=' + expiryDate + ' AND genesis__Status__c IN : appStatus';

        System.debug('query=' + query);
    }

    @TestVisible static sync_application syncApp;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
		//for logging only
		String appIdList = '';
		String leadIdList = '';
        try {
			List<genesis__Applications__c > listOfApp = (List<genesis__Applications__c >) scope;

			list<ApplicationInformation> listAppInfo = new list<ApplicationInformation>();

			for (genesis__Applications__c app : listOfApp) {
				appIdList = appIdList + String.valueOf(app.Id) + ' ';
				leadIdList = leadIdList + app.Lead_ID__c + ' ';
				applicationinformation appinfo = new ApplicationInformation();

				appinfo.expiry_date = app.Expiry_Date__c;

				if (app.genesis__Status__c == 'Expired') {
					appinfo.lead_guid = app.Lead_ID__c;
					appinfo.lead_id = app.LEAD_ID_ExtKey__c;
					appinfo.member_id = app.Member_ID__c;

					appinfo.is_expired = true;
					listAppInfo.add(appinfo);
				}
                if (app.genesis__Status__c == 'Expired-Withdrawn') {
					appinfo.lead_guid = app.Lead_ID__c;
					appinfo.lead_id = app.LEAD_ID_ExtKey__c;
					appinfo.member_id = app.Member_ID__c;

					appinfo.is_expired = true;
					listAppInfo.add(appinfo);
				}  

				//if((app.genesis__Status__c=='Declined' || app.genesis__Status__c=='Decline_Manual_Review') && app.owner.Name=='Declined' && app.Expiry_Date__c == currentSystemDate) {
				if ((app.genesis__Status__c == 'Declined' || app.genesis__Status__c == 'Decline_Manual_Review')) {
					appinfo.lead_guid = app.Lead_ID__c;
					appinfo.lead_id = app.LEAD_ID_ExtKey__c;
					appinfo.member_id = app.Member_ID__c;

					appinfo.is_expired = true;
					listAppInfo.add(appinfo);
				} /*else if (app.genesis__Status__c == 'Declined' && app.owner.Name == 'Declined') {
                    appinfo.lead_guid = app.Lead_ID__c;
                    appinfo.lead_id = app.LEAD_ID_ExtKey__c;
                    appinfo.member_id = app.Member_ID__c;
                    appinfo.is_expired = false;
                    listAppInfo.add(appinfo);
                }*/
			}

			syncApp = new sync_application('sync_application', listAppInfo);
			String str = JSON.serialize(syncApp, true);
			System.debug('str=' + str);
			If (!Test.IsRunningTest()) {
				MW_WebhookHandler.CallWebHookIntegration(str, appIdList, leadIdList);
			}
			//log for reporting
			loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'MWBatchPostExpiryApplication_Manual';
            bplog.loan__Message__c = 'JSON = ' + str;
            bplog.loan__Type__c = 'Info';
            bplog.loan__Time__c = DateTime.now();
            bplog.App_Ids__c = 'Lead GUID = ' + leadIdList;
            bplog.loan__Log_Level__c = 'DEBUG';
			insert bplog;

        } catch (Exception ex) {
			//log for reporting
			loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'MWBatchPostExpiryApplication_Manual';
            bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage() + ' Stack: ' + ex.getStackTraceString();
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            bplog.App_Ids__c = 'Lead GUID = ' + leadIdList;
            bplog.loan__Log_Level__c = 'ERROR';
            insert bplog;
        }

    }

    global void finish(Database.BatchableContext BC) {

    }

    /*
    global void execute(SchedulableContext sc) {
        MWBatchPostExpiryApplication_Manual b = new MWBatchPostExpiryApplication_Manual();
        Database.executeBatch(b,1);
    }
    */

    class ApplicationInformation {
        public string lead_guid;
        public string lead_id;
        public string member_id;
        public date expiration_date;
        public date expiry_date;
        public boolean is_expired;
    }

    class sync_application {
        String type;
        @TestVisible ApplicationInformation[] data;
        public sync_application(String type, ApplicationInformation[] appInfo) {
            this.type = type;
            this.data = appInfo;
        }
    }

}