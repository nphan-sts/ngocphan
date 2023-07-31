@isTest
public class MW_UploadTILToBOXTempBatchTest {
    
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
            Name = 'TestINVESTOR',
            loan__Investor__c = true,
            loan__Active__c = 'Yes',
            
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName',
            peer__Last_Name__c='TestLName',
            BoxFolderID__c = '48673238292',
            City__c='TestCity',
            State__c='TestState',
            ZIP_Code__c='123456',
            Investor_Code__c='TIU'
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
            app.genesis__Status__c = 'pre_funding';
            app.Lead_ID__c = 'lkjnjfujw4nwrofujfsofjijwrjnojf';
            app.genesis__Draw_Period_End_Date__c = system.Today();
            app.Employment_Status__c = 'Full Time';
            app.BoxFolderID__c = '48673238292';
            app.genesis__Loan_Amount__c=1000;
            app.LeadGUID_XX_BoxFolderID__c =' 123213213'+i;
            applist.add(app);
           }
           insert applist;
           
            genesis__Application_Document_Category__c appDoc = new genesis__Application_Document_Category__c();
            appDoc.Box_URl__c = 'https://happymoney.app.box.com/file/538729346459';
            appDoc.Name = 'TIL Document';
            
            appDoc.genesis__Application__c = applist[0].Id;
            insert appDoc;
            
            Attachment attach = new Attachment();  
            attach.Name =' Unit Test Attachment';
            Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
            attach.body = bodyBlob;
            attach.Description = 'TIL Document';
            attach.parentId = applist[0].Id;
            insert attach;
                
       
    }
  
    public static testMethod void testWF_FixTILBatch(){
        
        CL_Document__c cs = new CL_Document__c();
        cs.Doc1__c = 'Credit Score Notice';
        cs.Doc2__c = 'TIL Document';
        cs.Doc3__c = 'Adverse Action Document';
        cs.UploadedBOX__c = 'UploadedBOX';
        insert cs;
        
        
        Datetime startDate = datetime.newInstance(2019, 10, 10);
        Datetime endDate = datetime.newInstance(2019, 10, 12);
        system.debug('startDate==='+startDate);
        system.debug('endDate==='+endDate);
        
        set<string> skipLoanStatusSet = new set<string>();
        skipLoanStatusSet.add('Review');
        skipLoanStatusSet.add('Decline_Manual_Review');
        skipLoanStatusSet.add('Declined');
        skipLoanStatusSet.add('Expired');
        skipLoanStatusSet.add('Withdrawn');
        skipLoanStatusSet.add('Default Documents');
        skipLoanStatusSet.add('offer_shown');
        List<genesis__Applications__c> applist = [Select Id,Lead_Id__c from genesis__Applications__c limit 1];
        set<String> appStatuses = new set<String>();
        appStatuses.add(applist[0].Lead_Id__c);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new TestBoX_IntegMock1());
        MW_UploadTILToBOXTempBatch btch = new MW_UploadTILToBOXTempBatch(appStatuses);
        Database.executeBatch(btch,1);
        Test.stopTest();
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