/* ****************Modification History******************
 * Class Name - TestYodleeWebServiceConstantsv1
 * Purpose - Test Class for YodleeWebServiceConstantsv1
 * Modified By        Date			Change
 *1. Shakul        2022/01/12     Added Assert statements
 ******************Modification History******************/
@isTest
public class TestYodleeWebServiceConstantsv1{
   testmethod static void method1(){
        //Creating custom setting
        ints__Yodlee_Cobrand_Credentials__c yodlee = ints__Yodlee_Cobrand_Credentials__c.getOrgdefaults();
        
        test.startTest();
        string str1 =YodleeWebServiceConstantsv1.HOST_URI;
        string str2 = YodleeWebServiceConstantsv1.USER_REGISTER_URL;
        string str3 = YodleeWebServiceConstantsv1.USER_UNREGISTER_URL;
        string str4 =YodleeWebServiceConstantsv1.USER_TRANSACTIONS_URI;
        string str5 =YodleeWebServiceConstantsv1.COB_LOGIN_URL;
        string str6 =YodleeWebServiceConstantsv1.USER_LOGIN_URL;
        string str7 =YodleeWebServiceConstantsv1.USER_ACCESS_TOKEN;
        string str8 =YodleeWebServiceConstantsv1.USER_ACCOUNT_SUMMARY;
        string str9 =YodleeWebServiceConstantsv1.HISTORICAL_BALANCES;
        string str10 =YodleeWebServiceConstantsv1.ACCOUNT_STATEMENTS;
        string str11 =YodleeWebServiceConstantsv1.paramNameNewUserLogin;
        string str12 =YodleeWebServiceConstantsv1.paramNameNewUserPassword;
        string str13 =YodleeWebServiceConstantsv1.paramNameInstanceType;
        string str14 =YodleeWebServiceConstantsv1.paramNameUserEmail;
        string str15 =YodleeWebServiceConstantsv1.paramNameCobSessionToken;
        string str16 =YodleeWebServiceConstantsv1.paramNameUserSessionToken;
        string str17 =YodleeWebServiceConstantsv1.paramNameCobrandLogin;
        string str18 =YodleeWebServiceConstantsv1.paramNameCobrandPassword;
        string str19 =YodleeWebServiceConstantsv1.paramNameUserLogin;
        string str20 =YodleeWebServiceConstantsv1.paramNameUserPassword;
        string str21 =YodleeWebServiceConstantsv1.paramNameLocale;
        string str22 =YodleeWebServiceConstantsv1.paramNameBridgetAppId;
        string str23 =YodleeWebServiceConstantsv1.paramNameSearchIdentifier;
        string str24 =YodleeWebServiceConstantsv1.paramNameRangeStartNumber;
        string str25 =YodleeWebServiceConstantsv1.paramNameRangeEndNumber;
        string str26 =YodleeWebServiceConstantsv1.paramNameContainer;
        string str27 =YodleeWebServiceConstantsv1.paramNamecontainerType;
        string str28 =YodleeWebServiceConstantsv1.paramNamehigherFetchLimit;
        string str29 =YodleeWebServiceConstantsv1.paramNamelowerFetchLimit;
        string str30 =YodleeWebServiceConstantsv1.paramNameendNumber;
        string str31 =YodleeWebServiceConstantsv1.paramNamestartNumber;
        string str32 =YodleeWebServiceConstantsv1.paramNameclientId;
        string str33 =YodleeWebServiceConstantsv1.paramNameclientName;
        string str34 =YodleeWebServiceConstantsv1.paramNamecurrencyCode;
        string str35 =YodleeWebServiceConstantsv1.paramNamefromDate;
        string str36 =YodleeWebServiceConstantsv1.paramNametoDate;
        string str37 =YodleeWebServiceConstantsv1.paramNametransactionSplitType;
        string str38 =YodleeWebServiceConstantsv1.paramNameignoreUserInput;
        string str39 =YodleeWebServiceConstantsv1.paramNameMemSiteAccId;
        test.stopTest();
        System.assertEquals('cobrandLogin', str17);
        System.assertEquals('statements', str10);
   }
}