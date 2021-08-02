trigger MW_logCreationOnClCommonBatchProcessLog on clcommon__Batch_Process_Log__c(
	after insert,
	after update
) {
	private static String apexClass = 'clcommon__Batch_Process_Log__c';
	private static String label = 'Batch Process Log';

	loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
	if(org.loan__Disable_Triggers__c) {
		return;
	}
	
	for (clcommon__Batch_Process_Log__c entry : Trigger.new) {
		String type = '';
		if (entry.clcommon__Type__c == 'Exception') {
			type = 'Error';
		} else if (entry.clcommon__Type__c == 'Warning') {
			type = entry.clcommon__Type__c;
		} else if (String.isBlank(entry.clcommon__Type__c) == true) {
			type = 'Warning';
		} else {
			type = 'Info';
		}

		new MW_LogTriggerHelper().construct(entry.Name, apexClass, label, type, JSON.serialize(entry));
	}
}