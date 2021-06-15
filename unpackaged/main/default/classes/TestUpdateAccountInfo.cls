@isTest
public class TestUpdateAccountInfo{    
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
   testmethod static void method1(){
       //Creating custom setting
        ints__Yodlee_Cobrand_Credentials__c yodlee = ints__Yodlee_Cobrand_Credentials__c.getOrgdefaults();
        
       //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            //Borrower_s_Last_Name__c='Testborrower',
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
         //Creating Application
        genesis__Applications__c app= new genesis__Applications__c(
                                            genesis__Due_Day__c = 20,
                                            genesis__Expected_First_Payment_Date__c = system.Today(),
                                            genesis__Expected_Start_Date__c = system.Today(),
                                            genesis__Funding_in_Tranches__c = true,
                                            Borrower_s_Email__c = null,
                                            genesis__Account__c = acc.Id,
                                            Application_Start_DateV2__c = system.Today(),
                                            DocuSignFlag__c=true,
                                            genesis__Status__c = 'agent_verified',
                                            genesis__Draw_Period_End_Date__c = system.Today()
                                            );
        insert app;
        System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');
        Test.setMock(HttpCalloutMock.class, new TestGetAccountContainerMock());
        test.startTest();
        UpdateAccountInfo.getLastUpdate(acc.id);
        test.stopTest();
   }
}