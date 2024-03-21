@isTest
global class MW_NeoVerifyIntegrationHttpCalloutMock implements HttpCalloutMock {

    private Integer  m_responseCode;
    private String   m_reponses;
    
    public MW_NeoVerifyIntegrationHttpCalloutMock(String reponses, Integer responseCode){
        m_reponses = reponses;
        m_responseCode = responseCode;
    }

    global HTTPResponse respond(HTTPRequest req) 
    { 
        // String xmlString ='{ "report_id": "SL2Mq6jtrCuirj7OiiS5FcM85","url": "https://payofftest.neoverify.com/income_verification/SL2Mq6jtrCuirj7OiiS5FcM85"}';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(m_reponses);
        res.setStatusCode(m_responseCode);
        return res;
    }


   /* @isTest static void testCallout() {
    
        List<String> alist = new List<String>();

        for(genesis__Applications__c app:[select Id from genesis__Applications__c limit 99]){
            alist.add(app.id);
        }

        Test.setMock(HttpCalloutMock.class, new MW_NeoVerifyIntegrationHttpCalloutMock());
        MW_NeoVerifyIntegration.postNeoVerify(alist);
    }*/
}