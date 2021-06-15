/*Author : Vishal Lakkammanavar - CLS*/

global class InterestCorrectionBatch implements Database.Batchable<sObject> {
    
    String query = '';
    public Set<Id> lacc = new Set<Id>();
    Date systemDate = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
    
    public List<String> status = new List<String>();
    loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
    
    global InterestCorrectionBatch(){
       
        System.debug('default constructor');
        status.add('Active - Good Standing');
        //status.add('Active - Bad Standing');
        
        query = 'Select id from loan__loan_account__c where loan__Number_of_Days_Overdue__c = 0 ' +
                'and loan__Loan_Status__c in:status and Skipped_a_Pay__c = false and loan__Interest_Remaining__c > 0 ' +
                'and loan__Invalid_Data__c = false';

    }
    
        global InterestCorrectionBatch(Set<Id> lContract){
         status.add('Active - Good Standing');
        //status.add('Active - Bad Standing');
         lacc = lContract;
         
         query = 'Select id from loan__loan_account__c where  loan__Number_of_Days_Overdue__c = 0 ' +
                'and loan__Loan_Status__c in:status and Skipped_a_Pay__c = false and loan__Interest_Remaining__c > 0 ' +
                'and loan__Invalid_Data__c = false and id in : lacc'; 
    }
    
    
    global InterestCorrectionBatch(Set<Id> lContract,String query1){   

        status.add('Active - Good Standing');
       // status.add('Active - Bad Standing');
        lacc = lContract;
        query = query1;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        if(test.isRunningTest()){
          systemDate = System.today();
        }

        if(query.length() == 0){
              
           // query = 'Select id from loan__loan_account__c where  loan__Number_of_Days_Overdue__c = 0 ' +
            //'and loan__Loan_Status__c in:status and Skipped_a_Pay__c = false ';   
            
            query = 'Select id from loan__loan_account__c where loan__Number_of_Days_Overdue__c = 0 ' +
                'and loan__Loan_Status__c in:status and Skipped_a_Pay__c = false and loan__Interest_Remaining__c > 0 ' +
                'and loan__Invalid_Data__c = false';          
        
        }

        System.debug('query ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<loan__loan_account__c> loanAccounts){
        
        System.debug('list is not null');
        List<loan__loan_account__c> LAtobeUpdated = [select id,name,loan__Loan_Status__c,IR_Fixed__c,
                                                     loan__Loan_Amount__c,
                                                     loan__Principal_Remaining__c,
                                                     loan__Principal_Paid__c,
                                                     loan__Interest_Paid__c,
                                                     loan__Interest_Remaining__c,
                                                     loan__Invalid_Data__c ,
                                                     (select id,name,createddate,
                                                      loan__Principal__c,
                                                      loan__interest__c 
                                                      from loan__Loan_Payment_Transactions__r 
                                                      where 
                                                      loan__Reversed__c=false and loan__Cleared__c=true and loan__Rejected__c=false),
                                                     (select id,loan__Interest_Posted__c from loan__Interest_Posting_Transactions__r   
                                                     where loan__Status__c = 'Closed' 
                                                     and loan__Discarded__c = false),
                                                     (select id,loan__Due_Interest__c,loan__Due_Principal__c,loan__Due_Date__c
                                                     From loan__Repayment_Schedule__r
                                                     Where loan__Is_Archived__c = false and loan__Is_Billed__c = true
                                                     and loan__Is_Posted__c = true
                                                     and loan__Due_Date__c <= today)
                                                     from loan__Loan_Account__c where id in:loanAccounts and IR_Fixed__c = false];
       
        System.debug(logginglevel.error, ' LAtobeUpdated :: ' +LAtobeUpdated); 

        for(loan__loan_account__c contract : LAtobeUpdated){
            
            try{
                
                InterestFixBatch dataFix = new InterestFixBatch(contract);
                dataFix.FixInterestloan();

            }catch (Exception e) {
            
                batch.loan__Log_Level__c = 'ERROR';
                batch.loan__Message__c = ' Data fix failed for ::'+ contract.Name + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
                batch.loan__Batch_Id__c = 'InterestFixBatch';
                insert batch;
                
                System.debug(logginglevel.error,'line number'+e.getLineNumber());
                System.debug(logginglevel.error,'error stackTrace'+e.getStackTraceString());
                System.debug(logginglevel.error,'error message'+e.getMessage()); 
            
            }

        }
        System.debug('count ' + LAtobeUpdated.size());

    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('finish batch job');
    }
}