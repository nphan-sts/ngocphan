/* ****************Modification History******************
 *Created By       Pallavi          2020-02-06
 ******************Modification History******************/
global class CustomLoanPaymentTxnCreationJobScheduler implements Schedulable {
    public Integer batchSize;
    global CustomLoanPaymentTxnCreationJobScheduler(Integer bsize){
        batchSize = bsize;
    }
    global void execute(SchedulableContext SC){
        Boolean submitNextJob = false;
        loan.LoanPaymentTransactionCreationJob job = new loan.LoanPaymentTransactionCreationJob(submitNextJob); 
        Database.executeBatch(job,batchSize);
    }
}