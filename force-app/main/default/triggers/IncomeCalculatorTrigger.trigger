trigger IncomeCalculatorTrigger on Income_Calculators__c (before insert, before update) {
    if(!genesis.CustomSettingsUtil.getOrgParameters().genesis__Disable_Triggers__c) { 
        IncomeCalculatorTriggerHandler handler = new IncomeCalculatorTriggerHandler(trigger.new, trigger.newMap, trigger.oldMap);
        if (trigger.isbefore){
            if(trigger.isInsert){
                handler.beforeInsert();
            }    
            if(trigger.isUpdate){
                handler.beforeUpdate();
            }
        }
    }
}