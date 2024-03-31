@isTest

global class TestAdverseScoreIntegrationMock implements HttpCalloutMock{

        global HTTPResponse respond(HTTPRequest req) { 
                 
            String json = '{"credit_policy_decisions":[{"no_hit":false,"decision_codes":{"score_factor_text":[{"rank":1,"description":"dummy","code":"1.5"}],"adverse_actions":[{"reason":"ABC","name":"Test","description":"xyz"}]},"data":{"no_hit":false,"decision_codes":{"score_factor_text":[{"rank":1,"description":"dummy","code":"1.5"}],"adverse_actions":[{"reason":"ABC","name":"Test","description":"xyz"}]}}},{"no_hit":false,"decision_codes":{"score_factor_text":[{"rank":1,"description":"dummy","code":"1.5"}],"adverse_actions":[{"reason":"ABC","name":"Test","description":"xyz"}]},"data":{"no_hit":false,"decision_codes":{"score_factor_text":[{"rank":1,"description":"dummy","code":"1.5"}],"adverse_actions":[{"reason":"ABC","name":"Test","description":"xyz"}]}}}]}';
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody(json);
            res.setStatusCode(200);
            return res;
        }
    }