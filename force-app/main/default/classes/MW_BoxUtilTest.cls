@isTest
private class MW_BoxUtilTest{
  
  @testSetup static void setup() 
  {
         BoxUrl__c box = new BoxUrl__c();
         box.BoxService__c='BoxSB.com';
         box.Boxurl__c='https://happymoney.app.box.com/';
         insert box;

         ints__OAuth_Settings__c oAuthName = new ints__OAuth_Settings__c();
         oAuthName.ints__Consumer_Key__c     = 'd998c67720u9bf2zg34ll4ogesxppsh7';
         oAuthName.ints__Consumer_Secret__c  = 'fSmCcCTwBxYHFpxElbYcJJywiw4CelFd';
         oAuthName.ints__Access_Token_URL__c = 'https://api.box.com/oauth2/token';
         oAuthName.ints__Service_Name__c     = 'BoxSB.com';
         insert oAuthName;
         
         ints__OAuth_Token__c authToken = new ints__OAuth_Token__c();
         authToken.ints__Token__c = 'yBE4Ci4BP9wa8D00AXH4rm9t9Y6blKrL';  
         authToken.ints__Refresh_Token__c = 'NqDQcTONAkM0U1NJKVBeTi3bNmNHoDwS88TkS-quSK1RVn4tQKlWFBzDkxXy9woPq';
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
            app.genesis__Draw_Period_End_Date__c = system.Today();
            app.Employment_Status__c = 'Full Time';
            app.BoxFolderID__c = '48673238292';
            app.genesis__Loan_Amount__c=1000;    
            applist.add(app);
           }
           insert applist;
                
       
    }
   
    @isTest static void testMethod1() {
       test.StartTest();
        List<genesis__Applications__c> genids =  [SELECT BoxFolderID__c,Investor__r.BoxFolderID__c,Lead_ID__c, LeadGUID_XX_BoxFolderID__c FROM genesis__Applications__c];
              genids[0].LeadGUID_XX_BoxFolderID__c='123213213';
             update  genids;
             MW_BoxUtil.invokeCheckBoxFolder(genids);
             test.StopTest();
    }

    @isTest static void testMethod2() {
       test.StartTest();
        List<genesis__Applications__c> genids =  [SELECT BoxFolderID__c,Investor__r.BoxFolderID__c,Lead_ID__c, LeadGUID_XX_BoxFolderID__c FROM genesis__Applications__c];
         genids[0].LeadGUID_XX_BoxFolderID__c='123213213';
         update  genids;
        MW_BoxUtil.CreateAppFolder(genids[0].Id,genids[0].LeadGUID_XX_BoxFolderID__c,genids[0].Lead_ID__c,200); 
       test.StopTest();
    }


    @isTest static void testMethod3() {
       test.StartTest();
        List<genesis__Applications__c> genids =  [SELECT BoxFolderID__c,Investor__r.BoxFolderID__c,Lead_ID__c, LeadGUID_XX_BoxFolderID__c FROM genesis__Applications__c];
         genids[0].LeadGUID_XX_BoxFolderID__c='123213213';
         update  genids;
        MW_BoxUtil.InsertAppFolderID(String.valueOf(genids[0].LeadGUID_XX_BoxFolderID__c),String.valueOf(genids[0].Id)); 
       test.StopTest();
    }

    @isTest static void testMethod31() {
       test.StartTest();
        List<genesis__Applications__c> genids =  [SELECT BoxFolderID__c,Investor__r.BoxFolderID__c,Lead_ID__c, LeadGUID_XX_BoxFolderID__c FROM genesis__Applications__c];
        genids[0].BoxFolderID__c='123213213';
        update  genids;
        MW_BoxUtil.InsertAppFolderID(String.valueOf(genids[0].LeadGUID_XX_BoxFolderID__c),String.valueOf(genids[0].Id)); 
       test.StopTest();
    }
    
    @isTest static void testMethod4() {
       test.StartTest();
            List<genesis__Applications__c> genids =  [SELECT BoxFolderID__c,Investor__r.BoxFolderID__c,Lead_ID__c, LeadGUID_XX_BoxFolderID__c FROM genesis__Applications__c];
             genids[0].LeadGUID_XX_BoxFolderID__c='123213213';

             update  genids;
             Test.setMock(HttpCalloutMock.class,new TestBoX_IntegMock1());
             MW_BoxUtil.invokeCheckBoxFolder(genids); 
       test.StopTest();
    }
    @isTest static void testMethod5() {
       test.StartTest();
            List<genesis__Applications__c> genids =  [SELECT BoxFolderID__c,Investor__r.BoxFolderID__c,Lead_ID__c, LeadGUID_XX_BoxFolderID__c FROM genesis__Applications__c];
             Test.setMock(HttpCalloutMock.class,new TestBoX_IntegMock2());
             MW_BoxUtil.invokeCheckBoxFolder(genids); 
       test.StopTest();
    }

    @isTest static void testMethod6() {
       test.StartTest();
            List<genesis__Applications__c> genids =  [SELECT BoxFolderID__c,Investor__r.BoxFolderID__c,Lead_ID__c, LeadGUID_XX_BoxFolderID__c FROM genesis__Applications__c];
             Test.setMock(HttpCalloutMock.class,new TestBoX_IntegMock3());
             MW_BoxUtil.invokeCheckBoxFolder(genids); 
       test.StopTest();
    }

    @isTest static void testMethod7() {
       test.StartTest();
            List<Account> genids =  [SELECT Id FROM Account];
             Test.setMock(HttpCalloutMock.class,new TestBoX_IntegMock3());
             MW_BoxUtil.CheckBoxFolder(genids[0].Id); 
       test.StopTest();
    }
    
    @isTest static void testMethod21() {
       test.StartTest();
        List<genesis__Applications__c> genids =  [SELECT BoxFolderID__c,Investor__r.BoxFolderID__c,Lead_ID__c, LeadGUID_XX_BoxFolderID__c FROM genesis__Applications__c];
        Test.setMock(HttpCalloutMock.class,new TestBoX_IntegMock4());
        MW_BoxUtil.CreateAppFolder(genids[0].Id,'123213213',genids[0].Lead_ID__c,200); 
        test.StopTest();
    }

    @isTest static void testMethod22() {
       test.StartTest();
        List<genesis__Applications__c> genids =  [SELECT BoxFolderID__c,Investor__r.BoxFolderID__c,Lead_ID__c, LeadGUID_XX_BoxFolderID__c FROM genesis__Applications__c];
        Test.setMock(HttpCalloutMock.class,new TestBoX_IntegMock2());
        MW_BoxUtil.CreateAppFolder(genids[0].Id,'123213213',genids[0].Lead_ID__c,200); 
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

    public class TestBoX_IntegMock3 implements HTTPCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            StaticResource sr = [select Body from StaticResource where Name='BoxResposne' limit 1];
            String xmlString = sr.Body.toString();
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/JSON');
            res.setBody(xmlString);
            res.setStatusCode(200);
            res.setStatus('Created');
            res.setHeader('X-AUTH-TOKEN', 'aouthtoken12345');
            return res;
        }
    }

     public class TestBoX_IntegMock4 implements HTTPCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            StaticResource sr = [select Body from StaticResource where Name='BoxResposne' limit 1];
            String xmlString = sr.Body.toString();
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/JSON');
            res.setBody(xmlString);
            res.setStatusCode(201);
            res.setStatus('Created');
            res.setHeader('X-AUTH-TOKEN', 'aouthtoken12345');
            return res;
        }
    }
}