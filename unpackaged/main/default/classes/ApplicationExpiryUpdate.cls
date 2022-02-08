global class ApplicationExpiryUpdate implements Database.batchable<sObject>,Schedulable, Database.AllowsCallouts {
            
    String query;
    //Set<String> skipLoanStatus = new Set<String>{'funded','Expired','Declined','Decline_Manual_Review','Approved for funding','pre_funding','Expired-Withdrawn'};
    List<String> skipLoanStatus = System.Label.Application_Expired_Status.split(',');
    String CSD;
    Date currentSystemDate;
        
       
    global ApplicationExpiryUpdate(){
       currentSystemDate = (new loan.GlobalLoanUtilFacade().getCurrentSystemDate());
    	CSD = String.valueof(currentSystemDate);
                
    }
    
    global ApplicationExpiryUpdate(String query,Date currentSystemDate){
        
        this.query = query; 
        if(currentSystemDate != null){
            CSD = String.valueof(currentSystemDate);
            this.currentSystemDate = currentSystemDate;
        }else{
            this.currentSystemDate = (new loan.GlobalLoanUtilFacade().getCurrentSystemDate());
        }
    }
    
    global void execute(SchedulableContext sc) {
        
        ApplicationExpiryUpdate b = new ApplicationExpiryUpdate();
        Database.executeBatch(b,1);
    	 /* If you want to executee above batch class for specific expiry date then below is for reference
           String query='SELECT id, Expiry_Date__c, genesis__Status__c,CreatedById, DocuSign_EnvelopeId__c, Expiration_Tag__c,(SELECT id,name,Loan_amount_counteroffer__c FROM Credit_Policy__r WHERE Loan_amount_counteroffer__c>0 LIMIT 1 )FROM genesis__Applications__c WHERE Expiry_Date__c ='+ CSD +' AND genesis__Status__c NOT IN: skipLoanStatus'
		   Date specificdate=String.valueof(date);
           ApplicationExpiryUpdate b = new ApplicationExpiryUpdate(query,specificdate);
           Database.executeBatch(b,1);
         */
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        if(query == null){
            //LOP-270 changed condition to Expiry date <= CSD
        query = 'SELECT id, Expiry_Date__c, genesis__Status__c,CreatedById, DocuSign_EnvelopeId__c, Expiration_Tag__c,(SELECT id,name,Loan_amount_counteroffer__c FROM Credit_Policy__r WHERE Loan_amount_counteroffer__c>0 LIMIT 1 )FROM genesis__Applications__c WHERE Expiry_Date__c <='+ CSD +' AND genesis__Status__c NOT IN: skipLoanStatus';
        }                     
        System.debug('Query'+query);    
        return Database.getQueryLocator(query);
    
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        System.debug('----Method execute(+)scope----'+ scope);
        //System.debug(CSD);
        
        QueueSobject declinedQue;
        QueueSobject expiredQue;
        Manual_Adverse_Action_Decline__c actionDecline;
        try{
            expiredQue = [SELECT queue.id,queue.name,QueueID 
                                            FROM QueueSobject 
                                            WHERE SobjectType ='genesis__Applications__c'                                   
                                            AND queue.Name =: 'Expired Queue'];
        }
        catch(Exception e){
            System.debug('Exception'+ e);
            throw new ints.IntegrationException('Expired Queue is not setup');
        }
        
        try{
            declinedQue = [SELECT queue.id,queue.name,QueueID 
                                            FROM QueueSobject 
                                            WHERE SobjectType ='genesis__Applications__c'                                   
                                            AND queue.Name =: 'Declined'];
        }
        catch(Exception e){
            System.debug('Exception'+ e);
            throw new ints.IntegrationException('Declined Queue is not setup');
        }
        
        try{
            actionDecline = [SELECT id,name 
                             FROM Manual_Adverse_Action_Decline__c 
                             WHERE Decline_Name__c ='insufficient tradeline balance'  ];
        }
        catch(Exception e){
            System.debug('Exception'+ e);
            throw new ints.IntegrationException(' Manual adverse action is not setup');
        }
        List<genesis__Applications__c > listOfApp = (List<genesis__Applications__c >)scope;
        List<genesis__Applications__c > listOfAppTobeUpdated = new List<genesis__Applications__c> ();
        Set<String> appEnvelope = new Set<String>();
        
        Set<String> pre_qual_status = new Set<String>{'pre_qual_collected','partner_pre_qual_shown','partner_offer_estimates',
                                                      'offer_shown','offer_accepted'};
        
        
        Set<String> verification_status = new Set<String>{'loan_details_shown','credit_score_notice_shown','ach_accepted',
            											'kba_disclosure_accepted','kba_success','dcp_accepted','til_accepted',
            										'agent_verification_pending','agent_document_verification_pending','agent_verified'};
        
        Set<String> docs_status = new Set<String>{'hard_inquiry_disclosure_accepted','docusign_loan_docs_sent',
                                     				'docusign_loan_docs_complete', 'pre_funding','funded'};
                
        for(genesis__Applications__c  app : listOfApp){
            if(app.Credit_Policy__r.size()==0){
                
                if((app.Expiry_Date__c != null && app.Expiry_Date__c <= currentSystemDate) && (app.genesis__Status__c != null && app.genesis__Status__c != 'funded')){
               
                    if(pre_qual_status.contains(app.genesis__Status__c)){
                  
                        app.Expiration_Tag__c = 'expired_pre_qual';
                  
                    }else if(verification_status.contains(app.genesis__Status__c)){
                                  
                      app.Expiration_Tag__c = 'expired_verification'; 
                      
                      }else if(docs_status.contains(app.genesis__Status__c) ){
                                       
                          app.Expiration_Tag__c = 'expired_docs';
                      
                      }
                   if(app.DocuSign_EnvelopeId__c != null){
                      System.debug('app.DocuSign_EnvelopeId__c...'+ app.DocuSign_EnvelopeId__c);
                      //appEnvelope.add(app.DocuSign_EnvelopeId__c);
                      SendEnvDocuSignAPI.voidDocuSignEnvelope(app.DocuSign_EnvelopeId__c);
                   }
                   app.genesis__Status__c = 'Expired';
                   app.OwnerId = expiredQue.Queue.Id;
                   //app.OwnerId = app.CreatedById;
                }
            }
            else{
                if(app.Credit_Policy__r.size()>0 && app.Expiry_Date__c != null && app.Expiry_Date__c <= currentSystemDate){  
                   
                    if(pre_qual_status.contains(app.genesis__Status__c)){
                  
                        app.Expiration_Tag__c = 'expired_pre_qual';
                  
                    }else if(verification_status.contains(app.genesis__Status__c)){
                                  
                      app.Expiration_Tag__c = 'expired_verification'; 
                      
                  
                      }else if(docs_status.contains(app.genesis__Status__c)){
                                       
                          app.Expiration_Tag__c = 'expired_docs';
                      
                      }
                   if(app.DocuSign_EnvelopeId__c != null){
                      System.debug('app.DocuSign_EnvelopeId__c...'+ app.DocuSign_EnvelopeId__c);
                      
                      SendEnvDocuSignAPI.voidDocuSignEnvelope(app.DocuSign_EnvelopeId__c);
                   }                
                    
                    app.genesis__Status__c = 'Expired-Withdrawn';
                    app.OwnerId = expiredQue.Queue.Id;                          
                    }
        
            }
            
            listOfAppTobeUpdated.add(app);
            
        }
        
        update listOfAppTobeUpdated ;
    } 
    
    public void finish(Database.BatchableContext BC){

    }
    
}