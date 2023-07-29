global class MW_OriginationDocs_OrgiDeclnScheduler implements Schedulable {

   global void execute(SchedulableContext SC) {
      Database.executeBatch(new MWOriginationDocuments_OrgiDocs('Declined'), 1);
   }

}