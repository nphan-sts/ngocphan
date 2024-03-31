global class LoanApplicationUpdateJob extends loan.MfiflexBatchJob implements Schedulable{
    global static String NAME = 'Loan Application Update Job';
    
    Date currentSystemDate = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();     
        
    global  LoanApplicationUpdateJob(){
       super(NAME,buildquery());                 
    }
    global  LoanApplicationUpdateJob(String query){
        super(NAME,query);
    }  
     
    global virtual override void submitNextJob() {
        
    }
    
    global void execute(SchedulableContext sc) {
        //When Origination Date changes, Schedule gets generated, so need to run this with as low batch size as possible.
        LoanApplicationUpdateJob job = new LoanApplicationUpdateJob();
        Database.executeBatch(job,1);
    }    
   
    
    global Override void doStart(Database.BatchableContext bc) {
        
    }
    
    global Override void doExecute(Database.BatchableContext bc, List<sObject> scope) {
        List<genesis__Applications__c> loanApps= (List<genesis__Applications__c>) scope;
        
        Map<Id,genesis__Applications__c> loanAppsToBeUpdate = new Map<Id,genesis__Applications__c>();
        
        for(genesis__Applications__c app : loanApps) {
            
            /*
            * First check if application is expired by time in pending.
            */
            
            //Update status to DENIED and Denial Reason
            if(Date.valueof(app.CreatedDate).daysBetween(currentSystemDate) > 9){
                /*app.genesis__Status__c =  OppLoansConstants.DENIED;
                app.Denial_Reason__c = OpploansConstants.TIME_ELAPED;
                app.DenialReason__c = OpploansConstants.TIME_ELAPED;     */           
                loanAppsToBeUpdate.put(app.Id,app);
            }
            
                
            }
        
        
       if(!loanAppsToBeUpdate.isEmpty()) {
           update loanAppsToBeUpdate.values();
       }
    }
    
    global Override void doFinish(Database.BatchableContext bc) {
        
    }
    
     global static string buildquery(){
    //axosoft #1149 : Change added field Type_Formula__c and removed from where condition.
        string allowedStatuesForAutoDeny = '\'' + PayoffConstants.DENIED + '\'' + ',' + '\''+ PayoffConstants.LOAN_APPROVED+ '\'';
        String query = 'select Id,name,'+
                        'genesis__Status__c,'+
                        'CreatedDate,genesis__Expected_Close_Date__c'+
                  ' From genesis__Applications__c'+
                 ' Where genesis__Status__c Not In (' + allowedStatuesForAutoDeny + ')';
         system.debug('--Query--'+ query);      
         return query;
    }
     
}