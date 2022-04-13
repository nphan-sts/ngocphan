/* ****************Modification History******************
*    Created By        	 Date			Version
*1. Bhavya Maliwal        2022/03/02     LSP-621 Initial Version,renamed method, modified code for validation errors

******************Modification History******************/
@isTest

private class TestCongaAutomation{
    //************Mock response class 
    public class WrapperSecurityTokenTest implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) { 
                 
            String body = '{"access_token":"null", "instance_url":"null"}';
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
  /*Created By : Bhavya Maliwal
Method name : congaAutomationTest
Purpose : to cover code satisfying CongaAutomation
*/    
    Testmethod static void congaAutomationTest(){
        
         //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
             peer__Last_Name__c='TestLName2',
            cnotify__Email__c = 'abc4@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123123109'
            );
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
        //Creating Application
        genesis__Applications__c app= new genesis__Applications__c(
                                            genesis__Due_Day__c = 25,
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
        System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');
        
        Test.setMock(HttpCalloutMock.class, new WrapperSecurityTokenTest());
        
        test.startTest();
        WrapperSecurityToken wsToken = new WrapperSecurityToken();
        wsToken.instance_url='testurl';
        CongaAutomation.CongaBackgroundMode(app.id);
        test.stopTest();
    }
    
}