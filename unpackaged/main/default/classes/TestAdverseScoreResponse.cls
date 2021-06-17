@isTest

private class TestAdverseScoreResponse{
    Testmethod static void method1(){
            String json = '{"credit_policy_decisions":[{"no_hit":false,"decision_codes":{"score_factor_text":[{"rank":1,"description":"dummy","code":"1.5"}],"adverse_actions":[{"reason":"ABC","name":"Test","description":"xyz"}]},"data":{"no_hit":false,"decision_codes":{"score_factor_text":[{"rank":1,"description":"dummy","code":"1.5"}],"adverse_actions":[{"reason":"ABC","name":"Test","description":"xyz"}]}}},{"no_hit":false,"decision_codes":{"score_factor_text":[{"rank":1,"description":"dummy","code":"1.5"}],"adverse_actions":[{"reason":"ABC","name":"Test","description":"xyz"}]},"data":{"no_hit":false,"decision_codes":{"score_factor_text":[{"rank":1,"description":"dummy","code":"1.5"}],"adverse_actions":[{"reason":"ABC","name":"Test","description":"xyz"}]}}}]}';
         //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
        
        
        //Creating Application
        genesis__Applications__c app= new genesis__Applications__c(
                                            genesis__Due_Day__c = 20,
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
        
        
        Test.StartTest();
        AdverseScoreResponse obj = new AdverseScoreResponse();
        obj.parse(json,acc.id,app.id);
        System.assert(obj != null);
        Test.stopTest();
    }
}