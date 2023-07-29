@RestResource(urlMapping='/Application/Documents/delivery')
global with sharing class WSDeliveryDocuments {

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
				String name = document.Name.trim();
        String docUrl = String.isBlank(document.Box_URl__c) ? document.Doc_URL__c : document.Box_URl__c;
				if (String.isNotBlank(name) && String.isNotBlank(docUrl)) {
                    String groupName = null;
                    Integer lastSpaceIndex = name.lastIndexOf(' ');
                    if (lastSpaceIndex > 0) {
                        try {
                            Integer suffix = Integer.valueOf(name.substring(lastSpaceIndex + 1));
                            groupName = name.substring(0, lastSpaceIndex);
                        }
                        catch (Exception e) {
                            // Ignore
                        }
                    }
                    if (groupName == null) {
                        groupName = name;
                    }
										if (groupName == 'Plaid Asset Report') {
												groupName = 'Linked_Account';
										}
                    String key = groupName.toLowerCase().replaceAll('\\s+', '_');
                    List<String> items = docs.get(key);
					if (items == null) {
						items = new List<String>();
						docs.put(key, items);
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
                    String key = code.toLowerCase().replaceAll('\\s+', '_');
					List<String> items = docs.get(key);
					if (items == null) {
						items = new List<String>();
						docs.put(key, items);
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