@isTest
private class TestCL_GeneratedDocsUploadToBoxjob{
 
     @testSetup static void methodName() {
          
        CL_Document__c CS = CL_Document__c.getOrgDefaults();
        CS.Doc1__c        = 'Credit Score Notice';
        CS.Doc2__c        = 'TIL Document';
        CS.Doc3__c        = 'Adverse Action Document';
        CS.UploadedBOX__c = 'UploadedBOX';
        upsert CS;
        
            loan.TestHelper.createSeedDataForTesting();
            loan.TestHelper.createOffice();
            genesis__Applications__c genesis_applications_Obj = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Draw_Period_End_Date__c = system.Today(),
            LeadGUIDBoxFolderID__c = '48673238292',
            BoxFolderID__c = '48673238292',
            genesis__APR__c = 173
        );
        Insert genesis_applications_Obj;
        list<attachment> attlist = new list<attachment>();
       for(integer i=0; i<2; i++){
      
            Attachment at = new Attachment();
            if(i==0){
            
                at.Name = 'Credit Score Notice';
                at.Description = 'Credit Score Notice';
            }
            if(i==1){
            
                at.Name = 'TIL Document';
                at.Description = 'TIL Document';
            }
            at.body = Blob.valueOf('Generated Documents');
            at.ParentId = genesis_applications_Obj.id;
            
            attlist.add(at);
        
       }
       insert attlist;
     }
     @isTest static void testMethod1(){
      
     test.StartTest();  
          string folderid = '48673238292';      
          Blob b = Blob.valueOf('Unit Test Attachment Body');
          String namefile = 'filename'; 
          List<attachment> att = [SELECT Id,name,body,Description,ParentId from Attachment where parentId != null];
          System.debug('***att***'+att.size());
          genesis__Applications__c app =  [SELECT Id,BoxFolderID__c,LeadGUIDBoxFolderID__c from genesis__Applications__c where id =:att[0].parentId limit 1];
          System.debug('****app***'+app.BoxFolderID__c+'****'+app);
          
              CL_GeneratedDocsUploadToBoxjob genDOC = new CL_GeneratedDocsUploadToBoxjob();
              Database.QueryLocator ql = genDOC.start(null);
              genDOC.execute(null,att);
              BoX_Integ.uploadFileToBox(b,namefile,folderid,app.id);
              genDOC.Finish(null);
      test.StopTest();

    }
    @isTest static void testMethod2(){
      
     test.StartTest();  
          string folderid = '48673238292';      
          Blob b = Blob.valueOf('Unit Test Attachment Body');
          String namefile = 'filename'; 
          List<attachment> att = [SELECT Id,name,body,Description,ParentId from Attachment where parentId != null];
          System.debug('***att***'+att.size());
          genesis__Applications__c app =  [SELECT Id,BoxFolderID__c,LeadGUIDBoxFolderID__c from genesis__Applications__c where id =:att[0].parentId limit 1];
          System.debug('****app***'+app.BoxFolderID__c+'****'+app);
          
              CL_GeneratedDocsUploadToBoxjob genDOC = new CL_GeneratedDocsUploadToBoxjob();
              Database.QueryLocator ql = genDOC.start(null);
              genDOC.execute(null,att);
              Test.setMock(HttpCalloutMock.class,new TestCL_GeneratedDocsUploadToBoxjobMock());
              BoX_Integ.uploadFileToBox(b,namefile,folderid,app.id);
              genDOC.Finish(null);
      test.StopTest();

    }
    @isTest static void testMethod3(){
      
     test.StartTest();  
          string folderid = '48673238292';      
          Blob b = Blob.valueOf('Unit Test Attachment Body');
          String namefile = 'filename'; 
          List<attachment> att = [SELECT Id,name,parentId,Description from Attachment where parentId != null];
          System.debug('***att***'+att.size());
          genesis__Applications__c app =  [SELECT Id,BoxFolderID__c,LeadGUIDBoxFolderID__c from genesis__Applications__c where id =:att[0].parentId limit 1];
          System.debug('****app***'+app.BoxFolderID__c+'****'+app);
          
              CL_GeneratedDocsUploadToBoxjob genDOC = new CL_GeneratedDocsUploadToBoxjob();
              Database.QueryLocator ql = genDOC.start(null);
              genDOC.execute(null,att);
              Test.setMock(HttpCalloutMock.class,new TestCL_GeneratedDocsUploadToBoxjobMock1());
              BoX_Integ.uploadFileToBox(b,namefile,folderid,app.id);
              genDOC.Finish(null);
      test.StopTest();

    }
    public class TestCL_GeneratedDocsUploadToBoxjobMock implements HTTPCalloutMock{
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
    public class TestCL_GeneratedDocsUploadToBoxjobMock1 implements HTTPCalloutMock{
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
            res.setStatus('Conflict');
            res.setHeader('X-AUTH-TOKEN', 'aouthtoken12345');
            return res;
        }
    }
}