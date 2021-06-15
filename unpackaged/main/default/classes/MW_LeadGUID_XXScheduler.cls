global class MW_LeadGUID_XXScheduler implements Schedulable {

   global void execute(SchedulableContext SC) {
      Database.executeBatch(new MW_UpdateBoxFolder1(), 1);
   }
   
}