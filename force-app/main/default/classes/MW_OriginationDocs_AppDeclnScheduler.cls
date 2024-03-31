global class MW_OriginationDocs_AppDeclnScheduler implements Schedulable {

   global void execute(SchedulableContext SC) {
      Database.executeBatch(new MWOriginationDocuments_AppDocs('Declined'), 1);
   }

}