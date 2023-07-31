/*
Purpose: Related to CRM-769. For running manually this job, this class is replica of 'MWOriginationDocuments_AppDocs'.
Additionally have modified to have dynamic date range and application status.
Currently we are not considering 'Expired' applications. But we can pass this status if needed in future.

How to call this batch?
---------------------------------------
For CRM-769, For 'Declined'
---------------------------------------
Set<String> appStatus = new Set<String>{'Decline_Manual_Review', 'Declined'};
//All possible values - AppCreatedDate, AppModifiedDate, DocuSignSignedDate
String selectAppsBy = 'AppCreatedDate';
//DateTime Type (yyyy-mm-ddT17:00:00Z), In case of day range, because of UTC timezone, MINUS 7 hours in the date. For eg. '2019-05-15T00:00:00Z' should be '2019-05-14T17:00:00Z'
String appStartDate = '2019-05-15T17:00:00Z';
//DateTime Type (yyyy-mm-ddT07:00:00Z), In case of day range, because of UTC timezone, ADD 7 hours in the date. For eg. '2019-05-15T00:00:00Z' should be '2019-05-16T07:00:00Z'
String appEndDate = '2019-05-16T07:00:00Z'; //DateTime Type (yyyy-mm-ddT07:00:00Z), Because of UTC timezone, add 7 hours.
MWOriginationDocuments_AppDocs_Manual b = new MWOriginationDocuments_AppDocs_Manual(selectAppsBy, appStartDate, appEndDate, appStatus);
Database.executeBatch(b,1);

---------------------------------------
For PreFunding('pre_funding')
---------------------------------------
//Existing batch job running for 'PreFunding('pre_funding') Apps and DocuSigned Date is YESTERDAY.
This batch job can also be used for same purpose by passing DocuSign Signed Date range and prefunding app status.
Set<String> appStatus = new Set<String>{'pre_funding'};
//All possible values - AppCreatedDate, AppModifiedDate, DocuSignSignedDate
String selectAppsBy = 'DocuSignSignedDate';
String appStartDate = '2020-05-21'; //Date Type format (yyyy-mm-dd)
String appEndDate = '2020-05-21'; //Date Type format (yyyy-mm-dd)
MWOriginationDocuments_AppDocs_Manual b = new MWOriginationDocuments_AppDocs_Manual(selectAppsBy, appStartDate, appEndDate, appStatus);
Database.executeBatch(b,1);
*/

global with sharing class MWOriginationDocuments_AppDocs_Manual implements Database.Batchable<sObject>,Database.AllowsCallouts {

	public static CL_Document__c cs = CL_Document__c.getOrgDefaults();
	public static string credit = cs.Doc1__c;
	public string Til = cs.Doc2__c;
	public string Adverse = cs.Doc3__c;
	public string uploadbox = cs.UploadedBOX__c;
	public static String OrginaitionDocumentFolder =cs.OrginaitionDocumentFolder__C;

	global String query;
	global final String selectAppsBy;
	global final String appStartDate; //DateTime Type
	global final String appEndDate; //DateTime Type
	global final Set<String> appStatus;

	global MWOriginationDocuments_AppDocs_Manual(String pSelectAppsBy, String pAppStartDate, String pAppEndDate, Set<String> pAppStatus)
	{
		/*
		//Original Existing Queries
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
		*/

		selectAppsBy = pSelectAppsBy;
		appStartDate = pAppStartDate;
		appEndDate = pAppEndDate;
		appStatus = pAppStatus;

		//SELECT id, genesis__Application__c, genesis__Application__r.genesis__Status__c, Lead_Id__c, Doc_Code_FF__c, genesis__Application__r.id, genesis__Application__r.LeadGUIDBoxFolderID__c, Name, Box_URl__c FROM genesis__Application_Document_Category__c WHERE genesis__Application__r.genesis__Status__c IN ('Decline_Manual_Review', 'Declined') AND Box_URl__c='' AND (Name= 'Credit Score Notice' OR Name= 'Adverse Action Notice' OR Name= 'TIL Document') AND genesis__Application__r.CreatedDate >= 2018-07-30T17:00:00Z AND genesis__Application__r.CreatedDate <= 2018-08-14T07:00:00Z
		query = 'SELECT id, genesis__Application__c, genesis__Application__r.genesis__Status__c, Lead_Id__c, Doc_Code_FF__c, genesis__Application__r.id, genesis__Application__r.LeadGUIDBoxFolderID__c, Name, Box_URl__c ' +
				'FROM genesis__Application_Document_Category__c' +
				' WHERE genesis__Application__r.genesis__Status__c IN : appStatus AND Box_URl__c=\'\' AND (Name=:credit OR Name=: Adverse OR Name=: Til)';

		if(selectAppsBy == 'AppCreatedDate') {
			query += ' AND genesis__Application__r.CreatedDate >= ' + appStartDate + ' AND genesis__Application__r.CreatedDate <= ' + appEndDate;
		} else if(selectAppsBy == 'AppModifiedDate') {
			query += ' AND genesis__Application__r.LastModifiedDate >= '  + appStartDate + ' AND genesis__Application__r.LastModifiedDate <= ' + appEndDate;
		}else if(selectAppsBy == 'DocuSignSignedDate') {
			query += ' AND genesis__Application__r.DocuSign_Sign_Date__c >= ' + appStartDate + ' AND genesis__Application__r.DocuSign_Sign_Date__c <= ' + appEndDate;
		}

		System.debug('initialize query: ' +query);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('inside start, query: ' +query);
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<genesis__Application_Document_Category__c> scope) {

		Map<String, String> appMap          = new Map<String, String>();
		List<genesis__Application_Document_Category__c> dealRoomDocs  = new List<genesis__Application_Document_Category__c>();
		List<loan__Batch_Process_Log__c> batchProcessLogs = new List<loan__Batch_Process_Log__c>();

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

				//log for reporting
				loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
				bplog.loan__Origin__c = 'MWOriginationDocuments_AppDocs_Manual';
				bplog.loan__Message__c = 'genesis__Application_Document_Category__c.Lead_Id__c = ' + AppDocCategory.Lead_Id__c + '; ' + 'genesis__Application_Document_Category__c.Name = ' + AppDocCategory.Name;
				bplog.loan__Type__c = 'Info';
				bplog.loan__Time__c = DateTime.now();
				bplog.App_Ids__c = 'boxUrl = ' + boxUrl;
				bplog.loan__Log_Level__c = 'DEBUG';
				batchProcessLogs.Add(bplog);
			}
		}

		MW_BoxUtil1.insertAccessToken();
		if(dealRoomDocs.size()>0) update dealRoomDocs;

		if(batchProcessLogs.size()>0) {
			insert batchProcessLogs;
		}
	}


	global void finish(Database.BatchableContext BC) {
		System.debug('query=' + query);
	}

}