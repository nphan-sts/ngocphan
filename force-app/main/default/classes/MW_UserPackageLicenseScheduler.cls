global class MW_UserPackageLicenseScheduler implements Schedulable{
    global void execute(SchedulableContext SC) {
         Database.executeBatch(new MW_UserPackageLicense(), 200);
    }
}