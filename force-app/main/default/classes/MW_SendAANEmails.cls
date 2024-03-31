/* This class was created by referring to the 'AttachPDFtoApplication' class. Only the send email method is replicated for this class. 
 * Script to run this batch class
 * Pass a set of app ids for which AAN emails are to be re-sent. 
 * If there's a different query then pass the query as well, otherwise pass NULL
 * MW_SendAANEmails em = new MW_SendAANEmails(new set<Id>{'a6h190000006Ejj','a6h190000006Ehi'},null); 
 * Database.executeBatch(em,1);
*/
global class MW_SendAANEmails implements Database.Batchable<sObject>,Database.AllowsCallouts{
    public set<Id> appIds;
    public string query;
    
    global MW_SendAANEmails(set<Id> appIds,string query){
        this.appIds = appIds;
        if(query != null){
            this.query = query;
        }else{
            this.query = 'SELECT Id, Name, Borrower_s_Email__c,Borrower_s_First_Name__c, genesis__Status__c,genesis__Account__c FROM genesis__applications__c WHERE Id IN : appIds';
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('query==>'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<genesis__Applications__c> scope) {
        for(genesis__Applications__c app : scope){
            Attachment aanAtt = getAANattachment(app.Id);
            Attachment csnAtt = getCSNattachment(app.Id);
            sendEmail(app,(aanAtt.body != null ? aanAtt.body : null),(csnAtt.body != null ? csnAtt.body : null));
        }
    }
    
    public static void sendEmail(genesis__Applications__c app, blob aanBody, blob csnBody){
        EmailTemplate et = [Select Id,HtmlValue FROM EmailTemplate WHERE name = 'Adverse_Action' LIMIT 1];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();        
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        try{
            if(aanBody != null) {
                Messaging.Emailfileattachment efa1 = new Messaging.Emailfileattachment();
                efa1.setFileName('AdverseAction.pdf');
                efa1.setBody(aanBody);
                fileAttachments.add(efa1);
            }
            if(csnBody != null) {
                Messaging.Emailfileattachment efa2 = new Messaging.Emailfileattachment();
                efa2.setFileName('CreditScoreNotice.pdf');
                efa2.setBody(csnBody);
                fileAttachments.add(efa2);
            }
            List<Contact> conList = new List<Contact>(); 
            conList = [Select id,name from contact where Account.id =: app.genesis__Account__c ];
        
            List<String> sendTo = new List<String>();
            sendTo.add(app.Borrower_s_Email__c);
            OrgWideEmailAddress emailid = [select Id from OrgWideEmailAddress where DisplayName = 'PayOff' LIMIT 1];
            for(contact con : conList){  
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                mail.setOrgWideEmailAddressId(emailid.id);
                mail.setReplyTo('success@payoff.com');
                mail.setTargetObjectId(con.id);
                mail.setWhatId(app.Id);
                mail.setTemplateId(et.Id);
                mail.setSaveAsActivity(false);
                mail.isTreatBodiesAsTemplate();
                if(fileAttachments !=null && fileAttachments.size()>0){
                    mail.setFileAttachments(fileAttachments);
                }
                mails.add(mail);
            } 
            Messaging.SendEmailResult [] r1 = Messaging.sendEmail(mails);
        }Catch(Exception ex){                
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Origin__c = 'MW_SendAANEmails';
            bplog.loan__Message__c = 'Error: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            insert bplog;
        }  
    }
    
    public static Attachment getAANattachment(Id applicationId){
        List<Attachment> attachList = [ Select Id,body from Attachment where 
                                       parentId = :applicationId and 
                                       Name like '%Adverse Action Document%' order by createddate desc];
        if(attachList != null){
            return attachList[0];
        }
        return null;
    }
    
    public static Attachment getCSNattachment(Id applicationId){
       List<Attachment> attachList = [ Select Id,Body from Attachment where 
                                        parentId = :applicationId and 
                                        Name like '%Credit Score Notice%' order by createddate desc];
        if(attachList != null){
            return attachList[0];
        }
        return null;
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}