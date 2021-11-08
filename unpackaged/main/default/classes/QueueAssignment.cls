/***********Modification History**************
Pallavi         LOS-207         2019-11-21
* Modified by   Date            JIRA number
* Pallavi       2020/11/04      LOP-36/CRM-974(9013 Still flagging for fraud review)
/********************************************/

public class QueueAssignment{
    Private Static boolean KBAFraudT = false,
                       verificationF = false;
    Private Static Set<String> UTM_SOCIAL_MEDIUM = new Set<String>{'OrganicSocial','psocial-cq','psocial-dm','psocial-rm'}; //LSP-344
    Private Static Set<String> UTM_CREDIT_KARMA_NON_PRIORITY = new Set<String>{'p1','p2','p3'}; //LSP-344
    Public Static final Decimal Siftscore = MW_Settings__c.getInstance().Sift_score__c;
    
    @invocablemethod()
    Public static void appToQueueAssignment(List<ID> apps){
        List<Application_Tags__c> lstApplicationTags = new List<Application_Tags__c>();
        String reason = '' ;
        String temp;
        Id appID = apps[0];
        //Decimal mwsetting = MW_Settings__c.getInstance().Sift_score__c;
             
        List<QueueSobject> FundingQueue = [SELECT Queue.Id,queue.Name, QueueId FROM QueueSobject 
                                            WHERE SobjectType = 'genesis__Applications__c' 
                                            AND queue.DeveloperName =: 'Pre_Funding_Queue'];    
        
            
        List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
        
        appList = [select id,name,Sift_Status__c,
                            Affiliate_Partner__c, utm_medium__c, utm_source__c,                              
                         (select id,Application__c,Precise_ID_Overall_SCore__c,
                                 Precise_ID_First_Payment_Default__c,
                                 Precise_ID_ID_Theft__c,
                                 Precise_ID_Validation__c,
                                 Precise_ID_General_Fraud_Shield_Indicat__c,
                                 Paste_Count__c,
                                 Precise_ID_Adverse_Action_Code__c,
                                 Id_Analytics_Score__c,
                                 KBA_Attempts__c
                                 from KBA_Details__r order by createddate desc limit 1),
                         (select id,name, 
                                  IDMV_Status__c,
                                  IDMA_Status__c,
                                  Identity_Verification__c,
                                  Bank_Verification_Flag__c,
                                  Deal_room_Verification_Flag__c,
                                  Income_Verification_Flag__c,
                                  KBA_Verification_Flag__c,
                                  Credit_Policy_Verification_Flag__c,
                                  Neo_Verification_Flag__c
                                  from Identity_Verifications__r order by createddate desc limit 1)        
                         from genesis__Applications__c where id =: appID];       
        
        if(appList != null && appList.size() > 0){                                          
            for(genesis__Applications__c app : appList){ 
                 //--- Fraud Tag 30.01.2018 //LSP-344
                // -- added this condition - app.KBA_Details__r != null && app.KBA_Details__r.size()>0 because Process builder was failing.
                if((app.Sift_Status__c != null && app.Sift_Status__c > Siftscore && app.utm_medium__c != 'DM' && app.utm_medium__c != 'Email' 
                    && !UTM_SOCIAL_MEDIUM.contains(app.utm_medium__c) && app.utm_medium__c != 'partner' && !UTM_CREDIT_KARMA_NON_PRIORITY.contains(app.utm_medium__c) && app.utm_source__c !='creditkarma' && app.utm_source__c!='creditkarma_lightbox') ||
                ((app.KBA_Details__r != null && app.KBA_Details__r.size()>0) &&
                 ((app.utm_medium__c == 'DM' || app.utm_medium__c == 'Email' || 
                  UTM_SOCIAL_MEDIUM.contains(app.utm_medium__c)) 
                  && (app.Sift_Status__c > Siftscore || app.KBA_Details__r[0].Id_Analytics_Score__c >= 725)) ||
                 (((app.utm_medium__c == 'partner' || UTM_CREDIT_KARMA_NON_PRIORITY.contains(app.utm_medium__c)) && (app.utm_source__c =='creditkarma' || 
          app.utm_source__c =='creditkarma_lightbox') && 
                   (app.Sift_Status__c > Siftscore || app.KBA_Details__r[0].Id_Analytics_Score__c >= 800)))
                   || (String.IsBlank(app.utm_medium__c) && (app.utm_source__c =='creditkarma' || 
          app.utm_source__c =='creditkarma_lightbox') 
                       && (app.Sift_Status__c > Siftscore || app.KBA_Details__r[0].Id_Analytics_Score__c >= 800))
                   || 
                  ((app.KBA_Details__r != null && app.KBA_Details__r.size()>0) && ((app.KBA_Details__r[0].Precise_ID_Overall_SCore__c != null && app.KBA_Details__r[0].Precise_ID_Overall_SCore__c < 0) ||
                  (app.KBA_Details__r[0].Precise_ID_First_Payment_Default__c != null && (app.KBA_Details__r[0].Precise_ID_First_Payment_Default__c == 9001 || app.KBA_Details__r[0].Precise_ID_First_Payment_Default__c == 9013)) ||
                  (app.KBA_Details__r[0].Precise_ID_ID_Theft__c != null && (app.KBA_Details__r[0].Precise_ID_ID_Theft__c == 9001 || app.KBA_Details__r[0].Precise_ID_ID_Theft__c == 9013)) ||
                  (app.KBA_Details__r[0].Precise_ID_Validation__c != null && (app.KBA_Details__r[0].Precise_ID_Validation__c == 9001 || app.KBA_Details__r[0].Precise_ID_Validation__c == 9013)) ||
                  (app.KBA_Details__r[0].Precise_ID_Overall_SCore__c != null && (app.KBA_Details__r[0].Precise_ID_Overall_SCore__c == 9001 || app.KBA_Details__r[0].Precise_ID_Overall_SCore__c == 9013)) || 
                  (app.KBA_Details__r[0].Precise_ID_First_Payment_Default__c != null && app.KBA_Details__r[0].Precise_ID_First_Payment_Default__c < 0) || 
                  (app.KBA_Details__r[0].Precise_ID_ID_Theft__c != null && app.KBA_Details__r[0].Precise_ID_ID_Theft__c < 0) || 
                  (app.KBA_Details__r[0].Precise_ID_Validation__c != null && app.KBA_Details__r[0].Precise_ID_Validation__c < 0) || 
                  (app.KBA_Details__r[0].Precise_ID_General_Fraud_Shield_Indicat__c != null && app.KBA_Details__r[0].Precise_ID_General_Fraud_Shield_Indicat__c.equalsIgnoreCase('F05')) ||
                  (app.KBA_Details__r[0].Paste_Count__c != null && app.KBA_Details__r[0].Paste_Count__c >= 2) ||
                  (app.KBA_Details__r[0].Id_Analytics_Score__c != null && app.Affiliate_Partner__c && app.KBA_Details__r[0].Id_Analytics_Score__c >= 750 && app.utm_medium__c != 'DM' && app.utm_medium__c != 'Email' 
                    && !UTM_SOCIAL_MEDIUM.contains(app.utm_medium__c) && app.utm_medium__c != 'partner' && !UTM_CREDIT_KARMA_NON_PRIORITY.contains(app.utm_medium__c) && app.utm_source__c !='creditkarma' && app.utm_source__c!='creditkarma_lightbox') ||
                  (app.KBA_Details__r[0].Id_Analytics_Score__c != null && !app.Affiliate_Partner__c && app.KBA_Details__r[0].Id_Analytics_Score__c >= 700 && app.utm_medium__c != 'DM' && app.utm_medium__c != 'Email' 
                    && !UTM_SOCIAL_MEDIUM.contains(app.utm_medium__c) && app.utm_medium__c != 'partner' && !UTM_CREDIT_KARMA_NON_PRIORITY.contains(app.utm_medium__c) && app.utm_source__c !='creditkarma' && app.utm_source__c!='creditkarma_lightbox'))))){
                    
                    KBAFraudT = true;
                } 
               //--- Set Fraud Reason for valid Fraud Tags
               if (KBAFraudT){
                   if(app.Sift_Status__c != null && app.Sift_Status__c > Siftscore && app.utm_medium__c != 'DM' && app.utm_medium__c != 'Email' 
                   && !UTM_SOCIAL_MEDIUM.contains(app.utm_medium__c) && app.utm_medium__c != 'partner' && !UTM_CREDIT_KARMA_NON_PRIORITY.contains(app.utm_medium__c) && app.utm_source__c !='creditkarma' && app.utm_source__c!='creditkarma_lightbox'){                        
                            reason += 'Sift score '+ '> ' + Siftscore +'.';}
                   
                        if(app.KBA_Details__r != null && app.KBA_Details__r.size()>0){   //pallavi(desk id 18882/LOS-207)
                        if(app.Sift_Status__c >= Siftscore && (app.utm_medium__c == 'DM' || app.utm_medium__c == 'Email' ||
                          UTM_SOCIAL_MEDIUM.contains(app.utm_medium__c))){ 
                          
                             reason += 'utm_medium '+ app.utm_medium__c + ' Sift score '+ '> ' + Siftscore +'.';}
                         
                        if(app.Sift_Status__c > Siftscore && (app.utm_medium__c == 'partner' || UTM_CREDIT_KARMA_NON_PRIORITY.contains(app.utm_medium__c) && (app.utm_source__c =='creditkarma' || app.utm_source__c =='creditkarma_lightbox'))){
                                
                            reason += 'utm_medium '+ app.utm_medium__c + ' And ' + ' utm_sousce ' + app.utm_source__c + ' Sift score '+ '> ' + Siftscore +'.';}
                            if(app.Sift_Status__c > Siftscore && (String.IsBlank(app.utm_medium__c) && (app.utm_source__c =='creditkarma' || 
          app.utm_source__c =='creditkarma_lightbox'))){
                               
                                reason += 'utm_medium ' + app.utm_medium__c + ' utm_source '+ app.utm_source__c + ' Sift score '+ '> ' + Siftscore +'.';}
                               
                          
                        if(app.KBA_Details__r[0].Id_Analytics_Score__c >=725 && (app.utm_medium__c == 'DM' || app.utm_medium__c == 'Email' || 
                           UTM_SOCIAL_MEDIUM.contains(app.utm_medium__c))){
                                reason += 'utm_medium '+ app.utm_medium__c + ' IDA Score >= 725.';}
                         
                      
                       if (app.KBA_Details__r[0].Id_Analytics_Score__c >= 800 && (app.utm_medium__c == 'partner' || UTM_CREDIT_KARMA_NON_PRIORITY.contains(app.utm_medium__c) && (app.utm_source__c =='creditkarma' || app.utm_source__c =='creditkarma_lightbox'))){
                           reason += 'utm_medium '+ app.utm_medium__c + ' And ' + ' utm_source ' + app.utm_source__c + ' IDA Score >= 800.';}
                       if(app.KBA_Details__r[0].Id_Analytics_Score__c >=800 && (String.IsBlank(app.utm_medium__c) && (app.utm_source__c =='creditkarma' || 
                                                                                                                      app.utm_source__c =='creditkarma_lightbox'))){
                                                reason += 'utm_medium ' + app.utm_medium__c + ' utm_source '+ app.utm_source__c + ' IDA Score>= 800.';}                                                                           
                  
                       if(app.KBA_Details__r[0].Precise_ID_Overall_SCore__c != null && app.KBA_Details__r[0].Precise_ID_Overall_SCore__c == 9013){                        
                                reason += 'Blocked/frozen ' + 'Precise ID Overall Score = 9013. ';}                        
                       if (app.KBA_Details__r[0].Precise_ID_First_Payment_Default__c != null && app.KBA_Details__r[0].Precise_ID_First_Payment_Default__c == 9013){                        
                                reason += 'Blocked/frozen '+ 'Precise ID First Payment Default = 9013. ';}                        
                       if (app.KBA_Details__r[0].Precise_ID_ID_Theft__c != null && app.KBA_Details__r[0].Precise_ID_ID_Theft__c == 9013){                        
                                reason += 'Blocked/frozen ' + 'Precise ID theft = 9013. ';}                        
                       if(app.KBA_Details__r[0].Precise_ID_Validation__c != null && app.KBA_Details__r[0].Precise_ID_Validation__c == 9013){                        
                                reason += 'Blocked/frozen ' + 'Precise ID Validation = 9013. ';}                        
                       if(app.KBA_Details__r[0].Precise_ID_Overall_SCore__c != null && app.KBA_Details__r[0].Precise_ID_Overall_SCore__c == 9001){                        
                                reason += 'Deceased ' + 'Precise ID Overall Score = 9001. ';}                        
                       if(app.KBA_Details__r[0].Precise_ID_First_Payment_Default__c != null && app.KBA_Details__r[0].Precise_ID_First_Payment_Default__c == 9001){                        
                                reason += 'Deceased ' + 'Precise ID First Payment Default = 9001. ';}                        
                       if(app.KBA_Details__r[0].Precise_ID_ID_Theft__c != null && app.KBA_Details__r[0].Precise_ID_ID_Theft__c == 9001){                        
                                reason += 'Deceased ' + 'Precise ID theft = 9001. ';}                        
                       if(app.KBA_Details__r[0].Precise_ID_Validation__c != null && app.KBA_Details__r[0].Precise_ID_Validation__c == 9001){                        
                                reason += 'Deceased ' + 'Precise ID Validation = 9001. ';}         
                       if(app.KBA_Details__r[0].Precise_ID_Overall_SCore__c != null && app.KBA_Details__r[0].Precise_ID_Overall_SCore__c < 0){                        
                                reason += 'Precise ID Overall Score < 0. ';}
                       if(app.KBA_Details__r[0].Precise_ID_First_Payment_Default__c != null && app.KBA_Details__r[0].Precise_ID_First_Payment_Default__c < 0){                        
                                reason += 'Precise ID First Payment Default < 0. ';}
                       if(app.KBA_Details__r[0].Precise_ID_ID_Theft__c != null && app.KBA_Details__r[0].Precise_ID_ID_Theft__c < 0){                        
                                reason += 'Precise ID ID Theft < 0. ';}
                       if(app.KBA_Details__r[0].Precise_ID_Validation__c != null && app.KBA_Details__r[0].Precise_ID_Validation__c < 0){                        
                                reason += 'Precise ID Validation < 0. ';}
                       if(app.KBA_Details__r[0].Precise_ID_General_Fraud_Shield_Indicat__c != null && app.KBA_Details__r[0].Precise_ID_General_Fraud_Shield_Indicat__c.equalsIgnoreCase('F05')){                        
                                reason += 'Precise ID Fraud Shield = F05. ';}
                       if(app.KBA_Details__r[0].Paste_Count__c >= 2){                        
                                reason += 'Paste Count >= 2. ';}
                       if(app.Affiliate_Partner__c && app.KBA_Details__r[0].Id_Analytics_Score__c >= 750 && app.utm_medium__c != 'DM' && app.utm_medium__c != 'Email' 
                    && !UTM_SOCIAL_MEDIUM.contains(app.utm_medium__c) && app.utm_medium__c != 'partner' && !UTM_CREDIT_KARMA_NON_PRIORITY.contains(app.utm_medium__c) && app.utm_source__c !='creditkarma' && app.utm_source__c!='creditkarma_lightbox') {                        
                                reason += 'IDA Score >= 750. ';}
                       if(!app.Affiliate_Partner__c && app.KBA_Details__r[0].Id_Analytics_Score__c >= 700 && app.utm_medium__c != 'DM' && app.utm_medium__c != 'Email' 
                    && !UTM_SOCIAL_MEDIUM.contains(app.utm_medium__c) && app.utm_medium__c != 'partner' && !UTM_CREDIT_KARMA_NON_PRIORITY.contains(app.utm_medium__c) && app.utm_source__c !='creditkarma' && app.utm_source__c!='creditkarma_lightbox') {                        
                                reason += 'IDA Score >= 700. ';}
                   }    //pallavi(desk id 18882/LOS-127)
                   
               } 
                
                //--   
               if(app.Identity_Verifications__r != null && app.Identity_Verifications__r.size()>0){   
                   
                   /*if(app.Identity_Verifications__r[0].IDMA_Status__c != null ||
                   app.Identity_Verifications__r[0].IDMA_Status__c != null){*/      //pallavi(desk id 18882/LOS-207)(commented)
                   
                       if(app.Identity_Verifications__r[0].IDMV_Status__c != null &&    //pallavi(desk id 18882)
                          app.Identity_Verifications__r[0].IDMV_Status__c == 'Initial Fraud Alert'){                       
                           reason += 'IDMV Status = Initial Fraud Alert. ';
                           System.debug(logginglevel.error,'REASON : '+reason );
                           verificationF = true;
                           
                       }
                       
                       if (app.Identity_Verifications__r[0].IDMV_Status__c != null &&   //pallavi(desk id 18882/LOS-207)
                           app.Identity_Verifications__r[0].IDMV_Status__c == 'Consumer Statement Bureau'){                       
                           reason +=  'IDMV Status = Consumer Statement Bureau. ';
                           System.debug(logginglevel.error,'REASON : '+reason );
                           verificationF = true;
                                              
                       }
                       
                       if (app.Identity_Verifications__r[0].IDMA_Status__c != null &&   //pallavi(desk id 18882/LOS-207)
                           app.Identity_Verifications__r[0].IDMA_Status__c == 'Initial Fraud Alert'){                       
                           reason +=  'IDMA Status = Initial Fraud Alert. ';
                           System.debug(logginglevel.error,'REASON : '+reason );
                           verificationF = true;
                                              
                       }
                       
                       if (app.Identity_Verifications__r[0].IDMA_Status__c != null &&   //pallavi(desk id 18882/LOS-207)
                           app.Identity_Verifications__r[0].IDMA_Status__c == 'Consumer Statement Bureau'){                       
                           reason +=  'IDMA Status = Consumer Statement Bureau. ';
                           System.debug(logginglevel.error,'REASON : '+reason );
                           verificationF = true;
                                                                           
                       }
                       
                       
                   //}
               }
            
               List<Application_Tags__c> lstAppTags = [SELECT id,Application_Tag__c,softDelete__c FROM Application_Tags__c where Application__c = :app.Id and Application_Tag__c = 'Fraud' and softDelete__c = false];  //CRM-974        
               if(KBAFraudT || verificationF){
                   //List<Application_Tags__c> lstAppTags = [SELECT Application_Tag__c FROM Application_Tags__c where Application__c = :app.Id and Application_Tag__c LIKE '%Fraud%' and softDelete__c = false];    //pallavi LOS-212(added softDelete) //CRM-974(commented the query)
                        if(lstAppTags.isEmpty()){                           
                            Application_Tags__c appTags = new Application_Tags__c();
                            appTags.Application__c = app.Id;
                            appTags.Application_Tag__c = 'Fraud';
                            lstApplicationTags.add(appTags);
                            
                        }
                }
                //CRM-974
                else{
                    if(!lstAppTags.isEmpty()){
                        for(Application_Tags__c appTag : lstAppTags)
                            appTag.softDelete__c = true;
                        update lstAppTags;
                    }
                }
                //CRM-974
                app.Fraud_Assignment_Reason__c = reason;
           }
        }
        
      update appList;  
     //return 'Assigned to Queue';
        if(!lstApplicationTags.isEmpty() && lstApplicationTags.size()>0){   //pallavi(desk id 18882/LOS-207)
        System.debug('not empty----' + lstApplicationTags.size());
        insert lstApplicationTags;
        }
           
    }

}