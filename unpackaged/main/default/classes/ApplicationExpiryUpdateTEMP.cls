/*
This is to expire the applications for a specific expiry date.
How to execute batch(one time execute) :
Date dt = Date.valueOf('2019-04-20');
string qry = 'select id, Expiry_Date__c, genesis__Status__c,CreatedById, DocuSign_EnvelopeId__c, Expiration_Tag__c, (select id,name,Loan_amount_counteroffer__c from Credit_Policy__r where Loan_amount_counteroffer__c!=null limit 1) from genesis__Applications__c where Expiry_Date__c = 2019-04-20 and genesis__Status__c not in (\'funded\',\'Expired\',\'Approved for funding\',\'pre_funding\',\'Withdrawn\')';
Database.executeBatch(new ApplicationExpiryUpdateTEMP(qry,dt),1);

---schedule the batch, if required -----
//System.schedule('ApplicationExpiryUpdateTEMP', '0 32 13 * * ?', new ApplicationExpiryUpdateTEMP(qry,dt));
*/

global class ApplicationExpiryUpdateTEMP implements Database.Batchable<SObject>, Schedulable, Database.AllowsCallouts {

    static global Set<Id> notifyIds = new Set<Id>();

    String query;
    List<String> skipLoanStatus = System.Label.Application_Expired_Status.split(',');
    String CSD;
    Date currentSystemDate;

    global ApplicationExpiryUpdateTEMP() {
        CSD = String.valueOf(new loan.GlobalLoanUtilFacade().getCurrentSystemDate());
        currentSystemDate = (new loan.GlobalLoanUtilFacade().getCurrentSystemDate());
    }

    global ApplicationExpiryUpdateTEMP(String query, Date currentSystemDate) {
        this.query = query;
        if (currentSystemDate != null) {
            CSD = String.valueOf(currentSystemDate);
            this.currentSystemDate = currentSystemDate;
        } else {
            this.currentSystemDate = (new loan.GlobalLoanUtilFacade().getCurrentSystemDate());
        }
    }
    
    global void execute(SchedulableContext sc) {        
        ApplicationExpiryUpdateTEMP b = new ApplicationExpiryUpdateTEMP(query,currentSystemDate);
        Database.executeBatch(b,1);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {

        notifyIds.clear();
        if(query == null){
            query = 'select id, Expiry_Date__c, genesis__Status__c,CreatedById, DocuSign_EnvelopeId__c, Expiration_Tag__c, (select id,name,Loan_amount_counteroffer__c from Credit_Policy__r where Loan_amount_counteroffer__c!=null limit 1 ) from genesis__Applications__c where Expiry_Date__c =' + CSD +' and genesis__Status__c not in : skipLoanStatus';
        }
        System.debug(LoggingLevel.INFO, 'ApplicationExpiryUpdateTEMP Query===>' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        ApplicationExpiryUpdateHandler.execute(CSD, currentSystemDate, scope, notifyIds);
    }

    public void finish(Database.BatchableContext bc) {

        System.debug(LoggingLevel.INFO, 'ApplicationExpiryUpdateTEMP.finish:' + notifyIds);
        if (notifyIds != null && !notifyIds.isEmpty()) {
            try{
                Integer batchSize = Integer.valueOf(MW_Settings__c.getInstance().Allocation_Engine_Batch_Size__c);
                AllocationEngineCalloutBatch aEBatch = new AllocationEngineCalloutBatch(notifyIds, MW_AllocationEngineHandler.CANCELLED);
                Database.executeBatch(aEBatch, batchSize);
            }catch(Exception ex){
                MW_LogUtility.error('ApplicationExpiryUpdateTEMP','','','finish',ex);
            }
        }
    }
}