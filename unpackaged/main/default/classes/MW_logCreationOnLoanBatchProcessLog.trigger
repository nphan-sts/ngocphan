trigger MW_logCreationOnLoanBatchProcessLog on loan__Batch_Process_Log__c(
	after insert,
	after update
) {
	private static String apexClass = 'loan__Batch_Process_Log__c';
	private static String label = 'Batch Process Log';

	loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
	if(org.loan__Disable_Triggers__c) {
		return;
	}

	for (loan__Batch_Process_Log__c entry : Trigger.new) {
		
		String type = '';
		if (entry.loan__Type__c == 'Exception') {
			type = 'Error';
		} else if (entry.loan__Type__c == 'Warning') {
			type = entry.loan__Type__c;
		} else if (String.isBlank(entry.loan__Type__c) == true) {
			type = 'Warning';
		} else {
			continue;
		}

		new MW_LogTriggerHelper().construct(entry.Name, apexClass, label, type, JSON.serialize(entry));

	}
}