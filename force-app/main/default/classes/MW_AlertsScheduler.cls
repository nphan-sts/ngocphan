global class MW_AlertsScheduler implements Schedulable {

   global void execute(SchedulableContext SC) {
      Database.executeBatch(new MW_Alerts(), 1);
   }

}