/**
 * Created by ilazarte on 3/11/22.
 */

@IsTest
private class MW_ClientCredentialsOAuthHelperTest {

    public class ClientCredentialsMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest httpRequest) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"token_type":"Bearer","expires_in":3600,"access_token":"accesstokenvalue","scope":"HM"}');
            res.setStatusCode(200);
            return res;
        }
    }

    public class ClientCredentialsErrorMock implements HttpCalloutMock {
        public Integer attempts = 0;
        public HttpResponse respond(HttpRequest httpRequest) {
            attempts++;
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(500);
            return res;
        }
    }

    @TestSetup
    static void setup() {
        ints__OAuth_Settings__c okta = new ints__OAuth_Settings__c();
        okta.ints__Consumer_Key__c = 'aclientid';
        okta.ints__Consumer_Secret__c = 'aclientsecret';
        okta.ints__Access_Token_URL__c = 'https://remotesite/v1/token';
        okta.ints__Service_Name__c = 'Okta Test';
        insert okta;
    }

    @IsTest
    static void request_handlesResponse_200() {

        Test.setMock(HttpCalloutMock.class, new ClientCredentialsMock());
        Test.startTest();

        String bearerToken = MW_ClientCredentialsOAuthHelper.getBearerToken('Okta Test');

        Test.stopTest();

        System.assertEquals('accesstokenvalue', bearerToken);
        System.assertEquals('accesstokenvalue', MW_ClientCredentialsOAuthHelper.getBearerToken('Okta Test'));
    }

    /**
     * Assert that unless we receive a 200, any other response code causes a retry
     */
    @IsTest
    static void request_invalidResponseCode_throwsClientCredentialsException() {
        ClientCredentialsErrorMock mock = new ClientCredentialsErrorMock();

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();

        try {
            MW_ClientCredentialsOAuthHelper.getBearerToken('Okta Test');
        } catch (MW_ClientCredentialsOAuthHelper.ClientCredentialsException e) {
            System.assertEquals(MW_ClientCredentialsOAuthHelper.MAX_RETRY, mock.attempts);
        }

        Test.stopTest();
    }

    @IsTest
    static void request_invalidName_throwsException() {
        try {
            MW_ClientCredentialsOAuthHelper.getBearerToken('Non-existing');
        } catch (IllegalArgumentException e) {
            System.assertEquals('No ints__OAuth_Settings__c found for Non-existing', e.getMessage());
        }
    }
}