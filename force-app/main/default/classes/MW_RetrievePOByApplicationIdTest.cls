@isTest
//MW_RetrievePricingOfferByApplicationIdTest
public with sharing class MW_RetrievePOByApplicationIdTest {
    //test get Pricing offer endpoint
    static testMethod void MW_RetrievePOByApplicationIdTestWithInvalidDate() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addParameter('invalid-param', 'test-id');
        req.requestURI = '/services/apexrest/pricing-offer/application-id/?invalid-param=test-id';    
        req.httpMethod = 'GET'; 
        RestContext.request = req;  
        RestContext.response= res;  
        Test.startTest();
        MW_RetrievePricingOfferByApplicationId.MW_RetrievePricingOfferByApplicationId();
        Test.stopTest();
        
        system.assertNotEquals(null, res.responseBody, 'response is not null');
    }

    //test get application document category endpoint
    static testMethod void MW_RetrievePOByApplicationIdTestWithValidDate() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addParameter('application-id', 'test-id');
        req.requestURI = '/services/apexrest/pricing-offer/application-id/?application-id=test-guid';

        req.httpMethod = 'GET'; 
        RestContext.request = req;  
        RestContext.response= res;  
        Test.startTest();
        MW_RetrievePricingOfferByApplicationId.MW_RetrievePricingOfferByApplicationId();
        Test.stopTest(); 
        
        
        
        system.assertNotEquals(null, res.responseBody, 'response is not null');
    }
}
