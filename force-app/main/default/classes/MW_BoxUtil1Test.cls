@isTest
private class MW_BoxUtil1Test {

	@testSetup static void setup(){
		BoxUrl__c box = new BoxUrl__c();
		box.BoxService__c='BoxSB.com';
		box.Boxurl__c='https://happymoney.app.box.com/';
		insert box;

		ints__OAuth_Settings__c oAuthName = new ints__OAuth_Settings__c();
		oAuthName.ints__Consumer_Key__c     = 'd998c67720u9bf2zg34ll4ogesxppsh7';
		oAuthName.ints__Consumer_Secret__c  = 'fSmCcCTwBxYHFpxElbYcJJywiw4CelFd';
		oAuthName.ints__Access_Token_URL__c = 'https://api.box.com/oauth2/token';
		oAuthName.ints__Service_Name__c     = 'BoxSB.com';
		insert oAuthName;

		ints__OAuth_Token__c authToken = new ints__OAuth_Token__c();
		authToken.ints__Token__c = 'yBE4Ci4BP9wa8D00AXH4rm9t9Y6blKrL';
		authToken.ints__Refresh_Token__c = 'NqDQcTONAkM0U1NJKVBeTi3bNmNHoDwS88TkS-quSK1RVn4tQKlWFBzDkxXy9woPq';
		authToken.ints__OAuth_Settings__c = oAuthName.id;
		authToken.ints__Is_Valid__c = true;
		insert authToken;

		Account acc = new Account(
			Name = 'Test',
			loan__Investor__c = false,
			cnotify__Email__c = 'no-reply@testorganization.com',
			peer__First_Name__c = 'TestFName',
			peer__Last_Name__c='TestLName',
			City__c='TestCity',
			State__c='TestState',
			ZIP_Code__c='123456'
			);
		Insert acc;

		Account acc1 = new Account(
			Name = 'Test',
			loan__Investor__c = true,
			cnotify__Email__c = 'no-reply@testorganization.com',
			peer__First_Name__c = 'TestFName',
			peer__Last_Name__c='TestLName',
			BoxFolderID__c = '48673238292',
			City__c='TestCity',
			State__c='TestState',
			ZIP_Code__c='123456'
			);
		Insert acc1;
		List<genesis__Applications__c> applist = new List<genesis__Applications__c>();
		for(integer i = 0; i<3; i++) {
			genesis__Applications__c app = new genesis__Applications__c();
			app.genesis__Due_Day__c = 20;
			app.genesis__Expected_First_Payment_Date__c = system.Today();
			app.genesis__Expected_Start_Date__c = system.Today();
			app.genesis__Funding_in_Tranches__c = true;
			app.genesis__Account__c = acc.Id;
			app.Investor__c = acc1.id;
			app.Application_Start_DateV2__c = system.Today();
			app.genesis__Status__c = 'REJECTED';
			app.Lead_ID__c = 'lkjnjfujw4nwrofujfsofjijwrjnojf';
			app.genesis__Draw_Period_End_Date__c = system.Today();
			app.Employment_Status__c = 'Full Time';
			app.BoxFolderID__c = '48673238292';
			app.genesis__Loan_Amount__c=1000;
			app.LeadGUID_XX_BoxFolderID__c = '1233211234567';
			applist.add(app);
		}
		insert applist;

		List<Document> docs= new list<Document>();
		for(integer i=0; i<10; i++) {
			Document Documents = new Document();
			Documents.Body = Blob.valueOf('Some Text');
			Documents.ContentType = 'application/pdf';
			Documents.DeveloperName = 'my_document'+i;
			Documents.IsPublic = true;
			Documents.Name = 'My Document'+i;
			Documents.FolderId = [select id from folder where name = 'ACU'].id;
			docs.add(documents);
		}
		insert docs;
	}

	@isTest static void createLeadGUIDXXBoxFolderTest() {
		Test.startTest();
		genesis__Applications__c app = [Select id From genesis__Applications__c limit 1];
		app.LeadGUID_XX_BoxFolderID__c = null;
		update app;
		Test.setMock(HttpCalloutMock.class, new TestGetAccessTokenMock());
		Test.setMock(HttpCalloutMock.class, new TestCreateAppFolderMock());
		MW_BoxUtil1.createLeadGUIDXXBoxFolder(app.Id);
		Test.stopTest();
	}

	@isTest static void createLeadGUIDBoxFolderIDTest() {
		Test.startTest();
		genesis__Applications__c app = [Select id From genesis__Applications__c limit 1];
		Test.setMock(HttpCalloutMock.class, new TestSearchBoxFolderMock());
		MW_BoxUtil1.createLeadGUIDBoxFolderID(app.Id);
		Test.stopTest();
	}

	@isTest static void createAppFolderTest(){
		Test.startTest();
		Test.setMOck(HttpCalloutMock.class, new TestCreateAppFolderMock());
		String testResult = MW_BoxUtil1.CreateAppFolder('investorFolderID', 'leadId');
		System.assertEquals(null, testResult);
		Test.stopTest();
	}

	@isTest static void createAppFolderUnauthorizedTest(){
		Test.startTest();
		Test.setMOck(HttpCalloutMock.class, new TestCreateAppFolderUnauthorizedMock());
		String testResult = MW_BoxUtil1.CreateAppFolder('investorFolderID', 'leadId');
		System.assertEquals(null, testResult);
		Test.stopTest();
	}

	// @isTest static void SearchBoxFolderExistUnauthorizedTest(){
	//      Test.startTest();
	//      genesis__Applications__c app = [Select id, LeadGUID_XX_BoxFolderID__c, Lead_ID__c From genesis__Applications__c limit 1];
	//      Test.setMock(HttpCalloutMock.class,new TestGetAccessTokenMock());
	//      Test.setMock(HttpCalloutMock.class, new TestSearchBoxFolderUnauthorizedMock());
	//      String testResult = MW_BoxUtil1.SearchBoxFolderExist(app.Id, app.LeadGUID_XX_BoxFolderID__c, app.Lead_ID__c);
	//      System.assertEquals(null, testResult);
	//      Test.stopTest();
	// }

	@isTest static void insertAccessTokenTest(){
		Test.startTest();
		MW_BoxUtil1.insertAccessToken();
		ints__OAuth_Settings__c oAuthName = [SELECT Id,Name, ints__Access_Token_URL__c,ints__Consumer_Key__c, ints__Consumer_Secret__c
		                                     FROM ints__OAuth_Settings__c WHERE ints__Service_Name__c = 'BoxSB.com' LIMIT 1];
		ints__OAuth_Token__c authToken = [SELECT ints__Token__c, ints__Refresh_Token__c
		                                  FROM ints__OAuth_Token__c
		                                  WHERE ints__OAuth_Settings__c =: oAuthName.Id and ints__Is_Valid__c = true Order By CreatedDate DESC LIMIT 1];
		System.assertNotEquals('NqDQcTONAkM0U1NJKVBeTi3bNmNHoDwS88TkS', authToken.ints__Refresh_Token__c);
		Test.stopTest();
	}

	@isTest static void uploadFileToBoxTest(){
		Test.startTest();
		List<Document> docum =  [SELECT Id,Name,FolderId,Folder.Name,body FROM Document];
		Test.setMock(HttpCalloutMock.class, new TestUploadFieldToBoxMock());
		MW_BoxUtil1.uploadFileToBox(docum[0].body, docum[0].Name, docum[0].FolderId, null);
		Test.stopTest();
	}

	@isTest static void uploadFileToBoxUnauthorizedTest(){
		Test.startTest();
		List<Document> docum =  [SELECT Id,Name,FolderId,Folder.Name,body FROM Document];
		Test.setMock(HttpCalloutMock.class, new TestUploadFieldToBoxUnauthorizedMock());
		String testUrl = MW_BoxUtil1.uploadFileToBox(docum[0].body, docum[0].Name, docum[0].FolderId, null);
		System.assertEquals(null, testUrl);
		Test.stopTest();
	}

	@isTest static void uploadFileToBoxConflictTest(){
		Test.startTest();
		List<Document> docum =  [SELECT Id,Name,FolderId,Folder.Name,body FROM Document];
		Test.setMock(HttpCalloutMock.class, new TestUploadFieldToBoxConflictMock());
		String testUrl = MW_BoxUtil1.uploadFileToBox(docum[0].body, docum[0].Name, docum[0].FolderId, null);
		System.assertEquals(null, testUrl);
		Test.stopTest();
	}

	public class TestCreateAppFolderMock implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req){
			StaticResource sr = [select Body from StaticResource where Name='BoxResposne' limit 1];
			String xmlString = sr.Body.toString();
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/JSON');
			res.setStatusCode(201);
			res.setStatus('Created');
			res.setBody(xmlString);
			res.setHeader('X-AUTH-TOKEN', 'aouthtoken12345');
			return res;
		}
	}

	public class TestCreateAppFolderUnauthorizedMock implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req){
			StaticResource sr = [select Body from StaticResource where Name='BoxResposne' limit 1];
			String xmlString = sr.Body.toString();
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/JSON');
			res.setStatusCode(401);
			res.setStatus('Unauthorized');
			return res;
		}
	}

	public class TestGetAccessTokenMock implements HTTPCalloutMock {
		public HTTPResponse respond(HTTPRequest req){
			HttpResponse res = new HTTPResponse();
			res.setHeader('Content-Type', 'application/JSON');
			res.setBody('{"access_token":"VPTELvq1gYzJmgqaFFsSuAZfOwyBj4pk","expires_in":3975,"restricted_to":[],"refresh_token":"hWZu9ngpClDnlPIBPiHnUWvReBC87xKhIKhYImMaank9ZK7jCjY4wYP8fGH772uE","token_type":"bearer"}');
			res.setStatusCode(200);
			res.setHeader('X-AUTH-TOKEN', 'aouthtoken12345');
			return res;
		}
	}

	public class TestSearchBoxFolderMock implements HTTPCalloutMock {
		public HTTPResponse respond(HTTPRequest req){
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/JSON');
			res.setStatusCode(200);
			res.setBody('{"total_count":1, "cls_entries":[{"id":1233211234567,"name":"ACU","cls_parent":{"id":1233211234567}}]}');
			return res;
		}
	}

	public class TestSearchBoxFolderUnauthorizedMock implements HTTPCalloutMock {
		public HTTPResponse respond(HTTPRequest req){
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/JSON');
			res.setStatusCode(401);
			res.setStatus('Unauthorized');
			return res;
		}
	}

	public class TestUploadFieldToBoxConflictMock implements HTTPCalloutMock {
		public HTTPResponse respond(HTTPRequest req){
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/JSON');
			res.setStatusCode(409);
			res.setStatus('Conflict');
			return res;
		}
	}

	public class TestUploadFieldToBoxUnauthorizedMock implements HTTPCalloutMock {
		public HTTPResponse respond(HTTPRequest req){
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/JSON');
			res.setStatusCode(401);
			res.setStatus('Unauthorized');
			return res;
		}
	}

	public class TestUploadFieldToBoxMock implements HTTPCalloutMock {
		public HTTPResponse respond(HTTPRequest req){
			HttpResponse res = new HTTPResponse();
			res.setHeader('Content-Type', 'application/JSON');
			res.setBody('{'+
			            '"total_count":1,'+
			            '"entries":['+
			            '{'+
			            '"type":"file",'+
			            '"id":"284925978574",'+
			            '"file_version":{'+
			            '"type":"file_version",'+
			            '"id":"299801290750",'+
			            '"sha1":"5d41c94f5687eff92c9085992a19313c92a881bd"'+
			            '},'+
			            '"sequence_id":"0",'+
			            '"etag":"0",'+
			            '"sha1":"5d41c94f5687eff92c9085992a19313c92a881bd",'+
			            '"name":"TILDocument a6h2F0000004d5gQAA.pdf",'+
			            '"description":"",'+
			            '"size":5060,'+
			            '"path_collection":{'+
			            '"total_count":2,'+
			            '"entries":['+
			            '{'+
			            '"type":"folder",'+
			            '"id":"0",'+
			            '"sequence_id":null,'+
			            '"etag":null,'+
			            '"name":"All Files"'+
			            '},'+
			            '{'+
			            '"type":"folder",'+
			            '"id":"47383466400",'+
			            '"sequence_id":"0",'+
			            '"etag":"0",'+
			            '"name":"SampleFromOrg"'+
			            '}'+
			            ']'+
			            '},'+
			            '"created_at":"2018-03-26T05:51:55-07:00",'+
			            '"modified_at":"2018-03-26T05:51:55-07:00",'+
			            '"trashed_at":null,'+
			            '"purged_at":null,'+
			            '"content_created_at":"2018-03-26T05:51:55-07:00",'+
			            '"content_modified_at":"2018-03-26T05:51:55-07:00",'+
			            '"created_by":{'+
			            '"type":"user",'+
			            '"id":"3202805146",'+
			            '"name":"CLS Dev User",'+
			            '"login":"cls_dev@happymoney.com"'+
			            '},'+
			            '"modified_by":{'+
			            '"type":"user",'+
			            '"id":"3202805146",'+
			            '"name":"CLS Dev User",'+
			            '"login":"cls_dev@happymoney.com"'+
			            '},'+
			            '"owned_by":{'+
			            '"type":"user",'+
			            '"id":"3202805146",'+
			            '"name":"CLS Dev User",'+
			            '"login":"cls_dev@happymoney.com"'+
			            '},'+
			            '"shared_link":null,'+
			            '"parent":{'+
			            '"type":"folder",'+
			            '"id":"47383466400",'+
			            '"sequence_id":"0",'+
			            '"etag":"0",'+
			            '"name":"SampleFromOrg"'+
			            '},'+
			            '"item_status":"active"'+
			            '}'+
			            ']'+
			            '}'
			            );
			res.setStatusCode(201);
			res.setStatus('Created');
			res.setHeader('X-AUTH-TOKEN', 'aouthtoken12345');
			return res;
		}
	}
}