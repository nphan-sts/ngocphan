@isTest
private class TestCreditPolicyResponse {
    @testSetup static void setup(){
        //Creating Account
        Account acc = new Account(
            loan__Investor__c=False,
            Name='Testfname Testlname',
            cnotify__Email__c = 'abc@test.com',
            peer__First_Name__c= 'Testfname',
            peer__Last_Name__c= 'Testlname',
            loan__SOCIAL_SECURITY_NUMBER__c = '123123123'
        );
        insert acc;
        
        
        System.assertEquals('Testlname',acc.peer__Last_Name__c,'Wrong Account');
        
        //Creating Application
        genesis__Applications__c app= new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            Borrower_s_Email__c = null,
            genesis__Account__c = acc.Id,
            Application_Start_DateV2__c = system.Today(),
            DocuSignFlag__c=true,
            genesis__Status__c = 'Offer shown',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Lead_ID__c ='3270d13e-b8b7-6a60-4eb0-edffafa04f00'
        );
        insert app;
        System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');
        
    }
    
    Testmethod static void method1(){
        
        Manual_Adverse_Action_Decline__c mda = new 	Manual_Adverse_Action_Decline__c();
        mda.Decline_Name__c = 'insufficient tradeline balance';
        mda.Description__c = 'So we are unable to proceed with your loan application.';
        mda.Name = 'Expiration_decline_insufficient_tradeline_balances';
        mda.Reason__c = 'Your unsecured consumer debt does not support the amount requested.';
        insert mda;
        Account acc1 = [Select id,name from Account where name='Testfname Testlname' limit 1];
        
        genesis__Applications__c app1 = [select id,genesis__Status__c,Lead_ID__c from genesis__Applications__c where genesis__Status__c='Offer shown' limit 1];
        app1.Manual_Adverse_Action_Decline__c = mda.Id;
        
        update app1;
        //String bureau = '{"HIAP01_home_equity_monthly_payment":-1,"AADM12_credit_vision_alternative_risk_score":1234,"AGG901_non_mortgage_increases_last_3_mo":6789}';
        //String json = '{"credit_policy_decision":{"credit_policy_version":"v3","credit_policy_gem_version":"4.1.33","tradeline_analysis":"{}","Bureau_subset":"{}","source":"payoff","tradeline_revolving_trades_balance":2345.89,"max_unsecured_installment_loan_utilization":0.0,"days_since_open_unsecured_loan":"819.0","tradeline_unsecured_installment_loans_balance":0.0,"tradeline_ndi":"1867.3125","tradeline_non_mortgage_trades_monthly_payment":453.0,"days_since_open_unsecured_installment_loan":"919.0","days_since_unsecured_installment_inquiry":"89.0","raw_bureau_data":"raw bureau data","loan_amount_counteroffer":"7000","final_decision":"Decline","request_intent":"verification","federal_tax_payment":"3251.25","state_tax_payment":"3905.0","tradeline_dti":0.491771428571429,"monthly_dti":0.23423452,"decision_codes":{"invalid_input_knockout_codes":["invalid_data_PAYMNT08_min_payment_revolving_ratio_missing","invalid_data_TRV12_revolving_high_credit_increases_last_3_mo_missing","invalid_data_RVLR14_revolver_transactor_inactive_pattern_missing"],"prebureau_knockout_codes":[],"postbureau_knockout_codes":[],"risk_model_codes":["risk_model_fico_score_low","risk_model_ndi_low","risk_model_percent_satisfactory_trades_last_24_mo_low","risk_model_mo_since_oldest_credit_card_opened_low"],"adverse_actions":[{"reason":"No reason","name":"Test","description":"No"}],"score_factor_text":[{"rank":"10","description":"ddesc","code":"123.678"}]},"metadata":{"status":200}}}';                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
        //String json = '{"credit_policy_decision":{"credit_policy_version":"v3","credit_policy_gem_version":"4.1.33","source":"payoff","days_since_open_unsecured_loan":"819.0","days_since_open_unsecured_installment_loan":"919.0","days_since_unsecured_installment_inquiry":"89.0","raw_bureau_data":"raw bureau data","loan_amount_counteroffer":"7000","final_decision":"Decline","request_intent":"verification","federal_tax_payment":3251.25,"state_tax_payment":3905.0,"tradeline_dti":0.491771428571429,"monthly_dti":0.23423452,"tradeline_unsecured_installment_loans_balance":0.0,"tradeline_revolving_trades_balance":"17212.0","max_unsecured_installment_loan_utilization":"0.0","tradeline_non_mortgage_trades_monthly_payment":"453.0","tradeline_ndi":"1867.3125","decision_codes":{"invalid_input_knockout_codes":["invalid_data_PAYMNT08_min_payment_revolving_ratio_missing","invalid_data_TRV12_revolving_high_credit_increases_last_3_mo_missing","invalid_data_RVLR14_revolver_transactor_inactive_pattern_missing"],"prebureau_knockout_codes":[],"postbureau_knockout_codes":[],"risk_model_codes":["risk_model_fico_score_low","risk_model_ndi_low","risk_model_percent_satisfactory_trades_last_24_mo_low","risk_model_mo_since_oldest_credit_card_opened_low"],"adverse_actions":[{"reason":"No reason","name":"Test","description":"No"}],"score_factor_text":[]},"probability_differences":{"risk_model_min_payment_revolving_ratio_low":-0.19750776338280002,"risk_model_trades_30_days_past_due_high":0.0,"risk_model_inquiries_last_6_mo_high":-0.02342364,"risk_model_mo_since_recent_charge_off_opened_low":0.0,"risk_model_non_mortgage_increases_high":"-0.14200806","risk_model_percent_delinquency_high":"0.0","risk_model_percent_high_revolving_trade_utilization_high":"-0.16278675","risk_model_ndi_low":"-0.5557961939400001","risk_model_consumer_tri_highest_card_type_t_low":"-0.05804013","risk_model_mo_since_oldest_credit_card_opened_low":"-0.23259331","risk_model_dti_high":"-0.06538871167038594285714285714285714285714371234442228","risk_model_percent_satisfactory_trades_last_24_mo_low":-0.48671481,"risk_model_overlimit_trend_high":"0.0","risk_model_consumer_tri_highest_card_type_i_high":"0.0","risk_model_max_bankcard_utilization_high":-0.10801354,"risk_model_percent_trades_opened_last_24_mo_high":0.0,"risk_model_non_medical_collections_high":0.0,"risk_model_number_of_open_credit_cards_high":-0.14254735,"risk_model_fico_score_low":"-1.820333939999999667","risk_model_revolving_high_credit_increases_high":-0.07806163,"risk_model_installment_loans_high":"0.0"},"tradeline_analysis":{"credit_card_count":8,"credit_card_balance":17212,"credit_card_limit":17100,"credit_card_utilization":100.65497076023391,"credit_card_monthly_payments":311,"credit_card_closed_with_balance_count":0,"unsecured_installment_loan_count":0,"unsecured_installment_loan_balance":0,"unsecured_installment_loan_opened_last_12_mo":0,"unsecured_installment_loan_monthly_payment":0,"student_loan_count":2,"student_loan_balance":9549,"student_loan_monthly_payment":142,"student_loan_deferred_count":0,"auto_loan_count":0,"auto_loan_balance":0,"auto_loan_monthly_payment":0,"mortgage_count":0,"mortgage_balance":0,"mortgage_monthly_payment":0,"heloc_count":0,"heloc_balances":0,"heloc_monthly_payment":0},"_metadata":{"status":200}}}';                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
        // String json1 = '{"credit_policy_decision":{"raw_bureau_data":"raw bureau data","final_decision":"Decline","request_intent":"verification"';
        String json = '{"credit_policy_decision": {"risk_model_source": "hm", "risk_model_version": "6.0123", "is_offer_presented": true, "pricing_policy_filters": null,"offers": [{"amount": "7000","origination_fee": "0.0","key": "1","monthly_payment": "310.21","apr": "5.99","type": "USRule360Loan","interest_rate": "5.99","segment": "prime","term_months": 24,"origination_fee_discount": "140.0","pricing_tier": "t1","origination_fee_rate_discount": "2.0","above_prime_max": "false","origination_fee_rate": "0.0"}],"balance_to_income_with_lie_detector": 0.34795,"tradeline_summary_of_balances": 34795,"request_intent": "application","tradeline_revolving_trades_balance": 34795,"tradeline_open_unsecured_installment_loans": 0,"request_context": "active","student_loan_flag": null,"max_unsecured_installment_loan_utilization": 0,"tri_highest_card_type_t": null,"btiwlie_balmag01_product": null,"balance_to_income": 0.34795,"federal_tax_payment": 17131.99541591809,"credit_policy_version": "v3","tradeline_unsecured_installment_loans_opened_last_12_mo": 0,"def_remark_flag": 0,"funding_model": "null","debt_to_income": 0.0000105574,"state_tax_payment": 12777.5,"tradeline_ndi": 3624.875382006826,"suppress_flag": 0,"tri_highest_card_type_i": null,"overlimit_trend": null,"percent_new_bc_trades_in_last_year": 0,"tradeline_dti": 0.34795,"tradeline_analysis": "{\\"credit_card_count\\":21,\\"credit_card_balance\\":32911,\\"credit_card_limit\\":166000,\\"credit_card_utilization\\":19.825903614457832,\\"credit_card_monthly_payments\\":481,\\"credit_card_closed_with_balance_count\\":0,\\"unsecured_installment_loan_count\\":0,\\"unsecured_installment_loan_balance\\":0,\\"unsecured_installment_loan_opened_last_12_mo\\":0,\\"unsecured_installment_loan_monthly_payment\\":0,\\"student_loan_count\\":0,\\"student_loan_balance\\":0,\\"student_loan_monthly_payment\\":0,\\"student_loan_deferred_count\\":0,\\"auto_loan_count\\":1,\\"auto_loan_balance\\":396,\\"auto_loan_monthly_payment\\":512,\\"mortgage_count\\":1,\\"mortgage_balance\\":152070,\\"mortgage_monthly_payment\\":1312,\\"heloc_count\\":1,\\"heloc_balances\\":70383,\\"heloc_monthly_payment\\":223}","traditional_dti": 0.26592,"age_flag": null,"days_since_open_unsecured_loan": 479,"payoff_uid": "9e9ea079-1fb5-e6b5-2dd8-f5e9d8924733","tradeline_unsecured_installment_loans_balance": 0,"tradeline_unsecured_installment_loans_opened_last_3_mo": null,"final_decision_level": "6.0","def_payment_flag": 0,"no_hit": false,"fico_inquiries_product": 0,"w55_agg910_unf": null,"invalid_missing_risk_model_variables": null,"bureau_subset": "{}","decision_codes": {"invalid_input_knockout_codes": [],"prebureau_knockout_codes": [],"postbureau_knockout_codes": [],"risk_model_codes": [8,4,3,21],"adverse_actions": [],"score_factor_text": [{"rank": 1,"code": "10","description": "Proportion of balances to credit limits on bank/national revolving or other revolving accounts is too high"},{"rank": 2,"code": "5","description": "Too many accounts with balances"},{"rank": 3,"code": "11","description": "Amount owed on revolving accounts is too high"},{"rank": 4,"code": "14","description": "Length of time accounts have been established"}]},"monthly_dti": 0.26592,"days_since_open_unsecured_installment_loan": null,"credit_policy_gem_version": "6.1.0","pricing_segment": null,"mod_remark_flag": 0,"tradeline_dti_with_lie_detector": 0.34795,"tradeline_alliant_charge_off": 0,"raw_bureau_data": "","net_disposable_income": 2947.308382006826,"pricing_tier": "t1","frozen_report": false,"days_since_unsecured_installment_inquiry": null,"adverse_action_template": "adverse_action","pricing_policy_gem_version": "0.5.0","disaster_remark_flag": 0,"risk_models": {"v3": {"risk_model_decision": "Approve","risk_model_score": -5.383537769317627,"logistic_prediction_of_default": 0.0045705633237957954,"invalid_risk_model_variable_count": 0,"probability_differences": {"risk_model_non_mortgage_increases_high":"none","risk_model_max_bankcard_utilization_high":0.234,"risk_model_percent_satisfactory_trades_last_24_mo_low":0.0,"risk_model_percent_trades_opened_last_24_mo_high":0.0003,"risk_model_number_of_open_credit_cards_high":"none","risk_model_mo_since_oldest_credit_card_opened_low":0.0,"risk_model_fico_score_low":"none","risk_model_installment_loans_high":0.0,"risk_model_trades_30_days_past_due_high":0.0,"risk_model_mo_since_recent_charge_off_opened_low":0.0,"risk_model_non_medical_collections_high":0.0,"risk_model_min_payment_revolving_ratio_low":"none","risk_model_percent_high_revolving_trade_utilization_high":"none","risk_model_inquiries_last_6_mo_high":"none","risk_model_revolving_high_credit_increases_high":"none","risk_model_dti_high":"none","risk_model_ndi_low":"none","risk_model_overlimit_trend_high":"none","risk_model_percent_delinquency_high":"none","risk_model_consumer_tri_highest_card_type_i_high":"none","risk_model_consumer_tri_highest_card_type_t_low":"none"}}},"tradeline_non_mortgage_trades_monthly_payment": 1416,"decision_reason": null,"pricing_test_bucket": "2021Feb_rollout","lie_detector_high": 0.1,"percent_delinquency": -0.004617607692307692,"loan_amount_counteroffer": null,"request_id": "9d3e6097-e916-4b24-9c04-6a44d5ca198f","final_decision": "Approve","tradeline_ndi_with_lie_detector": 3624.875382006826,"data": {"pricing_policy_filters": null,"offers": [{"amount": "7000","origination_fee": "0.0","key": "1","monthly_payment": "310.21","apr": "5.99","type": "USRule360Loan","interest_rate": "5.99","segment": "prime","term_months": 24,"origination_fee_discount": "140.0","pricing_tier": "t1","origination_fee_rate_discount": "2.0","above_prime_max": "false","origination_fee_rate": "0.0"}],"balance_to_income_with_lie_detector": 0.34795,"tradeline_summary_of_balances": 34795,"request_intent": "application","tradeline_revolving_trades_balance": 34795,"tradeline_open_unsecured_installment_loans": 0,"request_context": "active","student_loan_flag": null,"max_unsecured_installment_loan_utilization": 0,"tri_highest_card_type_t": null,"btiwlie_balmag01_product": null,"balance_to_income": 0.34795,"federal_tax_payment": 17131.99541591809,"credit_policy_version": "6.0","tradeline_unsecured_installment_loans_opened_last_12_mo": 0,"def_remark_flag": 0,"funding_model": null,"debt_to_income": 0.0000105574,"state_tax_payment": 12777.5,"tradeline_ndi": 3624.875382006826,"suppress_flag": 0,"tri_highest_card_type_i": null,"overlimit_trend": null,"percent_new_bc_trades_in_last_year": 0,"tradeline_dti": 0.34795,"tradeline_analysis": "{\\"credit_card_count\\":21,\\"credit_card_balance\\":32911,\\"credit_card_limit\\":166000,\\"credit_card_utilization\\":19.825903614457832,\\"credit_card_monthly_payments\\":481,\\"credit_card_closed_with_balance_count\\":0,\\"unsecured_installment_loan_count\\":0,\\"unsecured_installment_loan_balance\\":0,\\"unsecured_installment_loan_opened_last_12_mo\\":0,\\"unsecured_installment_loan_monthly_payment\\":0,\\"student_loan_count\\":0,\\"student_loan_balance\\":0,\\"student_loan_monthly_payment\\":0,\\"student_loan_deferred_count\\":0,\\"auto_loan_count\\":1,\\"auto_loan_balance\\":396,\\"auto_loan_monthly_payment\\":512,\\"mortgage_count\\":1,\\"mortgage_balance\\":152070,\\"mortgage_monthly_payment\\":1312,\\"heloc_count\\":1,\\"heloc_balances\\":70383,\\"heloc_monthly_payment\\":223}","traditional_dti": 0.26592,"age_flag": null,"days_since_open_unsecured_loan": 479,"payoff_uid": "9e9ea079-1fb5-e6b5-2dd8-f5e9d8924733","tradeline_unsecured_installment_loans_balance": 0,"tradeline_unsecured_installment_loans_opened_last_3_mo": null,"final_decision_level": "6.0","def_payment_flag": 0,"no_hit": false,"fico_inquiries_product": 0,"w55_agg910_unf": null,"invalid_missing_risk_model_variables": null,"decision_codes": {"invalid_input_knockout_codes": [],"prebureau_knockout_codes": [],"postbureau_knockout_codes": [],"risk_model_codes": [8,4,3,21],"adverse_actions": [],"score_factor_text": [{"rank": 1,"code": "10","description": "Proportion of balances to credit limits on bank/national revolving or other revolving accounts is too high"}]},"monthly_dti": 0.26592,"days_since_open_unsecured_installment_loan": null,"credit_policy_gem_version": "6.1.0","pricing_segment": null,"mod_remark_flag": 0,"tradeline_dti_with_lie_detector": 0.34795,"tradeline_alliant_charge_off": 0,"net_disposable_income": 2947.308382006826,"pricing_tier": "t1","frozen_report": false,"days_since_unsecured_installment_inquiry": null,"adverse_action_template": "adverse_action","pricing_policy_gem_version": "0.5.0","disaster_remark_flag": 0,"risk_models": {"v3": {"risk_model_decision": "Approve","risk_model_score": -5.383537769317627,"logistic_prediction_of_default": 0.0045705633237957954,"invalid_risk_model_variable_count": 0,"probability_differences": {"risk_model_non_mortgage_increases_high":"none","risk_model_max_bankcard_utilization_high":0.234,"risk_model_percent_satisfactory_trades_last_24_mo_low":0.0,"risk_model_percent_trades_opened_last_24_mo_high":0.0003,"risk_model_number_of_open_credit_cards_high":"none","risk_model_mo_since_oldest_credit_card_opened_low":0.0,"risk_model_fico_score_low":"none","risk_model_installment_loans_high":0.0,"risk_model_trades_30_days_past_due_high":0.0,"risk_model_mo_since_recent_charge_off_opened_low":0.0,"risk_model_non_medical_collections_high":0.0,"risk_model_min_payment_revolving_ratio_low":"none","risk_model_percent_high_revolving_trade_utilization_high":"none","risk_model_inquiries_last_6_mo_high":"none","risk_model_revolving_high_credit_increases_high":"none","risk_model_dti_high":"none","risk_model_ndi_low":"none","risk_model_overlimit_trend_high":"none","risk_model_percent_delinquency_high":"none","risk_model_consumer_tri_highest_card_type_i_high":"none","risk_model_consumer_tri_highest_card_type_t_low":"none"}}},"tradeline_non_mortgage_trades_monthly_payment": 1416,"decision_reason": null,"pricing_test_bucket": "2021Feb_rollout","lie_detector_high": 0.1,"percent_delinquency": -0.004617607692307692,"loan_amount_counteroffer": null,"request_id": "9d3e6097-e916-4b24-9c04-6a44d5ca198f","final_decision": "Approve","tradeline_ndi_with_lie_detector": 3624.875382006826}}}';
            Test.StartTest();
        CreditPolicyResponse obj = new CreditPolicyResponse();
        obj = obj.parse(json,acc1.id,app1.id, app1.Lead_ID__c);
        //obj.parse(json1,acc1.id,app1.id, app1.Lead_ID__c);
        System.assert(obj != null);
        CreditPolicyResponse.credit_policy_decision cpd = obj.credit_policy_decision;
        CreditPolicyResponse.Decision_codes decision_codes = cpd.decision_codes;
        System.assert(decision_codes.invalid_input_knockout_codes != null);
        System.assert(decision_codes.prebureau_knockout_codes != null);
        System.assert(decision_codes.postbureau_knockout_codes != null);
        System.assert(decision_codes.risk_model_codes != null);
        System.assert(cpd.id == null);
        System.assert(cpd.applicant_id == null);
        System.assert(cpd.credit_policy_gem_version != null);
        System.assert(cpd.source == null);
        System.assert(cpd.no_hit == false);
        System.assert(cpd.frozen_report == false);
        System.assert(cpd.pricing_segment == null);
        System.assert(cpd.pricing_tier != null);
        for (CreditPolicyResponse.offers offer : cpd.offers) {
            System.assert(offer.key != null); 
            System.assert(offer.amount != null);  
            System.assert(offer.term_months != null);  
            System.assert(offer.apr != null);  
            System.assert(offer.interest_rate != null);  
            System.assert(offer.origination_fee_rate != null);  
            System.assert(offer.monthly_payment != null);  
            System.assert(offer.origination_fee != null);  
            System.assert(offer.segment != null);  
            System.assert(offer.pricing_tier != null);  
            System.assert(offer.above_prime_max != null);  
            System.assert(offer.type != null);  
            System.assert(offer.Is_Offer_Selected == null);
        }
        System.assert(cpd.debt_to_income != null);
        System.assert(cpd.federal_tax_payment != null);
        System.assert(cpd.net_disposable_income != null);
        System.assert(cpd.overlimit_trend == null);
        System.assert(cpd.percent_delinquency != null);
        System.assert(cpd.tri_highest_card_type_i == null);
        System.assert(cpd.tri_highest_card_type_t == null);
        System.assert(cpd.tradeline_unsecured_installment_loans_opened_last_12_mo != null);
        System.assert(cpd.pricing_policy_filters == null);
        System.assert(cpd.adverse_action_template != null);
        System.assert(cpd.created_at == null);
        System.assert(cpd.updated_at == null);
        CreditPolicyResponse.V3 v3 = cpd.risk_models.V3;
        System.assert(v3.risk_model_decision != null);
        System.assert(v3.risk_model_score != null);
        System.assert(v3.logistic_prediction_of_default != null);
        
        CreditPolicyResponse.Probability_differences pd = v3.probability_differences;
        System.assert(pd.risk_model_non_mortgage_increases_high != null); 
        System.assert(pd.risk_model_max_bankcard_utilization_high != null); 
        System.assert(pd.risk_model_percent_satisfactory_trades_last_24_mo_low != null); 
        System.assert(pd.risk_model_percent_trades_opened_last_24_mo_high != null); 
        System.assert(pd.risk_model_number_of_open_credit_cards_high != null); 
        System.assert(pd.risk_model_mo_since_oldest_credit_card_opened_low != null); 
        System.assert(pd.risk_model_fico_score_low != null); 
        System.assert(pd.risk_model_installment_loans_high != null); 
        System.assert(pd.risk_model_trades_30_days_past_due_high != null); 
        System.assert(pd.risk_model_mo_since_recent_charge_off_opened_low != null); 
        System.assert(pd.risk_model_non_medical_collections_high != null); 
        System.assert(pd.risk_model_min_payment_revolving_ratio_low != null); 
        System.assert(pd.risk_model_percent_high_revolving_trade_utilization_high != null); 
        System.assert(pd.risk_model_inquiries_last_6_mo_high != null); 
        System.assert(pd.risk_model_revolving_high_credit_increases_high != null); 
        System.assert(pd.risk_model_dti_high != null); 
        System.assert(pd.risk_model_ndi_low != null); 
        System.assert(pd.risk_model_overlimit_trend_high != null); 
        System.assert(pd.risk_model_percent_delinquency_high != null); 
        System.assert(pd.risk_model_consumer_tri_highest_card_type_i_high != null); 
        System.assert(pd.risk_model_consumer_tri_highest_card_type_t_low != null);
        
        System.assert(cpd.request_context != null);
        System.assert(cpd.tradeline_dti_with_lie_detector != null);
        System.assert(cpd.tradeline_ndi_with_lie_detector != null);
        System.assert(cpd.tradeline_unsecured_installment_loans_opened_last_3_mo == null);
        System.assert(cpd.final_decision_level != null);
        System.assert(cpd.days_since_open_unsecured_loan != null);
        System.assert(cpd.tradeline_alliant_charge_off != null);
        System.assert(cpd.tradeline_summary_of_balances != null);
        System.assert(cpd.age_flag == null);
        System.assert(cpd.student_loan_flag == null);
        System.assert(cpd.funding_model != null);
        
        System.assert(cpd.risk_model_source != null);
        System.assert(cpd.risk_model_version != null);
        System.assert(cpd.is_offer_presented == true);

        CreditPolicyResponse.Data data = cpd.data;
        System.assert(data.credit_policy_version != null);
        System.assert(data.credit_policy_gem_version != null);
        System.assert(data.source == null);
        System.assert(data.no_hit == false);
        System.assert(data.frozen_report == false);
        System.assert(data.final_decision != null);
        System.assert(data.final_decision_level != null);
        System.assert(data.request_intent != null);
        System.assert(data.pricing_segment == null);
        System.assert(data.pricing_tier != null);
        System.assert(data.debt_to_income != null);
        System.assert(data.net_disposable_income != null);
        System.assert(data.overlimit_trend == null);
        System.assert(data.percent_delinquency != null);
        v3 = data.risk_models.V3;
        System.assert(v3.risk_model_decision != null);
        System.assert(v3.risk_model_score != null);
        System.assert(v3.logistic_prediction_of_default != null);
        System.assert(data.state_tax_payment != null);
        System.assert(data.tri_highest_card_type_i == null);
        System.assert(data.tri_highest_card_type_t == null);
        System.assert(data.tradeline_unsecured_installment_loans_balance != null);
        System.assert(data.tradeline_unsecured_installment_loans_opened_last_12_mo != null);
        System.assert(data.tradeline_non_mortgage_trades_monthly_payment != null);
        System.assert(data.tradeline_revolving_trades_balance != null);
        System.assert(data.tradeline_summary_of_balances != null);
        System.assert(data.max_unsecured_installment_loan_utilization != null);
        System.assert(data.pricing_policy_gem_version != null);
        System.assert(data.tradeline_ndi != null);
        System.assert(data.tradeline_dti != null);
        System.assert(data.monthly_dti != null);
        System.assert(data.tradeline_analysis != null);
        System.assert(data.pricing_policy_filters == null);
        System.assert(data.adverse_action_template != null);
        System.assert(data.loan_amount_counteroffer == null);
        System.assert(data.tradeline_dti_with_lie_detector != null);
        System.assert(data.tradeline_ndi_with_lie_detector != null);
        System.assert(data.tradeline_alliant_charge_off != null);
        System.assert(data.days_since_unsecured_installment_inquiry == null);
        System.assert(data.days_since_open_unsecured_installment_loan == null);
        System.assert(data.days_since_open_unsecured_loan != null);
        System.assert(data.age_flag == null);
        System.assert(data.student_loan_flag == null);
        System.assert(data.pricing_test_bucket != null);
        
        
        Test.stopTest();
    }
    
    Testmethod static void method2(){
        
        Manual_Adverse_Action_Decline__c mda = new 	Manual_Adverse_Action_Decline__c();
        mda.Decline_Name__c = 'insufficient tradeline balance';
        mda.Description__c = 'So we are unable to proceed with your loan application.';
        mda.Name = 'Expiration_decline_insufficient_tradeline_balances';
        mda.Reason__c = 'Your unsecured consumer debt does not support the amount requested.';
        insert mda;
        Account acc1 = [Select id,name from Account where name='Testfname Testlname' limit 1];
        
        genesis__Applications__c app1 = [select id,genesis__Status__c,Lead_ID__c from genesis__Applications__c where genesis__Status__c='Offer shown' limit 1];
        app1.Manual_Adverse_Action_Decline__c = mda.Id;
        
        update app1;
        //String bureau = '{"HIAP01_home_equity_monthly_payment":-1,"AADM12_credit_vision_alternative_risk_score":1234,"AGG901_non_mortgage_increases_last_3_mo":6789}';
        //String json = '{"credit_policy_decision":{"credit_policy_version":"v3","credit_policy_gem_version":"4.1.33","tradeline_analysis":"{}","Bureau_subset":"{}","source":"payoff","tradeline_revolving_trades_balance":2345.89,"max_unsecured_installment_loan_utilization":0.0,"days_since_open_unsecured_loan":"819.0","tradeline_unsecured_installment_loans_balance":0.0,"tradeline_ndi":"1867.3125","tradeline_non_mortgage_trades_monthly_payment":453.0,"days_since_open_unsecured_installment_loan":"919.0","days_since_unsecured_installment_inquiry":"89.0","raw_bureau_data":"raw bureau data","loan_amount_counteroffer":"7000","final_decision":"Decline","request_intent":"verification","federal_tax_payment":"3251.25","state_tax_payment":"3905.0","tradeline_dti":0.491771428571429,"monthly_dti":0.23423452,"decision_codes":{"invalid_input_knockout_codes":["invalid_data_PAYMNT08_min_payment_revolving_ratio_missing","invalid_data_TRV12_revolving_high_credit_increases_last_3_mo_missing","invalid_data_RVLR14_revolver_transactor_inactive_pattern_missing"],"prebureau_knockout_codes":[],"postbureau_knockout_codes":[],"risk_model_codes":["risk_model_fico_score_low","risk_model_ndi_low","risk_model_percent_satisfactory_trades_last_24_mo_low","risk_model_mo_since_oldest_credit_card_opened_low"],"adverse_actions":[{"reason":"No reason","name":"Test","description":"No"}],"score_factor_text":[{"rank":"10","description":"ddesc","code":"123.678"}]},"metadata":{"status":200}}}';                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
        //String json = '{"credit_policy_decision":{"credit_policy_version":"v3","credit_policy_gem_version":"4.1.33","source":"payoff","days_since_open_unsecured_loan":"819.0","days_since_open_unsecured_installment_loan":"919.0","days_since_unsecured_installment_inquiry":"89.0","raw_bureau_data":"raw bureau data","loan_amount_counteroffer":"7000","final_decision":"Decline","request_intent":"verification","federal_tax_payment":3251.25,"state_tax_payment":3905.0,"tradeline_dti":0.491771428571429,"monthly_dti":0.23423452,"tradeline_unsecured_installment_loans_balance":0.0,"tradeline_revolving_trades_balance":"17212.0","max_unsecured_installment_loan_utilization":"0.0","tradeline_non_mortgage_trades_monthly_payment":"453.0","tradeline_ndi":"1867.3125","decision_codes":{"invalid_input_knockout_codes":["invalid_data_PAYMNT08_min_payment_revolving_ratio_missing","invalid_data_TRV12_revolving_high_credit_increases_last_3_mo_missing","invalid_data_RVLR14_revolver_transactor_inactive_pattern_missing"],"prebureau_knockout_codes":[],"postbureau_knockout_codes":[],"risk_model_codes":["risk_model_fico_score_low","risk_model_ndi_low","risk_model_percent_satisfactory_trades_last_24_mo_low","risk_model_mo_since_oldest_credit_card_opened_low"],"adverse_actions":[{"reason":"No reason","name":"Test","description":"No"}],"score_factor_text":[]},"probability_differences":{"risk_model_min_payment_revolving_ratio_low":-0.19750776338280002,"risk_model_trades_30_days_past_due_high":0.0,"risk_model_inquiries_last_6_mo_high":-0.02342364,"risk_model_mo_since_recent_charge_off_opened_low":0.0,"risk_model_non_mortgage_increases_high":"-0.14200806","risk_model_percent_delinquency_high":"0.0","risk_model_percent_high_revolving_trade_utilization_high":"-0.16278675","risk_model_ndi_low":"-0.5557961939400001","risk_model_consumer_tri_highest_card_type_t_low":"-0.05804013","risk_model_mo_since_oldest_credit_card_opened_low":"-0.23259331","risk_model_dti_high":"-0.06538871167038594285714285714285714285714371234442228","risk_model_percent_satisfactory_trades_last_24_mo_low":-0.48671481,"risk_model_overlimit_trend_high":"0.0","risk_model_consumer_tri_highest_card_type_i_high":"0.0","risk_model_max_bankcard_utilization_high":-0.10801354,"risk_model_percent_trades_opened_last_24_mo_high":0.0,"risk_model_non_medical_collections_high":0.0,"risk_model_number_of_open_credit_cards_high":-0.14254735,"risk_model_fico_score_low":"-1.820333939999999667","risk_model_revolving_high_credit_increases_high":-0.07806163,"risk_model_installment_loans_high":"0.0"},"tradeline_analysis":{"credit_card_count":8,"credit_card_balance":17212,"credit_card_limit":17100,"credit_card_utilization":100.65497076023391,"credit_card_monthly_payments":311,"credit_card_closed_with_balance_count":0,"unsecured_installment_loan_count":0,"unsecured_installment_loan_balance":0,"unsecured_installment_loan_opened_last_12_mo":0,"unsecured_installment_loan_monthly_payment":0,"student_loan_count":2,"student_loan_balance":9549,"student_loan_monthly_payment":142,"student_loan_deferred_count":0,"auto_loan_count":0,"auto_loan_balance":0,"auto_loan_monthly_payment":0,"mortgage_count":0,"mortgage_balance":0,"mortgage_monthly_payment":0,"heloc_count":0,"heloc_balances":0,"heloc_monthly_payment":0},"_metadata":{"status":200}}}';                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
        // String json1 = '{"credit_policy_decision":{"raw_bureau_data":"raw bureau data","final_decision":"Decline","request_intent":"verification"';
        String json = '{"credit_policy_decision": {"pricing_policy_filters": null,"offers": [{"amount": "7000","origination_fee": "0.0","key": "1","monthly_payment": "310.21","apr": "5.99","type": "USRule360Loan","interest_rate": "5.99","segment": "prime","term_months": 24,"origination_fee_discount": "140.0","pricing_tier": "t1","origination_fee_rate_discount": "2.0","above_prime_max": "false","origination_fee_rate": "0.0"}],"balance_to_income_with_lie_detector": 0.34795,"tradeline_summary_of_balances": 34795,"request_intent": "application","tradeline_revolving_trades_balance": 34795,"tradeline_open_unsecured_installment_loans": 0,"request_context": "active","student_loan_flag": null,"max_unsecured_installment_loan_utilization": 0,"tri_highest_card_type_t": null,"btiwlie_balmag01_product": null,"balance_to_income": 0.34795,"federal_tax_payment": 17131.99541591809,"credit_policy_version": "v3","tradeline_unsecured_installment_loans_opened_last_12_mo": 0,"def_remark_flag": 0,"funding_model": "null","debt_to_income": 0.0000105574,"state_tax_payment": 12777.5,"tradeline_ndi": 3624.875382006826,"suppress_flag": 0,"tri_highest_card_type_i": null,"overlimit_trend": null,"percent_new_bc_trades_in_last_year": 0,"tradeline_dti": 0.34795,"tradeline_analysis": "{\\"credit_card_count\\":21,\\"credit_card_balance\\":32911,\\"credit_card_limit\\":166000,\\"credit_card_utilization\\":19.825903614457832,\\"credit_card_monthly_payments\\":481,\\"credit_card_closed_with_balance_count\\":0,\\"unsecured_installment_loan_count\\":0,\\"unsecured_installment_loan_balance\\":0,\\"unsecured_installment_loan_opened_last_12_mo\\":0,\\"unsecured_installment_loan_monthly_payment\\":0,\\"student_loan_count\\":0,\\"student_loan_balance\\":0,\\"student_loan_monthly_payment\\":0,\\"student_loan_deferred_count\\":0,\\"auto_loan_count\\":1,\\"auto_loan_balance\\":396,\\"auto_loan_monthly_payment\\":512,\\"mortgage_count\\":1,\\"mortgage_balance\\":152070,\\"mortgage_monthly_payment\\":1312,\\"heloc_count\\":1,\\"heloc_balances\\":70383,\\"heloc_monthly_payment\\":223}","traditional_dti": 0.26592,"age_flag": null,"days_since_open_unsecured_loan": 479,"payoff_uid": "9e9ea079-1fb5-e6b5-2dd8-f5e9d8924733","tradeline_unsecured_installment_loans_balance": 0,"tradeline_unsecured_installment_loans_opened_last_3_mo": null,"final_decision_level": "6.0","def_payment_flag": 0,"no_hit": false,"fico_inquiries_product": 0,"w55_agg910_unf": null,"invalid_missing_risk_model_variables": null,"bureau_subset": "{}","decision_codes": {"invalid_input_knockout_codes": [],"prebureau_knockout_codes": [],"postbureau_knockout_codes": [],"risk_model_codes": [8,4,3,21],"adverse_actions": [],"score_factor_text": [{"rank": 1,"code": "10","description": "Proportion of balances to credit limits on bank/national revolving or other revolving accounts is too high"},{"rank": 2,"code": "5","description": "Too many accounts with balances"},{"rank": 3,"code": "11","description": "Amount owed on revolving accounts is too high"},{"rank": 4,"code": "14","description": "Length of time accounts have been established"}]},"monthly_dti": 0.26592,"days_since_open_unsecured_installment_loan": null,"credit_policy_gem_version": "6.1.0","pricing_segment": null,"mod_remark_flag": 0,"tradeline_dti_with_lie_detector": 0.34795,"tradeline_alliant_charge_off": 0,"raw_bureau_data": "","net_disposable_income": 2947.308382006826,"pricing_tier": "t1","frozen_report": false,"days_since_unsecured_installment_inquiry": null,"adverse_action_template": "adverse_action","pricing_policy_gem_version": "0.5.0","disaster_remark_flag": 0,"risk_models": {"v3": {"risk_model_decision": "Approve","risk_model_score": -5.383537769317627,"logistic_prediction_of_default": 0.0045705633237957954,"invalid_risk_model_variable_count": 0,"probability_differences": {"risk_model_non_mortgage_increases_high":"none","risk_model_max_bankcard_utilization_high":0.234,"risk_model_percent_satisfactory_trades_last_24_mo_low":0.0,"risk_model_percent_trades_opened_last_24_mo_high":0.0003,"risk_model_number_of_open_credit_cards_high":"none","risk_model_mo_since_oldest_credit_card_opened_low":0.0,"risk_model_fico_score_low":"none","risk_model_installment_loans_high":0.0,"risk_model_trades_30_days_past_due_high":0.0,"risk_model_mo_since_recent_charge_off_opened_low":0.0,"risk_model_non_medical_collections_high":0.0,"risk_model_min_payment_revolving_ratio_low":"none","risk_model_percent_high_revolving_trade_utilization_high":"none","risk_model_inquiries_last_6_mo_high":"none","risk_model_revolving_high_credit_increases_high":"none","risk_model_dti_high":"none","risk_model_ndi_low":"none","risk_model_overlimit_trend_high":"none","risk_model_percent_delinquency_high":"none","risk_model_consumer_tri_highest_card_type_i_high":"none","risk_model_consumer_tri_highest_card_type_t_low":"none"}}},"tradeline_non_mortgage_trades_monthly_payment": 1416,"decision_reason": null,"pricing_test_bucket": "2021Feb_rollout","lie_detector_high": 0.1,"percent_delinquency": -0.004617607692307692,"loan_amount_counteroffer": null,"request_id": "9d3e6097-e916-4b24-9c04-6a44d5ca198f","final_decision": "Approve","tradeline_ndi_with_lie_detector": 3624.875382006826,"data": {"pricing_policy_filters": null,"offers": [{"amount": "7000","origination_fee": "0.0","key": "1","monthly_payment": "310.21","apr": "5.99","type": "USRule360Loan","interest_rate": "5.99","segment": "prime","term_months": 24,"origination_fee_discount": "140.0","pricing_tier": "t1","origination_fee_rate_discount": "2.0","above_prime_max": "false","origination_fee_rate": "0.0"}],"balance_to_income_with_lie_detector": 0.34795,"tradeline_summary_of_balances": 34795,"request_intent": "application","tradeline_revolving_trades_balance": 34795,"tradeline_open_unsecured_installment_loans": 0,"request_context": "active","student_loan_flag": null,"max_unsecured_installment_loan_utilization": 0,"tri_highest_card_type_t": null,"btiwlie_balmag01_product": null,"balance_to_income": 0.34795,"federal_tax_payment": 17131.99541591809,"credit_policy_version": "6.0","tradeline_unsecured_installment_loans_opened_last_12_mo": 0,"def_remark_flag": 0,"funding_model": null,"debt_to_income": 0.0000105574,"state_tax_payment": 12777.5,"tradeline_ndi": 3624.875382006826,"suppress_flag": 0,"tri_highest_card_type_i": null,"overlimit_trend": null,"percent_new_bc_trades_in_last_year": 0,"tradeline_dti": 0.34795,"tradeline_analysis": "{\\"credit_card_count\\":21,\\"credit_card_balance\\":32911,\\"credit_card_limit\\":166000,\\"credit_card_utilization\\":19.825903614457832,\\"credit_card_monthly_payments\\":481,\\"credit_card_closed_with_balance_count\\":0,\\"unsecured_installment_loan_count\\":0,\\"unsecured_installment_loan_balance\\":0,\\"unsecured_installment_loan_opened_last_12_mo\\":0,\\"unsecured_installment_loan_monthly_payment\\":0,\\"student_loan_count\\":0,\\"student_loan_balance\\":0,\\"student_loan_monthly_payment\\":0,\\"student_loan_deferred_count\\":0,\\"auto_loan_count\\":1,\\"auto_loan_balance\\":396,\\"auto_loan_monthly_payment\\":512,\\"mortgage_count\\":1,\\"mortgage_balance\\":152070,\\"mortgage_monthly_payment\\":1312,\\"heloc_count\\":1,\\"heloc_balances\\":70383,\\"heloc_monthly_payment\\":223}","traditional_dti": 0.26592,"age_flag": null,"days_since_open_unsecured_loan": 479,"payoff_uid": "9e9ea079-1fb5-e6b5-2dd8-f5e9d8924733","tradeline_unsecured_installment_loans_balance": 0,"tradeline_unsecured_installment_loans_opened_last_3_mo": null,"final_decision_level": "6.0","def_payment_flag": 0,"no_hit": false,"fico_inquiries_product": 0,"w55_agg910_unf": null,"invalid_missing_risk_model_variables": null,"decision_codes": {"invalid_input_knockout_codes": [],"prebureau_knockout_codes": [],"postbureau_knockout_codes": [],"risk_model_codes": [8,4,3,21],"adverse_actions": [],"score_factor_text": [{"rank": 1,"code": "10","description": "Proportion of balances to credit limits on bank/national revolving or other revolving accounts is too high"}]},"monthly_dti": 0.26592,"days_since_open_unsecured_installment_loan": null,"credit_policy_gem_version": "6.1.0","pricing_segment": null,"mod_remark_flag": 0,"tradeline_dti_with_lie_detector": 0.34795,"tradeline_alliant_charge_off": 0,"net_disposable_income": 2947.308382006826,"pricing_tier": "t1","frozen_report": false,"days_since_unsecured_installment_inquiry": null,"adverse_action_template": "adverse_action","pricing_policy_gem_version": "0.5.0","disaster_remark_flag": 0,"risk_models": {"v3": {"risk_model_decision": "Approve","risk_model_score": -5.383537769317627,"logistic_prediction_of_default": 0.0045705633237957954,"invalid_risk_model_variable_count": 0,"probability_differences": {"risk_model_non_mortgage_increases_high":"none","risk_model_max_bankcard_utilization_high":0.234,"risk_model_percent_satisfactory_trades_last_24_mo_low":0.0,"risk_model_percent_trades_opened_last_24_mo_high":0.0003,"risk_model_number_of_open_credit_cards_high":"none","risk_model_mo_since_oldest_credit_card_opened_low":0.0,"risk_model_fico_score_low":"none","risk_model_installment_loans_high":0.0,"risk_model_trades_30_days_past_due_high":0.0,"risk_model_mo_since_recent_charge_off_opened_low":0.0,"risk_model_non_medical_collections_high":0.0,"risk_model_min_payment_revolving_ratio_low":"none","risk_model_percent_high_revolving_trade_utilization_high":"none","risk_model_inquiries_last_6_mo_high":"none","risk_model_revolving_high_credit_increases_high":"none","risk_model_dti_high":"none","risk_model_ndi_low":"none","risk_model_overlimit_trend_high":"none","risk_model_percent_delinquency_high":"none","risk_model_consumer_tri_highest_card_type_i_high":"none","risk_model_consumer_tri_highest_card_type_t_low":"none"}}},"tradeline_non_mortgage_trades_monthly_payment": 1416,"decision_reason": null,"pricing_test_bucket": "2021Feb_rollout","lie_detector_high": 0.1,"percent_delinquency": -0.004617607692307692,"loan_amount_counteroffer": null,"request_id": "9d3e6097-e916-4b24-9c04-6a44d5ca198f","final_decision": "Approve","tradeline_ndi_with_lie_detector": 3624.875382006826}}}';
            
            Test.StartTest();
        CreditPolicyResponse obj = new CreditPolicyResponse();
        obj.parse(json,acc1.id,app1.id, app1.Lead_ID__c);
        //obj.parse(json1,acc1.id,app1.id, app1.Lead_ID__c);
        System.assert(obj != null);
        Test.stopTest();
    }
    
    
    Testmethod static void method3(){
        Manual_Adverse_Action_Decline__c mda = new 	Manual_Adverse_Action_Decline__c();
        mda.Decline_Name__c = 'insufficient tradeline balance';
        mda.Description__c = 'So we are unable to proceed with your loan application.';
        mda.Name = 'Expiration_decline_insufficient_tradeline_balances';
        mda.Reason__c = 'Your unsecured consumer debt does not support the amount requested.';
        insert mda;
        Account acc1 = [Select id,name from Account where name='Testfname Testlname' limit 1];
        
        genesis__Applications__c app1 = [select id,genesis__Status__c,Lead_ID__c from genesis__Applications__c where genesis__Status__c='Offer shown' limit 1];
        app1.Manual_Adverse_Action_Decline__c = mda.Id;
        
        update app1;
        StaticResource sr = [Select id,name,body from StaticResource where name='CreditPolicyTest'];
        //String bureau = '{"HIAP01_home_equity_monthly_payment":-1,"AADM12_credit_vision_alternative_risk_score":1234,"AGG901_non_mortgage_increases_last_3_mo":6789}';
        String json = sr.body.toString();
        Test.StartTest();
        CreditPolicyResponse obj = new CreditPolicyResponse();
        obj.parse(json,acc1.id,app1.id, app1.Lead_ID__c);
        //obj.parse(json1,acc1.id,app1.id, app1.Lead_ID__c);
        System.assert(obj != null);
        Test.stopTest();
    }
    
    Testmethod static void method5(){
        
        Manual_Adverse_Action_Decline__c mda = new Manual_Adverse_Action_Decline__c();
        mda.Decline_Name__c = 'insufficient tradeline balance';
        mda.Description__c = 'So we are unable to proceed with your loan application.';
        mda.Name = 'Expiration_decline_insufficient_tradeline_balances';
        mda.Reason__c = 'Your unsecured consumer debt does not support the amount requested.';
        insert mda;
        Account acc1 = [Select id,name from Account where name='Testfname Testlname' limit 1];
        
        genesis__Applications__c app1 = [select id,genesis__Status__c,Lead_ID__c from genesis__Applications__c where genesis__Status__c='Offer shown' limit 1];
        app1.Manual_Adverse_Action_Decline__c = mda.Id;
        
        update app1;
        StaticResource sr = [Select id,name,body from StaticResource where name='CreditPolicyTest2'];
        //String bureau = '{"HIAP01_home_equity_monthly_payment":-1,"AADM12_credit_vision_alternative_risk_score":1234,"AGG901_non_mortgage_increases_last_3_mo":6789}';
        String json = sr.body.toString();
        Test.StartTest();
        CreditPolicyResponse obj = new CreditPolicyResponse();
        obj.parse(json,acc1.id,app1.id, app1.Lead_ID__c);
        //obj.parse(json1,acc1.id,app1.id, app1.Lead_ID__c);
        System.assert(obj != null);
        Test.stopTest();
    }
    
    @IsTest static void canParseParserV6Fields(){
        
        Manual_Adverse_Action_Decline__c mda = new 	Manual_Adverse_Action_Decline__c();
        mda.Decline_Name__c = 'insufficient tradeline balance';
        mda.Description__c = 'So we are unable to proceed with your loan application.';
        mda.Name = 'Expiration_decline_insufficient_tradeline_balances';
        mda.Reason__c = 'Your unsecured consumer debt does not support the amount requested.';
        insert mda;
        Account acc1 = [Select id,name from Account where name='Testfname Testlname' limit 1];
        
        genesis__Applications__c app1 = [select id,genesis__Status__c,Lead_ID__c from genesis__Applications__c where genesis__Status__c='Offer shown' limit 1];
        app1.Manual_Adverse_Action_Decline__c = mda.Id;
        
        update app1;
        StaticResource sr = [Select id,name,body from StaticResource where name='CreditPolicyTestParserV6'];
        String json = sr.body.toString();
        Test.StartTest();
        CreditPolicyResponse obj = new CreditPolicyResponse();
        obj.parse(json,acc1.id,app1.id, app1.Lead_ID__c);
        System.assert(obj != null);
        Test.stopTest();
    }
    
    /**
* Parse the actual example request that failed on the QA deployment.
* The previous version stands for backwards compatibility.
*/
    @IsTest static void canParseParserV6FieldsQA() {
        Manual_Adverse_Action_Decline__c mda = new 	Manual_Adverse_Action_Decline__c();
        mda.Decline_Name__c = 'insufficient tradeline balance';
        mda.Description__c = 'So we are unable to proceed with your loan application.';
        mda.Name = 'Expiration_decline_insufficient_tradeline_balances';
        mda.Reason__c = 'Your unsecured consumer debt does not support the amount requested.';
        insert mda;
        Account acc1 = [SELECT Id,Name FROM Account WHERE Name ='Testfname Testlname' LIMIT 1];
        
        genesis__Applications__c app1 = [SELECT Id,genesis__Status__c,Lead_ID__c FROM genesis__Applications__c WHERE genesis__Status__c='Offer shown' LIMIT 1];
        app1.Manual_Adverse_Action_Decline__c = mda.Id;
        
        update app1;
        StaticResource sr = [SELECT Id,Name,Body FROM StaticResource WHERE Name='CreditPolicyTestParserV6QA'];
        String json = sr.Body.toString();
        Test.startTest();
        CreditPolicyResponse obj = new CreditPolicyResponse();
        obj.parse(json,acc1.Id,app1.Id, app1.Lead_ID__c);
        System.assert(obj != null);
        Test.stopTest();
    }
    
    /**
* Parse the actual example request that failed on the QA deployment.
* The previous version stands for backwards compatibility.
*/
    @IsTest static void canParseParserV6FieldsQARemoveDataKey() {
        Manual_Adverse_Action_Decline__c mda = new 	Manual_Adverse_Action_Decline__c();
        mda.Decline_Name__c = 'insufficient tradeline balance';
        mda.Description__c = 'So we are unable to proceed with your loan application.';
        mda.Name = 'Expiration_decline_insufficient_tradeline_balances';
        mda.Reason__c = 'Your unsecured consumer debt does not support the amount requested.';
        insert mda;
        Account acc1 = [SELECT Id,Name FROM Account WHERE Name ='Testfname Testlname' LIMIT 1];
        
        genesis__Applications__c app1 = [SELECT Id,genesis__Status__c,Lead_ID__c FROM genesis__Applications__c WHERE genesis__Status__c='Offer shown' LIMIT 1];
        app1.Manual_Adverse_Action_Decline__c = mda.Id;
        
        update app1;
        StaticResource sr = [SELECT Id,Name,Body FROM StaticResource WHERE Name='CreditPolicyTestParserV6QARemoveDataKey'];
        String json = sr.Body.toString();
        Test.startTest();
        CreditPolicyResponse obj = new CreditPolicyResponse();
        obj = obj.parse(json,acc1.Id,app1.Id, app1.Lead_ID__c);
        
        System.assert(obj != null);
        CreditPolicyResponse.credit_policy_decision cpd = obj.credit_policy_decision;
        CreditPolicyResponse.Decision_codes decision_codes = cpd.decision_codes;
        System.assert(decision_codes.invalid_input_knockout_codes != null);
        System.assert(decision_codes.prebureau_knockout_codes != null);
        System.assert(decision_codes.postbureau_knockout_codes != null);
        System.assert(decision_codes.risk_model_codes != null);
        System.assert(cpd.id == null);
        System.assert(cpd.applicant_id == null);
        System.assert(cpd.credit_policy_gem_version != null);
        System.assert(cpd.source == null);
        System.assert(cpd.no_hit == false);
        System.assert(cpd.frozen_report == false);
        System.assert(cpd.pricing_segment == null);
        System.assert(cpd.pricing_tier != null);
        
        for (CreditPolicyResponse.offers offer : cpd.offers) {
            System.assert(offer.key != null);
            System.assert(offer.amount != null);
            System.assert(offer.term_months != null);
            System.assert(offer.apr != null);
            System.assert(offer.interest_rate != null);
            System.assert(offer.origination_fee_rate != null);
            System.assert(offer.monthly_payment != null);
            System.assert(offer.origination_fee != null);
            System.assert(offer.segment != null);
            System.assert(offer.pricing_tier != null);
            System.assert(offer.above_prime_max != null);
            System.assert(offer.type != null);
            System.assert(offer.Is_Offer_Selected == null);
        }
        System.assert(cpd.debt_to_income != null);
        System.assert(cpd.federal_tax_payment != null);
        System.assert(cpd.net_disposable_income != null);
        System.assert(cpd.overlimit_trend == null);
        System.assert(cpd.percent_delinquency != null);
        System.assert(cpd.tri_highest_card_type_i == null);
        System.assert(cpd.tri_highest_card_type_t == null);
        System.assert(cpd.tradeline_unsecured_installment_loans_opened_last_12_mo != null);
        System.assert(cpd.pricing_policy_filters == null);
        System.assert(cpd.adverse_action_template != null);
        System.assert(cpd.created_at == null);
        System.assert(cpd.updated_at == null);
        
        CreditPolicyResponse.V6 v6 = cpd.risk_models.v6;
        System.assert(v6.risk_model_decision != null);
        //System.assert(v6.risk_model_score != null);
        System.assert(v6.logistic_prediction_of_default != null);
        System.assert(v6.invalid_risk_model_variable_count != null);
        
        System.assert(cpd.request_context != null);
        System.assert(cpd.tradeline_dti_with_lie_detector != null);
        System.assert(cpd.tradeline_ndi_with_lie_detector != null);
        System.assert(cpd.tradeline_unsecured_installment_loans_opened_last_3_mo == null);
        System.assert(cpd.final_decision_level != null);
        System.assert(cpd.days_since_open_unsecured_loan != null);
        System.assert(cpd.tradeline_alliant_charge_off != null);
        System.assert(cpd.tradeline_summary_of_balances != null);
        System.assert(cpd.age_flag == null);
        System.assert(cpd.student_loan_flag == null);
        System.assert(cpd.funding_model != null);
        
        Test.stopTest();
    }
    
    /**
* Check non null status for fields present in previous versions.
*/
    @IsTest static void canParseParserV6FieldsQANullChecks(){
        
        Manual_Adverse_Action_Decline__c mda = new 	Manual_Adverse_Action_Decline__c();
        mda.Decline_Name__c = 'insufficient tradeline balance';
        mda.Description__c = 'So we are unable to proceed with your loan application.';
        mda.Name = 'Expiration_decline_insufficient_tradeline_balances';
        mda.Reason__c = 'Your unsecured consumer debt does not support the amount requested.';
        insert mda;
        Account acc1 = [SELECT Id,Name FROM Account WHERE Name='Testfname Testlname' LIMIT 1];
        
        genesis__Applications__c app1 = [SELECT Id,genesis__Status__c,Lead_ID__c FROM genesis__Applications__c WHERE genesis__Status__c='Offer shown' LIMIT 1];
        app1.Manual_Adverse_Action_Decline__c = mda.Id;
        
        update app1;
        StaticResource sr = [SELECT Id,Name,Body FROM StaticResource WHERE Name='CreditPolicyTestParserV6QA'];
        String json = sr.Body.toString();
        Test.startTest();
        CreditPolicyResponse obj = new CreditPolicyResponse();
        obj = obj.parse(json,acc1.Id,app1.Id, app1.Lead_ID__c);
        
        System.assert(obj != null);
        CreditPolicyResponse.credit_policy_decision cpd = obj.credit_policy_decision;
        CreditPolicyResponse.Decision_codes decision_codes = cpd.decision_codes;
        System.assert(decision_codes.invalid_input_knockout_codes != null);
        System.assert(decision_codes.prebureau_knockout_codes != null);
        System.assert(decision_codes.postbureau_knockout_codes != null);
        System.assert(decision_codes.risk_model_codes != null);
        System.assert(cpd.id == null);
        System.assert(cpd.applicant_id == null);
        System.assert(cpd.credit_policy_gem_version != null);
        System.assert(cpd.source == null);
        System.assert(cpd.no_hit == false);
        System.assert(cpd.frozen_report == false);
        System.assert(cpd.pricing_segment == null);
        System.assert(cpd.pricing_tier != null);
        
        for (CreditPolicyResponse.offers offer : cpd.offers) {
            System.assert(offer.key != null);
            System.assert(offer.amount != null);
            System.assert(offer.term_months != null);
            System.assert(offer.apr != null);
            System.assert(offer.interest_rate != null);
            System.assert(offer.origination_fee_rate != null);
            System.assert(offer.monthly_payment != null);
            System.assert(offer.origination_fee != null);
            System.assert(offer.segment != null);
            System.assert(offer.pricing_tier != null);
            System.assert(offer.above_prime_max != null);
            System.assert(offer.type != null);
            System.assert(offer.Is_Offer_Selected == null);
        }
        System.assert(cpd.debt_to_income != null);
        System.assert(cpd.federal_tax_payment != null);
        System.assert(cpd.net_disposable_income != null);
        System.assert(cpd.overlimit_trend == null);
        System.assert(cpd.percent_delinquency != null);
        System.assert(cpd.tri_highest_card_type_i == null);
        System.assert(cpd.tri_highest_card_type_t == null);
        System.assert(cpd.tradeline_unsecured_installment_loans_opened_last_12_mo != null);
        System.assert(cpd.pricing_policy_filters == null);
        System.assert(cpd.adverse_action_template != null);
        System.assert(cpd.created_at == null);
        System.assert(cpd.updated_at == null);
        
        CreditPolicyResponse.V6 v6 = cpd.risk_models.v6;
        System.assert(v6.risk_model_decision != null);
        //System.assert(v6.risk_model_score != null);
        System.assert(v6.logistic_prediction_of_default != null);
        System.assert(v6.invalid_risk_model_variable_count != null);
        
        System.assert(cpd.request_context != null);
        System.assert(cpd.tradeline_dti_with_lie_detector != null);
        System.assert(cpd.tradeline_ndi_with_lie_detector != null);
        System.assert(cpd.tradeline_unsecured_installment_loans_opened_last_3_mo == null);
        System.assert(cpd.final_decision_level != null);
        System.assert(cpd.days_since_open_unsecured_loan != null);
        System.assert(cpd.tradeline_alliant_charge_off != null);
        System.assert(cpd.tradeline_summary_of_balances != null);
        System.assert(cpd.age_flag == null);
        System.assert(cpd.student_loan_flag == null);
        System.assert(cpd.funding_model != null);
        
        CreditPolicyResponse.Data data = cpd.data;
        System.assert(data.credit_policy_version != null);
        System.assert(data.credit_policy_gem_version != null);
        System.assert(data.source == null);
        System.assert(data.no_hit == false);
        System.assert(data.frozen_report == false);
        System.assert(data.final_decision != null);
        System.assert(data.final_decision_level != null);
        System.assert(data.request_intent != null);
        System.assert(data.pricing_segment == null);
        System.assert(data.pricing_tier != null);
        System.assert(data.debt_to_income != null);
        System.assert(data.net_disposable_income != null);
        System.assert(data.overlimit_trend == null);
        System.assert(data.percent_delinquency != null);
        
        CreditPolicyResponse.V6 v6_data = cpd.data.risk_models.v6;
        System.assert(v6_data.risk_model_decision != null);
        //System.assert(v6_data.risk_model_score != null);
        System.assert(v6_data.logistic_prediction_of_default != null);
        System.assert(v6_data.invalid_risk_model_variable_count != null);
        
        System.assert(data.state_tax_payment != null);
        System.assert(data.tri_highest_card_type_i == null);
        System.assert(data.tri_highest_card_type_t == null);
        System.assert(data.tradeline_unsecured_installment_loans_balance != null);
        System.assert(data.tradeline_unsecured_installment_loans_opened_last_12_mo != null);
        System.assert(data.tradeline_non_mortgage_trades_monthly_payment != null);
        System.assert(data.tradeline_revolving_trades_balance != null);
        System.assert(data.tradeline_summary_of_balances != null);
        System.assert(data.max_unsecured_installment_loan_utilization != null);
        System.assert(data.pricing_policy_gem_version != null);
        System.assert(data.tradeline_ndi != null);
        System.assert(data.tradeline_dti != null);
        System.assert(data.monthly_dti != null);
        System.assert(data.tradeline_analysis != null);
        System.assert(data.pricing_policy_filters == null);
        System.assert(data.adverse_action_template != null);
        System.assert(data.loan_amount_counteroffer == null);
        System.assert(data.tradeline_dti_with_lie_detector != null);
        System.assert(data.tradeline_ndi_with_lie_detector != null);
        System.assert(data.tradeline_alliant_charge_off != null);
        System.assert(data.days_since_unsecured_installment_inquiry == null);
        System.assert(data.days_since_open_unsecured_installment_loan == null);
        System.assert(data.days_since_open_unsecured_loan != null);
        System.assert(data.age_flag == null);
        System.assert(data.student_loan_flag == null);
        System.assert(data.pricing_test_bucket != null);
        
        Test.stopTest();
    }
    
    @IsTest static void testCopyCreditPolicyFieldsToApplication() {

        Credit_Policy__c creditPolicy = new Credit_Policy__c();
        creditPolicy.FICO__c = 780;
        creditPolicy.Monthly_DTI__c = 40;
        creditPolicy.Net_Disposable_Income_NDI__c = '1200.0';
        creditPolicy.Num_Trades_Opened_Past_24mo__c = 4;
        creditPolicy.request_intent__c = 'application';
        creditPolicy.Risk_Model_Source__c = 'hm';
        creditPolicy.Risk_Model_Version__c = '6.0123';
        creditPolicy.Is_Offer_Presented__c = true;
        insert creditPolicy;

        genesis__Applications__c app = MW_GlobalTestUtility.GetApplication();
        insert app;

        String appId = String.valueOf(app.Id);

        CreditPolicyResponse.updateAppRulesetCreditPolicyFields(appId, creditPolicy.Id);

        genesis__Applications__c actual = selectCreditPolicyFields(appId);

        System.assertEquals(780, actual.FICO__c);
        System.assertEquals(40, actual.Monthly_DTI__c);
        System.assertEquals(1200.0, actual.Net_Disposable_Income_NDI_Num__c);
        System.assertEquals(4, actual.Num_Trades_Opened_Past_24mo__c);
        System.assertEquals('hm', actual.Risk_Model_Source__c);
        System.assertEquals('6.0123', actual.Risk_Model_Version__c);
        System.assertEquals(true, actual.Is_Offer_Presented__c);

        Credit_Policy__c creditPolicyVerification = new Credit_Policy__c();
        creditPolicyVerification.FICO__c = 600;
        creditPolicyVerification.Monthly_DTI__c = 90;
        creditPolicyVerification.Net_Disposable_Income_NDI__c = '700.0';
        creditPolicyVerification.Num_Trades_Opened_Past_24mo__c = 20;
        creditPolicyVerification.request_intent__c = 'verification';
        creditPolicy.Risk_Model_Source__c = 'crb';
        creditPolicy.Risk_Model_Version__c = '1.0123';
        creditPolicy.Is_Offer_Presented__c = false;
        insert creditPolicyVerification;

        /* Assert the fields do not change after another type of credit policy entry is added */
        CreditPolicyResponse.updateAppRulesetCreditPolicyFields(appId, creditPolicy.Id);

        actual = selectCreditPolicyFields(appId);

        System.assertEquals(780, actual.FICO__c);
        System.assertEquals(40, actual.Monthly_DTI__c);
        System.assertEquals(1200.0, actual.Net_Disposable_Income_NDI_Num__c);
        System.assertEquals(4, actual.Num_Trades_Opened_Past_24mo__c);
        System.assertEquals('hm', actual.Risk_Model_Source__c);
        System.assertEquals('6.0123', actual.Risk_Model_Version__c);
        System.assertEquals(true, actual.Is_Offer_Presented__c);
    }

    /**
     * The copy method itself is tested independently, confirm it works within the parsing operation.
     */
    @IsTest static void testCopyCreditPolicyFieldsToApplicationDuringParse() {

        Account acc1 = [SELECT Id,Name FROM Account WHERE Name ='Testfname Testlname' LIMIT 1];

        genesis__Applications__c app1 = [SELECT Id,genesis__Status__c,Lead_ID__c FROM genesis__Applications__c WHERE genesis__Status__c='Offer shown' LIMIT 1];

        StaticResource sr = [SELECT Id,Name,Body FROM StaticResource WHERE Name='CreditPolicyTestParserV6QARemoveDataKey'];
        String json = sr.Body.toString();

        Test.startTest();
        CreditPolicyResponse obj = new CreditPolicyResponse();
        obj = obj.parse(json,acc1.Id,app1.Id, app1.Lead_ID__c);

        genesis__Applications__c actual = selectCreditPolicyFields(String.valueOf(app1.Id));

        System.assertEquals(792, actual.FICO__c);
        System.assertEquals(26.59, actual.Monthly_DTI__c);
        System.assertEquals(3624.88, actual.Net_Disposable_Income_NDI_Num__c);
        System.assertEquals(5, actual.Num_Trades_Opened_Past_24mo__c);

        Test.stopTest();
    }

    /**
     * @param appId app to select with only credit policy fields
     * @return A minimal application instance
     */
    private static genesis__Applications__c selectCreditPolicyFields(String appId) {
        genesis__Applications__c app = [SELECT Id,
                FICO__c,
                Monthly_DTI__c,
                Net_Disposable_Income_NDI_Num__c,
                Num_Trades_Opened_Past_24mo__c,
                Risk_Model_Source__c,
                Risk_Model_Version__c,
                Is_Offer_Presented__c
        FROM   genesis__Applications__c
        WHERE  Id =: appId
        LIMIT  1];
        return app;
    }

    Testmethod static void method4(){
        
        Manual_Adverse_Action_Decline__c mda = new 	Manual_Adverse_Action_Decline__c();
        mda.Decline_Name__c = 'insufficient tradeline balance';
        mda.Description__c = 'So we are unable to proceed with your loan application.';
        mda.Name = 'Expiration_decline_insufficient_tradeline_balances';
        mda.Reason__c = 'Your unsecured consumer debt does not support the amount requested.';
        insert mda;
        Account acc1 = [Select id,name from Account where name='Testfname Testlname' limit 1];
        
        genesis__Applications__c app1 = [select id,genesis__Status__c,Lead_ID__c from genesis__Applications__c where genesis__Status__c='Offer shown' limit 1];
        app1.Manual_Adverse_Action_Decline__c = mda.Id;
        
        update app1;
        StaticResource sr = [Select id,name,body from StaticResource where name='hard_pull'];
        //String bureau = '{"HIAP01_home_equity_monthly_payment":-1,"AADM12_credit_vision_alternative_risk_score":1234,"AGG901_non_mortgage_increases_last_3_mo":6789}';
        String json = sr.body.toString();
        Test.StartTest();
        HardCreditPullResponse hardCreditpull = new HardCreditPullResponse();
        HardCreditPullResponse.All_attributes allatri = new HardCreditPullResponse.All_attributes();
        hardCreditpull.all_attributes  = allatri;
        HardCreditPullResponse.Bureau_report bureaReport = new HardCreditPullResponse.Bureau_report();
        bureaReport.raw_response = json;
        hardCreditpull.all_attributes.bureau_report =bureaReport;
        String req = System.JSON.serialize(hardCreditpull);
        HardCreditPullResponse.parse(req,acc1.id, app1.Id);
        Test.stopTest();
    }
    Testmethod static void canParseParserV62(){
        
        genesis__Applications__c app1 = [select id,genesis__Status__c,Lead_ID__c from genesis__Applications__c where genesis__Status__c='Offer shown' limit 1];
        Account acc1 = [Select id,name from Account where name='Testfname Testlname' limit 1];       
        
        StaticResource sr = [Select id,name,body from StaticResource where name='CreditPolicyTestParserV62'];
        String json = sr.body.toString();
        Test.StartTest();
        CreditPolicyResponse obj = new CreditPolicyResponse();
        obj = obj.parse(json,acc1.Id,app1.Id, app1.Lead_ID__c);
               
        System.assert(obj != null);
        CreditPolicyResponse.credit_policy_decision cpd = obj.credit_policy_decision;
        CreditPolicyResponse.Decision_codes decision_codes = cpd.decision_codes;
        System.assert(decision_codes.invalid_input_knockout_codes != null);
        System.assert(decision_codes.prebureau_knockout_codes != null);
        System.assert(decision_codes.postbureau_knockout_codes != null);
        System.assert(decision_codes.risk_model_codes != null);
        System.assert(cpd.id == null);
        System.assert(cpd.applicant_id == null);
        System.assert(cpd.credit_policy_gem_version != null);
        System.assert(cpd.source == null);
        System.assert(cpd.no_hit == false);
        System.assert(cpd.frozen_report == false);
        System.assert(cpd.pricing_segment == null);
        System.assert(cpd.pricing_tier != null);
        system.assert(cpd.raw_bureau_data != null);
        
        for (CreditPolicyResponse.offers offer : cpd.offers) {
            System.assert(offer.key != null);
            System.assert(offer.amount != null);
            System.assert(offer.term_months != null);
            System.assert(offer.apr != null);
            System.assert(offer.interest_rate != null);
            System.assert(offer.origination_fee_rate != null);
            System.assert(offer.monthly_payment != null);
            System.assert(offer.origination_fee != null);
            System.assert(offer.segment != null);
            System.assert(offer.pricing_tier != null);
            System.assert(offer.above_prime_max != null);
            System.assert(offer.type != null);
            System.assert(offer.Is_Offer_Selected == null);
        }
        System.assert(cpd.debt_to_income != null);
        System.assert(cpd.federal_tax_payment != null);
        System.assert(cpd.net_disposable_income != null);
        System.assert(cpd.overlimit_trend == null);
        System.assert(cpd.percent_delinquency != null);
        System.assert(cpd.tri_highest_card_type_i == null);
        System.assert(cpd.tri_highest_card_type_t == null);
        System.assert(cpd.tradeline_unsecured_installment_loans_opened_last_12_mo != null);
        System.assert(cpd.pricing_policy_filters == null);
        System.assert(cpd.adverse_action_template != null);
        System.assert(cpd.created_at == null);
        System.assert(cpd.updated_at == null);
        
        CreditPolicyResponse.V6 v6 = cpd.risk_models.v6;
        System.assert(v6.risk_model_decision != null);
        //System.assert(v6.risk_model_score != null);
        System.assert(v6.logistic_prediction_of_default != null);
        System.assert(v6.invalid_risk_model_variable_count != null);
        
        System.assert(cpd.request_context != null);
        System.assert(cpd.tradeline_dti_with_lie_detector != null);
        System.assert(cpd.tradeline_ndi_with_lie_detector != null);
        System.assert(cpd.tradeline_unsecured_installment_loans_opened_last_3_mo == null);
        System.assert(cpd.final_decision_level != null);
        System.assert(cpd.days_since_open_unsecured_loan != null);
        System.assert(cpd.tradeline_alliant_charge_off != null);
        System.assert(cpd.tradeline_summary_of_balances != null);
        System.assert(cpd.age_flag == null);
        System.assert(cpd.student_loan_flag == null);
        System.assert(cpd.funding_model != null);         
     
        Test.stopTest(); 
    }
   
    static testMethod void wrapperTest(){
        CreditPolicyResponse obj01 = new CreditPolicyResponse();
        CreditPolicyResponse.Prebureau_knockout_codes obj11 = new CreditPolicyResponse.Prebureau_knockout_codes();
        obj11.rank = 3;
        obj11.code = 'test';
        obj11.description = 'test';
        
        CreditPolicyResponse.TradelineAnalysis obj21 = new CreditPolicyResponse.TradelineAnalysis();
        obj21.credit_card_count= 5;
        obj21.credit_card_balance= 5;
        obj21.credit_card_limit= 5;
        obj21.credit_card_utilization= 5.0;
        obj21.credit_card_monthly_payments= 5;
        obj21.credit_card_closed_with_balance_count= 5;
        obj21.unsecured_installment_loan_count= 5;
        obj21.unsecured_installment_loan_balance= 5;
        obj21.unsecured_installment_loan_opened_last_12_mo= 5;
        obj21.unsecured_installment_loan_monthly_payment= 5;
        obj21.student_loan_count= 5;
        obj21.student_loan_balance= 5;
        obj21.student_loan_monthly_payment= 5;
        obj21.student_loan_deferred_count= 5;
        obj21.auto_loan_count= 5;
        obj21.auto_loan_balance= 5;
        obj21.auto_loan_monthly_payment= 5;
        obj21.mortgage_count= 5;
        obj21.mortgage_balance= 5;
        obj21.mortgage_monthly_payment= 5;
        obj21.heloc_count= 5;
        obj21.heloc_balances= 5;
        obj21.heloc_monthly_payment= 5;
        
        CreditPolicyResponse.Payment_pattern pP = new CreditPolicyResponse.Payment_pattern();
        pP.start_date = '01012020';
        pP.text = 'test';
        
        CreditPolicyResponse.Requestor req = new CreditPolicyResponse.Requestor();
        req.text = 'test';
        CreditPolicyResponse.Historical_counters hC = new CreditPolicyResponse.Historical_counters();
        hC.months_reviewed_count = 'test'; 
        hC.late_30_days_total = 'test'; 
        hC.late_60_days_total = 'test'; 
        hC.late_90_days_total = 'test';
        CreditPolicyResponse.Most_recent_payment mRC = new CreditPolicyResponse.Most_recent_payment();
        mRC.RecentDate = '01012020';
        CreditPolicyResponse.Applicant aPP = new CreditPolicyResponse.Applicant();
        aPP.id = 123; 
            aPP.person_uid = 'test'; 
            aPP.payoff_uid = 'test'; 
            aPP.income_annual = 'test'; 
            aPP.requested_loan_amount = 'test'; 
            aPP.housing_payment = 'test'; 
            aPP.date_of_birth = 'test';            
            aPP.bureau_report_subset = 'test'; 
            aPP.created_at = 'test'; 
            aPP.updated_at = 'test'; 
            aPP.first_name = 'test'; 
            aPP.middle_name = 'test'; 
            aPP.last_name = 'test'; 
            aPP.street1 = 'test'; 
            aPP.street2 = 'test'; 
            aPP.city = 'test'; 
            aPP.state = 'test'; 
            aPP.postal_code = 'test'; 
            aPP.ssn = 'test'; 
            aPP.request_context = 'test'; 
            aPP.credit_policy_version = 'test'; 
            aPP.suffix_name = 'test'; 
            aPP.bureau_request_uid = 'test'; 
            aPP.partner_applicant = 'test'; 
            aPP.selected_vendor_amount = 'test'; 
    }
    
}