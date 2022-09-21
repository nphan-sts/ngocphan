@isTest
private class MW_NeoVerifyIntegrationTest {

    @testSetup static void setup() {
        list<account> accList                  = MW_DataFactoryTest.createAccounts(1);
        accList[0].loan__SOCIAL_SECURITY_NUMBER__c = '6831540283';
        accList[0].loan__Investor__c=true;
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;
        MW_Settings__c mwSetting = new MW_Settings__c();
        mwSetting.Neoverify_APIkey__c = 'testapikey';
        insert mwSetting;
 

        Yodlee_User_Transaction__c sobj = new Yodlee_User_Transaction__c(
            Transaction_Date__c = system.Today(),
            Balance__c = 10.00,                                                                          // Balance
            Description__c = 'Debit transction for Goal',                                               // Description
            Category__c = 'Other Expenses',                                                             // Category
            Yodlee_Account__c = accList[0].id,                                                      // Yodlee Account
            Transaction_Type__c = 'DEBIT',                                                              // Transaction Type
            Debit__c = 8000.00,                                                                         // Debit
            isLatest__c = true,                                                                         // isLatest
            Yodlee_Application__c=appList[0].Id
            );
        insert sobj;

        Yodlee_User_Transaction__c sobj1 = new Yodlee_User_Transaction__c(
            Transaction_Date__c = system.Today(),
            Balance__c = 10.00,                                                                          // Balance
            Description__c = 'Debit transction for Goal',                                               // Description
            Category__c = 'Other Expenses',                                                             // Category
            Yodlee_Account__c = accList[0].id,                                                      // Yodlee Account
            Transaction_Type__c = 'DEBIT',                                                              // Transaction Type
            Debit__c = 8000.00,                                                                         // Debit
            isLatest__c = true,                                                                         // isLatest
            Yodlee_Application__c=appList[0].Id
            );
        insert sobj1;

        Yodlee_User_Account__c sobj22 = new Yodlee_User_Account__c(
            Name = 'TESTDATA-txn DUNKIN',                                              // Yodlee User Accounts Name
            Account_Number__c = '5031123456',                                            // Account Number
            Account_Holder_Name__c = 'accountHolder',                                    // Account Holder Name
            Available_Balance__c = 404.78,                                               // Available Balance
            Current_Balance__c = 304.78,                                                 // Current Balance
            Account_Type__c = 'CHECKING',                                                // Account Type
            Status__c = 'ACTIVE',                                                        // Status
            Yodlee_Application__c=appList[0].Id,
            Yodlee_Account__c= accList[0].id
            );
        insert sobj22;

        Attachment attach = new Attachment();
        attach.Name = appList[0].Id+'linked_acct_';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = appList[0].Id;
        insert attach;
    }

    @isTest static void testNeoVerifyTransactionQueue() {
        Test.startTest();
        Set<Id> alist = new Set<Id>();
        for(genesis__Applications__c app:[select Id from genesis__Applications__c limit 99]) {
            alist.add(app.id);
        }
        Id jobId = System.enqueueJob(new MW_NeoVerifyTransactionsCalloutQueue(alist));
        MW_Callout__c newCalloutJob = new MW_Callout__c();
        newCalloutJob.JobID__c = jobId;
        newCalloutJob.Status__c = 'Queued';
        insert newCalloutJob;
        Test.stopTest();
    }

    @isTest static void testMethod1() {
        test.StartTest();
        genesis__Applications__c aapp = [select Id from genesis__Applications__c];
        NeoVeifyRequestDetails ff = new NeoVeifyRequestDetails();
        ff.linkAccountTransactions(aapp.id, '1232312');
        test.StopTest();
    }


    @isTest static void testCallout() {

        Set<Id> alist = new Set<Id>();
        for(genesis__Applications__c app:[select Id from genesis__Applications__c limit 99]) {
            alist.add(app.id);
        }
        String xmlString ='{ "report_id": "SL2Mq6jtrCuirj7OiiS5FcM85","url": "https://payofftest.neoverify.com/income_verification/SL2Mq6jtrCuirj7OiiS5FcM85"}';
        Test.setMock(HttpCalloutMock.class, new MW_NeoVerifyIntegrationHttpCalloutMock(xmlString, 201));
        MW_NeoVerifyIntegration.postRegNeoVerify(alist);
    }

    @isTest static void testCalloutFail() {

        Set<Id> alist = new Set<Id>();
        for(genesis__Applications__c app:[select Id from genesis__Applications__c limit 99]) {
            alist.add(app.id);
        }
        String xmlString ='{ "report_id": "","url": "https://payofftest.neoverify.com/income_verification/SL2Mq6jtrCuirj7OiiS5FcM85"}';
        Test.setMock(HttpCalloutMock.class, new MW_NeoVerifyIntegrationHttpCalloutMock(xmlString, 200));
        MW_NeoVerifyIntegration.postRegNeoVerify(alist);
    }

    @isTest static void testCalloutFail2() {
		test.startTest();
        Set<Id> alist = new Set<Id>();
        for(genesis__Applications__c app:[select Id from genesis__Applications__c limit 99]) {
            alist.add(app.id);
        }
        String xmlString ='{ "report_id": 123456,"url": "https://payofftest.neoverify.com/income_verification/SL2Mq6jtrCuirj7OiiS5FcM85"}';
        Test.setMock(HttpCalloutMock.class, new MW_NeoVerifyIntegrationHttpCalloutMock(xmlString, 200));
        MW_NeoVerifyIntegration.postRegNeoVerify(alist);
        test.stopTest();
    }

    @isTest static void postlinkAccountTransactionsTest(){
        test.startTest();
        List<Attachment> aList = [select id, name, body, parentId from Attachment limit 99];
        Test.setMock(HttpCalloutMock.class, new MW_NeoVerifyIntegrationHttpCalloutMock('test response', 202));
        MW_NeoVerifyIntegration.postlinkAccountTransactions(aList[0].id, 'SL2Mq6jtrCuirj7OiiS5FcM85');
        test.stopTest();
    }

    @isTest static void testReportStatusFail() {

        List<ID> alist = new List<ID>();

        for(genesis__Applications__c app:[select Id from genesis__Applications__c limit 99]) {
            alist.add(app.id);
        }
        //StaticResource sr = [select Body from StaticResource where Name='neoVerify' limit 1];
        String xmlString = '{"report_status": {"status": "Report Ready","report_id": "ouztd12PRze8dYnceQ4eQAgBd"}}';//sr.Body.toString();

        Test.setMock(HttpCalloutMock.class, new MW_NeoVerifyIntegrationHttpCalloutMock(xmlString, 200));
        MW_NeoVerifyIntegration.processNeoVerifyReport(alist);
        //MW_NeoVerifyIntegration.getReportStatus(alist[0]);
    }

    @isTest static void testReportSta() {
		test.startTest();
        List<ID> alist = new List<ID>();

        for(genesis__Applications__c app:[select Id from genesis__Applications__c limit 99]) {
            alist.add(app.id);
        }

        String xmlString ='{ "Employments": [{"employer": "Report Ready","first_pay_date1": "ouztd12PRze8dYnceQ4eQAgBd","last_pay_date1":"45454","paychecks":1,"avg_paycheck":"1.0","pay_cycle":"monthly","next_day_date1":"45454","total_earnings":"1.0"}]}';

        Test.setMock(HttpCalloutMock.class, new MW_NeoVerifyIntegrationHttpCalloutMock(xmlString, 200));
        MW_NeoVerifyIntegration.Neoverifyfuturemethod(alist[0]);
        test.stoptest();
    }
    @isTest static void testscorecardtrigger() {
        
         list<account> accList                  = MW_DataFactoryTest.createAccounts(1);
         insert accList;
         list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
         insert appList;
 
         Neo_Verify__c no = new Neo_Verify__c(
         Application__c = appList[0].Id,
         NSF_OD__c = '1');
         insert no;
        }
    @isTest static void postCreateRegisterUserRequestTest(){
        Set<Id> alist = new Set<Id>();
        for(genesis__Applications__c app:[select Id from genesis__Applications__c limit 99]) {
            alist.add(app.id);
        }
        String xmlString ='{ "report_id": "","url": "https://payofftest.neoverify.com/income_verification/SL2Mq6jtrCuirj7OiiS5FcM85"}';
        Test.setMock(HttpCalloutMock.class, new MW_NeoVerifyIntegrationHttpCalloutMock(xmlString, 200));
        MW_NeoVerifyIntegration.postCreateRegisterUserRequest([select Id from genesis__Applications__c limit 1].id);
        
    }

}