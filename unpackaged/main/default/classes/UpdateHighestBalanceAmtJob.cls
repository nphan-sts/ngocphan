global with sharing class UpdateHighestBalanceAmtJob extends loan.MFiFlexBatchJob implements Database.Stateful {
    private String query;
    private final static String JOB_NAME = 'Update Highest Balance Amt Attained Job';
    private Boolean submitNextJob = false;
    private List<loan__Loan_Disbursal_Transaction__c> failedDisbursals;
    
    global UpdateHighestBalanceAmtJob() {
        super(JOB_NAME, getUpdateHighestBalanceAmtJob());
        this.failedDisbursals = new List<loan__Loan_Disbursal_Transaction__c>();
    }
    
    global UpdateHighestBalanceAmtJob(String query) {
        super(JOB_NAME, query);
        this.failedDisbursals = new List<loan__Loan_Disbursal_Transaction__c>();
    }
    
    private static String getUpdateHighestBalanceAmtJob() {
        String query = 'SELECT Id,' +
                       '       loan__Disbursed_Amt__c, ' +
                       '       loan__Loan_Account__c, ' +
                       '       loan__Loan_Snapshot__c, ' +
                       '       loan__Loan_Account__r.Id, ' +
                       '       loan__Loan_Account__r.loan__Metro2_Account_highest_bal_amount__c ' +
                       'FROM loan__Loan_Disbursal_Transaction__c ' +
                       'WHERE loan__Loan_Account__r.loan__Product_Type__c = \'Line of Credit\' AND loan__Cleared__c = true AND loan__Rejected__c = false ' +
                       'AND loan__Reversed__c = false ' +
                       'Order By loan__Disbursal_Time__c ASC';
        system.debug(LoggingLevel.ERROR, 'Query :: ' + query);
        return query;
    }
    
    public override void submitNextJob() {
        //does nothing
    }
    
    public override void doStart(Database.BatchableContext bc) {
        //does nothing
    }
    
    public override void doExecute(Database.BatchableContext bc, List<sObject> scope) {
        system.debug(LoggingLevel.ERROR, 'UpdateHighestBalanceAmtJob.doExecute');
        try{
            List<loan__Loan_Account__c> loanAccounts = new List<loan__Loan_Account__c>();
            Map<Id, List<loan__Loan_Disbursal_Transaction__c>> loanIdToDisbursalMap = new Map<Id, List<loan__Loan_Disbursal_Transaction__c>>();
            //Creating the Map of Loan Id to all the Dibursals for that Loan.
            for(sObject s : scope){
                loan__Loan_Disbursal_Transaction__c dis = (loan__Loan_Disbursal_Transaction__c)s;
                List<loan__Loan_Disbursal_Transaction__c> loanDis;
                loanDis = loanIdToDisbursalMap.get(dis.loan__Loan_Account__c);
                if(loanDis == null) {
                    loanDis = new List<loan__Loan_Disbursal_Transaction__c>();
                    loanIdToDisbursalMap.put(dis.loan__Loan_Account__c, loanDis);
                }
                loanDis.add(dis);
            }
            system.debug(LoggingLevel.ERROR, 'loanIdToDisbursalMap :: ' + loanIdToDisbursalMap);
            
            //calculating the highest credit balance ever attained.
            for(Id loanId : loanIdToDisbursalMap.keySet()) {
                List<loan__Loan_Disbursal_Transaction__c> loandisbursals = loanIdToDisbursalMap.get(loanId);
                Decimal principalRemaining;
                Decimal highestCredit = 0;
                loan__Loan_Account__c loan = new loan__Loan_Account__c();
                for(loan__Loan_Disbursal_Transaction__c dis : loandisbursals) {
                    principalRemaining = 0;
                    String snapshot = dis.loan__Loan_Snapshot__c;
                    List<String> splitList = snapshot.Split(String.valueOf('#'));
                    for(String s : splitList) {
                        List<String> unitSplitList = s.Split(String.valueOf('_'));
            
                        if(unitSplitList.size() < 2)
                            continue;
                        else if(unitSplitList.get(0) == String.valueOf('PR')) {
                            principalRemaining = Decimal.valueOf(unitSplitList.get(1));
                        }
                        Decimal balance = (principalRemaining + dis.loan__Disbursed_Amt__c);
                        if(balance > highestCredit) {
                            highestCredit = balance;
                        }
                    }
                    loan = dis.loan__Loan_Account__r;
                }
                //update the loan value
                loan.loan__Metro2_Account_highest_bal_amount__c = highestCredit;
                loanAccounts.add(loan);
            }
            update loanAccounts;
        }
        catch(Exception e){
            for(sObject s : scope){
                loan__Loan_Disbursal_Transaction__c dis = (loan__Loan_Disbursal_Transaction__c)s;
                failedDisbursals.add(dis);
            }
            system.debug(LoggingLevel.ERROR, 'Error in execution :: '+failedDisbursals + 'Error Message :: ' + e.getMessage() + 'Stack Trace :: ' + e.getStackTraceString() + 'Cause :: ' + e.getCause());
        }
    }
    
    public override void doFinish(Database.BatchableContext bc) {
        if(failedDisbursals.size() == 0){
            system.debug(LoggingLevel.ERROR, 'Migration for all the loans is successful');
        }
    }
}