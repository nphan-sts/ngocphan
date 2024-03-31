@IsTest

private class TestWSSelectedOffer{
    @TestSetup
    static void setupData() {
        //Creating Account
        Account accTest = new Account(
                                Name = 'GetsOverwritten',
            					peer__First_Name__c = 'WSSelectedOfferFirstName',
                                loan__Investor__c=false,
                                cnotify__Email__c = 'abc1212@test.com',
                                loan__SOCIAL_SECURITY_NUMBER__c = '123123123',
                                peer__Last_Name__c = 'TestLastName'
                                );
        insert accTest;
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
    }

    testMethod static void testNewOfferIsSelectedWithKey(){
        
        Account acc =[SELECT id, name FROM Account WHERE name='WSSelectedOfferFirstName TestLastName' LIMIT 1];
        genesis__Applications__c app=[SELECT id,genesis__Account__c FROM genesis__Applications__c WHERE genesis__Account__c=:acc.id LIMIT 1];
        Pricing_Offer__c pOffer = [SELECT id,Key__c FROM Pricing_Offer__c WHERE Key__c=6 LIMIT 1];
        
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

        Pricing_Offer__c pOfferOut = [
                SELECT Id,
                        Amount__c,
                        APR__c,
                        Pricing_Tier__c,
                        Term__c,
                        Origination_fee__c,
                        Monthly_Payment__c,
                        Interest_Rate__c,
                        Key__c,
                        Is_Offer_Selected__c
                FROM Pricing_Offer__c
                WHERE Key__c = :pOffer.Key__c
        ];
        system.assertEquals(true, pOfferOut.Is_Offer_Selected__c);

        genesis__Applications__c actual = getApp(app.Id);

        System.assertEquals(actual.genesis__Loan_Amount__c, pOfferOut.Amount__c);
        System.assertEquals(actual.genesis__APR__c, pOfferOut.APR__c);
        System.assertEquals(actual.Pricing_Tier__c, pOfferOut.Pricing_Tier__c);
        System.assertEquals(actual.genesis__Term__c, pOfferOut.Term__c);
        System.assertEquals(actual.Origination_fee__c, pOfferOut.Origination_fee__c);
        System.assertEquals(actual.genesis__Monthly_Debt_Payments__c, pOfferOut.Monthly_Payment__c);
        System.assertEquals(actual.genesis__Interest_Rate__c, pOfferOut.Interest_Rate__c);
        System.assertEquals(actual.genesis__Financed_Amount__c, pOfferOut.Amount__c - pOfferOut.Origination_fee__c);
        System.assertEquals(actual.genesis__Status__c, 'offer_accepted');
    }

    private static genesis__Applications__c getApp(Id id) {
        return [SELECT Id,
                        genesis__Loan_Amount__c,
                        genesis__APR__c,
                        Pricing_Tier__c,
                        genesis__Term__c,
                        Origination_fee__c,
                        genesis__Monthly_Debt_Payments__c,
                        genesis__Interest_Rate__c,
                        genesis__Financed_Amount__c,
                        genesis__Status__c
                FROM genesis__Applications__c
                WHERE Id =: id
                LIMIT 1
        ];
    }

    // Check a Non EBP offer is already selected then return the message
    testMethod static void testNonEBPSelectedOfferAvailable(){
        
        Account acc =[SELECT id, name FROM Account WHERE name='WSSelectedOfferFirstName TestLastName' LIMIT 1];
        genesis__Applications__c app=[SELECT id,genesis__Account__c FROM genesis__Applications__c WHERE genesis__Account__c=:acc.id LIMIT 1];
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
        WSSelectedOffer.Response responseRec;
        
        Test.startTest();
        responseRec = WSSelectedOffer.markTentativeOfferSelected();
        Test.stopTest();
        
        system.assertEquals('One loan offer is already selected . Contact the support team for any queries', responseRec.errorMessage);
    }
    
    //Application ID null
    testMethod static void testAppIdNULLcheck(){

        Pricing_Offer__c pOffer = [SELECT Id,Key__c FROM Pricing_Offer__c WHERE Key__c=6 LIMIT 1];
        Map<String,String> reqMap = new Map<String,String>(); 
        reqMap.put('applicationId',null);
        reqMap.put('Key',String.valueOf(pOffer.Key__c));
        String jsonStr= JSON.serialize(reqMap);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/selectedoffer';
        req.requestBody = Blob.valueOf(jsonStr);
        req.httpMethod = 'POST';
                
        RestContext.request = req;
        RestContext.response = res;
        WSSelectedOffer.Response responseRec;
        
        Test.startTest();
        responseRec = WSSelectedOffer.markTentativeOfferSelected();
        Test.stopTest();
        System.assertEquals(PayoffConstants.APP_ID_CANNOT_BE_NULL, responseRec.errorMessage);
    }
    //Key null
    testMethod static void testKeyNULLcheck(){
        
        Account acc =[SELECT id, name FROM Account WHERE name='WSSelectedOfferFirstName TestLastName' LIMIT 1];
        genesis__Applications__c app=[SELECT id,genesis__Account__c FROM genesis__Applications__c WHERE genesis__Account__c=:acc.id LIMIT 1];
        Pricing_Offer__c pOffer = [SELECT id,Key__c,Is_Offer_Selected__c FROM Pricing_Offer__c WHERE Key__c=6 LIMIT 1];
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
        WSSelectedOffer.Response responseRec;
        
        Test.startTest();
        responseRec = WSSelectedOffer.markTentativeOfferSelected();
        Test.stopTest();
        system.assertEquals(PayoffConstants.KEY_CANNOT_BE_NULL, responseRec.errorMessage);
    }
    //App ID incorrect format
    testMethod static void testAppIDIncorrectFormat(){

        Pricing_Offer__c pOffer = [SELECT Id,Key__c,Is_Offer_Selected__c FROM Pricing_Offer__c WHERE Key__c=6 LIMIT 1];
        pOffer.Is_Offer_Selected__c = true;
        update pOffer;
        
        Map<String,String> reqMap = new Map<String,String>(); 
        reqMap.put('applicationId','***********');
        reqMap.put('Key','6');
        String jsonStr= JSON.serialize(reqMap);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/selectedoffer';
        req.requestBody = Blob.valueOf(jsonStr);
        req.httpMethod = 'POST';
                
        RestContext.request = req;
        RestContext.response = res;
        WSSelectedOffer.Response responseRec;
        
        Test.startTest();
        responseRec = WSSelectedOffer.markTentativeOfferSelected();
        Test.stopTest();
        System.assertEquals(PayoffConstants.APP_ID_INCORRECT_FORMAT, responseRec.errorMessage);
    }
	// Check old EBP offer is deselected and new one is a success
    testMethod static void testEBPOfferDeselected(){
        Account acc =[SELECT id, name FROM Account WHERE name='WSSelectedOfferFirstName TestLastName' LIMIT 1];
        genesis__Applications__c app=[SELECT id,genesis__Account__c FROM genesis__Applications__c WHERE genesis__Account__c=:acc.id LIMIT 1];
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
        pOffer.EBP_Offer_Code__c = '2021Feb_ebp_DCP_90';
        pOffer.EBP_Parent_Offer_Key__c = '';
        insert pOffer;
        Approved_Offer__c appOffer = new Approved_Offer__c( 
                                            Above_prime_max__c = 'false',
                                            Amount__c = 1200.00,
                                            Application__c=app.id,
                                            APR__c ='11.99',
                                            Interest_Rate__c = '9.97',
                                            Key__c = '6',
                                            Monthly_Payment__c = 200,
                                            Origination_fee__c = '150.00',
                                            Origination_fee_rate__c = '2.00',
                                            Pricing_Tier__c = 't2',
                                            Segment__c = 'prime',
                                            Term__c = 24,
                                            Type__c ='test',
                                            EBP_Offer_Code__c = '2021Feb_ebp_DCP_90',
                                            EBP_Parent_Offer_Key__c = ''    
                                            );
        insert appOffer;  
       
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
        WSSelectedOffer.Response responseRec;
        
        Test.startTest();
        responseRec = WSSelectedOffer.markTentativeOfferSelected();
        Test.stopTest();
        
        system.assertEquals(PayoffConstants.SUCCESS, responseRec.status);
        
    }
        
    //Offer Selected True and Key is same as Pricing offer Key
    testMethod static void testEBPOfferAlreadySelectedSameKey(){
        
        Account acc =[SELECT id, name FROM Account WHERE name='WSSelectedOfferFirstName TestLastName' LIMIT 1];
        genesis__Applications__c app=[SELECT id,genesis__Account__c FROM genesis__Applications__c WHERE genesis__Account__c=:acc.id LIMIT 1];
        Pricing_Offer__c pOffer = [SELECT id,Key__c,Is_Offer_Selected__c FROM Pricing_Offer__c WHERE Key__c=6 LIMIT 1];
        pOffer.Is_Offer_Selected__c = true;
        pOffer.EBP_Offer_Code__c = '2021Feb_ebp_DCP_90';
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
        WSSelectedOffer.Response responseRec;
        
        Test.startTest();
        responseRec = WSSelectedOffer.markTentativeOfferSelected();
        Test.stopTest();
        system.assertEquals(PayoffConstants.THIS_OFFER_IS_ALREADY_APPROVED, responseRec.successMessage);
    }
    //Offer Selected True and Key is not same as Pricing offer Key
    testMethod static void testEBPOfferAlreadySelectedDifferenteKey(){
        
        Account acc =[SELECT id, name FROM Account WHERE name='WSSelectedOfferFirstName TestLastName' LIMIT 1];
        genesis__Applications__c app=[SELECT id,genesis__Account__c FROM genesis__Applications__c WHERE genesis__Account__c=:acc.id LIMIT 1];
        Pricing_Offer__c pOffer = [SELECT id,Key__c,Is_Offer_Selected__c FROM Pricing_Offer__c WHERE Key__c=6 LIMIT 1];
        pOffer.Is_Offer_Selected__c = true;
        pOffer.EBP_Offer_Code__c = '2021Feb_ebp_DCP_90';
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
        WSSelectedOffer.Response responseRec;
        
        Test.startTest();
        responseRec = WSSelectedOffer.markTentativeOfferSelected();
        Test.stopTest();
        system.assertEquals(PayoffConstants.SUCCESS, responseRec.status);
    }
}