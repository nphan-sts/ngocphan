public class CLS_DiscardIPTJob implements Database.Batchable<sObject>{
    
    private List<String> loanContract;
    loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
    
    public CLS_DiscardIPTJob(List<String> loanContract){
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
            system.debug('Contract Names:'+contractNamesStr);
            query = 'SELECT Id,Name,loan__Next_Interest_Posting_Date__c,loan__Next_Installment_Date__c,loan__Expected_Repayment_Start_Date__c,'+
                'loan__Last_Interest_Posting_Date__c,loan__Interest_Posted__c,loan__Accrual_Start_Date__c,'+
                'loan__Interest_Remaining__c,loan__Principal_Posted__c FROM loan__Loan_Account__c WHERE Name IN ('+contractNamesStr+')';
        }
        System.debug('Query:'+query);
        System.debug(LoggingLevel.ERROR, 'query in initialize : ' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        Savepoint sp = database.setsavepoint();
        
        List<loan__Loan_Account__c> loanAccountList = (List<loan__Loan_Account__c>)scope;
        
        for(loan__Loan_Account__c loan:loanAccountList){
            System.debug(logginglevel.error, 'Processing Loan :: '+loan.name);
            try{
                CLS_IPTDiscardHandler handler = new CLS_IPTDiscardHandler(loan);
            }catch(exception e){
                database.rollback(sp); 
                System.debug(logginglevel.ERROR,'IPT Discard failed');
                batch.loan__Log_Level__c = 'ERROR';
                batch.loan__Message__c = 'IPT discard :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
                batch.loan__Batch_Id__c = 'IPTDiscardJob';
                insert batch;
            } 
        }
    }
    
    public void finish(Database.BatchableContext bc){
        
        System.debug('Success of DiscardIPTJob');
        
        //invoke batch custom IPT creation handler
        String returnMsg=CLS_GenerateIPTHandler.generateIPT(loanContract);
        
        if(returnMsg == 'Completed' || (test.isRunningTest() && returnMsg =='Processing')){
            Database.executeBatch(new CLS_DiscardBillJob(loanContract), 1);
        }
    }  
}