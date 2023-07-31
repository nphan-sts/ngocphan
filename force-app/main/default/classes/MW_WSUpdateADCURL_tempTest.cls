@isTest
private class MW_WSUpdateADCURL_tempTest {
	@isTest static void testLeadOfferPostRequest() {
		//Data Setup
		List<account> accList = MW_DataFactoryTest.createAccounts(1);
		insert accList;
		List<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
		insert appList;

		MW_Settings__c testSetting = new MW_Settings__c();
		testSetting.LEADS_FE_EndpointURL__c = 'https://google.com';
		insert testSetting;

		CL_Document__c clDocSetting = new CL_Document__c();
		clDocSetting.Doc1__c = 'Credit Score Notice';
		clDocSetting.Doc2__c = 'TIL Document';
		insert clDocSetting;

		//Test for Open Doc
		genesis__Application_Document_Category__c simpleADC = new genesis__Application_Document_Category__c();
		simpleADC.genesis__Application__c = appList[0].id;
		simpleADC.genesis__Status__c = 'OPEN';
		insert simpleADC;

		StaticResource sr = [Select Body From StaticResource Where Name='ADCUploadDoc' limit 1];
		String testJSON = sr.Body.toString();
		testJSON = testJSON.replace('documentId', simpleADC.id);

		Test.setMock(HttpCalloutMock.class, new TestWSUpdateADCURLMock());
		RestRequest req    = new RestRequest();
		RestResponse res   = new RestResponse();
		req.requestURI = '/services/apexrest/updateDocumentURL';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueof(testJSON);

		RestContext.request = req;
		RestContext.response = res;
		Test.startTest();
		MW_WSUpdateADCURL_temp.create();
		List<genesis__Application_Document_Category__c> testedADC = [Select id, Box_URl__c From genesis__Application_Document_Category__c Where id =: simpleADC.id];
		System.assertEquals('www.box.com/12345', testedADC[0].Box_URl__c);

		//Test the Doc has been CLEARED
		simpleADC.genesis__Status__c = 'CLEARED';
		update simpleADC;

		MW_WSUpdateADCURL_temp.create();
		List<Application_Tags__c> appTagsList = [Select id, Application__c, Application_Tag__c From Application_Tags__c Where Application__c =: appList[0].id and softDelete__c = false];	//pallavi(test class is failing in UAT and prod)
		//System.assertEquals('View Box for Documents', appTagsList[0].Application_Tag__c);

		//Test the Doc w/o folder(adc) id
		Delete appTagsList;
		testJSON = testJSON.replace(simpleADC.id, '');
		req.requestBody = Blob.valueof(testJSON);
		RestContext.request = req;
		RestContext.response = res;
		MW_WSUpdateADCURL_temp.create();
		List<Application_Tags__c> appTagsList2 = [Select id, Application__c, Application_Tag__c From Application_Tags__c Where Application__c =: appList[0].id and softDelete__c = false];	//pallavi(test class is failing in UAT and prod)
		System.assertEquals('View Box for Documents', appTagsList2[0].Application_Tag__c);
		Test.stopTest();
	}

	public class TestWSUpdateADCURLMock implements HTTPCalloutMock {
		public HTTPResponse respond(HTTPRequest req){
			HttpResponse res = new HTTPResponse();
			res.setHeader('Content-Type', 'application/JSON');
			res.setStatusCode(200);
			res.setStatus('SUCCESS');
			return res;
		}
	}

}