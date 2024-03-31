/*to run Billing job for select Contracts
 * @author = Pallavi
 */
public class DM_batch_forBillingJob{
    
    loan.GlobalLoanUtilFacade loanUtil = new loan.GlobalLoanUtilFacade();
    Date sodDate = loanUtil.getCurrentSystemDate();
    
    public void callBillingJob()
    {
        
        DateTime systemDateTime = DateTime.newInstance(sodDate.year(),sodDate.month(),sodDate.day());
        String systemDate = systemDateTime.format('yyyy-MM-dd');
        
        List<MigrationPhase__c> migrationPhase = MigrationPhase__c.getAll().values();
    	String phase = migrationPhase[0].phase__c;
         
        Boolean submitNextJob = False;
        Integer batchNumber = null;
        
        Set<Id> loanIDs = new Set<Id>();
		loanIDs.add('a1h2f000000Iu3l');
    
        String query = loan.ProcessJobQueryUtil4.getBillingAmzJobQuery(sodDate, batchNumber);
        String finalQuery = query + 'and loan__Next_Installment_Date__c > ' + systemDate;
        finalQuery = finalQuery + ' and loan__Next_Due_Generation_Date__c <='+ systemDate + ' and loan__is_rescheduled__c = true and isMigrated__c = true and DM_Migration_Phase__c = \'' +phase+ '\'';
        System.debug(logginglevel.error, '---------------finalQuery------------' +finalQuery);
        
        loan.BillingAmzJob amzJob = new loan.BillingAmzJob(finalQuery, sodDate, submitNextJob, loanIds);
        database.executeBatch(amzJob,1);
        
    }
}