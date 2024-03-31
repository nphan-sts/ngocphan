public class MC_UpdateLeadHandler {
	/*
	   This method update the applicaiton reference on lead - Required for the MC.
	 */
	@InvocableMethod
	public static void updateLead(List<genesis__Applications__c> newApps) {
		Map<String,Id> appMap = new Map<String,Id>();

		for(genesis__Applications__c app:newApps) {
			appMap.put(app.Lead_ID__c, app.Id);
		}

		List<Lead> updateLeads = new List<Lead>();

		for(Lead leadObj: [select Id, lead_guid__c from Lead where lead_guid__c in:appMap.keyset()]) {
			leadObj.application__c = appMap.get(leadObj.lead_guid__c);
			updateLeads.add(leadObj);
		}

		if(updateLeads.size()>0) {
			update updateLeads;
		}
	}
}