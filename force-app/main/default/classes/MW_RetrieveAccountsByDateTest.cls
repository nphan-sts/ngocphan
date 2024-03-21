@isTest 
private class MW_RetrieveAccountsByDateTest {
    //test get account endpoint
    static testMethod void MW_RetrieveAccountsByDateTestWithInvalidDate() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addParameter('invalid-param', '2019-10-28');
        req.requestURI = '/services/apexrest/application/date/?invalid-param=2019-10-28';    
        req.httpMethod = 'GET'; 
        RestContext.request = req;  
        RestContext.response= res;  
        Test.startTest();
        MW_RetrieveAccountsByDate.MW_RetrieveAccountsByDate();
        Test.stopTest();
        
        system.assertNotEquals(null, res.responseBody, 'response is not null');
    }

    //test get account endpoint
    static testMethod void MW_RetrieveAccountsByDateTestWithValidDate() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addParameter('origination-date', '2019-10-28');
        req.requestURI = '/services/apexrest/application/date/?origination-date=2019-10-28';

        req.httpMethod = 'GET'; 
        RestContext.request = req;  
        RestContext.response= res;  
        Test.startTest();
        MW_RetrieveAccountsByDate.MW_RetrieveAccountsByDate();
        Test.stopTest(); 
        
        
        
        system.assertNotEquals(null, res.responseBody, 'response is not null');
    }
}