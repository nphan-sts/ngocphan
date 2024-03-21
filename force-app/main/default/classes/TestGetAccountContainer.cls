@isTest
public class TestGetAccountContainer {

    public static testMethod void testParse() {
		String json=		'{'+
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
		GetAccountContainer.parse(json);
	}
}