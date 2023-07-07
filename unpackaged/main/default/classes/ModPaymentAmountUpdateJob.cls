public with sharing class ModPaymentAmountUpdateJob implements Database.Batchable<sObject> {

    String query;

    public ModPaymentAmountUpdateJob() {

    }
    public ModPaymentAmountUpdateJob(String query) {
        this.query = query;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
          
        if (String.isBlank(query)) {
            query = 'SELECT Id from loan__Loan_Account__c ' +
            'WHERE Mod_Payment_Amount__c = null and Mod_End_Date__c = null ' +
            'and '+
            '(U_LoanModTermExt__c != null  '+
            'or U_LoanModForbearance__c != null '+
            'or U_LoanModForbearDt__c != null '+
            'or U_LoanModRateLengt__c != null '+
            'or U_LoanModRateEffDt__c != null '+
            'or U_LoanModRate__c != null '+
            'or Hardship_Reason__c != null '+
            'or Hardship_Request_Date__c != null '+
            'or Hardship_New_Maturity_Date__c != null '+
            'or Loan_Mod_Offer__c != null '+
            'or Loan_Mod_Offer_Length_months__c != null '+
            'or U_LoanModExtDt__c != null)';       
        }

        System.debug('<< Initial Query >>' +query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<loan__Loan_Account__c> scope) {
        if(!scope.isEmpty()){
            list<loan__Loan_Account__c> loanContracts = new list<loan__Loan_Account__c>(scope);

            Set<String> setContractIds = new Set<String>();

            for(loan__Loan_Account__c contract : loanContracts) {
                setContractIds.add(contract.Id);
            }

            ModPaymentAmountFieldUpdateHandler.updateEndDateAndPaymentAmountModField(setContractIds);
        }
    }

    public void finish(Database.BatchableContext bc) {
        // update job's last run time in custom         
    } 
}