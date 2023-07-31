global class MW_OriginationDocs_AppScheduler implements Schedulable {

   global void execute(SchedulableContext SC) {
      Database.executeBatch(new MWOriginationDocuments_AppDocs('PreFunding'), 1);
   }

}