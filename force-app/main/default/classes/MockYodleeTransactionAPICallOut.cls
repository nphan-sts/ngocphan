@isTest
global class MockYodleeTransactionAPICallOut implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req){
        String response =		'{'+
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
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(response);
        res.setStatusCode(200);
        return res;

    } 
}