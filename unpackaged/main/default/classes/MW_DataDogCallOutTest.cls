@isTest
public class MW_DataDogCallOutTest {
	@testSetup
	static void setup() {
		//Mock necessary settings for DD
		MW_Settings__c setting = new MW_Settings__c();
		setting.DataDogApiURL__c = 'Test url';
		setting.DataDogApiKey__c = 'key';
		setting.DataDogTags__c = 'test tag';
		insert setting;
	}
	@isTest
	static void postfutureMWDataDogCallOut() {
		Test.startTest();

		MW_LogUtility_Queueable.Log log = new MW_LogUtility_Queueable.Log();
		log.message = 'test message';
		log.apexClass = 'test class';
		log.label = 'test label';
		log.type = 'info';

		// Associate the callout with a mock response
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

		// Call method to test
		HttpResponse result = MW_DataDogCallOut.send(JSON.serialize(log));
		// Verify mock response is not null
		System.assertNotEquals(
			null,
			result,
			'The callout returned a null response.'
		);
		// Verify status code
		System.assertEquals(
			200,
			result.getStatusCode(),
			'The status code is not 200.'
		);
		// Verify content type
		System.assertEquals(
			'application/json;charset=UTF-8',
			result.getHeader('Content-Type'),
			'The content type value is not expected.'
		);
		Test.stopTest();
	}

	@isTest
	static void postMWDataDogCallOut() {
		Test.startTest();

		MW_LogUtility.Log log = new MW_LogUtility.Log();
		log.data = 'test message';
		log.applicationId = 'test id';
		log.leadId = 'test lead id';
		log.apexClass = 'test class';
		log.type = 'info';
		log.statusCode = 200;

		// Associate the callout with a mock response
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

		// Call method to test
		HttpResponse result = MW_DataDogCallOut.send(log);
		// Verify mock response is not null
		System.assertNotEquals(
			null,
			result,
			'The callout returned a null response.'
		);
		// Verify status code
		System.assertEquals(
			200,
			result.getStatusCode(),
			'The status code is not 200.'
		);
		// Verify content type
		System.assertEquals(
			'application/json;charset=UTF-8',
			result.getHeader('Content-Type'),
			'The content type value is not expected.'
		);
		Test.stopTest();
	}

	@isTest
	static void bulkJsonPostMWDataDogCallOut() {
		Test.startTest();
		List<MW_LogUtility.Log> logs = new List<MW_LogUtility.Log>();

		MW_LogUtility.Log log = new MW_LogUtility.Log();
		log.data = 'test message';
		log.applicationId = 'test id';
		log.leadId = 'test lead id';
		log.apexClass = 'test class';
		log.type = 'info';
		log.statusCode = 200;

		logs.add(log);
		logs.add(log);

		// Associate the callout with a mock response
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

		// Call method to test
		HttpResponse result = MW_DataDogCallOut.sendJsonBatch(JSON.serialize(logs));
		// Verify mock response is not null
		System.assertNotEquals(
			null,
			result,
			'The callout returned a null response.'
		);
		// Verify status code
		System.assertEquals(
			200,
			result.getStatusCode(),
			'The status code is not 200.'
		);
		// Verify content type
		System.assertEquals(
			'application/json;charset=UTF-8',
			result.getHeader('Content-Type'),
			'The content type value is not expected.'
		);
		Test.stopTest();
	}

	@isTest
	static void bulkPostMWDataDogCallOut() {
		Test.startTest();
		List<MW_LogUtility.Log> logs = new List<MW_LogUtility.Log>();

		MW_LogUtility.Log log = new MW_LogUtility.Log();
		log.data = 'test message';
		log.applicationId = 'test id';
		log.leadId = 'test lead id';
		log.apexClass = 'test class';
		log.type = 'info';
		log.statusCode = 200;

		logs.add(log);
		logs.add(log);

		// Associate the callout with a mock response
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

		// Call method to test
		HttpResponse result = MW_DataDogCallOut.sendBatch(logs, new List<String>());
		// Verify mock response is not null
		System.assertNotEquals(
			null,
			result,
			'The callout returned a null response.'
		);
		// Verify status code
		System.assertEquals(
			200,
			result.getStatusCode(),
			'The status code is not 200.'
		);
		// Verify content type
		System.assertEquals(
			'application/json;charset=UTF-8',
			result.getHeader('Content-Type'),
			'The content type value is not expected.'
		);
		Test.stopTest();
	}

	public class MockHttpResponseGenerator implements HttpCalloutMock {
		// Implement this interface method
		public HTTPResponse respond(HTTPRequest req) {
			// Create a fake response
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json;charset=UTF-8');
			res.setStatusCode(200);
			return res;
		}
	}
}