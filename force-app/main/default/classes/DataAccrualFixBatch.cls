global class DataAccrualFixBatch implements Database.batchable<sObject>{
             
    String query;
    Set<Id> loanAccountIdSet = new Set<Id>();
    loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();      
    
    global DataAccrualFixBatch (Set<Id> LoanIDs){
       
    loanAccountIdSet = LoanIDs;
    System.debug(logginglevel.error,'loanAccountIdSet +++'+loanAccountIdSet); 
        
        query = 'Select id,name,lead_Guid__c,loan__First_Installment_Date__c, '+
                     'Application__r.genesis__Monthly_Debt_Payments__c,'+
                     'loan__Payment_Amount__c,'+
                     'loan__Accrual_Start_Date__c,'+
                     'Application__r.Loan_Origination_Date__c,'+
                     'loan__Last_Installment_Date__c,'+
                     'loan__Interest_Rate__c,'+
                     'loan__Frequency_of_Loan_Payment__c,'+
                     'loan__Pmt_Amt_Cur__c,'+
                     'loan__Next_Installment_Date__c,'+
                     'loan__Maturity_Date_Current__c,'+
                     'loan__Term_Cur__c,'+
                     '(Select id,name,'+
                     'loan__Is_Archived__c,'+
                     'loan__Due_Date__c'+
                     ' from loan__Repayment_Schedule__r),'+
                     '(select id,name from loan__Repayment_Plan__r),'+
                     'CPD_Reason__c,'+
                     'CPD_Expire_Date__c'+
                     ' from loan__Loan_Account__c'+
                     ' where Id in : loanAccountIdSet';//+
            		 //' where DataAccrualFix__c = true';	//pallavi
    
        System.debug(logginglevel.error,'query+++'+query); 
                
    }       
    
    global Database.QueryLocator start(Database.BatchableContext bc){
                              
        System.debug('IN Database.QueryLocator'+query);    
        return Database.getQueryLocator(query);
    
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        System.debug(logginglevel.error,'----Method execute(+)scope----'+ scope);
        List<loan__loan_account__c> listOfLoans = (List<loan__loan_account__c>)scope; 
        
          
                    
        for(loan__loan_account__c loan : listOfLoans ){
        
        System.debug(logginglevel.error, 'Processing Loan :: '+loan.name);
            
            try{   
                                                                       
                DataAccrualFixPatch accrualFix = new DataAccrualFixPatch(loan);
                accrualFix.rescheduleLoan();
               
            
                
            }catch(Exception e){
                
                System.debug(logginglevel.ERROR,'NO IO PRESENT WITH STATUS *NEW* ON CL CONTRACT :'+loan.Name);
                batch.loan__Log_Level__c = 'ERROR';
                batch.loan__Message__c = ' Reschedule Failed for ::'+ loan.Name + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
                batch.loan__Batch_Id__c = 'DataAccrualFixPatch';
                insert batch;
            }
        
        }
        
    } 
    
    public void finish(Database.BatchableContext BC){
        
        List<String> contractNames = new List<String>();
        List<Id> listID = new List<Id>(loanAccountIdSet);
        List<loan__Loan_Account__c> loanList=[SELECT Id,Name FROM loan__Loan_Account__c WHERE Id IN: listID];
        
        for(loan__Loan_Account__c loan:loanList){
            contractNames.add(loan.Name);
        }
        CLS_DiscardIPTJob job = new CLS_DiscardIPTJob(contractNames);
        Database.executeBatch(job, 1);
    }
    
}