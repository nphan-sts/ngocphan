trigger MW_logCreationOnClCommonBatchProcessLog on clcommon__Batch_Process_Log__c(
	after insert,
	after update
) {
	for (clcommon__Batch_Process_Log__c entry : Trigger.new) {
		MW_LogUtility_Queueable.Log log = new MW_LogUtility_Queueable.Log();
		log.apexClass = 'clcommon__Batch_Process_Log__c';
		log.label = 'Batch Process Log';
		log.message = JSON.serialize(entry);

		if (entry.clcommon__Type__c == 'Exception') {
			log.type = 'Error';
		} else if (entry.clcommon__Type__c == 'Warning') {
			log.type = entry.clcommon__Type__c;
		} else if (String.isBlank(entry.clcommon__Type__c) == true) {
			log.type = 'Warning';
		} else {
			log.type = 'Info';
		}

		//System.enqueueJob(new MW_LogUtility_Queueable(log));
	}

}