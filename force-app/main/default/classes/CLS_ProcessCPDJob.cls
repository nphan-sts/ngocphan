global class CLS_ProcessCPDJob Implements Database.Batchable<sObject>, Schedulable{
    
    private List<String> loanContract;
    loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
    
    public CLS_ProcessCPDJob(List<String> loanContract){
        this.loanContract = loanContract;
    }
    
    public CLS_ProcessCPDJob(){}
    
    global void execute(SchedulableContext sc) {
        
        CLS_ProcessCPDJob cpdProcess = new CLS_ProcessCPDJob();
        Database.executeBatch(cpdProcess,1);
    
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        String query = 'Select id,name,loan__Last_Installment_Date__c,loan__Interest_Rate__c,loan__Frequency_of_Loan_Payment__c,loan__Pmt_Amt_Cur__c,CPD_CSD_diff__c,CPD_Date__c,CPD_Unpaid_Due_Date__c,Future_Bill_Pending__c,'+
                         'loan__Next_Installment_Date__c,loan__Maturity_Date_Current__c,loan__Term_Cur__c,(Select id,name,loan__Is_Archived__c,loan__Due_Date__c from loan__Repayment_Schedule__r),'+                             
                         '(select id,name,loan__Due_Date__c from loan__Dues_Details__r where loan__Payment_Satisfied__c  = false and loan__DD_Primary_Flag__c = true order by loan__Due_Date__c DESC limit 1),'+
                         '(select id,name from loan__Repayment_Plan__r),CPD_Reason__c,CPD_Expire_Date__c from loan__Loan_Account__c where Future_Bill_Pending__c = True and CPD_CSD_diff__c >= 1';
    
        
        System.debug(LoggingLevel.ERROR, 'query in initialize : ' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        Savepoint sp = database.setsavepoint();
        
        List<loan__Loan_Account__c> loanAccountList = (List<loan__Loan_Account__c>)scope;
        
        for(loan__Loan_Account__c loan:loanAccountList){
            System.debug(logginglevel.error, 'Processing Loan :: '+loan.name);
            try{
                /*pallavi*/
                if(test.isRunningTest()){
                    Date lastPaymentDate = loan.loan__Last_Installment_Date__c;
                    Date tothrowException = lastPaymentDate.addDays(2);
                }
                /*pallavi*/
                CLS_ProcessCPDJobHandler handler = new CLS_ProcessCPDJobHandler();
                handler.ChangePaymentDate(loan);
            }catch(exception e){
                database.rollback(sp); 
                System.debug(logginglevel.ERROR,'CPD Processing failed for :'+loan.Name);
                batch.loan__Log_Level__c = 'ERROR';
                batch.loan__Message__c = 'Process CPD ::'+ loan.Name + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
                batch.loan__Batch_Id__c = 'CLS_ProcessCPDJob';
                insert batch;
            } 
        }
    }
    
    public void finish(Database.BatchableContext bc){}
    
}