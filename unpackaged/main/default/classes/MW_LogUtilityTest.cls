@isTest
private class MW_LogUtilityTest {
    @testSetup
    static void setupTestData() {
		mwSettingDataSetup();
    }

	@isTest
	static void testLogUtility() {
		DmlException ex = new DmlException();

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new BasicCalloutMock());
		MW_LogUtility.error('class', 'appId', 'leadId', 'errorMethod', ex);

		MW_LogUtility.info('classInfo', 'appId info', 'leadId', 'info method', 'good message');
		Map<String, String> v = new Map<String, String>();
		v.put('data', 'test data');
		MW_LogUtility.warn('classInfo', 'appId info', 'leadId', 'warn method', v);

		HttpResponse response = new HttpResponse();
		response.setStatusCode(200);
		MW_LogUtility.info('classInfo', 'appId info', 'leadId', 'info method', 'good message', response);

		response.setStatusCode(400);
		MW_LogUtility.info('classInfo', 'appId info', 'leadId', 'info method', 'bad message', response);

		MW_LogUtility.errorMessage('classInfo', 'label', new Map<String, String>());

		MW_LogUtility.errorMessage('classInfo', 'label', null);

		MW_LogUtility.infoMessage('classInfo', 'label', null);
		Test.stopTest();
	}

	@isTest
	static void testSlackCallout() {
		Test.startTest();
		String errorUrl = MW_SlackCallOut.logLevelChannels('Error');
		System.assertEquals(
			'https://hooks.slack.com/services/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',
			errorUrl,
			'Error URL set correctly.'
		);
		String otherUrl = MW_SlackCallOut.logLevelChannels('other url');
		System.assertEquals(
			'https://hooks.slack.com/services/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',
			otherUrl,
			'Other URL set correctly.'
		);
		Test.setMock(HttpCalloutMock.class, new BasicCalloutMock());
		MW_SlackCallOut.slackCallOut(otherUrl, 'message');
		Test.stopTest();
	}

	@isTest
	static void testSlackCallout2() {
		MW_LogUtility.Log log = new MW_LogUtility.Log();
		log.apexClass = 'apexClass';
		log.applicationId = 'applicationId';
		log.leadId = 'leadId';
		log.method = 'method';
		log.type = 'type';
		log.statusCode = 200;
		log.data = new MW_LogUtility.ExceptionDO(new DmlException());
		Test.startTest();
		MW_SlackCallOut.callSlack(log);
		Test.stopTest();
	}

	@isTest
	static void testDataDogCallout() {
		MW_LogUtility.Log log = new MW_LogUtility.Log();
		log.apexClass = 'apexClass';
		log.applicationId = 'applicationId';
		log.leadId = 'leadId';
		log.method = 'method';
		log.data = 'message';
		log.type = 'type';
		log.statusCode = 200;
		Test.startTest();
		TestCallOutMock mock = new TestCallOutMock();
		Test.setMock(HttpCalloutMock.class, mock);
		mock.setExpected('message');
		MW_DataDogCallOut.send('message');
		mock.setExpected(log);
		MW_DataDogCallOut.send(log);
		Test.stopTest();
	}

	@IsTest
	static void testSendAllocationRulesetErrorsTest() {

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new BasicCalloutMock());

		genesis__Checklist__c checkListWithDesc = new genesis__Checklist__c(
				genesis__Description__c = 'Exception, unable to do foo',
				genesis__Message__c = 'error123'
		);

		MW_LogUtility.sendAllocationRulesetErrors('myClass', 'appid123', 'leadid123', checkListWithDesc);

		List<clcommon__Batch_Process_Log__c> logs =
			[SELECT clcommon__Type__c,
					clcommon__Batch_Id__c,
					clcommon__Message__c
			FROM clcommon__Batch_Process_Log__c];

		System.assertEquals(1, logs.size());

		clcommon__Batch_Process_Log__c batchProcessLog = logs.get(0);
		System.assertEquals('Exception', batchProcessLog.clcommon__Type__c);
		System.assertEquals('appid123', batchProcessLog.clcommon__Batch_Id__c);
		System.assert(batchProcessLog.clcommon__Message__c.contains(checkListWithDesc.genesis__Message__c));

		Test.stopTest();
	}

	@IsTest
	static void testLogAllocation() {

		Account investor = MW_GlobalTestUtility.GetAccount('Investor');
		insert investor;

		genesis__Applications__c app = MW_GlobalTestUtility.GetApplication();
		app.Investor__c = investor.Id;
		app.Last_Investor_Assigned_On__c = System.now();
		insert app;

		String message = MW_LogUtility.allocationLogEntry(app, true);
		System.assert(message.contains('Successful allocation for Lead ID: c9149473-e69f-ee12-38a7-d18b0cba847d'));
		System.assert(message.contains('investor:Account Test'));
		System.assert(message.contains('status: kba_fail'));
		System.assert(message.contains('at: '));

		message = MW_LogUtility.allocationLogEntry(app, false);
		System.assert(message.contains('Failed allocation for Lead ID: c9149473-e69f-ee12-38a7-d18b0cba847d'));
		System.assert(message.contains('status: kba_fail'));

		/* verify a few unexpected scenarios don't cause exceptions */
		app.Investor__c = null;
		update app;
		MW_LogUtility.logAllocation('classInfo', app, true);

		app.Last_Investor_Assigned_On__c = null;
		app.genesis__Status__c = null;
		update app;

		MW_LogUtility.logAllocation('classInfo', app, true);
		MW_LogUtility.logAllocation('classInfo', null, true);
		MW_LogUtility.logAllocation('classInfo', null, false);
		MW_LogUtility.logAllocation(null, null, false);
	}

	@IsTest
	static void testAppLoggablesAndInfo() {

		Test.startTest();

		Account investor = MW_GlobalTestUtility.GetAccount('Investor');
		insert investor;

		genesis__Applications__c app = MW_GlobalTestUtility.GetApplication();
		app.Lead_ID__c = 'aaaa-bbbb-cccc-dddd';
		app.genesis__Status__c = 'advp';
		insert app;

		genesis__Applications__c noInvestorOrDateApp = [SELECT Lead_ID__c,
																genesis__Status__c
														FROM   genesis__Applications__c
														WHERE Id = : app.Id
														LIMIT 1];

		Map<String, Object> logNoInvestorOrApp = MW_LogUtility.toLoggableApp(noInvestorOrDateApp);
		MW_LogUtility.infoMessage('classInfo', 'no investor or date scenario', logNoInvestorOrApp);

		app.Investor__c = investor.Id;
		app.Last_Investor_Assigned_On__c = System.now();
		update app;

		List<genesis__Applications__c> apps = new List<genesis__Applications__c>();
		List<Map<String, Object>> emptyListLog = MW_LogUtility.toLoggableApps(apps);
		MW_LogUtility.infoMessage('classInfo', 'empty apps scenario', emptyListLog);

		apps.add(app);

		List<Map<String, Object>> appInfos = MW_LogUtility.toLoggableApps(apps);

		System.assert(appInfos != null);
		System.assertEquals(1, appInfos.size());
		Map<String, Object> appInfo = appInfos.get(0);

		System.assertEquals(app.Id, appInfo.get('Id'));
		System.assertEquals('aaaa-bbbb-cccc-dddd', appInfo.get('Lead_ID__c'));
		System.assertEquals('advp', appInfo.get('genesis__Status__c'));
		MW_LogUtility.infoMessage('classInfo', 'label', appInfos);

		Map<String, Object> nullAppInfo = MW_LogUtility.toLoggableApp(null);
		MW_LogUtility.infoMessage('classInfo', 'null object scenario', nullAppInfo);

		List<Map<String, Object>> nullAppInfos = MW_LogUtility.toLoggableApps(null);
		MW_LogUtility.infoMessage('classInfo', 'null objects scenario', nullAppInfos);

		Test.stopTest();
	}

	@IsTest
	static void testToSObjectKeyDiff() {

		genesis__Applications__c app1 = MW_GlobalTestUtility.GetApplication();

		genesis__Applications__c app2 = MW_GlobalTestUtility.GetApplication();
		app2.Lead_ID__c = '42838772381784123123';
		app2.genesis__Payment_Frequency__c = 'MONTHLY';
		app2.genesis__Loan_Amount__c = 14010.04;

		Map<String, Object> objDiff = MW_LogUtility.toSObjectKeyDiff(app1, app2);
		MW_LogUtility.infoMessage('classInfo', 'non saved scenario', objDiff);

		insert app1;
		insert app2;

		/* test update */
		objDiff = MW_LogUtility.toSObjectKeyDiff(app1, app2);
		System.assert(objDiff.containsKey('updated'));

		String updated = (String) objDiff.get('updated');
		System.assert(updated != null);
		System.assert(updated.containsIgnoreCase('genesis__Payment_Frequency__c'));
		MW_LogUtility.infoMessage('classInfo', 'one saved scenario', objDiff);

		/* test remove and insert */
		app2.genesis__Loan_Amount__c = null;
		app2.genesis__Interest_Calculation_Method__c = null;
		app2.Annual_Individual_Income_App__c = 1000000;
		app2.Last_Investor_Assigned_On__c = System.now();
		update app2;

		/*
		 The expected behavior is Last_Investor_Assigned_On__c will show up in the added field, including value
		 since it is included in the revealKeys.  Lead id wont show up as those fields have not changed.
		 genesis__Loan_Amount__c should show up in removed
		 */
		objDiff = MW_LogUtility.toSObjectKeyDiff(app2, app1, new List<String>{'Lead_ID__c', 'genesis__Loan_Amount__c', 'Last_Investor_Assigned_On__c'});
		System.assertEquals(3, objDiff.keySet().size());
		System.assert(objDiff.containsKey('removed'));
		System.assert(objDiff.containsKey('added'));
		System.assert(objDiff.containsKey('updated'));

		String removed = (String) objDiff.get('removed');
		System.assert(removed.contains('genesis__Loan_Amount__c: [22120.00 => null]'));
		System.assert(removed.contains('genesis__Interest_Calculation_Method__c'));

		String added = (String) objDiff.get('added');
		System.assert(added.contains('Annual_Individual_Income_App__c, Last_Investor_Assigned_On__c: [null => '));

		objDiff = MW_LogUtility.toSObjectKeyDiff(null, app2);
		MW_LogUtility.infoMessage('classInfo', 'null first scenario', objDiff);
		System.assert(objDiff.containsKey('Invalid Diff'));
		System.assertEquals('New object is empty', objDiff.get('Invalid Diff'));

		objDiff = MW_LogUtility.toSObjectKeyDiff(app1, null);
		System.assert(objDiff.containsKey('Invalid Diff'));
		System.assertEquals('Old object is empty', objDiff.get('Invalid Diff'));
		MW_LogUtility.infoMessage('classInfo', 'null second scenario', objDiff);
	}

	@IsTest
	static void testToLoggableObjs() {

		genesis__Applications__c app = MW_GlobalTestUtility.GetApplication();
		List<genesis__Applications__c> apps = new List<genesis__Applications__c>();
		apps.add(app);

		List<Map<String, Object>> logs = MW_LogUtility.toLoggableObjs(apps,
				new List<String> {'genesis__Payment_Frequency__c',
								  'genesis__Product_Type__c',
								  'genesis__Term__c',
								  'Lead_ID__c'});

		System.assertEquals(1, logs.size());
		Map<String, Object> log1 = logs.get(0);
		System.assertEquals('WEEKLY', log1.get('genesis__Payment_Frequency__c'));
		System.assertEquals('LOAN', log1.get('genesis__Product_Type__c'));
		System.assertEquals(24, log1.get('genesis__Term__c'));
		System.assertEquals('c9149473-e69f-ee12-38a7-d18b0cba847d', log1.get('Lead_ID__c'));

		logs = MW_LogUtility.toLoggableObjs(null, new List<String>());
		System.assertEquals(0, logs.size());

		Map<String, Object> log = MW_LogUtility.toLoggableObj(null, new List<String>());
		System.assertEquals(0, log.size());

		log = MW_LogUtility.toLoggableObj(app, null);
		System.assertEquals(0, log.size());
	}

	@isTest
	static void testBatchLogs() {
		Test.startTest();
		TestCallOutMock mock = new TestCallOutMock();
		mock.setBatch(true);
		mock.setExpected('test');
		Test.setMock(HttpCalloutMock.class, mock);

		MW_LogUtility.beginBatch();
		System.assertEquals(MW_LogUtility.isBatch, true);
		MW_LogUtility.info('MW_LogUtilityTest', 'testBatchLogs', 'test');
		System.assertEquals(MW_LogUtility.batchLogs.size(), 1);
		MW_LogUtility.sendBatch();

		Test.stopTest();
	}

	public static void mwSettingDataSetup(){
		//data Setup
		MW_Settings__c mwSetting = new MW_Settings__c();
		mwSetting.Slack_Alert_Channels__c = 'https://hooks.slack.com/services/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';
		mwSetting.Slack_Info_Channels__c = 'https://hooks.slack.com/services/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';
		mwSetting.Slack_Alert_Icon__c = 'Alert';
		mwSetting.Slack_Info_Icon__c = 'Info';
		mwSetting.DataDogApiKey__c = 'testApiKey';
		mwSetting.DataDogTags__c = 'env:testing';
		mwSetting.DataDogApiURL__c = 'https://http-intake.logs.datadoghq.com/v1/input';
		insert mwSetting;
	}

	public class BasicCalloutMock implements HTTPCalloutMock {
		public HttpResponse respond(HTTPRequest req) {
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/JSON');
			res.setStatusCode(200);
			return res;
		}
	}

	public class TestCallOutMock implements HTTPCalloutMock {
		private object expected;
		private boolean batch = false;

		public void setBatch(boolean e) {
			batch = e;
		}

		public void setExpected(object e) {
			expected = e;
		}

		private void expectObject(string j) {
			Map<string, object> body =
				(Map<string, object>) JSON.deserialize(j, Map<string, object>.class);
			object actual = body.get('message');
			string ddsource = (string) body.get('ddsource');
			System.assertEquals(actual, expected, 'Message should match excpected');
			System.assertEquals('Salesforce', ddsource, 'Ddsource should be Salesforce');
		}

		private void expectBatch(string j) {
			List<Map<string, object>> body =
				(List<Map<string, object>>) JSON.deserialize(j, List<Map<string, object>>.class);
			for (Map<string, object> obj : body) {
				object actual = obj.get('message');
				string ddsource = (string) obj.get('ddsource');
				System.assertEquals(actual, expected, 'Message should match excpected');
				System.assertEquals('Salesforce', ddsource, 'Ddsource should be Salesforce');
			}
		}

		public HttpResponse respond(HttpRequest req) {
			if (batch) {
				expectBatch(req.getBody());
			} else {
				expectObject(req.getBody());
			}
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/JSON');
			res.setStatusCode(200);
			return res;
		}
	}
}