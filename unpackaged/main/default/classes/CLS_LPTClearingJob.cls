public class CLS_LPTClearingJob implements Database.Batchable<sObject>{
    
    String loanId;
    loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
    
    public CLS_LPTClearingJob(String loanIds){
        this.loanId = loanIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = '';
        query = 'SELECT Id,Name,loan__Loan_Account__c FROM loan__Loan_Payment_Transaction__c WHERE loan__Loan_Account__c = \''+loanId+'\' AND'+
            ' Custom_Reverse__c = false AND loan__Reversed__c = false AND loan__Cleared__c = false ORDER BY loan__Transaction_Date__c ASC';
        
        
        System.debug(LoggingLevel.ERROR, 'query in initialize : ' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        Savepoint sp = database.setsavepoint();
        
        List<loan__Loan_Payment_Transaction__c> lptList = (List<loan__Loan_Payment_Transaction__c>)scope;
        
        for(loan__Loan_Payment_Transaction__c lpt:lptList){
            System.debug(logginglevel.error, 'Processing LPT :: '+lpt.Name);
            try{
                lpt.loan__Cleared__c = true;
                update lpt;
                //update contract
                List<loan__Loan_Account__c> loanAccList = [SELECT Id,Name,loan__Reschedule_Status__c,loan__Last_Accrual_Date__c 
                                                           FROM loan__Loan_Account__c WHERE Id=:lpt.loan__Loan_Account__c LIMIT 1];
                loanAccList[0].loan__Reschedule_Status__c = 'Success';
                update loanAccList;
            }catch(exception e){
                database.rollback(sp); 
                System.debug(logginglevel.ERROR,'Exception in clearing Loan Payment Transactions for :'+lpt.Name);
                batch.loan__Log_Level__c = 'ERROR';
                batch.loan__Message__c = ' Rposting failed::'+ lpt.Name + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
                batch.loan__Batch_Id__c = 'CLS_LPTClearingJob';
                insert batch;
            } 
        }
    }
    
    public void finish(Database.BatchableContext bc){
        
        System.debug('Success');
        List<loan__Interest_Posting_Transaction__c> iptList = [SELECT Id,Name,loan__Last_Accrual_Date__c FROM loan__Interest_Posting_Transaction__c 
                                                               WHERE loan__Loan_Contract__c=:loanId 
                                                               AND loan__Status__c=:'Open' AND loan__Discarded__c = false ORDER BY loan__Transaction_Creation_Date__c DESC];
        List<loan__Loan_Account__c> loanAccList = [SELECT Id,Name,loan__Reschedule_Status__c,loan__Last_Accrual_Date__c,Phase2__c,Phase3__c 
                                                   FROM loan__Loan_Account__c WHERE Id=:loanId LIMIT 1];
        loanAccList[0].loan__Reschedule_Status__c = '';
        loanAccList[0].loan__Last_Accrual_Date__c = iptList[0].loan__Last_Accrual_Date__c;
        loanAccList[0].Phase6__c = true;
        update loanAccList;
        System.debug('Success in Loan Update');
    } 
    
}