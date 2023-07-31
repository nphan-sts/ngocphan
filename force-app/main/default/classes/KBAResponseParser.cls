global class KBAResponseParser {
    
    global String requestBody;
    global String responseBody;
    global String integrationErrorStatus;
    global String integrationErrorStatusCode;
    global String errorMessage;
    global KBA_Details__c kba;
    global KBAResponseParser(){}

    global class Fraud_shield_result {
        global Integer id;
        global String kba_session_id;
        global String payoff_uid;
        global String final_decision;
        global String reference_number;
        global String review_reference_id;
        global String fraud_shield_code;
        global String fraud_shield_description;
        global Integer fpd_score;
        global Integer precise_id_score;
        global Integer validation_score;
        global Integer verification_score;
        global String date_of_birth_match;
        global String date_of_birth_match_description;
        global String ofac_validation_result;
        global String ofac_validation_result_description;
        global String phone_verification_result;
        global String phone_verification_result_description;
        global String ssn_result;
        global String ssn_result_description;
        global List<Adverse_actions> adverse_actions;
        global List<Fraud_shield_indicators> fraud_shield_indicators;
        global String reasons;
        global String additional_data;
        global String created_at;
        global String updated_at;
        global String ssn_issue_start_range;
        global String ssn_issue_end_range;
        global Scores scores;
    }
    
    global class Kiq_result {
        global Integer id;
        global String kba_session_id;
        global String payoff_uid;
        global String reference_number;
        global String review_reference_id;
        global String final_decision;
        global String precise_id_score;
        global String out_wallet_score;
        global String accept_refer_code;
        global String result_code;
        global String result_code_description;
        global String additional_data;
        global String created_at;
        global String updated_at;
    }
    
    
    global Kiq_result kiq_result;
    global Fraud_shield_result fraud_shield_result;
    global Integer kba_attempts;
    global Integer status_code;
    
    global class Fraud_shield_indicators {
        global String code;
        global String description;
    }
    
    global class Scores {
        global Integer fpd_score;
        global Integer precise_id_score;
        global Integer validation_score;
        global Integer verification_score;
    }
    
    global class Adverse_actions {
        global String name;
        global String reason;
        global String description;
    }
    

    global  static KBAResponseParser parse(String json, String accId, String appId, String Reqtype, String rawXMl, String LeadId) {
        KBAResponseParser KBAResponseData = (KBAResponseParser) System.JSON.deserialize(json, KBAResponseParser.class);
        try{
            KBAResponseData.kba = mappingOfFields(KBAResponseData, accId, appId, Reqtype, rawXMl, LeadId);
        }catch(Exception e){
            System.debug('Exception stack: '+e.getStackTraceString());
            throw new ints.IntegrationException(' API call failure Message: '+e.getMessage());
        }
        return KBAResponseData;
    }

    global static KBA_Details__c mappingOfFields(KBAResponseParser KBAResponseData,String accId,String appId, String Reqtype, String rawXMl, String LeadId)
    {
        System.debug(' ** RequestType ** ' +Reqtype);

        List<KBA_Details__c>  kbaInfo = new List<KBA_Details__c>([select Id from KBA_Details__c where Application__c=:appId limit 1]);
        
        KBA_Details__c obj; 
        if(kbaInfo.size()==0) obj = new KBA_Details__c(); else obj = kbaInfo[0];
        
        obj.Account__c=accId;
        obj.Application__c=appId;

        if(Reqtype=='KBA_18'){
            obj.IsKBA_18__c  = true; 
        }
            
        if(Reqtype=='KBA_06' && KBAResponseData!=null){
            obj.IsKBA_06__c  = true; 
            delete new List<Attachment>([select Id from Attachment where parentid=:obj.id]);
            Attachment a = new Attachment(parentid=appId, Name = 'preciseid_'+LeadId+'.xml', Body = Blob.valueOf(rawXMl), ContentType='application/xml');
            insert a;
        }
        
        if(KBAResponseData!=null && KBAResponseData.Fraud_shield_result !=null){
            if(KBAResponseData.Fraud_shield_result.date_of_birth_match !=null)
                obj.Date_of_Birth_Match__c=KBAResponseData.Fraud_shield_result.date_of_birth_match;
            
            if(KBAResponseData.Fraud_shield_result.date_of_birth_match_description!=null)
                obj.Date_of_Birth_Match_Description__c=KBAResponseData.Fraud_shield_result.date_of_birth_match_description;
            
            if(KBAResponseData.Fraud_shield_result.fraud_shield_description !=null)
                obj.Fraud_Description__c=KBAResponseData.Fraud_shield_result.fraud_shield_description;
            
            if(KBAResponseData.Fraud_shield_result.ofac_validation_result_description!=null)
                obj.OFAC_Description__c=KBAResponseData.Fraud_shield_result.ofac_validation_result_description;
            
            if(KBAResponseData.Fraud_shield_result.phone_verification_result !=null)
                obj.Phone_Verification_Result__c=KBAResponseData.Fraud_shield_result.phone_verification_result;
            
            if(KBAResponseData.Fraud_shield_result.phone_verification_result_description !=null)
                obj.Phone_Verification_Result_Description__c=KBAResponseData.Fraud_shield_result.phone_verification_result_description;
            
            if(KBAResponseData.Fraud_shield_result.adverse_actions !=null){
                for(Adverse_actions a:KBAResponseData.Fraud_shield_result.adverse_actions){
                    obj.Precise_ID_Adverse_Action_Code__c=KBAResponseData.Fraud_shield_result.adverse_actions[0].description;
                }
            }
            
            if(KBAResponseData.Fraud_shield_result.final_decision !=null){
                if(KBAResponseData.Fraud_shield_result.final_decision == 'ACC')
                    obj.Precise_ID_Decision__c='Accept';
                if(KBAResponseData.Fraud_shield_result.final_decision == 'REF')
                    obj.Precise_ID_Decision__c='Refer';
                if(KBAResponseData.Fraud_shield_result.final_decision == 'R01')
                    obj.Precise_ID_Decision__c='Highest Priority Referral';
                if(KBAResponseData.Fraud_shield_result.final_decision == 'R10')
                    obj.Precise_ID_Decision__c='Priority 10 Referral';
                if(KBAResponseData.Fraud_shield_result.final_decision == 'R20')
                    obj.Precise_ID_Decision__c='Priority 20 Referral';
                if(KBAResponseData.Fraud_shield_result.final_decision == 'R30')
                    obj.Precise_ID_Decision__c='Priority 30 Referral';
                if(KBAResponseData.Fraud_shield_result.final_decision == 'R40')
                    obj.Precise_ID_Decision__c='Priority 40 Referral';
                if(KBAResponseData.Fraud_shield_result.final_decision == 'R50')
                    obj.Precise_ID_Decision__c='Priority 50 Referral';
                if(KBAResponseData.Fraud_shield_result.final_decision == 'R60')
                    obj.Precise_ID_Decision__c='Priority 60 Referral';
                if(KBAResponseData.Fraud_shield_result.final_decision == 'R70')
                    obj.Precise_ID_Decision__c='Priority 70 Referral';
                if(KBAResponseData.Fraud_shield_result.final_decision == 'R80')
                    obj.Precise_ID_Decision__c='Priority 80 Referral';
                if(KBAResponseData.Fraud_shield_result.final_decision == 'R90')
                    obj.Precise_ID_Decision__c='Priority 90 Referral';
                if(KBAResponseData.Fraud_shield_result.final_decision == 'R99')
                    obj.Precise_ID_Decision__c='Lowest Priority Referral';
                if(KBAResponseData.Fraud_shield_result.final_decision == 'XXX')
                    obj.Precise_ID_Decision__c='No Decision';
                }
            
            if(KBAResponseData.Fraud_shield_result.fpd_score !=null)
                obj.Precise_ID_First_Payment_Default__c=KBAResponseData.Fraud_shield_result.fpd_score;
            
            if(KBAResponseData.Fraud_shield_result.fraud_shield_code !=null)
                obj.Precise_ID_Fraud_Classification__c=KBAResponseData.Fraud_shield_result.fraud_shield_code;
            
            if(KBAResponseData.Fraud_shield_result.fraud_shield_indicators !=null){
                for(Fraud_shield_indicators f:KBAResponseData.Fraud_shield_result.fraud_shield_indicators){
                /*    if(f.code=='FS09'|| f.code=='FS21')
                        obj.Precise_ID_General_Fraud_Shield_Indicat__c='general';
                    if(f.code=='FS01'|| f.code=='FS02'|| f.code=='FS03'|| f.code=='FS10'|| f.code=='FS11'|| f.code=='FS15'|| f.code=='FS16'|| f.code=='FS17'|| 
                       f.code=='FS18'|| f.code=='FS19'|| f.code=='FS20'|| f.code=='A'|| f.code=='D'|| f.code=='DN'|| f.code=='DS'|| f.code=='DY'|| f.code=='E'|| 
                       f.code=='F'|| f.code=='FF'|| f.code=='FY'|| f.code=='I'|| f.code=='M'|| f.code=='N'|| f.code=='NA'|| f.code=='NI'|| f.code=='NV'|| f.code=='P'|| 
                       f.code=='S'|| f.code=='SA'|| f.code=='V'|| f.code=='Y'|| f.code=='YA'|| f.code=='YB'|| f.code=='Z')
                        obj.Precise_ID_General_Fraud_Shield_Indicat__c='address';
                    if(f.code=='FS07')
                        obj.Precise_ID_General_Fraud_Shield_Indicat__c='dob';
                    if(f.code== 'FS04'|| f.code=='FS05'|| f.code=='FS06'|| f.code=='FS08'|| 
                       f.code=='FS13'||f.code=='FS14'|| f.code=='FS25'|| f.code=='FS26'|| f.code=='FS27')
                        obj.Precise_ID_General_Fraud_Shield_Indicat__c='ssn';
                        */
                }
            }
            
            
            if(KBAResponseData.Fraud_shield_result.verification_score !=null)
                obj.Precise_ID_ID_Theft__c=KBAResponseData.Fraud_shield_result.verification_score;
            
            if(KBAResponseData.Fraud_shield_result.ofac_validation_result !=null)
                obj.Precise_ID_OFAC__c=KBAResponseData.Fraud_shield_result.ofac_validation_result;
            
            if(KBAResponseData.Fraud_shield_result.precise_id_score !=null)
                obj.Precise_ID_Overall_SCore__c=KBAResponseData.Fraud_shield_result.precise_id_score;
            
            if(KBAResponseData.Fraud_shield_result.review_reference_id !=null)
                obj.Precise_ID_Reference_ID__c=KBAResponseData.Fraud_shield_result.review_reference_id;
            
            if(KBAResponseData.Fraud_shield_result.reference_number !=null)
                obj.Precise_ID_Reference_Number__c=KBAResponseData.Fraud_shield_result.reference_number;
            
            if(KBAResponseData.Fraud_shield_result.validation_score !=null)
                obj.Precise_ID_Validation__c=KBAResponseData.Fraud_shield_result.validation_score;
            
            if(KBAResponseData.Fraud_shield_result.ssn_issue_start_range !=null)
                obj.SSN_Issue_Date__c=KBAResponseData.Fraud_shield_result.ssn_issue_start_range;
            
            if(KBAResponseData.Fraud_shield_result.ssn_issue_end_range !=null)
                obj.SSN_Issue_End_Date__c=KBAResponseData.Fraud_shield_result.ssn_issue_end_range;
            
            if(KBAResponseData.Fraud_shield_result.ssn_result !=null)
                obj.SSN_Result__c=KBAResponseData.Fraud_shield_result.ssn_result;
            
            if(KBAResponseData.Fraud_shield_result.ssn_result_description !=null)
                obj.SSN_Result_Description__c=KBAResponseData.Fraud_shield_result.ssn_result_description;
        }
        
        //System.debug('...KBA Attempts...' + kba_attempts);
        if(KBAResponseData != null && KBAResponseData.kba_attempts != null){
            obj.KBA_Attempts__c = KBAResponseData.kba_attempts;
        }
       
        if(KBAResponseData!=null && KBAResponseData.kiq_result !=null ){
            if(KBAResponseData.kiq_result.accept_refer_code != null){
               obj.Accept_Refer_Code__c = KBAResponseData.kiq_result.accept_refer_code;
            }
            if(KBAResponseData.kiq_result.accept_refer_code!=null){
                if(KBAResponseData.kiq_result.accept_refer_code== 'ACC')
                    obj.Precise_ID_Decision_KIQ__c='Accept';
                if(KBAResponseData.kiq_result.accept_refer_code== 'REF')
                    obj.Precise_ID_Decision_KIQ__c='Refer';
                if(KBAResponseData.kiq_result.accept_refer_code== 'R01')
                    obj.Precise_ID_Decision_KIQ__c='Highest Priority Referral';
                if(KBAResponseData.kiq_result.accept_refer_code== 'R10')
                    obj.Precise_ID_Decision_KIQ__c='Priority 10 Referral';
                if(KBAResponseData.kiq_result.accept_refer_code== 'R20')
                    obj.Precise_ID_Decision_KIQ__c='Priority 20 Referral';
                if(KBAResponseData.kiq_result.accept_refer_code== 'R30')
                    obj.Precise_ID_Decision_KIQ__c='Priority 30 Referral';
                if(KBAResponseData.kiq_result.accept_refer_code== 'R40')
                    obj.Precise_ID_Decision_KIQ__c='Priority 40 Referral';
                if(KBAResponseData.kiq_result.accept_refer_code== 'R50')
                    obj.Precise_ID_Decision_KIQ__c='Priority 50 Referral';
                if(KBAResponseData.kiq_result.accept_refer_code== 'R60')
                    obj.Precise_ID_Decision_KIQ__c='Priority 60 Referral';
                if(KBAResponseData.kiq_result.accept_refer_code== 'R70')
                    obj.Precise_ID_Decision_KIQ__c='Priority 70 Referral';
                if(KBAResponseData.kiq_result.accept_refer_code== 'R80')
                    obj.Precise_ID_Decision_KIQ__c='Priority 80 Referral';
                if(KBAResponseData.kiq_result.accept_refer_code== 'R90')
                    obj.Precise_ID_Decision_KIQ__c='Priority 90 Referral';
                if(KBAResponseData.kiq_result.accept_refer_code== 'R99')
                    obj.Precise_ID_Decision_KIQ__c='Lowest Priority Referral';
                if(KBAResponseData.kiq_result.accept_refer_code== 'XXX')
                    obj.Precise_ID_Decision_KIQ__c='No Decision';
                
                }
            system.debug(KBAResponseData.kiq_result.final_decision);
            
            if(KBAResponseData.kiq_result.review_reference_id !=null)
                obj.Precise_ID_Reference_ID_KIQ__c=KBAResponseData.kiq_result.review_reference_id;
            
            if(KBAResponseData.kiq_result.reference_number !=null)
                obj.Precise_ID_Reference_Number_KIQ__c=KBAResponseData.kiq_result.reference_number ;
            
            if(KBAResponseData.kiq_result.precise_id_score !=null)
                obj.Precise_ID_Score_KIQ__c=Decimal.valueOf(KBAResponseData.kiq_result.precise_id_score);
        }

        upsert obj;
        
        return obj;
    }
}