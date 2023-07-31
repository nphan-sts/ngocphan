public with sharing class MC_DeleteLeadOfferHandler implements MW_TriggerHandlerUtility.HandlerInterface {
	public void handle(){
		List<Lead_Offer__c> leadOfferDeleteList = new List<Lead_Offer__c>();
		for(Lead leadObj : (List<Lead>)Trigger.old) {
			List<Lead_Offer__c> leadOfferList = [SELECT id, Lead__c FROM Lead_Offer__c WHERE Lead__c =: leadObj.id];
			leadOfferDeleteList.addAll(leadOfferList);
		}
		if(leadOfferDeleteList.size() > 0) {
			delete leadOfferDeleteList;
		}
	}
}