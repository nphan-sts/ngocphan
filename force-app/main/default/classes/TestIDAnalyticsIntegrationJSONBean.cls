@isTest

Public class TestIDAnalyticsIntegrationJSONBean{
 
    Testmethod static void method1(){
        String jsonResponse = '{ "status": "abc", "result": { "id_score": "123", "snapd": "abc", "id_score_cat": "xyz", "snapd_cat": "xyz", "sift_attributes": { "id_consistency_snapd_cat": "abc", "id_consistency_snapd_int": "abc", "id_idscore_cat": "abc", "id_idscore_int": "abc" }, "raw_response_xml": "abcde" } }';
            
        
        Test.StartTest();
       // IDAnalyticsIntegrationJSONBean resData  = (IDAnalyticsIntegrationJSONBean)JSON.deserialize(jsonResponse, IDAnalyticsIntegrationJSONBean.class);
        IDAnalyticsIntegrationJSONBean.parse(jsonResponse);
        Test.stopTest();
    }
        
}