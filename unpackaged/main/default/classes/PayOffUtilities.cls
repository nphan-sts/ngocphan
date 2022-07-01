Global class PayOffUtilities{
    
    Static Map<id, recordtype> orgRecordtypes=new Map<id,recordtype>([SELECT Id, Name,  DeveloperName,  SobjectType, IsActive,NamespacePrefix FROM RecordType]);
    
    Public static Id getRecordtypeId(String ObjName,string RtypName,boolean isActive){
        Map<String,id> rtypeid=new Map<string,id>();
        for(recordtype rtype:orgRecordtypes.Values())
            rtypeid.put(rtype.SobjectType+rtype.DeveloperName+rtype.IsActive,rtype.Id);
        return rtypeid.get(ObjName+RtypName+isActive);
    }
    
    Public static String getRecordtypeName(Id rid){
        return orgRecordtypes.get(rid).DeveloperName;
    }
    
    Public static PayOff_Integrations__c createLog(Exception e){
        PayOff_Integrations__c log=new PayOff_Integrations__c(ErrorMsg__c=e.getMessage()+'_'+e.getStackTraceString(),RunningUser__c=UserInfo.getUserId());
        return log;
    }
    
    Public static  Map<string,Payoff_Endpoint__mdt> getEndpoint(String ApiName){
        Map<string,Payoff_Endpoint__mdt> endpointMap = new Map<string,Payoff_Endpoint__mdt>();
        for(Payoff_Endpoint__mdt cls: [SELECT Id, DeveloperName, UserName__c, EndPointURL__c FROM Payoff_Endpoint__mdt where DeveloperName=:ApiName])
            endpointMap.put(cls.DeveloperName,cls);
        
        return endpointMap;
    }
    
    Webservice Static String AssignToMXQueue(id appId) {
        try{
            
            genesis__Applications__c application= [SELECT id,genesis__Status__c,genesis__Description__c 
                                                   FROM  genesis__Applications__c 
                                                   WHERE id =: appId];
            
            List<QueueSobject> lstQueues = [SELECT Queue.Id,queue.Name, QueueId FROM QueueSobject 
                                            WHERE SobjectType = 'genesis__Applications__c' 
                                            AND queue.DeveloperName =: 'MX_Queue'];
            
            application.OwnerId = lstQueues[0].Queue.Id;
            //application.genesis__Status__c = OppLoansConstants.WAITING_TO_SIGN;
            
            update application;       
            return Label.SUBMITTED_TO_MX_QUEUE;
            
        }catch(Exception ex){
            loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__Message__c='Error in assignToUnderwriterQueue:  '+ex.getlinenumber()+'Error: '+ex.getMessage());
            insert logs;
            return 'Exception: '+ex.getMessage(); 
        }
    } 
    
    Webservice Static String AssignToFraudQueue(id appId) {
        try{
            
            genesis__Applications__c application= [SELECT id,genesis__Status__c,genesis__Description__c 
                                                   FROM  genesis__Applications__c 
                                                   WHERE id =: appId];
            
            List<QueueSobject> lstQueues = [SELECT Queue.Id,queue.Name, QueueId FROM QueueSobject 
                                            WHERE SobjectType = 'genesis__Applications__c' 
                                            AND queue.DeveloperName =: 'Fraud_Queue'];
            
            application.OwnerId = lstQueues[0].Queue.Id;
            update application;       
            return Label.SUBMITTED_TO_FRAUD_QUEUE;
            
        }catch(Exception ex){
            loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__Message__c='Error in assignToUnderwriterQueue:  '+ex.getlinenumber()+'Error: '+ex.getMessage());
            insert logs;
            return 'Exception: '+ex.getMessage(); 
        }
    } 
    
    Webservice Static String AssignToVerificationQueue(id appId) {
        try{
            
    
            
            genesis__Applications__c application= [SELECT id,genesis__Status__c,genesis__Description__c 
                                                   FROM  genesis__Applications__c 
                                                   WHERE id =: appId];
            
            List<QueueSobject> lstQueues = [SELECT Queue.Id,queue.Name, QueueId FROM QueueSobject 
                                            WHERE SobjectType = 'genesis__Applications__c' 
                                            AND queue.DeveloperName =: 'Verification_Queue'];
            
            application.OwnerId = lstQueues[0].Queue.Id;
            
            update application;       
            return Label.ASSIGNED_TO_VERIFICATION_QUEUE;
            
        }catch(Exception ex){
            loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__Message__c='Error in assignToUnderwriterQueue:  '+ex.getlinenumber()+'Error: '+ex.getMessage());
            insert logs;
            return 'Exception: '+ex.getMessage(); 
        }
    } 
    
    Webservice Static String AssignToFundingQueue(id appId) {
        try{
            
            genesis__Applications__c application= [SELECT id,genesis__Status__c,genesis__Description__c 
                                                   FROM  genesis__Applications__c 
                                                   WHERE id =: appId];
            
            List<QueueSobject> lstQueues = [SELECT Queue.Id,queue.Name, QueueId FROM QueueSobject 
                                            WHERE SobjectType = 'genesis__Applications__c' 
                                            AND queue.DeveloperName =: 'Pre_Funding_Queue'];
            
            application.OwnerId = lstQueues[0].Queue.Id;
            application.genesis__Status__c = 'pre_funding';
            
            update application;       
            return 'Assigned to Funding Queue';
            
        }catch(Exception ex){
            loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__Message__c='Error in assignToUnderwriterQueue:  '+ex.getlinenumber()+'Error: '+ex.getMessage());
            insert logs;
            return 'Exception: '+ex.getMessage(); 
        }
    } 
    
    Webservice Static String AssignToDeclinedQueue(id appId) {
        try{
            string SetQueue = 'Declined';
            genesis__Applications__c application= [SELECT id,genesis__Status__c,genesis__Description__c 
                                                   FROM  genesis__Applications__c 
                                                   WHERE id =: appId];
            
            List<QueueSobject> lstQueues = [SELECT Queue.Id,queue.Name, QueueId FROM QueueSobject 
                                            WHERE SobjectType = 'genesis__Applications__c' 
                                            AND queue.Name =: SetQueue ];
            
            application.OwnerId = lstQueues[0].Queue.Id;
            
            update application;  
            //--Added on 24.01.2018 for Adverse Action Mail
            //AdverseScorectrl.Adversefuturemethod(appId);                 
            AttachPDFtoApplication.SaveAttachment(appId,true,true); 
            //---    
            return Label.ASSIGNED_TO_DECLINED_QUEUE;
            
        }catch(Exception ex){
            loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__Message__c='Error in assignToUnderwriterQueue:  '+ex.getlinenumber()+'Error: '+ex.getMessage());
            insert logs;
            return 'Exception: '+ex.getMessage(); 
        }
    }
    
    Webservice Static String AssignToDeclinedQueueStatus(id appId,String status) {
        try{
            string SetQueue = 'Declined';
            genesis__Applications__c application= [SELECT id,genesis__Status__c,genesis__Description__c 
                                                   FROM  genesis__Applications__c 
                                                   WHERE id =: appId];
            
            List<QueueSobject> lstQueues = [SELECT Queue.Id,queue.Name, QueueId FROM QueueSobject 
                                            WHERE SobjectType = 'genesis__Applications__c' 
                                            AND queue.Name =: SetQueue ];
            
            application.OwnerId = lstQueues[0].Queue.Id;
            application.genesis__status__c = status;
            update application;  
            //--Added on 24.01.2018 for Adverse Action Mail
            //AdverseScorectrl.Adversefuturemethod(appId);                 
            AttachPDFtoApplication.SaveAttachment(appId,true,true); 
            //---    
            return Label.ASSIGNED_TO_DECLINED_QUEUE;
            
        }catch(Exception ex){
            loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__Message__c='Error in assignToUnderwriterQueue:  '+ex.getlinenumber()+'Error: '+ex.getMessage());
            insert logs;
            return 'Exception: '+ex.getMessage(); 
        }
    }
 
    Webservice Static String AssignToAgentVerifiedQueue(id appId) {
      try{
          string SetQueue = 'Agent_Verified';
          genesis__Applications__c application = [SELECT id, name, genesis__Status__c, genesis__Description__c,
                                                     genesis__Loan_Amount__c,DocuSignFlag__c, Lead_ID__c, 
                                              ( SELECT id, Interest_Rate__c, Term__c, Monthly_Payment__c,amount__c 
                                                FROM pricing_Offer__r WHERE Is_Offer_Selected__c = TRUE)
                                              FROM genesis__Applications__c WHERE id = :appId];
          List<QueueSobject> lstQueues = [SELECT Queue.Id,queue.Name, QueueId FROM QueueSobject
                                          WHERE SobjectType = 'genesis__Applications__c' 
                                          AND queue.DeveloperName =: SetQueue ];
          if (application.pricing_Offer__r.size() > 0) {
                      if ( //Assuming Offer Selected and DQ Checks not passed 
                            Application.pricing_Offer__r[0].amount__c == null ||
                            Application.pricing_Offer__r[0].Interest_Rate__c == null ||
                            Application.pricing_Offer__r[0].Term__c == null ||
                            Application.pricing_Offer__r[0].Monthly_Payment__c == null ||
                            Application.pricing_Offer__r[0].amount__c == 0 ||
                            Application.pricing_Offer__r[0].Interest_Rate__c == 0 ||
                            Application.pricing_Offer__r[0].Term__c == 0 ||
                            Application.pricing_Offer__r[0].Monthly_Payment__c == 0){

                                OrgWideEmailAddress emailid = [select Id from OrgWideEmailAddress where DisplayName = 'PayOff' LIMIT 1];
                                
                                String body = '<p> The data quality check for your application : '+ application.name +', Lead : '+application.Lead_ID__c+ ' has failed at Agent Verify. <br/>';
                                body += 'Below are the values of fields to be reviewed. <br/>';
                                body += 'Loan Amount : ' + Application.pricing_Offer__r[0].amount__c +'<br/>';
                                body += 'Interest Rate: '+ Application.pricing_Offer__r[0].Interest_Rate__c +'<br/>';
                                body += 'Term: '+ Application.pricing_Offer__r[0].Term__c +'<br/>';
                                body += 'Monthly Payment: '+ Application.pricing_Offer__r[0].Monthly_Payment__c +'<br/>';
                                body += 'Please make sure to correct the above fields. Thank you. </p>';
                                
                                system.debug('Email Body :'+ body);

                                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                List<String> sendTo = Label.jira_email.split(';');
                                mail.setToAddresses(sendTo);
                                mail.setOrgWideEmailAddressId(emailid.id);
                                mail.setSubject(application.name + ' Offer Data Missing for Agent Verify');
                                mail.setHtmlBody(body);
                                mails.add(mail);
                                Messaging.sendEmail(mails); 
                                

                                return AssignToReviewQueue(application.id);
                          } else {
                                        application.OwnerId = lstQueues[0].Queue.Id;
                                        application.genesis__Status__c = 'agent_verified';
                                        application.DocuSignFlag__c = true;
                                        update application;
                                        return Label.ASSIGNED_TO_AGENT_VERIFIED_QUEUE;
                          }
          } else{
              return 'Offer is not Selected';
            }
      }catch(Exception ex){
          loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__Message__c='Error in assignToUnderwriterQueue:  '+ex.getlinenumber()+'Error: '+ex.getMessage());
          insert logs;
          return 'Exception: ' +ex.getMessage();
      }
  }


    

Webservice Static String AssignToReviewQueue(id appId) {
        try{
            string SetQueue = 'Review_Queue';
            genesis__Applications__c application= [SELECT id,genesis__Status__c,genesis__Description__c 
                                                   FROM  genesis__Applications__c 
                                                   WHERE id =: appId];
            
            List<QueueSobject> lstQueues = [SELECT Queue.Id,queue.Name, QueueId FROM QueueSobject 
                                            WHERE SobjectType = 'genesis__Applications__c' 
                                            AND queue.DeveloperName =: SetQueue ];
            
            application.OwnerId = lstQueues[0].Queue.Id;
            
            update application;
            return Label.Assign_To_Review_Queue ;
            
        }catch(Exception ex){
            loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__Message__c='Error in assignToReviewQueue:  '+ex.getlinenumber()+'Error: '+ex.getMessage());
            insert logs;
            return 'Exception: '+ex.getMessage();
                    }
    }
            
 Webservice Static String AssignToUser(id appId) {
        try{
            string SetQueue = UserInfo.getUserId();
            genesis__Applications__c application= [SELECT id,genesis__Status__c,genesis__Description__c 
                                                   FROM  genesis__Applications__c 
                                                   WHERE id =: appId];
            

            
            application.OwnerId = UserInfo.getUserId();
            
            update application;
            return Label.Assigned_to_User;
            
        }catch(Exception ex){
            loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__Message__c='Error in assignToUser:  '+ex.getlinenumber()+'Error: '+ex.getMessage());
            insert logs;
            return 'Exception: '+ex.getMessage(); 
        }
    }

 Webservice Static String AssignToUserPreCheck(id appId) {
        try{
            string SetQueue = UserInfo.getUserId();
            genesis__Applications__c application= [SELECT id,genesis__Status__c,genesis__Description__c, user_prechecker__c 
                                                   FROM  genesis__Applications__c 
                                                   WHERE id =: appId];
                                                   
                                                   
            List<QueueSobject> lstQueues = [SELECT Queue.Id,queue.Name, QueueId FROM QueueSobject 
                                            WHERE SobjectType = 'genesis__Applications__c' 
                                            AND queue.DeveloperName = 'Pre_Checker_Queue' ];
            

            
            application.user_prechecker__c = UserInfo.getUserId();
            application.OwnerId = lstQueues[0].Queue.Id;
            
            update application;
            return Label.Assigned_to_PreChecker;
            
        }catch(Exception ex){
            loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__Message__c='Error in assignToUser:  '+ex.getlinenumber()+'Error: '+ex.getMessage());
            insert logs;
            return 'Exception: '+ex.getMessage(); 
        }
    }
    
 Webservice Static String AssignToUserOutbounder(id appId) {
        try{
            string SetQueue = UserInfo.getUserId();
            genesis__Applications__c application= [SELECT id,genesis__Status__c,genesis__Description__c, user_outbounder__c 
                                                   FROM  genesis__Applications__c 
                                                   WHERE id =: appId];
            
            List<QueueSobject> lstQueues = [SELECT Queue.Id,queue.Name, QueueId FROM QueueSobject 
                                            WHERE SobjectType = 'genesis__Applications__c' 
                                            AND queue.DeveloperName = 'Outbounder_Queue' ];
            
            application.OwnerId = lstQueues[0].Queue.Id;
            
            application.user_outbounder__c= UserInfo.getUserId();
            
            update application;
            return Label.Assigned_to_Outbounder;
            
        }catch(Exception ex){
            loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__Message__c='Error in assignToUser:  '+ex.getlinenumber()+'Error: '+ex.getMessage());
            insert logs;
            return 'Exception: '+ex.getMessage(); 
        }
    }    
    
    
     Webservice Static String createAppTagforSoftpull(id appId) {
         genesis__Applications__c application= [SELECT id,
                                                     genesis__Status__c,
                                                     genesis__Description__c,
                                                     Stacker_reviewed__c,
                                                     Manual_Soft_Pull__c
                                                   FROM  genesis__Applications__c 
                                                   WHERE id =: appId];
         application.Stacker_reviewed__c = False;
         application.Manual_Soft_Pull__c = True;
         Application_Tags__c at = new Application_Tags__c();
         at.Application_Tag__c = 'Soft Pull Requested.';
         at.Application__c = appId;
         System.debug('****POUTIL:::'+appId);
         MW_WebhookHandler.generateSoftPullJson(appId);
         insert at;
         update application;
         return 'Soft Pull Requested';
         
     }
 Webservice Static String AssignToFinalVerificationQueue(id appId) {
        try{
            string SetQueue = 'Final_Verification';
            genesis__Applications__c application= [SELECT id,genesis__Status__c,genesis__Description__c 
                                                   FROM  genesis__Applications__c 
                                                   WHERE id =: appId];
            
            List<QueueSobject> lstQueues = [SELECT Queue.Id,queue.Name, QueueId FROM QueueSobject 
                                            WHERE SobjectType = 'genesis__Applications__c' 
                                            AND queue.DeveloperName =: SetQueue ];
            
            application.OwnerId = lstQueues[0].Queue.Id;
            
            update application;
            return Label.Assigned_to_Final_Verification_Queue;
            
        }catch(Exception ex){
            loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__Message__c='Error in assignToFinalVerificationQueue:  '+ex.getlinenumber()+'Error: '+ex.getMessage());
            insert logs;
            return 'Exception: '+ex.getMessage(); 
        }
        }
             
 Webservice Static String AssignToWithdrawnQueue(id appId) {
        try{
            string SetQueue = 'Withdrawn_Queue';
            genesis__Applications__c application= [SELECT id,genesis__Status__c,genesis__Description__c 
                                                   FROM  genesis__Applications__c 
                                                   WHERE id =: appId];
            
            List<QueueSobject> lstQueues = [SELECT Queue.Id,queue.Name, QueueId FROM QueueSobject 
                                            WHERE SobjectType = 'genesis__Applications__c' 
                                            AND queue.DeveloperName =: SetQueue ];
            
            application.OwnerId = lstQueues[0].Queue.Id;
            
            update application;
            return Label.Assigned_to_Withdrawn_Queue;
            
        }catch(Exception ex){
            loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__Message__c='Error in assignToWithdrawnQueue:  '+ex.getlinenumber()+'Error: '+ex.getMessage());
            insert logs;
            return 'Exception: '+ex.getMessage(); 
        }
        }

 Webservice Static String WorkEmailVerify(id appId) {
        try{
            list <genesis__Employment_Information__c> WorkEmail= [select id, Send_work_email_verification_Email__c,Work_Email__c 
                                                           from genesis__Employment_Information__c 
                                                           where genesis__Application__c =: appID and Work_Email__c  != null and Work_Email__c  !='' limit 1];
             WorkEmail[0].Send_work_email_verification_Email__c =True;         
            update WorkEmail;
            return Label.WorkEmailVerify;
            
        }catch(Exception ex){
            loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__Message__c='Error in WorkEmailVerify:  '+ex.getlinenumber()+'Error: '+ex.getMessage());
            insert logs;
            return 'Exception: '+ex.getMessage(); 
        }
        }     

    
    @InvocableMethod
    public static void AssignToConsentQueue(List<id> appId) {
        try{
            
            List<genesis__Applications__c> application= [SELECT id,genesis__Status__c,genesis__Description__c 
                                                   FROM  genesis__Applications__c 
                                                   WHERE id In: appId];
            
            List<QueueSobject> lstQueues = [SELECT Queue.Id,queue.Name, QueueId FROM QueueSobject 
                                            WHERE SobjectType = 'genesis__Applications__c' 
                                            AND queue.DeveloperName =: 'Review_Queue'];
            
            for(genesis__Applications__c app:application)
                app.OwnerId = lstQueues[0].Queue.Id;
            //application.genesis__Status__c = 'pre_funding';
            
            update application;       
            //return 'Assigned to Funding Queue';
            
        }catch(Exception ex){
            loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__Message__c='Error in assignToUnderwriterQueue:  '+ex.getlinenumber()+'Error: '+ex.getMessage());
            insert logs;
            //return 'Exception: '+ex.getMessage(); 
        }
    }
    Webservice Static String DeleteAppTagforSoftpull(id appId) {
         //delete [SELECT Id FROM Application_Tags__c WHERE Application__c =: appId AND Application_Tag__c =:'Soft Pull Requested.'];
         List<Application_Tags__c> SoftpullAppTags = new List<Application_Tags__c>();
         SoftpullAppTags = [SELECT Id, softDelete__c FROM Application_Tags__c WHERE Application__c =: appId AND Application_Tag__c =:'Soft Pull Requested.' AND softDelete__c=False];
         For (Application_Tags__c SPapp : SoftpullAppTags){
            SPapp.softDelete__c = True;
              }
            update SoftpullAppTags;  
         return 'Soft Pull Requested tag deleted';
     } 
    
    
     
     


}