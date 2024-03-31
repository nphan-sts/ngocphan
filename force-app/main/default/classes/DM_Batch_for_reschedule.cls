/* @author = Pallavi
 * 
 */
Global class DM_Batch_for_reschedule implements Database.Batchable<sObject> {
    String query;
    List<String> status = new List<String>(); //LSP-98
       
    integer thread = 0;
    
    List<MigrationPhase__c> migrationPhase = MigrationPhase__c.getAll().values();
    String phase = migrationPhase[0].phase__c;
    
    global DM_Batch_for_reschedule(integer threadNumber){
        status.add('Closed- Written Off');
    	status.add('Closed - Obligations met');  
        thread = threadNumber;
    }
    
    global DM_Batch_for_reschedule(){
        status.add('Closed- Written Off');
    	status.add('Closed - Obligations met');  
        System.debug('default constructor');
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        
        //query  = 'SELECT Id, name FROM loan__loan_account__c where loan__Is_Rescheduled__c = false and loan__Invalid_Data__c = false and loan__Loan_Status__c = \'' +status+ '\'' ;
        query  = 'SELECT Id, name FROM loan__loan_account__c where loan__Is_Rescheduled__c = false and loan__Invalid_Data__c = false and DM_Migration_Phase__c = \'' +phase+ '\' and loan__Loan_Status__c not in: status' ;	//LSP-98
        if(thread > 0)
            query = query + ' and loan__Thread_Number__c = ' + thread;
            
        System.debug(query);	//loan__Is_Rescheduled__c = false and 
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<loan__Loan_Account__c> dmList){
        
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
                             DM_Rescheduling_Error__c,	//LSP-27                        
                             (Select id,name,
                              loan__Is_Archived__c,
                              loan__Due_Date__c
                              from loan__Repayment_Schedule__r),
                             (select id,name from loan__Repayment_Plan__r),
                             CPD_Reason__c,
                             CPD_Expire_Date__c
                             from loan__Loan_Account__c
                             where id In: dmList];
        
        RescheduleLoanPostMigration a = new RescheduleLoanPostMigration();
        System.debug('Loan to be updated.. '+LAtobeUpdated);
        a.rescheduleLoan_throughBatch(LAtobeUpdated);
            
        }
    
    global void finish(Database.BatchableContext BC){
        system.debug('Finish Batch Job');
    }

}