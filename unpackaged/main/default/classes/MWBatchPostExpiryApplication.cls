/*  If you want to execute below batch class for a specific date(format YYYY-MM-DD) ,run the following script.
           Date specificDate=date.valueOf('2015-03-08');
           MWBatchPostExpiryApplication b = new MWBatchPostExpiryApplication(specificDate);
           Database.executeBatch(b,1);
          */
global class MWBatchPostExpiryApplication implements Database.batchable<sObject>, Schedulable, Database.AllowsCallouts {

    String query;
    Set<String> applicationStatus = new Set<String>{'Expired','Declined','Decline_Manual_Review','Expired-Withdrawn'};
    Set<String> applicationStatusDec = new Set<String>{'Declined'};
    //LOP-270

    
    Date currentSystemDate;
	String CSD;    
    Datetime currentSystemDateTime;
    String previousDate;
    @TestVisible static SObjectField lastModifiedDateField = genesis__Applications__c.LastModifiedDate;
    @TestVisible static sync_application syncApp;
    global MWBatchPostExpiryApplication(){
        currentSystemDate = (new loan.GlobalLoanUtilFacade().getCurrentSystemDate());
    	CSD = String.valueof(currentSystemDate); 
        currentSystemDateTime = DateTime.newInstance(currentSystemDate.year(), currentSystemDate.month(), currentSystemDate.day());
    	previousDate = currentSystemDateTime.addDays(-1).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
    }
    global MWBatchPostExpiryApplication(Date specificDate){
        if(specificDate != null){
            CSD = String.valueof(specificDate);
            query = 'SELECT '+
                    'Id, Expiry_Date__c, genesis__Status__c, CreatedById,' +
                    'owner.Name, LEAD_ID_ExtKey__c, Member_ID__c, Lead_ID__c, '+
                    'DocuSign_EnvelopeId__c, Expiration_Tag__c, '+ lastModifiedDateField +
                    '(SELECT id,name, Loan_amount_counteroffer__c ' +
                    'FROM '+
                    'Credit_Policy__r '+
                    'WHERE '+
                    'Loan_amount_counteroffer__c> 0 LIMIT 1) '+
                    'FROM genesis__Applications__c '+
                    'WHERE '+
                    '(Expiry_Date__c ='+ CSD + ' AND genesis__Status__c in: applicationStatus) ' +
                    'OR '+
                    '('+ lastModifiedDateField + '=' + previousDate + ' AND genesis__Status__c IN: applicationStatusDec ) ' ; 
                            
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(query == null){
          query = 'SELECT '+
                    'Id, Expiry_Date__c, genesis__Status__c, CreatedById,' +
                    'owner.Name, LEAD_ID_ExtKey__c, Member_ID__c, Lead_ID__c, '+
                    'DocuSign_EnvelopeId__c, Expiration_Tag__c, '+ lastModifiedDateField + ',' +
                    '(SELECT id,name, Loan_amount_counteroffer__c ' +
                    'FROM '+
                    'Credit_Policy__r '+
                    'WHERE '+
                    'Loan_amount_counteroffer__c> 0 LIMIT 1) '+
                    'FROM genesis__Applications__c '+
                    'WHERE '+
                    '(Expiry_Date__c <='+ CSD + ' AND genesis__Status__c in: applicationStatus AND is_ApplicationExpiryPosted__c=FALSE) ' +
                    'OR '+
                    '('+ lastModifiedDateField + '=' + previousDate + ' AND genesis__Status__c IN: applicationStatusDec AND is_ApplicationExpiryPosted__c=FALSE) ' ; 
                     

       //LOP-270 created a custom flag as is_ApplicationExpiryPosted__c whose default value is false 
                                          
                          
        }
        System.debug(query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        //for logging only
        String appIdList = '';
        String leadIdList = '';

        List<genesis__Applications__c > listOfApp = (List<genesis__Applications__c >)scope;

        list<ApplicationInformation> listAppInfo  = new list<ApplicationInformation>();

        for(genesis__Applications__c app : listOfApp) {
            appIdList = appIdList + String.valueOf(app.Id) + ' ';
            leadIdList = leadIdList + app.Lead_ID__c + ' ';
            applicationinformation appinfo= new ApplicationInformation();
            appinfo.expiry_date= app.Expiry_Date__c;

            if(app.genesis__Status__c=='Expired'|| app.genesis__Status__c=='Expired-Withdrawn') {
                appinfo.lead_guid = app.Lead_ID__c;
                appinfo.lead_id  = app.LEAD_ID_ExtKey__c;
                appinfo.member_id = app.Member_ID__c;
                appinfo.is_expired = true;
                listAppInfo.add(appinfo);
                
            }
            

            if((app.genesis__Status__c=='Declined' || app.genesis__Status__c=='Decline_Manual_Review') && app.owner.Name=='Declined' && app.Expiry_Date__c <= currentSystemDate) {
                appinfo.lead_guid = app.Lead_ID__c;
                appinfo.lead_id  = app.LEAD_ID_ExtKey__c;
                appinfo.member_id = app.Member_ID__c;  
                appinfo.is_expired = true;
                listAppInfo.add(appinfo);
                
            }
            else if(app.genesis__Status__c=='Declined' && app.owner.Name=='Declined') {
                appinfo.lead_guid = app.Lead_ID__c;
                appinfo.lead_id = app.LEAD_ID_ExtKey__c;
                appinfo.member_id = app.Member_ID__c;
                appinfo.is_expired = false;
                listAppInfo.add(appinfo);
                
            }
            // LOP-270 Set the custom flag as true, so previously processed expired Application doesn't get processed again
            app.is_ApplicationExpiryPosted__c = true;
        }
        
        system.debug('listappinfo---->>>'+listAppInfo);
        syncApp = new sync_application('sync_application', listAppInfo);
        String str = JSON.serialize(syncApp, true);
        // LOP-270 , checking callout is a success
        String isSuccess = MW_WebhookHandler.CallWebHookIntegration(str, appIdList, leadIdList);
        if (successful(isSuccess)){
        	update listOfApp;
        }
    
    }

    global void finish(Database.BatchableContext BC) {

    }

    global void execute(SchedulableContext sc) {
        MWBatchPostExpiryApplication b = new MWBatchPostExpiryApplication();
        Database.executeBatch(b,1);   
    }

    class ApplicationInformation
    {
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
        public sync_application(String type, ApplicationInformation[] appInfo){
            this.type = type;
            this.data = appInfo;
        }
    }
	public boolean successful(String isSuccess) {
		return (isSuccess.equalsIgnoreCase('Success'));
	}

	
}