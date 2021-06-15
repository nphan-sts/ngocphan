/*
 * This batch job initializes 'Reschedule option on excess payment' field on lending product and associated loan contracts
 * if 'Excess threshold % for reschedule' is some positive value on lending product
 */
global class UpdateRescheduleOptionJob extends loan.MFiFlexBatchJob {

    global Integer batchSize;
    private static String JOB_NAME = 'Reschedule Option update job';
    private Boolean submitNextJob = false;

    global virtual override void submitNextJob() {
        if(submitNextJob) {
            //do nothing. 
            return;
        }
    }

    global UpdateRescheduleOptionJob() {
        super(JOB_NAME, getLoansForUpdate(null));
        if(batchSize == 0 || batchSize == null) {
            batchSize = 200;
        }
        this.batchSize = batchSize;
    }

    global UpdateRescheduleOptionJob(String query, Integer batchSize) {
        super(JOB_NAME, getLoansForUpdate(query));
        
        system.debug(LoggingLevel.ERROR, 'passed query : ' + query);
        if(batchSize == 0 || batchSize == null) {
            batchSize = 200;
        }
        this.batchSize = batchSize;
    }

    private static String getLoansForUpdate(String query) {
        //Query loans:
        if(query == null || query.length() == 0) {
            query = 'SELECT Id,' +
                    '       Name,' +
                    '       loan__Reschedule_Option_On_Excess_Payment__c,' +
                    '       loan__Loan_Product_Name__c,'+
                    '       loan__Loan_Product_Name__r.loan__Excess_Threshold_For_Reschedule__c,' +
                    '       loan__Loan_Product_Name__r.loan__Reschedule_Option_On_Excess_Payment__c ' +
                    'FROM loan__Loan_Account__c '+
                    'WHERE loan__Loan_Product_Name__r.loan__Excess_Threshold_For_Reschedule__c > 0 ' +
                    'AND loan__Reschedule_Option_On_Excess_Payment__c = NULL ';

            system.debug(LoggingLevel.ERROR, 'new query : ' + query);
            return query;
        }
        else {
            return query;
        }
    }

    global override void doStart(Database.BatchableContext bc) {

        disableTriggers();

        List<loan__Loan_Product__c> loanProducts = [SELECT Id,
                                                    Name,
                                                    loan__Reschedule_Option_On_Excess_Payment__c
                                             FROM loan__Loan_Product__c
                                             WHERE loan__Excess_Threshold_For_Reschedule__c > 0
                                                 AND loan__Reschedule_Option_On_Excess_Payment__c = NULL
                                            ];
        updateLoanProducts(loanProducts);
        enableTriggers();
    }

    global override void doExecute(Database.BatchableContext bc, List<sObject> scope) {

        disableTriggers();

        List<loan__Loan_Account__c> loanAccountList = (List<loan__Loan_Account__c>)scope;
        updateLoanAccounts(loanAccountList);
        if (loanAccountList != null && loanAccountList.size() > 0) {
            update loanAccountList;
        }
        enableTriggers();
    }

    @TestVisible
    public void updateLoanProducts(List<loan__Loan_Product__c> loanProducts) {
        system.debug(LoggingLevel.ERROR, ' Loan Products size : ' + loanProducts.size());
        if (loanProducts != null && loanProducts.size() > 0) {
            for (loan__Loan_Product__c loanProduct : loanProducts) {
                system.debug(LoggingLevel.ERROR, 'loanProduct : ' + loanProduct);
                loanProduct.loan__Reschedule_Option_On_Excess_Payment__c = loan.LoanConstants.LOAN_RESCHEDULE_TERM_CHANGE;
            }
            update loanProducts;
        }
    }

    @TestVisible
    public void updateLoanAccounts(List<loan__Loan_Account__c> loanAccountList) {
        system.debug(LoggingLevel.ERROR, 'loanAccounts size : ' + loanAccountList.size());
        for (loan__Loan_Account__c loanAccount : loanAccountList) {
            system.debug(LoggingLevel.ERROR, 'loanAccount : ' + loanAccount);
            if (loanAccount.loan__Loan_Product_Name__r.loan__Excess_Threshold_For_Reschedule__c != null
                && loanAccount.loan__Loan_Product_Name__r.loan__Excess_Threshold_For_Reschedule__c > 0
                && (loanAccount.loan__Reschedule_Option_On_Excess_Payment__c == null
                    || loanAccount.loan__Reschedule_Option_On_Excess_Payment__c == '')) {

                //in case reschedule option is present on lending product of loan, then copy its value otherwise make it default to 'Keep Same Payment Amount'
                if (loanAccount.loan__Loan_Product_Name__r.loan__Reschedule_Option_On_Excess_Payment__c != null) {
                    loanAccount.loan__Reschedule_Option_On_Excess_Payment__c = loanAccount.loan__Loan_Product_Name__r.loan__Reschedule_Option_On_Excess_Payment__c;
                }
                else {
                    loanAccount.loan__Reschedule_Option_On_Excess_Payment__c = loan.LoanConstants.LOAN_RESCHEDULE_TERM_CHANGE;
                }
            }
        }
    }

    global override void doFinish(Database.BatchableContext bc) {} //does nothing

    private void disableTriggers() {
        loan__Org_Parameters__c orgParams = loan.CustomSettingsUtil.getOrgParameters();
        orgParams.loan__Namespace_Prefix__c = 'loan';
        orgParams.loan__Disable_Triggers__c = true;
        upsert orgParams;
    }

    private void enableTriggers() {
        loan__Org_Parameters__c orgParams = loan.CustomSettingsUtil.getOrgParameters();
        orgParams.loan__Namespace_Prefix__c = 'loan';
        orgParams.loan__Disable_Triggers__c = false;
        update orgParams;
    }
}