/**
 * Contains all the Constants that are going to be used for 
 * Yodlee Web Services.
 * Class: YodleeWebService.
 * 
 * @author - Sagar Hinsu
 **/
global class YodleeWebServiceConstantsv1 {

    /**Do not allow accidental instantiation of this class.**/
    private YodleeWebServiceConstantsv1(){}
    
    /**Host URL**/
    global static String HOST_URI;
    static{
        //Sample URL: https://developer.yodlee.com/services/restserver/v1/
        HOST_URI = ints__Yodlee_Cobrand_Credentials__c.getInstance().ints__Rest_URL__c;
    }
    
    global static String USER_REGISTER_URL = 'user/register';
    global static String USER_UNREGISTER_URL ='user/unregister';
    //global static String OAUTH_TOKEN_URI = 'jsonsdk/OAuthAccessTokenManagementService/getOAuthAccessToken';
    global static String USER_TRANSACTIONS_URI = 'transactions';
    //global static String USER_SEARCH_REQUEST_URI = 'jsonsdk/TransactionSearchService/executeUserSearchRequest';
    global static String COB_LOGIN_URL = 'cobrand/login';
    global static String USER_LOGIN_URL = 'user/login';
    global static String USER_ACCESS_TOKEN = 'user/accessToken';
    global static String USER_ACCOUNT_SUMMARY = 'account/summary/all';
    //global static String ALL_STIE_ACCOUNTS = '/jsonsdk/SiteAccountManagement/getAllSiteAccounts';
    //global static String ITEM_SUMMARIES_FOR_SITE = '/jsonsdk/DataService/getItemSummariesForSite';
    global static String HISTORICAL_BALANCES = 'accounts/historicalBalances';
    global static String ACCOUNT_STATEMENTS = 'statements';
    
    //Create cobrand credentials API parameters
    global static String paramNameNewUserLogin = 'userCredentials.loginName';
    global static String paramNameNewUserPassword = 'userCredentials.password';
    global static String paramNameInstanceType = 'userCredentials.objectInstanceType';
    global static String paramNameUserEmail = 'userProfile.emailAddress';
    
    //Common parameters for all APIs except for cobrand login or cobrand creation APIs
    global static String paramNameCobSessionToken = 'cobSessionToken';
    global static String paramNameUserSessionToken = 'userSessionToken';
    
    //Cobrand login API parameters
    global static String paramNameCobrandLogin = 'cobrandLogin';
    global static String paramNameCobrandPassword = 'cobrandPassword';

    //User login API parameters
    global static String paramNameUserLogin = 'loginName';
    global static String paramNameUserPassword = 'password';
    global static String paramNameLocale = 'locale';
    
    //OAuth API parameters.
    global static String paramNameBridgetAppId = 'bridgetAppId';
    
    //User Transactions API parameters.
    global static String paramNameSearchIdentifier = 'searchFetchRequest.searchIdentifier.identifier';
    global static String paramNameRangeStartNumber = 'searchFetchRequest.searchResultRange.startNumber';
    global static String paramNameRangeEndNumber = 'searchFetchRequest.searchResultRange.endNumber';
    global static String paramNameContainer = 'container';
    
    global static String paramNamecontainerType = 'transactionSearchRequest.containerType';
    global static String paramNamehigherFetchLimit = 'transactionSearchRequest.higherFetchLimit';
    global static String paramNamelowerFetchLimit = 'transactionSearchRequest.lowerFetchLimit';
    global static String paramNameendNumber = 'transactionSearchRequest.resultRange.endNumber';
    global static String paramNamestartNumber = 'transactionSearchRequest.resultRange.startNumber';
    global static String paramNameclientId = 'transactionSearchRequest.searchClients.clientId';
    global static String paramNameclientName = 'transactionSearchRequest.searchClients.clientName';
    global static String paramNamecurrencyCode = 'transactionSearchRequest.searchFilter.currencyCode';
    global static String paramNamefromDate = 'transactionSearchRequest.searchFilter.postDateRange.fromDate';
    global static String paramNametoDate = 'transactionSearchRequest.searchFilter.postDateRange.toDate';
    global static String paramNametransactionSplitType = 'transactionSearchRequest.searchFilter.transactionSplitType';
    global static String paramNameignoreUserInput = 'transactionSearchRequest.ignoreUserInput';
    
    // Site based
    global static String paramNameMemSiteAccId = 'memSiteAccId';
}