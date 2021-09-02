public with sharing class MW_DocumentCategoryHandler {

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
                                                           genesis__Required__c, genesis__Application__r.genesis__Account__c, genesis__Party__c, genesis__Review_Assigned_To__c, genesis__Review_Comments__c, Doc_Code_FF__c, genesis__Reviewed_By__c, genesis__Send_Notification__c,genesis__Status__c, ShareBoxLink__c,
                                                           genesis__Application__r.is_Plaid_Asset_Available__c
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
                                                           genesis__Required__c, genesis__Application__r.genesis__Account__c, genesis__Party__c, genesis__Review_Assigned_To__c, genesis__Review_Comments__c, Doc_Code_FF__c, genesis__Reviewed_By__c, genesis__Send_Notification__c,genesis__Status__c, ShareBoxLink__c,
                                                           genesis__Application__r.is_Plaid_Asset_Available__c
                                                           from genesis__Application_Document_Category__c where genesis__Parent_Application_Document_Category__c IN : ParentIdOfRequiredDocs order by Last2characters_forSorting__c ASC LIMIT 100]) {
            sobjList.add(adc);
        }
         /* -- END --- CLS-1177 -- Deal room -- MW change payload sent back to FE for verification docs -- */
        return sobjList;

    }

    //@future (callout=true)
    public static void processDataCate(List<String> appList){

        /* change for too many soql : 201 on MWQueable job */
        Set<String> appElements = new Set<String>();
        appElements.addAll(appList);
        /* ---- END change for too many soql : 201 on MWQueable job */
        System.debug('>>>>>>%%%%'+appElements.size());
        for(String appid:appElements) {
            Sync_Document_Category_ToWebHook(appid);
        }

    }

    public static void Sync_Document_Category_ToWebHook(String appid)
    {
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

        //LOP-324, don't need this
        //Map<Id, boolean> accMap                                   = MW_WebhookHelper.applicationHasYodleeDetails(accList);

        for(genesis__Application_Document_Category__c docCatlist: appDclist)
        {
            //LOP-324, don't need this
            /*
            if((docCatlist.genesis__Application__r.is_Plaid_Asset_Available__c || (accMap.get(docCatlist.genesis__Application__r.genesis__Account__c) !=null & accMap.size()>0)) &&
               docCatlist.genesis__Parent_Application_Document_Category__r.name=='Bank Statements' && docCatlist.genesis__Status__c=='OPEN')
                continue;
            */

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
        MW_WebhookHandler.CallWebHookIntegration(str, appid, leadId);
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