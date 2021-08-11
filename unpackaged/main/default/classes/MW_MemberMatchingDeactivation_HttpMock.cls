@isTest
global class MW_MemberMatchingDeactivation_HttpMock implements HttpCalloutMock{
    global HttpResponse respond(HTTPRequest req){
        //Create Fake Responce
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        //add a sample json responce here
        String body = '{ "status": "success", "result": { "result": [ { "deactivated_member_id": 120496722, "deactivated_lead_id": 1780162, "deactivated_lead_guid": "1274debd-630c-e66c-861b-e125953db49d" }, { "deactivated_member_id": 120496723, "deactivated_lead_id": 1780163, "deactivated_lead_guid": "34c0e99f-d568-4397-1911-e77952a35af9" } ] } }';
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
}