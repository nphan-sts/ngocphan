@isTest
public class MWQueuebleJobTest {

	@testSetup
	public static void setup(){
		MW_Settings__c testSettings = new MW_Settings__c();
		testSettings.LEADS_FE_EndpointURL__c = 'https://sfapi-dev.payoff.com/ms/api/cls/update_user';
		insert testSettings;
		list<account> accList = MW_DataFactoryTest.createAccounts(1);
		insert accList;
		list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
		insert appList;
	}

	static testmethod void testAcount(){
		Test.startTest();

		List<String> appList = new List<String>();
		for(genesis__Applications__c app:[select Id from genesis__Applications__c limit 99]) {
			appList.add(app.id);
		}

		List<MCCallout__c> calloutsScheduled = new List<MCCallout__c>();
		ID jobID = System.enqueueJob(new MWQueuebleJob(appList));

		system.debug('>>>>' + jobID);
		MCCallout__c mm = new MCCallout__c();
		mm.Job_ID__c = jobID;
		mm.Status__c = 'Queued';

		calloutsScheduled.add(mm);

		Test.stopTest();
	}

	static testmethod void testAcount1(){
		Test.startTest();

		List<String> appList = new List<String>();
		for(Account app:[select Id from Account limit 99]) {
			appList.add(app.id);
		}
		ID jobID = System.enqueueJob(new MWQueuebleJob(appList));

		List<MCCallout__c> calloutsScheduled = new List<MCCallout__c>();
		MCCallout__c mm = new MCCallout__c();
		mm.Job_ID__c = jobID;
		mm.Status__c = 'Queued';
		calloutsScheduled.add(mm);
		insert calloutsScheduled;

		Test.stopTest();
	}

	// static testmethod void testQueueable(){
	//   List<String> appList = new List<String>();
	//   MWQueuebleJob queuebleJob = new MWQueuebleJob(appList);
	//   Test.startTest();
	//
	//   System.enqueueJob(queuebleJob);
	//
	//   Test.stopTest();
	// }

	// static testmethod  void testAcount4(){
	//      Test.startTest();
	//
	//     List<String> appList = new List<String>();
	//     for(Account app:[select Id from Account limit 99]){
	//         appList.add(app.id);
	//     }
	//
	//     MWQueuebleJob.updateAniveDate(system.Today());
	//     MWQueuebleJob.updateAniveDate(system.Today()-1);
	//     MWQueuebleJob.updateAniveDate(system.Today()-2);
	//     MWQueuebleJob.updateAniveDate(system.Today()-3);
	//
	//      MWQueuebleJob.updateAniveDate1(system.Today());
	//     MWQueuebleJob.updateAniveDate1(system.Today()-1);
	//     MWQueuebleJob.updateAniveDate1(system.Today()-2);
	//     MWQueuebleJob.updateAniveDate1(system.Today()-3);
	//     Test.stopTest();
	// }


}