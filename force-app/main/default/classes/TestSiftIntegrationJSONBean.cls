@isTest

Public class TestSiftIntegrationJSONBean{
 
    Testmethod static void method1(){
       // String jsonResponse = '{ "status": "0", "error_message": "OK", "score": "0.41122398700382345", "reasons": [ { "name": "abc", "value": "8193" } ], "user_id": "e05a78bb-0344-4cbd-b76a-4b9525736abe", "actions": [ { "id": "ec158386c487a467180abc6800d3cd757ffffea1f4df741b:558c8061e4b0e75151f01f4f", "action": { "": {} } } ], "id": "ec158386c487a467180abc6800d3cd757ffffea1f4df741b:558c8061e4b0e75151f01f4f", "action": { "id": "558c8061e4b0e75151f01f4f" }, "entity": { "id": "e05a78bb-0344-4cbd-b76a-4b9525736abe" }, "score_response": { "score": "123", "status": "0" } }';
            
        
        Test.StartTest();
        //SiftIntegrationJSONBean resData  = (SiftIntegrationJSONBean)JSON.deserialize(jsonResponse, SiftIntegrationJSONBean.class);
        //SiftIntegrationJSONBean.parse(jsonResponse);
        SiftIntegrationJSONBean.score_response obj2 = new SiftIntegrationJSONBean.score_response();
        
        obj2.score = 100;
        obj2.status = 1;
        Test.stopTest();
    }
        
}