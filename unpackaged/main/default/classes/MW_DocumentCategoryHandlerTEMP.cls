/* Run the below script from dev console. Make sure to create a Batch Process Log record with App Ids in it - comma separated for below query to work
        loan__Batch_Process_Log__c logRec = [select Id,App_Ids__c from loan__Batch_Process_Log__c where Name = 'MW_PostDealRoomToFE' LIMIT 1 ];
        List<string> appIds;
        if(logRec.App_Ids__c != null){
            appIds = logRec.App_Ids__c.split(',');
            MW_DocumentCategoryHandlerTEMP mwtp = new MW_DocumentCategoryHandlerTEMP(appIds);
            Database.executeBatch(mwtp,10);
        }
*/

global class MW_DocumentCategoryHandlerTEMP implements Database.AllowsCallouts, Database.batchable<sObject>{
    List<string> appIds;
    global MW_DocumentCategoryHandlerTEMP(List<string> appIdsList){
        appIds = appIdsList;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        string qryStr = 'Select Id from genesis__Applications__c where Id IN : appIds';
        return Database.getQueryLocator(qryStr);
    }
    global void execute(Database.BatchableContext BC, List<genesis__Applications__c> scope) {
        List<String> appIds = new List<String>();
        for (genesis__Applications__c app : scope) {
            appIds.add(app.Id);
        }
        processDataCate(appIds);
    }
    global void finish(Database.BatchableContext BC) {
    }
    
    public Static List<genesis__Application_Document_Category__c> applicationDocumentCategory(String appId)
    {
        List<String> docCategoriesNamestoskip = MW_Settings__c.getInstance().docCategoriesNamestoskip__c.split(',');
        List<genesis__Application_Document_Category__c> sobjList = new List<genesis__Application_Document_Category__c>();
        List<genesis__Application_Document_Category__c> sobjList1 = new List<genesis__Application_Document_Category__c>();
       
        /* -- CLS-892 - Doc upload temporary fix for MVP -- in below query end after OR with Hardcoded name Name ='Verification Documents' -- */
        /* -- CLS-1177 -- Deal room -- MW change payload sent back to FE for verification docs -- */
        for(genesis__Application_Document_Category__c adc1:[SELECT Id,name, Action_Reason__c, genesis__Active__c, genesis__Application__c, genesis__Application__r.Lead_Id__c, genesis__Application__r.LEAD_ID_ExtKey__c, genesis__Application__r.Member_ID__c, Application_Email__c,Borrower_s_Email__c,
                                                           Borrower_s_First_Name__c,Box_URl__c,Deliver_Status__c, genesis__Description__c, genesis__Document_Category__r.genesis__Category_Name__c,
                                                           genesis__Parent_Application_Document_Category__r.name,genesis__Parent_Application_Document_Category__r.genesis__Description__c,
                                                           genesis__Document_Category__r.genesis__Parent_Document_Category__r.genesis__Category_Name__c, genesis__Email__c,genesis__Id__c, Member_Email__c,
                                                           genesis__Parent_Application_Document_Category__c, genesis__Parent_Id__c, genesis__Party_Type__c, genesis__Priority__c, Rejection_Reasons__c,
                                                           genesis__Required__c, genesis__Application__r.genesis__Account__c, genesis__Party__c, genesis__Review_Assigned_To__c, genesis__Review_Comments__c, Doc_Code_FF__c, genesis__Reviewed_By__c, genesis__Send_Notification__c,genesis__Status__c, ShareBoxLink__c
                                                           from genesis__Application_Document_Category__c where (genesis__Application__c =:appId
                                                                                                                                          AND genesis__Parent_Application_Document_Category__r.name != 'Root'
                                                                                                                                          AND genesis__Required__c = true AND
                                                                                                                                                                     Name NOT IN : docCategoriesNamestoskip) OR (genesis__Application__c =:appId AND Name ='Verification Documents') LIMIT 25]) {
            sobjList1.add(adc1);
        }
        
        Set<String> ParentIdOfRequiredDocs = new Set<String>();
        for(genesis__Application_Document_Category__c ad: sobjList1)
        {
            if(ad.genesis__Parent_Application_Document_Category__r.name != 'Verification Documents' && ad.genesis__Parent_Application_Document_Category__r.name!='Self Employed Documents' && ad.genesis__Parent_Application_Document_Category__r.name!='Root')
            {
               ParentIdOfRequiredDocs.add(ad.genesis__Parent_Application_Document_Category__c);
            }
            else
            {
                 sobjList.add(ad);
            } 
            
        }
        
        
        for(genesis__Application_Document_Category__c adc:[SELECT Id,name, Action_Reason__c, genesis__Active__c, genesis__Application__c, genesis__Application__r.Lead_Id__c, genesis__Application__r.LEAD_ID_ExtKey__c, genesis__Application__r.Member_ID__c, Application_Email__c,Borrower_s_Email__c,
                                                           Borrower_s_First_Name__c,Box_URl__c,Deliver_Status__c, genesis__Description__c, genesis__Document_Category__r.genesis__Category_Name__c,
                                                           genesis__Parent_Application_Document_Category__r.name,genesis__Parent_Application_Document_Category__r.genesis__Description__c,
                                                           genesis__Document_Category__r.genesis__Parent_Document_Category__r.genesis__Category_Name__c, genesis__Email__c,genesis__Id__c, Member_Email__c,
                                                           genesis__Parent_Application_Document_Category__c, genesis__Parent_Id__c, genesis__Party_Type__c, genesis__Priority__c, Rejection_Reasons__c,
                                                           genesis__Required__c, genesis__Application__r.genesis__Account__c, genesis__Party__c, genesis__Review_Assigned_To__c, genesis__Review_Comments__c, Doc_Code_FF__c, genesis__Reviewed_By__c, genesis__Send_Notification__c,genesis__Status__c, ShareBoxLink__c
                                                           from genesis__Application_Document_Category__c where genesis__Parent_Application_Document_Category__c IN : ParentIdOfRequiredDocs order by Last2characters_forSorting__c ASC LIMIT 100]) {
            sobjList.add(adc);
        }
        
         /* -- END --- CLS-1177 -- Deal room -- MW change payload sent back to FE for verification docs -- */
        return sobjList;
        
    }

    //@future (callout=true)
    public static void processDataCate(List<String> appList){
         List<loan__Batch_Process_Log__c> logList = new List<loan__Batch_Process_Log__c>();
        /* change for too many soql : 201 on MWQueable job */
        System.debug(logginglevel.error,'DCP1293_ MW_DocumentCategoryHandlerTEMP processDataCate' );
        Set<String> appElements = new Set<String>();
        appElements.addAll(appList);
        /* ---- END change for too many soql : 201 on MWQueable job */
        System.debug('>>>>>>%%%%'+appElements.size());
        for(String appid:appElements) {
            logList.addAll(Sync_Document_Category_ToWebHook(appid));
        }
        insert logList;
    }

    public static List<loan__Batch_Process_Log__c> Sync_Document_Category_ToWebHook(String appid)
    {   
        List<loan__Batch_Process_Log__c> logList = new List<loan__Batch_Process_Log__c>();
        list<DocumentInformation> listOfDoc = new list<DocumentInformation>();
        list<DocumentData> listOfDocdata    = new list<DocumentData>();

        String leadId;
        String lead_id_ext_key;
        String member_id;

        List<genesis__Application_Document_Category__c> appDclist = applicationDocumentCategory(appid);

        List<String> accList = new List<String>();
        for(genesis__Application_Document_Category__c acc:appDclist) {
            accList.add(acc.genesis__Application__r.genesis__Account__c);
        }

        Map<Id, boolean> accMap                                   = MW_WebhookHelper.applicationHasYodleeDetails(accList);

        for(genesis__Application_Document_Category__c docCatlist: appDclist)
        {
            if(accMap.get(docCatlist.genesis__Application__r.genesis__Account__c) !=null & accMap.size()>0 &&
               docCatlist.genesis__Parent_Application_Document_Category__r.name=='Bank Statements' && docCatlist.genesis__Status__c=='OPEN')
                continue;

            DocumentInformation dci = new DocumentInformation();
            if(docCatlist.genesis__Parent_Application_Document_Category__r.name!='Verification Documents' /*CLS-892 --> */ && docCatlist.genesis__Parent_Application_Document_Category__r.name!='Root' && docCatlist.genesis__Parent_Application_Document_Category__r.name!='Self Employed Documents') {
                System.debug('>>>>'+docCatlist.genesis__Parent_Application_Document_Category__r.name);
                dci.category           = docCatlist.genesis__Parent_Application_Document_Category__r.name;
                dci.category_label     = docCatlist.genesis__Parent_Application_Document_Category__r.name;
                dci.category_text      = docCatlist.genesis__Parent_Application_Document_Category__r.genesis__Description__c;
            }else{
                dci.category           = docCatlist.genesis__Document_Category__r.genesis__Category_Name__c;
                dci.category_label     = docCatlist.genesis__Document_Category__r.genesis__Category_Name__c;
                dci.category_text      = docCatlist.genesis__Description__c;
            }
            dci.document_id        = docCatlist.Id;
            dci.status             = docCatlist.genesis__Status__c;        
            dci.url                = docCatlist.Box_URl__c;
            dci.share_box_link     = docCatlist.ShareBoxLink__c;
            dci.isRequired         = docCatlist.genesis__Required__c;
            if(docCatlist.Doc_Code_FF__c!=null && docCatlist.Doc_Code_FF__c!='')
                dci.code               = docCatlist.Doc_Code_FF__c;
            if(docCatlist.genesis__Status__c == 'REJECTED')
                dci.rejection_reason   = docCatlist.Rejection_Reasons__c;
            listOfDoc.add(dci);

            if(leadId==null) leadId = docCatlist.genesis__Application__r.Lead_Id__c;
            if(lead_id_ext_key == null) lead_id_ext_key = docCatlist.genesis__Application__r.LEAD_ID_ExtKey__c;
            if(member_id == null) member_id = docCatlist.genesis__Application__r.Member_ID__c;
        }

        DocumentData doc    = new DocumentData(leadId,lead_id_ext_key,member_id,listOfDoc);
        listOfDocdata.add(doc);
        System.debug('>>>>>*** ' +listOfDocdata);

        Document_Category_Info syncdci = new Document_Category_Info('verification_docs', listOfDocdata);
        String str = JSON.serialize(syncdci, true);
        System.debug('>> Details '+ str);
        logList.addAll(CallWebHookIntegration(str, appid, leadId));
        return logList;
    }
    
    webservice Static List<loan__Batch_Process_Log__c> CallWebHookIntegration(String reqbody, String appId, String leadId)
	{
	    loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
	    List<loan__Batch_Process_Log__c> logList = new List<loan__Batch_Process_Log__c>();
			
		try {

			String certName = MW_Settings__c.getInstance().CertificateNameForLEADS__c;
			String leadsEndPoint = MW_Settings__c.getInstance().LEADS_FE_EndpointURL__c;
			HttpRequest req = new HttpRequest();
			req.setMethod('POST');
			req.setHeader('Content-Type', 'application/json');
			req.setHeader('Cache-Control', 'no-cache');
			if(certName!=null)
				req.setClientCertificateName(certName);
			System.debug('WebHook request :: >>' +reqbody  );
            
            MW_LogUtility.info('MW_DocumentCategoryHandlerTEMP--MW_WebhookHandler', appId, leadId, 'REQ: Sync_Document_Category_ToWebHook--CallWebHookIntegration', reqbody);
            bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'MW_POSTDEALROOMSTRUCTURE';
            bplog.loan__Message__c = 'Request = ' + reqbody;
            bplog.loan__Type__c = 'REQUEST';
            bplog.loan__Time__c = DateTime.now();
            bplog.loan__Summary_Record_Id__c = appId;
            bplog.loan__Batch_Job_Id__c = leadId;
            //bplog.loan__Batch_Id__c = res.getStatusCode();
            bplog.loan__Log_Level__c = 'DEBUG';
            logList.add(bplog);
            
			req.setEndpoint(leadsEndPoint);
			req.setbody(reqbody);
			Http http = new Http();
            req.setTimeout(120000);
			System.debug('Request:: >>' +req);
			HTTPResponse res = http.send(req);
			System.debug('Response :: >> ' +res);
			String response;
			MW_LogUtility.info('MW_DocumentCategoryHandlerTEMP--MW_WebhookHandler', appId, leadId, 'RES: Sync_Document_Category_ToWebHook--CallWebHookIntegration', res.getBody(), res);
            
			if(res.getStatusCode()==200) {
				response = res.getBody();
			}
			
			bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'MW_POSTDEALROOMSTRUCTURE';
            bplog.loan__Message__c = 'Response = ' + res.getBody();
            bplog.loan__Type__c = 'RESPONSE';
            bplog.loan__Time__c = DateTime.now();
            bplog.loan__Summary_Record_Id__c = appId;
            bplog.loan__Batch_Job_Id__c = leadId;
            bplog.loan__Batch_Id__c = String.valueOf(res.getStatusCode());
            bplog.loan__Log_Level__c = 'DEBUG';
            logList.add(bplog);
            
		}
		catch(Exception e){
			MW_LogUtility.error('MW_WebhookHandler', appId, leadId, 'ERROR: Sync_Document_Category_ToWebHook--CallWebHookIntegration', e);
			System.debug('Error: ' + e.getLineNumber() + ' Desc. ' + e.getMessage()+' Stack: '+e.getStackTraceString());
			bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'MW_POSTDEALROOMSTRUCTURE';
            bplog.loan__Message__c = 'Error = ' + e.getStackTraceString();
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            bplog.loan__Summary_Record_Id__c = appId;
            bplog.loan__Batch_Job_Id__c = leadId;
            bplog.loan__Batch_Id__c = e.getMessage();
            bplog.loan__Log_Level__c = 'ERROR';
            logList.add(bplog);
            return logList;
		}
		
		return logList;
	}

    class DocumentInformation {
        public String category;
        public String category_label;
        public String category_text;
        public String section;
        public String section_label;
        public String document_id;
        public String status;
        public String url;
        public String member_id;
        public String lead_id;
        public String share_box_link;
        public String rejection_reason;
        public String code;
        public boolean isRequired;
    }

    class DocumentData {
        DocumentInformation[] docs;
        String lead_guid;
        String lead_id;
        String member_id;
        boolean verification_docs_approved;

        public DocumentData(String leadId, String lead_id_ext_key, String member_id, DocumentInformation[] docData){
            this.lead_guid = leadId;
            this.lead_id = lead_id_ext_key;
            this.member_id = member_id;
            this.docs = docData;
            this.verification_docs_approved=false;
        }
    }

    class Document_Category_Info {
        String type;
        DocumentData[] data;
        public Document_Category_Info(String type, DocumentData[] docData){
            this.type = type;
            this.data = docData;
        }
    }

}