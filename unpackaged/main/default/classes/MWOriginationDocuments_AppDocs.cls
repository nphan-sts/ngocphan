global with sharing class MWOriginationDocuments_AppDocs implements Database.Batchable<sObject>,Database.AllowsCallouts {

	public static CL_Document__c cs = CL_Document__c.getOrgDefaults();
	public static string credit = cs.Doc1__c;
	public string Til = cs.Doc2__c;
	public string Adverse = cs.Doc3__c;
	public string uploadbox = cs.UploadedBOX__c;
	public static String OrginaitionDocumentFolder =cs.OrginaitionDocumentFolder__C;
	public string applnType;

	//global Final String query = 'SELECT id, genesis__Application__c, genesis__Application__r.genesis__Status__c, Lead_Id__c, Doc_Code_FF__c, genesis__Application__r.id, genesis__Application__r.LeadGUIDBoxFolderID__c, Name, Box_URl__c FROM genesis__Application_Document_Category__c WHERE (genesis__Application__r.genesis__Status__c=\'pre_funding\' AND genesis__Application__r.DocuSign_Sign_Date__c=YESTERDAY AND Box_URl__c=\'\' AND'+
	//		'(Name=:credit OR Name=: Adverse OR Name=: Til)) OR (genesis__Application__r.LastModifiedDate<=YESTERDAY AND (genesis__Application__r.genesis__Status__c=\'Decline_Manual_Review\' OR genesis__Application__r.genesis__Status__c=\'Declined\') AND Box_URl__c=\'\' AND (Name=:credit OR Name=: Adverse OR Name=: Til))';


	global final String query;

	global MWOriginationDocuments_AppDocs(String appType)
	{
		applnType = appType;
		if(appType == 'PreFunding') {
			this.query = 'SELECT id, genesis__Application__c, genesis__Application__r.genesis__Status__c, Lead_Id__c, Doc_Code_FF__c, genesis__Application__r.id, genesis__Application__r.LeadGUIDBoxFolderID__c, Name, Box_URl__c FROM genesis__Application_Document_Category__c ' +
					'WHERE ' +
					'(genesis__Application__r.genesis__Status__c=\'pre_funding\' AND genesis__Application__r.DocuSign_Sign_Date__c=YESTERDAY AND Box_URl__c=\'\' AND '+
					'(Name=:credit OR Name=: Adverse OR Name=: Til))';
		} else if(appType =='Declined')
		{
			this.query = 'SELECT id, genesis__Application__c, genesis__Application__r.genesis__Status__c, Lead_Id__c, Doc_Code_FF__c, genesis__Application__r.id, genesis__Application__r.LeadGUIDBoxFolderID__c, Name, Box_URl__c FROM genesis__Application_Document_Category__c ' +
					'WHERE ' +
					'(genesis__Application__r.LastModifiedDate<=YESTERDAY AND (genesis__Application__r.genesis__Status__c=\'Decline_Manual_Review\' OR genesis__Application__r.genesis__Status__c=\'Declined\') ' +
					'AND Box_URl__c=\'\' AND (Name=:credit OR Name=: Adverse OR Name=: Til))';

		}

		System.debug('query=' + query);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<genesis__Application_Document_Category__c> scope) {

		Map<String, String> appMap          = new Map<String, String>();
		List<genesis__Application_Document_Category__c> dealRoomDocs  = new List<genesis__Application_Document_Category__c>();

		for(genesis__Application_Document_Category__c app:scope) {
			appMap.put(app.genesis__Application__r.id,app.genesis__Application__r.LeadGUIDBoxFolderID__c);
		}

		/*
		    GeneraratedDocsMap
		 */
		map<String,Attachment> generatedDocsMap = new map<String,Attachment>();
		for(Attachment atch:[SELECT Name,body,ParentId,Description from Attachment where (Description =: credit OR Description =: Til OR Description =: Adverse)
		AND ParentId IN:appMap.keyset() AND Description!=:uploadbox and BodyLength>0 Order By CreatedDate ASC]) {
			generatedDocsMap.put(atch.ParentId+'_'+atch.Description, atch);
		}

		for(genesis__Application_Document_Category__c AppDocCategory:scope)
		{
			if(generatedDocsMap.size()>0 && generatedDocsMap.get(AppDocCategory.genesis__Application__r.id+'_'+AppDocCategory.Name)!=null) {
				String boxUrl = null;
				boxUrl = MW_BoxUtil1.uploadFileToBox(generatedDocsMap.get(AppDocCategory.genesis__Application__r.id+'_'+AppDocCategory.Name).body,AppDocCategory.Doc_Code_FF__c +'_'+AppDocCategory.Lead_Id__c+'.pdf',appMap.get(AppDocCategory.genesis__Application__c),AppDocCategory.genesis__Application__c);
				if(boxUrl!=null) {
					AppDocCategory.Box_URl__c = boxUrl;
					dealRoomDocs.add(AppDocCategory);
				}
			}
		}

		MW_BoxUtil1.insertAccessToken();
		if(dealRoomDocs.size()>0) update dealRoomDocs;
	}


	global void finish(Database.BatchableContext BC) {
		System.debug('MWOriginationDocuments_AppDocs ' + applnType);
		System.debug('query=' + query);
	}

}