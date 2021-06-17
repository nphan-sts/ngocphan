global class MW_DeleteLastNDaysRecords implements Database.batchable<sObject>, Schedulable {
	//Schedulable Process
	global void execute(SchedulableContext sc) {

		MW_DeleteLastNDaysRecords BDel = new MW_DeleteLastNDaysRecords();

		Integer days = MW_Settings__c.getInstance().Leads_Clear_Days__c.intValue();
		BDel.query = 'SELECT id, CreatedDate FROM Lead WHERE CreatedDate < LAST_N_DAYS: ' + days;

		ID batchprocessid = Database.executeBatch(BDel, 75);
		System.debug('Returned batch process ID: ' + batchProcessId);
	}

	//Batchable Process
	public String query;

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		delete scope;
		DataBase.emptyRecycleBin(scope);
	}

	global void finish(Database.BatchableContext BC){
	}
}