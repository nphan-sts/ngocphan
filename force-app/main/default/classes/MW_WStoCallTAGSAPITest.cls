@isTest
private class MW_WStoCallTAGSAPITest {

	@isTest
	static void testTagsAPI() {

		//load custom setting data.
		MW_Settings__c customSetting = new MW_Settings__c();
		customSetting.TagsAPI_URL__c = 'https://sfapi-dev.payoff.com/lsa/api/v1/resource_tagging/add_tag';
		customSetting.CertificateNameForLEADS__c = 'sfapi_staging';
		insert customSetting;

		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new TestTagsAPIMock());
		loan__Loan_Account__c loanAccountObj = getLoanAccountObj(false);

		Test.stopTest();
		List<loan__Loan_Account__c> loadId = new List<loan__Loan_Account__c>();
		loadId.add(loanAccountObj);
		System.debug('>>>' +loadId);
		MW_WStoCallTAGSAPI.invokeCheckBoxFolder(loadId);
		HTTPResponse resultResponse = MW_WStoCallTAGSAPI.res;
		System.assertEquals(null, resultResponse, 'success');
	}

	@isTest
	static void testTagsAPIWithoutUrl() {

		//load custom setting data.
		MW_Settings__c customSetting = new MW_Settings__c();
		customSetting.TagsAPI_URL__c = null;
		customSetting.CertificateNameForLEADS__c = 'sfapi_staging';
		insert customSetting;

		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new TestTagsAPIMock());
		loan__Loan_Account__c loanAccountObj = getLoanAccountObj(false);
		Test.stopTest();
		List<loan__Loan_Account__c> loadId = new List<loan__Loan_Account__c>();
		loadId.add(loanAccountObj);
		System.debug('>>>' +loadId);
		MW_WStoCallTAGSAPI.invokeCheckBoxFolder(loadId);
		HTTPResponse resultResponse = MW_WStoCallTAGSAPI.res;
		System.assertEquals(null, resultResponse, 'success');
	}

	@isTest
	static void testRemoveTagsAPI(){
		MW_Settings__c customSetting = new MW_Settings__c();
		customSetting.RemoveTagsAPI_URL__c = 'https://sfapi-dev.payoff.com/lsa/api/v1/resource_tagging/remove_tag';
		customSetting.CertificateNameForLEADS__c = 'sfapi_staging';
		insert customSetting;

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestRemoveTagsAPIMock());
		loan__Loan_Account__c loanAccountObj = getLoanAccountObj(true);
		Test.stopTest();
		List<loan__Loan_Account__c> loadId = new List<loan__Loan_Account__c>();
		loadId.add(loanAccountObj);
		MW_WStoCallTAGSAPI.invokeCheckBoxFolder(loadId);
		HTTPResponse resultResponse = MW_WStoCallTAGSAPI.res;
		System.assertEquals(null, resultResponse, 'success');
	}

	@isTest
	static void testRemoveTagsAPIWithoutUrl(){
		MW_Settings__c customSetting = new MW_Settings__c();
		customSetting.RemoveTagsAPI_URL__c = '';
		customSetting.CertificateNameForLEADS__c = 'sfapi_staging';
		insert customSetting;

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestRemoveTagsAPIMock());
		loan__Loan_Account__c loanAccountObj = getLoanAccountObj(true);
		Test.stopTest();
		List<loan__Loan_Account__c> loadId = new List<loan__Loan_Account__c>();
		loadId.add(loanAccountObj);
		MW_WStoCallTAGSAPI.invokeCheckBoxFolder(loadId);
		HTTPResponse resultResponse = MW_WStoCallTAGSAPI.res;
		System.assertEquals(null, resultResponse, 'success');
	}

	public class TestTagsAPIMock implements HTTPCalloutMock {
		public HTTPResponse respond(HTTPRequest req){
			System.assertEquals('https://sfapi-dev.payoff.com/lsa/api/v1/resource_tagging/add_tag', req.getEndpoint());
			HttpResponse res = new HTTPResponse();
			res.setHeader('Content-Type', 'application/JSON');
			res.setBody('{"status":"SUCCESS"}');
			res.setStatusCode(200);
			res.setStatus('SUCCESS');
			return res;
		}
	}

	public class TestRemoveTagsAPIMock implements HTTPCalloutMock {
		public HTTPResponse respond(HTTPRequest req){
			System.assertEquals('https://sfapi-dev.payoff.com/lsa/api/v1/resource_tagging/remove_tag', req.getEndpoint());
			HttpResponse res = new HTTPResponse();
			res.setHeader('Content-Type', 'application/JSON');
			res.setBody('{"status":200, "result": "pass"}');
			res.setStatusCode(200);
			res.setStatus('SUCCESS');
			return res;
		}
	}

	public static loan__Loan_Account__c getLoanAccountObj(Boolean removeTag){
		loan.TestHelper.systemDate = Date.today();
		loan.TestHelper.createSeedDataForTesting();
		loan.TestHelper.setupApprovalProcessForTxn();

		List<filegen__File_Metadata__c> metadata = Test.loadData(filegen__File_Metadata__c.sObjectType,'CustomTestMetaData');
		loan.TestHelper.setupACHParameters();
		loan.TestHelper2.createFileGenMetaData();
		//loan.TestHelper2.createOrgBankAccounts();
		loan__Bank_Account__c collectionTrustBA = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
		                                                                    loan__Bank_Name__c = 'Some Bank',
		                                                                    loan__Routing_Number__c = '999999999',
		                                                                    loan__Account_Type__c = 'Checking',
		                                                                    loan__Account_Usage__c = 'Collections Trust Account',
		                                                                    //loan__Contact__c = con.id,
		                                                                    Unmasked_Bank_Account_Number__c = '123234324',
		                                                                    loan__Active__c = True);
		insert collectionTrustBA;

		loan__Transaction_Approval_Config__c c = loan.CustomSettingsUtil.getApprovalConfig();
		c.loan__Payment__c = false;
		upsert c;

		loan__ACH_Parameters__c ach = loan.CustomSettingsUtil.getACHParameters();
		ach.loan__Days_In_Advance_To_Create_File__c = 0;
		ach.loan__Multiple_Payment_Method_Support__c =true;
		upsert ach;

		loan__Currency__c curr = loan.TestHelper.createCurrency();
		//Create a dummy MF_Account
		loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
		loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');

		loan__Payment_Mode__c pMode = [select id from loan__Payment_Mode__c where Name= 'ACH'];
		loan__Payment_Mode__c pMode1 = [select id from loan__Payment_Mode__c where Name = 'Cash'];

		loan__Bank_Account__c bank = [select id from loan__Bank_Account__c where loan__Account_usage__c=:loan.FractionalizationConstants.COLLECTIONS_TRUST_ACCOUNT limit 1];

		loan.TestHelper2.createAutomatedPaymentConfiguration(loan.LoanConstants.LOAN_PAYMENT,pMode,bank,'CustomLoanPaymentTxnNACHAGen');
		loan.TestHelper2.createAutomatedPaymentConfiguration(loan.LoanConstants.LOAN_PAYMENT,pMode1,bank,'CustomLoanPaymentTxnNACHAGen');

		//Create a Fee Set
		loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
		loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
		loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
		loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();

		//Create a dummy Loan Product
		loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
		                                                                  dummyAccount,
		                                                                  curr,
		                                                                  dummyFeeSet);

		loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();

		Contact a1 = new Contact(LastName='TestACH');
		insert a1;

		loan__Bank_Account__c ba = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
		                                                     loan__Bank_Name__c = 'Some Bank',
		                                                     loan__Routing_Number__c = '999999999',
		                                                     loan__Account_Type__c = 'Checking',
		                                                     Unmasked_Bank_Account_Number__c = '123234324',
		                                                     loan__Contact__c = a1.id);
		insert ba;

		loan__Loan_Account__c dummylaMonthly = loan.TestHelper.createLoanAccountForContactObj(dummyLP, a1, dummyFeeSet, dummyLoanPurpose, dummyOffice);

		if(removeTag) {
			dummylaMonthly.CPD_Reason__c = null;
		}
		else{
			dummylaMonthly.CPD_Reason__c = 'Changed Payment Date';
		}

		dummylaMonthly.lead_Guid__c = '76aec664-81fa-42a6-5d78-7b2a548ea232';
		return dummylaMonthly;
	}
}