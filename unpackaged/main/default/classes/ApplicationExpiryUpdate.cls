global class ApplicationExpiryUpdate implements Database.batchable<sObject>,Schedulable, Database.AllowsCallouts {
            
    String query;
    //Set<String> skipLoanStatus = new Set<String>{'Funded','Expired','Approved for funding','pre_funding'};
    List<String> skipLoanStatus = System.Label.Application_Expired_Status.split(',');
    String CSD = String.valueof(new loan.GlobalLoanUtilFacade().getCurrentSystemDate());
    

    Date currentSystemDate = (new loan.GlobalLoanUtilFacade().getCurrentSystemDate());
       
    global ApplicationExpiryUpdate(){
        
        
    query = 'select id, Expiry_Date__c, genesis__Status__c,CreatedById, DocuSign_EnvelopeId__c, Expiration_Tag__c, (select id,name,Loan_amount_counteroffer__c from Credit_Policy__r where Loan_amount_counteroffer__c!=null limit 1 ) from genesis__Applications__c where Expiry_Date__c =' + CSD +' and genesis__Status__c not in : skipLoanStatus';
        
        System.debug(logginglevel.error,'query+++'+query); 
                
    }
    
    global ApplicationExpiryUpdate(String query){
        
        this.query = query; 
    }
    
    global void execute(SchedulableContext sc) {
        
        ApplicationExpiryUpdate b = new ApplicationExpiryUpdate();
        Database.executeBatch(b,1);
    
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
                              
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
            expiredQue = [Select queue.id,queue.name,QueueID 
                                            from QueueSobject 
                                            where SobjectType ='genesis__Applications__c'                                   
                                            AND queue.Name =: 'Expired Queue'];
        }
        catch(Exception e){
            System.debug('Exception'+ e);
            throw new ints.IntegrationException('Expired Queue is not setup');
        }
        
        try{
            declinedQue = [Select queue.id,queue.name,QueueID 
                                            from QueueSobject 
                                            where SobjectType ='genesis__Applications__c'                                   
                                            AND queue.Name =: 'Declined'];
        }
        catch(Exception e){
            System.debug('Exception'+ e);
            throw new ints.IntegrationException('Declined Queue is not setup');
        }
        
        try{
            actionDecline = [Select id,name 
                             from Manual_Adverse_Action_Decline__c 
                             where Decline_Name__c ='insufficient tradeline balance'  ];
        }
        catch(Exception e){
            System.debug('Exception'+ e);
            throw new ints.IntegrationException(' Manual adverse action is not setup');
        }
        List<genesis__Applications__c > listOfApp = (List<genesis__Applications__c >)scope;
        List<genesis__Applications__c > listOfAppTobeUpdated = new List<genesis__Applications__c> ();
        Set<String> appEnvelope = new Set<String>();
                
        for(genesis__Applications__c  app : listOfApp){
            if(app.Credit_Policy__r.size()==0){
                
                if((app.Expiry_Date__c != null && app.Expiry_Date__c == currentSystemDate) && (app.genesis__Status__c != null && app.genesis__Status__c != 'funded')){
               
                    if(app.genesis__Status__c =='pre_qual_collected' ||
                       app.genesis__Status__c =='partner_pre_qual_shown' ||
                       app.genesis__Status__c =='partner_offer_estimates' ||
                       app.genesis__Status__c =='offer_shown' ||
                       app.genesis__Status__c == 'offer_accepted'){
                  
                        app.Expiration_Tag__c = 'expired_pre_qual';
                  
                    }else if(app.genesis__Status__c =='loan_details_shown' ||
                    app.genesis__Status__c =='credit_score_notice_shown' ||
                    app.genesis__Status__c =='ach_accepted' ||
                    app.genesis__Status__c =='kba_disclosure_accepted' ||
                    app.genesis__Status__c == 'kba_success' ||
                    app.genesis__Status__c =='dcp_accepted' ||
                    app.genesis__Status__c =='til_accepted' ||
                    app.genesis__Status__c =='agent_verification_pending' ||
                    app.genesis__Status__c == 'agent_document_verification_pending' ||
                    app.genesis__Status__c == 'agent_verified'){
                                  
                      app.Expiration_Tag__c = 'expired_verification'; 
                      /*Application_DSEnvelope__c dsAppEnv = [select DocuSign_EnvelopeId__c from Application_DSEnvelope__c where Application__C =: app.id LIMIT 1];
                      
                      if(app.DocuSign_EnvelopeId__c != null){
                          System.debug('app.DocuSign_EnvelopeId__c...'+ app.DocuSign_EnvelopeId__c);
                          //appEnvelope.add(app.DocuSign_EnvelopeId__c);
                          SendEnvDocuSignAPI.voidDocuSignEnvelope(app.DocuSign_EnvelopeId__c);
                      }*/
                  
                      }else if(app.genesis__Status__c =='hard_inquiry_disclosure_accepted' ||
                      app.genesis__Status__c =='docusign_loan_docs_sent' ||
                      app.genesis__Status__c =='docusign_loan_docs_complete' ||
                      app.genesis__Status__c =='pre_funding' ||
                      app.genesis__Status__c == 'funded' ){
                                       
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
                if(app.Credit_Policy__r.size()>0 && app.Expiry_Date__c != null && app.Expiry_Date__c == currentSystemDate){  
                    app.genesis__Status__c = 'Expired-Withdrawn';
                    app.OwnerId = expiredQue.Queue.Id;                          
                    }
        /**    else{
                if((app.Expiry_Date__c != null && app.Expiry_Date__c == currentSystemDate)){
                    app.genesis__Status__c = 'Declined';
                    app.OwnerId = declinedQue.Queue.Id;
                    app.Manual_Adverse_Action_Decline__c = actionDecline.id;
                    //app.OwnerId = app.CreatedById;
                    AttachPDFtoApplication.attachPDF(app.id,true,false);
                } 
            } **/
            }
            
            listOfAppTobeUpdated.add(app);
            
        }
        /*if(appEnvelope != null){
            for(String envelopeId : appEnvelope)
                SendEnvDocuSignAPI.voidDocuSignEnvelope(envelopeId);
        }*/
        update listOfAppTobeUpdated ;
    } 
    
    public void finish(Database.BatchableContext BC){

    }
    
}