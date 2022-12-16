/*
 * This class is serves as a bridge between ApptoContractConverterBatchJob which converts the applications to contracts 
 * and MW_AllocationEngineHandler which sends the final callouts to Allocation Engine.
 * This class isolates the execution contexts between callout and DMLs from both the classes. Better logic separation.
 * Also it provides better control over the governor limits for Allocation Engine
 * For the constructor with String query parameter, you can pass any query to send final calls to a specific set of applications
 * This will help in case there's a failure and a final Allocation call is to be sent for some set of applications 
 * A sample query :  SELECT Id,genesis__status__c FROM genesis__applications__c WHERE Id IN 
 *                   (SELECT genesis__Application__c FROM genesis__Application_Status_History__c WHERE CreatedDate = TODAY AND 
 *                   genesis__New_Value__c = 'funded')
 */

global class AllocationEngineCalloutBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {

    private static final String LOG_NAME = 'AllocationEngineCalloutBatch';

    public Set<Id> appIdList;
    public String queryStr;
    public String decisionLevel;

    /**
     * The is the intended entry point for the AllocationEngineCalloutBatch
     *
     * This confirm the funnel state before executing the call.
     * Remember, all code here is executing inside System.isBatch() == true
     *
     * @param ids The ids to execute, immediately cloned due to potentially shared list state
     * @param decisionLevel The decision level to consider
     *
     * @return Job id if executing
     */
    static global Id executeBatch(Set<Id> ids, String decisionLevel) {

        if (ids == null || ids.isEmpty()) {
            warn('No ids passed to AllocationEngineCalloutBatch for decision level: ' + decisionLevel);
            return null;
        }

        Set<Id> batchIds = ids.clone();

        try {
            Decimal configSize = MW_Settings__c.getInstance().Allocation_Engine_Batch_Size__c;
            Integer batchSize = configSize == null || configSize == 0 ? 10 : configSize.intValue();

            if (MW_AllocationEngineHandler.FINALIZED == decisionLevel) {
                List<String> unconvertedGuids = filterUnconvertedApps(batchIds);
                if (!unconvertedGuids.isEmpty()) {
                    warn('Final call not executed for following, as no contract was available for: ' + unconvertedGuids);
                }
            } else if (MW_AllocationEngineHandler.CANCELLED == decisionLevel) {
                List<String> uncancelledApps = filterUncancelledApps(batchIds);
                if (!uncancelledApps.isEmpty()) {
                    warn('Cancel call not executed for following, as app status not in MW_Settings cancel list: ' + uncancelledApps);
                }
            } else {
                warn('Invalid decision level for batch class: ' + decisionLevel);
                return null;
            }

            if (batchIds == null || batchIds.isEmpty()) {
                warn('No ids were available after filtering, for decision level: ' + decisionLevel);
                return null;
            }

            AllocationEngineCalloutBatch batch = new AllocationEngineCalloutBatch(batchIds, decisionLevel);
            return Database.executeBatch(batch, batchSize);

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage() + ', line number: ' + e.getLineNumber());
            MW_LogUtility.error(LOG_NAME, '', '', 'executeBatch', e);
            return null;
        }
    }

    static global void warn(String msg) {
        System.debug(LoggingLevel.WARN, msg);
        MW_LogUtility.warn(LOG_NAME, 'executeBatch', msg);
    }

    /**
     * @param ids Mutated - removed any id which does not have a contract
     * @return lead guid which have no contracts
     */
    private static List<String> filterUnconvertedApps(Set<Id> ids) {
        List<genesis__Applications__c> withoutContracts =
            [SELECT Id,
                    Lead_ID__c
             FROM   genesis__Applications__c
             WHERE  CL_Contract__c = NULL
             AND    Id IN :ids];

        Set<Id> withoutContractIds = toIds(withoutContracts);
        ids.removeAll(withoutContractIds);
        return toLeadGuids(withoutContracts);
    }

    /**
     * @param ids Mutated, removes any id which is not in MW_Settings cancel status list
     *
     * @return List of guids which are not to be cancelled
     */
    private static List<String> filterUncancelledApps(Set<Id> ids) {

        Set<String> cancelStatusSet = MW_AllocationEngineHandler.getCancelStatusSet();

        List<genesis__Applications__c> unCancelled =
            [SELECT Id,
                    Lead_ID__c
             FROM   genesis__Applications__c
             WHERE  genesis__Status__c NOT IN :cancelStatusSet
             AND    Id IN :ids];

        Set<Id> uncancelledIds = toIds(unCancelled);
        ids.removeAll(uncancelledIds);
        return toLeadGuids(unCancelled);
    }

    private static Set<Id> toIds(List<genesis__Applications__c> apps) {
        return (new Map<Id, SObject>(apps)).keySet();
    }

    private static List<String> toLeadGuids(List<genesis__Applications__c> apps) {
        List<String> guids = new List<String>();
        for (genesis__Applications__c app : apps) {
            guids.add(app.Lead_ID__c);
        }
        return guids;
    }

    global AllocationEngineCalloutBatch(String query, String decisionLevel){
        this.queryStr = query;
        this.decisionLevel = decisionLevel;
    }
    
    global AllocationEngineCalloutBatch(Set<Id> appIdList, String decisionLevel){
        this.appIdList = appIdList;
        this.decisionLevel = decisionLevel;
        if(appIdList != null){
            queryStr = 'SELECT Id FROM genesis__Applications__c WHERE Id IN : appIdList';
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){                              
        return Database.getQueryLocator(queryStr);    
    }
    
    global void execute(Database.BatchableContext bc, List<genesis__Applications__c> scope) {
        final String methodName = 'execute';
        List<Id> appIds = new List<Id>();
        if (MW_AllocationEngineHandler.isAllocationEngineServiceEnabled()) {
            for (genesis__Applications__c app : scope) {
                appIds.add(app.Id);
            }
            if (MW_AllocationEngineHandler.FINALIZED == decisionLevel) {
                MW_AllocationEngineHandler.handleFinal(appIds);
            } else if (MW_AllocationEngineHandler.CANCELLED == decisionLevel) {
                MW_AllocationEngineHandler.handleCancelled(appIds);
            } else {
                MW_LogUtility.error(LOG_NAME, methodName, 'Unsupported decision level ' + decisionLevel);
            }
        }else{
            MW_LogUtility.info(LOG_NAME,methodName,'Allocation Engine is NOT enabled');
        }
    }
    public void finish(Database.BatchableContext bc) {
        System.debug(LoggingLevel.INFO, 'AllocationEngineCalloutBatch.finish:' + appIdList);
        CertificateEmailSendBatch.executeBatch(appIdList);
    }
}