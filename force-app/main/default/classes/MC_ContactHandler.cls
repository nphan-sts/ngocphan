public class MC_ContactHandler {

	/*
	    This method update the applicaiton reference on contact - Required for the MC.
	 */
	@InvocableMethod
	public static void updateContct(List<genesis__Applications__c> newList){

		Map<Id,genesis__Applications__c> appMap = new Map<Id,genesis__Applications__c>();

		for(genesis__Applications__c app: newList) {
			appMap.put(app.genesis__Account__c, app);
		}

		List<contact> updateCon = new List<contact>();
		for(Contact con: [select Id, Accountid from contact where AccountId in:appMap.keyset()]) {
			con.application__c = appMap.get(con.Accountid).id;
			con.Application_Status_New__c = appMap.get(con.Accountid).genesis__Status__c;
			updateCon.add(con);
		}

		if(updateCon.size()>0) {
			update updateCon;
		}

	}
}