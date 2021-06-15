@isTest

private class TestWSSelectedOffer{
    @testSetup static void methodName() {
        //Creating Account
        Account accTest = new Account(
                                Name = 'Test',
                                loan__Investor__c=False,
                                cnotify__Email__c = 'abc@test.com',
                                loan__SOCIAL_SECURITY_NUMBER__c = '123'
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
        
        Pricing_Offer__c  pOffer = new Pricing_Offer__c();
        pOffer.Above_prime_max__c= 'false';
        pOffer.Amount__c = 8000;
        pOffer.Application__c =appTest.id;
        pOffer.APR__c = 11.997986061655;
        pOffer.Interest_Rate__c =9.97;
        pOffer.Is_Offer_Selected__c = false;
        pOffer.Key__c = 6;
        pOffer.Monthly_Payment__c = 215.489647581694;
        pOffer.Origination_fee__c = 160;
        pOffer.Origination_fee_rate__c = 2;
        pOffer.Pricing_Tier__c = 't2';
        pOffer.Segment__c = 'prime';
        pOffer.Term__c = 24;
        pOffer.Type__c = 'ABC';
        insert pOffer;
        System.assertEquals('ABC',pOffer.Type__c,'Wrong Pricing Offer Type');
    }

    Testmethod static void method1(){
        
        Account acc =[Select id, name from Account where name='Test' limit 1];
        genesis__Applications__c app=[select id,genesis__Account__c from genesis__Applications__c where genesis__Account__c=:acc.id Limit 1];
        Pricing_Offer__c pOffer = [Select id,Key__c from Pricing_Offer__c where Key__c=6 Limit 1];
        
        Map<String,String> reqMap = new Map<String,String>(); 
        reqMap.put('applicationId',app.id);
        reqMap.put('Key',String.ValueOf(pOffer.Key__c));
        String jsonStr= JSON.serialize(reqMap);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/selectedoffer';
        req.requestBody = Blob.valueOf(jsonStr);
        req.httpMethod = 'POST';
                
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        WSSelectedOffer.markTentativeOfferSelected();
        Test.stopTest();
    }
    
    Testmethod static void method11(){
        
        Account acc =[Select id, name from Account where name='Test' limit 1];
        genesis__Applications__c app=[select id,genesis__Account__c from genesis__Applications__c where genesis__Account__c=:acc.id Limit 1];
        //Pricing_Offer__c pOffer = [Select id,Key__c,Is_Offer_Selected__c from Pricing_Offer__c where Key__c=6 Limit 1];
         Pricing_Offer__c  pOffer = new Pricing_Offer__c();
        pOffer.Above_prime_max__c= 'false';
        pOffer.Amount__c = 8000;
        pOffer.Application__c =app.id;
        pOffer.APR__c = 11.997986061655;
        pOffer.Interest_Rate__c =9.97;
        pOffer.Is_Offer_Selected__c = false;
        pOffer.Key__c = 6;
        pOffer.Monthly_Payment__c = 215.489647581694;
        pOffer.Origination_fee__c = 160;
        pOffer.Origination_fee_rate__c = 2;
        pOffer.Pricing_Tier__c = 't2';
        pOffer.Segment__c = 'prime';
        pOffer.Term__c = 24;
        pOffer.Type__c = 'ABC';
        pOffer.Is_Offer_Selected__c = true;
        insert pOffer;
       
        Map<String,String> reqMap = new Map<String,String>(); 
        reqMap.put('applicationId',app.id);
        reqMap.put('Key','7');
        String jsonStr= JSON.serialize(reqMap);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/selectedoffer';
        req.requestBody = Blob.valueOf(jsonStr);
        req.httpMethod = 'POST';
                
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        WSSelectedOffer.markTentativeOfferSelected();
        Test.stopTest();
    }
    
    //Application ID null
    Testmethod static void method2(){
        
        Account acc =[Select id, name from Account where name='Test' limit 1];
        genesis__Applications__c app=[select id,genesis__Account__c from genesis__Applications__c where genesis__Account__c=:acc.id Limit 1];
        Pricing_Offer__c pOffer = [Select id,Key__c from Pricing_Offer__c where Key__c=6 Limit 1];
        Map<String,String> reqMap = new Map<String,String>(); 
        reqMap.put('applicationId',null);
        reqMap.put('Key',String.ValueOf(pOffer.Key__c));
        String jsonStr= JSON.serialize(reqMap);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/selectedoffer';
        req.requestBody = Blob.valueOf(jsonStr);
        req.httpMethod = 'POST';
                
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        WSSelectedOffer.markTentativeOfferSelected();
        Test.stopTest();
    }
    //Key null
    Testmethod static void method3(){
        
        Account acc =[Select id, name from Account where name='Test' limit 1];
        genesis__Applications__c app=[select id,genesis__Account__c from genesis__Applications__c where genesis__Account__c=:acc.id Limit 1];
        Pricing_Offer__c pOffer = [Select id,Key__c,Is_Offer_Selected__c from Pricing_Offer__c where Key__c=6 Limit 1];
        pOffer.Is_Offer_Selected__c = true;
        update pOffer;
        
        Map<String,String> reqMap = new Map<String,String>(); 
        reqMap.put('applicationId',app.id);
        reqMap.put('Key',null);
        String jsonStr= JSON.serialize(reqMap);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/selectedoffer';
        req.requestBody = Blob.valueOf(jsonStr);
        req.httpMethod = 'POST';
                
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        WSSelectedOffer.markTentativeOfferSelected();
        Test.stopTest();
    }
    //Offer Selected True and Key is same as Pricing offer Key
    Testmethod static void method4(){
        
        Account acc =[Select id, name from Account where name='Test' limit 1];
        genesis__Applications__c app=[select id,genesis__Account__c from genesis__Applications__c where genesis__Account__c=:acc.id Limit 1];
        Pricing_Offer__c pOffer = [Select id,Key__c,Is_Offer_Selected__c from Pricing_Offer__c where Key__c=6 Limit 1];
        pOffer.Is_Offer_Selected__c = true;
        update pOffer;
        
        Map<String,String> reqMap = new Map<String,String>(); 
        reqMap.put('applicationId',app.id);
        reqMap.put('Key',String.ValueOf(pOffer.Key__c));
        String jsonStr= JSON.serialize(reqMap);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/selectedoffer';
        req.requestBody = Blob.valueOf(jsonStr);
        req.httpMethod = 'POST';
                
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        WSSelectedOffer.markTentativeOfferSelected();
        Test.stopTest();
    }
    //Offer Selected True and Key is not same as Pricing offer Key
    Testmethod static void method5(){
        
        Account acc =[Select id, name from Account where name='Test' limit 1];
        genesis__Applications__c app=[select id,genesis__Account__c from genesis__Applications__c where genesis__Account__c=:acc.id Limit 1];
        Pricing_Offer__c pOffer = [Select id,Key__c,Is_Offer_Selected__c from Pricing_Offer__c where Key__c=6 Limit 1];
        pOffer.Is_Offer_Selected__c = true;
        update pOffer;
        
        Map<String,String> reqMap = new Map<String,String>(); 
        reqMap.put('applicationId',app.id);
        reqMap.put('Key','8');
        String jsonStr= JSON.serialize(reqMap);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/selectedoffer';
        req.requestBody = Blob.valueOf(jsonStr);
        req.httpMethod = 'POST';
                
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        WSSelectedOffer.markTentativeOfferSelected();
        Test.stopTest();
    }
}