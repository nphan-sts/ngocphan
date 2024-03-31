/**
 * Created by ilazarte on 3/11/22.
 */

@IsTest
private class MW_ClientCredentialsOAuthHelperTest {

    private static final String OKTA_TEST_SERVICE_NAME = 'Okta Test';

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
        okta.ints__Service_Name__c = OKTA_TEST_SERVICE_NAME;
        insert okta;
    }

    @IsTest
    static void request_handlesResponse_200() {

        Test.setMock(HttpCalloutMock.class, new ClientCredentialsMock());
        Test.startTest();

        String bearerToken = MW_ClientCredentialsOAuthHelper.getBearerToken(OKTA_TEST_SERVICE_NAME);

        Test.stopTest();

        System.assertEquals('accesstokenvalue', bearerToken);
        System.assertEquals('accesstokenvalue', MW_ClientCredentialsOAuthHelper.getBearerToken(OKTA_TEST_SERVICE_NAME));
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
            MW_ClientCredentialsOAuthHelper.getBearerToken(OKTA_TEST_SERVICE_NAME);
        } catch (MW_ClientCredentialsOAuthHelper.ClientCredentialsException e) {
            System.assertEquals(MW_ClientCredentialsOAuthHelper.MAX_RETRY, mock.attempts);
        }

        Test.stopTest();
    }

    @IsTest
    static void request_ClientCrendentialsCreatedAndUpdated() {

        Test.setMock(HttpCalloutMock.class, new ClientCredentialsMock());
        Test.startTest();

        MW_ClientCredentialsOAuthHelper.getBearerToken(OKTA_TEST_SERVICE_NAME);
        MW_ClientCredentialsOAuthHelper.accessToken = null;
        MW_ClientCredentialsOAuthHelper.getBearerToken(OKTA_TEST_SERVICE_NAME);
        MW_ClientCredentialsOAuthHelper.commitToken();
        MW_ClientCredentialsOAuthHelper.commitToken();

        List<ints__OAuth_Token__c> oAuthTokens = getTokens();

        Test.stopTest();

        System.assert(oAuthTokens != null);
        System.assert(oAuthTokens.size() == 1);

        ints__OAuth_Token__c oAuthToken = oAuthTokens.get(0);
        System.assertEquals('accesstokenvalue', oAuthToken.Token_Large__c);
        System.assertEquals(3600, oAuthToken.Valid_Time__c);
    }

    /**
     * More a coverage test, confirm the load access test returns t/f in token scenarios
     */
    @IsTest
    static void method_loadAccessToken() {

        ints__OAuth_Settings__c settings = [
                SELECT Id
                FROM ints__OAuth_Settings__c
                WHERE ints__Service_Name__c = :OKTA_TEST_SERVICE_NAME
                LIMIT 1
        ];

        ints__OAuth_Token__c oAuthToken = new ints__OAuth_Token__c();
        oAuthToken.ints__OAuth_Settings__c = settings.Id;
        oAuthToken.Token_Large__c = 'faketoken';
        oAuthToken.Valid_Time__c = null;
        insert oAuthToken;

        System.assert(!MW_ClientCredentialsOAuthHelper.loadAccessToken(settings));

        oAuthToken.Valid_Time__c = 3600;
        update oAuthToken;

        System.assert(MW_ClientCredentialsOAuthHelper.loadAccessToken(settings));

        oAuthToken.Valid_Time__c = -3600;
        update oAuthToken;

        System.assert(!MW_ClientCredentialsOAuthHelper.loadAccessToken(settings));
    }
    static List<ints__OAuth_Token__c> getTokens() {
        return [
                SELECT Id,
                        Token_Large__c,
                        Valid_Time__c
                FROM ints__OAuth_Token__c
        ];
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