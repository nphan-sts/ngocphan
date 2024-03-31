global class MW_LoanDocumentsPreCheckScheduler implements Schedulable {
	public Integer batchSize;
    global MW_LoanDocumentsPreCheckScheduler(Integer bsize){
        batchSize = bsize;
    }
    global void execute(SchedulableContext SC){
       MW_LoanDocumentsPreCheckBatch bc= new MW_LoanDocumentsPreCheckBatch();
       ID batchprocessid = Database.executeBatch(bc,batchSize);
    }
}