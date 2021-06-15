public with sharing class ApplicationAttachmentHandler {
    public static boolean isOfferTrgExecuting=true;
    public static boolean isDCPTrgExecuting=true;
    
    List<String> documentType = new List<String>();   
   
    public ApplicationAttachmentHandler(boolean isExecuting){
        isOfferTrgExecuting = isExecuting;
        isDCPTrgExecuting = isExecuting;
    } 
    @InvocableMethod
    public static void createCSN(List<genesis__Applications__c> appId) 
    {
        genesis__applications__c appInfo = [Select Id, genesis__Status__c, Investor__r.Name from genesis__applications__c Where Id =: appId[0].id];
        //List<Attachment> attach = [Select id,name from attachment where name like'%Credit%' and parentId =: appInfo.id  limit 1];
        //CSN Fix
        //if(appInfo.Investor__r.Name != null){
        ApplicationAttachmentHandler.attachmentHandler(appInfo.Id, appInfo.Investor__r.Name, 'CSN'); 
        //}          
    }
    public static PageReference savePdfAttachment(Id applicationId) { 
   
        System.debug('.... savePdfAttachment ....' + applicationId  ); 
        System.debug('Before isOfferTrgExecuting ....'+ isOfferTrgExecuting );
        if(isOfferTrgExecuting){
            //isOfferTrgExecuting = false;
            System.debug('After isOfferTrgExecuting ....'+ isOfferTrgExecuting );
            
            genesis__applications__c appInfo = [Select Id, genesis__Status__c, Investor__r.Name,
                                                (Select id,name from Credit_Policy__r) 
                                                from genesis__applications__c Where
                                                Id =: applicationId];
            if(appInfo.Investor__r.Name != null && appInfo.genesis__Status__c != NULL && appInfo.Credit_Policy__r != null){
                ApplicationAttachmentHandler.attachmentHandler(appInfo.Id, appInfo.Investor__r.Name, appInfo.genesis__Status__c); 
                isOfferTrgExecuting = false;            
                System.debug('Application Attachment Record Created');                    
            }
            /*else
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.FATAL, 'Please Check the Investor'));*/
                                    
        }
        //Render the application to view results
        return new PageReference('/'+applicationId);  
    }
    //@Future(callout=true)
    public static PageReference savePdfAttachment(Id applicationId, String investorInfo, String appStatus) { 
   
        System.debug('.... savePdfAttachment ....' + applicationId + investorInfo+ appStatus  ); 
        
        if(isDCPTrgExecuting){
            //isDCPTrgExecuting = false;
            System.debug('isDCPTrgExecuting ....'+ isDCPTrgExecuting );            
            genesis__applications__c appInfo = [Select Investor__r.Name from genesis__applications__c Where
                                         Id =: applicationId];
            if(appInfo.Investor__r.Name != null && appStatus != NULL){
                System.debug('.... savePdfAttachment ....' + applicationId + appInfo.Investor__r.Name + appStatus);
                ApplicationAttachmentHandler.attachmentHandler(applicationId, appInfo.Investor__r.Name, appStatus);
                isDCPTrgExecuting = false; 
                System.debug('Application Attachment Record Created');
            } 
            /*else
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.FATAL, 'Please Check the Investor'));
            */
        }
        //Render the application to view results
        return new PageReference('/'+applicationId);
    }
    public static void delAttachments(Id applicationId, String docType){
        String docValue = '%' + docType.trim() + '%';
        System.debug('delAttachments.....');
        List<Attachment> attach = [Select Id from Attachment where 
                                            parentId = :applicationId and 
                                            Name like : docValue];
        if(!attach.isEmpty()){
            Set<Id> attmtId = new Set<Id>();
            for(Attachment att : attach)
                attmtId.add(att.Id);
            DeleteAppDocJunAttachments.delAttachments(attmtId);    
        }
        
        //delete([Select Id from Attachment where ParentId =: applicationId and Description like : docValue]);
    }
    
    @Future(callout=true)
    public static void attachmentHandler(Id applicationId, String investorInfo, String appStatus){
        CL_Document__c cs = CL_Document__c.getOrgDefaults();
        string credit = cs.Doc1__c;
        string Til = cs.Doc2__c;   
        System.debug('...Status...' +  appStatus + investorInfo);
        List<String> documentType = new List<String>();
        if(appStatus.equalsIgnoreCase('CSN')){
           // documentType.add(Til);
            documentType.add(credit);            
        }
        if(appStatus.equalsIgnoreCase('offer_accepted')){
            documentType.add(Til);
            /*list<Credit_Policy__c> creditPolicy = [select id,name,fico__c from Credit_Policy__c where application__c =:applicationId order by createdDate desc];
            if(creditPolicy!=null && creditPolicy.size()>0 && creditPolicy[0].fico__c!=null)
                documentType.add(credit);   */         
        } else if(appStatus.equalsIgnoreCase('dcp_accepted')){            
            documentType.add('TILDocument_DCP');
        } else if(appStatus.equalsIgnoreCase('redecision') || appStatus.equalsIgnoreCase('Reallocation')){
            documentType.add(Til);
        } else if(appStatus.equalsIgnoreCase('TIL')) {
             documentType.add(Til);
        }else if(appStatus.equalsIgnoreCase('TILDocument_forDCP')) {    //CLS-1189
             documentType.add('TILDocument_forDCP');
        }
        System.debug('.........DocumentType...........' + documentType);
        PageReference pdfDocument = null;
        List<Attachment> attachmentLst = new List<Attachment>();
        System.debug('.........DocumentType...........' + documentType);
         for(String strDocument : documentType){
            Attachment attach = new Attachment();
            
            //if(strDocument.contains(credit)){
            if(strDocument.equalsIgnorecase(credit)){
                pdfDocument = Page.CSNDocument;      
                delAttachments(applicationId, strDocument);
            }
            else if(strDocument.equalsIgnorecase(Til)){
                pdfDocument = Page.TILDocument;
                delAttachments(applicationId, 'TIL');
            }
            else if(strDocument.equalsIgnorecase('TILDocument_DCP')){
                pdfDocument = Page.TILDocument_TCU; 
                delAttachments(applicationId, 'TIL');
            }else if(strDocument.equalsIgnorecase('TILDocument_forDCP')){   //CLS-1189
                pdfDocument = Page.TILDocument_forDCP; 
                delAttachments(applicationId, 'TIL');
                strDocument = Til;
            }
               
            System.debug('...' +strDocument);
            //delAttachments(applicationId, strDocument);
            
            pdfDocument.getParameters().put('id',applicationId);
            // the contents of the attachment from the pdf
            Blob body; 
            try { 
                try{
                    // returns the output of the page as a PDF
                    if(!test.isRunningTest()){
                        body = pdfDocument.getContent();
                        if(body == null){
                        
                           // System.debug('***body****'+body);
                        }
                     }
                    else
                        body=blob.valueOf('Test String');
                    //body = pdfDocument.getContent();
                    system.debug('Body'+body);
                } 
                catch (VisualforceException e) {
                    body = Blob.valueOf('Could not generate the Document');
                    System.debug('***body*****'+body);
                }                    
                attach.Body = body;
                string curTime = String.valueOf(System.NOW());
                attach.Name = strDocument+ ' ' +applicationId+' '+curTime+'.pdf';
                System.debug('Doc Name:....' + attach.Name);
                attach.Description = strDocument;
                attach.IsPrivate = false;
                attach.ContentType = 'application/pdf';
                attach.ParentId = applicationId; 
                System.debug('Attachment:...' + attach);
                attachmentLst.add(attach);
                //String boxFolderID = BoxAPI_Integration.CheckBoxFolder(applicationId);
                /*Attachment att = [SELECT Name, body from Attachment where name='AdverseActionDocument a6h2F0000008r1fQAA.pdf' LIMIT 1];
                String fileName = strDocument+' '+applicationId+'.pdf';
                BoxAPI_Integration.uploadFile('47663770171', att.Name, att.body);*/
            }
            catch (Exception ex){
                loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
                bplog.loan__Origin__c = strDocument;
                bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
                bplog.loan__Type__c = 'Exception';
                bplog.loan__Time__c = DateTime.now();
                insert bplog;
                
                throw ex;
            } 
        }
          
        insert attachmentLst;  
        //Set<Id> attmtId = new Set<Id>();
        Map<id,string> attchmentMap = new Map<id,string>();
        for(Attachment attach : attachmentLst){
            //attmtId.add(attach.Id);
            if(!attchmentmap.containsKey(attach.id))
            {
                attchmentmap.put(attach.id,attach.Description);
            }
        }
        DealroomAttachment(applicationId, attchmentmap);
    }
    public static void DealroomAttachment(Id applicationId, Map<id,string> mapAttach){
        try{           
                                    
            for(Id attachId : mapAttach.keySet()){
                
                List<genesis__AppDocCatAttachmentJunction__c> appDocCatAttInsert = new List<genesis__AppDocCatAttachmentJunction__c>();
        
                string name  = mapAttach.get(attachid);
                string DocumentName = '%' + name + '%';
                
                List<genesis__Application_Document_Category__c> lstAppDocCat = [Select Id,genesis__status__c  from genesis__Application_Document_Category__c where genesis__Application__c =: applicationId and Name like : DocumentName and IsDeleted = false];
                
                if(!lstAppDocCat.isEmpty()){
                    system.debug('---lstAppDocCat----'+lstAppDocCat); 
                    System.debug('.... Attachment Id ..' + attachId );
                    
                    for(genesis__Application_Document_Category__c genesisAppIterate : lstAppDocCat){
                        if (genesisAppIterate.genesis__status__c !=null)
                        {
                        genesis__AppDocCatAttachmentJunction__c lstAppDocCatAttachment = new genesis__AppDocCatAttachmentJunction__c();  
                        
                        lstAppDocCatAttachment.genesis__Application_Document_Category__c = genesisAppIterate.Id;
                        lstAppDocCatAttachment.genesis__AttachmentId__c = attachId;  
                        appDocCatAttInsert.add(lstAppDocCatAttachment); 
                    }
                    }
                    if(!appDocCatAttInsert.isEmpty())
                        insert appDocCatAttInsert;
                }
            }
        }catch (Exception ex){
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'AttachmentDealroom';
            bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            insert bplog;
            
            throw ex;
        } 
    }
}