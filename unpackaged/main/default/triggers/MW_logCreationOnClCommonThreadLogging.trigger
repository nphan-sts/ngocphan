trigger MW_logCreationOnClCommonThreadLogging on clcommon__Thread_Logging__c(
	after insert,
	after update
) {
	for (clcommon__Thread_Logging__c entry : Trigger.new) {
		MW_LogUtility_Queueable.Log log = new MW_LogUtility_Queueable.Log();
		log.apexClass = 'clcommon__Thread_Logging__c';
		log.label = 'Thread Logging';
		log.message = JSON.serialize(entry);

		if (
			entry.clcommon__Status__c == 'Failure' ||
			entry.clcommon__Status__c == 'Aborted'
		) {
			log.type = 'Error';
		} else if (String.isBlank(entry.clcommon__Status__c) == true) {
			log.type = 'Warning';
		} else {
			log.type = 'Info';
		}

		//System.enqueueJob(new MW_LogUtility_Queueable(log));
	}

}