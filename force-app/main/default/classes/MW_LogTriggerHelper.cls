public with sharing class MW_LogTriggerHelper {
    public MW_LogUtility.JobLog construct(String name, String apexclass, String label, String type, String message) {

        MW_LogUtility.JobLog log = new MW_LogUtility.JobLog();
        log.apexClass = apexclass;
		log.label = label;
		log.message = message;
        log.type = type;


        List<String> facetList = new List<String>();
		facetList.add('severity:' + log.type);
		External_Logger__e logEvent = new External_Logger__e(
			Log_Id__c = name,
			Serialized_Log__c = JSON.serialize(log)
		);

		Database.SaveResult result = EventBus.publish(logEvent);

		if (!result.isSuccess()) {
			for (Database.Error err : result.getErrors()) {
				System.debug('Error returned: ' + err.getStatusCode() +	' - ' +	err.getMessage());
			}
		}

		return log;
    }
}