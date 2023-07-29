@isTest
public with sharing class MW_WebhookHelperTest {

    static testMethod void selectedCreditPolicyDetailsTest() {
        Test.startTest();
        List<account> accList = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        List<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        Credit_Policy__c testCP = new Credit_Policy__c();
        testCP.Application__c = appList[0].Id;
        testCP.Name = 'test Credit Policy';
        insert testCP;

        Map<Id, Credit_Policy__c> helperResult = MW_WebhookHelper.selectedCreditPolicyDetails(new Set<String>{applist[0].id});
        System.assertEquals(1, helperResult.size());
        Test.stopTest();
    }

    static testMethod void appQueueDetailsTest(){
        Test.startTest();
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;

        System.runAs(new User(Id=UserInfo.getUserId()))
        {
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.Id, SObjectType = 'genesis__Applications__c');
        insert testQueue;
        }
        Map<String, String> appQueueResult = MW_WebhookHelper.appQueueDetails();
        System.assertEquals(true, appQueueResult.size()>0);
        Test.stopTest();
    }

    static testMethod void applicationDocumentCatTest(){
        Test.startTest();
        List<account> accList = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        List<id> accLis = new List<id>();
        accLis.add(accList[0].Id);
        List<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        appList[0].agentVerificationPendingFlag__c = false;
        insert appList;

        genesis__Application_Document_Category__c appDocCategoryObj = new genesis__Application_Document_Category__c();
        appDocCategoryObj.Name = 'test';
        appDocCategoryObj.genesis__Required__c = true;
        appDocCategoryObj.genesis__Application__c = appList[0].Id;
        genesis__Application_Document_Category__c appDocCategoryObj2 = new genesis__Application_Document_Category__c();
        appDocCategoryObj.Name = 'test2';
        appDocCategoryObj.genesis__Required__c = true;
        appDocCategoryObj.genesis__Application__c = appList[0].Id;
        List<genesis__Application_Document_Category__c> appDocCategoryList = new List<genesis__Application_Document_Category__c>();
        appDocCategoryList.add(appDocCategoryObj);
        appDocCategoryList.add(appDocCategoryObj2);
        insert appDocCategoryList;
        Map<Id, Integer> applicationDocumentCatResult = MW_WebhookHelper.applicationDocumentCat(new List<String>{appList[0].Id});
        System.assertEquals(1, applicationDocumentCatResult.size());
        applicationDocumentCatResult = MW_WebhookHelper.applicationDocumentCat(new List<String>{appList[0].Id});
        System.assertEquals(1, applicationDocumentCatResult.get(appDocCategoryObj.genesis__Application__c));
        MW_WebhookHelper.updateBankApplicationDocCat(accLis);
        Test.stopTest();
    }

    static testMethod void applicationHasYodleeDetailsTest(){
        Test.startTest();
        List<account> accList = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        ints__Yodlee_User_Credentials__c yodleeUserCredentialTest = new ints__Yodlee_User_Credentials__c();
        yodleeUserCredentialTest.ints__Account__c = accList[0].Id;
        yodleeUserCredentialTest.ints__Yodlee_Username__c = 'testUser';
        yodleeUserCredentialTest.ints__Yodlee_Password__c = 'testPassword';
        yodleeUserCredentialTest.yodlee_Account_count__c =1;
        insert yodleeUserCredentialTest;
        Map<Id, boolean> applicationHasYodleeDetailsResult = MW_WebhookHelper.applicationHasYodleeDetails(new List<String>{accList[0].Id});
        System.assertEquals(1, applicationHasYodleeDetailsResult.size());
        Test.stopTest();
    }
}