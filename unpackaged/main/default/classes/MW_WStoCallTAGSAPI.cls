global class MW_WStoCallTAGSAPI {

	@InvocableVariable
	global Boolean removeCPDTag;

	@InvocableMethod
	public static void invokeCheckBoxFolder(List<loan__Loan_Account__c> genid)
	{
		system.debug('*******Loan CL contract*********'+genid);
		system.debug('*******genid[0].id*********'+genid[0].id);

		if(genid[0].CPD_Reason__c !=null  && genid[0].CPD_Reason__c =='Changed Payment Date') {
			String objJSONStr = Json.serialize(genid[0]);
			jsonGenearteTags(objJSONStr);
		}
		else if(genid[0].CPD_Reason__c == null) {
			String objJSONStr = Json.serialize(genid[0]);
			removeCPDTags(objJSONStr);
		}
	}

	@TestVisible
	private static HTTPResponse res;

	@future(callout=true)
	public Static void jsonGenearteTags(String objJSONStr){
		loan__Loan_Account__c loanID = (loan__Loan_Account__c) Json.deserialize(objJSONStr, System.Type.forName('loan__Loan_Account__c'));
		JSONGenerator jsonBody = JSON.createGenerator(true);
		List< loan__Repayment_Schedule_Summary__c> repaymentSch = [Select id, loan__RSS_Repayment_Dt__c, loan__RSS_Loan_Account__c from loan__Repayment_Schedule_Summary__c where loan__RSS_Loan_Account__c =: loanID.id order by CreatedDate desc limit 1];
		String reqBody = '';
		jsonBody.writeStartObject();
		try {

			jsonBody.writeStringField('lead_id', loanID.lead_Guid__c);
			jsonBody.writeStringField('payment_date', String.valueOf(repaymentSch[0].loan__RSS_Repayment_Dt__c));
			jsonBody.writeStringField('source', 'CloudLendingUser');
			jsonBody.writeEndObject();
			reqBody = jsonBody.getAsString();

			String tagsAPIEndPoint = MW_Settings__c.getInstance().TagsAPI_URL__c;
			String certName = MW_Settings__c.getInstance().CertificateNameForLEADS__c;

			HttpRequest req = new HttpRequest();
			req.setMethod('POST');
			req.setHeader('Content-Type', 'application/json');
			req.setHeader('Cache-Control', 'no-cache');
			if(certName!=null)
				req.setClientCertificateName(certName);
			System.debug('TAGS WebHook request :: >>' +reqbody  );

			req.setEndpoint(tagsAPIEndPoint);
			req.setbody(reqbody);
			Http http = new Http();

			System.debug('Request:: >>' +req);
			res = http.send(req);
			System.debug('Response :: >> ' +res  );

			String response;
			if(res.getStatusCode()==200) {
				response = res.getBody();
			}

		}
		catch(exception e)
		{
			System.debug('Error: ' + e.getLineNumber() + ' Desc. ' + e.getMessage()+' Stack: '+e.getStackTraceString());

		}
	}

	@future(callout=true)
	public Static void removeCPDTags(String objJSONStr){
		loan__Loan_Account__c obj = (loan__Loan_Account__c) Json.deserialize(objJSONStr, System.Type.forName('loan__Loan_Account__c'));
		JSONGenerator jsonBody = JSON.createGenerator(true);
		String reqBody = '';
		jsonBody.writeStartObject();
		try {
			jsonBody.writeStringField('lead_id', obj.lead_Guid__c);
			jsonBody.writeEndObject();
			reqBody = jsonBody.getAsString();

			String tagsAPIEndPoint = MW_Settings__c.getInstance().RemoveTagsAPI_URL__c;
			String certName = MW_Settings__c.getInstance().CertificateNameForLEADS__c;

			HttpRequest req = new HttpRequest();
			req.setMethod('POST');
			req.setHeader('Content-Type', 'application/json');
			req.setHeader('Cache-Control', 'no-cache');
			if(certName!=null) {
				req.setClientCertificateName(certName);
			}

			System.debug('REMOVE TAGS WebHook request :: >>' + reqbody);

			req.setEndpoint(tagsAPIEndPoint);
			req.setbody(reqbody);

			Http http = new Http();
			System.debug('Remove Request:: >>' + req);
			res = http.send(req);
			System.debug('Remove Response :: >> ' + res);

			if(res.getStatusCode()==200) {
				String response = res.getBody();
			}
		}
		catch(exception e)
		{
			System.debug('Error: ' + e.getLineNumber() + ' Desc. ' + e.getMessage()+' Stack: '+e.getStackTraceString());
		}
	}
}