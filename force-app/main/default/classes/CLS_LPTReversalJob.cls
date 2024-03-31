public class CLS_LPTReversalJob implements Database.Batchable<sObject>,Database.AllowsCallouts{
    
    private List<String> loanContract;
    loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
    
    public CLS_LPTReversalJob(List<String> loanContract){
        this.loanContract = loanContract;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = '';
        if(loanContract!=null && loanContract.size() > 0){
            String contractNamesStr = '';
            for (String contractName : loanContract) {
                contractNamesStr = contractNamesStr + '\'' + String.escapeSingleQuotes(contractName) + '\'' + ',';
            }
            contractNamesStr = contractNamesStr.substring(0, contractNamesStr.length() - 1);  
            query = 'SELECT Id,Name,loan__Last_Accrual_Date__c,loan__Accrual_Start_Date__c,loan__Interest_Remaining__c,'+
                'loan__Interest_Accrued_Not_Due__c,(Select Id,Name FROM loan__Other_Loan_Transactions__r) FROM loan__Loan_Account__c WHERE Name IN ('+contractNamesStr+')';
        }
        
        System.debug(LoggingLevel.ERROR, 'query in initialize : ' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        Savepoint sp = database.setsavepoint();
        
        List<loan__Loan_Account__c> loanAccountList = (List<loan__Loan_Account__c>)scope;
        
        for(loan__Loan_Account__c loan:loanAccountList){
            System.debug(logginglevel.error, 'Processing Loan :: '+loan.name);
            try{
                CLS_LPTReversalJobHandler handler = new CLS_LPTReversalJobHandler(loan);
            }catch(exception e){
                database.rollback(sp); 
                System.debug(logginglevel.ERROR,'LPT Reversal failed for :'+loan.Name);
                batch.loan__Log_Level__c = 'ERROR';
                batch.loan__Message__c = 'LPT Reversal failed for ::'+ loan.Name + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
                batch.loan__Batch_Id__c = 'LPTReversalJob';
                insert batch;
            } 
        }
    }
    
    public void finish(Database.BatchableContext bc){
        
        //invoke batch for rescheduling 
        List<loan__Loan_Account__c> loanList= [SELECT Id,Name FROM loan__Loan_Account__c WHERE Name IN: loanContract];
        Set<Id> loanIds = new Set<Id>();
        for(loan__Loan_Account__c loan:loanList){
            loanIds.add(loan.Id);
        }
        DataAccrualFixBatch job = new DataAccrualFixBatch(loanIds);
        Database.executeBatch(job,1);
        
        System.debug('Success');
    } 
    
}