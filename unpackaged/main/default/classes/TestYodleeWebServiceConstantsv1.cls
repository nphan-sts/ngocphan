/* ****************Modification History******************
 * Class Name - TestYodleeWebServiceConstantsv1
 * Purpose - Test Class for YodleeWebServiceConstantsv1
 * Modified By        Date			Change
 *1. Shakul        2022/01/12     Added Assert statements
 ******************Modification History******************/
@isTest
public class TestYodleeWebServiceConstantsv1{
   testmethod static void testYodleeWSConstants(){
        //Creating custom setting
        ints__Yodlee_Cobrand_Credentials__c.getOrgdefaults();
        
        Test.startTest();
        String host_uri = YodleeWebServiceConstantsv1.HOST_URI;
        String user_Register_url = YodleeWebServiceConstantsv1.USER_REGISTER_URL;
        String user_unregister_url = YodleeWebServiceConstantsv1.USER_UNREGISTER_URL;
        String user_transactions_uri = YodleeWebServiceConstantsv1.USER_TRANSACTIONS_URI;
        String cob_login_url = YodleeWebServiceConstantsv1.COB_LOGIN_URL;
        String user_login_url = YodleeWebServiceConstantsv1.USER_LOGIN_URL;
        String user_access_token = YodleeWebServiceConstantsv1.USER_ACCESS_TOKEN;
        String user_account_summary = YodleeWebServiceConstantsv1.USER_ACCOUNT_SUMMARY;
        String historical_balances = YodleeWebServiceConstantsv1.HISTORICAL_BALANCES;
        String account_statements = YodleeWebServiceConstantsv1.ACCOUNT_STATEMENTS;
        String paramNameNewUserLogin = YodleeWebServiceConstantsv1.paramNameNewUserLogin;
        String paramNameNewUserPassword = YodleeWebServiceConstantsv1.paramNameNewUserPassword;
        String paramNameInstanceType = YodleeWebServiceConstantsv1.paramNameInstanceType;
        String paramNameUserEmail = YodleeWebServiceConstantsv1.paramNameUserEmail;
        String paramNameCobSessionToken = YodleeWebServiceConstantsv1.paramNameCobSessionToken;
        String paramNameUserSessionToken = YodleeWebServiceConstantsv1.paramNameUserSessionToken;
        String paramNameCobrandLogin = YodleeWebServiceConstantsv1.paramNameCobrandLogin;
        String paramNameCobrandPassword = YodleeWebServiceConstantsv1.paramNameCobrandPassword;
        String paramNameUserLogin = YodleeWebServiceConstantsv1.paramNameUserLogin;
        String paramNameUserPassword = YodleeWebServiceConstantsv1.paramNameUserPassword;
        String paramNameLocale = YodleeWebServiceConstantsv1.paramNameLocale;
        String paramNameBridgetAppId = YodleeWebServiceConstantsv1.paramNameBridgetAppId;
        String paramNameSearchIdentifier = YodleeWebServiceConstantsv1.paramNameSearchIdentifier;
        String paramNameRangeStartNumber = YodleeWebServiceConstantsv1.paramNameRangeStartNumber;
        String paramNameRangeEndNumber = YodleeWebServiceConstantsv1.paramNameRangeEndNumber;
        String paramNameContainer = YodleeWebServiceConstantsv1.paramNameContainer;
        String paramNamecontainerType = YodleeWebServiceConstantsv1.paramNamecontainerType;
        String paramNameHigherFetchLimit = YodleeWebServiceConstantsv1.paramNamehigherFetchLimit;
        String paramNamelowerFetchLimit = YodleeWebServiceConstantsv1.paramNamelowerFetchLimit;
        String paramNameEndNumber = YodleeWebServiceConstantsv1.paramNameendNumber;
        String paramNameStartNumber = YodleeWebServiceConstantsv1.paramNamestartNumber;
        String paramNameClientId = YodleeWebServiceConstantsv1.paramNameclientId;
        String paramNameClientName = YodleeWebServiceConstantsv1.paramNameclientName;
        String paramNameCurrencyCode = YodleeWebServiceConstantsv1.paramNamecurrencyCode;
        String paramNameFromDate = YodleeWebServiceConstantsv1.paramNamefromDate;
        String paramNameToDate = YodleeWebServiceConstantsv1.paramNametoDate;
        String paramNameTransactionSplitType = YodleeWebServiceConstantsv1.paramNametransactionSplitType;
        String paramNameIgnoreUserInput = YodleeWebServiceConstantsv1.paramNameignoreUserInput;
        String paramNameMemSiteAccId = YodleeWebServiceConstantsv1.paramNameMemSiteAccId;
        Test.stopTest();
   }
}