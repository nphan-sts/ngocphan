global class MW_OriginationDocs_OrgiScheduler implements Schedulable {

   global void execute(SchedulableContext SC) {
      Database.executeBatch(new MWOriginationDocuments_OrgiDocs('PreFunding'), 1);
   }

}