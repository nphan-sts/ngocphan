/* ****************Modification History*****************************************************************
* Modified by      Date            JIRA number
*Bhavya Maliwal  2022/07/07    LSP-881 If Bank Account gets Inactive update the APS and mark it inactive. 
******************Modification History*****************************************************************/
trigger CustomBankAccount on loan__Bank_Account__c (before insert,before update,after update) {
    if (!genesis.CustomSettingsUtil.getOrgParameters().genesis__Disable_Triggers__c) {
        
        if((trigger.isUpdate || trigger.isInsert) && trigger.isBefore) {
            
            for(loan__Bank_Account__c ba: trigger.new){
                if(ba.Unmasked_Bank_Account_Number__c != null){
                    ba.loan__Bank_Account_Number__c = '*******' + ba.Unmasked_Bank_Account_Number__c.right(4);
                }
                else{
                    ba.loan__Bank_Account_Number__c = ba.Unmasked_Bank_Account_Number__c;
                }
                if(ba.Account_Number__c != null){
                    ba.Account_Number_Con_Info__c = '*******' + ba.Account_Number__c.right(4);
                }
                else{
                    ba.Account_Number_Con_Info__c = ba.Account_Number__c;
                }
                
            }
            
        }
        if(trigger.isUpdate && trigger.isAfter) {
            MW_SynchronizeHandler.postBankAccountDetailsOnWebHook(trigger.OldMap,trigger.NewMap);
            /* Bhavya Maliwal : LSP-881  : Below method checks for the bank account and there respective APS
and if Bank Account gets inactive it marks the corresponding APS Inactive*/
            CustomBankAccountHandler checkAPS=new CustomBankAccountHandler();
            checkAPS.updateAPSInactive(trigger.new, trigger.oldMap);
            //end LSP-881
        }
        
    }
}