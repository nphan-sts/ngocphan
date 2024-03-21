/*CRM-867/LSP-14 chages by Neha*/
global class PreBillUpdateBatch implements Database.batchable<sObject> {
    
    String query;
    Set<Id> loanAccountIdSet = new Set<Id>();
    Set<String> loanAccountNameSet = new Set<String>();
    Map<String,String> loanAccountNameMap = new Map<String,String>();
    
    loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
    
    loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
    Date systemDate = util.getCurrentSystemDate();
    Decimal PreBillValue ;
    
    global PreBillUpdateBatch (Map<String,String> LoanNames){
        loanAccountNameSet = LoanNames.keySet();
        loanAccountNameMap = LoanNames;        
        
        System.debug(logginglevel.error,'loanAccountNameMap +++'+loanAccountNameMap);
        
        query = 'Select id,name,loan__Next_Installment_Date__c from loan__Loan_Account__c where Name in : loanAccountNameSet';            
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){                           
        System.debug('In Database.QueryLocator : '+query);    
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        System.debug(logginglevel.error,'*** Method execute(+)scope *** '+ scope);        
        List<loan__loan_account__c> listOfLoans = (List<loan__loan_account__c>)scope;                   
        
        for(loan__loan_account__c loan : listOfLoans ){
            System.debug(logginglevel.error,'*** Loan *** '+loan); 
            if(loanAccountNameMap != null && loanAccountNameMap.size()>0){
              preBillValue = Integer.valueOf((loanAccountNameMap.get(loan.Name)).trim());
            }
            loan.loan__Pre_Bill_Days__c = preBillValue;
            loan.loan__Next_Due_Generation_Date__c = loan.loan__Next_Installment_Date__c.addDays((Integer)(-1*preBillValue));
            System.debug(logginglevel.DEBUG, 'Processing Loan :: '+loan.name); 
        
        try{                                                                     
            
                update listOfLoans;             
                 
                               
            }catch(Exception e){
                 System.debug(logginglevel.DEBUG,'Update Failed for loan : '+loan.Name);
                 batch.loan__Log_Level__c = 'ERROR';
                 batch.loan__Message__c = ' Update failed for ::'+ loan.Name + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
                 batch.loan__Batch_Id__c = 'PreBillUpdateBatch';
                 insert batch;
            }
        }
    }
           
    public void finish(Database.BatchableContext BC){
        
    }
    
}