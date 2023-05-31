@isTest
private class TestWSGetPricingOffer{
    @testSetup static void setup() {
        //Creating Account
        Account accTest = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName',
            peer__Last_Name__c='TestLName', 
            City__c='TestCity',
            State__c='TestState',
            ZIP_Code__c='123456'
        );
        insert accTest;
        System.assertEquals('Test',accTest.Name,'Wrong Account');
        
        //Creating Application
        genesis__Applications__c appTest= new genesis__Applications__c(
                                        genesis__Due_Day__c = 20,
                                        genesis__Expected_First_Payment_Date__c = system.Today(),
                                        genesis__Expected_Start_Date__c = system.Today(),
                                        genesis__Funding_in_Tranches__c = true,
                                        Borrower_s_Email__c = null,
                                        genesis__Account__c = accTest.Id,
                                        Application_Start_DateV2__c = system.Today(),
                                        DocuSignFlag__c=true,
                                        genesis__Status__c = 'agent_verified',
                                        genesis__Draw_Period_End_Date__c = system.Today()
                                        );
        insert appTest;
        System.assertEquals(null,appTest.Borrower_s_Email__c,'Borrower Email is not null');
       
    }

    Testmethod static void method1(){
        
        Account acc =[Select id, name from Account where name='TestFName TestLName' limit 1];
        genesis__Applications__c app=[select id,genesis__Account__c from genesis__Applications__c where genesis__Account__c=:acc.id Limit 1];
      
        String jsonStr = '{"offers":[{"type1":"1","term_months":3,"amount":"1200","Is_Offer_Selected":true,"monthly_payment":"1100","origination_fee_rate":"2","interest_rate":"3","apr":"10.30%","above_prime_max":"3","segment":"2","pricing_tier":"3","origination_fee":"150","key":"Test","ebp_offer_code":"2021Feb_ebp_DCP_optout","ebp_parent_offer_key":""}],"applicationId":app.id}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/offers';
        req.requestBody = Blob.valueOf(jsonStr);
        req.httpMethod = 'POST';
                
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        WSGetPricingOffer.Response response = WSGetPricingOffer.parse();
        System.assertEquals(PayoffConstants.NO_ERROR, response.errorCode, 'No error');
        Test.stopTest();
    }
    
    Testmethod static void method2(){
        
        Account acc =[Select id, name from Account where name='TestFName TestLName' limit 1];
        genesis__Applications__c app=[select id,genesis__Account__c from genesis__Applications__c where genesis__Account__c=:acc.id Limit 1];
        
        Map<String,String> reqMap = new Map<String,String>(); 
        reqMap.put('applicationId',app.id);
        String jsonStr= JSON.serialize(reqMap);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/offers';
        req.requestBody = Blob.valueOf(jsonStr);
        req.httpMethod = 'POST';
                
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        WSGetPricingOffer.Response response = WSGetPricingOffer.parse();
        System.assertEquals(PayoffConstants.NO_ERROR, response.errorCode, 'No error');
        Test.stopTest();
    }
    
    Testmethod static void method3(){
        
        Account acc =[Select id, name from Account where name='TestFName TestLName' limit 1];
        genesis__Applications__c app=[select id,genesis__Account__c from genesis__Applications__c where genesis__Account__c=:acc.id Limit 1];
        
        String jsonStr = '{"Test":"abc"}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/offers';
        req.requestBody = Blob.valueOf(jsonStr);
        req.httpMethod = 'POST';
                
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        WSGetPricingOffer.Response response = WSGetPricingOffer.parse();
        System.assertEquals(PayoffConstants.NO_ERROR, response.errorCode, 'No error');
        Test.stopTest();
    }
    
    Testmethod static void method4(){
        
        Account acc =[Select id, name from Account where name='TestFName TestLName' limit 1];
        genesis__Applications__c app=[select id,genesis__Account__c from genesis__Applications__c where genesis__Account__c=:acc.id Limit 1];
      
        String jsonStr = '{"offers":[{"Is_Offer_Selected":true,"above_prime_max":"3","segment":"2","pricing_tier":"3","origination_fee":"150","key":"Test","ebp_offer_code":"2021Feb_ebp_DCP_optout","ebp_parent_offer_key":""}],"applicationId":app.id}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/offers';
        req.requestBody = Blob.valueOf(jsonStr);
        req.httpMethod = 'POST';
                
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        WSGetPricingOffer.Response response = WSGetPricingOffer.parse();
        System.assertEquals(PayoffConstants.NO_ERROR, response.errorCode, 'No error');
        Test.stopTest();
    }

    @isTest static void testPricingOfferWithScore(){
        Account acc = [Select id, name from Account where name='TestFName TestLName' limit 1];
        genesis__Applications__c app = [select id,genesis__Account__c from genesis__Applications__c where genesis__Account__c=:acc.id Limit 1];
      
        String jsonStr = '{"offers":[{"Is_Offer_Selected":true,"above_prime_max":"3","segment":"2","pricing_tier":"3","origination_fee":"150","key":"Test","ebp_offer_code":"2021Feb_ebp_DCP_optout","ebp_parent_offer_key":"","score":"780"}],"applicationId":app.id}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/offers';
        req.requestBody = Blob.valueOf(jsonStr);
        req.httpMethod = 'POST';
                
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        WSGetPricingOffer.Response response = WSGetPricingOffer.parse();
        System.assertEquals(PayoffConstants.NO_ERROR, response.errorCode, 'No error');
        Test.stopTest();
    }

    @isTest static void testNewExternalOfferId() {
        Account acc = [Select id, name from Account where name='TestFName TestLName' limit 1];
        genesis__Applications__c app = [select id,genesis__Account__c from genesis__Applications__c where genesis__Account__c=:acc.id Limit 1];
      
        String jsonStr =  '{"applicationId":"'+ app.id+'","offers":[{"external_offer_id": "5a17de3f-3ee1-4161-b5d8-4ebbcf840b8f","Is_Offer_Selected":true,"above_prime_max":"3","segment":"2","pricing_tier":"3","origination_fee":"150","key":"1","ebp_offer_code":"2021Feb_ebp_DCP_optout","ebp_parent_offer_key":"","score":"780"}]}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/offers';
        req.requestBody = Blob.valueOf(jsonStr);
        req.httpMethod = 'POST';
                
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        WSGetPricingOffer.Response response = WSGetPricingOffer.parse();
        Test.stopTest();

        System.assertEquals(PayoffConstants.NO_ERROR, response.errorCode, 'No error');

        Pricing_Offer__c pOffer = [Select external_offer_id__c from Pricing_Offer__c where Application__c =:app.Id limit 1];

        System.assertEquals('5a17de3f-3ee1-4161-b5d8-4ebbcf840b8f', pOffer.external_offer_id__c, 'external offer id should be inserted');

    }
}