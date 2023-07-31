trigger MC_CustomTriggerOnLead on Lead (before delete) {
	if(!genesis.CustomSettingsUtil.getOrgParameters().genesis__Disable_Triggers__c) {
    	//add action for project license date trigger handler
    	MW_TriggerHandlerUtility th = new MW_TriggerHandlerUtility();
    	th.bind(MW_TriggerHandlerUtility.Evt.beforedelete, new MC_DeleteLeadOfferHandler());
    
    	//execute bindings
    	th.manage();
	}
}