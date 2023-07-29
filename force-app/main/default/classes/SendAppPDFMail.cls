/* ****************Modification History******************************************************************
 * Last Modified by    Date    		JIRA number
 *     Pallavi      2019/12/03    	LOS-210(Manual Decline AAN Email Should Come From success@payoff.com)
 ******************Modification History*****************************************************************/
global class SendAppPDFMail {
    public static boolean isAttmtTrgExecuting=true;
    public static void SaveAttachment(id idVal){
        
        if(isAttmtTrgExecuting){
            SendAppPDFMail.attachPDF(idVal);                    
        }
    }
    
    @Future(callout=true)
    public static void attachPDF(id idVal){
        list<Attachment> attachments = new list<Attachment>();
        try{
            PageReference pdf = Page.AdverseActionPDF;
            
            Attachment attach = new Attachment(); 
            attach.ParentId = idVal;
            attach.Name = 'Adverse Action';
            //attach.Body = pdf.getContentAsPDF();
            if(!test.isRunningTest())
            {
                attach.Body = pdf.getContentAsPDF();
            }
            else
            {
                attach.Body=blob.valueOf('Test String');
            }
    
            attachments.add(attach);
            
            Database.SaveResult[] srList = Database.insert(attachments, false);
            
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) 
                    sendEmail(idVal, sr.getId());
                
                /*for(Database.Error er : sr.getErrors()){
                    System.debug(er.getStatusCode() + ': ' + er.getMessage());
                    System.debug('Account fields that affected this error: ' + er.getFields());
                }*/
            }
        } catch (Exception ex){
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c(loan__Origin__c = 'Adverse Action',loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString(),loan__Type__c = 'Exception',loan__Time__c = DateTime.now());
            
            insert bplog;
            
            throw ex;
        }
    }
    
    public static void sendEmail(Id applicationId, Id adverseId){
        
        genesis__applications__c application = [SELECT Name, 
                                                      Borrower_s_Email__c,
                                                      Borrower_s_First_Name__c
                                                      FROM genesis__applications__c
                                                      WHERE id= :applicationId LIMIT 1];
        EmailTemplate et = [Select id,HtmlValue  
                            FROM EmailTemplate 
                            //WHERE name = 'adverse action(Lead state = decline)1'(name changed to adverse_action) 
                            WHERE name = 'Adverse_Action'
                            LIMIT 1];
                            
        List<Attachment> attachCSN = [SELECT Id, Body, Name from Attachment where ParentId =: applicationId AND Name like '%Credit Score Notice%' Order By LastModifiedDate Limit 1];
        
        List<Attachment> attachAdverse = [SELECT Id, Body, Name from Attachment where Id =: adverseId];
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        
        if(!attachCSN.isEmpty()){
            System.debug('......attachCSN......');
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(attachCSN[0].Name);
            efa.setBody(attachCSN[0].Body);
            fileAttachments.add(efa);
        }
        
        if(!attachAdverse.isEmpty()){
            System.debug('......attachAdverse......');
            Messaging.Emailfileattachment efa1 = new Messaging.Emailfileattachment();
            efa1.setFileName(attachAdverse[0].Name);
            efa1.setBody(attachAdverse[0].Body);
            fileAttachments.add(efa1);       
        }        
        
        /*for (Attachment a : [SELECT Id, Body, Name, Description from Attachment where ParentId =: idVal AND (Description like '% Credit Score Notice %' OR name LIKE '% Adverse Action %')])
        {
           Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
          efa.setFileName(a.Name);
          efa.setBody(a.Body);
          fileAttachments.add(efa);
        }*/
        
        try{    
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            List<String> sendTo = new List<String>();
            sendTo.add(application.Borrower_s_Email__c);
            
            /*LOS-210*/
             OrgWideEmailAddress emailid = [select Id from OrgWideEmailAddress where DisplayName = 'PayOff' LIMIT 1];
             mail.setOrgWideEmailAddressId(emailid.id);
            /*LOS-210*/
            
            mail.setToAddresses(sendTo);
            mail.setReplyTo('success@payoff.com');
            //mail.setSenderDisplayName('Payoff');	//commented LOS-210
            mail.setSubject('Your Payoff Loan Application Status');
            
            et.HtmlValue = et.HtmlValue.replace(' {!genesis__Applications__c.Borrower_s_First_Name__c}', ' ' + application.Borrower_s_First_Name__c);
            et.HtmlValue = et.HtmlValue.replace(']]>','');
            mail.setHtmlBody(et.HtmlValue);
            //   mail.setTargetObjectId(app.Id);
            mail.setWhatId(application.Id);
            mail.setTemplateId(et.Id);
            mail.setSaveAsActivity(false);
            mail.isTreatBodiesAsTemplate();
            mail.setFileAttachments(fileAttachments);
            
            mails.add(mail);
            System.debug('Mail body -> ' + mail);
        
            Messaging.SendEmailResult [] r1 = Messaging.sendEmail(mails);
            isAttmtTrgExecuting = false;
            System.debug(r1);
            
            System.debug('Dealroom attachment - AdverseAction Attachment');
            DealroomAttachment(applicationId, adverseId);
        }catch (Exception ex){
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c(loan__Origin__c = 'Adverse Action Mail',loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString(),loan__Type__c = 'Exception',loan__Time__c = DateTime.now());
            
            insert bplog;
            
            throw ex;
        } 
        
    }
    
    public static void DealroomAttachment(Id applicationId, Id adverseId){
        try{
            List<genesis__AppDocCatAttachmentJunction__c> appDocCatAttInsert = new List<genesis__AppDocCatAttachmentJunction__c>();
        
            List<genesis__Application_Document_Category__c> lstAppDocCat = [Select Id from genesis__Application_Document_Category__c where genesis__Application__c =: applicationId and Name like '%Generated Documents%' and IsDeleted = false];
            
            if(!lstAppDocCat.isEmpty()){
            system.debug('---lstAppDocCat----'+lstAppDocCat); 
            System.debug('.... Attachment Id ..' + adverseId );
            
            for(genesis__Application_Document_Category__c genesisAppIterate : lstAppDocCat){
                genesis__AppDocCatAttachmentJunction__c lstAppDocCatAttachment = new genesis__AppDocCatAttachmentJunction__c();  
                
                lstAppDocCatAttachment.genesis__Application_Document_Category__c = genesisAppIterate.Id;
                lstAppDocCatAttachment.genesis__AttachmentId__c = adverseId;  
                appDocCatAttInsert.add(lstAppDocCatAttachment); 
            }
            if(!appDocCatAttInsert.isEmpty())
                insert appDocCatAttInsert;
        }
        }catch (Exception ex){
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c(loan__Origin__c = 'Adverse Action Dealroom',loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString(),loan__Type__c = 'Exception',loan__Time__c = DateTime.now());
            
            insert bplog;
            
            throw ex;
        } 
    }
}