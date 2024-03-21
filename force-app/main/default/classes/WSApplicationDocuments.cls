@RestResource(urlMapping='/Application/Documents/getForDelivery')
global with sharing class WSApplicationDocuments {

	@HttpGet
	global static void getDocuments() {
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		try {
			String leadId = req.params.get('lead_id');
			if (String.isBlank(leadId)) {
				res.statusCode = 400;
				res.responseBody = Blob.valueOf('lead_id is required');
				return;
			}

			List<genesis__Application_Document_Category__c> documents = [select Name, Doc_Code_FF__c, Box_URl__c, Doc_URL__c
			                                                             from genesis__Application_Document_Category__c
			                                                             where IsDeleted = FALSE and genesis__Active__c = TRUE and genesis__Status__c = 'CLEARED' and genesis__Application__r.Lead_ID__c = :leadId];

			Map<String, List<String>> docs = new Map<String, List<String>>();
			for (genesis__Application_Document_Category__c document : documents) {
				String code = document.Doc_Code_FF__c;
				String docUrl = String.isBlank(document.Box_URl__c) ? document.Doc_URL__c : document.Box_URl__c;
				if (String.isNotBlank(code) && String.isNotBlank(docUrl)) {
					List<String> items = docs.get(code);
					if (items == null) {
						items = new List<String>();
						docs.put(code, items);
					}
					items.add(docUrl);
				}
			}

			List<Origination_Documents__c> oDocuments = [select id, Code_FF__c, BoxUrl__c from Origination_Documents__c
			                                             where Application__r.Lead_ID__c = :leadId];
			for (Origination_Documents__c oDocument : oDocuments) {
				String code = oDocument.Code_FF__c;
				String boxUrl = oDocument.BoxUrl__c;
				if (String.isNotBlank(code) && String.isNotBlank(boxUrl)) {
					List<String> items = docs.get(code);
					if (items == null) {
						items = new List<String>();
						docs.put(code, items);
					}
					items.add(boxUrl);
				}
			}

			res.statusCode = 200;
			res.responseBody = Blob.valueOf(JSON.serialize(docs));
		}
		catch (Exception e) {
			res.statusCode = 500;
			res.responseBody = Blob.valueOf(e.getMessage());
		}
	}
}