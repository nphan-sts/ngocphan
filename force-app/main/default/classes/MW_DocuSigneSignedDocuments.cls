public class MW_DocuSigneSignedDocuments
{
	public String envelopeId;  //47ED9153-8E4B-4759-B0DB-9A229F06E41C
	public cls_envelopeDocuments[] envelopeDocuments;
	public Id applicationId;

	public class cls_envelopeDocuments {
		public String documentId;//1
		public String name; //FFA Membership Application - DocuSign
		public String type; //content
		public String uri; //envelopes/47ED9153-8E4B-4759-B0DB-9A229F06E41C/documents/1
		public String order; //1
		public String pages; //1
		public cls_availableDocumentTypes[] availableDocumentTypes;
		public String display; //inline
		public String includeInDownload; //true
		public String signerMustAcknowledge; //no_interaction
	}

	class cls_availableDocumentTypes {
		public String type; //electronic
		public String isDefault; //true
	}

	public static MW_DocuSigneSignedDocuments parse(String json){
		return (MW_DocuSigneSignedDocuments) System.JSON.deserialize(json, MW_DocuSigneSignedDocuments.class);
	}

	public class cls_signedDocs {
		cls_docusign[] data;
		public String type;
		public cls_signedDocs(cls_docusign[] docs, String type){
			this.data = docs;
			this.type=type;
		}
	}

	class cls_docusign {
		public String status;
		public String lead_guid;
		public String envelope_id;
		public String lead_id;
		public String member_id;
		public cls_documents[] documents;
	}

	class cls_documents {
		public String id;
		public String type;
		public String folder_id;
		public String code_ff;

	}

	class FailureException extends Exception {}

	@Future(callout=true)
	public static void postDocumentDetails(String envId, Id applicationId, String lead_guid)
	{
		postDocumentDetailsWithoutCallout(envId, applicationId, lead_guid);
	}

	public static void postDocumentDetailsWithoutCallout(String envId, Id applicationId, String lead_guid)
	{
		//Credentials are stored in Custom Settings.
		String accountID = DocuSignAPICred__c.getInstance().account_ID__c;
		String userName = DocuSignAPICred__c.getInstance().userName__c;
		String passWord = DocuSignAPICred__c.getInstance().passWord__c;
		String integratorKey = DocuSignAPICred__c.getInstance().integrator_Key__c;
		String DocusignEndpoint = DocuSignAPICred__c.getInstance().EndpointURL__c;
		String endPoint = DocusignEndpoint+'/accounts/'+accountID+'/envelopes/'+envId+'/documents';
		//String endPoint ='https://www.docusign.net/restapi/v2/accounts/'+accountID+'/envelopes/'+envId+'/documents';


		Http http = new Http();
		HttpRequest req = new HttpRequest();
		String methodType = 'GET';

		req.setEndpoint(endPoint);
		req.setMethod(methodType);

		//Apex HTTP Method Initialization.
		String authorizationHeader = '<DocuSignCredentials><Username>'+userName+
				'</Username><Password>'+Password+
				'</Password><IntegratorKey>'+integratorKey+
				'</IntegratorKey></DocuSignCredentials>';

		System.debug('Authorization Header:..........' + authorizationHeader);
		req.setHeader('X-DocuSign-Authentication', authorizationHeader);
		req.setHeader('Accept','application/json');
		req.setHeader('Content-Type','application/json');

		MW_DocuSigneSignedDocuments docs;
		try {
			HTTPResponse res = http.send(req);
			docs = parse(res.getbody());
			MW_LogUtility.info('MW_DocuSigneSignedDocuments', applicationId, lead_guid,
				'postDocumentDetailsWithoutCallout', res.getbody(), res);

			System.debug('Response from Docusign' + docs);
		} catch (Exception ex) {
			MW_LogUtility.error('MW_DocuSigneSignedDocuments', applicationId, lead_guid,
				'postDocumentDetailsWithoutCallout', ex);
			throw ex;
		}

		Map<String, List<cls_documents>> mapOd = new Map<String, List<cls_documents>>();

		List<cls_documents> listDocs = new List<cls_documents>();

		Map<String, String> DocMap      = new Map<String, String>();
		Map<String, String> DocMapCode  = new Map<String, String>();

		/*CLS-744 */
		Map<String, genesis__Applications__c> appMap = new Map<String, genesis__Applications__c>();
		for(genesis__Applications__c app: [select Id, LEAD_ID_ExtKey__c, Lead_ID__c, Member_ID__c from genesis__Applications__c where Lead_ID__c=:lead_guid LIMIT 1]) {
			appMap.put(app.Lead_ID__c,app);
		}

		for(genesis__Application_Document_Category__c apDoc:[select Id, genesis__Application__c,genesis__Document_Category__r.genesis__Category_Name__c, Doc_Code_FF__c
		from genesis__Application_Document_Category__c where genesis__Application__c=:applicationId and genesis__Document_Category__r.genesis__Category_Name__c!=null]) {
			System.debug('List Of Document IDs > ' +apDoc.genesis__Document_Category__r.genesis__Category_Name__c);
			DocMap.put(String.valueOf(apDoc.genesis__Document_Category__r.genesis__Category_Name__c).trim(), apDoc.id);
			if(apDoc.Doc_Code_FF__c!=null)
				DocMapCode.put(String.valueOf(apDoc.genesis__Document_Category__r.genesis__Category_Name__c).trim(), apDoc.Doc_Code_FF__c);
		}

		if(docs !=null)
		{

			for(cls_envelopeDocuments envDocs:docs.envelopeDocuments) {

				System.debug('Envelope File name 1' + envDocs.Name);
				System.debug('Envelope File name 2' + DocMap.get(envDocs.Name.trim()));

				if(DocMap.get(envDocs.Name.trim())!=null) {
					cls_documents cl = new cls_documents();
					cl.id            = envDocs.documentId;
					cl.type          = envDocs.Name;
					/*if(envDocs.Name.containsAny(' - Final DocuSign'))
					   cl.folder_id     = DocMap.get((envDocs.Name.replace(' - Final DocuSign',' ')).trim());
					   else
					   cl.folder_id     = DocMap.get((envDocs.Name.replace(' - DocuSign',' ')).trim());*/
					cl.folder_id     = DocMap.get(envDocs.Name.trim());
					if(DocMapCode.get(envDocs.Name.trim())!=null)
						cl.code_ff       = DocMapCode.get(envDocs.Name.trim());
					listDocs.add(cl);
				}
			}

			/*
			   Send the Document Id to Webhook Inoder to udpate the Boxurls
			 */
			List<cls_docusign> doclist = new List<cls_docusign>();
			cls_docusign cld = new cls_docusign();
			cld.documents    = listDocs;
			cld.lead_guid    = lead_guid;
			cld.envelope_id  = envId;
			/*CLS-744 */
			cld.member_id    = appMap.get(lead_guid).Member_ID__c;
			cld.lead_id      = appMap.get(lead_guid).LEAD_ID_ExtKey__c;

			cld.status       ='signed';
			doclist.add(cld);
			cls_signedDocs docuRes = new cls_signedDocs(doclist, 'docusign');

			//Work around for callout issue
			String success = MW_WebhookHandler.CallWebHookIntegration(JSON.serialize(docuRes), String.valueOf(applicationId), lead_guid);
			if (success == 'Fail') {
				throw new FailureException('CallWebHookIntegration failed.');
			}

			/*
			   Push to webhook on the hardpull request
			 */
			List<cls_docusign> dolist = new List<cls_docusign>();
			cls_docusign clsd = new cls_docusign();
			clsd.documents    = null;
			clsd.lead_guid    = lead_guid;
			clsd.member_id    = appMap.get(lead_guid).Member_ID__c;
			clsd.lead_id      = appMap.get(lead_guid).LEAD_ID_ExtKey__c;
			clsd.envelope_id  = null;
			clsd.status       = null;
			dolist.add(clsd);
			cls_signedDocs hardPullReq = new cls_signedDocs(dolist, 'hard_pull');

			/*
			    CLS-685 Changes
			 */
			List<genesis__Applications__c> appList = new List<genesis__Applications__c>([SELECT Id, isHardPull__c, genesis__Status__c from genesis__Applications__c where id=: applicationId limit 1]);

			String Webhookstatus;

			if(appList.size()>0) {

				if(!appList[0].isHardPull__c  && !MW_WebhookHelper.isHardpullDone(appList[0].Id)) /*CLS-685*/
					Webhookstatus = MW_WebhookHandler.CallWebHookIntegration(JSON.serialize(hardPullReq, true), String.valueOf(applicationId), lead_guid);

				if(Webhookstatus=='Success') {
					if(!appList[0].isHardPull__c) appList[0].isHardPull__c = true;
				}

				appList[0].genesis__Status__c  ='pre_funding';
				//CLS-811
				if(MW_WebhookHelper.appQueueDetails().size()>0) {
					appList[0].ownerid = MW_WebhookHelper.appQueueDetails().get('Pre-Funding Queue');
				}
				update appList;
			}
		}

	}
}