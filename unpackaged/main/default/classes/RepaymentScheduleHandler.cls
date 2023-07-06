public with sharing class RepaymentScheduleHandler {
    final List<loan__Repayment_Schedule_Summary__c> newRecords;
    final Map<Id, loan__Repayment_Schedule_Summary__c> oldMap;
    final Map<Id, loan__Repayment_Schedule_Summary__c> newMap;

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
    
        ModPaymentAmountFieldUpdateHandler.updateModField(contractIds);
    }
}