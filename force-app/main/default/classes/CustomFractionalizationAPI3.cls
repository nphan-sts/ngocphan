global Class CustomFractionalizationAPI3 {
    
    public CustomFractionalizationAPI3(){}
    
    public loan__Loan_Payment_Transaction__c createLoanPayment(Id loanAccount,
                                                        Id paymentMode,
                                                        Date transactionDate,
                                                        Decimal transactionAmount,                                                      
                                                        Decimal principal,
                                                        Decimal interest,
                                                        Decimal fees,
                                                        Boolean manualPayment,
                                                        Boolean installmentPayment,
                                                        Boolean payoff,
                                                        Decimal prepaymentPenalty) {
        
        loan__Loan_Payment_Transaction__c lpt = new loan__Loan_Payment_Transaction__c();
        
        //Contract :                                                
        if(loanAccount == null) {
            throw new peer.MarketPlaceException('Loan account ID cannot be null.');
        }
        lpt.loan__Loan_Account__c = loanAccount;
        
        //Payment mode :
        if(paymentMode == null) {
            paymentMode = [SELECT Id FROM loan__Payment_Mode__c WHERE Name = 'ACH'].Id;
        }
        lpt.loan__Payment_Mode__c = paymentMode;
        
        //Transaction Date :
        if(transactionDate == null) {
            loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
            transactionDate = util.getCurrentSystemDate();
        }
        lpt.loan__Transaction_Date__c = transactionDate;
        
        //Amount
        if(manualPayment != null && manualPayment) {
            lpt.loan__Manual_Payment__c = true;
            if(principal == null && interest == null && fees == null) {
             throw new peer.MarketPlaceException('At least one of principal, interest or fees must be provided for manually spread payments.');
            }
            lpt.loan__Principal__c = principal == null ? 0.00 : principal;
            lpt.loan__Interest__c = interest == null ? 0.00 : interest;
            lpt.loan__Fees__c = fees == null ? 0.00 : fees;
            
            lpt.loan__Transaction_Amount__c = lpt.loan__Principal__c + lpt.loan__Interest__c + lpt.loan__Fees__c;  
        }
        else {
            //Not checking for null or zero value of transaction amount because CL Loan will throw error.
            lpt.loan__Transaction_Amount__c = transactionAmount;
        }
        
        //Installment payment
        if(installmentPayment != null && installmentPayment) {
            //Again, not putting a check here because CL loan handles all exceptions.
            lpt.loan__Installment_Payment__c = true;
        }      
        
        //New loan payment.
        try{
            insert lpt;
        }
        catch(Exception e) {
            throw e;
        }
        return lpt;
    }
}