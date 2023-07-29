global class LoanPaymentTxnClearingJobCustomQuery implements loan.IQueryBuilder  {
    String query;
    global String getQuery(){
        loan.GlobalLoanUtilFacade glutil = new loan.GlobalLoanUtilFacade();
        System.Debug('SystemDate ***Custom Query***' + glutil.getCurrentSystemDate());
        System.Debug('Is holiday ***Custom Query***' + loan.HolidayUtil.INSTANCE.isBankHoliday(glutil.getCurrentSystemDate()));
        if(loan.HolidayUtil.INSTANCE.isBankHoliday(glutil.getCurrentSystemDate())){
            query = loan.ProcessJobQueryUtil2.getLoanPaymentClearingJobQuery(null, null, null) + ' LIMIT 0';            
            System.Debug('LoanPaymentTxnClearingJob ***Custom Query1***' + query);
            return query;
        }
        else{
            query = loan.ProcessJobQueryUtil2.getLoanPaymentClearingJobQuery(null, null, null);         
            System.Debug('LoanPaymentTxnClearingJob ***Custom Query2***' + query);
            return query;
        }       
        
    }    
}