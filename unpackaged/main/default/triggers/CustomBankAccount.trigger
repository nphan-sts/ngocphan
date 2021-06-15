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
        }
    
    }
}