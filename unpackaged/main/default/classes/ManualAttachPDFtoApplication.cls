global with sharing class ManualAttachPDFtoApplication {
    public static boolean isAttmtPDFExecuting=true;
    public static String s;
    public static boolean adverseAction;
    public static boolean csnNotice;
  
    public static Attachment csnAttachment(String idVal) {
        PageReference pdfCSN = Page.CSNDocument;
        pdfCSN.getParameters().put('id',idVal);
        Attachment attachCSN = new Attachment(); 
        attachCSN.ParentId = idVal;
        String s = string.valueOf(System.Now());
        attachCSN.Name = 'Credit Score Notice'+ ' ' +idVal+' ' +s+'.pdf';
        attachCSN.Description = 'Credit Score Notice';
        Blob bodyCSN; 
        try{
            // returns the output of the page as a PDF
            if(!test.isRunningTest())
                bodyCSN = pdfCSN.getContent();
            else
                bodyCSN = blob.valueOf('Test String');
            //body = pdf.getContent();
            
            attachCSN.Body = bodyCSN;
            system.debug('Test');
            //attachments.add(attachCSN);
            //insert attachments;
        } catch (VisualforceException e) {
            attachCSN.body = Blob.valueOf('Could not generate the Document');
        }   
        return attachCSN;
    }
    
    public static Attachment adverseAttachment(String id) {
        PageReference pdf = Page.AdverseActionDocument;
        pdf.getParameters().put('id',id);
        Attachment attach = new Attachment();
        attach.ParentId = id;
        String s = string.valueOf(System.Now());
        System.debug('***s****'+s);
        attach.Name = 'Adverse Action Document'+ ' ' +id+' '+s+'.pdf';
        Blob body; 
        try{
            // returns the output of the page as a PDF
            if(!test.isRunningTest())
                body = pdf.getContent();
            else
                body=blob.valueOf('Test String');
                    
            attach.Body = body;
            System.debug('Doc Name:....' + attach.Name);
            attach.Description = 'Adverse Action Notice';
            attach.IsPrivate = false;
            //attachments.add(attach);
        } catch (VisualforceException e) {
            attach.body = Blob.valueOf('Could not generate the Document');
        }   
        return attach;
    }
    
    webservice static void attachPDFWebService(String idVal,boolean adverse,boolean csn){
        attachPDF(idVal,adverse,csn);
    } 
    public static void attachPDF(String idVal,boolean adverse,boolean csn){
        adverseAction = adverse;
        csnNotice = csn;
        list<Attachment> attachments = new list<Attachment>();
        Attachment attachAdverse,attachCSN;
        try{
            if(adverse) {
                attachAdverse = adverseAttachment(idVal);
                attachments.add(attachAdverse);
            }
            if(csn) {
                attachCSN = csnAttachment(idVal);
                attachments.add(attachCSN);
            }
           
            Database.SaveResult[] srList = Database.insert(attachments, false);
            Set<Id> attmt = new Set<Id>();
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    attmt.add(sr.getId());
                }
                for(Database.Error er : sr.getErrors()){
                    System.debug(er.getStatusCode() + ': ' + er.getMessage());
                    System.debug('Account fields that affected this error: ' + er.getFields());
                }
            }
            
            DelAppDocJuncAttachment(idVal);
            AppDealRoomAttachment.DealroomAttachment(idVal, attmt);     
        }catch (Exception ex){
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'AttachPDFto Application Email';
            bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            insert bplog;
            
            throw ex;
        } 
    }
    
  
    
    public static void DelAppDocJuncAttachment(Id applicationId){
        try{
            List<Attachment> attach = new List<Attachment>();
            
            if(adverseAction==true) {
                List<Attachment> attachAdverse = [Select Id from Attachment where 
                                            parentId = :applicationId and 
                                            Name like '%Adverse Action Document%'];
                attach.addAll(attachAdverse);
            }
            if(csnNotice==true) {
                List<Attachment> attachCSN = [Select Id from Attachment where 
                                            parentId = :applicationId and 
                                            Name like '%Credit Score Notice%'];
                attach.addAll(attachCSN);
            }
            if(!attach.isEmpty()){
                Set<Id> attmtId = new Set<Id>();
                for(Attachment att : attach)
                    attmtId.add(att.Id);
                DeleteAppDocJunAttachments.delAttachments(attmtId);    
            }
         }catch (Exception ex){
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'ManualAttachPDFtoApplication - DelAppDocJuncAttachment';
            bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            insert bplog;
            
            throw ex;
        } 
    }
    
    Webservice static String ManualTILgenerate(Id appId){
        try{
            List<genesis__applications__c> app = [SELECT Id,Name,genesis__Status__c,Investor__c,Investor__r.Name,Total_Arcus_Transactions__c,Investor__r.DCP_Allowed__c, DCP_Investor_Eligibility__c,state__c
                                                  FROM genesis__applications__c WHERE Id=:appId LIMIT 1];
            System.debug('Application :'+app);
            
              if(app[0].Investor__c!=null) {
                           if(app[0].Total_Arcus_Transactions__c >0 && (app[0].Investor__r.DCP_Allowed__c==true || app[0].DCP_Investor_Eligibility__c)) {
                               ApplicationAttachmentHandler.attachmentHandler(app[0].Id, app[0].Investor__r.Name, 'TILDocument_forDCP');
                           }
                           /*else if (app[0].state__c =='IN'){
                           System.debug('-----in elseif Indiana----');
                           ApplicationAttachmentHandler.attachmentHandler(app[0].Id, app[0].Investor__r.Name, 'TILDocument_Indiana');
                           }*/
                           else {
                            System.debug('-----in else without dcp----'  + app[0].Investor__r.Name);
                            ApplicationAttachmentHandler.attachmentHandler(app[0].Id, app[0].Investor__r.Name, 'TIL');
                       }
                    }    
        }catch(Exception ex){
            System.debug('Exception:Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString());
        } 
        return Label.Til_Regenerated;
    } 
}