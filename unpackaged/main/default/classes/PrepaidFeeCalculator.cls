global class PrepaidFeeCalculator implements loan.CustomFeeCalculator {

    global Decimal computeFee(loan__Fee__c fee, loan__Loan_Account__c loanRec) {
        
        Decimal retVal;
       List<loan__Loan_Account__c > loans = new List<loan__Loan_Account__c >();
       loans =[SELECT peer__Origination_Fee__c FROM loan__Loan_Account__c WHERE id =:loanRec.id];
        
        //if(!loanRec.loan__Contract_Type__c.equalsIgnoreCase(loan.LoanConstants.CONTRACT_TYPE_REFINANCE)) {
            retVal =loans[0].peer__Origination_Fee__c !=null ?  loans[0].peer__Origination_Fee__c: 0;
        /*}else{
            retVal = 0;
        }*/
        
        return retVal;
    }
    
}