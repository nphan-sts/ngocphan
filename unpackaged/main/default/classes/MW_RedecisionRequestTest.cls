@isTest
private class MW_RedecisionRequestTest {

	@isTest static void accountRedecisionRequestTest() {
		Test.startTest();

		List<account> accList = MW_DataFactoryTest.createAccounts(1);
		insert accList;
		List<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
		insert appList;

		Redecision_Request__c testObj = new Redecision_Request__c();
		testObj.Application__c = appList[0].Id;
		testObj.Triggered_From__c = 'Account';
		testObj.Body__c = 'peer__First_Name__c';
		insert testObj;

		MW_RedecisionRequest.invokeRedecisionRequest(new List<Redecision_Request__c>{testObj});

		System.assertEquals('redecision', MW_RedecisionRequest.redeci.type);

		Test.stopTest();
	}

	@isTest static void applicationRedecisionRequestTest() {
		Test.startTest();

		List<account> accList = MW_DataFactoryTest.createAccounts(1);
		insert accList;
		List<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
		insert appList;

		Redecision_Request__c testObj = new Redecision_Request__c();
		testObj.Application__c = appList[0].Id;
		testObj.Triggered_From__c = 'Application';
		testObj.Body__c = 'genesis__Loan_Amount__c';
		insert testObj;

		MW_RedecisionRequest.invokeRedecisionRequest(new List<Redecision_Request__c>{testObj});

		System.assertEquals('redecision', MW_RedecisionRequest.redeci.type);

		Test.stopTest();
	}
}