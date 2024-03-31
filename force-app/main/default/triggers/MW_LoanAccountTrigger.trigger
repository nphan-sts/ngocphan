trigger MW_LoanAccountTrigger on loan__Loan_Account__c(before update) {
    if (!loan.CustomSettingsUtil.getOrgParameters().loan__Disable_Triggers__c) {
        LoanAccountHandler handler = new LoanAccountHandler(Trigger.new, Trigger.newMap, Trigger.oldMap);
        if (Trigger.isUpdate && Trigger.isBefore) {
            handler.beforeUpdate();
        }
    }

}