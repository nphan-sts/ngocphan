public with sharing class RepaymentScheduleHandler {
    final List<loan__Repayment_Schedule_Summary__c> newRecords;
    final Map<Id, loan__Repayment_Schedule_Summary__c> oldMap;
    final Map<Id, loan__Repayment_Schedule_Summary__c> newMap;

    final static Integer FIRST_PAYMENT = 1;
    final static Integer NUMBER_OF_PAYMENT = 2;
    final static Integer THIRD_PAYMENT = 3;

    //update contract payment amount when there is a modification in repayment schedule
    //when there are 3 repayment schedule inserted with priamry flag is true 
    //and reschedule payment with sequence number 1 has repayment amount != contract payment amount
    //and triggered only when there is a thrid payment with sequecen number = 3
    public RepaymentScheduleHandler(List< loan__Repayment_Schedule_Summary__c> newRecords, Map<Id, loan__Repayment_Schedule_Summary__c> oldMap, Map<Id, loan__Repayment_Schedule_Summary__c> newMap) {
        this.newRecords = newRecords;
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

    public void afterInsert() {
        updateContractPaymentAmount();
    }

    //LSP-1153
    private void updateContractPaymentAmount() {
        Set<String> contractIds = new Set<String>();
    
        for(loan__Repayment_Schedule_Summary__c rs : newRecords) {
    
            if (rs.loan__RSS_Seq__c == THIRD_PAYMENT && rs.loan__RSS_Primary_flag__c == true) {
                contractIds.add(rs.loan__RSS_Loan_Account__c);
            }
        }
    
        List<loan__Loan_Account__c> updateContract = new List<loan__Loan_Account__c>();
    
        for (List<loan__Loan_Account__c> clContracts : [SELECT 
                                                        Id, loan__Payment_Amount__c, 
                                                        (select id, loan__RSS_Seq__c, loan__RSS_Repayment_Amt__c, loan__RSS_Repayment_Dt__c 
                                                        FROM loan__Repayment_Schedule_Summary__r 
                                                        WHERE loan__RSS_Primary_flag__c = true order by loan__RSS_Seq__c asc) 
                                                        FROM loan__Loan_Account__c 
                                                        WHERE id IN :contractIds
                                                        WITH SECURITY_ENFORCED]){
            for(loan__Loan_Account__c clContract : clContracts) {
    
                if (clContract.loan__Repayment_Schedule_Summary__r.size() >= NUMBER_OF_PAYMENT &&
                    clContract.loan__Repayment_Schedule_Summary__r[0].loan__RSS_Seq__c == FIRST_PAYMENT && 
                    clContract.loan__Repayment_Schedule_Summary__r[0].loan__RSS_Repayment_Amt__c != clContract.loan__Payment_Amount__c
                ) {

                    clContract.Mod_Payment_Amount__c = clContract.loan__Repayment_Schedule_Summary__r[0].loan__RSS_Repayment_Amt__c;
                    clContract.Mod_End_Date__c = clContract.loan__Repayment_Schedule_Summary__r[1].loan__RSS_Repayment_Dt__c.addDays(-1);


                    updateContract.add(clContract);
                }
            }                                                    
        }
    
        if (updateContract.size() > 0) {
            update updateContract;
        }
    }
}
