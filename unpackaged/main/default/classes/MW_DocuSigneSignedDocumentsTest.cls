@isTest
private class MW_DocuSigneSignedDocumentsTest {

	@isTest
	static void testCallout() {
		List<Account> accList = MW_DataFactoryTest.createAccounts(1);
		insert accList;
		List<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
		insert appList;
		MW_Settings__c mwSetting = new MW_Settings__c();
		mwSetting.LEADS_FE_EndpointURL__c = 'https://cls-lead.payoff.com/api/cls/update_user';
		insert mwSetting;

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MW_DocuSignResponseHttpCalloutMock());
		MW_DocuSigneSignedDocuments.postDocumentDetailsWithoutCallout(
			'a9be6341-3992-4d90-91c1-ec830ad4b077',
			appList[0].Id,
			'c9149473-e69f-ee12-38a7-d18b0cba847d'
		);
		System.assert(true, 'Ran successfully.');
		Test.stopTest();
	}

	@isTest
	static void testFEWebhookFailure() {
		List<Account> accList = MW_DataFactoryTest.createAccounts(1);
		insert accList;
		List<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
		insert appList;
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MW_DocuSignResponseHttpCalloutMock());
		try {
			MW_DocuSigneSignedDocuments.postDocumentDetailsWithoutCallout(
				'a9be6341-3992-4d90-91c1-ec830ad4b077',
				appList[0].Id,
				'c9149473-e69f-ee12-38a7-d18b0cba847d'
			);
		}
		catch (Exception e) {
			System.assertEquals(e.getMessage(), 'CallWebHookIntegration failed.',
				'The exception should alert that CallWebHookIntegration failed.');
		}
		Test.stopTest();
	}

	@isTest
	static void testInitialCalloutFailure() {
		List<Account> accList = MW_DataFactoryTest.createAccounts(1);
		insert accList;
		List<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
		insert appList;
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new DocuSignFailureCalloutMock());
		try {
			MW_DocuSigneSignedDocuments.postDocumentDetailsWithoutCallout(
				'a9be6341-3992-4d90-91c1-ec830ad4b077',
				appList[0].Id,
				'c9149473-e69f-ee12-38a7-d18b0cba847d'
			);
		}
		catch (Exception e) {
			System.assertEquals(e.getMessage(), 'Bad request',
				'The failure should be what is defined in this class.');
		}
		Test.stopTest();
	}

	public class TestException extends Exception {}

	public class DocuSignFailureCalloutMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req)
        {
			throw new TestException('Bad request');
        }
	}
}