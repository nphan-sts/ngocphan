@isTest
public class TestDCPIntegration {
    
    @isTest
    static void TestDCPIntegration_usecase(){
        
        DCP_Arcus__c dcpParameters = new DCP_Arcus__c();
        dcpParameters.secret_key__c = 'ltJj93aM0bn5R/ItWqJy75bBtF/VeeVsWlcGIoyg0yutj45cXIc83QEbprJye+PsEF07iW2KND8q4YBJnHlmXQ==';
        dcpParameters.Endpoint__c = 'https://apix.staging.arcusapi.com/';
        dcpParameters.API_Key__c = '0683f8c05b4540f7f0ac0ca8a0046445';
        insert dcpParameters;
        
        Test.setMock(HttpCalloutMock.class, new TestDCPHttpCalloutMock());
        test.starttest();
        httpResponse response = DCPIntegration.patchTransactions('123456789');
        test.stoptest();
        
        String contentType = response.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = response.getBody();
        System.assertEquals(200, response.getStatusCode());
        
    }
     @isTest
    static void TestDCPIntegration_getAccts(){
        	DCP_Arcus__c dcpParameters = new DCP_Arcus__c();
            dcpParameters.secret_key__c = 'ltJj93aM0bn5R/ItWqJy75bBtF/VeeVsWlcGIoyg0yutj45cXIc83QEbprJye+PsEF07iW2KND8q4YBJnHlmXQ==';
            dcpParameters.Endpoint__c = 'https://apix.staging.arcusapi.com/';
            dcpParameters.API_Key__c = '0683f8c05b4540f7f0ac0ca8a0046445';
            insert dcpParameters;
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('DCPGetAccounts');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
        	test.startTest();
            	httpResponse result = DCPIntegration.getAccounts();
        	test.stopTest();
    }
}