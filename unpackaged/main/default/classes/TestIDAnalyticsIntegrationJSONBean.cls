/* ****************Modification History******************
 * Last Modified by        Date          JIRA number
 *      1. Shakul         2022/03/29     LSP-611 (Added asserts to test dummy response)
 ******************Modification History******************/
@isTest

public class TestIDAnalyticsIntegrationJSONBean{
    
    public static testmethod void assertDummyResponse(){
        String jsonResponse = '{ "status": "abc", "result": { "id_score": "123", "snapd": "abc", "id_score_cat": "xyz", "snapd_cat": "xyz", "sift_attributes": { "id_consistency_snapd_cat": "abc", "id_consistency_snapd_int": "abc", "id_idscore_cat": "abc", "id_idscore_int": "abc" }, "raw_response_xml": "abcde" } }';
        
        
        Test.StartTest();
        IDAnalyticsIntegrationJSONBean testResp = IDAnalyticsIntegrationJSONBean.parse(jsonResponse);
        Test.stopTest();
        System.assertEquals('abc', testResp.status);
        System.assertEquals(true, testResp.result != null);
    }
}