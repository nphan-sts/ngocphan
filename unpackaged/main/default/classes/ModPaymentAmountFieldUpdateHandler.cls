public with sharing class ModPaymentAmountFieldUpdateHandler
 {

    public static void updateEndDateAndPaymentAmountModField(Set<String> contractIds) {

        Map<Id, loan__Loan_Account__c>updateContract = new Map<Id, loan__Loan_Account__c>();

        for (List<loan__Loan_Account__c> clContracts : [SELECT 
                                                                Id, loan__Payment_Amount__c, Skipped_a_Pay__c, U_LoanModForbearDt__c, U_LoanModForbearance__c, Mod_End_Date__c, Mod_Payment_Amount__c
                                                                FROM loan__Loan_Account__c 
                                                                WHERE id IN :contractIds
                                                                WITH SECURITY_ENFORCED])
        {
            for(loan__Loan_Account__c clContract : clContracts) {

                //for skipped a pay
                if (clContract.Skipped_a_Pay__c) {
                    clContract.Mod_Payment_Amount__c = 0;
                    clContract.Mod_End_Date__c = clContract.U_LoanModForbearDt__c.addDays(-1).addMonths(Integer.valueOf(clContract.U_LoanModForbearance__c));

                    updateContract.put(clContract.id, clContract);
                }

            }                                                    
        }

        if (updateContract.values().size() > 0) {
            Database.update(updateContract.values(), false);
        }
    }

}