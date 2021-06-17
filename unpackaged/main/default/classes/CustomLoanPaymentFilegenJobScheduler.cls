/* ****************Modification History******************
 *Created By       Pallavi          2020-02-06
 ******************Modification History******************/
global class CustomLoanPaymentFilegenJobScheduler implements Schedulable {
    public Integer batchSize;
    global CustomLoanPaymentFilegenJobScheduler(Integer bsize){
        batchSize = bsize;
    }
    global void execute(SchedulableContext SC){
        loan.LoanPaymentFilegenJob job = new loan.LoanPaymentFilegenJob();
        Database.executeBatch(job,batchSize);
    }

}