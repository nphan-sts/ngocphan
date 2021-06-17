public with sharing class MW_KBAResponse {
    
    public cls_kiq_result kiq_result;
    public cls_fraud_shield_result fraud_shield_result;
    public Integer kba_attempts;    //0
    public Integer status_code; //200

     

    
    public MW_KBAResponse(cls_kiq_result kiq_result, cls_fraud_shield_result fraud_shield_result, Integer kba_attempts) {
         this.kiq_result = kiq_result; 
         this.fraud_shield_result = fraud_shield_result;
         this.kba_attempts= kba_attempts;
         this.status_code = 200;
    }
    

    public static boolean isBlank(String fieldName){
        if(fieldName == null || fieldName.length()==0){
                return true;
        }
        return false;
    } 


    public static String KBAResponse(String RawXML, String Type)
    { 
         
         cls_kiq_result          kiq    = new cls_kiq_result();
         cls_fraud_shield_result fs     = new cls_fraud_shield_result();
         
        if(Type=='KBA_18')
        {
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<ReferenceNumber>','</ReferenceNumber>'))))
            kiq.reference_number        = String.ValueOf(RawXML.substringBetween('<ReferenceNumber>','</ReferenceNumber>')); //"NetConnectResponse:Products:PreciseIDServer:Header:ReferenceNumber"
            
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<ReviewReferenceID>','</ReviewReferenceID>'))))
            kiq.review_reference_id     = String.ValueOf(RawXML.substringBetween('<ReviewReferenceID>','</ReviewReferenceID>')); //"NetConnectResponse:Products:PreciseIDServer:Summary:ReviewReferenceID"
            
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<FinalDecision>','</FinalDecision>'))))
            kiq.final_decision          = String.ValueOf(RawXML.substringBetween('<FinalDecision>','</FinalDecision>')); //""NetConnectResponse:Products:PreciseIDServer:Summary:InitialResults:FinalDecision"
            
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<PreciseIDScore>','</PreciseIDScore>'))))
            kiq.precise_id_score        = String.ValueOf(RawXML.substringBetween('<PreciseIDScore>','</PreciseIDScore>')); //"NetConnectResponse:Products:PreciseIDServer:KBAScore:ScoreSummary:PreciseIDScore"
            
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<OutWalletScore>','</OutWalletScore>'))))
            kiq.out_wallet_score        = String.ValueOf(RawXML.substringBetween('<OutWalletScore>','</OutWalletScore>')); //"NetConnectResponse:Products:PreciseIDServer:KBAScore:ScoreSummary:OutWalletScore"
            
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<AcceptReferCode>','</AcceptReferCode>'))))
            kiq.accept_refer_code       = String.ValueOf(RawXML.substringBetween('<AcceptReferCode>','</AcceptReferCode>')); //"NetConnectResponse:Products:PreciseIDServer:KBAScore:ScoreSummary:AcceptReferCode"
            
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<KBAResultCode>','</KBAResultCode>'))))
            kiq.result_code             = String.ValueOf(RawXML.substringBetween('<KBAResultCode>','</KBAResultCode>')); //"NetConnectResponse:Products:PreciseIDServer:KBAScore:General:KBAResultCode"
            
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<KBAResultCodeDescription>','</KBAResultCodeDescription>'))))
            kiq.result_code_description = String.ValueOf(RawXML.substringBetween('<KBAResultCodeDescription>','</KBAResultCodeDescription>'));//"NetConnectResponse:Products:PreciseIDServer:KBAScore:General:KBAResultCodeDescription"
            
        }
        if(Type=='KBA_06')
        {   
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<FinalDecision>','</FinalDecision>'))))
            fs.final_decision           = String.ValueOf(RawXML.substringBetween('<FinalDecision>','</FinalDecision>')); //NetConnectResponse:Products:PreciseIDServer:Summary:InitialResults:FinalDecision
            
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<ReferenceNumber>','</ReferenceNumber>'))))
            fs.reference_number         = String.ValueOf(RawXML.substringBetween('<ReferenceNumber>','</ReferenceNumber>')); //NetConnectResponse:Products:PreciseIDServer:Header:ReferenceNumber
            
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<ReviewReferenceID>','</ReviewReferenceID>'))))
            fs.review_reference_id      = String.ValueOf(RawXML.substringBetween('<ReviewReferenceID>','</ReviewReferenceID>'));//NetConnectResponse:Products:PreciseIDServer:Summary:ReviewReferenceID
           
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<MostLikelyFraudType code="','">'))))
            fs.fraud_shield_code        = String.ValueOf(RawXML.substringBetween('<MostLikelyFraudType code="','">'));//NetConnectResponse:Products:PreciseIDServer:Summary:InitialResults:MostLikelyFraudType 
            
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<MostLikelyFraudType code="','</MostLikelyFraudType>')))){
                String fraud_shield_description = String.ValueOf(RawXML.substringBetween('<MostLikelyFraudType code="','</MostLikelyFraudType>').split('">')[1]);
                if(!isBlank(fraud_shield_description))
                fs.fraud_shield_description = fraud_shield_description;//NetConnectResponse:Products:PreciseIDServer:Summary:InitialResults:MostLikelyFraudType
            }

            if(!isBlank(String.ValueOf(RawXML.substringBetween('<FPDScore>','</FPDScore>'))))
            fs.fpd_score                = Integer.ValueOf(RawXML.substringBetween('<FPDScore>','</FPDScore>'));//NetConnectResponse:Products:PreciseIDServer:Summary:FPDScore"
            
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<PreciseIDScore>','</PreciseIDScore>'))))
            fs.precise_id_score         = Integer.ValueOf(RawXML.substringBetween('<PreciseIDScore>','</PreciseIDScore>'));//NetConnectResponse:Products:PreciseIDServer:Summary:PreciseIDScore"
            
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<ValidationScore>','</ValidationScore>'))))
            fs.validation_score         = Integer.ValueOf(RawXML.substringBetween('<ValidationScore>','</ValidationScore>'));//NetConnectResponse:Products:PreciseIDServer:Summary:ValidationScore"
            
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<VerificationScore>','</VerificationScore>'))))
            fs.verification_score       = Integer.ValueOf(RawXML.substringBetween('<VerificationScore>','</VerificationScore>'));//NetConnectResponse:Products:PreciseIDServer:Summary:VerificationScore
            
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<DateOfBirthMatch>','</DateOfBirthMatch>'))))
            fs.date_of_birth_match      = String.ValueOf(RawXML.substringBetween('<DateOfBirthMatch>','</DateOfBirthMatch>'));//NetConnectResponse:Products:PreciseIDServer:GLBDetail:CheckpointSummary:DateOfBirthMatch
           
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<DateOfBirthMatchCode code="','</DateOfBirthMatchCode>')))){
                String date_of_birth_match_description = String.ValueOf(RawXML.substringBetween('<DateOfBirthMatchCode code="','</DateOfBirthMatchCode>').split('">')[1]);
                if(!isBlank(date_of_birth_match_description))
                fs.date_of_birth_match_description= date_of_birth_match_description;//NetConnectResponse:Products:PreciseIDServer:Checkpoint:GeneralResults:DateOfBirthMatch"
            } 
             
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<OFACValidationResult>','</OFACValidationResult>'))))
            fs.ofac_validation_result   = String.ValueOf(RawXML.substringBetween('<OFACValidationResult>','</OFACValidationResult>'));//NetConnectResponse:Products:PreciseIDServer:GLBDetail:CheckpointSummary:OFACValidationResult",
            
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<OFACValidationResult code="','</OFACValidationResult>')))){
                String ofac_validation_result_description = String.ValueOf(RawXML.substringBetween('<OFACValidationResult code="','</OFACValidationResult>').split('">')[1]);
                if(!isBlank(ofac_validation_result_description))
                fs.ofac_validation_result_description= ofac_validation_result_description;//NetConnectResponse:Products:PreciseIDServer:Checkpoint:ValidationSegment:OFACValidationResult[@code='1 ']"
            } 

            if(!isBlank(String.ValueOf(RawXML.substringBetween('<PhoneVerificationResult code="','">'))))
            fs.phone_verification_result= String.ValueOf(RawXML.substringBetween('<PhoneVerificationResult code="','">'));//NetConnectResponse:Products:PreciseIDServer:Checkpoint:GeneralResults:PhoneVerificationResult[@code='F ']@code",
            
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<PhoneVerificationResult code="','</PhoneVerificationResult>')))){
                String phone_verification_result_description = String.ValueOf(RawXML.substringBetween('<PhoneVerificationResult code="','</PhoneVerificationResult>').split('">')[1]);
                if(!isBlank(phone_verification_result_description))
                fs.phone_verification_result_description= phone_verification_result_description;//NetConnectResponse:Products:PreciseIDServer:Checkpoint:GeneralResults:PhoneVerificationResult[@code='F ']/text()"
            }
            
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNResult code="','">'))))
            fs.ssn_result             = String.ValueOf(RawXML.substringBetween('<SSNResult code="','">'));//NetConnectResponse:Products:PreciseIDServer:Checkpoint:GeneralResults:SSNResult[@code='Y ']@code"
            
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNResult code="','</SSNResult>')))){
                String ssn_result_description = String.ValueOf(RawXML.substringBetween('<SSNResult code="','</SSNResult>').split('">')[1]);
                if(!isBlank(ssn_result_description))
                fs.ssn_result_description = ssn_result_description;//NetConnectResponse:Products:PreciseIDServer:Checkpoint:GeneralResults:SSNResult[@code='Y ']/text()"
            }
            
            /*
   
            "adverse_actions": ["NetConnectResponse:Products:PreciseIDServer:FCRADetail:SharedApplication:AdverseActionCode1[@code=" "]",
                                "NetConnectResponse:Products:PreciseIDServer:FCRADetail:SharedApplication:AdverseActionCode2[@code=" "]",
                                "NetConnectResponse:Products:PreciseIDServer:FCRADetail:SharedApplication:AdverseActionCode3[@code=" "]",
                                "NetConnectResponse:Products:PreciseIDServer:FCRADetail:SharedApplication:AdverseActionCode4[@code=" "]",],
            */
           
            List<Adverse_actions> listofadverseActions = new List<Adverse_actions>();

            if(!isBlank(String.ValueOf(RawXML.substringBetween('<AdverseActionCode1 code="','"/>')))){
                Adverse_actions aaction = new Adverse_actions();
                aaction.description = String.ValueOf(RawXML.substringBetween('<AdverseActionCode1 code="','"/>'));
               
                String s  = null;
                if(aaction.description.contains('</AdverseActionCode1><AdverseActionCode2')) {
                    s  = aaction.description.replace('</AdverseActionCode1><AdverseActionCode2','');
                    s  = s.substring(s.indexOf('>')+1).replace('="','');
                }
                if(s!=null) aaction.description = s;
                
                listofadverseActions.add(aaction);
            }

            fs.adverse_actions = listofadverseActions;

            List<Fraud_shield_indicators> listOffs = new List<Fraud_shield_indicators>();
            /*
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<FS01>','</FS01>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS01>','</FS01>')),String.ValueOf(RawXML.substringBetween('<FS01>','</FS01>'))));
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<FS02>','</FS02>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS02>','</FS02>')),String.ValueOf(RawXML.substringBetween('<FS02>','</FS02>'))));
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<FS03>','</FS03>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS03>','</FS03>')),String.ValueOf(RawXML.substringBetween('<FS03>','</FS03>'))));
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<FS04>','</FS04>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS04>','</FS04>')),String.ValueOf(RawXML.substringBetween('<FS04>','</FS04>'))));
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNResult>','</SSNResult>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS05>','</FS05>')),String.ValueOf(RawXML.substringBetween('<FS05>','</FS05>'))));
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNResult>','</SSNResult>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS06>','</FS06>')),String.ValueOf(RawXML.substringBetween('<FS06>','</FS06>'))));
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNResult>','</SSNResult>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS07>','</FS07>')),String.ValueOf(RawXML.substringBetween('<FS07>','</FS07>'))));
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNResult>','</SSNResult>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS08>','</FS08>')),String.ValueOf(RawXML.substringBetween('<FS08>','</FS08>'))));
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNResult>','</SSNResult>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS09>','</FS09>')),String.ValueOf(RawXML.substringBetween('<FS09>','</FS09>'))));
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNResult>','</SSNResult>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS10>','</FS10>')),String.ValueOf(RawXML.substringBetween('<FS10>','</FS10>'))));
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNResult>','</SSNResult>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS11>','</FS11>')),String.ValueOf(RawXML.substringBetween('<FS11>','</FS11>'))));
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNResult>','</SSNResult>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS12>','</FS12>')),String.ValueOf(RawXML.substringBetween('<FS12>','</FS12>'))));
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNResult>','</SSNResult>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS13>','</FS13>')),String.ValueOf(RawXML.substringBetween('<FS13>','</FS13>'))));
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNResult>','</SSNResult>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS14>','</FS14>')),String.ValueOf(RawXML.substringBetween('<FS14>','</FS14>'))));
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNResult>','</SSNResult>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS15>','</FS15>')),String.ValueOf(RawXML.substringBetween('<FS15>','</FS15>'))));
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNResult>','</SSNResult>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS16>','</FS16>')),String.ValueOf(RawXML.substringBetween('<FS16>','</FS16>'))));
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNResult>','</SSNResult>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS17>','</FS17>')),String.ValueOf(RawXML.substringBetween('<FS17>','</FS17>'))));
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNResult>','</SSNResult>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS18>','</FS18>')),String.ValueOf(RawXML.substringBetween('<FS18>','</FS18>'))));
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNResult>','</SSNResult>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS19>','</FS19>')),String.ValueOf(RawXML.substringBetween('<FS19>','</FS19>'))));
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNResult>','</SSNResult>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS20>','</FS20>')),String.ValueOf(RawXML.substringBetween('<FS20>','</FS20>'))));
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNResult>','</SSNResult>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS21>','</FS21>')),String.ValueOf(RawXML.substringBetween('<FS21>','</FS21>'))));
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNResult>','</SSNResult>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS22>','</FS22>')),String.ValueOf(RawXML.substringBetween('<FS22>','</FS22>'))));
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNResult>','</SSNResult>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS23>','</FS23>')),String.ValueOf(RawXML.substringBetween('<FS23>','</FS23>'))));
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNResult>','</SSNResult>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS24>','</FS24>')),String.ValueOf(RawXML.substringBetween('<FS24>','</FS24>'))));
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNResult>','</SSNResult>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS25>','</FS25>')),String.ValueOf(RawXML.substringBetween('<FS25>','</FS25>'))));
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNResult>','</SSNResult>'))))
            listOffs.add(new Fraud_shield_indicators(String.ValueOf(RawXML.substringBetween('<FS26>','</FS26>')),String.ValueOf(RawXML.substringBetween('<FS26>','</FS26>'))));
           */
             
            fs.fraud_shield_indicators  = listOffs;
            
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNIssueStartRange>','</SSNIssueStartRange>'))))
            fs.ssn_issue_start_range  = String.ValueOf(RawXML.substringBetween('<SSNIssueStartRange>','</SSNIssueStartRange>'));//NetConnectResponse:Products:PreciseIDServer:Checkpoint:ValidationSegment:SSNIssueStartRange",
            
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<SSNIssueEndRange>','</SSNIssueEndRange>'))))
            fs.ssn_issue_end_range    = String.ValueOf(RawXML.substringBetween('<SSNIssueEndRange>','</SSNIssueEndRange>'));//NetConnectResponse:Products:PreciseIDServer:Checkpoint:ValidationSegment:SSNIssueEndRange",
  
            Scores sc = new Scores();
            if(!isBlank(String.ValueOf(RawXML.substringBetween('<FPDScore>','</FPDScore>'))))
            sc.fpd_score                = Integer.ValueOf(RawXML.substringBetween('<FPDScore>','</FPDScore>'));

            if(!isBlank(String.ValueOf(RawXML.substringBetween('<PreciseIDScore>','</PreciseIDScore>'))))
            sc.precise_id_score         = Integer.ValueOf(RawXML.substringBetween('<PreciseIDScore>','</PreciseIDScore>'));

            if(!isBlank(String.ValueOf(RawXML.substringBetween('<ValidationScore>','</ValidationScore>'))))
            sc.validation_score         = Integer.ValueOf(RawXML.substringBetween('<ValidationScore>','</ValidationScore>'));

            if(!isBlank(String.ValueOf(RawXML.substringBetween('<VerificationScore>','</VerificationScore>'))))
            sc.verification_score       = Integer.ValueOf(RawXML.substringBetween('<VerificationScore>','</VerificationScore>'));
            
            fs.scores = sc;           
        }
        
        MW_KBAresponse MW_KBA          = new MW_KBAresponse(kiq,fs,1); 
        String hh = JSON.serialize(MW_KBA, true);
        
        return hh;
    }    
    class cls_kiq_result{
        public Integer id;
        //public String kba_session_id;
        public String payoff_uid;
        public String reference_number;
        public String review_reference_id;
        public String final_decision;
        public String precise_id_score;
        public String out_wallet_score;
        public String accept_refer_code;
        public String result_code;
        public String result_code_description;
        public String additional_data;
        public String created_at;
        public String updated_at;
    }
    
    class cls_fraud_shield_result {
        public Integer id;
        //public String kba_session_id;
        public String payoff_uid;
        public String final_decision;
        public String reference_number;
        public String review_reference_id;
        public String fraud_shield_code;
        public String fraud_shield_description;
        public Integer fpd_score;
        public Integer precise_id_score;
        public Integer validation_score;
        public Integer verification_score;
        public String date_of_birth_match;
        public String date_of_birth_match_description;
        public String ofac_validation_result;
        public String ofac_validation_result_description;
        public String phone_verification_result;
        public String phone_verification_result_description;
        public String ssn_result;
        public String ssn_result_description;
        public List<Adverse_actions> adverse_actions;
        public List<Fraud_shield_indicators> fraud_shield_indicators;
        public String reasons;
        public String additional_data;
        public String created_at;
        public String updated_at;
        public String ssn_issue_start_range;
        public String ssn_issue_end_range;
        public Scores scores;
    }
    
    class Adverse_actions {
        public String name;
        public String reason;
        public String description;
    }
    
    class Fraud_shield_indicators {
        public String code; //FS06
        public String description;  //Inquiry age younger than Social Security number issue date

        public Fraud_shield_indicators(String code, String description){
            this.code= code;
            this.description=description;
        }
    }
    
    class cls_reasons {
    }
    
    class Scores {
        public Integer fpd_score;   //469
        public Integer precise_id_score; //368
        public Integer validation_score; //610
        public Integer verification_score; //369

    }

}