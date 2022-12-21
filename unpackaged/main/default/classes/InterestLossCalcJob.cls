/******************Modification History*****************************************
 * Punith          2022-10-07          LSP-452**
 * ****************************************************************************/
global without sharing class InterestLossCalcJob extends clcommon.DynamicJob {
    private static String NAME = 'Interest Loss Job';

    global InterestLossCalcJob() {
        super(NAME, getQuery());
    }
    
    global override String getRuntimeQuery() {
        String query = getQuery();
        return query;
    }
    
    public static String getQuery() {
        String ns = loan.CustomSettingsUtil.getOrgParameters().loan__Namespace_Prefix__c;
        mfiflexUtil.ExecutionContext ec = mfiflexUtil.ExecutionContext.getExecContext();
        mfiflexUtil.ObjectCache loanOC;
        loanOC = ec.getObject('InterestLoss');
        if( loanOC != null){
            ec.deleteObject('InterestLoss');
        }
        loanOC = ec.createObject('InterestLoss', 'Loan_Account__c', ns);
        String fields = loan.ObjectCacheQueryUtil.getLoanSnapshotFields();
        loanOC.addFields(fields);
        
        String whereClause = 'Invalid_Data__c = false';
        loanOC.setWhereClause(whereClause);
        loanOC.buildQuery();
        String query = loanOC.getQuery();
        query += ' AND Interest_Loss__c = true';
        return query;
    }
    
    global override String getRuntimeQueryForPipelinedExecution(Set<Id> records) {
        return null;
    }
    
    global override void doInitialize() {}
    
    public override void doStart(Database.BatchableContext batchableContext) {}
    
    global override void doExecute(Database.BatchableContext batchableContext, List<sObject> scope) {
        List<loan__Loan_Account__c> loanAccounts = (List<loan__Loan_Account__c>)scope;
        InterestLossCalcHandler handler = new InterestLossCalcHandler(loanAccounts);
        handler.process();
    }
    
    global override void doFinish(Database.BatchableContext batchableContext) {}
}