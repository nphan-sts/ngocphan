@isTest

private class TestGetYodleeAccountResponseAPI{
    Testmethod static void method1(){
        String json= '{"bankAccounts":[{"refreshinfo":{"statusMessage":"154qw","statusCode":123,"nextRefreshScheduled":"121313","lastRefreshed":"Abc","lastRefreshAttempt":"123323"},"providerName":"TestProvider","providerId":"134534","providerAccountId":21,"lastUpdated":"Yes","isManual":true,"isAsset":true,"includeInNetWorth":true,"id":2,"holderProfile":[{"name":{"displayed":"Yes"}}],"currentBalance":{"currencyAmount":"123","amount":13213.21},"createdDate":"2013/10/13","CONTAINER":"Test","balance":{"currencyAmount":"123","amount":13213.21},"availableBalance":{"currencyAmount":"123","amount":13213.21},"aggregationSource":"Test","accountType":"Individual","accountStatus":"TestAccountStatus","accountNumber":"12345678903","accountName":"TestAccount"}]}';
        GetYodleeAccountResponseAPI.parse(json);
    }
}