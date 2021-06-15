@isTest
public class AdverseScorectrlTest{    
    public class TestAdverseScoreIntegrationMockInner implements HttpCalloutMock{

        public HTTPResponse respond(HTTPRequest req) { 
             
        String json = '{"credit_policy_decisions":[{"no_hit":false,"decision_codes":{"score_factor_text":[{"rank":1,"description":"dummy","code":"1.5"}],"adverse_actions":[{"reason":"ABC","name":"Test","description":"xyz"}]},"data":{"no_hit":false,"decision_codes":{"score_factor_text":[{"rank":1,"description":"dummy","code":"1.5"}],"adverse_actions":[{"reason":"ABC","name":"Test","description":"xyz"}]}}},{"no_hit":false,"decision_codes":{"score_factor_text":[{"rank":1,"description":"dummy","code":"1.5"}],"adverse_actions":[{"reason":"ABC","name":"Test","description":"xyz"}]},"data":{"no_hit":false,"decision_codes":{"score_factor_text":[{"rank":1,"description":"dummy","code":"1.5"}],"adverse_actions":[{"reason":"ABC","name":"Test","description":"xyz"}]}}}]}';
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setBody(json);
        res.setStatusCode(320);
        return res;
    }
}
      Testmethod static void AdversefuturemethodTest_UseCase1(){
         
        Account account_Obj = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com'
        );
        Insert account_Obj;
        
        Account acc = [select Id, Annual_Individual_Income__c from Account  where Name = 'Test' LIMIT 1];
        System.assertEquals(true, acc!=Null);
        
        genesis__Applications__c genesis_applications_Obj = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Account__c = acc.Id,        
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'Default Documents',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c = 'Full Time'
        );      
        Insert genesis_applications_Obj; 
        
        
        genesis__Applications__c app = [SELECT Id, Employment_Status__c from genesis__Applications__c WHERE genesis__Account__c =: acc.Id LIMIT 1];
        System.assertEquals(true, app!=Null);
        Test.setMock(HttpCalloutMock.class, new TestAdverseScoreIntegrationMock());
        test.startTest();
        AdverseScorectrl advScore = new AdverseScorectrl(true);
        AdverseScorectrl.Adversefuturemethod(app.Id);
        test.stopTest();
      }
      
      Testmethod static void AdversefuturemethodTest_UseCase2(){
         
        Account account_Obj = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com'
        );
        Insert account_Obj;
        
        Account acc = [select Id, Annual_Individual_Income__c from Account  where Name = 'Test' LIMIT 1];
        System.assertEquals(true, acc!=Null);
        
        genesis__Applications__c genesis_applications_Obj = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Account__c = acc.Id,        
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'Default Documents',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c = 'Full Time'
        );      
        Insert genesis_applications_Obj; 
        
        genesis__Applications__c app = [SELECT Id, Employment_Status__c from genesis__Applications__c WHERE genesis__Account__c =: acc.Id LIMIT 1];
        System.assertEquals(true, app!=Null);
        Test.setMock(HttpCalloutMock.class, new TestAdverseScoreIntegrationMockInner());
        test.startTest();
        AdverseScorectrl advScore = new AdverseScorectrl(true);
        AdverseScorectrl.Adversefuturemethod(app.Id);
        test.stopTest();
      }
}