/*******************************************************************************************************
 * 
 * @author Anusha
 * 
 * This class is to run reschedule job from CL contract details page and also from list view of CL contracts
 * This generates new amortization schedule in case of advance payment of loan...etc for both single and multiple contracts
 * LoanRescheduleJob of managed package is called interally.
 * 
 *********************************************************************************************************/

global class LoanRescheduleJob {
    Webservice static void runRescheduleJob(List<Id> LoanId)
    {
        Boolean submitNextJob = False;
        Integer batchSize = 1;
        Set<Id> loanIDs = new Set<Id>();
        loanIDs.addall(LoanId);
        loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
        try{        
            List<loan__Loan_Account__c> loanAcc = [Select Id,loan__Branch__r.loan__Current_System_Date__c from loan__Loan_Account__c where Id in:LoanId];
            Date systemDate = loanAcc.get(0).loan__Branch__r.loan__Current_System_Date__c;
            loan.LoanRescheduleJob resc = new loan.LoanRescheduleJob(systemDate,loanIDs,submitNextJob,batchSize);
            Database.executebatch(resc,1);
        }catch(Exception e){
            System.debug('Batch processing failed with exception: '+e.getMessage());
            batch.loan__Log_Level__c = 'ERROR';
            batch.loan__Message__c = 'Rescheduling failed for one or more loans in ::'+ loanIDs + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
            batch.loan__Batch_Id__c = 'LoanRescheduleJob';
            insert batch;
        }
        System.debug('Batch processing completed for loan ids: '+loanIDs);
    }
    
}