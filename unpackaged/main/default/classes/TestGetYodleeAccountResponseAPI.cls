/* ****************Modification History******************
 * Class Name - TestGetYodleeAccountResponseAPI
 * Purpose - Test Class for GetYodleeAccountResponseAPI
 * Modified By        Date			Change
 *1. Shakul        2022/01/12     Added Assert statements and enclosed the test logic within Test.startTest and Test.stopTest
 ******************Modification History******************/
@isTest

private class TestGetYodleeAccountResponseAPI{
    Testmethod static void method1(){
        Test.startTest();
        String json= '{"bankAccounts":[{"refreshinfo":{"statusMessage":"154qw","statusCode":123,"nextRefreshScheduled":"121313","lastRefreshed":"Abc","lastRefreshAttempt":"123323"},"providerName":"TestProvider","providerId":"134534","providerAccountId":21,"lastUpdated":"Yes","isManual":true,"isAsset":true,"includeInNetWorth":true,"id":2,"holderProfile":[{"name":{"displayed":"Yes"}}],"currentBalance":{"currencyAmount":"123","amount":13213.21},"createdDate":"2013/10/13","CONTAINER":"Test","balance":{"currencyAmount":"123","amount":13213.21},"availableBalance":{"currencyAmount":"123","amount":13213.21},"aggregationSource":"Test","accountType":"Individual","accountStatus":"TestAccountStatus","accountNumber":"12345678903","accountName":"TestAccount"}]}';
        GetYodleeAccountResponseAPI result = GetYodleeAccountResponseAPI.parse(json);
        Test.stopTest();
        System.assertEquals('TestProvider',result.bankAccounts[0].providerName);
    }
}