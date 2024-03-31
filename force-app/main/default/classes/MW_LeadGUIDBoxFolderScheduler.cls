global class MW_LeadGUIDBoxFolderScheduler implements Schedulable {

   global void execute(SchedulableContext SC) {
      Database.executeBatch(new MW_UpdateBoxFolder2(), 1);
   }

}