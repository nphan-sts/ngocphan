global class CreditPolicyResponse {
        
        global credit_policy_decision credit_policy_decision;
        global metadata metadata;
        global String requestBody;
        global String responseBody;
        global String integrationErrorStatus;
        global String integrationErrorStatusCode;
        global String errorMessage;
        
        global Credit_Policy__c cpData;
        global List<Hard_Inquiry_Meta_Data__c> hardData;
        global List<Credit_Report_Details__c> crdData;
        global List<Adverse_Actions__c> adverseActionData;
        global List<Score_Factors__c> scf;
        global Decision_codes decision_codes;
        global class metadata {
            global Integer status {get;set;} 
        }
        
        
        global class offers{
            public String key {get;set;} 
            public String amount {get;set;} 
            public Integer term_months {get;set;} 
            public String apr {get;set;} 
            public String interest_rate {get;set;} 
            public String origination_fee_rate {get;set;} 
            public String monthly_payment {get;set;} 
            public String origination_fee {get;set;} 
            public String segment {get;set;} 
            public String pricing_tier {get;set;} 
            public String above_prime_max {get;set;} 
            public String type {get;set;}
            public Boolean Is_Offer_Selected {get;set;}
            
        }
        
        global class Regression_scores {
            global String agg901_non_mortgage_increases_last_3_mo  {get;set;} 
            global Double agg911_max_bankcard_utilization  {get;set;} 
            global Double at103s_percent_satisfactory_trades_last_24_mo  {get;set;} 
            global Double at104s_percent_trades_opened_last_24_mo  {get;set;} 
            global String bc02s_open_credit_cards  {get;set;} 
            global Double bc20s_mo_since_oldest_credit_card_opened  {get;set;} 
            global String cemp08_fico_score  {get;set;} 
            global Double fi02s_installment_trades  {get;set;} 
            global Double g058s_trades_30_days_past_due_last_6_mo  {get;set;} 
            global Double g209s_mo_since_recent_charge_off_opened  {get;set;} 
            global Double g215b_non_medical_collections  {get;set;} 
            global String paymnt08_min_payment_revolving_ratio  {get;set;} 
            global String re31s_percent_high_revolving_trade_utilization  {get;set;} 
            global String s114s_inquiries_last_6_mo  {get;set;} 
            global String trv12_revolving_high_credit_increases_last_3_mo  {get;set;} 
            global String dti  {get;set;} 
            global String ndi  {get;set;} 
            global String overlimit_trend {get;set;} 
            global String percent_delinquency {get;set;} 
            global String tri_highest_card_type_i {get;set;} 
            global String tri_highest_card_type_t {get;set;} 
        }
        
        global class Utm_tracking {
            global String utm_source {get;set;} 
            global String utm_medium {get;set;} 
            global String utm_campaign {get;set;} 
        }
        
        global class Adverse_actions {
            global String name {get;set;} 
            global String reason {get;set;} 
            global String description {get;set;} 
        }
        
        global class Data {
            global String credit_policy_version {get;set;} 
            global String credit_policy_gem_version {get;set;} 
            global String source {get;set;} 
            global Boolean no_hit {get;set;} 
            global Boolean frozen_report {get;set;} 
            global String final_decision {get;set;} 
            global String final_decision_level {get;set;}
            global String request_intent {get;set;}
            global Risk_models risk_models {get;set;} 
            global String pricing_segment {get;set;} 
            global String pricing_tier {get;set;} 
            global List<Invalid_input_knockout_codes> offers {get;set;} 
            global String debt_to_income {get;set;} 
           // global String federal_tax_payment {get;set;} 
            global String net_disposable_income {get;set;} 
            global String overlimit_trend {get;set;} 
            global String percent_delinquency {get;set;} 
            global String state_tax_payment {get;set;} 
            global String tri_highest_card_type_i {get;set;} 
            global String tri_highest_card_type_t {get;set;} 
            global String tradeline_unsecured_installment_loans_balance {get;set;} 
            global String tradeline_unsecured_installment_loans_opened_last_12_mo {get;set;} 
            global String tradeline_non_mortgage_trades_monthly_payment {get;set;} 
            global String tradeline_revolving_trades_balance {get;set;} 
            global String tradeline_summary_of_balances {get;set;} 
            global Double max_unsecured_installment_loan_utilization  {get;set;}
            global String tradeline_ndi {get;set;} 
            global String tradeline_dti {get;set;}
            global String monthly_dti {get;set;}  
            global String tradeline_analysis {get;set;} 
            global String pricing_policy_filters {get;set;} 
            global String adverse_action_template {get;set;} 
            global String loan_amount_counteroffer {get;set;} 
            global String tradeline_dti_with_lie_detector {get;set;} 
            global String tradeline_ndi_with_lie_detector {get;set;} 
            global String tradeline_alliant_charge_off {get;set;} 
            global String days_since_unsecured_installment_inquiry {get;set;} 
            global String days_since_open_unsecured_installment_loan {get;set;} 
            global String days_since_open_unsecured_loan {get;set;} 
            global String age_flag {get;set;} 
            global String student_loan_flag {get;set;} 
			global String pricing_test_bucket {get;set;}	//pallavi(LOS-197)
            global String pricing_policy_gem_version {get;set;}
        }
        
        global class Risk_models {
            global V3 v3 {get;set;}
            global V6 v6 {get;set;}
        }
        
        global class credit_policy_decision {
            global Decision_codes decision_codes {get;set;}
            global Integer id {get;set;} 
            global Integer applicant_id {get;set;} 
            global String credit_policy_version {get;set;} 
            global String credit_policy_gem_version {get;set;} 
            global String source {get;set;} 
            global Boolean no_hit {get;set;} 
            global Boolean frozen_report {get;set;} 
            global String final_decision {get;set;}
            global String request_intent {get;set;} 
            //*** Added by Snehal for CLS-527
            global String federal_tax_payment{get;set;}
            global String state_tax_payment{get;set;}
            //***
            global String pricing_segment {get;set;} 
            global String pricing_tier {get;set;} 
            // global List<Invalid_input_knockout_codes> offers {get;set;} //Commented By Jandeep
            global List<offers> offers {get;set;}
            global Double debt_to_income {get;set;} 
            global Double net_disposable_income {get;set;} 
            global Double overlimit_trend {get;set;} 
            global Double percent_delinquency {get;set;} 
            global Double tri_highest_card_type_i {get;set;} 
            global Double tri_highest_card_type_t {get;set;} 
            global Double tradeline_unsecured_installment_loans_balance {get;set;} 
            global Double tradeline_unsecured_installment_loans_opened_last_12_mo {get;set;} 
            global Double tradeline_non_mortgage_trades_monthly_payment {get;set;} 
            global Double tradeline_revolving_trades_balance {get;set;} 
            global Decimal tradeline_ndi {get;set;} 
            global Double tradeline_dti {get;set;}
            global Double monthly_dti {get;set;} 
            global String tradeline_analysis {get;set;} 
            global String pricing_policy_filters {get;set;} 
            global String adverse_action_template {get;set;} 
            global String created_at {get;set;} 
            global String updated_at {get;set;} 
            global String loan_amount_counteroffer {get;set;} 
            global Risk_models risk_models {get;set;} 
            global String request_context {get;set;}
            /* leaving this in for backwards compat, but data key removed in v6 */
            global Data data {get;set;}
            global Double tradeline_dti_with_lie_detector {get;set;} 
            global Double tradeline_ndi_with_lie_detector {get;set;} 
            global String tradeline_unsecured_installment_loans_opened_last_3_mo {get;set;} 
            global String final_decision_level {get;set;} 
            global String days_since_unsecured_installment_inquiry {get;set;} 
            global String days_since_open_unsecured_installment_loan {get;set;} 
            global Double days_since_open_unsecured_loan {get;set;} 
            global Double tradeline_alliant_charge_off {get;set;} 
            global Double tradeline_summary_of_balances {get;set;} 
            global Double max_unsecured_installment_loan_utilization  {get;set;}
            global Double age_flag {get;set;} 
            global Double student_loan_flag {get;set;} 
            global String funding_model {get;set;} 
			global String pricing_test_bucket {get;set;} 	//pallavi LOS-197
            /** 
            * Fix for CLS-145
            **/
            global String raw_bureau_data {get;set;}
            global String bureau_subset {get;set;}

            
            
        }
        
        global class Invalid_input_knockout_codes {
        }
        
        global class Probability_differences {
            global String risk_model_non_mortgage_increases_high {get;set;} 
            global Double risk_model_max_bankcard_utilization_high {get;set;} 
            global Double risk_model_percent_satisfactory_trades_last_24_mo_low {get;set;} 
            global Double risk_model_percent_trades_opened_last_24_mo_high {get;set;} 
            global String risk_model_number_of_open_credit_cards_high {get;set;} 
            global Double risk_model_mo_since_oldest_credit_card_opened_low {get;set;} 
            global String risk_model_fico_score_low {get;set;} 
            global Double risk_model_installment_loans_high {get;set;} 
            global Double risk_model_trades_30_days_past_due_high {get;set;} 
            global Double risk_model_mo_since_recent_charge_off_opened_low {get;set;} 
            global Double risk_model_non_medical_collections_high {get;set;} 
            global String risk_model_min_payment_revolving_ratio_low {get;set;} 
            global String risk_model_percent_high_revolving_trade_utilization_high {get;set;} 
            global String risk_model_inquiries_last_6_mo_high {get;set;} 
            global String risk_model_revolving_high_credit_increases_high {get;set;} 
            global String risk_model_dti_high {get;set;} 
            global String risk_model_ndi_low {get;set;} 
            global String risk_model_overlimit_trend_high {get;set;} 
            global String risk_model_percent_delinquency_high {get;set;} 
            global String risk_model_consumer_tri_highest_card_type_i_high {get;set;} 
            global String risk_model_consumer_tri_highest_card_type_t_low {get;set;} 
        }
        
        global class Funding_model {
            global String funding_model_decision {get;set;} 
            global Double funding_model_regression_score {get;set;} 
        }
        
        global class Applicant {
            global Integer id {get;set;} 
            global String person_uid {get;set;} 
            global String payoff_uid {get;set;} 
            global String income_annual {get;set;} 
            global String requested_loan_amount {get;set;} 
            global String housing_payment {get;set;} 
            global String date_of_birth {get;set;} 
            global Utm_tracking utm_tracking {get;set;} 
            global String bureau_report_subset {get;set;} 
            global String created_at {get;set;} 
            global String updated_at {get;set;} 
            global String first_name {get;set;} 
            global String middle_name {get;set;} 
            global String last_name {get;set;} 
            global String street1 {get;set;} 
            global String street2 {get;set;} 
            global String city {get;set;} 
            global String state {get;set;} 
            global String postal_code {get;set;} 
            global String ssn {get;set;} 
            global String request_context {get;set;} 
            global String credit_policy_version {get;set;} 
            global String suffix_name {get;set;} 
            global String bureau_request_uid {get;set;} 
            global String partner_applicant {get;set;} 
            global String selected_vendor_amount {get;set;} 
        }
        
        global class Decision_codes {
            global List<String> invalid_input_knockout_codes {get;set;} 
            global List<String> prebureau_knockout_codes {get;set;} 
            global List<String> postbureau_knockout_codes {get;set;} 
            global List<String> risk_model_codes {get;set;} 
            global List<Adverse_actions> adverse_actions {get;set;} 
            global List<Prebureau_knockout_codes> score_factor_text {get;set;} 
        }
        
        global class Risk_model_codes {
            
        }
        global class Prebureau_knockout_codes {
            global Integer rank {get;set;}
            global String code {get;set;}
            global String description {get;set;}
        }

        /*
         v6.0 key, parsed manually
         */
        global class V6 {
            global String risk_model_decision {get;set;}
            global Double risk_model_score {get;set;}
            global Double logistic_prediction_of_default {get;set;}
            global Integer invalid_risk_model_variable_count {get;set;}
        }

        global class V3 {
            global String risk_model_decision {get;set;} 
            global String risk_model_score {get;set;} 
            global Double logistic_prediction_of_default {get;set;} 
            global Regression_scores regression_scores {get;set;} 
            global Probability_differences probability_differences {get;set;} 
        }
        
        /* Trade Line Analysis Details */  
        global class TradelineAnalysis {
            global Integer credit_card_count {get;set;}
            global Integer credit_card_balance {get;set;}
            global Integer credit_card_limit {get;set;}
            global Double credit_card_utilization {get;set;}
            global Integer credit_card_monthly_payments {get;set;}
            global Integer credit_card_closed_with_balance_count {get;set;}
            global Integer unsecured_installment_loan_count {get;set;}
            global Integer unsecured_installment_loan_balance {get;set;}
            global Integer unsecured_installment_loan_opened_last_12_mo {get;set;}
            global Integer unsecured_installment_loan_monthly_payment {get;set;}
            global Integer student_loan_count {get;set;}
            global Integer student_loan_balance {get;set;}
            global Integer student_loan_monthly_payment {get;set;}
            global Integer student_loan_deferred_count {get;set;}
            global Integer auto_loan_count {get;set;}
            global Integer auto_loan_balance {get;set;}
            global Integer auto_loan_monthly_payment {get;set;}
            global Integer mortgage_count {get;set;}
            global Integer mortgage_balance {get;set;}
            global Integer mortgage_monthly_payment {get;set;}
            global Integer heloc_count {get;set;}
            global Integer heloc_balances {get;set;}
            global Integer heloc_monthly_payment {get;set;}
        }
        
        global TradelineAnalysis parse(String json) {
            return (TradelineAnalysis) System.JSON.deserialize(json, TradelineAnalysis.class);
        }

        /**
         * parse credit_policy_decision.data.risk_models['6.0'] manually, due to non de-serializable key
         * TODO either create some better helper methods for similar use cases or find a good user friendly lib
         * @param unescapedString The complete response ready for parsing
         * @param CPResponse The response collecting parsed data
         */
        global void parseV6RiskModel(String unescapedString, CreditPolicyResponse CPResponse) {
           /** if (CPResponse.credit_policy_decision.credit_policy_version != '6.0') {
                return;
            }**/

            Map<String, Object> untypedResponse = (Map<String, Object>) System.JSON.deserializeUntyped(unescapedString);
            if (untypedResponse == null) {
                throw new IllegalArgumentException('invalid string to parse as json');
            }

            Map<String, Object> untypedCreditPolicyDecision = (Map<String, Object>) untypedResponse.get('credit_policy_decision');
            if (untypedCreditPolicyDecision == null) {
                throw new IllegalArgumentException('JSON document does not contain credit_policy_decision');
            }

            Map<String, Object> untypedRiskModels = (Map<String, Object>) untypedCreditPolicyDecision.get('risk_models');
            if (untypedRiskModels == null) {
                return;
            }

            //Map<String, Object> untypedV6 = (Map<String, Object>) untypedRiskModels.get('6.0');
            Map<String, Object> untypedV6 = (Map<String, Object>) untypedRiskModels.get(CPResponse.credit_policy_decision.credit_policy_version);
            if (untypedV6 == null) {
                return;
            }

            CreditPolicyResponse.V6 v6 = new CreditPolicyResponse.V6();
            v6.invalid_risk_model_variable_count = (Integer) untypedV6.get('invalid_risk_model_variable_count');
            v6.logistic_prediction_of_default = (Double) untypedV6.get('logistic_prediction_of_default');
            system.debug('v6.logistic_prediction_of_default'+v6.logistic_prediction_of_default);
            v6.risk_model_decision = (String) untypedV6.get('risk_model_decision');
            //v6.risk_model_score = (Double) untypedV6.get('risk_model_score');

            /* leaving this in for backwards compat, but data key removed in v6, create data key for risk models v6 only */
            if (CPResponse.credit_policy_decision.data != null) {
                if (CPResponse.credit_policy_decision.data.risk_models == null) {
                    CPResponse.credit_policy_decision.data.risk_models = new Risk_models();
                }
                CPResponse.credit_policy_decision.data.risk_models.v6 = v6;
            }

            CPResponse.credit_policy_decision.risk_models.v6 = v6;
        }

        global CreditPolicyResponse parse(String json,String accountID,String appId, String LeadID) 
        {    
            //json=json.replace('type', 'type1');
            //System.(' : Before Deserilize : '+json);

            CreditPolicyResponse CPResponse = new CreditPolicyResponse();
            try{
                String BureauResponse ;
                Id CPid;
                String unescapedString = json.replace('\\\\', '');
                CPResponse = (CreditPolicyResponse) System.JSON.deserialize(unescapedString, CreditPolicyResponse.class);

                parseV6RiskModel(unescapedString, CPResponse);

                CPResponse.cpData = mappingOfFields(CPResponse,accountID,appId,json);
                if(CPResponse.cpData != null){
                    insert CPResponse.cpData;
                    CPid = CPResponse.cpData.id;
                    if(CPResponse.cpData.final_decision__c !=null){
                    String attname = 'cbr_'+LeadID+'.xml';
                    if (CPResponse.cpData.final_decision__c == 'Approve' && CPResponse.cpData.pricing_test_bucket__c != NULL && 
                        CPResponse.cpData.request_intent__c == 'application') {
                        attname = 'cbr_'+LeadID+'_origination.xml';  // LOP-112
                    }
                    Attachment a = new Attachment(parentid=appId, Name = attname , Body = Blob.valueOf(json) );
                    insert a;
                    }
                    System.Debug('****cpDataID******' + CPResponse.cpData.id);
                }
                System.Debug('****cpData1******' + CPResponse.cpData);
                if(CPResponse!=null && CPResponse.credit_policy_decision !=null ) {
                    if (CPResponse.credit_policy_decision.bureau_subset != null) {
                        BureauResponse = CPResponse.credit_policy_decision.bureau_subset;
                        if(BureauResponse != null){
                             String bureau_data = String.valueOF(CPResponse.credit_policy_decision.bureau_subset);
                             System.debug( 'Bureau data ' +bureau_data);
                             CPResponse.crdData = fieldMapping(CPResponse,BureauResponse,accountID,appId);
                             String attnm = 'Bureau_subset_Data_'+CPid+'.txt';
                             Attachment att = new Attachment(parentid=CPid, Name = attnm , Body = Blob.valueOf(bureau_data) );
                             insert att;
                            System.debug('success');
                        }
                            
                    }
                    if(CPResponse.credit_policy_decision.decision_codes!=null) {
                        CPResponse.adverseActionData = mappingOfAdverseAction(CPResponse.credit_policy_decision.decision_codes,accountID,appId);
                        CPResponse.scf = mappingOfFieldscf(CPResponse.credit_policy_decision.decision_codes,accountID,appId);
                    }
                    
    
                    
                }
                CPResponse.hardData= mappingOfHardInquiryData(CPResponse,accountID,appId);
                
                if(CPResponse.crdData != null && CPResponse.crdData.size() > 0){
                    insert CPResponse.crdData;
                    System.Debug('****crdData after Insert******' + CPResponse.crdData);
                }
                if(CPResponse.hardData != null && CPResponse.hardData.size() > 0){
                    insert CPResponse.hardData;
                    System.Debug('****hardData after Insert******' + CPResponse.hardData);
                }
                if(CPResponse.scf!= null && CPResponse.scf.size() > 0){
                    List<Score_Factors__c> scfList = [Select Id from Score_Factors__c where Application__c = :appId and
                                                    Account__c =: accountId];
                    System.debug('....Delete List... '+ scfList );
                    if(scfList!=null && scfList.size()>0)
                        delete scfList ;
                    insert CPResponse.scf;
                    
                    System.Debug('****Score Factor Text after Insert******' + CPResponse.scf);
                }
                if(CPResponse.adverseActionData!= null && CPResponse.adverseActionData.size() > 0){
                    List<genesis__Applications__c> applistToUpdate = [Select id,name,genesis__status__c,Bureau_SSN__c,Bureau_DOB__c from genesis__Applications__c where id=: appId LIMIT 1 ];
    
                    List<Adverse_Actions__c> advActionData = [Select Id from Adverse_Actions__c where Application__c = :appId and
                                                    Account__c =: accountId];
                    System.debug('....Delete List... '+ advActionData );
                    if(advActionData!=null && advActionData.size()>0)
                        delete advActionData ;
                    insert CPResponse.adverseActionData;
                    if(CPResponse.cpData.final_decision__c!=null && CPResponse.cpData.final_decision__c.equalsIgnoreCase('Decline') && applistToUpdate[0].genesis__status__c != 'Declined') {
                        QueueSobject declinedQue = [Select queue.id,queue.name,QueueID 
                                                from QueueSobject 
                                                where SobjectType ='genesis__Applications__c'                                   
                                                AND queue.DeveloperName =: 'Declined'];
                        applistToUpdate[0].genesis__status__c = 'Declined';
                        applistToUpdate[0].OwnerId = declinedQue.Queue.Id;

                        if (!Test.isRunningTest()) {
                            AttachPDFtoApplication.SaveAttachment(applistToUpdate[0].id,true,true);
                        }
                    }
                    
                    
                    System.Debug('****AdverseActions after Insert******' + CPResponse.adverseActionData);
                     //System.debug('****bureau_social_security_number4****' + applistToUpdate[0].Bureau_SSN__c);
                    update applistToUpdate[0];
                }
           //added for CLS-794 Stacker Check Passed by BGarbaccio
            if(CPResponse!=null && CPResponse.credit_policy_decision !=null){
                   // List<genesis__Applications__c> StackCheckapplistToUpdate = [Select id,name,genesis__status__c from genesis__Applications__c where id=: appId and genesis__status__c='agent_document_verification_pending' LIMIT 1 ];
                    List<genesis__Applications__c> StackCheckapplistToUpdate = [Select id,name,genesis__status__c,Stacker_Reviewed__c from genesis__Applications__c where id=: appId LIMIT 1 ];
                    if(CPResponse.cpData.final_decision__c!=null && CPResponse.cpData.final_decision__c.equalsIgnoreCase('Approve') && CPResponse.cpData.request_intent__c!=null && CPResponse.cpData.request_intent__c.equalsIgnoreCase('verification') && StackCheckapplistToUpdate[0].genesis__status__c !='Declined') {
                        StackCheckapplistToUpdate[0].genesis__status__c = 'Stacker_Check_Passed';
                        StackCheckapplistToUpdate[0].Stacker_Reviewed__c = true;
                    }
                    if(CPResponse.cpData.final_decision__c!=null && CPResponse.cpData.final_decision__c.equalsIgnoreCase('Decline') && CPResponse.cpData.request_intent__c!=null && CPResponse.cpData.request_intent__c.equalsIgnoreCase('verification')) {
                        List<Application_Tags__c> lstAppTags = [SELECT Application_Tag__c FROM Application_Tags__c where Application__c = :appId and Application_Tag__c LIKE '%Stacker Check Declined%' and softDelete__c = false];	//pallavi LOS-212
                            if(lstAppTags.isEmpty()){ 
                        Application_Tags__c appTags = new Application_Tags__c();
                                appTags.Application__c = appId;
                                appTags.Application_Tag__c = 'Stacker Check Declined';
                      insert appTags;        
                    }}
                    System.Debug('****StackerCheck after Insert******' + CPResponse.adverseActionData);
                     update StackCheckapplistToUpdate[0];
                }     
                
                
                
            }catch(Exception ex){
                clcommon__batch_process_log__c logs = new clcommon__batch_process_log__c(clcommon__Message__c='Error in parsing Credit Policy response:  '+ex.getlinenumber()+'Error: '+ex.getMessage());
                insert logs;
                System.debug('Exception: '+ex.getMessage());
                System.debug('Exception stack: '+ex.getStackTraceString() + 'Mes**' + ex.getMessage() + ' on line number ' + ex.getLineNumber());
                throw new ints.IntegrationException(' API call failure Message: '+ex.getMessage() + ' on line number ' + ex.getLineNumber());
            }
            return CPResponse;
        }
        /*
        bureau_report_subset Information. 
        */
        global class BureauRequestAPI
        {
            global String bureau_request_uid {get;set;}   
            global Integer AADM12_credit_vision_alternative_risk_score {get;set;} 
            global Integer AGG901_non_mortgage_increases_last_3_mo {get;set;}  
            global Integer W55_AGG901_non_mortgage_increases_last_3_mo {get;set;}
            global Integer AGG909_mo_since_max_bankcard_balance {get;set;}
            global Integer W55_AGG909_mo_since_max_agg_bnkcrd_bal_over_last_12mo {get;set;}
            global String AGG911_max_bankcard_utilization   {get;set;}
            global String W55_AGG911_max_agg_bnkcrd_util_over_last_year   {get;set;}
            global Integer AGGS903_monthly_spend    {get;set;}
            global Integer W55_AGGS903_monthly_spend    {get;set;}
            global Integer AT02S_open_trades    {get;set;}
            global Integer V71_AT02S_open_trades    {get;set;}
            global Integer AT03S_satisfactory_open_trades   {get;set;}
            global Integer V71_AT03S_satisfactory_open_trades   {get;set;}
            global Integer AT103S_percent_satisfactory_trades_last_24_mo {get;set;}
            global Integer V71_AT103S_percent_satisfactory_trades_last_24_mo {get;set;}
            global Integer AT104S_percent_trades_opened_last_24_mo  {get;set;}
            global Integer V71_AT104S_pct_all_trd_opned_pst_24mo_all_trd  {get;set;}
            global Integer AT20S_mo_since_oldest_trade_opened {get;set;}
            global Integer V71_AT20S_mo_since_oldest_trd_opn {get;set;}
            global Integer BC02S_open_credit_cards {get;set;}
            global Integer V71_BC02S_open_credit_cards {get;set;}
            global Integer BC20S_mo_since_oldest_credit_card_opened {get;set;}
            global Integer V71_BC20S_mo_since_oldest_cc_trd_opned {get;set;}
            global Integer BR109S_revolving_trades_with_past_due_over_50_days {get;set;}
            global Integer V71_BR109S_revolving_trades_with_past_due_over_50_days {get;set;}
            global String EPAY01_ATTR06_student_loan_monthly_payment {get;set;}
            global String W49_ATTR06_cur_pmt_amt_1st_most_recently_updated_opn_pers_ln {get;set;}
            global String EPAY01_ATTR10_payments_mortgage_trade_highest_high_credit {get;set;}
            global String W49_ATTR10_payments_mortgage_trade_highest_high_credit {get;set;}
            global Integer EPAY01_AUP1003_auto_trade_monthly_payment {get;set;}
            global Integer W49_AUP1003_auto_trade_monthly_payment {get;set;}
            global Integer FI02S_installment_trades {get;set;}
            global Integer V71_FI02S_installment_trades {get;set;}
            global Integer G058S_trades_30_days_past_due_last_6_mo {get;set;}
            global Integer V71_G058S_num_trd_30_or_more_dpd_pst_6mo {get;set;}
            global Integer G061S_trades_30_days_past_due_last_24_mo {get;set;}
            global Integer V71_G061S_num_trd_30_or_more_dpd_pst_24mo {get;set;}
            global Integer G069S_trades_90_days_past_due_last_12_mo {get;set;}
            global Integer V71_G069S_trades_90_days_past_due_last_12_mo {get;set;}
            global Integer G095S_mo_since_global_record {get;set;}
            global Integer G209S_mo_since_recent_charge_off_opened {get;set;}  
            global Integer V71_G209S_mo_since_recent_charge_off_opened {get;set;}
            global Integer G215B_non_medical_collections {get;set;}
            global Integer V71_G215B_non_medical_collections {get;set;}
            global Integer HIAP01_home_equity_monthly_payment {get;set;}
            global Integer V71_HIAP01_home_equity_monthly_payment {get;set;}
            global Integer IN33S_installment_trades_balance {get;set;}
            global Integer V71_IN33S_installment_trades_balance {get;set;}
            global Integer IN34S_utilization_installment_trades_last_12_mo {get;set;}
            global Integer V71_IN34S_utilization_installment_trades_last_12_mo {get;set;}
            global Integer INAP01_installment_trades_monthly_payment {get;set;}
            global Integer V71_INAP01_installment_trades_monthly_payment {get;set;}
            global Integer MT101S_total_mortgage_balance {get;set;}
            global Integer V71_MT101S_total_mortgage_balance {get;set;}
            global Integer MT21S_mo_since_recent_mortgage_trade_opened {get;set;}
            global Integer V71_MT21S_mo_since_recent_mortgage_trade_opened {get;set;}
            global String PAYMNT08_min_payment_revolving_ratio {get;set;}
            global String W55_PAYMNT08_ratio_actual_min_pmt_for_rvl_trd_last_mo {get;set;}
            global Integer RE101S_revolving_trades_balance {get;set;}
            global Integer V71_RE101S_revolving_trades_balance {get;set;}
            global Integer RE31S_percent_high_revolving_trade_utilization {get;set;}
            global Integer V71_RE31S_pct_opn_rvl_trd_gt_75pct_credln_verif_pst_12mo {get;set;}
            global Integer RE33S_open_revolving_trades_balance {get;set;}
            global Integer V71_RE33S_open_revolving_trades_balance {get;set;}
            global Integer REAP01_revolving_trade_monthly_payment {get;set;}
            global Integer V71_REAP01_total_sched_mo_pmt_for_all_rvl_trd_verif_pst_12mo {get;set;}
            global Integer RVLR04_retail_revolver_trade_balance {get;set;}
            global Integer W55_RVLR04_retail_revolver_trade_balance {get;set;}
            global String RVLR14_revolver_transactor_inactive_pattern {get;set;}
            global String W55_RVLR14_revolver_transactor_inactive_pattern {get;set;}
            global Integer SCRG082_trades_past_due_last_2_mo {get;set;}
            global Integer N05_G082_trades_past_due_last_2_mo {get;set;}
            global Integer SCRG085_trades_90_days_past_due_last_2_mo {get;set;}
            global Integer N05_G085_trades_90_days_past_due_last_2_mo {get;set;}
            global Integer SCRG086_trades_120_days_past_due_last_2_mo {get;set;}
            global Integer N05_G086_trades_120_days_past_due_last_2_mo {get;set;}
            global Integer SCRG087_trades_150_days_past_due_last_2_mo {get;set;}
            global Integer N05_G087_trades_150_days_past_due_last_2_mo {get;set;}
            global Integer SCRIN07_installment_trades_opened_last_12_mo {get;set;}
            global Integer N05_IN07_installment_trades_opened_last_12_mo {get;set;}
            global Integer S114S_inquiries_last_6_mo {get;set;}
            global Integer V71_S114S_num_dedup_inq_pst_6mo_excl_auto_mtg_inq {get;set;}
            global Integer ST06S_student_loan_trades_opened_last_6_mo {get;set;}
            global Integer V71_ST06S_student_loan_trades_opened_last_6_mo {get;set;}
            global Integer TRV01_mo_since_overlimit_on_bankcard {get;set;}
            global Integer W55_TRV01_num_mo_since_overlimit_on_a_bnkcrd {get;set;}
            global Integer TRV02_mo_overlimit_on_bankcard {get;set;}
            global Integer W55_TRV02_num_mo_overlimit_on_a_bnkcrd_over_last_12mo {get;set;}
            global Integer TRV12_revolving_high_credit_increases_last_3_mo {get;set;}
            global Integer W55_TRV12_num_rvl_high_cred_incr_last_3mo {get;set;}
            global List<Inquiries> inquiries {get;set;}
            global Integer fico_score;  
            global String consumer_id;
            global List<String> fico_score_factors {get;set;} 
            global Boolean file_inquiries_impacted_score {get;set;} 
            global List<Trades> trades {get;set;}

            /* Bureau changed bureau_date_of_birth array to string in 6.2.  Handling this manually.*/
            /*global List<String> bureau_social_security_number {get;set;}*/
            global List<String> manual_bureau_social_security_number {get;set;}
            global String manual_bureau_social_security_number_str {get;set;}

            /* Bureau changed bureau_date_of_birth array to string in 6.2.  Handling this manually.*/
            /*global List<String> bureau_date1_of_birth {get;set;}*/
            global List<String> manual_bureau_date1_of_birth {get;set;}
            global String manual_bureau_date1_of_birth_str {get;set;}
            global Integer months_since_oldest_trade {get;set;} 
            global Integer inquiries_last_6_months {get;set;} 
            global Integer number_of_open_trades {get;set;} 
            global Integer number_of_satisfactory_open_trades {get;set;} 
            global Integer number_of_delinquencies_last_2_years {get;set;} 
            global Integer number_of_current_delinquencies {get;set;} 
            global Integer number_of_tax_liens {get;set;} 
            global Integer number_of_90_day_delinquencies {get;set;} 
            global Integer number_of_trades_opened_in_last_12_months {get;set;} 
            global Integer global_records {get;set;} 
            global Integer revolving_balance {get;set;} 
            global String percent_high_card_utilization {get;set;} 
            global String months_since_derogatory_global_record {get;set;} 
            global Boolean no_hit {get;set;} 
            global Boolean frozen {get;set;} 
            global String bureau_inquiry_date {get;set;} 
            global String bureau_report_uid {get;set;}
            global Integer G095S_mo_since_public_record {get;set;}
            global Integer V71_G095S_mo_since_public_record {get;set;}
            global Integer V71_AT09S_num_trd_opned_pst_24mo {get;set;}
        }
        
        global class Inquiries {
            global String ecoa_designator {get;set;} 
            global Subscriber subscriber {get;set;} 
            global Requestor requestor {get;set;} 
            global String date1 {get;set;} 
        }    
        
        global class Subscriber {
            global String inquiry_subscriber_prefix_code {get;set;} 
            global String industry_code {get;set;} 
            global String member_code {get;set;} 
            global Name name {get;set;} 
        }
        
        global class Name {
            global String unparsed {get;set;} 
        }
        
        global class Account {
            global String type {get;set;}
            
        }         
        
        global class Trades {
            global Subscriber subscriber {get;set;} 
            global String portfolio_type {get;set;} 
            global String account_number {get;set;} 
            global String ecoa_designator {get;set;} 
            global String date_opened {get;set;} 
            global String date_effective {get;set;} 
            global String date_closed {get;set;} 
            global String closed_indicator {get;set;} 
            global String date_paid_out {get;set;}
            global String name {get;set;} 
            global String current_balance {get;set;} 
            global String high_credit {get;set;} 
            global String credit_limit {get;set;} 
            global String account_rating {get;set;} 
            global List<Remarks> remarks {get;set;} 
            // global Requestor terms {get;set;} 
            global Terms terms {get;set;}
            global Account account {get;set;} 
            global String past_due {get;set;} 
            global Payment_history payment_history {get;set;} 
            global Most_recent_payment most_recent_payment {get;set;} 
            global String update_method {get;set;} 
            global integer Balance{get;set;} 
            //global String abc;
            
            
        }
        
        global class Terms{
            global String payment_frequency {get;set;}
            global String payment_schedule_month_count {get;set;}
            global String scheduled_monthly_payment {get;set;}
        }   
        
        
        
        global class Remarks {
            global String code {get;set;} 
            global String type {get;set;} 
        }
        
        global class Payment_history {
            global List<Requestor> max_delinquency {get;set;} 
            global Payment_pattern payment_pattern {get;set;} 
            global Historical_counters historical_counters {get;set;} 
        }
        
        global class Payment_pattern {
            global String start_date {get;set;} 
            global String text {get;set;}
        }     
        
        global class Requestor{
            global String text {get;set;}
        }   
        
        global class Historical_counters {
            global String months_reviewed_count {get;set;} 
            global String late_30_days_total {get;set;} 
            global String late_60_days_total {get;set;} 
            global String late_90_days_total {get;set;} 
        }
        
        global class Most_recent_payment {
            global String Recentdate {get;set;} 
        }
        
        global BureauRequestAPI parseBRAPI(String json){
            //json=json.replace('type', 'type1');
            //json=json.replace('date', 'date');
            
            return (BureauRequestAPI) System.JSON.deserialize(json, BureauRequestAPI.class);
        }
        
        /*
    *  End of the bureau_report_subset Request associated classes.
    * @author- Nupur Bhagat_CG 
    */  
        
        global static Credit_Policy__c mappingOfFields(CreditPolicyResponse CPResponse,String accountID,String appId,String json)
        {
            String tradeLineanalysis;
            Credit_Policy__c  obj= new Credit_Policy__c();
            List<genesis__Applications__c> applistToUpdate = [Select id,Federal_tax_payment__c,Bureau_SSN__c,Bureau_DOB__c,state_tax_payment__c from genesis__Applications__c where id=: appId LIMIT 1 ];
    
            obj.Account__c=accountId;
            obj.Application__c=appId;
             /// Change with
            obj.Active__c = TRUE;
            if(CPResponse!=null && CPResponse.credit_policy_decision!=null && CPResponse.credit_policy_decision.raw_bureau_data != null){
                obj.Raw_XML__c = String.valueOF(CPResponse.credit_policy_decision.raw_bureau_data);
                
                obj.Consumer_status_Indicator__c = CPResponse.credit_policy_decision.raw_bureau_data.substringBetween('<consumerStatementIndicator>', '</consumerStatementIndicator>');
                if(obj.Consumer_status_Indicator__c == 'true'){
                obj.Consumer_Statement_Type__c = CPResponse.credit_policy_decision.raw_bureau_data.substringBetween('<consumerFileData><consumerStatement><type>', '</type>');
                obj.Consumer_Statement_Text__c = CPResponse.credit_policy_decision.raw_bureau_data.substringBetween('<text>', '</text></consumerStatement>');
                }
                 obj.Logistic_Prediction_Of_Default__c = CPResponse.credit_policy_decision.risk_models.V6.logistic_prediction_of_default;
            
            }
            else{
                obj.Raw_XML__c = 'No Data found in raw_bureau_data';
            }
            
            if(CPResponse!=null && CPResponse.credit_policy_decision!=null && CPResponse.credit_policy_decision.bureau_subset != null){
                String bureau_data = String.valueOF(CPResponse.credit_policy_decision.bureau_subset);
                System.debug(bureau_data);
               
                //Id CPid = CPResponse.cpData.id;
               // System.debug('id of cp' + CPid);
                 //String attnm = 'Bureau_subset_Data_'+CPid+'.xml';
                 //Attachment att = new Attachment(parentid=CPid, Name = attnm , Body = Blob.valueOf(bureau_data) );
                    //insert att;
               
            }
            else{
                obj.bureau_subset__c = 'No Data found in raw_bureau_data';
            }
            System.debug(CPResponse.credit_policy_decision.bureau_subset);
            
            if(CPResponse.credit_policy_decision.loan_amount_counteroffer != null){
                obj.loan_amount_counteroffer__c = Decimal.valueOf(CPResponse.credit_policy_decision.loan_amount_counteroffer);
            }
            
            if(CPResponse.credit_policy_decision.credit_policy_version != null) {
                obj.Credit_Policy_Version__c = CPResponse.credit_policy_decision.credit_policy_version;
            }
            
            if(CPResponse!=null && CPResponse.credit_policy_decision!=null && CPResponse.credit_policy_decision.tradeline_analysis!=null)
                tradeLineanalysis = CPResponse.credit_policy_decision.tradeline_analysis;            
            System.debug(' * * Raw_XML__c * *' + obj.Raw_XML__c);
            if(CPResponse!=null && CPResponse.credit_policy_decision !=null && CPResponse.credit_policy_decision.final_decision!=null)
                obj.final_decision__c = String.valueOF(CPResponse.credit_policy_decision.final_decision);
            
            if(CPResponse!=null && CPResponse.credit_policy_decision !=null && CPResponse.credit_policy_decision.days_since_unsecured_installment_inquiry!=null)
                obj.Days_Since_unsec_install_loan_inq__c = Decimal.valueOF(CPResponse.credit_policy_decision.days_since_unsecured_installment_inquiry);
            if(CPResponse!=null && CPResponse.credit_policy_decision !=null && CPResponse.credit_policy_decision.days_since_open_unsecured_installment_loan!=null)
                obj.Days_since_unsec_install_loan__c = Decimal.valueOF(CPResponse.credit_policy_decision.days_since_open_unsecured_installment_loan);
            if(CPResponse!=null && CPResponse.credit_policy_decision !=null && CPResponse.credit_policy_decision.request_intent!=null)
                obj.request_intent__c = String.valueOF(CPResponse.credit_policy_decision.request_intent);
            
            //*****Added by Snehal for CLS-527
            if(CPResponse!=null && CPResponse.credit_policy_decision !=null && CPResponse.credit_policy_decision.federal_tax_payment!=null)
            {    obj.Federal_tax__c = String.valueOF(CPResponse.credit_policy_decision.federal_tax_payment);
                 applistToUpdate[0].Federal_tax_payment__c = String.valueOF(CPResponse.credit_policy_decision.federal_tax_payment);
    
            }
            if(CPResponse!=null && CPResponse.credit_policy_decision !=null && CPResponse.credit_policy_decision.state_tax_payment!=null)
             {   obj.state_tax_payment__c = String.valueOF(CPResponse.credit_policy_decision.state_tax_payment);
                 applistToUpdate[0].state_tax_payment__c = String.valueOF(CPResponse.credit_policy_decision.state_tax_payment);
    
            }
            
            
            //************
            System.debug(' * * final_decision__c * *' + obj.final_decision__c);
                    
            
            if(tradeLineanalysis !=null){
                CreditPolicyResponse.TradelineAnalysis  trade_Analysis = CPResponse.parse(tradeLineanalysis);
                if(trade_Analysis!=null){
                    if(trade_Analysis.auto_loan_balance!=null)
                        obj.Auto_Loan_Balance__c=trade_Analysis.auto_loan_balance;
                    if(trade_Analysis.auto_loan_monthly_payment!=null)
                        obj.Auto_Loan_Monthly_Payments__c=trade_Analysis.auto_loan_monthly_payment;
                    if(trade_Analysis.auto_loan_count!=null)
                        obj.Auto_Loan_Total_Count__c=trade_Analysis.auto_loan_count;
                    if(trade_Analysis.credit_card_balance!=null)
                        obj.Credit_Card_Balances__c=trade_Analysis.credit_card_balance;
                    if(trade_Analysis.credit_card_limit!=null)
                        obj.Credit_Card_Limits__c=trade_Analysis.credit_card_limit;
                    if(trade_Analysis.credit_card_monthly_payments!=null)
                        obj.Credit_Card_Monthly_Payments__c=trade_Analysis.credit_card_monthly_payments;
                    if(trade_Analysis.credit_card_count!=null)
                        obj.Credit_Card_Total_Count__c=trade_Analysis.credit_card_count;
                    if(trade_Analysis.mortgage_balance!=null)
                        obj.Mortgage_Balance__c=trade_Analysis.mortgage_balance;
                    if(trade_Analysis.unsecured_installment_loan_balance!=null)
                        obj.Unsecured_Installment_Loans_Balance__c=trade_Analysis.unsecured_installment_loan_balance;
                    if(trade_Analysis.student_loan_balance!=null)
                        obj.Student_Loan_Balance__c=trade_Analysis.student_loan_balance;
                    if(trade_Analysis.student_loan_count!=null)
                        obj.Student_Loan_Count__c=trade_Analysis.student_loan_count;
                    if(trade_Analysis.mortgage_monthly_payment!=null)
                        obj.Mortgage_Monthly_Payments__c=trade_Analysis.mortgage_monthly_payment;
                    if(trade_Analysis.mortgage_count!=null)
                        obj.Mortgage_Total_Count__c =trade_Analysis.mortgage_count;
                    if(trade_Analysis.credit_card_utilization!=null)
                        obj.Credit_Card_Utilization__c=Integer.valueOf((trade_Analysis.credit_card_utilization));
                    if(trade_Analysis.credit_card_closed_with_balance_count!=null)
                        obj.Credit_Cards_Closed_with_Balance_Count__c=String.valueOf(trade_Analysis.credit_card_closed_with_balance_count);
                    if(trade_Analysis.heloc_balances!=null)
                        obj.HELOC_Balance__c=trade_Analysis.heloc_balances;
                    if(trade_Analysis.heloc_monthly_payment!=null)
                        obj.HELOC_Monthly_Payments__c=trade_Analysis.heloc_monthly_payment;
                    if(trade_Analysis.heloc_count!=null)
                        obj.HELOC_Total_Count__c=trade_Analysis.heloc_count;
                    if(trade_Analysis.student_loan_deferred_count!=null)
                        obj.Student_Loan_Deferred_Count__c=trade_Analysis.student_loan_deferred_count;
                    if(trade_Analysis.student_loan_monthly_payment!=null)
                        obj.Student_Loan_Monthly_Payments__c=trade_Analysis.student_loan_monthly_payment;
                    if(trade_Analysis.unsecured_installment_loan_count!=null)
                        obj.Unsecured_Installment_Loans_Count__c=trade_Analysis.unsecured_installment_loan_count;
                    if(trade_Analysis.unsecured_installment_loan_monthly_payment!=null)
                        obj.Unsecured_Installment_Loans_Monthly_Paym__c=trade_Analysis.unsecured_installment_loan_monthly_payment;
                    if(trade_Analysis.unsecured_installment_loan_opened_last_12_mo!=null)
                        obj.Unsecured_Installment_Loans_Opened_in_La__c=trade_Analysis.unsecured_installment_loan_opened_last_12_mo;
                }
            }
            try{
                
                if(CPResponse!=null && CPResponse.credit_policy_decision!=null && CPResponse.credit_policy_decision.tradeline_dti!=null)
                    obj.Debt_to_Income_DTI__c = math.round((CPResponse.credit_policy_decision.tradeline_dti * 100));
            } catch(Exception e){
                obj.Debt_to_Income_DTI__c = 0.00; 
            }
            try{
                
                if(CPResponse!=null && CPResponse.credit_policy_decision!=null && CPResponse.credit_policy_decision.monthly_dti!=null) {
                    Decimal monthlyDti = CPResponse.credit_policy_decision.monthly_dti * 100;
                    obj.Monthly_DTI__c = monthlyDti.setScale(2);
                } else {
                    obj.Monthly_DTI__c = 0.0; 
                }
            } catch(Exception e){
                obj.Monthly_DTI__c = 0.0; 
            }
            String BureauResponse;
            if(CPResponse!=null){
                    if(CPResponse.credit_policy_decision !=null){
                        if(CPResponse.credit_policy_decision.tradeline_unsecured_installment_loans_balance!=null)
                            obj.Tradeline_unsecured_installment_loan_bal__c  = CPResponse.credit_policy_decision.tradeline_unsecured_installment_loans_balance;
                        
                        if(CPResponse.credit_policy_decision.tradeline_revolving_trades_balance!=null)
                            obj.Tradeline_revolving_trades_balance__c  = CPResponse.credit_policy_decision.tradeline_revolving_trades_balance;
                        if(CPResponse.credit_policy_decision.max_unsecured_installment_loan_utilization!=null)
                            obj.Max_util_of_install_loan__c  = CPResponse.credit_policy_decision.max_unsecured_installment_loan_utilization;
                        if(CPResponse.credit_policy_decision.tradeline_non_mortgage_trades_monthly_payment!=null)
                            obj.Tradeline_non_mortgage_trade_monthly_pay__c  = CPResponse.credit_policy_decision.tradeline_non_mortgage_trades_monthly_payment;
                        
                        if(CPResponse.credit_policy_decision.tradeline_ndi!=null)
                            obj.Net_Disposable_Income_NDI__c = String.valueOf(CPResponse.credit_policy_decision.tradeline_ndi.setscale(2));
							
						/*pallavi(LOS-197)*/
						if(CPResponse.credit_policy_decision.pricing_test_bucket!=null)
                            obj.Pricing_test_bucket__c = CPResponse.credit_policy_decision.pricing_test_bucket;
						/*pallavi(LOS-197)*/
                    }
                    // Change this
                    if(CPResponse.credit_policy_decision !=null && CPResponse.credit_policy_decision.bureau_subset!=null)
                        BureauResponse = CPResponse.credit_policy_decision.bureau_subset;
                    System.debug(' * * Credit Policy Information * *' + BureauResponse);
                
            }
            if(BureauResponse!=null){  
                System.debug('***BureauResponse***' + BureauResponse);
                //obj.bureau_subset__c = String.ValueOf(CPResponse.credit_policy_decision.bureau_subset);

                /**
                 * NOTE: the following line names all fields with date in the bureau string.
                 * Not sure the history of it, seems dangerous
                 */
                BureauResponse = BureauResponse.replace('date', 'date1');           
                CreditPolicyResponse.BureauRequestAPI bureauReq = (BureauRequestAPI)System.JSON.deserialize(BureauResponse,BureauRequestAPI.class);
                Map<String, Object> bureauUntypedResponse = (Map<String, Object>) System.JSON.deserializeUntyped(BureauResponse);

                if(bureauReq!=null){
                    //obj.bureau_subset__c = String.ValueOf(BureauResponse);
                    if(bureauReq.fico_score!=null)
                        obj.FICO__c = bureauReq.fico_score;
                    System.debug('***bureauReq***' + bureauReq);
                    if(bureauReq.fico_score_factors!=null){
                        if(bureauReq.fico_score_factors.size()>0)
                            obj.Score_Factors__c =bureauReq.fico_score_factors[0]; 
                    }

                    parseBureauSSN(bureauUntypedResponse, bureauReq, applistToUpdate);

                    if(bureauReq.consumer_id !=null){
                        System.debug('****consumer id****' + bureauReq.consumer_id );
                        applistToUpdate[0].TU_Consumer_Id__c = String.valueOF(bureauReq.consumer_id);
                    }

                    parseBureauDateOfBirth(bureauUntypedResponse, bureauReq, applistToUpdate);

                    if(bureauReq.inquiries_last_6_months!=null)         
                        obj.Inquiries_Last_6_Mo__c = bureauReq.inquiries_last_6_months;
                    if(bureauReq.months_since_oldest_trade!=null)
                        obj.Months_Since_Oldest_Trade__c=bureauReq.months_since_oldest_trade;
                    if(bureauReq.number_of_tax_liens!=null)
                        obj.Tax_Liens__c                =bureauReq.number_of_tax_liens;
                    if(bureauReq.number_of_open_trades!=null)
                        obj.Total_Open_Trades__c        =bureauReq.number_of_open_trades;
                    if(bureauReq.bureau_inquiry_date!=null)
                        obj.Bureau_Inquiry_Date__c      =bureauReq.bureau_inquiry_date;
                    /**
                    *Changes For CLS 384
                    **/
                    if(bureauReq.G058S_trades_30_days_past_due_last_6_mo !=null)
                        obj.X30_Delinq_6months__c = bureauReq.G058S_trades_30_days_past_due_last_6_mo;
                    if(bureauReq.RE31S_percent_high_revolving_trade_utilization !=null)
                        obj.Rev_75_12months__c =    bureauReq.RE31S_percent_high_revolving_trade_utilization;
                    if(bureauReq.BC20S_mo_since_oldest_credit_card_opened!=null)
                        obj.Age_Oldest_Crc_mo__c =  bureauReq.BC20S_mo_since_oldest_credit_card_opened;
                    if(bureauReq.AGG901_non_mortgage_increases_last_3_mo!=null)
                        obj.Bal_Increases_3mo__c =  bureauReq.AGG901_non_mortgage_increases_last_3_mo;
                    if(bureauReq.AGG911_max_bankcard_utilization!=null)
                        obj.Agg_utilization_12mo__c =   bureauReq.AGG911_max_bankcard_utilization;
                    if(bureauReq.TRV12_revolving_high_credit_increases_last_3_mo!=null)
                        obj.Rev_Inc_3mo__c =    bureauReq.TRV12_revolving_high_credit_increases_last_3_mo;
                    if(bureauReq.PAYMNT08_min_payment_revolving_ratio!=null)
                        obj.Revolving_Actual_Min_payment_1mo__c =   bureauReq.PAYMNT08_min_payment_revolving_ratio;
                    if(bureauReq.G215B_non_medical_collections!=null)
                        obj.Non_med_Col_0__c =  bureauReq.G215B_non_medical_collections;
                    if(bureauReq.G209S_mo_since_recent_charge_off_opened!=null)
                        obj.Recent_Charge_off_mo__c =   bureauReq.G209S_mo_since_recent_charge_off_opened;
                    if(bureauReq.FI02S_installment_trades!=null)
                        obj.Open_Fin_Inst_Trades__c =   bureauReq.FI02S_installment_trades;
                    if(bureauReq.S114S_inquiries_last_6_mo!=null)
                        obj.Deduped_inq_6mo__c =    bureauReq.S114S_inquiries_last_6_mo;
                    if(bureauReq.AT104S_percent_trades_opened_last_24_mo!=null)
                        obj.Trades_open_last_24_mos_All_Trades__c = bureauReq.AT104S_percent_trades_opened_last_24_mo;
                    if(bureauReq.G095S_mo_since_public_record!=null){
                        if(bureauReq.G095S_mo_since_public_record<0) obj.MosSinceDerog__c = 0;
                        if(bureauReq.G095S_mo_since_public_record>=0) obj.MosSinceDerog__c =  bureauReq.G095S_mo_since_public_record; } 
                    if(bureauReq.G069S_trades_90_days_past_due_last_12_mo!=null)
                        obj.trades_90_Day_Delinq_in_last_12_mos__c =  bureauReq.G069S_trades_90_days_past_due_last_12_mo;
                    if(bureauReq.AADM12_credit_vision_alternative_risk_score!=null)
                        obj.AlternativeRiskScore__c =   bureauReq.AADM12_credit_vision_alternative_risk_score;
                    if(bureauReq.AT103S_percent_satisfactory_trades_last_24_mo!=null)
                        obj.Satisfactory_Trades_All_Trades__c = bureauReq.AT103S_percent_satisfactory_trades_last_24_mo;

                    /* LOP-241 update parser to v6 */
                    if(bureauReq.V71_G058S_num_trd_30_or_more_dpd_pst_6mo !=null)
                        obj.X30_Delinq_6months__c = bureauReq.V71_G058S_num_trd_30_or_more_dpd_pst_6mo;
                    if(bureauReq.V71_RE31S_pct_opn_rvl_trd_gt_75pct_credln_verif_pst_12mo !=null)
                        obj.Rev_75_12months__c =    bureauReq.V71_RE31S_pct_opn_rvl_trd_gt_75pct_credln_verif_pst_12mo;
                    if(bureauReq.V71_BC20S_mo_since_oldest_cc_trd_opned!=null)
                        obj.Age_Oldest_Crc_mo__c =  bureauReq.V71_BC20S_mo_since_oldest_cc_trd_opned;
                    if(bureauReq.W55_AGG901_non_mortgage_increases_last_3_mo!=null)
                        obj.Bal_Increases_3mo__c =  bureauReq.W55_AGG901_non_mortgage_increases_last_3_mo;
                    if(bureauReq.W55_AGG911_max_agg_bnkcrd_util_over_last_year!=null)
                        obj.Agg_utilization_12mo__c =   bureauReq.W55_AGG911_max_agg_bnkcrd_util_over_last_year;
                    if(bureauReq.W55_TRV12_num_rvl_high_cred_incr_last_3mo!=null)
                        obj.Rev_Inc_3mo__c =    bureauReq.W55_TRV12_num_rvl_high_cred_incr_last_3mo;
                    if(bureauReq.W55_PAYMNT08_ratio_actual_min_pmt_for_rvl_trd_last_mo!=null)
                        obj.Revolving_Actual_Min_payment_1mo__c =   bureauReq.W55_PAYMNT08_ratio_actual_min_pmt_for_rvl_trd_last_mo;
                    if(bureauReq.V71_G215B_non_medical_collections!=null)
                        obj.Non_med_Col_0__c =  bureauReq.V71_G215B_non_medical_collections;
                    if(bureauReq.V71_G209S_mo_since_recent_charge_off_opened!=null)
                        obj.Recent_Charge_off_mo__c =   bureauReq.V71_G209S_mo_since_recent_charge_off_opened;
                    if(bureauReq.V71_FI02S_installment_trades!=null)
                        obj.Open_Fin_Inst_Trades__c =   bureauReq.V71_FI02S_installment_trades;
                    if(bureauReq.V71_S114S_num_dedup_inq_pst_6mo_excl_auto_mtg_inq!=null)
                        obj.Deduped_inq_6mo__c =    bureauReq.V71_S114S_num_dedup_inq_pst_6mo_excl_auto_mtg_inq;
                    if(bureauReq.V71_G095S_mo_since_public_record!=null){
                        if(bureauReq.V71_G095S_mo_since_public_record<0) obj.MosSinceDerog__c = 0;
                        if(bureauReq.V71_G095S_mo_since_public_record>=0) obj.MosSinceDerog__c =  bureauReq.V71_G095S_mo_since_public_record; }
                    if(bureauReq.V71_G069S_trades_90_days_past_due_last_12_mo!=null)
                        obj.trades_90_Day_Delinq_in_last_12_mos__c =  bureauReq.V71_G069S_trades_90_days_past_due_last_12_mo;
                    if(bureauReq.V71_AT103S_percent_satisfactory_trades_last_24_mo!=null)
                        obj.Satisfactory_Trades_All_Trades__c = bureauReq.V71_AT103S_percent_satisfactory_trades_last_24_mo;
                    if(bureauReq.V71_AT09S_num_trd_opned_pst_24mo!=null) {
                        obj.Num_Trades_Opened_Past_24mo__c = bureauReq.V71_AT09S_num_trd_opned_pst_24mo;
                    }
                }
                
            }
            System.debug('***CP inside Field Mapping***' + obj);
            update applistToUpdate[0];
    
            return obj;
            
        }

        /**
         * This handles the surprise data type change to string from array.
         * Handle the date of birth field in a generic way just in case bureau reverts to original array.
         * Since its manual, setting available fields back to previously parsed.
         *
         * @param bureauUntypedResponse json object parsed untyped
         * @param bureauReq The previously deserialized json response
         * @param applistToUpdate The Application instance we're updating
         */
        private static void parseBureauDateOfBirth(Map<String, Object> bureauUntypedResponse, BureauRequestAPI bureauReq, List<genesis__Applications__c> applistToUpdate) {

            Object bureauBirthDateObj = bureauUntypedResponse.get('bureau_date1_of_birth');
            if (bureauBirthDateObj == null) {
                return;
            }

            Date dobDateTime;
            if (bureauBirthDateObj instanceof List<Object>) {
                bureauReq.manual_bureau_date1_of_birth = listObjToListStr((List<Object>) bureauBirthDateObj);
                dobDateTime = Date.valueOf(bureauReq.manual_bureau_date1_of_birth[0]);
            } else {
                bureauReq.manual_bureau_date1_of_birth_str = (String) bureauBirthDateObj;
                dobDateTime = Date.valueOf(bureauReq.manual_bureau_date1_of_birth_str);
            }

            String BureauDOB = dobDateTime.format();
            applistToUpdate[0].Bureau_DOB__c = BureauDOB;
            System.debug('*****bureauDOB****' + BureauDOB );
        }

        /**
         * This handles the surprise data type change to string from array.
         * Similar premise to date of birth change above.
         *
         * @param bureauUntypedResponse json object parsed untyped
         * @param bureauReq The previously deserialized json response
         * @param applistToUpdate The Application instance we're updating
         */
        private static void parseBureauSSN(Map<String, Object> bureauUntypedResponse, BureauRequestAPI bureauReq, List<genesis__Applications__c> applistToUpdate) {
            Object ssnObj = bureauUntypedResponse.get('bureau_social_security_number');
            System.debug('****bureau_social_security_number****' + ssnObj);
            if (ssnObj == null) {
                return;
            }

            String finalSsn;
            if (ssnObj instanceof List<Object>) {
                bureauReq.manual_bureau_social_security_number = listObjToListStr((List<Object>) ssnObj);
                finalSsn = bureauReq.manual_bureau_social_security_number[0];
            } else {
                bureauReq.manual_bureau_social_security_number_str = (String) ssnObj;
                finalSsn = bureauReq.manual_bureau_social_security_number_str;
            }
            applistToUpdate[0].Bureau_SSN__c = finalSsn;
        }

        private static List<String> listObjToListStr(List<Object> objs) {
            List<String> strs = new List<String>();
            for (Object obj : objs) {
                strs.add(obj == null ? null : obj.toString());
            }
            return strs;
        }

        global static List<Credit_Report_Details__c> fieldMapping(CreditPolicyResponse CPResponse,String bureauResponse, String accountID,String appId){
            list<Credit_Report_Details__c> listReport = new list<Credit_Report_Details__c>();
            
            CreditPolicyResponse.BureauRequestAPI bureauReq = CPResponse.parseBRAPI(BureauResponse);
            if(bureauReq!=null && bureauReq.trades!=null) {
            For(CreditPolicyResponse.Trades trade : bureauReq.trades){
                Credit_Report_Details__c report = new Credit_Report_Details__c();
                report.Account__c = accountId;
                report.Application__c=appId;
                report.Active__c = TRUE;
                report.Credit_Policy__c = CPResponse.cpData.id;
                System.debug(logginglevel.error,'TRADES +++'+ trade);
                
                System.debug(logginglevel.error,'TRADES - ACCOUNT +++'+ trade.account);
                if(trade.account != null){
                    if(trade.account.type!=null){
                        //system.debug('trade.account.type'+trade.account.type);
                        if(/*(trade.portfolio_type != 'installment') &&*/ (trade.account.type== 'CC' || 
                                                                        trade.account.type=='FX'|| trade.account.type =='CH'||
                                                                        trade.account.type =='BC'|| trade.account.type == 'SC')) 
                        {
                            report.Account_Type__c= 'CREDIT CARD';}
                        
                        
                        else if(/*(trade.portfolio_type != 'installment') &&*/ 
                                trade.account.type == 'ST' ){
                                    report.Account_Type__c= 'STUDENT LOAN';}
                        
                        else if(/*(trade.portfolio_type != 'installment') &&*/
                                (trade.account.type == 'CV'||trade.account.type == 'CY' ||trade.account.type == 'FL' 
                                 || trade.account.type =='FR' || trade.account.type =='RM' ||trade.account.type == 'SM' 
                                 || trade.account.type =='VM' || trade.account.type == 'MB' ))
                        {
                            report.Account_Type__c= 'MORTGAGE';}
                        
                        else if(/*(trade.portfolio_type != 'installment') &&*/
                                (trade.account.type == 'AU' || trade.account.type == 'AL' ))
                        {
                            report.Account_Type__c= '  AUTO LOAN';}
                        
                        else if(/*(trade.portfolio_type != 'installment') &&*/ (trade.account.type == 'HE'))
                            report.Account_Type__c= ' HELOC';
                        
                        
                        else if(/*(trade.portfolio_type != 'installment') &&*/ (trade.account.type== 'US')){
                            report.Account_Type__c= ' UNSECURED IL';}
                        
                        else if(/*(trade.portfolio_type != 'installment') &&*/ (trade.account.type == 'LC' ||trade.account.type == 'CE')){
                            report.Account_Type__c= ' LINE OF CREDIT';}
                        
                        
                        
                        else{
                            report.Account_Type__c= 'OTHER';
                            
                            if(trade.account.type =='AX' || trade.account.type =='CP' ||
                               trade.account.type =='CU' ||trade.account.type =='DC' ||
                               trade.account.type =='DR' ||trade.account.type =='FI' ||
                               trade.account.type =='FM' ||trade.account.type=='GS' ||
                               trade.account.type=='HI' ||trade.account.type=='LE' ||
                               trade.account.type =='LS' ||trade.account.type =='RA' ||
                               trade.account.type=='RC' ||trade.account.type=='RD' ||
                               trade.account.type =='RE' ||trade.account.type=='SE' ||
                               trade.account.type =='SH' ||trade.account.type=='SI' ||
                               trade.account.type =='SO' ||trade.account.type =='UC'){
                                   report.Account_Type__c= 'OTHER';}
                            else
                                report.Account_Type__c= ' UNSECURED IL';
                            }
                    }
                
                
                if(trade.subscriber.name.unparsed != null)
                    report.Account_Name__c = trade.subscriber.name.unparsed;
                //if(trade.account.type != null)
                //report.Account_Type__c = trade.account.type;
                System.debug(logginglevel.error,'Account name' +report.Account_Name__c );
                System.debug(logginglevel.error,'Account Type' +report.Account_Type__c );
                
                if(trade.current_balance!=null)
                    report.Balance__c = Decimal.valueof(trade.current_balance);
                if(trade.date_closed!=null)
                    report.Date_Closed__c = trade.date_closed;
                if(trade.date_opened!=null)
                    report.Date_Opened__c = trade.date_opened;
                if(trade.high_credit!=null)
                    report.High_credit__c = Decimal.valueOf(trade.high_credit);
                if(trade.credit_limit!=null)
                    report.Limit__c= Decimal.valueof(trade.credit_limit);
                //if(trade.account!=null && trade.account.AccountName!=null)
                //report.Account_Name__c = trade.account.AccountName;
                if(trade.remarks!=null){
                    for(remarks rem: trade.remarks){
                        if(rem.code!=null && rem.type!=null)
                            report.Remarks__c='Code : ' +rem.code  +' and '+'  Type : '+rem.type;
                    }
                }
                if(trade.terms!=null && trade.terms.scheduled_monthly_payment!=null)
                    report.Monthly_Payment__c =Decimal.ValueOf(trade.terms.scheduled_monthly_payment);
                if(trade.account_rating!=null){
                    if(trade.account_rating == '01')
                        report.Status__c = 'Good';
                    else
                        report.Status__c='Bad';
                }
                
                // report.Interest_Rate__c = 0;
                
                listreport.add(report);
            }
            }
            }
            return listreport;
            
        }
        
        global static List<Adverse_Actions__c> mappingOfAdverseAction(Decision_codes decisionCode,String accountID,String appId) {
            List<Adverse_Actions__c> adverse=new List<Adverse_Actions__c>();
              
              if(null != decisionCode.adverse_actions){
                  for(CreditPolicyResponse.Adverse_actions adv: decisionCode.Adverse_actions){
                      Adverse_Actions__c advobj=new Adverse_Actions__c();
                      advobj.Adverse_action_name__c=adv.name;
                      advobj.Description__c=adv.description;
                      advobj.Reason__c=adv.reason;
                      advobj.Account__c=accountID;
                      advobj.Application__c=appId;
                      adverse.add(advobj);
                  }
              }
              return adverse;
        }
        
        global static List<Score_Factors__c> mappingOfFieldscf(Decision_codes decisionCode,String accId,String appId){
              List<Score_Factors__c> scorefac=new List<Score_Factors__c>();
              
              if(null != decisionCode.score_factor_text){
                  for(CreditPolicyResponse.Prebureau_knockout_codes scfa : decisionCode.Score_factor_text){
                      Score_Factors__c scfobj=new Score_Factors__c();
                      scfobj.Rank__c=scfa.rank;
                      scfobj.Description__c=scfa.description;
                      scfobj.Code__c=Decimal.valueOf(scfa.code);
                      scfobj.Account__c=accId;
                      scfobj.Application__c=appId;
                      scorefac.add(scfobj);
                  }
              }
              return scorefac;
          }
        
        
        global static List<Hard_Inquiry_Meta_Data__c> mappingOfHardInquiryData(CreditPolicyResponse CPResponse,String accountID,String appId){  
            String BureauResponse;
            List<Hard_Inquiry_Meta_Data__c> hrdata= new List<Hard_Inquiry_Meta_Data__c>();
            //Hard_Inquiry_Meta_Data__c obj= new Hard_Inquiry_Meta_Data__c();
            if(CPResponse.credit_policy_decision !=null && CPResponse.credit_policy_decision.bureau_subset!=null)
                BureauResponse = CPResponse.credit_policy_decision.bureau_subset;
            
            if(BureauResponse!=null){  
                
                BureauResponse = BureauResponse.replace('date', 'date1');           
                CreditPolicyResponse.BureauRequestAPI bureauReq = (BureauRequestAPI)System.JSON.deserialize(BureauResponse,BureauRequestAPI.class);  
                if(bureauReq!=null){
                    if(bureauReq.inquiries!=null){
                        if(bureauReq.inquiries.size()>0){
                            for(CreditPolicyResponse.inquiries inq:bureauReq.inquiries){
                                Hard_Inquiry_Meta_Data__c obj= new Hard_Inquiry_Meta_Data__c();
                                obj.Account__c=accountID;
                                obj.Application__c=appId;
                                obj.Subscriber_Name__c=String.valueOf(inq.subscriber.name.unparsed);
                                obj.Credit_Policy__c = CPResponse.cpData.id;
                                system.debug(logginglevel.error,inq.date1);
                                //if(bureauReq.inquiries[0].date1!=null)
                                obj.Inquiry_Date__c=inq.date1;
                                // System.debug(logginglevel.error,'Hard_Inquiry_Meta_Data_Inquiry_Date +++'+ obj.Hard_Inquiry_Meta_Data_Inquiry_Date__c);
                                hrdata.add(obj);
                                System.debug('id of cp' + obj.Id);
                            }
                        }
                    }
                }
            } 
            //System.debug('id of cp' + obj.Id);
            return hrdata;
        }
    }