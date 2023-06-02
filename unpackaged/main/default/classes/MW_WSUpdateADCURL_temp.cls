@RestResource(urlMapping='/updateDocumentURL')
global with sharing class MW_WSUpdateADCURL_temp {

    public class ADCBoxClass {
        public String document_id;
        public String box_url;
        public String shared_url;
        public String category;
        public String lead_id;
    }

    @HttpPost
    global static String create() {
        RestRequest req =Restcontext.request;
        String jsonData = req.requestBody.toString();
        ADCBoxClass adcObj = (ADCBoxClass) JSON.deserialize(jsonData, ADCBoxClass.class);
        try {
            if(!String.isBlank(adcObj.document_id)) {
                List<genesis__Application_Document_Category__c> newDoc =
                [Select Id, Name, genesis__Application__c, Box_URl__c,ShareBoxLink__c, genesis__Status__c
                 From genesis__Application_Document_Category__c
                 Where Id =: adcObj.document_id];
                if(newDoc.size() > 0 && newDoc[0].genesis__Status__c != 'CLEARED') {
                    newDoc[0].Box_URl__c = adcObj.box_url;
                    newDoc[0].Rejection_Reasons__c = null;
                    if(adcObj.shared_url!=null)
                    newDoc[0].ShareBoxLink__c = adcObj.shared_url;
                    
                    createNewDocTag(newDoc[0].genesis__Application__c);
                    update newDoc;
                }
                else if (newDoc.size() > 0){
                    //if doc is already CLEARED then tag the application
                    createApplicationTag(newDoc[0].genesis__Application__c);
                }
            }
            else{
                List<genesis__Applications__c> appList = [Select Id, Lead_ID__c From genesis__Applications__c Where Lead_ID__c =: adcObj.lead_id];
                if(appList.size() > 0) {
                    //update the flag on application here
                    createApplicationTag(appList[0].Id);
                }
            }
            return 'Success';
        }
        catch(Exception e){
            MW_LogUtility.error('MW_WSUpdateADCURL_temp', '', adcObj.lead_id, 'create', e);
            return 'Error: ' + e.getLineNumber() + ' Desc. ' + e.getMessage()+' Stack: '+e.getStackTraceString();
        }
    }

    public static void createApplicationTag(Id appId){
        List<Application_Tags__c> appTagsList = [Select id, Application__c, Application_Tag__c
                                                 From Application_Tags__c
                                                 Where Application__c =: appId AND Application_Tag__c = 'View Box for Documents' AND softDelete__c =false];//LOS-217
        if(appTagsList.size() == 0) {
            Application_Tags__c newAppTag = new Application_Tags__c();
            newAppTag.Application__c = appId;
            newAppTag.Application_Tag__c = 'View Box for Documents';
            appTagsList.add(newAppTag);
            insert appTagsList;
        }
    }
    public static void createNewDocTag(Id appId){
        List<Application_Tags__c> appTagsList = [Select id, Application__c, Application_Tag__c
                                                 From Application_Tags__c
                                                 Where Application__c =: appId AND Application_Tag__c = 'New Documents' AND softDelete__c = false];//LOS-217
        if(appTagsList.size() == 0) {
            Application_Tags__c newAppTag = new Application_Tags__c();
            newAppTag.Application__c = appId;
            newAppTag.Application_Tag__c = 'New Documents';
            appTagsList.add(newAppTag);
            insert appTagsList;
        }
    }
}