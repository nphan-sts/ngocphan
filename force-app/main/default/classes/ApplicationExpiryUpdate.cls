/* To execute below batch class for a specific Expiry date(format YYYY-MM-DD) ,run the following script.
           Date specificDate=date.valueOf('2015-03-08');
		   ApplicationExpiryUpdate b = new ApplicationExpiryUpdate(specificDate);
		   Database.executeBatch(b,1);
*/

global class ApplicationExpiryUpdate implements Database.Batchable<SObject>, Schedulable, Database.Stateful, Database.AllowsCallouts 
{
    global Set<Id> notifyIds = new Set<Id>();
    String query;
    List<String> skipLoanStatus = System.Label.Application_Expired_Status.split(',');
    String CSD;
    Date currentSystemDate;      
    global ApplicationExpiryUpdate()
    {
    currentSystemDate = (new loan.GlobalLoanUtilFacade().getCurrentSystemDate());
    CSD = String.valueof(currentSystemDate);          
    }
    
    global ApplicationExpiryUpdate(Date specificDate)
    {
        if(specificDate != null)
        {
            CSD = String.valueof(specificDate);
            this.currentSystemDate = specificDate;
        }
    }
            
    global void execute(SchedulableContext sc)
    {
        ApplicationExpiryUpdate b = new ApplicationExpiryUpdate();
        Database.executeBatch(b,1);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        if(query == null)
        {
            //LOP-270 changed condition to Expiry date <= CSD
            query = 'SELECT '+
                    'Id, Expiry_Date__c, genesis__Status__c, CreatedById,' +
                    'DocuSign_EnvelopeId__c, Expiration_Tag__c, '+
                    '(SELECT id,name, Loan_amount_counteroffer__c ' +
                    'FROM '+
                    'Credit_Policy__r '+
                    'WHERE '+
                    'Loan_amount_counteroffer__c!=null  LIMIT 1) '+
                    'FROM genesis__Applications__c '+
                    'WHERE Expiry_Date__c <='+ CSD +
                    ' AND genesis__Status__c NOT IN: skipLoanStatus';                                                                                                                                                                                       
        }                     
        System.debug('Query'+query);    
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope)
    {
        ApplicationExpiryUpdateHandler.execute(CSD, currentSystemDate, scope, notifyIds);
    }

    public void finish(Database.BatchableContext bc)
    { 
        System.debug(LoggingLevel.INFO, 'ApplicationExpiryUpdate.finish: ' + notifyIds);
        AllocationEngineCalloutBatch.executeBatch(notifyIds, MW_AllocationEngineHandler.CANCELLED);
    }
}