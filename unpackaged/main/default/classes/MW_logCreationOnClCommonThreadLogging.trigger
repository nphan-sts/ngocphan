trigger MW_logCreationOnClCommonThreadLogging on clcommon__Thread_Logging__c(
	after insert,
	after update
) {
	private static String apexClass = 'clcommon__Thread_Logging__c';
	private static String label = 'Thread Logging';
	loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();

	if(org.loan__Disable_Triggers__c) {
		return;
	}
	for (clcommon__Thread_Logging__c entry : Trigger.new) {
		
		String type = '';
		if (
			entry.clcommon__Status__c == 'Failure' ||
			entry.clcommon__Status__c == 'Aborted'
		) {
			type = 'Error';
		} else if (String.isBlank(entry.clcommon__Status__c) == true) {
			type = 'Warning';
		} else {
			if(entry.clcommon__Status__c == 'Success') {
				type = 'Info';
			}
			else {
				continue;
			}
		}

		new MW_LogTriggerHelper().construct(entry.Name, apexClass, label, type, JSON.serialize(entry));
	}
}