/***********Modification History**************
* Modified by   Date            JIRA number
* Pallavi         LOS-207         2019-11-21
* Pallavi       2020/11/04      LOP-36/CRM-974(9013 Still flagging for fraud review)
* Old references                LOS-207;LSP-344;
* Vikram       2023/02/06       LPC-333
/********************************************/

public class QueueAssignment{
     @TestVisible
     Private Static boolean KBAFraudT = false,
                        verificationF = false;
     Public Static final Decimal Siftscore = MW_Settings__c.getInstance().Sift_score__c;
     Public Static Decimal Id_Analytics_Score_Threshold = 0;
     
     @invocablemethod()
     Public static void appToQueueAssignment(List<ID> apps){
          for(FraudTagsThreshold__mdt queryRecord : [SELECT Id, QualifiedApiName, Threshold_Value__c, MasterLabel FROM FraudTagsThreshold__mdt]){
               if(queryRecord.QualifiedApiName == 'Id_Analytics_Score')
                    Id_Analytics_Score_Threshold = queryRecord.Threshold_Value__c;
          }
         
          List<Application_Tags__c> lstApplicationTags = new List<Application_Tags__c>();
          String reason = '' ;
          String temp;
          Id appID = apps[0];
              
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
                    //--- Fraud will be True where Sift Score > 98.
                    if(app.Sift_Status__c != null && app.Sift_Status__c > Siftscore) {
                     KBAFraudT = true;
                     reason += 'Sift score '+ '> ' + Siftscore +'.';
                    }
                    //--- Added this condition - app.KBA_Details__r != null && app.KBA_Details__r.size()>0 because Process builder was failing.
                    if(app.KBA_Details__r != null && app.KBA_Details__r.size()>0){
                         KBA_Details__c KBAd = app.KBA_Details__r[0];  
                    
                         //--- Fraud will be true for Precise ID Overall score where score is = 9001     
                         if(KBAd.Precise_ID_Overall_SCore__c != null && KBAd.Precise_ID_Overall_SCore__c == 9001){                        
                              KBAFraudT = true;
                              reason += 'Deceased ' + 'Precise ID Overall Score = 9001. ';
                         }
                         //--- Fraud will be true for Precise ID First Payment Default where score is = 9001    
                         if(KBAd.Precise_ID_First_Payment_Default__c != null && KBAd.Precise_ID_First_Payment_Default__c == 9001){                        
                              KBAFraudT = true;
                              reason += 'Deceased ' + 'Precise ID First Payment Default = 9001. ';
                         }
                         //--- Fraud will be true for Precise ID Validation where score is = 9001    
                         if(KBAd.Precise_ID_Validation__c != null && KBAd.Precise_ID_Validation__c == 9001){                        
                              KBAFraudT = true;
                              reason += 'Deceased ' + 'Precise ID Validation = 9001. ';
                         }
                         //--- Fraud will be teur for Precise ID Overall score where score is less than 0   
                         if(KBAd.Precise_ID_Overall_SCore__c != null && KBAd.Precise_ID_Overall_SCore__c < 0){                        
                              KBAFraudT = true; 
                              reason += 'Precise ID Overall Score < 0. ';
                         }
                         //--- Fraud will be true for Precise ID First Payment Default where score is less than or equal to 10   
                         if(KBAd.Precise_ID_First_Payment_Default__c != null && KBAd.Precise_ID_First_Payment_Default__c <=10){                        
                              KBAFraudT = true;
                              reason += 'Precise ID First Payment Default <= 10. ';
                         }
                         //--- Fraud will be true for Precise ID ID Theft where score is less than 0    
                         if(KBAd.Precise_ID_ID_Theft__c != null && KBAd.Precise_ID_ID_Theft__c < 0){                        
                              KBAFraudT = true;
                              reason += 'Precise ID ID Theft < 0. ';
                         }
                         //--- Fraud will be true for Precise ID Validation where score is less than 0     
                         if(KBAd.Precise_ID_Validation__c != null && KBAd.Precise_ID_Validation__c < 0){                        
                              KBAFraudT = true;
                              reason += 'Precise ID Validation < 0. ';
                         }
                         //--- Fraud will be true for Precise Id General Fraud Shield Indicat where score is = F05 (equalsIgnoreCase)    
                         if(KBAd.Precise_ID_General_Fraud_Shield_Indicat__c != null && KBAd.Precise_ID_General_Fraud_Shield_Indicat__c.equalsIgnoreCase('F05')){                        
                              KBAFraudT = true;
                              reason += 'Precise ID Fraud Shield = F05. ';
                         }
                         //--- Fraud will be true for Paste Count where score is equql to or greater than 2  
                         if(KBAd.Paste_Count__c >= 2){                        
                              KBAFraudT = true;
                              reason += 'Paste Count >= 2. ';
                         }
                         //--- Fraud will be true for ID Analytic Score where score is equal to or greater than 675   
                         if(KBAd.Id_Analytics_Score__c != null && KBAd.Id_Analytics_Score__c >= Id_Analytics_Score_Threshold) {
                              KBAFraudT = true;
                              reason += 'IDA Score >= ' + Id_Analytics_Score_Threshold + '. ';
                         }        
                    } // end of if(app.KBA_Details__r != null && app.KBA_Details__r.size()>0)
                 
                    if(app.Identity_Verifications__r != null && app.Identity_Verifications__r.size()>0){
                         if(app.Identity_Verifications__r[0].IDMV_Status__c != null &&
                           app.Identity_Verifications__r[0].IDMV_Status__c == 'Initial Fraud Alert'){                       
                              reason += 'IDMV Status = Initial Fraud Alert. ';                
                              verificationF = true;                            
                         }
                        
                         if (app.Identity_Verifications__r[0].IDMV_Status__c != null &&
                            app.Identity_Verifications__r[0].IDMV_Status__c == 'Consumer Statement Bureau'){                       
                            reason +=  'IDMV Status = Consumer Statement Bureau. ';
                            verificationF = true;
                         }
                        
                         if (app.Identity_Verifications__r[0].IDMA_Status__c != null &&
                            app.Identity_Verifications__r[0].IDMA_Status__c == 'Initial Fraud Alert'){                       
                            reason +=  'IDMA Status = Initial Fraud Alert. ';
                            verificationF = true;
                         }
                        
                         if (app.Identity_Verifications__r[0].IDMA_Status__c != null &&
                            app.Identity_Verifications__r[0].IDMA_Status__c == 'Consumer Statement Bureau'){                       
                            reason +=  'IDMA Status = Consumer Statement Bureau. ';                   
                            verificationF = true;                                                   
                         }
                    }
             
                    List<Application_Tags__c> lstAppTags = [SELECT id,Application_Tag__c,softDelete__c FROM Application_Tags__c where Application__c = :app.Id and Application_Tag__c = 'Fraud' and softDelete__c = false];        
                    if(KBAFraudT || verificationF){
                         if(lstAppTags.isEmpty()){                           
                             Application_Tags__c appTags = new Application_Tags__c();
                             appTags.Application__c = app.Id;
                             appTags.Application_Tag__c = 'Fraud';
                             lstApplicationTags.add(appTags);
                         }
                    }
                    else{
                         if(!lstAppTags.isEmpty()){
                              for(Application_Tags__c appTag : lstAppTags)
                                   appTag.softDelete__c = true;
                              update lstAppTags;
                         }
                    }
                    
                    app.Fraud_Assignment_Reason__c = reason;
               } //end of for(genesis__Applications__c app : appList){
          } // end of if(appList != null && appList.size() > 0){
         
          update appList;
          
          //return 'Assigned to Queue';
          if(!lstApplicationTags.isEmpty() && lstApplicationTags.size()>0){
               System.debug('not empty----' + lstApplicationTags.size());
               insert lstApplicationTags;
         }
     } //end of Public static void appToQueueAssignment(List<ID> apps){
} //end of public class QueueAssignment{