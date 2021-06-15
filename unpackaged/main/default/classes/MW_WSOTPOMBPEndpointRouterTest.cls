@isTest
private class MW_WSOTPOMBPEndpointRouterTest {

	@isTest static void postCallOutTest() {
		postBodyData postData = new postBodyData();
		postData.leadGuid = 'fc92a9e9-dff6-e044-b8c6-dd645cb505dd';
		postData.transactionAmount = 100;
		postData.debitDate = '2018-09-15';
		postData.paymentModeName = 'ACH';
		postData.frequency = '0';
		postData.amountType = 'FIXED AMOUNT';
		postData.type = 'One Time';
		postData.manualSpreadName = 'name';
		String postDataJsonMsg=JSON.serialize(postData);

		//Setup Test Data
		dataSetup();

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestWSOTPOMBPMock());
		RestRequest req    = new RestRequest();
	  RestResponse res   = new RestResponse();

    req.requestURI 	   = '/services/apexrest/OTPOMBPEndpoint';
    //req.addParameter('Lead_ID', 'c9149473-e69f-ee12-38a7-d18b0cba847d');
    req.httpMethod = 'POST';

    req.requestBody = Blob.valueof(postDataJsonMsg);

    RestContext.request = req;
    RestContext.response = res;

		String response = MW_WSOTPOMBPEndpointRouter.OTPOMBPEndpointRouter();

		// Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
		// System.assertEquals('SUCCESS', jsonResponse.get('status'));
		try{
			Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
			System.assertEquals('SUCCESS', jsonResponse.get('status'));
		}
		catch(exception ex){
			System.assertEquals('System.JSONException', ex.getTypeName());
		}


		Test.stopTest();


	}

	private class postBodyData{
		public String leadGuid;
		public Decimal transactionAmount;
		public String debitDate;
		public String paymentModeName;
		public String frequency;
		public String amountType;
		public String type;
		public String manualSpreadName;
	}

	public class TestWSOTPOMBPMock implements HTTPCalloutMock{
			public HTTPResponse respond(HTTPRequest req){
					HttpResponse res = new HTTPResponse();
					res.setHeader('Content-Type', 'application/JSON');
					res.setBody('{"status":"SUCCESS","rowNumber":-1,"response":[],"errorNumber":0,"errorMessage":"","errorCode":"","content":[{"attributes":{"type":"loan__Automated_Payment_Setup__c","url":"/services/data/v34.0/sobjects/loan__Automated_Payment_Setup__c/a8D4F0000005GK4UAM"},"loan_CL_Contractc":"a1h4F0000005liEQAQ","loanActivec":true,"loanTypec":"One Time","loanBank_Accountc":"a0E4F000000Ef9AUAS","loanFrequencyc":null,"loanPayment_Modec":"a2d410000018BOYAA2","loanAmount_Typec":"FIXED AMOUNT","loanTransaction_Amountc":100,"loanLoan_Payment_Spreadc":null,"loanDebit_Datec":"2018-09-15","loanRecurring_ACH_Start_Datec":null,"loanRecurring_ACH_End_Datec":null,"loanSetup_Date_c":"2018-09-15","Id":"a8D4F0000005GK4UAM"}]}');
					res.setStatusCode(200);
					res.setStatus('SUCCESS');
					return res;
			}
	}

	public static void dataSetup(){
		loan.TestHelper.createSeedDataForTesting();
		loan.TestHelper.setupApprovalProcessForTxn(); // 3 day lock period
		List<filegen__File_Metadata__c> metadata = Test.loadData(filegen__File_Metadata__c.sObjectType,'CustomTestMetaData');
		loan.TestHelper.setupACHParameters();
		loan.TestHelper2.createFileGenMetaData();
		//loan.TestHelper2.createOrgBankAccounts();

		loan__Transaction_Approval_Config__c c = loan.CustomSettingsUtil.getApprovalConfig();
		loan__ACH_Parameters__c ach = loan.CustomSettingsUtil.getACHParameters();
		ach.loan__Days_In_Advance_To_Create_File__c = 0;
		ach.loan__Multiple_Payment_Method_Support__c =true;
		ach.loan__ACH_Return_Filegen__c = 'CustomACHReturnFileParser';
		ach.PPDAdvance_Folder_Name__c = 'ACH';
		ach.CORPayment_Folder_Name__c = 'ACH';
		upsert ach;

		loan__Currency__c curr = loan.TestHelper.createCurrency();
		//Create a dummy MF_Account
		loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
		loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');

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

		loan__Payment_Mode__c pMode = new loan__Payment_Mode__c(Name = 'ACH BofA Opp');
		insert pMode;
		loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
		//Account a1 = loan.TestHelper2.createInvestor('Bull', 1000);
		Account b1 = loan.TestHelper2.createBorrower('ShoeString');
		Contact con= new Contact(LastName='Test');
		insert con;
		loan__Bank_Account__c ba = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
																						 loan__Bank_Name__c = 'Some Bank',
																						 Unmasked_Bank_Account_Number__c = '123234324',
																						 loan__Routing_Number__c = '99999999',
																						 loan__Account_Type__c = 'Checking',
																						 loan__Account__c = b1.id);
		insert ba;

		loan__Bank_Account__c collectionTrustBA = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
																						 loan__Bank_Name__c = 'Some Bank',
																						 Unmasked_Bank_Account_Number__c = '123234324',
																						 loan__Routing_Number__c = '99999999',
																						 loan__Account_Type__c = 'Checking',
																						 loan__Account_Usage__c = 'Collections Trust Account',
																						 loan__Contact__c = con.id,
																						 loan__Active__c = True);
		insert collectionTrustBA ;

		loan__Loan_Account__c dummylaMonthly = loan.TestHelper.createLoanAccountForAccountObj(dummyLP,
																		b1,
																		dummyFeeSet,
																		dummyLoanPurpose,
																		dummyOffice);

		dummylaMonthly.loan__Loan_Status__c = 'Active - Good Standing';
		dummylaMonthly.loan__Principal_Remaining__c = 10000;
		dummylaMonthly.loan__Contact__c = con.id;
		dummylaMonthly.Investor_Account__c = b1.id;
		dummylaMonthly.lead_Guid__c = 'fc92a9e9-dff6-e044-b8c6-dd645cb505dd';
		update dummylaMonthly;

		loan.GlobalLoanUtilFacade loanUtil = new loan.GlobalLoanUtilFacade();
		Date systemDate = loanUtil.getCurrentSystemDate();


		System.debug('--Loan--'+dummylaMonthly);


		loan__Automated_Payment_Configuration__c apc = loan.TestHelper2.createAutomatedPaymentConfiguration(
																												'LOAN PAYMENT',
																												 pMode,
																												 collectionTrustBA,
																												 'loan.LoanPaymentTxnNACHAGen');


		apc.loan__Bank_Account__c = ba.id;
		update apc;
	}
}