@isTest
private class TestBoxAPI_CreateFolder{

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
                loan__Investor__c = false,
                cnotify__Email__c = 'no-reply@testorganization.com',
                peer__First_Name__c = 'TestFName',
                peer__Last_Name__c='TestLName', 
                City__c='TestCity',
                State__c='TestState',
                ZIP_Code__c='123456'
            );
            Insert acc;
              
           Account acc1 = new Account(
            Name = 'Test',
            loan__Investor__c = true,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName',
            peer__Last_Name__c='TestLName',
            BoxFolderID__c = '48673238292',
            City__c='TestCity',
            State__c='TestState',
            ZIP_Code__c='123456'
        );
        Insert acc1;
        List<genesis__Applications__c> applist = new List<genesis__Applications__c>();
        for(integer i = 0; i<3; i++){
        genesis__Applications__c app = new genesis__Applications__c();
            app.genesis__Due_Day__c = 20;
            app.genesis__Expected_First_Payment_Date__c = system.Today();
            app.genesis__Expected_Start_Date__c = system.Today();
            app.genesis__Funding_in_Tranches__c = true;
            app.genesis__Account__c = acc.Id;
            app.Investor__c = acc1.id;     
            app.Application_Start_DateV2__c = system.Today();
            app.genesis__Status__c = 'REJECTED';
            app.Lead_ID__c = 'lkjnjfujw4nwrofujfsofjijwrjnojf';
            app.LeadGUID_XX_BoxFolderID__c = '234455666';
            app.LeadGUIDBoxFolderID__c = null;
            app.genesis__Draw_Period_End_Date__c = system.Today();
            app.Employment_Status__c = 'Full Time';
            app.BoxFolderID__c = null;
            app.genesis__Loan_Amount__c=1000;    
            applist.add(app);
           }
           insert applist;
                
       
    }
    @isTest static void testMethod1() {
       test.StartTest();
            List<genesis__Applications__c> genids =  [SELECT BoxFolderID__c,Investor__r.BoxFolderID__c,Lead_ID__c,LeadGUID_XX_BoxFolderID__c,LeadGUIDBoxFolderID__c FROM genesis__Applications__c];
             
             BoxAPI_CreateFolder.invokeCheckBoxFolder(genids);
              
       test.StopTest();
    }
    @isTest static void testMethod2() {
       test.StartTest();
            List<genesis__Applications__c> genids =  [SELECT BoxFolderID__c,Investor__r.BoxFolderID__c,Lead_ID__c,LeadGUID_XX_BoxFolderID__c, LeadGUIDBoxFolderID__c FROM genesis__Applications__c];
             Test.setMock(HttpCalloutMock.class,new TestBoX_IntegMock1());
             BoxAPI_CreateFolder.invokeCheckBoxFolder(genids); 
       test.StopTest();
    }
    @isTest static void testMethod3() {
       test.StartTest();
            List<genesis__Applications__c> genids =  [SELECT BoxFolderID__c,Investor__r.BoxFolderID__c,Lead_ID__c,LeadGUID_XX_BoxFolderID__c, LeadGUIDBoxFolderID__c FROM genesis__Applications__c];
             Test.setMock(HttpCalloutMock.class,new TestBoX_IntegMock2());
             BoxAPI_CreateFolder.invokeCheckBoxFolder(genids); 
       test.StopTest();
    }
     public class TestBoX_IntegMock1 implements HTTPCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/JSON');
            res.setBody('{"type":"folder","id":"48679906299","etag":"0"}');
            res.setStatusCode(201);
            res.setStatus('Created');
            res.setHeader('X-AUTH-TOKEN', 'aouthtoken12345');
            return res;
        }
    }
    public class TestBoX_IntegMock2 implements HTTPCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/JSON');
            res.setBody('{"type":"folder","id":"48679906299","etag":"0"}');
            res.setStatusCode(401);
            res.setStatus('Unauthorized');
            res.setHeader('X-AUTH-TOKEN', 'aouthtoken12345');
            return res;
        }
    }
}