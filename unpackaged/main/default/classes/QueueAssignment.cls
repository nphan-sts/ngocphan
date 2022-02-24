/***********Modification History**************
Pallavi         LOS-207         2019-11-21
* Modified by   Date            JIRA number
* Pallavi       2020/11/04      LOP-36/CRM-974(9013 Still flagging for fraud review)
/********************************************/

public class QueueAssignment{
    @TestVisible
    Private Static boolean KBAFraudT = false,
                       verificationF = false;
    Private Static Set<String> UTM_SOCIAL_MEDIUM = new Set<String>{'OrganicSocial','psocial-cq','psocial-dm','psocial-rm'}; //LSP-344
    Private Static Set<String> UTM_CREDIT_KARMA_NON_PRIORITY = new Set<String>{'p1','p2','p3'}; //LSP-344
    Public Static final Decimal Siftscore = MW_Settings__c.getInstance().Sift_score__c;
    Public Static final integer PIS = 9001; 
    Public Static final string FRAUDSHEILD = 'F05';
    Public Static final string UTM_MEDIUM = 'utm_medium';
    
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
                //--- Fraud will be True where Sift Score > 98.
                if(app.Sift_Status__c != null && app.Sift_Status__c > Siftscore) {
                    KBAFraudT = true;
                    reason += 'Sift score > ' + Siftscore +'.';
                }
                //--- Added this condition - app.KBA_Details__r != null && app.KBA_Details__r.size()>0 because Process builder was failing.
                if(app.KBA_Details__r != null && app.KBA_Details__r.size()>0){
                KBA_Details__c KBAd = app.KBA_Details__r[0];  
                
                //--- Fraud will be true for Precise ID Overall score where score is = 9001     
                if(KBAd.Precise_ID_Overall_SCore__c != null && KBAd.Precise_ID_Overall_SCore__c == PIS){                        
                     KBAFraudT = true;
                     reason += 'Deceased Precise ID Overall Score = ' + PIS +'. ';
                }
                //--- Fraud will be true for Precise ID First Payment Default where score is = 9001    
                if(KBAd.Precise_ID_First_Payment_Default__c != null && KBAd.Precise_ID_First_Payment_Default__c == PIS){                        
                     KBAFraudT = true;
                     reason += 'Deceased Precise ID First Payment Default ' + PIS +'. ';
                }
                //--- Fraud will be true for Precise ID Validation where score is = 9001    
                if(KBAd.Precise_ID_Validation__c != null && KBAd.Precise_ID_Validation__c == PIS){                        
                     KBAFraudT = true;
                     reason += 'Deceased Precise ID Validation = ' + PIS +'. ';
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
                if(KBAd.Precise_ID_General_Fraud_Shield_Indicat__c != null && KBAd.Precise_ID_General_Fraud_Shield_Indicat__c.equalsIgnoreCase(FRAUDSHEILD)){                        
                     KBAFraudT = true;
                     reason += 'Precise ID Fraud Shield ' + FRAUDSHEILD + '. ';
                }
                //--- Fraud will be true for Paste Count where score is equql to or greater than 2  
                if(KBAd.Paste_Count__c >= 2){                        
                     KBAFraudT = true;
                     reason += 'Paste Count >= 2. ';
                }
                //--- Fraud will be True for utm_medium = DM or Email or OrganicSocial, psocial-cq, psocial-dm, psocial-rm where ID Analytic Score >= 725    
                if((app.utm_medium__c == 'DM' || app.utm_medium__c == 'Email' || UTM_SOCIAL_MEDIUM.contains(app.utm_medium__c)) 
                     && KBAd.Id_Analytics_Score__c >= 725) {
                     KBAFraudT = true;
                     reason += UTM_MEDIUM + ' '+ app.utm_medium__c + ' IDA Score >= 725 .';
                }
                //--- Fraud will be true for utm_medium = partner or p1,p2,p3 and utm_source = creditkarma or creditkarma lightbox where ID analytic score is >= 800     
                else if(((app.utm_medium__c == 'partner' || UTM_CREDIT_KARMA_NON_PRIORITY.contains(app.utm_medium__c)) 
                     && (app.utm_source__c =='creditkarma' || app.utm_source__c =='creditkarma_lightbox')) && 
                        (KBAd.Id_Analytics_Score__c >= 800)){
                     KBAFraudT = true;
                     reason += UTM_MEDIUM + ' '+ app.utm_medium__c + ' And  utm_source ' + app.utm_source__c + ' IDA Score >= 800 .'; 
                }
                //--- Fraud will be true for utm_medium = null and utm source = creditkarma or creditkarma lightbox where ID Analytics score is >= 800  
                else if((String.IsBlank(app.utm_medium__c) && (app.utm_source__c =='creditkarma' || app.utm_source__c =='creditkarma_lightbox') 
                     && (KBAd.Id_Analytics_Score__c >= 800))) {
                     KBAFraudT = true;
                     reason += UTM_MEDIUM + ' '+ app.utm_medium__c + ' And  utm_source ' + app.utm_source__c + ' IDA Score >= 800 .'; 
                }
                //--- Fraud will be true for ID Analytic Score where score is equal to or greater than 750 (For Affiliate/Non Affilate Partner)   
                else if((KBAd.Id_Analytics_Score__c != null && KBAd.Id_Analytics_Score__c >= 750 )
                     && ((app.Affiliate_Partner__c && app.utm_source__c !='creditkarma')|| (!app.Affiliate_Partner__c && app.utm_source__c !='creditkarma_lightbox'))) {
                     KBAFraudT = true;
                     reason += 'IDA Score >= 750. ';
                }
                //--- Fraud will be true for ID Analytic Score where score is equal to or greater than 700 (For Non-Affiliate Partner)    
                else if(KBAd.Id_Analytics_Score__c != null && !app.Affiliate_Partner__c 
                     && KBAd.Id_Analytics_Score__c >= 700 && app.utm_medium__c != 'DM' && app.utm_medium__c != 'Email' && !UTM_SOCIAL_MEDIUM.contains(app.utm_medium__c) 
                     && app.utm_source__c !='creditkarma_lightbox')  {
                     KBAFraudT = true;
                     reason += 'IDA Score >= 700. ';
                }
             
                }
                
                
                
               if(app.Identity_Verifications__r != null && app.Identity_Verifications__r.size()>0){ 
                   
                       if(app.Identity_Verifications__r[0].IDMV_Status__c != null &&    //pallavi(desk id 18882)
                          app.Identity_Verifications__r[0].IDMV_Status__c == 'Initial Fraud Alert'){                       
                           reason += 'IDMV Status = Initial Fraud Alert. ';                
                           verificationF = true;
                           
                       }
                       
                       if (app.Identity_Verifications__r[0].IDMV_Status__c != null &&   //pallavi(desk id 18882/LOS-207)
                           app.Identity_Verifications__r[0].IDMV_Status__c == 'Consumer Statement Bureau'){                       
                           reason +=  'IDMV Status = Consumer Statement Bureau. ';
                           verificationF = true;
                                              
                       }
                       
                       if (app.Identity_Verifications__r[0].IDMA_Status__c != null &&   //pallavi(desk id 18882/LOS-207)
                           app.Identity_Verifications__r[0].IDMA_Status__c == 'Initial Fraud Alert'){                       
                           reason +=  'IDMA Status = Initial Fraud Alert. ';
                           verificationF = true;
                                              
                       }
                       
                       if (app.Identity_Verifications__r[0].IDMA_Status__c != null &&   //pallavi(desk id 18882/LOS-207)
                           app.Identity_Verifications__r[0].IDMA_Status__c == 'Consumer Statement Bureau'){                       
                           reason +=  'IDMA Status = Consumer Statement Bureau. ';                   
                           verificationF = true;
                                                                           
                       }
                       
               }
            
               List<Application_Tags__c> lstAppTags = [SELECT id,Application_Tag__c,softDelete__c FROM Application_Tags__c where Application__c = :app.Id and Application_Tag__c = 'Fraud' and softDelete__c = false];  //CRM-974        
               if(KBAFraudT || verificationF){
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