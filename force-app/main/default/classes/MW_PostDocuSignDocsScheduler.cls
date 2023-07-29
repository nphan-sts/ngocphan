global class MW_PostDocuSignDocsScheduler implements Schedulable {
    public Integer batchSize;
   
   global MW_PostDocuSignDocsScheduler(Integer bSize){
       batchSize = bSize;
   }
   global void execute(SchedulableContext SC) {
      Database.executeBatch(new MW_PostDocuSignDocs(), batchSize);
   }

}