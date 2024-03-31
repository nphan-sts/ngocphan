/* ****************Modification History*****************************************************************
 * Modified by      Date            JIRA number
 *Bhavya Maliwal  2022/07/07    LSP-881 If Bank Account gets Inactive update the APS and mark it inactive.
 ******************Modification History*****************************************************************/
trigger CustomBankAccount on loan__Bank_Account__c(before insert, before update, after update, before delete) {
    CustomBankAccountHandler handler = new CustomBankAccountHandler(
        Trigger.new,
        Trigger.old,
        Trigger.newMap,
        Trigger.oldMap
    );
    if (!genesis.CustomSettingsUtil.getOrgParameters().genesis__Disable_Triggers__c) {
        if (Trigger.isInsert && Trigger.isBefore) {
            handler.beforeInsert();
        }
        if (Trigger.isUpdate && Trigger.isBefore) {
            handler.beforeUpdate();
        }
        if (Trigger.isUpdate && Trigger.isAfter) {
            /* Bhavya Maliwal : LSP-881  : Below method checks for the bank account and there respective APS
             and if Bank Account gets inactive it marks the corresponding APS Inactive*/

            handler.afterUpdate();
        }

        if (Trigger.isDelete && Trigger.isBefore) {
            system.debug('trigger.old' + Trigger.old);
            /* LSP-1011  : When a bank account record gets deleted then the related APS record will need to be deactivated*/
            handler.beforeDelete();
        }
    }

}