global class MW_MissingInvestorAlertScheduler implements Schedulable {
    public Integer batchSize;
    global MW_MissingInvestorAlertScheduler(Integer bsize){
        batchSize = bsize;
    }
    global void execute(SchedulableContext SC) {
       MW_MissingInvestorAlert bc= new MW_MissingInvestorAlert();
       ID batchprocessid=Database.executeBatch(bc,batchSize);
    }
}