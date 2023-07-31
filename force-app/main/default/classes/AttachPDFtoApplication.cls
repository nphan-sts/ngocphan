/* ****************Modification History******************************************************************
 * Last Modified by    Date    		JIRA number
 *     Pallavi      2019/12/03    	LOS-210(Manual Decline AAN Email Should Come From success@payoff.com)
 *     Pallavi      2020/06/09    	CRM-655(Bug - AAN sent to Authorized contact)
 ******************Modification History*****************************************************************/
global with sharing class AttachPDFtoApplication {
    public static boolean isAttmtPDFExecuting=true;
    public static String s;
    public static boolean adverseAction;
    public static boolean csnNotice;
    @Future(callout=true)
    public static void SaveAttachment(String idVal,boolean adverse,boolean csn){
        adverseAction = adverse;
        csnNotice = csn;
        if(isAttmtPDFExecuting)
            AttachPDFtoApplication.attachPDF(idVal, adverse, csn);
    }
    /*webservice static void saveAttachmentFromSkuid(String idVal){
        if(isAttmtPDFExecuting)
            AttachPDFtoApplication.attachPDF(idVal);
    }*/
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
            /*PageReference pdf = Page.AdverseActionDocument;
            
            
            pdf.getParameters().put('id',idVal);
            
            Attachment attach = new Attachment();
            attach.ParentId = idVal;
            s = string.valueOf(System.Now());
            System.debug('***s****'+s);
            attach.Name = 'Adverse Action Document'+ ' ' +idVal+' '+s+'.pdf';
            Blob body; 
            try{
                // returns the output of the page as a PDF
                if(!test.isRunningTest())
                    body = pdf.getContent();
                else
                    body=blob.valueOf('Test String');
                    
                attach.Body = body;
                System.debug('Doc Name:....' + attach.Name);
                attach.Description = 'Adverse Action Document';
                attach.IsPrivate = false;
                attachments.add(attach);
            } catch (VisualforceException e) {
                body = Blob.valueOf('Could not generate the Document');
            } */ 
                
            
            // Attaching Credit Score Notice
            
            /*PageReference pdfCSN = Page.CSNDocument;
            pdfCSN.getParameters().put('id',idVal);
            Attachment attachCSN = new Attachment(); 
            attachCSN.ParentId = idVal;
            s = string.valueOf(System.Now());
            attachCSN.Name = 'Credit Score Notice'+ ' ' +idVal+' ' +s+'.pdf';
            Blob bodyCSN; 
            try{
                // returns the output of the page as a PDF
                if(!test.isRunningTest())
                    bodyCSN = pdfCSN.getContent();
                else
                    bodyCSN = blob.valueOf('Test String');
                //body = pdf.getContent();
            
                attachCSN.Body = bodyCSN;   
                attachments.add(attachCSN);
                //insert attachments;
            } catch (VisualforceException e) {
                bodyCSN = Blob.valueOf('Could not generate the Document');
            }*/
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
            sendEmail(idVal, attmt, (attachAdverse!=null?attachAdverse.Body:null), (attachCSN!=null?attachCSN.Body:null));
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
    
    public static void sendEmail(id idVal, Set<Id> adverseId, blob body, blob body1){
        
        list<genesis__applications__c> application = [SELECT id, Name, 
                                                      Borrower_s_Email__c,
                                                      Borrower_s_First_Name__c,
                                                      genesis__Status__c,
                                                      genesis__Account__c
                                                      FROM genesis__applications__c
                                                      WHERE id= :idVal];
        EmailTemplate et = [Select id,HtmlValue  
                            FROM EmailTemplate 
                           WHERE name = 'Adverse_Action'
                            LIMIT 1];
               
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        if(body1 !=null) {
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName('CreditScoreNotice.pdf');
            efa.setBody(Body1);
            fileAttachments.add(efa);
        }
        
        if(body != null) {
            Messaging.Emailfileattachment efa1 = new Messaging.Emailfileattachment();
            efa1.setFileName('AdverseAction.pdf');
            efa1.setBody(body);
            fileAttachments.add(efa1);
        }
        
        for(genesis__applications__c app : application){
            
            //Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();	//CRM-655(commented)
            
            List<Contact> c = new List<Contact>();  //CRM-655

            try{
                c = [Select id,name from contact where Account.id =: app.genesis__Account__c AND Email != NULL ];//limit 1];	//CRM-655(commented LIMIT 1)
                //Appended Email != NULL CRM-877
                }
            Catch(Exception e){                
                System.debug('No Contact Found');
            }
            
            List<String> sendTo = new List<String>();
            sendTo.add(app.Borrower_s_Email__c);
            
            //mail.setToAddresses(sendTo);
            /*LOS-210*/
             OrgWideEmailAddress emailid = [select Id from OrgWideEmailAddress where DisplayName = 'PayOff' LIMIT 1];
            for(contact con : c){	//CRM-655
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();	//CRM-655
             mail.setOrgWideEmailAddressId(emailid.id);
            /*LOS-210*/
            mail.setReplyTo('success@payoff.com');
            //mail.setSenderDisplayName('Payoff');	//commented LOS-210
            
            mail.setTargetObjectId(con.id);
            mail.setWhatId(app.Id);
            mail.setTemplateId(et.Id);
            mail.setSaveAsActivity(false);
            mail.isTreatBodiesAsTemplate();
            if(fileAttachments !=null && fileAttachments.size()>0)
                mail.setFileAttachments(fileAttachments);
            
            mails.add(mail);
            }
                        
            System.debug('Dealroom attachment - AdverseAction Attachment');
            DelAppDocJuncAttachment(idVal);
            AppDealRoomAttachment.DealroomAttachment(idVal, adverseId);
            isAttmtPDFExecuting = false;
        }	//CRM-655
        Messaging.SendEmailResult [] r1 = Messaging.sendEmail(mails);
        System.debug(r1);        
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
            bplog.loan__Origin__c = 'AttachPDFtoApplication - DelAppDocJuncAttachment';
            bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            insert bplog;
            
            throw ex;
        } 
    }
}