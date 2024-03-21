@isTest
public with sharing class NightlyDynamicAlertJobTest {
    final static String SUCCESS = 'Success';
    final static String FAILURE = 'Failure';

    @testSetup
    private static void testSetup() {
        MW_Settings__c setting = MW_GlobalTestUtility.GetSettings();
        setting.Slack_mentions_for_Nacha_alert__c = 'test@user.com,test1@user.com';
        setting.Slack_mentions_for_loan_ops__c = 'test@user.com,test1@user.com';
        setting.lsp_team_slack_channel_webhook__c = 'lsp_team_slack_channel_webhook__c';
        setting.loan_ops_slack_channel_webhook__c = 'loan_ops_slack_channel_webhook__c';
        insert setting;
    }

    static void createJobLogging(String jobStatus, String jobName) {
        clcommon__DAG_Logging__c dagLogging = new clcommon__DAG_Logging__c(
            clcommon__Status__c = jobStatus,
            clcommon__Start_Time__c = System.now()
        );
        insert dagLogging;

        clcommon__Job_Logging__c jobLogging = new clcommon__Job_Logging__c(
            clcommon__Status__c = jobStatus,
            clcommon__DAG_Logging__c = dagLogging.Id,
            clcommon__Label__c = jobName
        );
        insert jobLogging;

        clcommon__Thread_Logging__c threadLogging = new clcommon__Thread_Logging__c(
            clcommon__Status__c = jobStatus,
            clcommon__Job_Logging__c = jobLogging.Id
        );
        insert threadLogging;

        clcommon__Job_Logging__c jobLogging2 = new clcommon__Job_Logging__c(
            clcommon__Status__c = jobStatus,
            clcommon__DAG_Logging__c = dagLogging.Id,
            clcommon__Label__c = 'test2'
        );
        insert jobLogging2;

        clcommon__Thread_Logging__c threadLogging2 = new clcommon__Thread_Logging__c(
            clcommon__Status__c = jobStatus,
            clcommon__Job_Logging__c = jobLogging2.Id
        );
        insert threadLogging2;

        clcommon__Job_Logging__c jobLogging3 = new clcommon__Job_Logging__c(
            clcommon__Status__c = jobStatus,
            clcommon__DAG_Logging__c = dagLogging.Id,
            clcommon__Label__c = jobName
        );
        insert jobLogging3;

        clcommon__Batch_Logging__c log = new clcommon__Batch_Logging__c();
        log.clcommon__Status__c = jobStatus;
        log.clcommon__Thread_Logging__c = threadLogging.Id;
        log.clcommon__Log__c = 'insert failed';

        Database.SaveResult result = Database.insert(log, false);

        System.assert(result.isSuccess(), 'inserted');
        System.assert(result.getErrors().size() == 0, 'no errors');
    }

    @isTest
    static void jobSuccess() {
        createJobLogging(SUCCESS, '');

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpSlackCalloutMock());

        NightlyDynamicAlertJob job = new NightlyDynamicAlertJob();
        String jobID = Database.executeBatch(job, 1);

        List<clcommon__DAG_Logging__c> dagLogList = new List<clcommon__DAG_Logging__c>();

        clcommon__DAG_Logging__c dagLogging = [
            SELECT Id
            FROM clcommon__DAG_Logging__c
            LIMIT 1
        ];

        dagLogList.add(dagLogging);
        NightlyDynamicAlertHandler handler = new NightlyDynamicAlertHandler(
            dagLogList[0].Id
        );
        System.enqueueJob(handler);
        Test.StopTest();

        Assert.isTrue(jobID != null, 'job runs 1');
    }

    @isTest
    static void jobFailure() {
        createJobLogging(FAILURE, 'StartOfDayDynamicJob');

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpSlackCalloutMock());

        NightlyDynamicAlertJob job = new NightlyDynamicAlertJob();
        String jobID = Database.executeBatch(job);

        List<clcommon__DAG_Logging__c> dagLogList = new List<clcommon__DAG_Logging__c>();

        clcommon__DAG_Logging__c dagLogging = [
            SELECT Id
            FROM clcommon__DAG_Logging__c
            LIMIT 1
        ];

        dagLogList.add(dagLogging);
        NightlyDynamicAlertHandler handler = new NightlyDynamicAlertHandler(
            dagLogList[0].Id
        );
        System.enqueueJob(handler);

        Test.StopTest();

        Assert.isTrue(jobID != null, 'job runs 2');
    }

    @isTest
    static void jobFailureTestNoThreadLog() {
        clcommon__DAG_Logging__c dagLogging = new clcommon__DAG_Logging__c(
            clcommon__Status__c = FAILURE,
            clcommon__Start_Time__c = System.now()
        );
        insert dagLogging;

        clcommon__Job_Logging__c jobLogging = new clcommon__Job_Logging__c(
            clcommon__Status__c = FAILURE,
            clcommon__DAG_Logging__c = dagLogging.Id,
            clcommon__Label__c = 'StartOfDayDynamicJob'
        );
        insert jobLogging;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpSlackCalloutMock());

        NightlyDynamicAlertJob job = new NightlyDynamicAlertJob();
        String jobID = Database.executeBatch(job);

        List<clcommon__DAG_Logging__c> dagLogList = new List<clcommon__DAG_Logging__c>();

        dagLogList.add([
            SELECT Id
            FROM clcommon__DAG_Logging__c
            LIMIT 1
        ]);
        NightlyDynamicAlertHandler handler = new NightlyDynamicAlertHandler(
            dagLogList[0].Id
        );
        System.enqueueJob(handler);

        Test.StopTest();

        Assert.isTrue(jobID != null, 'job runs 2');
    }
}