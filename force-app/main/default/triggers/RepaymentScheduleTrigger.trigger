trigger RepaymentScheduleTrigger on loan__Repayment_Schedule_Summary__c (after insert) {

    if(!loan.CustomSettingsUtil.getOrgParameters().loan__Disable_Triggers__c) { 

        RepaymentScheduleHandler handler = new RepaymentScheduleHandler(trigger.new, trigger.newMap, trigger.oldMap);

        if (trigger.isAfter && trigger.isInsert) {
            handler.afterInsert();
        }
    }
}