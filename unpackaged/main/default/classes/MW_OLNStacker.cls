public with sharing class MW_OLNStacker {

	public static void parseOLNStacker(List<genesis__Applications__c> apps, String rawXml){
		//prase the xml lazy parsing

		/***CLS-1142 will remove after FE make changes on Sunset2***/
		if(Test.isRunningTest()) {
			Double olnaf1194 = Double.valueOf(rawXml.substringBetween('<Indicator name="OLNAF1194">', '</Indicator>'));
			genesis__Applications__c appOLN = new genesis__Applications__c(id=apps[0].Id);
			appOLN.OLN_Stacker_Status__c = olnaf1194;
			update appOLN;
		}
		if((apps[0].genesis__Status__c == 'Stacker_Check_Passed' || apps[0].genesis__Status__c == 'agent_document_verification_pending') && apps[0].owner.name == 'Final_Verification') {
			/***End Remove Section***/
			Double olnaf1194 = Double.valueOf(rawXml.substringBetween('<Indicator name="OLNAF1194">', '</Indicator>'));
			genesis__Applications__c appOLN = new genesis__Applications__c(id=apps[0].Id);
			appOLN.OLN_Stacker_Status__c = olnaf1194;
			update appOLN;
		}
	}
}