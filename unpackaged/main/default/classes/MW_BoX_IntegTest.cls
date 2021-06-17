@isTest
private class MW_BoX_IntegTest{

  @testSetup static void setup() {
    
        ints__OAuth_Settings__c oAuthName = new ints__OAuth_Settings__c();
         oAuthName.ints__Consumer_Key__c     = 'd998c67720u9bf2zg34ll4ogesxppsh7';
         oAuthName.ints__Consumer_Secret__c  = 'fSmCcCTwBxYHFpxElbYcJJywiw4CelFd';
         oAuthName.ints__Access_Token_URL__c = 'https://api.box.com/oauth2/token';
         oAuthName.ints__Service_Name__c     = 'BoxSB.com';
         insert oAuthName;
         
         BoxUrl__c box = new BoxUrl__c();
         box.BoxService__c = 'BoxSB.com';
         box.Boxurl__c = 'https://happymoney.app.box.com/';
         Upsert box;
         
         
         ints__OAuth_Token__c authToken = new ints__OAuth_Token__c();
         authToken.ints__Token__c = 'yBE4Ci4BP9wa8D00AXH4rm9t9Y6blKrL';  
         authToken.ints__Refresh_Token__c = 'NqDQcTONAkM0U1NJKVBeTi3bNmNHoDwS88TkSquSK1RVn4tQKlWFBzDkxXy9woPq';
         authToken.ints__OAuth_Settings__c = oAuthName.id;
         authToken.ints__Is_Valid__c = true;
         insert authToken;
          
           Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName',
            peer__Last_Name__c='TestLName', 
            City__c='TestCity',
            State__c='TestState',
            ZIP_Code__c='123456'
        );
        Insert acc;
        
        genesis__Applications__c app = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Account__c = acc.Id,        
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'REJECTED',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c = 'Full Time',
            genesis__Loan_Amount__c=1000
        );      
        Insert app;
                
       
    }
    @isTest static void testMethod1() {
       test.StartTest();
            MW_BoX_Integ.getOldAccessToken();
       test.StopTest();
    }
    @isTest static void testMethod2() {
       test.StartTest();
             Test.setMock(HttpCalloutMock.class,new TestBoX_IntegMock1());
             MW_BoX_Integ.getNewAccessToken();
       test.StopTest();
    }
    @isTest static void testMethod3() {
       test.StartTest();
             MW_BoX_Integ.getNewAccessToken();
       test.StopTest();
    }
    @isTest static void testMethod61() {
       test.StartTest();
             MW_BoxUtilHelper.getNewAccessToken();
       test.StopTest();
    }
    @isTest static void testMethod4() {
      try{
        ints__OAuth_Settings__c oAuthName = [SELECT Id,Name, ints__Access_Token_URL__c,ints__Consumer_Key__c, ints__Consumer_Secret__c 
                                     FROM ints__OAuth_Settings__c WHERE ints__Service_Name__c ='BoxSB.com' LIMIT 1];
            System.debug('... oAuthName...'+oAuthName );
            delete oAuthName;
                            
                    ints__OAuth_Token__c authToken = [SELECT ints__Token__c, 
                                                            ints__Refresh_Token__c
                                                            FROM ints__OAuth_Token__c WHERE 
                                                            ints__OAuth_Settings__c =: oAuthName.Id and 
                                                      ints__Is_Valid__c = true Order By CreatedDate DESC LIMIT 1];
          }
          catch(exception e){
          }
         
    }
    @isTest static void testMethod5() {
       test.StartTest();
            testMethod4();
            MW_BoX_Integ.getOldAccessToken();
       test.StopTest();
    }
    @isTest static void testMethod6(){
      
      test.StartTest();
        ints__OAuth_Settings__c oAuthName = [SELECT Id,Name, ints__Access_Token_URL__c,ints__Consumer_Key__c, ints__Consumer_Secret__c 
                                     FROM ints__OAuth_Settings__c WHERE ints__Service_Name__c ='BoxSB.com' LIMIT 1];
            System.debug('... oAuthName...'+oAuthName );
                            
                    ints__OAuth_Token__c authToken = [SELECT ints__Token__c, 
                                                            ints__Refresh_Token__c
                                                            FROM ints__OAuth_Token__c WHERE 
                                                            ints__OAuth_Settings__c =: oAuthName.Id and 
                                                      ints__Is_Valid__c = true Order By CreatedDate DESC LIMIT 1];
         
         MW_BoX_Integ.insertBoxToken(oAuthName.Id, authToken.ints__Token__c,authToken.ints__Refresh_Token__c);
       test.StopTest();
        
        
    }
     @isTest static void testMethod7(){
      
      test.StartTest();
      try{
        ints__OAuth_Settings__c oAuthName = [SELECT Id,Name, ints__Access_Token_URL__c,ints__Consumer_Key__c, ints__Consumer_Secret__c 
                                     FROM ints__OAuth_Settings__c WHERE ints__Service_Name__c ='BoxSB.com' LIMIT 1];
            System.debug('... oAuthName...'+oAuthName );
                          
                    ints__OAuth_Token__c authToken = [SELECT ints__Token__c, 
                                                            ints__Refresh_Token__c
                                                            FROM ints__OAuth_Token__c WHERE 
                                                            ints__OAuth_Settings__c =: oAuthName.Id and 
                                                      ints__Is_Valid__c = true Order By CreatedDate DESC LIMIT 1];
         
         MW_BoX_Integ.insertBoxToken(authToken.name,authToken.ints__Token__c,authToken.ints__Refresh_Token__c);         
         ints__OAuth_Token__c authToken1 = [SELECT ints__Token__c, 
                                                            ints__Refresh_Token__c
                                                            FROM ints__OAuth_Token__c WHERE 
                                                            ints__OAuth_Settings__c =: oAuthName.Id and 
                                                      ints__Is_Valid__c = true Order By CreatedDate DESC LIMIT 1];
         
         
       }
       catch(exception e){
           
       }
      
       test.StopTest();
        
        
    }
    @isTest static void testMethod8(){
      
      test.StartTest();
      try{
        ints__OAuth_Settings__c oAuthName = [SELECT Id,Name, ints__Access_Token_URL__c,ints__Consumer_Key__c, ints__Consumer_Secret__c 
                                     FROM ints__OAuth_Settings__c WHERE ints__Service_Name__c ='BoxSB.com' LIMIT 1];
            System.debug('... oAuthName...'+oAuthName );
                          
                    ints__OAuth_Token__c authToken = [SELECT ints__Token__c, 
                                                            ints__Refresh_Token__c
                                                            FROM ints__OAuth_Token__c WHERE 
                                                            ints__OAuth_Settings__c =: oAuthName.Id and 
                                                      ints__Is_Valid__c = true Order By CreatedDate DESC LIMIT 1];
         
         MW_BoX_Integ.insertBoxToken(authToken.name,authToken.ints__Token__c,authToken.ints__Refresh_Token__c);         
         ints__OAuth_Token__c authToken1 = [SELECT ints__Token__c, 
                                                            ints__Refresh_Token__c
                                                            FROM ints__OAuth_Token__c WHERE 
                                                            ints__OAuth_Settings__c =: oAuthName.Id and 
                                                      ints__Is_Valid__c = true Order By CreatedDate DESC LIMIT 1];
         
         
       }
       catch(exception e){
           
       }
      
       test.StopTest();
        
        
    }
    @isTest static void testMethod9(){
      
      test.StartTest();
        Account acc = [Select id From Account Where Name = 'Test' limit 1];
        genesis__Applications__c app = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Account__c = acc.Id,        
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'REJECTED',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c = 'Full Time',
            genesis__Loan_Amount__c=1000
        );      
        Insert app;
          string folderid = '48673238292';      
          Blob b = Blob.valueOf('Unit Test Attachment Body');
          String namefile = 'filename';
          MW_BoX_Integ.uploadFileToBox(b,namefile ,folderid,app.id);
      test.StopTest();

    }
    @isTest static void testMethod10(){
      
     test.StartTest();  
          string folderid = '48673238292';      
          Blob b = Blob.valueOf('Unit Test Attachment Body');
          String namefile = 'filename';
          List<genesis__Applications__c> app =  [SELECT Id from genesis__Applications__c];
          Test.setMock(HttpCalloutMock.class,new TestBoX_IntegMock2());
          MW_BoX_Integ.uploadFileToBox(b,namefile ,folderid,app[0].id);
      test.StopTest();

    }
    @isTest static void testMethod11(){
      
     test.StartTest();  
          string folderid = '48673238292';      
          Blob b = Blob.valueOf('Unit Test Attachment Body');
          String namefile = 'filename';
          List<genesis__Applications__c> app =  [SELECT Id from genesis__Applications__c];
          Test.setMock(HttpCalloutMock.class,new TestBoX_IntegMock3());
          MW_BoX_Integ.uploadFileToBox(b,namefile ,folderid,app[0].id);
      test.StopTest();

    }
    
    public class TestBoX_IntegMock1 implements HTTPCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/JSON');
            res.setBody('{"access_token":"VPTELvq1gYzJmgqaFFsSuAZfOwyBj4pk","expires_in":3975,"restricted_to":[],"refresh_token":"hWZu9ngpClDnlPIBPiHnUWvReBC87xKhIKhYImMaank9ZK7jCjY4wYP8fGH772uE","token_type":"bearer"}');
            res.setStatusCode(200);
            res.setHeader('X-AUTH-TOKEN', 'aouthtoken12345');
            return res;
        }
    }
    public class TestBoX_IntegMock2 implements HTTPCalloutMock{
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
    public class TestBoX_IntegMock3 implements HTTPCalloutMock{
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
            res.setStatusCode(401);
            res.setStatus('Unauthorized');
            res.setHeader('X-AUTH-TOKEN', 'aouthtoken12345');
            return res;
        }
    }
    
    
}