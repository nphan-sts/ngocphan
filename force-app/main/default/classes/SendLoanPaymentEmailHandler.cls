public with Sharing class SendLoanPaymentEmailHandler{
    public Static Void SendMail(Id templateId, Id loanAccountID, Id contactID, Id orgWideEmailId, String emailAddress){
        System.debug('...SendLoanPaymentHandler.SendMail ...');
        
        try{
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                
            List<String> sendTo = new List<String>();
            //sendTo.add(loanAccount.loan__Account__r.cnotify__Email__c);
            
            sendTo.add(emailAddress);
            email.setToAddresses(sendTo);             
            //email.setSenderDisplayName('Payoff');
            email.setReplyTo('payments@payoff.com');
    
            email.setorgWideEmailAddressId(orgWideEmailId);
            email.setTargetObjectId(contactID);
            //email.setTargetObjectId(userId);
            //email.setTreatTargetObjectAsRecipient(false);
            email.setWhatId(loanAccountID);
            email.setTemplateId(templateId);
            
            email.saveAsActivity = false;
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }catch(exception ex){
            loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
            bplog.loan__Message__c = 'Error in SendLoanPaymentHandler: ' + ex.getLineNumber() + ' Desc. ' + ex.getMessage()+' Stack: '+ex.getStackTraceString();
            bplog.loan__Type__c = 'Exception';
            bplog.loan__Time__c = DateTime.now();
            insert bplog;
            
            throw ex;
        }
    }
       
    
    /*@Future 
    public Static Void ManualPaymentMode(Map<ID, String> lstLoanAcc){
        Contact con = new Contact();
        con.LastName = 'Test';
        con.Email = 'no-reply@organization.com';
        insert con;
        Id templateId =  [select id, name from EmailTemplate where developername = 'Manual_Payment_Selected'].Id; 
        
        Id orgWideEmailId;
        OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where DisplayName = 'PayOff' LIMIT 1];
        if(owea != null)
            orgWideEmailId = owea.Id;
        String emailAddress;
        for(ID loanAccID : lstLoanAcc.keySet()){
            emailAddress = lstLoanAcc.get(loanAccID);
            System.debug('...Email Details...'+ templateId+'...'+ loanAccID +'...'+ con.Id+'...'+ orgWideEmailId+'...'+ emailAddress);
            SendLoanPaymentEmailHandler.SendMail(templateId, loanAccID, con.Id, orgWideEmailId, emailAddress);
        }
        delete con;
    } */
    
    @InvocableMethod
    public Static Void ManualPaymentMode(List<ID> lstLoanAcc){
        Contact con = new Contact();
        con.LastName = 'Test';
        con.Email = 'no-reply@organization.com';
        insert con;
        Id templateId =  [select id, name from EmailTemplate where developername = 'Manual_Payment_Selected'].Id; 
        
        Id orgWideEmailId;
        OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where DisplayName = 'PayOff' LIMIT 1];
        if(owea != null)
            orgWideEmailId = owea.Id;
        String emailAddress;
        for(ID loanAccID : lstLoanAcc){
            emailAddress = [SELECT loan__Account__r.cnotify__Email__c FROM loan__Loan_Account__c WHERE ID=:loanAccID].loan__Account__r.cnotify__Email__c;
                         
            //emailAddress = lstLoanAcc.get(loanAccID);
            System.debug('...Email Details...'+ templateId+'...'+ loanAccID +'...'+ con.Id+'...'+ orgWideEmailId+'...'+ emailAddress);
            SendLoanPaymentEmailHandler.SendMail(templateId, loanAccID, con.Id, orgWideEmailId, emailAddress);
        }
        delete con;
    } 
}