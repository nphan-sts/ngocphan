/**
 * This class generates a bearer token held statically.
 * This won't persist between requests, but should work fine.
 * Retries to the server use the static access token after a successful response.
 *
 * Client Credentials Flow is a pain to implement in Salesforce.
 * This class is built to work to generate the authorization header
 * for the client_credentials grant for Happy Money's IDP.
 * Pass a service name from ints__OAuth_Settings__c and it does the rest
 */
public with sharing class MW_ClientCredentialsOAuthHelper {

    private static String tokenBody = 'grant_type=client_credentials&scope=HM';

    private static String accessToken = null;

    private static Integer RESPONSE_CODE_2XX = 2;

    @TestVisible
    private static Integer MAX_RETRY = 3;

    /**
     * Throw exception if no access token can be generated
     */
    public class ClientCredentialsException extends Exception {
    }

    /**
     * Parse the response
     */
    public class ClientCredentialsResponse {
        public String token_type {get; set;}
        public Integer expires_in {get; set;}
        public String access_token {get; set;}
    }

    /**
     * @param serviceName The integration name
     *
     * @return The string for the authorization header
     */
    public static String getBearerToken(String serviceName) {

        if (accessToken != null) {
            return accessToken;
        }

        List<ints__OAuth_Settings__c> oAuthSettings = getSettings(serviceName);
        if (oAuthSettings.isEmpty()) {
            throw new IllegalArgumentException('No ints__OAuth_Settings__c found for ' + serviceName);
        }

        ints__OAuth_Settings__c okta = oAuthSettings.get(0);
        getAccessToken(okta, 0);

        return accessToken;
    }

    private static void getAccessToken(ints__OAuth_Settings__c okta, Integer retryCount) {

        if (retryCount >= MAX_RETRY) {
            throw new ClientCredentialsException('Unable to produce access token after retries: ' + MAX_RETRY);
        }

        String header = okta.ints__Consumer_Key__c + ':' + okta.ints__Consumer_Secret__c;
        String authHeader = EncodingUtil.base64Encode(Blob.valueOf(header));

        HttpRequest req = new HttpRequest();
        req.setEndpoint(okta.ints__Access_Token_URL__c);
        req.setHeader('Authorization', 'Basic ' + authHeader);
        req.setTimeout(5 * 1000);
        req.setMethod('POST');
        req.setBody(tokenBody);

        Http http = new Http();
        HttpResponse res = http.send(req);
        Integer code = res.getStatusCode();

        if (code / 100 != RESPONSE_CODE_2XX) {
            getAccessToken(okta, ++retryCount);
        }

        ClientCredentialsResponse ccr = (ClientCredentialsResponse) JSON.deserialize(res.getBody(), ClientCredentialsResponse.class);

        accessToken = ccr.access_token;
    }

    /**
     * @param serviceName The name to uniquely identify the oauth integration
     *
     * @return The list of instances (should be only 1)
     */
    private static List<ints__OAuth_Settings__c> getSettings(String serviceName) {
        return [SELECT Id,
                        ints__Access_Token_URL__c,
                        ints__Authorization_URL__c,
                        ints__Consumer_Key__c,
                        ints__Consumer_Secret__c,
                        Name,
                        ints__Request_Token_URL__c,
                        ints__Service_Name__c
                FROM   ints__OAuth_Settings__c
                WHERE ints__Service_Name__c = :serviceName];
    }
}