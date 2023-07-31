@isTest
global class MockYodleeTransactionAPICallOut1 implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req){
        String response ='{"bankAccounts":[{"refreshinfo":{"statusMessage":"154qw","statusCode":123,"nextRefreshScheduled":"121313","lastRefreshed":"Abc","lastRefreshAttempt":"123323"},"providerName":"TestProvider","providerId":"134534","providerAccountId":21,"lastUpdated":"Yes","isManual":true,"isAsset":true,"includeInNetWorth":true,"id":2,"holderProfile":[{"name":{"displayed":"Yes"}}],"currentBalance":{"currencyAmount":"123","amount":13213.21},"createdDate":"2013/10/13","CONTAINER":"Test","balance":{"currencyAmount":"123","amount":13213.21},"availableBalance":{"currencyAmount":"123","amount":13213.21},"aggregationSource":"Test","accountType":"Individual","accountStatus":"TestAccoun","accountNumber":"12345678903","accountName":"TestAccount"}]}';	//LOS-63	
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(response);
        res.setStatusCode(200);
        return res;

    } 
}