trigger MW_LoanAccountTrigger on loan__Loan_Account__c (before update) {
    if (!loan.CustomSettingsUtil.getOrgParameters().loan__Disable_Triggers__c) {
        set<id> AppId = new set<id>();
        if (Trigger.isUpdate){
            for(loan__Loan_Account__c newLoanAcc :Trigger.New){
                
                loan__Loan_Account__c oldLoanAcc = Trigger.oldMap.get(newLoanAcc.id);
                system.debug('newLoanAcc.Application__c------->' + newLoanAcc.Application__c);
                if(oldLoanAcc.loan__Loan_Status__c  != newLoanAcc.loan__Loan_Status__c && newLoanAcc.loan__Loan_Status__c == 'Closed - obligations met'&&
                   newLoanAcc.Application__c != null)
                    AppId.add(newLoanAcc.Application__c);
            }
            system.debug('AppId------>'+AppId);
            set<id>BankAccountId = new set<id>();
            list<genesis__applications__c> apps = [select id, name, bank_account__c from genesis__applications__c where ID IN :AppId];
            
            for(genesis__applications__c app:apps){
                BankAccountId.add(app.bank_account__c);
            }
            
            List<loan__Bank_Account__c> BankAccId = [select id, name, loan__Active__c from loan__Bank_Account__c where Id IN :BankAccountId];
            for(loan__Bank_Account__c ba:BankAccId){
                ba.loan__Active__c = false;
            }
            update BankAccId;
        }
        if(Trigger.isUpdate && Trigger.isBefore){
            MW_LoanAccountTriggerHandler.updatePlacedStatusFields(Trigger.new, Trigger.oldMap);
        }
    }
}