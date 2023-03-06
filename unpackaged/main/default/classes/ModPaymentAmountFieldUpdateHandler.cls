public with sharing class ModPaymentAmountFieldUpdateHandler {

    final static Integer FIRST_PAYMENT = 1;
    final static Integer NUMBER_OF_PAYMENT = 2;

    public static void updateModField(Set<String> contractIds) {

        List<loan__Loan_Account__c> updateContract = new List<loan__Loan_Account__c>();

        for (List<loan__Loan_Account__c> clContracts : [SELECT 
                                                                Id, loan__Payment_Amount__c, 
                                                                (select id, loan__RSS_Seq__c, loan__RSS_Repayment_Amt__c, loan__RSS_Repayment_Dt__c,
                                                                createdDate 
                                                                FROM loan__Repayment_Schedule_Summary__r 
                                                                WHERE loan__RSS_Primary_flag__c = true order by loan__RSS_Seq__c asc, createdDate desc) 
                                                                FROM loan__Loan_Account__c 
                                                                WHERE id IN :contractIds
                                                                WITH SECURITY_ENFORCED])
        {
            for(loan__Loan_Account__c clContract : clContracts) {

                Map<Decimal, loan__Repayment_Schedule_Summary__c> mapSequenceToRepayment = getMapSequenceToRepayment(clContract);
    
                if (mapSequenceToRepayment.values().size() >= NUMBER_OF_PAYMENT &&
                    mapSequenceToRepayment.values()[0].loan__RSS_Seq__c == FIRST_PAYMENT && 
                    mapSequenceToRepayment.values()[0].loan__RSS_Repayment_Amt__c != clContract.loan__Payment_Amount__c
                ) {

                    clContract.Mod_Payment_Amount__c = mapSequenceToRepayment.values()[0].loan__RSS_Repayment_Amt__c;
                    clContract.Mod_End_Date__c = mapSequenceToRepayment.values()[1].loan__RSS_Repayment_Dt__c.addDays(-1);


                    updateContract.add(clContract);
                }
            }                                                    
        }

        if (updateContract.size() > 0) {
            update updateContract;
        }
    }


    //make sure to get only one newest repayment schedule for each sequence
    private static Map<Decimal, loan__Repayment_Schedule_Summary__c> getMapSequenceToRepayment(loan__Loan_Account__c clContract) {
        Map<Decimal, loan__Repayment_Schedule_Summary__c> mapSequenceToRepayment = new Map<Decimal, loan__Repayment_Schedule_Summary__c>();

        for(loan__Repayment_Schedule_Summary__c rs : clContract.loan__Repayment_Schedule_Summary__r) {

            if(mapSequenceToRepayment.get(rs.loan__RSS_Seq__c) == null) {
                mapSequenceToRepayment.put(rs.loan__RSS_Seq__c, rs);
            }
        }

        return mapSequenceToRepayment;
    }
}