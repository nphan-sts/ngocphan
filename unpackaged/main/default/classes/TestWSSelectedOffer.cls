@IsTest

private class TestWSSelectedOffer{
    @TestSetup
    static void setupData() {

        MW_Settings__c mwSettings = new MW_Settings__c();
        mwSettings.Allocation_Engine_Deployment_Mode__c = 'DARK_MODE';
        mwSettings.Allocation_Engine_Service_URL_FMT__c = 'http://localhost:8080/{0}';
        mwSettings.Allocation_Engine_Cancel_Statuses__c = 'Declined,Expired,Withdrawn,Decline_Manual_Review,Expired-Withdrawn';
        mwSettings.LEADS_FE_EndpointURL__c = 'https://sfapi-dev.payoff.com/ms/api/cls/update_user';
        insert mwSettings;

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
        
        Pricing_Offer__c pOfferOut = [SELECT Id,Key__c,Is_Offer_Selected__c FROM Pricing_Offer__c WHERE Key__c =: pOffer.Key__c];
        system.assertEquals(true, pOfferOut.Is_Offer_Selected__c);
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

        Pricing_Offer__c pOffer = [SELECT id,Key__c FROM Pricing_Offer__c WHERE Key__c=6 LIMIT 1];
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
        WSSelectedOffer.Response responseRec;
        
        Test.startTest();
        responseRec = WSSelectedOffer.markTentativeOfferSelected();
        Test.stopTest();
        system.assertEquals(PayoffConstants.APP_ID_CANNOT_BE_NULL, responseRec.errorMessage);
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

        Pricing_Offer__c pOffer = [SELECT id,Key__c,Is_Offer_Selected__c FROM Pricing_Offer__c WHERE Key__c=6 LIMIT 1];
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
        system.assertEquals(PayoffConstants.APP_ID_INCORRECT_FORMAT, responseRec.errorMessage);
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

    /**
     * Confirm that WSSelectedOffer will not fire the first request at ADVP
     * if the app is a redecision app with an incoming pricing tier difference
     */
    @IsTest static void testAdvpFlagNotSetOnNewApplication() {

        Account account = getAccount();
        genesis__Applications__c app = getApplication();
        Pricing_Offer__c offer = getOffer();

        app.genesis__Status__c = 'offer_shown';
        app.Required_Docs_Count__c = 2;
        update app;

        RestContext.request = makeRestRequest(app, offer);
        RestContext.response = new RestResponse();

        Test.startTest();
        WSSelectedOffer.markTentativeOfferSelected();
        Test.stopTest();

        genesis__Applications__c actualApp = getApplication(account);
        System.assertEquals('offer_accepted', actualApp.genesis__Status__c);

        Pricing_Offer__c actual = getOffer();
        System.assertEquals(true, actual.Is_Offer_Selected__c);
        System.assertEquals(false, InvestorAllocation.allocationForADVPcalled);
    }

    /**
     * Pricing tier change will trigger second (correct) allocation engine request
     */
    @IsTest static void testAdvpFlagSetOnRedecisionedAppWithPricingTierChange() {

        Account account = getAccount();
        genesis__Applications__c app = getApplication(account);
        Pricing_Offer__c offer = getOffer();

        app.genesis__Status__c = 'Redecision_Required';
        app.Required_Docs_Count__c = 0;
        app.Pricing_Tier__c = 't1';
        update app;

        offer.Pricing_Tier__c = 't2';
        update offer;

        RestContext.request = makeRestRequest(app, offer);
        RestContext.response = new RestResponse();

        Test.startTest();
        WSSelectedOffer.markTentativeOfferSelected();
        Test.stopTest();

        genesis__Applications__c actualApp = getApplication(account);
        System.assertEquals('agent_document_verification_pending', actualApp.genesis__Status__c);

        Pricing_Offer__c actual = getOffer();
        System.assertEquals(true, actual.Is_Offer_Selected__c);
        System.assertEquals(true, InvestorAllocation.allocationForADVPcalled);
    }

    /**
     * @param app The application instance
     * @param offer The offer instance
     *
     * @return A test rest request
     */
    private static RestRequest makeRestRequest(genesis__Applications__c app, Pricing_Offer__c offer) {
        Map<String, String> reqMap = new Map<String, String>();
        reqMap.put('applicationId', app.Id);
        reqMap.put('Key', String.valueOf(offer.Key__c));
        String jsonStr = JSON.serialize(reqMap);

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/selectedoffer';
        req.requestBody = Blob.valueOf(jsonStr);
        req.httpMethod = 'POST';
        return req;
    }

    private static Account getAccount() {
        List<Account> accounts = [
                SELECT Id,
                       Name
                FROM   Account
                WHERE  Name = 'WSSelectedOfferFirstName TestLastName'
                LIMIT  1
        ];
        return accounts.get(0);
    }

    private static genesis__Applications__c getApplication() {
        return getApplication(getAccount());
    }

    private static genesis__Applications__c getApplication(Account acc) {
        List<genesis__Applications__c> apps = [
                SELECT Id,
                       Required_Docs_Count__c,
                       genesis__Account__c,
                       genesis__Status__c
                FROM   genesis__Applications__c
                WHERE  genesis__Account__c = :acc.Id
                LIMIT 1
        ];
        return apps.get(0);
    }

    private static Pricing_Offer__c getOffer() {
        List<Pricing_Offer__c> offers = [
                SELECT Id,
                       Key__c,
                       Pricing_Tier__c,
                       Is_Offer_Selected__c
                FROM   Pricing_Offer__c
                WHERE  Key__c = 6
                LIMIT  1
        ];
        return offers.get(0);
    }
}