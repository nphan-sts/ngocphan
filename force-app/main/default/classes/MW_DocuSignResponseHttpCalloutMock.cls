@isTest
global class MW_DocuSignResponseHttpCalloutMock implements HttpCalloutMock {

        global HTTPResponse respond(HTTPRequest req) 
        { 
            StaticResource sr = [select Body from StaticResource where Name='DocuSignResponse' limit 1];
            String xmlString = sr.Body.toString();
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(xmlString);
            res.setStatusCode(200);
            return res;
        }
}