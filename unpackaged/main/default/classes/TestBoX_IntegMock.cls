/* ****************Modification History******************
* Created By       Date                    JIRA Number
*   Shakul        10/3/2022          LSP-584 (Refactored Test Class)	
******************Modification History******************/
@isTest
global class TestBoX_IntegMock implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/JSON');
        res.setBody('{'+
        '"total_count":1,'+
           '"entries":['+ 
              '{'+ 
                 '"type":"file",'+
                 '"id":"284925978574",'+
                 '"file_version":{'+ 
                    '"type":"file_version",'+
                    '"id":"299801290750",'+
                    '"sha1":"5d41c94f5687eff92c9085992a19313c92a881bd"'+
                 '},'+
                 '"sequence_id":"0",'+
                 '"etag":"0",'+
                 '"sha1":"5d41c94f5687eff92c9085992a19313c92a881bd",'+
                 '"name":"TILDocument a6h2F0000004d5gQAA.pdf",'+
                 '"description":"",'+
                 '"size":5060,'+
                 '"path_collection":{'+  
                    '"total_count":2,'+
                    '"entries":['+  
                       '{'+ 
                          '"type":"folder",'+
                          '"id":"0",'+
                          '"sequence_id":null,'+
                          '"etag":null,'+
                          '"name":"All Files"'+
                       '},'+
                       '{'+ 
                          '"type":"folder",'+
                          '"id":"47383466400",'+
                          '"sequence_id":"0",'+
                          '"etag":"0",'+
                          '"name":"SampleFromOrg"'+
                       '}'+
                    ']'+
                 '},'+
                 '"created_at":"2018-03-26T05:51:55-07:00",'+
                 '"modified_at":"2018-03-26T05:51:55-07:00",'+
                 '"trashed_at":null,'+
                 '"purged_at":null,'+
                 '"content_created_at":"2018-03-26T05:51:55-07:00",'+
                 '"content_modified_at":"2018-03-26T05:51:55-07:00",'+
                 '"created_by":{'+ 
                    '"type":"user",'+
                    '"id":"3202805146",'+
                    '"name":"CLS Dev User",'+
                    '"login":"cls_dev@happymoney.com"'+
                 '},'+
                 '"modified_by":{'+  
                    '"type":"user",'+
                    '"id":"3202805146",'+
                    '"name":"CLS Dev User",'+
                    '"login":"cls_dev@happymoney.com"'+
                 '},'+
                 '"owned_by":{'+  
                    '"type":"user",'+
                    '"id":"3202805146",'+
                    '"name":"CLS Dev User",'+
                    '"login":"cls_dev@happymoney.com"'+
                 '},'+
                 '"shared_link":null,'+
                 '"parent":{'+  
                    '"type":"folder",'+
                    '"id":"47383466400",'+
                    '"sequence_id":"0",'+
                    '"etag":"0",'+
                    '"name":"SampleFromOrg"'+
                 '},'+
                 '"item_status":"active"'+
              '}'+
           ']'+
        '}'
        );
        res.setStatusCode(201);
        res.setStatus('Created');
        res.setHeader('X-AUTH-TOKEN', 'aouthtoken12345');
        return res;
    }
}