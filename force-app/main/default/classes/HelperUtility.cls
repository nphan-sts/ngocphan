public class HelperUtility {

    public static String getDayOfWeek(Date today) {
        
        Datetime dt = DateTime.newInstance(today, Time.newInstance(0, 0, 0, 0));
        String dayOfWeek = dt.format('EEEE');
        System.debug('Day : ' + dayOfWeek);
        
        return dayOfWeek;
    }
    
    public static Date getNextOriginationDate(Date currentSystemDate) {
        
        If(HelperUtility.getDayOfWeek(currentSystemDate) == 'Saturday' ||
           HelperUtility.getDayOfWeek(currentSystemDate) == 'Sunday') {
            currentSystemDate = loan.HolidayUtil.INSTANCE.getNextWorkingDate(currentSystemDate).addDays(1);       
        }else{
            currentSystemDate = currentSystemDate.addDays(1);    
        }
        return loan.HolidayUtil.INSTANCE.getNextWorkingDate(currentSystemDate);
    }
    
    
    public static void createLog(String message,String origin,Date logDate) {
        loan__Batch_Process_log__c bpLog = new loan__Batch_Process_log__c();
        bpLog.loan__Message__c = message;
        bpLog.loan__Time__c = System.Now();
        bpLog.loan__Date__c =  logDate;
        bpLog.loan__Origin__c = origin;
        
        insert bpLog;
    }
    
    public static List<loan__Batch_Process_Log__c> createLogs(List<Database.SaveResult> results,String origin) {
        List<loan__Batch_Process_Log__c> retVal = new List<loan__Batch_Process_Log__c>();
        loan__Batch_Process_Log__c bLog;
        
        for (Database.SaveResult sr : results) {
            
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully Performed DML for Record: ' + sr.getId());
            }
            else {
                bLog = new loan__Batch_Process_Log__c(loan__Origin__c = origin);
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    
                    bLog.loan__Message__c = 'Error while performing DMLs for '+'\'' + Origin + '\'' +'. Error Status Code: '+err.getStatusCode()+'. Error Message: '+err.getMessage();
                    bLog.loan__date__c = Date.today();
                    retVal.adD(bLog);
                }
            }
        }
        
        return retVal;
    }

}