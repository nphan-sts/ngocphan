/*  Trigger fires before insert and before update of Automated Payment Setup object
* Modified by      Date            JIRA ticket number
* Mohan Kiran   06/07/2022           LSP-473

******************Modification History*****************************************************************
******************************************************************************/

trigger CustomAutomatedPaymentSetupTrigger on loan__Automated_Payment_Setup__c (before insert, before update) {
    
    loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
    
    if(org.loan__Disable_Triggers__c == false){   
        //Variable declaration
        Map<String,String> oldType = new Map<String,String>();
        List<loan__Automated_Payment_Setup__c> apsList = new list<loan__Automated_Payment_Setup__c>();
        List<Id> contractId= new List<Id>();
        //Call Handler Class
        APSTriggerHandler callHandler = new APSTriggerHandler();
        //Call Handler methods - Before Insert and Before Update.
        if(trigger.isBefore){
            //LSP-473 - Send the loan Id and APS Payment mode details to the handler method
            if(trigger.isInsert){
                callHandler.beforeInsert(Trigger.new);
            } 
            if(trigger.isUpdate){
                callHandler.beforeUpdate(Trigger.new);
            }
        }
    }
    
}