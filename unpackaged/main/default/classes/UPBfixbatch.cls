/*Author : pallavi*/

global class UPBfixbatch implements Database.Batchable<sObject> {
    
    String query = '';
    public Set<Id> lacc = new Set<Id>();
    Date systemDate = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
    
    public List<String> status = new List<String>();
    loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
    
    global UPBfixbatch(){
       
        System.debug('default constructor');
        status.add('Active - Good Standing');
        status.add('Active - Bad Standing');
        
        /*list<loan__loan_account__c> ls = [select id from loan__loan_account__c where loan__Loan_Status__c in:status];
        
        for (loan__loan_account__c la : ls){
            lacc.add(la.id);
        }*/

        query = 'Select id from loan__loan_account__c where loan__Uncleared_Repayment_Amount__c > 0 and loan__Principal_paid__c > 0 ' +
                'and datafixupb__c = true and loan__Loan_Status__c in:status and loan__Last_Accrual_Date__c <=:systemDate ';

    }
    
    global UPBfixbatch(Set<Id> lContract){
        status.add('Active - Good Standing');
        status.add('Active - Bad Standing');
        lacc = lContract;
    }
    
    global UPBfixbatch(Set<Id> lContract,String query1){   

        /*pallavi(new constructor to pass query along with contracts if any change in query id needed)
        if using status/id in where condition,please always use 'id in:lacc and loan__Loan_Status__c in:status'
        */ 

        status.add('Active - Good Standing');
        status.add('Active - Bad Standing');
        lacc = lContract;
        query = query1;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        if(test.isRunningTest()){
          systemDate = System.today();
        }

        if(query.length() == 0){
            /*query = 'Select id from loan__loan_account__c where loan__Uncleared_Repayment_Amount__c > 0 and loan__Principal_paid__c > 0 ' +
                    'and datafixupb__c = false and id in:lacc and loan__Loan_Status__c in:status and loan__Last_Accrual_Date__c <:systemDate ';*/
            
            
            //updated as we are setting the value of datafixupb__c through a batch job now 
           query = 'Select id from loan__loan_account__c where loan__Uncleared_Repayment_Amount__c > 0 and loan__Principal_paid__c > 0 ' +
                    'and datafixupb__c = true and id in:lacc and loan__Loan_Status__c in:status and loan__Last_Accrual_Date__c <:systemDate ';               
        
        }

        System.debug('query ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<loan__loan_account__c> loanAccounts){
        
        System.debug('list is not null');
        List<loan__loan_account__c> LAtobeUpdated = [select id,name,loan__Loan_Status__c,
                                                     datafixupb__c,
                                                     UPBunaffected__c,
                                                     negprincipal__c,
                                                     loan__Loan_Amount__c,
                                                     loan__Principal_Remaining__c,
                                                     loan__Uncleared_Repayment_Amount__c,
                                                     loan__Principal_Paid__c,
                                                     loan__Interest_Paid__c,
                                                     loan__Interest_Remaining__c,
                                                     (select id,name,createddate,
                                                      loan__Principal__c,
                                                      loan__interest__c 
                                                      from loan__Loan_Payment_Transactions__r 
                                                      where 
                                                      loan__Reversed__c=false and loan__Cleared__c=true and loan__Rejected__c=false),
                                                     (select id,loan__Interest_Posted__c from loan__Interest_Posting_Transactions__r    //pallavi
                                                     where loan__Status__c = 'Closed' 
                                                     and loan__Discarded__c = false)
                                                     from loan__Loan_Account__c where id in:loanAccounts];
       
        System.debug(logginglevel.error, ' LAtobeUpdated :: ' +LAtobeUpdated); 

        for(loan__loan_account__c contract : LAtobeUpdated){
            
            try{
                
                DataFixUPBPatch dataFix = new DataFixUPBPatch(contract);
                dataFix.Fixupbloan();

            }catch (Exception e) {
            
                batch.loan__Log_Level__c = 'ERROR';
                batch.loan__Message__c = ' Data fix failed for ::'+ contract.Name + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
                batch.loan__Batch_Id__c = 'DataFixUPBPatch';
                insert batch;
                
                System.debug(logginglevel.error,'line number'+e.getLineNumber());
                System.debug(logginglevel.error,'error stackTrace'+e.getStackTraceString());
                System.debug(logginglevel.error,'error message'+e.getMessage()); 
            
            }

        }
        //System.debug('count ' + LAtobeUpdated.size());

    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('finish batch job');
    }
}