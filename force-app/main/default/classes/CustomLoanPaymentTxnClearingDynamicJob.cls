global without sharing class CustomLoanPaymentTxnClearingDynamicJob extends clcommon.DynamicJob implements loan.IPaymentModeBasedScheduler, loan.IPaymentModeBasedScheduler1 {
    
    
    loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
    
    global Integer batchSize;
    public static String NAME = 'LOAN PAYMENT TXN CLEARING JOB';
    public loan.IQueryBuilder queryBuilder;
    private Set<String> paymentModes;
    private Date iDate;
    
    global CustomLoanPaymentTxnClearingDynamicJob() {
        super(NAME, getQueryBuilder() != null ? getQueryBuilder().getQuery() : loan.ProcessJobQueryUtil2.getLoanPaymentClearingJobQuery(null, null, null));
        this.paymentModes = getPaymentModes();
        this.batchSize = 200;
        this.iDate = util.getCurrentSystemDate();
    }

    public CustomLoanPaymentTxnClearingDynamicJob(Date iDate, Set<String> paymentModes) {
        super(NAME, getQueryBuilder() != null ? getQueryBuilder().getQuery() : loan.ProcessJobQueryUtil2.getLoanPaymentClearingJobQuery(null, null, paymentModes));
        this.paymentModes = paymentModes;
        this.batchSize = 200;
        this.iDate = util.getCurrentSystemDate();
    }
    
    private static loan.IQueryBuilder getQueryBuilder() {
        String queryBuilder = loan.CustomSettingsUtil.getACHParameters().loan__Query_For_Loan_Payment_Clearing__c ;
        if (queryBuilder == null) {
            return null;
        }
        return (loan.IQueryBuilder) loan.TypeUtil.getNewInstance(queryBuilder, null);
    }

    global override void doexecute(SchedulableContext sc) {
        //Getting Instance with the help of getInstance Method #ND-756
        Database.executeBatch(this.getInstance(), this.batchSize);
    }

    global CustomLoanPaymentTxnClearingDynamicJob(String query, Integer batchSize) {
        super(NAME, query == null ? loan.ProcessJobQueryUtil2.getLoanPaymentClearingJobQuery(null, null, null) : query);
        this.paymentModes = getPaymentModes();
        this.batchSize = 200;
        if (batchSize != null) {
            this.batchSize = batchSize;
        }
    }

    global virtual Set<String> getPaymentModes() {
        return paymentModes;
    }

    global virtual CustomLoanPaymentTxnClearingDynamicJob getInstance() {
        loan.IQueryBuilder queryBuilder = getQueryBuilder();
        String query;
        if (queryBuilder == null) {
            query = loan.ProcessJobQueryUtil2.getLoanPaymentClearingJobQuery(null, null, getPaymentModes());
        } else {
            query = queryBuilder.getQuery();
        }
        CustomLoanPaymentTxnClearingDynamicJob job = new CustomLoanPaymentTxnClearingDynamicJob(query, null);
        return job;
    }
    
    global override void doInitialize() {} // do nothing
    
    global override String getRuntimeQuery() {
        //Add run time query when query passed in the constructor is null.
        String query;
        if(getQueryBuilder() != null) {
            query = getQueryBuilder().getQuery();
        }
        else {
            if(iDate == null) {
                iDate = util.getCurrentSystemDate();
            }
            query = loan.ProcessJobQueryUtil2.getLoanPaymentClearingJobQuery(iDate, null);
        }
        return query;
    }

    global override void doStart(Database.BatchableContext bc) {} // do nothing

    private void clearTransactions(List<loan__Loan_Payment_Transaction__c> txnsToClear) {
        
        update txnsToClear;
    }

    global override void doExecute(Database.BatchableContext bc, List<sObject> scope) {
        List<loan__Loan_Payment_Transaction__c> txns = (List<loan__Loan_Payment_Transaction__c>) scope;
        //ND-3227 : Marking the cleared flag as true, this will be marked as false in the before update handler of repaymentTriggerHandler.
        //therefore if there is any failures while processing the transaction will still be marked as false.
        for (loan__Loan_Payment_Transaction__c txn : txns) {
            txn.loan__Cleared__c = true;
        }
        clearTransactions(txns);
    }

    global override void doFinish(Database.BatchableContext bc) {}
    
}