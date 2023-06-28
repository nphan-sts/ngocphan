public with sharing class ModPaymentAmountFieldUpdateHandler {

    public static void updateModField(Set<String> contractIds) {

        List<loan__Loan_Account__c> updateContract = new List<loan__Loan_Account__c>();

        for (List<loan__Loan_Account__c> clContracts : [SELECT 
                                                                Id, loan__Pmt_Amt_Cur__c, 
                                                                (select id, clcommon__Sequence_Number__c, clcommon__Payment_Amount__c, clcommon__Number_Of_Payments__c,
                                                                clcommon__Payment_Start_Date__c  
                                                                FROM loan__Repayment_Plan__r
                                                                ) 
                                                                FROM loan__Loan_Account__c 
                                                                WHERE id IN :contractIds
                                                                WITH SECURITY_ENFORCED])
        {
            for(loan__Loan_Account__c clContract : clContracts) {

                //if there is a repayment plan
                if (clContract.loan__Repayment_Plan__r.size() > 0) {

                    clContract.Mod_Payment_Amount__c = clContract.loan__Repayment_Plan__r[0].clcommon__Payment_Amount__c;
                    clContract.Mod_End_Date__c = clContract.loan__Repayment_Plan__r[0].clcommon__Payment_Start_Date__c.addMonths(Integer.valueOf(clContract.loan__Repayment_Plan__r[0].clcommon__Number_Of_Payments__c));

                    updateContract.add(clContract);
                }
            }                                                    
        }

        if (updateContract.size() > 0) {
            update updateContract;
        }
    }

}