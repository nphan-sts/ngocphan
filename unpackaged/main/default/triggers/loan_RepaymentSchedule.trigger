trigger loan_RepaymentSchedule on loan__Repayment_Schedule_Summary__c (after insert) {

    if(!loan.CustomSettingsUtil.getOrgParameters().loan__Disable_Triggers__c) { 

        loan_RepaymentScheduleHandler handler = new loan_RepaymentScheduleHandler(trigger.new, trigger.newMap, trigger.oldMap);

        if (trigger.isAfter) {
            if(trigger.isInsert) {
                handler.afterInsert();
            }
        }
    }

}