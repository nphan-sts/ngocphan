/* ****************Modification History******************
*    Created By        	 Date			Version
*1. Bhavya Maliwal        2022/03/08     LSP-639 Initial Version,set up method,mock method, code modification as per validations

******************Modification History******************/
@isTest
public class AdverseScorectrlTest{  
    @testSetup
    static void setup(){
        Account account_Obj = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            peer__Last_Name__c='TestLName2',
            cnotify__Email__c = 'no-reply@testorganization.com'
        );
        Insert account_Obj;
        
        genesis__Applications__c genesis_applications_Obj = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Account__c = account_Obj.Id,        
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'Default Documents',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c = 'Full Time'
        );      
        Insert genesis_applications_Obj; 
        
        Adverse_Actions__c adv=new Adverse_Actions__c();
        adv.Application__c=genesis_applications_Obj.id;
        adv.Account__c=account_Obj.id;
        insert adv;
        
        Score_Factors__c sf=new Score_Factors__c();
        sf.Account__c=account_Obj.id;
        sf.Application__c=genesis_applications_Obj.id;
        insert sf;
        
        Adverse__c ad=new Adverse__c();
        ad.Account__c=account_Obj.id;
        ad.Application__c=genesis_applications_Obj.id;
        insert ad;
        
    }
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
    public class TestAdverseScoreIntegrationMock1 implements HttpCalloutMock{
        
        public HTTPResponse respond(HTTPRequest req) { 
            
            String json = '{"credit_policy_decisions":[{"no_hit":false,"decision_codes":{"score_factor_text":[{"rank":1,"description":"dummy","code":"1.5"}],"adverse_actions":[{"reason":"ABC","name":"Test","description":"xyz"}]},"data":{"no_hit":false,"decision_codes":{"score_factor_text":[{"rank":1,"description":"dummy","code":"1.5"}],"adverse_actions":[{"reason":"ABC","name":"Test","description":"xyz"}]}}},{"no_hit":false,"decision_codes":{"score_factor_text":[{"rank":1,"description":"dummy","code":"1.5"}],"adverse_actions":[{"reason":"ABC","name":"Test","description":"xyz"}]},"data":{"no_hit":false,"decision_codes":{"score_factor_text":[{"rank":1,"description":"dummy","code":"1.5"}],"adverse_actions":[{"reason":"ABC","name":"Test","description":"xyz"}]}}}]}';
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody(json);
            res.setStatusCode(200);
            return res;
        }
    }
    Testmethod static void adversefuturemethodTestUseCase1(){
        genesis__Applications__c app = [SELECT Id, Employment_Status__c from genesis__Applications__c LIMIT 1];
        System.assertEquals(true, app!=Null);
        Test.setMock(HttpCalloutMock.class, new TestAdverseScoreIntegrationMock1());
        test.startTest();
        AdverseScorectrl advScore = new AdverseScorectrl(true);
        AdverseScorectrl.Adversefuturemethod(app.Id);
        test.stopTest();
    }
    
    Testmethod static void adversefuturemethodTestUseCase2(){
        genesis__Applications__c app = [SELECT Id, Employment_Status__c from genesis__Applications__c LIMIT 1];
        System.assertEquals(true, app!=Null);
        Test.setMock(HttpCalloutMock.class, new TestAdverseScoreIntegrationMockInner());
        test.startTest();
        AdverseScorectrl.Adversefuturemethod(app.Id);
        test.stopTest();
    }
}