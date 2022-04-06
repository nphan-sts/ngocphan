/* ****************Modification History******************
 * Updated By        Date			 Jira Number
 *1. Bhanupriya       2022/03/09     LSP-608(create setup() method,Add required fields, add comments, assert statements)
 ******************Modification History******************/

@isTest
public class TestLastUpdateDate{
    
    public class TestGetAccountContainerMock implements HttpCalloutMock{

        public HTTPResponse respond(HTTPRequest req) { 
                 
            String json =  '{'+
                '"account": ['+
                '   {'+
                '      "CONTAINER": "bank",'+
                '      "providerAccountId": 12345,'+
                '      "accountName": "SMB account",'+
                '      "id": 801503,'+
                '      "accountNumber": "xxxx4933",'+
                '      "availableBalance": {'+
                '         "amount": 4699,'+
                '         "currencyAmount": "USD"'+
                '      },'+
                '      "accountType": "SAVINGS",'+
                '      "createdDate": "2016-08-25T09:16:32Z",'+
                '      "isAsset": true,'+
                '      "isManual": true,'+
                '      "balance": {'+
                '         "amount": 84699,'+
                '         "currencyAmount": "USD"'+
                '      },'+
                '      "providerId": 16441,'+
                '      "providerName": "Dag Site",'+
                '      "overDraftLimit": {'+
                '         "amount": 654,'+
                '         "currencyAmount": "INR"'+
                '      },'+
                '      "refreshinfo": {'+
                '         "statusCode": 0,'+
                '         "statusMessage": "OK",'+
                '         "lastRefreshed": "2015-09-20T14:46:23Z",'+
                '         "lastRefreshAttempt": "2015-09-20T14:46:23Z",'+
                '         "nextRefreshScheduled": "2015-09-23T14:46:23Z"'+
                '      }, '+
                '      "accountStatus": "ACTIVE"'+
                '   }'+
                ']'+
                '}';
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody(json);
            res.setStatusCode(200);
            return res;
        }
    }
   //create testsetup method() 	
    @testsetup()
    public static void testsetup()
    {
        		 //Creating custom setting
        ints__Yodlee_Cobrand_Credentials__c yodlee = ints__Yodlee_Cobrand_Credentials__c.getOrgdefaults();
        system.debug('Yodlee Credentials'+yodlee);
         //Creating Account
        Account accTest = new Account(
                                Name = 'Test',
                                loan__Investor__c=False,
                                cnotify__Email__c = 'abc@test.com',
                                peer__Last_Name__c = 'Test Last Name',						//LSP-608 Required field
                                loan__SOCIAL_SECURITY_NUMBER__c = '123456789'				//LSP-608 must be 9 digit
                                );
        insert accTest;
        
        //Creating Application
        genesis__Applications__c appTest= new genesis__Applications__c(
                                        genesis__Due_Day__c = 20,
                                        genesis__Expected_First_Payment_Date__c = system.Today(),
                                        genesis__Expected_Start_Date__c = system.Today(),
                                        genesis__Funding_in_Tranches__c = true,
                                        Borrower_s_Email__c = null,
                                        genesis__Account__c = accTest.Id,
                                        Application_Start_DateV2__c = system.Today(),
                                        DocuSignFlag__c=true,
                                        genesis__Status__c = 'agent_verified',
                                        genesis__Draw_Period_End_Date__c = system.Today()
                                        );
        insert appTest;
               
    }
    //test method 
    Testmethod static void useraccountLastupdateDate(){
        
        	genesis__Applications__c appTest = [select id from genesis__Applications__c]; 
        
        	Test.startTest();
        	HttpResponse res = new HttpResponse();
        	Test.setMock(HttpCalloutMock.class, new TestGetAccountContainerMock());
        	LastUpdateDate.getLastUpdate('12292014_0:749a171967442663f14b6def055d7f5e2e4ca42ba7de5a0014597f950867cdb625bec7fcbc99b5eb806f1af7c8b04ed93668751207b27ed114dcb289ce0cb0f8','1234',appTest.id);
        	Test.stopTest();
        	system.assert(res!=null);  	
    }
}