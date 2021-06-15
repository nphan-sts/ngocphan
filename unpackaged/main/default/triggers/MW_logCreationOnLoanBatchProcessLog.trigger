trigger MW_logCreationOnLoanBatchProcessLog on loan__Batch_Process_Log__c(
	after insert,
	after update
) {
	for (loan__Batch_Process_Log__c entry : Trigger.new) {
		MW_LogUtility_Queueable.Log log = new MW_LogUtility_Queueable.Log();
		log.apexClass = 'loan__Batch_Process_Log__c';
		log.label = 'Batch Process Log';
		log.message = JSON.serialize(entry);

		if (entry.loan__Type__c == 'Exception') {
			log.type = 'Error';
		} else if (entry.loan__Type__c == 'Warning') {
			log.type = entry.loan__Type__c;
		} else if (String.isBlank(entry.loan__Type__c) == true) {
			log.type = 'Warning';
		} else {
			log.type = 'Info';
		}

		//System.enqueueJob(new MW_LogUtility_Queueable(log));
	}

}