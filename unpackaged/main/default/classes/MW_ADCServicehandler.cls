public class MW_ADCServicehandler {

	public static void postDealRoomStructure(List<genesis__Application_Document_Category__c > adcList, Map<Id, genesis__Application_Document_Category__c> oldMap){

		List<String> appList                 = new List<String>();
		List<MCCallout__c> calloutsScheduled = new List<MCCallout__c>();

		for(genesis__Application_Document_Category__c adc : adcList) {
			if(adc.genesis__Status__c !='SUBMITTED' && adc.genesis__Application__r.genesis__Status__c !='offer_shown' && adc.genesis__Application__r.genesis__Status__c !='agent_verified' && adc.genesis__Application__r.genesis__Status__c !='docusign_loan_docs_sent' && adc.genesis__Application__r.genesis__Status__c !='docusign_loan_docs_complete' && adc.genesis__Application__r.genesis__Status__c !='pre_funding' && adc.genesis__Application__r.genesis__Status__c !='Approved for funding' && adc.genesis__Application__r.genesis__Status__c !='funded' &&
			   adc.genesis__Application__r.genesis__Status__c != 'Default Documents' && adc.genesis__Application__r.genesis__Status__c != 'NEW - ENTERED' && adc.genesis__Application__r.genesis__Status__c !='Declined' && adc.genesis__Application__r.genesis__Status__c !='Expired' && adc.genesis__Application__r.genesis__Status__c !='Withdrawn' && adc.genesis__Application__r.genesis__Status__c !='Decline_Manual_Review' &&
			   adc.genesis__Parent_Application_Document_Category__r.name != 'Generated Documents' && adc.genesis__Application__r.owner.Name != 'Review Queue')
			{
				appList.add(adc.genesis__Application__c);
			}

		}
		System.debug('>>>>>>>>>>> APPLIST >>>>>>>>'+appList);
		if(appList.size()>0)
		{
			// -- CLS - 1018
			ID jobID = System.enqueueJob(new MWQueuebleJob(appList));
			System.debug('>>> 1'+jobID);
			calloutsScheduled.add(new MCCallout__c(Job_ID__c = jobID, Application__c=appList[0], Status__c = 'Queued', Send_on__c=System.now(), Duration__c = system.now().getTime()-System.now().getTime()));

			if(calloutsScheduled.size()>0) {
				insert calloutsScheduled;
			}
			// -- CLS - 1018 ends
		}
	}

	public static void updateADCStatus(List<genesis__Application_Document_Category__c > adcList, Map<Id, genesis__Application_Document_Category__c> oldMap){

		List<String> appList                 = new List<String>();

		for(genesis__Application_Document_Category__c adc:adcList) {
			appList.add(adc.genesis__Application__c);
		}

		Map<Id,Id> parneteSignMap = new Map<Id,Id>();
		for(genesis__Application_Document_Category__c esdoc: [Select Id, Name, genesis__Application__c, genesis__Parent_Application_Document_Category__c
		                                                      From genesis__Application_Document_Category__c
		                                                      Where genesis__Application__c IN :appList and genesis__Parent_Application_Document_Category__r.name='ESign Documents']) {
			parneteSignMap.put(esdoc.genesis__Application__c, esdoc.genesis__Parent_Application_Document_Category__c);
		}

		Map<String, Boolean> parent_adc_is_generated_doc = new Map<String, Boolean>();
		for(genesis__Application_Document_Category__c parentADC : [Select Id, genesis__Parent_Application_Document_Category__r.name
		                                                           From genesis__Application_Document_Category__c
		                                                           Where Id IN: adcList AND genesis__Parent_Application_Document_Category__r.name ='Generated Documents']) {
			parent_adc_is_generated_doc.put(parentADC.Id, true);
		}

		for(genesis__Application_Document_Category__c adc:adcList) {

			if(oldMap.get(adc.id).Box_URl__c!=adc.Box_URl__c && adc.Box_URl__c!=null && (oldMap.get(adc.id).genesis__Status__c=='OPEN' || oldMap.get(adc.id).genesis__Status__c=='REJECTED') &&
			   adc.genesis__Parent_Application_Document_Category__r.name != 'ESign Documents')
			{
				if(parent_adc_is_generated_doc.get(adc.Id) != null && parent_adc_is_generated_doc.get(adc.Id)) {
					adc.genesis__Status__c ='CLEARED';
				}
				else{
					adc.genesis__Status__c ='SUBMITTED';
				}
			}

			/* CLS-559 */
			if(adc.genesis__Parent_Application_Document_Category__c==parneteSignMap.get(adc.genesis__Application__c) && oldMap.get(adc.id).Box_URl__c!=adc.Box_URl__c && adc.Box_URl__c!=null) {
				adc.genesis__Status__c ='CLEARED';
			}

		}
	}

	public static void countRequiredDocs(List<genesis__Application_Document_Category__c > adcList){

		System.debug('-----In count requiredDoc ----');
		List<String> accList                 = new List<String>();

		set<ID> appIdSet                     = new Set<id>();
		Map<Id, Integer> requiredDocs        = new Map<Id, Integer>();

		Map<Id,Set<String>> parentDocMap     = new Map<Id,Set<String>>();
		Set<String> parentDocList            = new Set<String>();

		for(genesis__Application_Document_Category__c adc:adcList) {
			accList.add(adc.Account__c);
			appIdSet.add(adc.genesis__Application__c);
			Set<String> parentDoc   = new Set<String>();
			parentDocMap.put(adc.genesis__Application__c, parentDoc);
		}

		Map<Id, boolean> accMap                      = MW_WebhookHelper.applicationHasYodleeDetails(accList);// accountId, True

		Map<Id, genesis__Applications__c> appMap = new Map<Id, genesis__Applications__c>([SELECT Id, is_Plaid_Asset_Available__c
																						FROM genesis__Applications__c
																						WHERE Id in :appIdSet]);
		Map<String, boolean> appWithYodleeOrPlaidMap        = new Map<String, boolean>();
		Map<String, boolean> appWithNYodleeOrPlaidMap       = new Map<String, boolean>();

		for(genesis__Application_Document_Category__c adc:adcList) {
			if(accMap.get(adc.Account__c)!=null || appMap.get(adc.genesis__Application__c).is_Plaid_Asset_Available__c) {
				appWithYodleeOrPlaidMap.put(adc.genesis__Application__c, true);
			}
			else {
				appWithNYodleeOrPlaidMap.put(adc.genesis__Application__c, false);
			}
		}

		if(appWithNYodleeOrPlaidMap.size()>0) {
			for(genesis__Application_Document_Category__c adc:[SELECT Id,genesis__Application__c,genesis__Parent_Application_Document_Category__r.name,
																											 genesis__Required__c, Box_URl__c from genesis__Application_Document_Category__c
																											 where genesis__Application__c in:appWithNYodleeOrPlaidMap.keyset()
																											 AND genesis__Parent_Application_Document_Category__r.name != 'ESign Documents'
																											 AND genesis__Parent_Application_Document_Category__r.name != 'Root'
																											 AND genesis__Parent_Application_Document_Category__r.name != 'Generated Documents'
																											 AND Name!='Root'
																											 AND Name!='Bank Statements'
																											 AND Name!='Paystubs'
																											 AND genesis__Required__c = true
																																									AND genesis__Application__r.agentVerificationPendingFlag__c=false Order by Box_URl__c DESC NULLS LAST]) {

				if(adc.Box_URl__c != null && adc.genesis__Parent_Application_Document_Category__r.name !='Verification Documents'
					 && adc.genesis__Parent_Application_Document_Category__r.name !='Self Employed Documents') {
					Set<String> parentDoc     =  parentDocMap.get(adc.genesis__Application__c);
					parentDoc.add(adc.genesis__Parent_Application_Document_Category__r.name);
					parentDocMap.put(adc.genesis__Application__c, parentDoc);
				}

				if( parentDocMap.size()>0 && adc.Box_URl__c == null) {
					Set<String> parentDoc = parentDocMap.get(adc.genesis__Application__c);
					if(!parentDoc.contains(adc.genesis__Parent_Application_Document_Category__r.name))
					{
						if(requiredDocs.get(adc.genesis__Application__c)==null)
							requiredDocs.put(adc.genesis__Application__c, 1);
						else
							requiredDocs.put(adc.genesis__Application__c, requiredDocs.get(adc.genesis__Application__c)+1);
					}

				}
			}
		}

		if(appWithYodleeOrPlaidMap.size()>0) {
			for(genesis__Application_Document_Category__c adc:[SELECT Id,genesis__Application__c, genesis__Required__c, Box_URl__c,
																											 genesis__Parent_Application_Document_Category__r.name from genesis__Application_Document_Category__c
																											 where genesis__Application__c in:appWithYodleeOrPlaidMap.keyset()
																											 AND genesis__Parent_Application_Document_Category__r.name != 'ESign Documents'
																											 AND genesis__Parent_Application_Document_Category__r.name != 'Root'
																											 AND genesis__Parent_Application_Document_Category__r.name != 'Generated Documents'
																											 AND Name!='Root'
																											 AND Name!='Bank Statements'
																											 AND (NOT Name like 'Bank Statement%')
																											 AND Name!='Paystubs'
																											 AND genesis__Required__c = true
																																									AND genesis__Application__r.agentVerificationPendingFlag__c=false Order by Box_URl__c DESC NULLS LAST]) {

				if(adc.Box_URl__c != null && adc.genesis__Parent_Application_Document_Category__r.name !='Verification Documents'
					 && adc.genesis__Parent_Application_Document_Category__r.name !='Self Employed Documents') {
					Set<String> parentDoc     =  parentDocMap.get(adc.genesis__Application__c);
					parentDoc.add(adc.genesis__Parent_Application_Document_Category__r.name);
					parentDocMap.put(adc.genesis__Application__c, parentDoc);
				}

				if( parentDocMap.size()>0 && adc.Box_URl__c == null) {
					Set<String> parentDoc = parentDocMap.get(adc.genesis__Application__c);
					if(!parentDoc.contains(adc.genesis__Parent_Application_Document_Category__r.name))
					{
						if(requiredDocs.get(adc.genesis__Application__c)==null)
							requiredDocs.put(adc.genesis__Application__c, 1);
						else
							requiredDocs.put(adc.genesis__Application__c, requiredDocs.get(adc.genesis__Application__c)+1);
					}
				}
			}
		}

		if(appIdSet.size()>0) {

			List<genesis__Applications__c> applist = new List<genesis__Applications__c>();

			for(genesis__Applications__c app: [select Id, Required_Docs_Count__c,agentVerificationPendingFlag__c from genesis__Applications__c where Id in:appIdSet and agentVerificationPendingFlag__c=false]) {
				if(requiredDocs.get(app.id)!=null && requiredDocs.size()>0) {
					app.Required_Docs_Count__c = requiredDocs.get(app.id);
					app.agentVerificationPendingFlag__c= false;
				}
				else{
					app.Required_Docs_Count__c = 0;
				}

				applist.add(app);
			}

			if(applist.size()>0)
				update applist;
		}
	}

	// Method for CLS-1031 - please revisit for optimization changes
	public static void updateADCStructure(List<ints__Yodlee_User_Credentials__c > yuaList){

		Set<Id> accId = new set<Id>();

		for(ints__Yodlee_User_Credentials__c yua:yuaList) {
			accId.add(yua.ints__Account__c);
		}

		//List<string> appStatustoavoid = new List<string>{'agent_document_verification_pending'};

		List<genesis__Application_Document_Category__c> adctoUpdate  = new List<genesis__Application_Document_Category__c>();

		for(genesis__Application_Document_Category__c apdoc:[select Id, Name, genesis__Application__c, genesis__Application__r.genesis__Account__c,
		                                                     genesis__Status__c, genesis__Parent_Application_Document_Category__c,
		                                                     genesis__Application__r.genesis__Status__c
		                                                     from genesis__Application_Document_Category__c where
		                                                     genesis__Parent_Application_Document_Category__r.name='Bank Statements' and
		                                                                                                            genesis__Application__r.genesis__Account__c =:accId and
		                                                                                                                                                          /*genesis__Application__r.genesis__Status__c IN:appStatustoavoid and */
		                                                                                                                                                          genesis__Status__c='OPEN']) {

			adctoUpdate.add(apdoc);
		}

		if(adctoUpdate.size()>0)
			update adctoUpdate;
	}

	// Method for LOP-182 - please revisit for optimization changes
	public static void refreshADCStructure(List<Id > appIds){
		List<genesis__Application_Document_Category__c> adctoUpdate  = new List<genesis__Application_Document_Category__c>();

		for(genesis__Application_Document_Category__c apdoc:[select Id, Name, genesis__Application__c, genesis__Application__r.genesis__Account__c,
															 genesis__Status__c, genesis__Parent_Application_Document_Category__c,
															 genesis__Application__r.genesis__Status__c
															 from genesis__Application_Document_Category__c where
															 genesis__Parent_Application_Document_Category__r.name='Bank Statements' and
															 genesis__Application__c in :appIds and
															 genesis__Status__c='OPEN']) {
			adctoUpdate.add(apdoc);
		}

		if(adctoUpdate.size()>0)
		  update adctoUpdate;
	}

}