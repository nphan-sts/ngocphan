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

    private static final String tokenBody = 'grant_type=client_credentials&scope=HM';

    private static final Integer RESPONSE_CODE_2XX = 2;

    @TestVisible
    private static String accessToken = null;

    private static ClientCredentialsResponse clientCredentialsResponse;

    private static Id oAuthSettingsId;

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
     * @return The string for the auth header
     */
    public static String getBearerToken(String serviceName) {
        return getBearerToken(serviceName, false);
    }

    /**
     * @param serviceName Integration name
     * @param force       Force retrieval of a new token
     *
     * @return the string for the auth header
     */
    public static String getBearerToken(String serviceName, Boolean force) {

        if (!force && accessToken != null) {
            return accessToken;
        }

        List<ints__OAuth_Settings__c> oAuthSettings = getSettings(serviceName);
        if (oAuthSettings.isEmpty()) {
            throw new IllegalArgumentException('No ints__OAuth_Settings__c found for ' + serviceName);
        }

        ints__OAuth_Settings__c okta = oAuthSettings.get(0);

        if (!force && loadAccessToken(okta)) {
            return accessToken;
        }

        getAccessToken(okta, 0);

        return accessToken;
    }

    /**
     * Retrieve the client credentials value.  Set to static variables if succeeds to commit later.
     * @param oAuthSettings The oauth settings to use
     * @param retryCount The retry count currently
     */
    private static void getAccessToken(ints__OAuth_Settings__c oAuthSettings, Integer retryCount) {

        if (retryCount >= MAX_RETRY) {
            System.debug(LoggingLevel.ERROR, 'CCH: EXITING MAX RETRY getAccessToken');
            throw new ClientCredentialsException('Unable to produce access token after retries: ' + MAX_RETRY);
        }

        String header = oAuthSettings.ints__Consumer_Key__c + ':' + oAuthSettings.ints__Consumer_Secret__c;
        String authHeader = EncodingUtil.base64Encode(Blob.valueOf(header));

        HttpRequest req = new HttpRequest();
        req.setEndpoint(oAuthSettings.ints__Access_Token_URL__c);
        req.setHeader('Authorization', 'Basic ' + authHeader);
        req.setTimeout(5 * 1000);
        req.setMethod('POST');
        req.setBody(tokenBody);

        Http http = new Http();
        HttpResponse res = http.send(req);
        Integer code = res.getStatusCode();

        if (code / 100 != RESPONSE_CODE_2XX) {
            getAccessToken(oAuthSettings, ++retryCount);
        }

        ClientCredentialsResponse ccr = (ClientCredentialsResponse) JSON.deserialize(res.getBody(), ClientCredentialsResponse.class);

        accessToken = ccr.access_token;
        oAuthSettingsId = oAuthSettings.Id;
        clientCredentialsResponse = ccr;
    }

    /**
     * A successful token retrieval from the Okta should be saved
     * It's not saved immediately after retrieving since client code might need to execute a callout first
     * This is the classic 'you have uncommited work' exception.
     * Client code should always call this after all callouts are complete on the request.
     */
    public static void commitToken() {

        if (oAuthSettingsId == null || clientCredentialsResponse == null) {
            return;
        }

        List<ints__OAuth_Token__c> tokens = findAccessToken(oAuthSettingsId);
        if (tokens.isEmpty()) {
            ints__OAuth_Token__c oAuthToken = new ints__OAuth_Token__c();
            oAuthToken.ints__OAuth_Settings__c = oAuthSettingsId;
            oAuthToken.Token_Large__c = clientCredentialsResponse.access_token;
            oAuthToken.Valid_Time__c = clientCredentialsResponse.expires_in;
            insert oAuthToken;
        } else {
            ints__OAuth_Token__c oAuthToken = tokens.get(0);
            oAuthToken.Token_Large__c = clientCredentialsResponse.access_token;
            oAuthToken.Valid_Time__c = clientCredentialsResponse.expires_in;
            update oAuthToken;
        }

        Map<String, String> msg = new Map<String, String>();
        msg.put('message', 'HM Okta client credentials access token issued.  Expires in ' + clientCredentialsResponse.expires_in + ' seconds.');
        MW_LogUtility.infoMessage('MW_ClientCredentialsOAuthHelper', 'commitToken', msg);
    }

    /**
     * @param okta the Settings instance
     *
     * @return true if was able to load
     */
    @TestVisible
    private static Boolean loadAccessToken(ints__OAuth_Settings__c okta) {

        List<ints__OAuth_Token__c> oAuthTokens = findAccessToken(okta.Id);

        if (oAuthTokens.isEmpty()) {
            return false;
        }

        ints__OAuth_Token__c oAuthToken = oAuthTokens.get(0);

        Decimal validTime = oAuthToken.Valid_Time__c;
        if (validTime == null) {
            return false;
        }

        Datetime expiration = oAuthToken.LastModifiedDate.addSeconds(validTime.intValue());
        if (Datetime.now() < expiration) {
            accessToken = oAuthToken.Token_Large__c;
            return true;
        }

        return false;
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

    /**
     * @param oAuthSettingsId the settings id
     *
     * @return The tokens loaded if any
     */
    private static List<ints__OAuth_Token__c> findAccessToken(Id oAuthSettingsId) {
        return [
                SELECT Id,
                       Token_Large__c,
                       Valid_Time__c,
                       LastModifiedDate
                FROM   ints__OAuth_Token__c
                WHERE  ints__OAuth_Settings__c =: oAuthSettingsId
        ];
    }
}