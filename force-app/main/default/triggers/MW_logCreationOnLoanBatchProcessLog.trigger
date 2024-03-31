trigger MW_logCreationOnLoanBatchProcessLog on loan__Batch_Process_Log__c(before insert, after insert, after update) {
    loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
    if (org.loan__Disable_Triggers__c) {
        return;
    }

    LoanBatchProcessHandler handle = new LoanBatchProcessHandler(Trigger.new, Trigger.newMap, Trigger.oldMap);

    if (Trigger.isBefore && Trigger.isInsert) {
        handle.beforeInsert();
    }

    if (Trigger.isAfter) {
        if (Trigger.isUpdate)
            handle.afterUpdate();
        if (Trigger.isInsert)
            handle.afterInsert();
    }
}