/* ****************Modification History******************
* Updated By        Date				Jira Number		 
*1. Bhanupriya       2022/03/011     	LSP-609		(Add required fields,comments and assert statement)
******************Modification History******************/
@isTest

private class TestKBAResponse{
    //Create testsetup()
    @testSetup static void setup(){
        //Creating Account
        genesis__Org_Parameters__c genorg = genesis__Org_Parameters__c.getOrgDefaults();
        genorg.genesis__Disable_Triggers__c = true;
        upsert genorg;
        
        loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
        org.loan__Disable_Triggers__c = true;
        upsert org;


        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123456789',
            peer__Last_Name__c = 'LastName',
            peer__First_Name__c = 'FirstName'
            );
        insert acc;
        
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
            genesis__Status__c = 'agent_verified',
            genesis__Draw_Period_End_Date__c = system.Today()
        );
        insert app;


        //Kba Details
        KBA_Details__c kbaObj = new KBA_Details__c(
            Application__c = app.Id,
            Precise_ID_Overall_SCore__c = 9012, 
            Precise_ID_First_Payment_Default__c = 9012, 
            Precise_ID_ID_Theft__c = 9012,  
            Precise_ID_Validation__c = 9012, 
            Precise_ID_Adverse_Action_Code__c = 'I', 
            Precise_ID_Decision__c = 'Accept',
            Precise_ID_Decision_KIQ__c = 'Accept', 
            Precise_ID_General_Fraud_Shield_Indicat__c = 'F04', 
            Id_Analytics_Score__c = 500, 
            Consistency_Snapd_score__c = 30, 
            Paste_Count__c = 1,
            Public_Records__c=0,
            Accept_Refer_Code__c= 'ACC'  //CRM-966
        );
       Insert kbaObj;
       app.genesis__Status__c = 'agent_verified';
       update app;
        
    }
    //Test method
    @isTest
    public static void kbaResponseDetails(){
        Account acc1 = [Select id,name,peer__Last_Name__c 
                        from Account 
                        where peer__Last_Name__c ='LastName'];
        genesis__Applications__c app = [select id,genesis__Status__c 
                        from genesis__Applications__c LIMIT 1];
        system.debug('app-->'+ app);
        genesis__Applications__c app1 = [select id,genesis__Status__c 
                                         from genesis__Applications__c 
                                         where genesis__Status__c='agent_verified' limit 1];
        String json = '{"kiq_result":{"updated_at":"13/04/2015","review_reference_id":"154qw","result_code_description":"Success","result_code":"13213424","reference_number":"121313","precise_id_score":"500","payoff_uid":"Abc","out_wallet_score":"213","kba_session_id":123323,"id":123,"final_decision":"ACC","created_at":"12/03/2015","additional_data":"No","accept_refer_code":"12"},"kba_attempts":2,"kba":null,"fraud_shield_result":{"verification_score":23,"validation_score":54,"updated_at":"15/08/2013","ssn_result_description":"correct","ssn_result":"1314124","ssn_issue_start_range":"13/03/2013","ssn_issue_end_range":"12/03/2013","scores":{"verification_score":232,"validation_score":242,"precise_id_score":22,"fpd_score":121},"review_reference_id":"1324","reference_number":"A","reasons":"Unknown","precise_id_score":32,"phone_verification_result_description":"Success","phone_verification_result":"success","payoff_uid":"ABC","ofac_validation_result_description":"Success","ofac_validation_result":"Success","kba_session_id":123,"id":13213,"fraud_shield_indicators":[{"description":"Test","code":"FS09"}],"fraud_shield_description":"12","fraud_shield_code":"123","fpd_score":20,"final_decision":"ACC","date_of_birth_match_description":"Matched","date_of_birth_match":"true","created_at":"12/08/2013","adverse_actions":[{"reason":"No reason","name":"Test","description":"No"}],"additional_data":"no data"}}';
        String json1 = '{"kiq_result":{"updated_at":"13/04/2015","review_reference_id":"154qw","result_code_description":"Success","result_code":"13213424","reference_number":"121313","precise_id_score":"500","payoff_uid":"Abc","out_wallet_score":"213","kba_session_id":123323,"id":123,"final_decision":"REF","created_at":"12/03/2015","additional_data":"No","accept_refer_code":"12"},"kba_attempts":2,"kba":null,"fraud_shield_result":{"verification_score":23,"validation_score":54,"updated_at":"15/08/2013","ssn_result_description":"correct","ssn_result":"1314124","ssn_issue_start_range":"13/03/2013","ssn_issue_end_range":"12/03/2013","scores":{"verification_score":232,"validation_score":242,"precise_id_score":22,"fpd_score":121},"review_reference_id":"1324","reference_number":"A","reasons":"Unknown","precise_id_score":32,"phone_verification_result_description":"Success","phone_verification_result":"success","payoff_uid":"ABC","ofac_validation_result_description":"Success","ofac_validation_result":"Success","kba_session_id":123,"id":13213,"fraud_shield_indicators":[{"description":"Test","code":"FS01"}],"fraud_shield_description":"12","fraud_shield_code":"123","fpd_score":20,"final_decision":"REF","date_of_birth_match_description":"Matched","date_of_birth_match":"true","created_at":"12/08/2013","adverse_actions":[{"reason":"No reason","name":"Test","description":"No"}],"additional_data":"no data"}}';
        String json2 = '{"kiq_result":{"updated_at":"13/04/2015","review_reference_id":"154qw","result_code_description":"Success","result_code":"13213424","reference_number":"121313","precise_id_score":"500","payoff_uid":"Abc","out_wallet_score":"213","kba_session_id":123323,"id":123,"final_decision":"R01","created_at":"12/03/2015","additional_data":"No","accept_refer_code":"12"},"kba_attempts":2,"kba":null,"fraud_shield_result":{"verification_score":23,"validation_score":54,"updated_at":"15/08/2013","ssn_result_description":"correct","ssn_result":"1314124","ssn_issue_start_range":"13/03/2013","ssn_issue_end_range":"12/03/2013","scores":{"verification_score":232,"validation_score":242,"precise_id_score":22,"fpd_score":121},"review_reference_id":"1324","reference_number":"A","reasons":"Unknown","precise_id_score":32,"phone_verification_result_description":"Success","phone_verification_result":"success","payoff_uid":"ABC","ofac_validation_result_description":"Success","ofac_validation_result":"Success","kba_session_id":123,"id":13213,"fraud_shield_indicators":[{"description":"Test","code":"FS07"}],"fraud_shield_description":"12","fraud_shield_code":"123","fpd_score":20,"final_decision":"R01","date_of_birth_match_description":"Matched","date_of_birth_match":"true","created_at":"12/08/2013","adverse_actions":[{"reason":"No reason","name":"Test","description":"No"}],"additional_data":"no data"}}';
        String json3 = '{"kiq_result":{"updated_at":"13/04/2015","review_reference_id":"154qw","result_code_description":"Success","result_code":"13213424","reference_number":"121313","precise_id_score":"500","payoff_uid":"Abc","out_wallet_score":"213","kba_session_id":123323,"id":123,"final_decision":"R10","created_at":"12/03/2015","additional_data":"No","accept_refer_code":"12"},"kba_attempts":2,"kba":null,"fraud_shield_result":{"verification_score":23,"validation_score":54,"updated_at":"15/08/2013","ssn_result_description":"correct","ssn_result":"1314124","ssn_issue_start_range":"13/03/2013","ssn_issue_end_range":"12/03/2013","scores":{"verification_score":232,"validation_score":242,"precise_id_score":22,"fpd_score":121},"review_reference_id":"1324","reference_number":"A","reasons":"Unknown","precise_id_score":32,"phone_verification_result_description":"Success","phone_verification_result":"success","payoff_uid":"ABC","ofac_validation_result_description":"Success","ofac_validation_result":"Success","kba_session_id":123,"id":13213,"fraud_shield_indicators":[{"description":"Test","code":"FS04"}],"fraud_shield_description":"12","fraud_shield_code":"123","fpd_score":20,"final_decision":"R10","date_of_birth_match_description":"Matched","date_of_birth_match":"true","created_at":"12/08/2013","adverse_actions":[{"reason":"No reason","name":"Test","description":"No"}],"additional_data":"no data"}}';
        String json4 = '{"kiq_result":{"updated_at":"13/04/2015","review_reference_id":"154qw","result_code_description":"Success","result_code":"13213424","reference_number":"121313","precise_id_score":"500","payoff_uid":"Abc","out_wallet_score":"213","kba_session_id":123323,"id":123,"final_decision":"R20","created_at":"12/03/2015","additional_data":"No","accept_refer_code":"12"},"kba_attempts":2,"kba":null,"fraud_shield_result":{"verification_score":23,"validation_score":54,"updated_at":"15/08/2013","ssn_result_description":"correct","ssn_result":"1314124","ssn_issue_start_range":"13/03/2013","ssn_issue_end_range":"12/03/2013","scores":{"verification_score":232,"validation_score":242,"precise_id_score":22,"fpd_score":121},"review_reference_id":"1324","reference_number":"A","reasons":"Unknown","precise_id_score":32,"phone_verification_result_description":"Success","phone_verification_result":"success","payoff_uid":"ABC","ofac_validation_result_description":"Success","ofac_validation_result":"Success","kba_session_id":123,"id":13213,"fraud_shield_indicators":[{"description":"Test","code":"FS09"}],"fraud_shield_description":"12","fraud_shield_code":"123","fpd_score":20,"final_decision":"R20","date_of_birth_match_description":"Matched","date_of_birth_match":"true","created_at":"12/08/2013","adverse_actions":[{"reason":"No reason","name":"Test","description":"No"}],"additional_data":"no data"}}';
        String json5 = '{"kiq_result":{"updated_at":"13/04/2015","review_reference_id":"154qw","result_code_description":"Success","result_code":"13213424","reference_number":"121313","precise_id_score":"500","payoff_uid":"Abc","out_wallet_score":"213","kba_session_id":123323,"id":123,"final_decision":"R30","created_at":"12/03/2015","additional_data":"No","accept_refer_code":"12"},"kba_attempts":2,"kba":null,"fraud_shield_result":{"verification_score":23,"validation_score":54,"updated_at":"15/08/2013","ssn_result_description":"correct","ssn_result":"1314124","ssn_issue_start_range":"13/03/2013","ssn_issue_end_range":"12/03/2013","scores":{"verification_score":232,"validation_score":242,"precise_id_score":22,"fpd_score":121},"review_reference_id":"1324","reference_number":"A","reasons":"Unknown","precise_id_score":32,"phone_verification_result_description":"Success","phone_verification_result":"success","payoff_uid":"ABC","ofac_validation_result_description":"Success","ofac_validation_result":"Success","kba_session_id":123,"id":13213,"fraud_shield_indicators":[{"description":"Test","code":"FS09"}],"fraud_shield_description":"12","fraud_shield_code":"123","fpd_score":20,"final_decision":"R30","date_of_birth_match_description":"Matched","date_of_birth_match":"true","created_at":"12/08/2013","adverse_actions":[{"reason":"No reason","name":"Test","description":"No"}],"additional_data":"no data"}}';
        String json6 = '{"kiq_result":{"updated_at":"13/04/2015","review_reference_id":"154qw","result_code_description":"Success","result_code":"13213424","reference_number":"121313","precise_id_score":"500","payoff_uid":"Abc","out_wallet_score":"213","kba_session_id":123323,"id":123,"final_decision":"R40","created_at":"12/03/2015","additional_data":"No","accept_refer_code":"12"},"kba_attempts":2,"kba":null,"fraud_shield_result":{"verification_score":23,"validation_score":54,"updated_at":"15/08/2013","ssn_result_description":"correct","ssn_result":"1314124","ssn_issue_start_range":"13/03/2013","ssn_issue_end_range":"12/03/2013","scores":{"verification_score":232,"validation_score":242,"precise_id_score":22,"fpd_score":121},"review_reference_id":"1324","reference_number":"A","reasons":"Unknown","precise_id_score":32,"phone_verification_result_description":"Success","phone_verification_result":"success","payoff_uid":"ABC","ofac_validation_result_description":"Success","ofac_validation_result":"Success","kba_session_id":123,"id":13213,"fraud_shield_indicators":[{"description":"Test","code":"FS09"}],"fraud_shield_description":"12","fraud_shield_code":"123","fpd_score":20,"final_decision":"R40","date_of_birth_match_description":"Matched","date_of_birth_match":"true","created_at":"12/08/2013","adverse_actions":[{"reason":"No reason","name":"Test","description":"No"}],"additional_data":"no data"}}';
        String json7 = '{"kiq_result":{"updated_at":"13/04/2015","review_reference_id":"154qw","result_code_description":"Success","result_code":"13213424","reference_number":"121313","precise_id_score":"500","payoff_uid":"Abc","out_wallet_score":"213","kba_session_id":123323,"id":123,"final_decision":"R50","created_at":"12/03/2015","additional_data":"No","accept_refer_code":"12"},"kba_attempts":2,"kba":null,"fraud_shield_result":{"verification_score":23,"validation_score":54,"updated_at":"15/08/2013","ssn_result_description":"correct","ssn_result":"1314124","ssn_issue_start_range":"13/03/2013","ssn_issue_end_range":"12/03/2013","scores":{"verification_score":232,"validation_score":242,"precise_id_score":22,"fpd_score":121},"review_reference_id":"1324","reference_number":"A","reasons":"Unknown","precise_id_score":32,"phone_verification_result_description":"Success","phone_verification_result":"success","payoff_uid":"ABC","ofac_validation_result_description":"Success","ofac_validation_result":"Success","kba_session_id":123,"id":13213,"fraud_shield_indicators":[{"description":"Test","code":"FS09"}],"fraud_shield_description":"12","fraud_shield_code":"123","fpd_score":20,"final_decision":"R50","date_of_birth_match_description":"Matched","date_of_birth_match":"true","created_at":"12/08/2013","adverse_actions":[{"reason":"No reason","name":"Test","description":"No"}],"additional_data":"no data"}}';
        String json8 = '{"kiq_result":{"updated_at":"13/04/2015","review_reference_id":"154qw","result_code_description":"Success","result_code":"13213424","reference_number":"121313","precise_id_score":"500","payoff_uid":"Abc","out_wallet_score":"213","kba_session_id":123323,"id":123,"final_decision":"R60","created_at":"12/03/2015","additional_data":"No","accept_refer_code":"12"},"kba_attempts":2,"kba":null,"fraud_shield_result":{"verification_score":23,"validation_score":54,"updated_at":"15/08/2013","ssn_result_description":"correct","ssn_result":"1314124","ssn_issue_start_range":"13/03/2013","ssn_issue_end_range":"12/03/2013","scores":{"verification_score":232,"validation_score":242,"precise_id_score":22,"fpd_score":121},"review_reference_id":"1324","reference_number":"A","reasons":"Unknown","precise_id_score":32,"phone_verification_result_description":"Success","phone_verification_result":"success","payoff_uid":"ABC","ofac_validation_result_description":"Success","ofac_validation_result":"Success","kba_session_id":123,"id":13213,"fraud_shield_indicators":[{"description":"Test","code":"FS09"}],"fraud_shield_description":"12","fraud_shield_code":"123","fpd_score":20,"final_decision":"R60","date_of_birth_match_description":"Matched","date_of_birth_match":"true","created_at":"12/08/2013","adverse_actions":[{"reason":"No reason","name":"Test","description":"No"}],"additional_data":"no data"}}';
        String json9 = '{"kiq_result":{"updated_at":"13/04/2015","review_reference_id":"154qw","result_code_description":"Success","result_code":"13213424","reference_number":"121313","precise_id_score":"500","payoff_uid":"Abc","out_wallet_score":"213","kba_session_id":123323,"id":123,"final_decision":"R70","created_at":"12/03/2015","additional_data":"No","accept_refer_code":"12"},"kba_attempts":2,"kba":null,"fraud_shield_result":{"verification_score":23,"validation_score":54,"updated_at":"15/08/2013","ssn_result_description":"correct","ssn_result":"1314124","ssn_issue_start_range":"13/03/2013","ssn_issue_end_range":"12/03/2013","scores":{"verification_score":232,"validation_score":242,"precise_id_score":22,"fpd_score":121},"review_reference_id":"1324","reference_number":"A","reasons":"Unknown","precise_id_score":32,"phone_verification_result_description":"Success","phone_verification_result":"success","payoff_uid":"ABC","ofac_validation_result_description":"Success","ofac_validation_result":"Success","kba_session_id":123,"id":13213,"fraud_shield_indicators":[{"description":"Test","code":"FS09"}],"fraud_shield_description":"12","fraud_shield_code":"123","fpd_score":20,"final_decision":"R70","date_of_birth_match_description":"Matched","date_of_birth_match":"true","created_at":"12/08/2013","adverse_actions":[{"reason":"No reason","name":"Test","description":"No"}],"additional_data":"no data"}}';
        String json10 = '{"kiq_result":{"updated_at":"13/04/2015","review_reference_id":"154qw","result_code_description":"Success","result_code":"13213424","reference_number":"121313","precise_id_score":"500","payoff_uid":"Abc","out_wallet_score":"213","kba_session_id":123323,"id":123,"final_decision":"R80","created_at":"12/03/2015","additional_data":"No","accept_refer_code":"12"},"kba_attempts":2,"kba":null,"fraud_shield_result":{"verification_score":23,"validation_score":54,"updated_at":"15/08/2013","ssn_result_description":"correct","ssn_result":"1314124","ssn_issue_start_range":"13/03/2013","ssn_issue_end_range":"12/03/2013","scores":{"verification_score":232,"validation_score":242,"precise_id_score":22,"fpd_score":121},"review_reference_id":"1324","reference_number":"A","reasons":"Unknown","precise_id_score":32,"phone_verification_result_description":"Success","phone_verification_result":"success","payoff_uid":"ABC","ofac_validation_result_description":"Success","ofac_validation_result":"Success","kba_session_id":123,"id":13213,"fraud_shield_indicators":[{"description":"Test","code":"FS09"}],"fraud_shield_description":"12","fraud_shield_code":"123","fpd_score":20,"final_decision":"R80","date_of_birth_match_description":"Matched","date_of_birth_match":"true","created_at":"12/08/2013","adverse_actions":[{"reason":"No reason","name":"Test","description":"No"}],"additional_data":"no data"}}';
        String json11 = '{"kiq_result":{"updated_at":"13/04/2015","review_reference_id":"154qw","result_code_description":"Success","result_code":"13213424","reference_number":"121313","precise_id_score":"500","payoff_uid":"Abc","out_wallet_score":"213","kba_session_id":123323,"id":123,"final_decision":"R90","created_at":"12/03/2015","additional_data":"No","accept_refer_code":"12"},"kba_attempts":2,"kba":null,"fraud_shield_result":{"verification_score":23,"validation_score":54,"updated_at":"15/08/2013","ssn_result_description":"correct","ssn_result":"1314124","ssn_issue_start_range":"13/03/2013","ssn_issue_end_range":"12/03/2013","scores":{"verification_score":232,"validation_score":242,"precise_id_score":22,"fpd_score":121},"review_reference_id":"1324","reference_number":"A","reasons":"Unknown","precise_id_score":32,"phone_verification_result_description":"Success","phone_verification_result":"success","payoff_uid":"ABC","ofac_validation_result_description":"Success","ofac_validation_result":"Success","kba_session_id":123,"id":13213,"fraud_shield_indicators":[{"description":"Test","code":"FS09"}],"fraud_shield_description":"12","fraud_shield_code":"123","fpd_score":20,"final_decision":"R90","date_of_birth_match_description":"Matched","date_of_birth_match":"true","created_at":"12/08/2013","adverse_actions":[{"reason":"No reason","name":"Test","description":"No"}],"additional_data":"no data"}}';
        String json12 = '{"kiq_result":{"updated_at":"13/04/2015","review_reference_id":"154qw","result_code_description":"Success","result_code":"13213424","reference_number":"121313","precise_id_score":"500","payoff_uid":"Abc","out_wallet_score":"213","kba_session_id":123323,"id":123,"final_decision":"R99","created_at":"12/03/2015","additional_data":"No","accept_refer_code":"12"},"kba_attempts":2,"kba":null,"fraud_shield_result":{"verification_score":23,"validation_score":54,"updated_at":"15/08/2013","ssn_result_description":"correct","ssn_result":"1314124","ssn_issue_start_range":"13/03/2013","ssn_issue_end_range":"12/03/2013","scores":{"verification_score":232,"validation_score":242,"precise_id_score":22,"fpd_score":121},"review_reference_id":"1324","reference_number":"A","reasons":"Unknown","precise_id_score":32,"phone_verification_result_description":"Success","phone_verification_result":"success","payoff_uid":"ABC","ofac_validation_result_description":"Success","ofac_validation_result":"Success","kba_session_id":123,"id":13213,"fraud_shield_indicators":[{"description":"Test","code":"FS09"}],"fraud_shield_description":"12","fraud_shield_code":"123","fpd_score":20,"final_decision":"R99","date_of_birth_match_description":"Matched","date_of_birth_match":"true","created_at":"12/08/2013","adverse_actions":[{"reason":"No reason","name":"Test","description":"No"}],"additional_data":"no data"}}';
        String json13 = '{"kiq_result":{"updated_at":"13/04/2015","review_reference_id":"154qw","result_code_description":"Success","result_code":"13213424","reference_number":"121313","precise_id_score":"500","payoff_uid":"Abc","out_wallet_score":"213","kba_session_id":123323,"id":123,"final_decision":"XXX","created_at":"12/03/2015","additional_data":"No","accept_refer_code":"12"},"kba_attempts":2,"kba":null,"fraud_shield_result":{"verification_score":23,"validation_score":54,"updated_at":"15/08/2013","ssn_result_description":"correct","ssn_result":"1314124","ssn_issue_start_range":"13/03/2013","ssn_issue_end_range":"12/03/2013","scores":{"verification_score":232,"validation_score":242,"precise_id_score":22,"fpd_score":121},"review_reference_id":"1324","reference_number":"A","reasons":"Unknown","precise_id_score":32,"phone_verification_result_description":"Success","phone_verification_result":"success","payoff_uid":"ABC","ofac_validation_result_description":"Success","ofac_validation_result":"Success","kba_session_id":123,"id":13213,"fraud_shield_indicators":[{"description":"Test","code":"FS09"}],"fraud_shield_description":"12","fraud_shield_code":"123","fpd_score":20,"final_decision":"XXX","date_of_birth_match_description":"Matched","date_of_birth_match":"true","created_at":"12/08/2013","adverse_actions":[{"reason":"No reason","name":"Test","description":"No"}],"additional_data":"no data"}}';
 
        
        Test.StartTest();
        KBAResponse obj = new KBAResponse();
       	KBAResponse k1 = KBAResponse.parse(json,acc1.id,app1.id);
        KBAResponse k2 = KBAResponse.parse(json1,acc1.id,app1.id);
        KBAResponse k3 = KBAResponse.parse(json2,acc1.id,app1.id);
        KBAResponse k4 = KBAResponse.parse(json3,acc1.id,app1.id);
        KBAResponse k5 = KBAResponse.parse(json4,acc1.id,app1.id);
        KBAResponse k6 = KBAResponse.parse(json5,acc1.id,app1.id);
        KBAResponse k7 = KBAResponse.parse(json6,acc1.id,app1.id);
        KBAResponse k8 = KBAResponse.parse(json7,acc1.id,app1.id);
        KBAResponse k9 = KBAResponse.parse(json8,acc1.id,app1.id);
        KBAResponse k10 = KBAResponse.parse(json9,acc1.id,app1.id);
        KBAResponse k11 = KBAResponse.parse(json10,acc1.id,app1.id);
        KBAResponse k12 = KBAResponse.parse(json11,acc1.id,app1.id);
        KBAResponse k13 = KBAResponse.parse(json12,acc1.id,app1.id);
        KBAResponse k14 = KBAResponse.parse(json13,acc1.id,app1.id);
        Test.stopTest();
        system.assert(obj!=null);
        system.assert(k1!=null);
        system.assertNotEquals(k2,k3);
        system.assert(k12!=null);
        system.assertNotEquals(k6,k8);
        system.assert(k14!=null);
        system.assertNotEquals(k4,k5);
        system.assert(k10!=null);
        system.assert(k7!=null);
        system.assertNotEquals(k11,k13);
        system.assert(k9!=null);

       }
    
}