@isTest
private class MW_DocuResponseTest {

	public static void dataSetup(){
		List<Account> testAccountList = MW_DataFactoryTest.createAccounts(1);
		insert testAccountList;
		List<genesis__Applications__c> testAppList =MW_DataFactoryTest.createApplication(1, testAccountList[0].id);
		insert testAppList;
	}

	static testmethod void test() {
		Test.startTest();
		String resposne ='{"envelopeId":"Demo Document Allocation","uri": "VANESSA","statusDateTime":"RAYMOND","status" :"Mr"}';
		MW_DocuResponse.parse(resposne);
		Test.stopTest();
	}

	static testmethod void test2() {
		Test.startTest();
		dataSetup();
		String resposne ='{"envelopeId":"Demo Document Allocation","uri": "VANESSA","statusDateTime":"RAYMOND","status" :"Mr"}';
		MW_WebhookHandler.SendDetailstoUI(resposne, 'c9149473-e69f-ee12-38a7-d18b0cba847d');
		Test.stopTest();
	}

	// Don't need this test method
	// static testmethod void test5() {
	//      Test.startTest();
	//      dataSetup();
	//      String resposne ='{"envelopeId":"Demo Document Allocation","uri": "VANESSA","statusDateTime":"RAYMOND","status" :"Mr"}';
	//      MW_WebhookHandler.SendDetailstoUI(resposne, null);
	//      Test.stopTest();
	// }
}