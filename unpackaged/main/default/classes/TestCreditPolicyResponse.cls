@isTest
private class TestCreditPolicyResponse {
	@testSetup static void setup(){
            //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
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
     	 Account acc1 = [Select id,name from Account where name='Test' limit 1];
         
         genesis__Applications__c app1 = [select id,genesis__Status__c,Lead_ID__c from genesis__Applications__c where genesis__Status__c='Offer shown' limit 1];
         app1.Manual_Adverse_Action_Decline__c = mda.Id;
         
         update app1;
         //String bureau = '{"HIAP01_home_equity_monthly_payment":-1,"AADM12_credit_vision_alternative_risk_score":1234,"AGG901_non_mortgage_increases_last_3_mo":6789}';
         String json = '{"credit_policy_decision":{"credit_policy_version":"v3","credit_policy_gem_version":"4.1.33","tradeline_analysis":"{}","Bureau_subset":"{}","source":"payoff","tradeline_revolving_trades_balance":2345.89,"max_unsecured_installment_loan_utilization":0.0,"days_since_open_unsecured_loan":"819.0","tradeline_unsecured_installment_loans_balance":0.0,"tradeline_ndi":"1867.3125","tradeline_non_mortgage_trades_monthly_payment":453.0,"days_since_open_unsecured_installment_loan":"919.0","days_since_unsecured_installment_inquiry":"89.0","raw_bureau_data":"raw bureau data","loan_amount_counteroffer":"7000","final_decision":"Decline","request_intent":"verification","federal_tax_payment":"3251.25","state_tax_payment":"3905.0","tradeline_dti":0.491771428571429,"monthly_dti":0.23423452,"decision_codes":{"invalid_input_knockout_codes":["invalid_data_PAYMNT08_min_payment_revolving_ratio_missing","invalid_data_TRV12_revolving_high_credit_increases_last_3_mo_missing","invalid_data_RVLR14_revolver_transactor_inactive_pattern_missing"],"prebureau_knockout_codes":[],"postbureau_knockout_codes":[],"risk_model_codes":["risk_model_fico_score_low","risk_model_ndi_low","risk_model_percent_satisfactory_trades_last_24_mo_low","risk_model_mo_since_oldest_credit_card_opened_low"],"adverse_actions":[{"reason":"No reason","name":"Test","description":"No"}],"score_factor_text":[{"rank":"10","description":"ddesc","code":"123.678"}]},"metadata":{"status":200}}}';                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
         //String json = '{"credit_policy_decision":{"credit_policy_version":"v3","credit_policy_gem_version":"4.1.33","source":"payoff","days_since_open_unsecured_loan":"819.0","days_since_open_unsecured_installment_loan":"919.0","days_since_unsecured_installment_inquiry":"89.0","raw_bureau_data":"raw bureau data","loan_amount_counteroffer":"7000","final_decision":"Decline","request_intent":"verification","federal_tax_payment":3251.25,"state_tax_payment":3905.0,"tradeline_dti":0.491771428571429,"monthly_dti":0.23423452,"tradeline_unsecured_installment_loans_balance":0.0,"tradeline_revolving_trades_balance":"17212.0","max_unsecured_installment_loan_utilization":"0.0","tradeline_non_mortgage_trades_monthly_payment":"453.0","tradeline_ndi":"1867.3125","decision_codes":{"invalid_input_knockout_codes":["invalid_data_PAYMNT08_min_payment_revolving_ratio_missing","invalid_data_TRV12_revolving_high_credit_increases_last_3_mo_missing","invalid_data_RVLR14_revolver_transactor_inactive_pattern_missing"],"prebureau_knockout_codes":[],"postbureau_knockout_codes":[],"risk_model_codes":["risk_model_fico_score_low","risk_model_ndi_low","risk_model_percent_satisfactory_trades_last_24_mo_low","risk_model_mo_since_oldest_credit_card_opened_low"],"adverse_actions":[{"reason":"No reason","name":"Test","description":"No"}],"score_factor_text":[]},"probability_differences":{"risk_model_min_payment_revolving_ratio_low":-0.19750776338280002,"risk_model_trades_30_days_past_due_high":0.0,"risk_model_inquiries_last_6_mo_high":-0.02342364,"risk_model_mo_since_recent_charge_off_opened_low":0.0,"risk_model_non_mortgage_increases_high":"-0.14200806","risk_model_percent_delinquency_high":"0.0","risk_model_percent_high_revolving_trade_utilization_high":"-0.16278675","risk_model_ndi_low":"-0.5557961939400001","risk_model_consumer_tri_highest_card_type_t_low":"-0.05804013","risk_model_mo_since_oldest_credit_card_opened_low":"-0.23259331","risk_model_dti_high":"-0.06538871167038594285714285714285714285714371234442228","risk_model_percent_satisfactory_trades_last_24_mo_low":-0.48671481,"risk_model_overlimit_trend_high":"0.0","risk_model_consumer_tri_highest_card_type_i_high":"0.0","risk_model_max_bankcard_utilization_high":-0.10801354,"risk_model_percent_trades_opened_last_24_mo_high":0.0,"risk_model_non_medical_collections_high":0.0,"risk_model_number_of_open_credit_cards_high":-0.14254735,"risk_model_fico_score_low":"-1.820333939999999667","risk_model_revolving_high_credit_increases_high":-0.07806163,"risk_model_installment_loans_high":"0.0"},"tradeline_analysis":{"credit_card_count":8,"credit_card_balance":17212,"credit_card_limit":17100,"credit_card_utilization":100.65497076023391,"credit_card_monthly_payments":311,"credit_card_closed_with_balance_count":0,"unsecured_installment_loan_count":0,"unsecured_installment_loan_balance":0,"unsecured_installment_loan_opened_last_12_mo":0,"unsecured_installment_loan_monthly_payment":0,"student_loan_count":2,"student_loan_balance":9549,"student_loan_monthly_payment":142,"student_loan_deferred_count":0,"auto_loan_count":0,"auto_loan_balance":0,"auto_loan_monthly_payment":0,"mortgage_count":0,"mortgage_balance":0,"mortgage_monthly_payment":0,"heloc_count":0,"heloc_balances":0,"heloc_monthly_payment":0},"_metadata":{"status":200}}}';                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
         // String json1 = '{"credit_policy_decision":{"raw_bureau_data":"raw bureau data","final_decision":"Decline","request_intent":"verification"';
         Test.StartTest();
         CreditPolicyResponse obj = new CreditPolicyResponse();
         obj.parse(json,acc1.id,app1.id, app1.Lead_ID__c);
         //obj.parse(json1,acc1.id,app1.id, app1.Lead_ID__c);
         System.assert(obj != null);
         Test.stopTest();
     }
    
    Testmethod static void method2(){
         
         Manual_Adverse_Action_Decline__c mda = new 	Manual_Adverse_Action_Decline__c();
         mda.Decline_Name__c = 'insufficient tradeline balance';
         mda.Description__c = 'So we are unable to proceed with your loan application.';
         mda.Name = 'Expiration_decline_insufficient_tradeline_balances';
         mda.Reason__c = 'Your unsecured consumer debt does not support the amount requested.';
         insert mda;
     	 Account acc1 = [Select id,name from Account where name='Test' limit 1];
         
         genesis__Applications__c app1 = [select id,genesis__Status__c,Lead_ID__c from genesis__Applications__c where genesis__Status__c='Offer shown' limit 1];
         app1.Manual_Adverse_Action_Decline__c = mda.Id;
         
         update app1;
         //String bureau = '{"HIAP01_home_equity_monthly_payment":-1,"AADM12_credit_vision_alternative_risk_score":1234,"AGG901_non_mortgage_increases_last_3_mo":6789}';
         String json = '{"credit_policy_decision":{"credit_policy_version":"v3","credit_policy_gem_version":"4.1.33","tradeline_analysis":"{}","Bureau_subset":"{}","source":"payoff","tradeline_revolving_trades_balance":2345.89,"max_unsecured_installment_loan_utilization":0.0,"days_since_open_unsecured_loan":"819.0","tradeline_unsecured_installment_loans_balance":0.0,"tradeline_ndi":"1867.3125","tradeline_non_mortgage_trades_monthly_payment":453.0,"days_since_open_unsecured_installment_loan":"919.0","days_since_unsecured_installment_inquiry":"89.0","raw_bureau_data":"raw bureau data","loan_amount_counteroffer":"7000","final_decision":"Decline","request_intent":"verification","federal_tax_payment":"3251.25","state_tax_payment":"3905.0","tradeline_dti":0.491771428571429,"monthly_dti":0.23423452,"decision_codes":{"invalid_input_knockout_codes":["invalid_data_PAYMNT08_min_payment_revolving_ratio_missing","invalid_data_TRV12_revolving_high_credit_increases_last_3_mo_missing","invalid_data_RVLR14_revolver_transactor_inactive_pattern_missing"],"prebureau_knockout_codes":[],"postbureau_knockout_codes":[],"risk_model_codes":["risk_model_fico_score_low","risk_model_ndi_low","risk_model_percent_satisfactory_trades_last_24_mo_low","risk_model_mo_since_oldest_credit_card_opened_low"],"adverse_actions":[{"reason":"No reason","name":"Test","description":"No"}],"score_factor_text":[{"rank":"10","description":"ddesc","code":"123.678"}]},"metadata":{"status":200}}}';                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
         //String json = '{"credit_policy_decision":{"credit_policy_version":"v3","credit_policy_gem_version":"4.1.33","source":"payoff","days_since_open_unsecured_loan":"819.0","days_since_open_unsecured_installment_loan":"919.0","days_since_unsecured_installment_inquiry":"89.0","raw_bureau_data":"raw bureau data","loan_amount_counteroffer":"7000","final_decision":"Decline","request_intent":"verification","federal_tax_payment":3251.25,"state_tax_payment":3905.0,"tradeline_dti":0.491771428571429,"monthly_dti":0.23423452,"tradeline_unsecured_installment_loans_balance":0.0,"tradeline_revolving_trades_balance":"17212.0","max_unsecured_installment_loan_utilization":"0.0","tradeline_non_mortgage_trades_monthly_payment":"453.0","tradeline_ndi":"1867.3125","decision_codes":{"invalid_input_knockout_codes":["invalid_data_PAYMNT08_min_payment_revolving_ratio_missing","invalid_data_TRV12_revolving_high_credit_increases_last_3_mo_missing","invalid_data_RVLR14_revolver_transactor_inactive_pattern_missing"],"prebureau_knockout_codes":[],"postbureau_knockout_codes":[],"risk_model_codes":["risk_model_fico_score_low","risk_model_ndi_low","risk_model_percent_satisfactory_trades_last_24_mo_low","risk_model_mo_since_oldest_credit_card_opened_low"],"adverse_actions":[{"reason":"No reason","name":"Test","description":"No"}],"score_factor_text":[]},"probability_differences":{"risk_model_min_payment_revolving_ratio_low":-0.19750776338280002,"risk_model_trades_30_days_past_due_high":0.0,"risk_model_inquiries_last_6_mo_high":-0.02342364,"risk_model_mo_since_recent_charge_off_opened_low":0.0,"risk_model_non_mortgage_increases_high":"-0.14200806","risk_model_percent_delinquency_high":"0.0","risk_model_percent_high_revolving_trade_utilization_high":"-0.16278675","risk_model_ndi_low":"-0.5557961939400001","risk_model_consumer_tri_highest_card_type_t_low":"-0.05804013","risk_model_mo_since_oldest_credit_card_opened_low":"-0.23259331","risk_model_dti_high":"-0.06538871167038594285714285714285714285714371234442228","risk_model_percent_satisfactory_trades_last_24_mo_low":-0.48671481,"risk_model_overlimit_trend_high":"0.0","risk_model_consumer_tri_highest_card_type_i_high":"0.0","risk_model_max_bankcard_utilization_high":-0.10801354,"risk_model_percent_trades_opened_last_24_mo_high":0.0,"risk_model_non_medical_collections_high":0.0,"risk_model_number_of_open_credit_cards_high":-0.14254735,"risk_model_fico_score_low":"-1.820333939999999667","risk_model_revolving_high_credit_increases_high":-0.07806163,"risk_model_installment_loans_high":"0.0"},"tradeline_analysis":{"credit_card_count":8,"credit_card_balance":17212,"credit_card_limit":17100,"credit_card_utilization":100.65497076023391,"credit_card_monthly_payments":311,"credit_card_closed_with_balance_count":0,"unsecured_installment_loan_count":0,"unsecured_installment_loan_balance":0,"unsecured_installment_loan_opened_last_12_mo":0,"unsecured_installment_loan_monthly_payment":0,"student_loan_count":2,"student_loan_balance":9549,"student_loan_monthly_payment":142,"student_loan_deferred_count":0,"auto_loan_count":0,"auto_loan_balance":0,"auto_loan_monthly_payment":0,"mortgage_count":0,"mortgage_balance":0,"mortgage_monthly_payment":0,"heloc_count":0,"heloc_balances":0,"heloc_monthly_payment":0},"_metadata":{"status":200}}}';                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
         // String json1 = '{"credit_policy_decision":{"raw_bureau_data":"raw bureau data","final_decision":"Decline","request_intent":"verification"';
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
     	 Account acc1 = [Select id,name from Account where name='Test' limit 1];
         
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
         
         Manual_Adverse_Action_Decline__c mda = new 	Manual_Adverse_Action_Decline__c();
         mda.Decline_Name__c = 'insufficient tradeline balance';
         mda.Description__c = 'So we are unable to proceed with your loan application.';
         mda.Name = 'Expiration_decline_insufficient_tradeline_balances';
         mda.Reason__c = 'Your unsecured consumer debt does not support the amount requested.';
         insert mda;
     	 Account acc1 = [Select id,name from Account where name='Test' limit 1];
         
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
    
    Testmethod static void method4(){
         
         Manual_Adverse_Action_Decline__c mda = new 	Manual_Adverse_Action_Decline__c();
         mda.Decline_Name__c = 'insufficient tradeline balance';
         mda.Description__c = 'So we are unable to proceed with your loan application.';
         mda.Name = 'Expiration_decline_insufficient_tradeline_balances';
         mda.Reason__c = 'Your unsecured consumer debt does not support the amount requested.';
         insert mda;
     	 Account acc1 = [Select id,name from Account where name='Test' limit 1];
         
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
    
    
}