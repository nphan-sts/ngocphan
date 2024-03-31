public with sharing class LoanAccountHandler {
    
    List<loan__Loan_Account__c> newRecords;
    Map<Id, loan__Loan_Account__c> oldMap;
    Map<Id, loan__Loan_Account__c> newMap;

    public LoanAccountHandler(List<loan__Loan_Account__c> newRecords, Map<Id, loan__Loan_Account__c> newMap, Map<Id, loan__Loan_Account__c> oldMap) {
        this.newRecords = newRecords;
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

    public void beforeUpdate() {
        List<loan__Bank_Account__c> bankAccToBeDeactivated = new List<loan__Bank_Account__c>();
        try {

            set<id> appId = new Set<id>();
            for (loan__Loan_Account__c newLoanAcc : newRecords) {
                //LPC-938 for skipped a pay
                if (newLoanAcc.Mod_End_Date__c == null && newLoanAcc.Skipped_a_Pay__c && newLoanAcc.U_LoanModForbearDt__c != null && newLoanAcc.U_LoanModForbearance__c != null) {
                    newLoanAcc.Mod_Payment_Amount__c = null;
                    newLoanAcc.Mod_End_Date__c = newLoanAcc.U_LoanModForbearDt__c.addDays(-1).addMonths(Integer.valueOf(newLoanAcc.U_LoanModForbearance__c));
                }

                loan__Loan_Account__c oldLoanAcc = oldMap.get(newLoanAcc.id);
                system.debug('newLoanAcc.Application__c------->' + newLoanAcc.Application__c);
                if (oldLoanAcc.loan__Loan_Status__c != newLoanAcc.loan__Loan_Status__c && newLoanAcc.loan__Loan_Status__c == 'Closed - obligations met' && newLoanAcc.Application__c != null){
                    appId.add(newLoanAcc.Application__c);
                }
            }

            for (genesis__applications__c app : [SELECT id, name, bank_account__c FROM genesis__applications__c WHERE ID IN :appId]) {
                bankAccToBeDeactivated.add(new loan__Bank_Account__c(Id=app.bank_account__c, loan__Active__c = false));
            }
            if (bankAccToBeDeactivated.size() > 0) {
                update bankAccToBeDeactivated;
            }
        } catch (Exception e) {
            MW_LogUtility.error('LoanAccountHandler', 'beforeUpdate', bankAccToBeDeactivated, e);
        }
    }
}