@isTest
private class TestBoxAPI_Integration{
    @testSetup static void setup() {
      
          
            ints__OAuth_Settings__c oAuthName = new ints__OAuth_Settings__c();
             oAuthName.ints__Consumer_Key__c     = 'd998c67720u9bf2zg34ll4ogesxppsh7';
             oAuthName.ints__Consumer_Secret__c  = 'fSmCcCTwBxYHFpxElbYcJJywiw4CelFd';
             oAuthName.ints__Access_Token_URL__c = 'https://api.box.com/oauth2/token';
             oAuthName.ints__Service_Name__c     = 'BoxSB.com';
             insert oAuthName;
             
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
        @isTest static void testMethod1(){
      
          test.StartTest();
          List<genesis__Applications__c> app =  [SELECT Id from genesis__Applications__c];
            ints__OAuth_Settings__c oAuthName = [SELECT Id,Name, ints__Access_Token_URL__c,ints__Consumer_Key__c, ints__Consumer_Secret__c 
                                         FROM ints__OAuth_Settings__c WHERE ints__Service_Name__c ='BoxSB.com' LIMIT 1];
                System.debug('... oAuthName...'+oAuthName );
                                
                        ints__OAuth_Token__c authToken = [SELECT ints__Token__c, 
                                                                ints__Refresh_Token__c
                                                                FROM ints__OAuth_Token__c WHERE 
                                                                ints__OAuth_Settings__c =: oAuthName.Id and 
                                                          ints__Is_Valid__c = true Order By CreatedDate DESC LIMIT 1];
            
             String authCode ='jfljfldjfljfljflkdf';
             BoxAPI_Integration.getBoxToken(app[0].id,oAuthName.id,authCode);
           test.StopTest();
        
        
         }
         @isTest static void testMethod2(){
      
          test.StartTest();
          List<genesis__Applications__c> app =  [SELECT Id from genesis__Applications__c];
            ints__OAuth_Settings__c oAuthName = [SELECT Id,Name, ints__Access_Token_URL__c,ints__Consumer_Key__c, ints__Consumer_Secret__c 
                                         FROM ints__OAuth_Settings__c WHERE ints__Service_Name__c ='BoxSB.com' LIMIT 1];
                System.debug('... oAuthName...'+oAuthName );
                                
                        ints__OAuth_Token__c authToken = [SELECT ints__Token__c, 
                                                                ints__Refresh_Token__c
                                                                FROM ints__OAuth_Token__c WHERE 
                                                                ints__OAuth_Settings__c =: oAuthName.Id and 
                                                          ints__Is_Valid__c = true Order By CreatedDate DESC LIMIT 1];
            
             String authCode ='jfljfldjfljfljflkdf';
             Test.setMock(HttpCalloutMock.class,new TestBoxAPI_IntegrationMock1());
             BoxAPI_Integration.getBoxToken(app[0].id,oAuthName.id,authCode);
           test.StopTest();
        
        
         }
         @isTest static void testMethod3(){
      
          test.StartTest();
          List<genesis__Applications__c> app =  [SELECT Id from genesis__Applications__c];
            ints__OAuth_Settings__c oAuthName = [SELECT Id,Name, ints__Access_Token_URL__c,ints__Consumer_Key__c, ints__Consumer_Secret__c 
                                         FROM ints__OAuth_Settings__c WHERE ints__Service_Name__c ='BoxSB.com' LIMIT 1];
                System.debug('... oAuthName...'+oAuthName );
                                
                        ints__OAuth_Token__c authToken = [SELECT ints__Token__c, 
                                                                ints__Refresh_Token__c
                                                                FROM ints__OAuth_Token__c WHERE 
                                                                ints__OAuth_Settings__c =: oAuthName.Id and 
                                                          ints__Is_Valid__c = true Order By CreatedDate DESC LIMIT 1];
            
             
             BoxAPI_Integration.getAccessToken();
           test.StopTest();
        
        
         }
          @isTest static void testMethod4(){
      
          test.StartTest();
          List<genesis__Applications__c> app =  [SELECT Id from genesis__Applications__c];
            ints__OAuth_Settings__c oAuthName = [SELECT Id,Name, ints__Access_Token_URL__c,ints__Consumer_Key__c, ints__Consumer_Secret__c 
                                         FROM ints__OAuth_Settings__c WHERE ints__Service_Name__c ='BoxSB.com' LIMIT 1];
                System.debug('... oAuthName...'+oAuthName );
                                
                        ints__OAuth_Token__c authToken = [SELECT ints__Token__c, 
                                                                ints__Refresh_Token__c
                                                                FROM ints__OAuth_Token__c WHERE 
                                                                ints__OAuth_Settings__c =: oAuthName.Id and 
                                                          ints__Is_Valid__c = true Order By CreatedDate DESC LIMIT 1];
            
             
             Test.setMock(HttpCalloutMock.class,new TestBoxAPI_IntegrationMock1());
             BoxAPI_Integration.getAccessToken();
           test.StopTest();
        
        
         }
         public class TestBoxAPI_IntegrationMock1 implements HTTPCalloutMock{
         public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/JSON');
            res.setBody('{"access_token":"VPTELvq1gYzJmgqaFFsSuAZfOwyBj4pk","expires_in":3975,"restricted_to":[],"refresh_token":"hWZu9ngpClDnlPIBPiHnUWvReBC87xKhIKhYImMaank9ZK7jCjY4wYP8fGH772uE","token_type":"bearer"}');
            res.setStatusCode(200);
            res.setHeader('X-AUTH-TOKEN', 'aouthtoken12345');
            return res;
        }
    }
}