trigger CustomAutomatedPaymentSetupTrigger on loan__Automated_Payment_Setup__c (before insert) {
    
    loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
    
    if(org.loan__Disable_Triggers__c == false){
        Map<String,String> oldType = new Map<String,String>();
        List<loan__Automated_Payment_Setup__c> APS = new list<loan__Automated_Payment_Setup__c>();
        List<Id> contractId= new List<Id>();
        for(loan__Automated_Payment_Setup__c newAPS : trigger.new){
            contractId.add(newAPS.loan__CL_Contract__c);
        }
        APS = [Select id,loan__CL_Contract__r.id,loan__Type__c,loan__Active__c from loan__Automated_Payment_Setup__c where loan__CL_Contract__c IN:contractId
               and loan__Type__c = 'Recurring' and loan__Active__c = true LIMIT 1];
        for(loan__Automated_Payment_Setup__c temp : APS)
            oldType.put(String.valueOf(temp.loan__CL_Contract__r.id),temp.loan__Type__c);
        
        if(oldType.size() > 0){
            for(loan__Automated_Payment_Setup__c newAPS : trigger.new){
                if(oldType.containsKey(String.valueOf(newAPS.loan__CL_Contract__c)) && newAPS.loan__Type__c.equalsIgnoreCase('Recurring'))
                  newAPS.addError('There can be only one Active recurring APS on a contract');  
            }
        }
    }   
}