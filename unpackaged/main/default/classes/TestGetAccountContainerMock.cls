/* ****************Modification History******************
* Created By       Date                    JIRA Number
*   Shakul        15/3/2022          LSP-597 (Refactored Test Class)	
******************Modification History******************/
public class TestGetAccountContainerMock implements HttpCalloutMock{
    static final String CURLY_BRACKETCLOSE_CONST = '},';
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
            CURLY_BRACKETCLOSE_CONST+
            '      "accountType": "SAVINGS",'+
            '      "createdDate": "2016-08-25T09:16:32Z",'+
            '      "isAsset": true,'+
            '      "isManual": true,'+
            '      "balance": {'+
            '         "amount": 84699,'+
            '         "currencyAmount": "USD"'+
            CURLY_BRACKETCLOSE_CONST+
            '      "providerId": 16441,'+
            '      "providerName": "Dag Site",'+
            '      "overDraftLimit": {'+
            '         "amount": 654,'+
            '         "currencyAmount": "INR"'+
            CURLY_BRACKETCLOSE_CONST+
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