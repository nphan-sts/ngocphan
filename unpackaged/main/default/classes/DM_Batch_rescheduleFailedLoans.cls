/* ****************Modification History******************
 * Created By        Date          JIRA number
 *1. Pallavi        2021/03/12     LSP-27
 *      
 ******************Modification History******************/
Global class DM_Batch_rescheduleFailedLoans implements Database.Batchable<sObject> {

    String query;
      
    integer thread = 0;
    List<String> errorMessage = new List<String>();
    
    List<MigrationPhase__c> migrationPhase = MigrationPhase__c.getAll().values();
    String phase = migrationPhase[0].phase__c;
    
    global DM_Batch_rescheduleFailedLoans(integer threadNumber){
        errorMessage.add('Divide by 0');
        errorMessage.add('List index out of bounds: 0');
        thread = threadNumber;
    }
    
    global DM_Batch_rescheduleFailedLoans(){
        errorMessage.add('Divide by 0');
        errorMessage.add('List index out of bounds: 0');
        System.debug('default constructor');
    }
    global Database.QueryLocator start(Database.BatchableContext bC){
                
        query  = 'SELECT Id, name FROM loan__loan_account__c where loan__Is_Rescheduled__c = false and loan__Invalid_Data__c = false and DM_Migration_Phase__c = \'' +phase+ '\' and DM_Rescheduling_Error__c in: errorMessage' ;	
        if(thread > 0)
            query = query + ' and loan__Thread_Number__c = ' + thread;
            
        System.debug(query);	//loan__Is_Rescheduled__c = false and 
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bC,List<loan__Loan_Account__c> dmList){
        
        List<loan__Loan_Account__c> lAtobeUpdated = [Select id,name,lead_Guid__c,
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
                             where id In: dmList];
        
        RescheduleFailedLoansPostMigration a = new RescheduleFailedLoansPostMigration();
        System.debug('Loan to be updated.. '+lAtobeUpdated);
        a.rescheduleLoan_throughBatch(lAtobeUpdated);
            
        }
    
    global void finish(Database.BatchableContext bC){
        system.debug('Finish Batch Job');
    }
}