@RestResource(urlMapping='/SelectedLeadOffer')
global with sharing class MW_WSSelectedLeadOffer {

	public class SelectedOffer {
		public String lead_guid;
		public Integer key;
	}

	//CLS-1188 Update Lead to Partner_pre_qual_shown
	public static void updateLeadStatus(String lead_guid){
		List<Lead> leadList = [Select id, lead_guid__c, status From Lead Where lead_guid__c =: lead_guid];
		if(leadList.size() > 0) {
			leadList[0].status = 'partner_pre_qual_shown';
			update leadList;
		}
	}

	@HttpPost
	global static String create() {
		RestRequest req = Restcontext.request;
		String jsonData = req.requestBody.toString();
		SelectedOffer leadObj = (SelectedOffer) JSON.deserialize(jsonData, SelectedOffer.class);
		try {
			List<Lead_Offer__c> leadOffersList = [SELECT id, Lead__c, Lead__r.status, Key__c, Selected_Offer__c FROM Lead_Offer__c WHERE Lead__r.lead_guid__c =: leadObj.lead_guid];
			Boolean foundLeadOffer = false;
			for(Lead_Offer__c leadOffer : leadOffersList) {
				if(leadOffer.key__c == leadObj.key) {
					leadOffer.Selected_Offer__c = true;
					foundLeadOffer = true;
				}
				else{
					leadOffer.Selected_Offer__c = false;
				}
			}
			if(foundLeadOffer) {
				update leadOffersList;
				updateLeadStatus(leadObj.lead_guid);
				return 'Success';
			}
			else{
				return 'Offer Not Found';
			}
		}
		catch(Exception e){
			MW_LogUtility.error('MW_WSSelectedLeadOffer', '', leadObj.lead_guid, 'create', e);
			System.debug('Error: ' + e.getLineNumber() + ' Desc. ' + e.getMessage()+' Stack: '+e.getStackTraceString());
			System.debug(logginglevel.error,'line number'+e.getLineNumber());
			System.debug(logginglevel.error,'error stackTrace'+e.getStackTraceString());
			return 'Error: ' + e.getLineNumber() + ' Desc. ' + e.getMessage()+' Stack: '+e.getStackTraceString();
		}
	}
}