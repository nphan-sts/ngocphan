/***********Modification History**************
Pallavi			LOS-207			2019-11-21
* Modified by   Date            JIRA number
* Pallavi		2020/11/04		LOP-36/CRM-974(9013 Still flagging for fraud review)
/********************************************/

public class QueueAssignment{
    Private Static boolean KBAFraudT = false,
                           verificationF = false;
    
    @invocablemethod()
    Public static void appToQueueAssignment(List<ID> apps){
        List<Application_Tags__c> lstApplicationTags = new List<Application_Tags__c>();
        String reason = '' ;
        String temp;
        Id appID = apps[0];  
             
        List<QueueSobject> FundingQueue = [SELECT Queue.Id,queue.Name, QueueId FROM QueueSobject 
                                            WHERE SobjectType = 'genesis__Applications__c' 
                                            AND queue.DeveloperName =: 'Pre_Funding_Queue'];    
        
            
        List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
        
        appList = [select id,name,Sift_Status__c,
                            Affiliate_Partner__c,                               
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
                       

                //--- Fraud Tag 30.01.2018
                // -- added this condition - app.KBA_Details__r != null && app.KBA_Details__r.size()>0 because Process builder was failing.
                if((app.Sift_Status__c != null && app.Sift_Status__c > 80) ||
                 
                ((app.KBA_Details__r != null && app.KBA_Details__r.size()>0) && 
                  ((app.KBA_Details__r[0].Precise_ID_Overall_SCore__c != null && app.KBA_Details__r[0].Precise_ID_Overall_SCore__c < 0) ||
                  (app.KBA_Details__r[0].Precise_ID_First_Payment_Default__c != null && (app.KBA_Details__r[0].Precise_ID_First_Payment_Default__c == 9001 || app.KBA_Details__r[0].Precise_ID_First_Payment_Default__c == 9013)) ||
                  (app.KBA_Details__r[0].Precise_ID_ID_Theft__c != null && (app.KBA_Details__r[0].Precise_ID_ID_Theft__c == 9001 || app.KBA_Details__r[0].Precise_ID_ID_Theft__c == 9013)) ||
                  (app.KBA_Details__r[0].Precise_ID_Validation__c != null && (app.KBA_Details__r[0].Precise_ID_Validation__c == 9001 || app.KBA_Details__r[0].Precise_ID_Validation__c == 9013)) ||
                  (app.KBA_Details__r[0].Precise_ID_Overall_SCore__c != null && (app.KBA_Details__r[0].Precise_ID_Overall_SCore__c == 9001 || app.KBA_Details__r[0].Precise_ID_Overall_SCore__c == 9013)) || 
                  (app.KBA_Details__r[0].Precise_ID_First_Payment_Default__c != null && app.KBA_Details__r[0].Precise_ID_First_Payment_Default__c < 0) || 
                  (app.KBA_Details__r[0].Precise_ID_ID_Theft__c != null && app.KBA_Details__r[0].Precise_ID_ID_Theft__c < 0) || 
                  (app.KBA_Details__r[0].Precise_ID_Validation__c != null && app.KBA_Details__r[0].Precise_ID_Validation__c < 0) || 
                  (app.KBA_Details__r[0].Precise_ID_General_Fraud_Shield_Indicat__c != null && app.KBA_Details__r[0].Precise_ID_General_Fraud_Shield_Indicat__c.equalsIgnoreCase('F05')) ||
                  (app.KBA_Details__r[0].Paste_Count__c != null && app.KBA_Details__r[0].Paste_Count__c >= 2) ||
                  (app.KBA_Details__r[0].Id_Analytics_Score__c != null && app.Affiliate_Partner__c && app.KBA_Details__r[0].Id_Analytics_Score__c >= 750) ||
                  (app.KBA_Details__r[0].Id_Analytics_Score__c != null && !app.Affiliate_Partner__c && app.KBA_Details__r[0].Id_Analytics_Score__c >= 700)))){
                    
                    KBAFraudT = true;
                } 
               //--- Set Fraud Reason for valid Fraud Tags
               if (KBAFraudT){
                   if(app.Sift_Status__c != null && app.Sift_Status__c > 80){                        
                            reason += 'Sift score > 80. ';}
                   if(app.KBA_Details__r != null && app.KBA_Details__r.size()>0){	//pallavi(desk id 18882/LOS-207)
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
                       if(app.Affiliate_Partner__c && app.KBA_Details__r[0].Id_Analytics_Score__c >= 750){                        
                                reason += 'IDA Score >= 750. ';}
                       if(!app.Affiliate_Partner__c && app.KBA_Details__r[0].Id_Analytics_Score__c >= 700){                        
                                reason += 'IDA Score >= 700. ';}
                   }	//pallavi(desk id 18882/LOS-127)
                   
               } 
                
                //--   
               if(app.Identity_Verifications__r != null && app.Identity_Verifications__r.size()>0){   
                   
                   /*if(app.Identity_Verifications__r[0].IDMA_Status__c != null ||
                   app.Identity_Verifications__r[0].IDMA_Status__c != null){*/		//pallavi(desk id 18882/LOS-207)(commented)
                   
                       if(app.Identity_Verifications__r[0].IDMV_Status__c != null &&	//pallavi(desk id 18882)
                          app.Identity_Verifications__r[0].IDMV_Status__c == 'Initial Fraud Alert'){                       
                           reason += 'IDMV Status = Initial Fraud Alert. ';
                           System.debug(logginglevel.error,'REASON : '+reason );
                           verificationF = true;
                           
                       }
                       
                       if (app.Identity_Verifications__r[0].IDMV_Status__c != null &&	//pallavi(desk id 18882/LOS-207)
                           app.Identity_Verifications__r[0].IDMV_Status__c == 'Consumer Statement Bureau'){                       
                           reason +=  'IDMV Status = Consumer Statement Bureau. ';
                           System.debug(logginglevel.error,'REASON : '+reason );
                           verificationF = true;
                                              
                       }
                       
                       if (app.Identity_Verifications__r[0].IDMA_Status__c != null &&	//pallavi(desk id 18882/LOS-207)
                           app.Identity_Verifications__r[0].IDMA_Status__c == 'Initial Fraud Alert'){                       
                           reason +=  'IDMA Status = Initial Fraud Alert. ';
                           System.debug(logginglevel.error,'REASON : '+reason );
                           verificationF = true;
                                              
                       }
                       
                       if (app.Identity_Verifications__r[0].IDMA_Status__c != null &&	//pallavi(desk id 18882/LOS-207)
                           app.Identity_Verifications__r[0].IDMA_Status__c == 'Consumer Statement Bureau'){                       
                           reason +=  'IDMA Status = Consumer Statement Bureau. ';
                           System.debug(logginglevel.error,'REASON : '+reason );
                           verificationF = true;
                                                                           
                       }
                       
                       
                   //}
               }
            
               List<Application_Tags__c> lstAppTags = [SELECT id,Application_Tag__c,softDelete__c FROM Application_Tags__c where Application__c = :app.Id and Application_Tag__c = 'Fraud' and softDelete__c = false];	//CRM-974        
               if(KBAFraudT || verificationF){
                   //List<Application_Tags__c> lstAppTags = [SELECT Application_Tag__c FROM Application_Tags__c where Application__c = :app.Id and Application_Tag__c LIKE '%Fraud%' and softDelete__c = false];	//pallavi LOS-212(added softDelete) //CRM-974(commented the query)
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
        if(!lstApplicationTags.isEmpty() && lstApplicationTags.size()>0){	//pallavi(desk id 18882/LOS-207)
        System.debug('not empty----' + lstApplicationTags.size());
        insert lstApplicationTags;
        }
           
    }

}
