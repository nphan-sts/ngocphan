@isTest
public class TestGetTransactionContainer {
static testMethod void testParse() {
		String json=		'{'+
		'  "transaction": ['+
		'    {'+
		'      "CONTAINER": "bank",'+
		'      "id": 25335410,'+
		'      "type": "OTHER_DEPOSITS",'+
		'      "subType": "CREDIT",'+
		'      "amount": {'+
		'        "amount": 3465,'+
		'        "currency": "USD"'+
		'      },'+
		'      "baseType": "CREDIT",'+
		'      "categoryType": "INCOME",'+
		'      "categoryId": 32,'+
		'      "category": "Other Income",'+
		'      "categorySource": "SYSTEM",'+
		'      "description": {'+
		'        "original": "DESC",'+
		'        "simple": "DESC"'+
		'      },'+
		'      "date": "2017-03-16",'+
		'      "postDate": "2017-03-16",'+
		'      "transactionDate": "2017-03-16",'+
		'      "isManual": false,'+
		'      "status": "POSTED",'+
		'      "accountId": 10563602,'+
		'      "runningBalance": {'+
		'        "amount": 59,'+
		'        "currency": "USD"'+
		'      },'+
		'      "checkNumber": "DAG-133",'+
		'      "highLevelCategoryId": 10000012'+
		'    },'+
		'    {'+
		'      "CONTAINER": "bank",'+
		'      "id": 25335412,'+
		'      "type": "OTHER_WITHDRAWALS",'+
		'      "subType": "DEBIT",'+
		'      "amount": {'+
		'        "amount": 3103,'+
		'        "currency": "USD"'+
		'      },'+
		'      "baseType": "DEBIT",'+
		'      "categoryType": "EXPENSE",'+
		'      "categoryId": 19,'+
		'      "category": "Other Expenses",'+
		'      "categorySource": "SYSTEM",'+
		'      "description": {'+
		'        "original": "DESC",'+
		'        "simple": "DESC"'+
		'      },'+
		'      "date": "2017-03-14",'+
		'      "postDate": "2017-03-14",'+
		'      "transactionDate": "2017-03-12",'+
		'      "isManual": false,'+
		'      "status": "POSTED",'+
		'      "accountId": 10563602,'+
		'      "runningBalance": {'+
		'        "amount": 59,'+
		'        "currency": "USD"'+
		'      },'+
		'      "checkNumber": "DAG-333",'+
		'      "highLevelCategoryId": 10000009'+
		'    },'+
		'    {'+
		'      "CONTAINER": "bank",'+
		'      "id": 25335411,'+
		'      "type": "OTHER_DEPOSITS",'+
		'      "subType": "CREDIT",'+
		'      "amount": {'+
		'        "amount": 5646,'+
		'        "currency": "USD"'+
		'      },'+
		'      "baseType": "CREDIT",'+
		'      "categoryType": "INCOME",'+
		'      "categoryId": 32,'+
		'      "category": "Other Income",'+
		'      "categorySource": "SYSTEM",'+
		'      "description": {'+
		'        "original": "DESC",'+
		'        "simple": "DESC"'+
		'      },'+
		'      "date": "2017-03-10",'+
		'      "postDate": "2017-03-10",'+
		'      "transactionDate": "2017-03-11",'+
		'      "isManual": false,'+
		'      "status": "POSTED",'+
		'      "accountId": 10563602,'+
		'      "runningBalance": {'+
		'        "amount": 59,'+
		'        "currency": "USD"'+
		'      },'+
		'      "checkNumber": "DAG-233",'+
		'      "highLevelCategoryId": 10000012'+
		'    },'+
		'    {'+
		'      "CONTAINER": "bank",'+
		'      "id": 25335413,'+
		'      "type": "OTHER_DEPOSITS",'+
		'      "subType": "CREDIT",'+
		'      "amount": {'+
		'        "amount": 9846,'+
		'        "currency": "USD"'+
		'      },'+
		'      "baseType": "CREDIT",'+
		'      "categoryType": "INCOME",'+
		'      "categoryId": 32,'+
		'      "category": "Other Income",'+
		'      "categorySource": "SYSTEM",'+
		'      "description": {'+
		'        "original": "DESC",'+
		'        "simple": "DESC"'+
		'      },'+
		'      "date": "2017-03-02",'+
		'      "postDate": "2017-03-02",'+
		'      "transactionDate": "2017-03-16",'+
		'      "isManual": false,'+
		'      "status": "POSTED",'+
		'      "accountId": 10563602,'+
		'      "runningBalance": {'+
		'        "amount": 59,'+
		'        "currency": "USD"'+
		'      },'+
		'      "checkNumber": "DAG-333",'+
		'      "highLevelCategoryId": 10000012'+
		'    }'+
		'  ]'+
		'}';
    
    	
		GetTransactionContainer obj = GetTransactionContainer.parse(json);
		System.assert(obj != null);
	}
}