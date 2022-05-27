global class ApplicationExpiryUpdate implements Database.Batchable<SObject>, Schedulable, Database.AllowsCallouts {

    static global Set<Id> notifyIds = new Set<Id>();

    String query;
    List<String> skipLoanStatus = System.Label.Application_Expired_Status.split(',');
    String CSD = String.valueOf(new loan.GlobalLoanUtilFacade().getCurrentSystemDate());
    Date currentSystemDate = (new loan.GlobalLoanUtilFacade().getCurrentSystemDate());


    global ApplicationExpiryUpdate() {

        query = 'select id, Expiry_Date__c, genesis__Status__c,CreatedById, DocuSign_EnvelopeId__c, Expiration_Tag__c, (select id,name,Loan_amount_counteroffer__c from Credit_Policy__r where Loan_amount_counteroffer__c!=null limit 1 ) from genesis__Applications__c where Expiry_Date__c =' + CSD + ' and genesis__Status__c not in : skipLoanStatus';

        System.debug(logginglevel.error, 'query+++' + query);
    }
    
    global ApplicationExpiryUpdate(String query){
        
        this.query = query; 
    }
    
    global void execute(SchedulableContext sc) {

        ApplicationExpiryUpdate b = new ApplicationExpiryUpdate();
        Database.executeBatch(b, 1);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){

        notifyIds.clear();
        System.debug(LoggingLevel.INFO, 'ApplicationExpiryUpdate Query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        ApplicationExpiryUpdateHandler.execute(CSD, currentSystemDate, scope, notifyIds);
    }

    public void finish(Database.BatchableContext BC) {

        System.debug(LoggingLevel.INFO, 'ApplicationExpiryUpdate.finish: ' + notifyIds);
        if (notifyIds != null && !notifyIds.isEmpty()) {
            try {
                Integer batchSize = Integer.valueOf(MW_Settings__c.getInstance().Allocation_Engine_Batch_Size__c);
                AllocationEngineCalloutBatch aEBatch = new AllocationEngineCalloutBatch(notifyIds, MW_AllocationEngineHandler.CANCELLED);
                Database.executeBatch(aEBatch, batchSize);
            } catch (Exception ex) {
                MW_LogUtility.error('ApplicationExpiryUpdate', '', '', 'finish', ex);
            }
        }
    }
}