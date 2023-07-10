@isTest
public with sharing class NightlyDynamicAlertJobTest {

    final static String SUCCESS = 'Success';
    final static String FAILURE = 'Failure';

    @testSetup
    private static void testSetup() {
        MW_Settings__c setting = MW_GlobalTestUtility.GetSettings();
        setting.Slack_mentions_for_Nacha_alert__c = 'test@user.com';
        insert setting;
    }

	static void createJobLogging(String jobStatus, String jobName) {
		clcommon__DAG_Logging__c dagLogging = new clcommon__DAG_Logging__c(
			clcommon__Status__c = jobStatus,
			clcommon__Start_Time__c = System.now()
		);
		insert dagLogging;

		clcommon__Job_Logging__c jobLogging = new clcommon__Job_Logging__c(
			clcommon__Status__c = SUCCESS,
			clcommon__DAG_Logging__c = dagLogging.Id,
			clcommon__Label__c = jobName
		);
		insert jobLogging;

		clcommon__Thread_Logging__c threadLogging = new clcommon__Thread_Logging__c(
			clcommon__Status__c = jobStatus,
			clcommon__Job_Logging__c = jobLogging.Id
		);
		insert threadLogging;

		clcommon__Batch_Logging__c log = new clcommon__Batch_Logging__c();
		log.clcommon__Status__c = jobStatus;
		log.clcommon__Thread_Logging__c = threadLogging.Id;

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
        String jobID = Database.executeBatch(job,1);

        List<clcommon__DAG_Logging__c> dagLogList = new List<clcommon__DAG_Logging__c>();

		clcommon__DAG_Logging__c dagLogging = [Select Id from clcommon__DAG_Logging__c LIMIT 1];

        dagLogList.add(dagLogging);
		NightlyDynamicAlertHandler handler = new NightlyDynamicAlertHandler(dagLogList[0].Id);
        System.enqueueJob(handler);
        Test.StopTest();
		
        Assert.isTrue(jobID != null,'job runs 1');

    }

    @isTest
    static void jobFailure() {

		createJobLogging(FAILURE, 'StartOfDayDynamicJob');
        
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpSlackCalloutMock());

        NightlyDynamicAlertJob job = new NightlyDynamicAlertJob();
        String jobID = Database.executeBatch(job);

        List<clcommon__DAG_Logging__c> dagLogList = new List<clcommon__DAG_Logging__c>();

		clcommon__DAG_Logging__c dagLogging = [Select Id from clcommon__DAG_Logging__c LIMIT 1];
		
        dagLogList.add(dagLogging);
		NightlyDynamicAlertHandler handler = new NightlyDynamicAlertHandler(dagLogList[0].Id);
        System.enqueueJob(handler);

        Test.StopTest();

		Assert.isTrue(jobID != null,'job runs 2');

    }


}