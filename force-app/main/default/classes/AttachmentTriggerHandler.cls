/*  Description: Document Category related logic 
    Developer           Date            Description 
    Mohseen Begum       07/04/2017      Created
                        20/09/2017      Modified
    --------------------------------------------------------------------------- */
public with Sharing class AttachmentTriggerHandler {
    
    public static boolean isTrgExecuting=true;
        
    /* Constructor to initialize
     * @param isExecuting    Has value of which context it is executing */
    public AttachmentTriggerHandler(boolean isExecuting){
        isTrgExecuting = isExecuting;
    }    
    
    
    /* Description: Below method is used to create document category
     * @param newAttchLst     Attachment records 
     * @param futureMethod    IsBeingCalledFromFutureMethod */    
    public void AttachmentDocumentCategory(List<Attachment> newAttchLst){
        System.debug('.... AttachmentDocumentCategory....' );
        if(isTrgExecuting){
            isTrgExecuting = false;
            System.debug('isTrgExecuting ....'+ isTrgExecuting );
            string attachName; 
            
            try{
                
                set<Id> attachIdSet  = new set<Id>();
                for(Attachment attach : newAttchLst){
                    attachIdSet.add(attach.Id);
                }
                if(!attachIdSet.isEmpty()){
                    List<Attachment> attachmentLst = [select Id, Name, Description, ParentId from Attachment where Id IN: attachIdSet and isDeleted = false limit 50000];
                    if(!attachmentLst.isEmpty()){
                        for(Attachment attachIterate: attachmentLst){ 
                            if(attachIterate.Id != null && attachIterate.ParentId != null){
                                Id attachId = attachIterate.Id; 
                                Id appId = attachIterate.ParentId;
                                String docType = attachIterate.Description;
                                if(attachIterate.Name != NULL && attachIterate.Name.contains('DocuSign')){
                                     System.debug('----' + appId +' ... ' + attachId +'....'+ docType);
                                     createDocumentAttCategory(attachId, appId);  
                                }
                             }     
                        }
                    }
                    
                }                
            }
            catch (Exception ex){
                loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
                bplog.loan__Origin__c = 'AttachmentTriggerHandler' ;
                bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
                bplog.loan__Type__c = 'Exception';
                bplog.loan__Time__c = DateTime.now();
                insert bplog;            
                throw ex;
            }
        }
    }  
    
    @future(callout=true)
    public static void createDocumentAttCategory(Id attachId, Id applId){ 
        System.debug('... createDocumentAttCategory....');
        String docType=null;
        Map<Id,List<id>> attachMap = new Map<Id,List<id>>();
        Map<Id,List<Id>> appWithAttchMap = new Map<Id,List<Id>>();
        if(attachMap.containsKey(applId)){
            attachMap.get(applId).add(attachId);
        }
        else{
            attachMap.put(applId,New List<Id>{attachId});
        }
        Boolean docStatus = false;        
        if(!attachMap.isEmpty()){
            list<dsfs__DocuSign_Status__c> docuSignStatusId = [Select Id,dsfs__Envelope_Status__c,dsfs__Subject__c,dsfs__DocuSign_Envelope_ID__c from dsfs__DocuSign_Status__c where Id IN: attachMap.keySet()];
            
            if(!docuSignStatusId.isEmpty()){
                for(dsfs__DocuSign_Status__c docuSignStatusIterate : docuSignStatusId){
                    Id appId = getApplicationId(docuSignStatusIterate.dsfs__DocuSign_Envelope_ID__c); 
                    List<id> attIds  = attachMap.get(docuSignStatusIterate.Id);
                    if(appWithAttchMap.containsKey(appId)){
                        appWithAttchMap.get(appId).addAll(attIds);
                    }
                    else{
                        appWithAttchMap.put(appId,new List<Id>());
                        appWithAttchMap.get(appId).addAll(attIds);                        
                    }
                    if(docuSignStatusIterate.dsfs__Subject__c.contains('Promissory'))
                        docType = 'Promissory Note';  
                    else if(docuSignStatusIterate.dsfs__Subject__c.contains('ESign'))                    
                        docType = 'ESign Documents';
                }
                if(!appWithAttchMap.isEmpty()){
                    delAttachments(applId);
                    createDocument(appWithAttchMap,docType);
                }
            }
        }
        
    }
    
    /* Description: Below method is used to create record in AppDocCatAttachmentJunction record
    * @param appId     ApplicationId
    * @param attchId   AttachmentId
    * @param docType   Document Type - Promissory/TIL  */    
    public static void createDocument(Map<Id,List<Id>> appWithAttchMap,string docType){
        List<genesis__AppDocCatAttachmentJunction__c> appDocCatAttInsert = new List<genesis__AppDocCatAttachmentJunction__c>();
        List<genesis__Application_Document_Category__c> lstAppDocCat = [Select Id,genesis__Application__c from genesis__Application_Document_Category__c where genesis__Application__c =: appWithAttchMap.keySet() and Name =: docType and IsDeleted = false];
        
        if(!lstAppDocCat.isEmpty()){
            system.debug('---lstAppDocCat----'+lstAppDocCat); 
            for(genesis__Application_Document_Category__c genesisAppIterate : lstAppDocCat){
                
                List<Id> attachmentIds = appWithAttchMap.get(genesisAppIterate.genesis__Application__c);
                
                for(Id attId : attachmentIds)
                {
                    genesis__AppDocCatAttachmentJunction__c lstAppDocCatAttachment = new genesis__AppDocCatAttachmentJunction__c();  
                    
                    lstAppDocCatAttachment.genesis__Application_Document_Category__c = genesisAppIterate.Id;
                    lstAppDocCatAttachment.genesis__AttachmentId__c = attId;  
                    appDocCatAttInsert.add(lstAppDocCatAttachment);
                }
            }
            if(!appDocCatAttInsert.isEmpty())
                insert appDocCatAttInsert;
        }
    }
    
    public static void delAttachments(Id applicationId){
        System.debug('delAttachments.....');
        List<Attachment> attach = [Select Id from Attachment where 
                                            parentId = :applicationId and 
                                            Name like '%DocuSign.pdf%'];
        if(!attach.isEmpty()){
            Set<Id> attmtId = new Set<Id>();
            for(Attachment att : attach)
                attmtId.add(att.Id);
            DeleteAppDocJunAttachments.delAttachments(attmtId);    
        }
    }
    
    /* Description: Below method is used to get attachmnet record ID from attachment name.
    * @param attName     Attachment record name */
    public static Id getApplicationId(string attName){     
        system.debug('getApplicationId... Application Name ' + attName);
        //Id appId = attName.substring(attName.length()-18, attName.length());
        Id appId = [SELECT Id from genesis__Applications__c where DocuSign_EnvelopeId__c =: attName].Id;
        system.debug('... Application Id ' + appId);
        return appId;
    }
}