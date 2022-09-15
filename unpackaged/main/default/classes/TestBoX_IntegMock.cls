/* ****************Modification History******************
* Created By       Date                    JIRA Number
*   Shakul        10/3/2022          LSP-584 (Refactored Test Class)	
******************Modification History******************/
@isTest
global class TestBoX_IntegMock implements HttpCalloutMock {
   static final String SEQ_ID_CONST = '"sequence_id":"0",';
   static final String ETAG_CONST = '"etag":"0",';
   static final String TYPE_FOLDER_CONST = '"type":"folder",';
   static final String TYPE_USER_CONST = '"type":"user",';
   static final String ID_CONST ='"id":"3202805146",';
   static final String NAME_CLS_CONST ='"name":"CLS Dev User",';
   static final String LOGIN_CONST ='"login":"cls_dev@happymoney.com"';
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
                 SEQ_ID_CONST+
                 ETAG_CONST+
                 '"sha1":"5d41c94f5687eff92c9085992a19313c92a881bd",'+
                 '"name":"TILDocument a6h2F0000004d5gQAA.pdf",'+
                 '"description":"",'+
                 '"size":5060,'+
                 '"path_collection":{'+  
                    '"total_count":2,'+
                    '"entries":['+  
                       '{'+ 
                          TYPE_FOLDER_CONST+
                          '"id":"0",'+
                          '"sequence_id":null,'+
                          '"etag":null,'+
                          '"name":"All Files"'+
                       '},'+
                       '{'+ 
                          TYPE_FOLDER_CONST+
                          '"id":"47383466400",'+
                          SEQ_ID_CONST+
                          ETAG_CONST+
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
                    TYPE_USER_CONST+
                    ID_CONST+
                    NAME_CLS_CONST+
                    LOGIN_CONST+
                 '},'+
                 '"modified_by":{'+  
                    TYPE_USER_CONST+
                    ID_CONST+
                    NAME_CLS_CONST+
                    LOGIN_CONST+
                 '},'+
                 '"owned_by":{'+  
                    TYPE_USER_CONST+
                    ID_CONST+
                    NAME_CLS_CONST+
                    LOGIN_CONST+
                 '},'+
                 '"shared_link":null,'+
                 '"parent":{'+  
                    TYPE_FOLDER_CONST+
                    '"id":"47383466400",'+
                    SEQ_ID_CONST+
                    ETAG_CONST+
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