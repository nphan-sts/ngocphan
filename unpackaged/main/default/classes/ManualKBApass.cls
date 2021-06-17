/* ****************Modification History******************
 * Created By        Date          JIRA number
 *1. Pallavi        2020/09/22     CRM-878(KBA fail interaction MW - FE - CLS change to add the button)
 *2. Pallavi        2020/09/24     CRM-880(Send Email to Allie on New Manual KBA Result)
 ******************Modification History******************/
global class ManualKBApass {
    
    Webservice static integer passKBAmanually(id appId){
        String currentUser = UserInfo.getName();
        DateTime currentDateTime;
        loan.GlobalLoanUtilFacade loanUtil = new loan.GlobalLoanUtilFacade();
        Integer emailIdNotpresent = 0;
        if(!test.isRunningTest())
            currentDateTime = loanUtil.getCurrentSystemDateTime();
        else
            currentDateTime = System.today();
        List<genesis__applications__C> app = [Select id,genesis__status__c,Manual_KBA__c,ManualKBApass_Performed_By__c,
                                              ManualKBApass_Performed_Date__c,genesis__Account__c
                                              from genesis__applications__C
                                              where id =: appId];
        if(app.size()>0){
            app[0].genesis__status__c = 'kba_success';
            app[0].Manual_KBA__c = true;
            app[0].ManualKBApass_Performed_By__c = currentUser;
            app[0].ManualKBApass_Performed_Date__c = currentDateTime;
            try{
                update app;
                /*CRM-880*/
                EmailTemplate et = [Select id,HtmlValue  
                            FROM EmailTemplate 
                           WHERE name = 'Manual KBA Pass Email'
                            LIMIT 1];
               
        		List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                List<Contact> c = new List<Contact>();
                c = [Select id from contact where Account.id =: app[0].genesis__Account__c AND Email != NULL];
                if(c.size()==0)
                    emailIdNotpresent = 1;
                OrgWideEmailAddress emailid = [select Id from OrgWideEmailAddress where DisplayName = 'PayOff' LIMIT 1];
                for(contact con : c){
                     	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                     	mail.setOrgWideEmailAddressId(emailid.id);
                        mail.setReplyTo('success@payoff.com');                        
                        mail.setTargetObjectId(con.id);
                        mail.setWhatId(app[0].Id);
                        mail.setTemplateId(et.Id);
                        mail.setSaveAsActivity(false);
                        mail.isTreatBodiesAsTemplate();
                        
                        mails.add(mail);
            }
            if(mails.size()>0)    
            	Messaging.SendEmailResult [] r1 = Messaging.sendEmail(mails);             
            }
            /*CRM-880*/
            catch(Exception ex){
                loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__Batch_Id__c = 'ManualKBApass',loan__Log_Level__c = 'Error',loan__Message__c='Error in manually passing KBA:  '+ex.getlinenumber()+'Error: '+ex.getMessage());
                insert logs;
            }
        }
        return emailIdNotpresent;  
    }

}