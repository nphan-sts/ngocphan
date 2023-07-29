global class MW_MissingInvestorAlert implements Database.batchable<sObject>,Database.AllowsCallouts {
	global String query;

	global Database.QueryLocator start(Database.BatchableContext bc) {
		String genesis_status = System.Label.App_Status;
		String statuslist = '' ;
		System.debug('value' + genesis_status);
		List<string> genesis_status_list = new List<string>(genesis_status.Split(','));
		System.debug('listOfNames' + genesis_status_list);
		for(String str : genesis_status_list)
		{	
			statuslist += '\'' + str.trim() + '\',';
			statuslist = statuslist.lastIndexOf(',') > 0 ? statuslist.substring(0,statuslist.lastIndexOf(',')) + ',' : statuslist ;
		}
		System.debug('Names' + statuslist);
		statuslist = statuslist.removeEnd(',');
		query = 'SELECT ID, genesis__Status__c, Investor__c, Name FROM genesis__Applications__c Where genesis__Status__c IN ('+statuslist+') and Investor__c=null';
		System.debug('query' + query);
		return Database.getQueryLocator(query);
	}

	// Execute method
	global void execute(Database.BatchableContext BC, List<genesis__Applications__c> scope){
		MW_LogUtility.beginBatch();
		for (genesis__Applications__c s : scope) {
			Map<String, Object> msg = new Map<String, Object>();
			msg.put('title', 'No Investor Alert');
			msg.put('whoFor', s.Name);

			MW_LogUtility.warn('MW_MissingInvestorAlert', 'execute', msg);
		}
		MW_LogUtility.sendBatch();
	}

    // Finish Method
	global void finish(Database.BatchableContext BC) { }
}