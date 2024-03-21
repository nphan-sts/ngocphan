Global class DM_ResceduleJob_forFutureLADContracts implements Database.Batchable<sObject>,Schedulable {
    
    String query;
    loan.GlobalLoanUtilFacade loanUtil = new loan.GlobalLoanUtilFacade();
    Date sysDate = loanUtil.getCurrentSystemDate();
    DateTime systemDateTime = DateTime.newInstance(sysDate.year(),sysDate.month(),sysDate.day());
    String systemDate = systemDateTime.format('yyyy-MM-dd');
    
    Global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'Select id from loan__loan_account__c where loan__Last_Accrual_Date__c <= ' + systemDate + ' and loan__Is_Rescheduled__c = false '+
                'and isMigrated__c = true and DM_Future_LAD__c = true';
        System.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(SchedulableContext sc) {
        DM_ResceduleJob_forFutureLADContracts j =new DM_ResceduleJob_forFutureLADContracts();
        Database.executebatch(j,1);
    }
    
    Global void execute(Database.BatchableContext BC,List<loan__loan_account__C> loan){
        
        List<loan__Loan_Account__c> LAtobeUpdated = [Select id,name,lead_Guid__c,
                             loan__First_Installment_Date__c,
                             loan__Oldest_Due_Date__c,
                             Application__r.genesis__Monthly_Debt_Payments__c,
                             loan__Payment_Amount__c,
                             loan__Last_Payment_Date__c,
                             loan__Accrual_Start_Date__c,
                             Application__r.Loan_Origination_Date__c,
                             loan__Last_Installment_Date__c,
                             Last_RSS_date__c,
                             loan__Interest_Rate__c,
                             loan__Frequency_of_Loan_Payment__c,
                             loan__Pmt_Amt_Cur__c,
                             loan__Next_Installment_Date__c,
                             loan__Maturity_Date_Current__c,
                             loan__Term_Cur__c,
                             loan__Loan_Status__c,
                             loan__Last_Accrual_Date__c,
                             (Select id,name,
                              loan__Is_Archived__c,
                              loan__Due_Date__c
                              from loan__Repayment_Schedule__r),
                             (select id,name from loan__Repayment_Plan__r),
                             CPD_Reason__c,
                             CPD_Expire_Date__c
                             from loan__Loan_Account__c
                             where id In: loan];
        
        RescheduleLoanPostMigration a = new RescheduleLoanPostMigration();
        a.rescheduleFutureLADLoan(LAtobeUpdated);
            
        }
    
    public void finish(Database.BatchableContext BC){
        System.debug('Finish Batch Job');
    }
}