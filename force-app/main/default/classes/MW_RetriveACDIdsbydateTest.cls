@isTest
public with sharing class MW_RetriveACDIdsbydateTest {
    static testMethod void MW_RetriveACDIdsbydateTestWithInvalidDate() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addParameter('invalid-param', '2019-10-28');
        req.requestURI = '/application-document-category/target-date/?invalid-param=2019-10-28';    
        req.httpMethod = 'GET'; 
        RestContext.request = req;  
        RestContext.response= res;  
        Test.startTest();
        MW_RetriveACDIdsbydate.MW_RetriveACDIdsbydate();
        Test.stopTest();
        
        system.assertNotEquals(null, res.responseBody, 'response is not null');
    }
    static testMethod void MW_RetriveACDIdsbydateTestWithValidDate() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addParameter('target-date', '2019-10-28');
        req.requestURI = '/application-document-category/target-date/?target-date=2019-10-28';

        req.httpMethod = 'GET'; 
        RestContext.request = req;  
        RestContext.response= res;  
        Test.startTest();
        MW_RetriveACDIdsbydate.MW_RetriveACDIdsbydate();
        Test.stopTest(); 
        
        system.assertNotEquals(null, res.responseBody, 'response is not null');

    }
}
