@IsTest
private class AllocationEngineCalloutBatchTest {

    @TestSetup static void setup() {
    
        Account investor1 = MW_GlobalTestUtility.GetAccount('Investor');
        investor1.Investor_Code__c = 'FCU';
    
        Account investor2 = MW_GlobalTestUtility.GetAccount('Investor');
        investor2.Investor_Code__c = 'GCSU';
    
        Account member1 = MW_GlobalTestUtility.GetAccount('Member');
        member1.State__c = 'CA';
        member1.ZIP_Code__c = '92782';
    
        Account member2 = MW_GlobalTestUtility.GetAccount('Member');
        member2.State__c = 'VA';
        member2.ZIP_Code__c = '92782';
    
        insert new List<Account> {investor1, investor2, member1, member2};
    
        /* Used for most tests, but typical app wont have all this data */
        genesis__Applications__c app1 = MW_GlobalTestUtility.GetApplication();
        app1.genesis__Account__c = member1.Id;
        app1.genesis__Status__c = PayoffConstants.AGENT_DOCUMENT_VERIFICATION_PENDING;
        app1.Investor__c = investor1.Id;
        app1.Lead_ID__c = 'abc123';
        app1.genesis__APR__c = 7.00;
        app1.genesis__Interest_Rate__c = 10.00;
        app1.Pricing_Tier__c = 't1';
        app1.genesis__Term__c = 5;
        app1.FICO__c = 700.00;
        app1.Monthly_DTI__c = 12;
        app1.Net_Disposable_Income_NDI_Num__c = 1200;
        app1.Loan_Purpose__c = 'debt_consolidation';
        app1.Credit_Policy_Approval_Models__c = 'crb_otb';
        app1.genesis__Loan_Amount__c = 25000.00;
        app1.utm_medium__c = 'medium';
        app1.utm_source__c = 'source';
        app1.utm_campaign__c = 'campaign';
        app1.Allocation_ID__c = 'alloc1';
        app1.Allocation_Operation_Error__c = MW_AllocationEngineHandler.ADVP;
        app1.Allocation_Timestamp__c = Datetime.now();
        app1.Expected_Yield__c = 321.11;
        app1.Expected_Chargeoff__c = 432.0;
    
        /* fresh advp apps will look more like this */
        genesis__Applications__c app2 = MW_GlobalTestUtility.GetApplication();
        app2.genesis__Account__c = member2.Id;
        app2.genesis__Status__c = PayoffConstants.AGENT_DOCUMENT_VERIFICATION_PENDING;
        app2.Lead_ID__c = 'def456';
        app2.genesis__APR__c = 7.99;
        app2.genesis__Interest_Rate__c = 10.00;
        app2.Pricing_Tier__c = 't2';
        app2.genesis__Term__c = 5;
        app2.FICO__c = 700.00;
        app2.Monthly_DTI__c = 12;
        app2.Net_Disposable_Income_NDI_Num__c = 1200;
        app2.Loan_Purpose__c = 'debt_consolidation';
        app2.Credit_Policy_Approval_Models__c = null;
        app2.genesis__Loan_Amount__c = 15000.00;
        insert new List<genesis__Applications__c> {app1, app2}; 
        
        app1.genesis__Status__c = PayoffConstants.FUNDED;
        app2.genesis__Status__c = PayoffConstants.FUNDED;  
        
        update new List<genesis__Applications__c> {app1, app2};
    }
    @isTest static void testBatchClassExecutionWithApps() {
        
        insert getMWSettings();
        Id jobId;
        set<Id> appIds = new set<Id>();
        Integer batchSize = Integer.valueOf(MW_Settings__c.getOrgDefaults().Allocation_Engine_Batch_Size__c);
        
        for(genesis__applications__c app : [SELECT Id FROM genesis__applications__c]){
            appIds.add(app.Id);
        }
        Test.startTest();
            AllocationEngineCalloutBatch btch = new AllocationEngineCalloutBatch(appIds, MW_AllocationEngineHandler.FINALIZED);
            jobId = Database.executeBatch(btch,batchSize);
        Test.stopTest();
        AsyncApexJob asapx = [SELECT Id, Status FROM AsyncApexJob WHERE Id =: jobId];
        System.assertEquals('Completed',asapx.Status);
    }
    @isTest static void testBatchClassExecutionWithQuery() {
        insert getMWSettings();
        Id jobId;
        Integer batchSize = Integer.valueOf(MW_Settings__c.getOrgDefaults().Allocation_Engine_Batch_Size__c);
        String queryStr =  'SELECT Id,genesis__status__c FROM genesis__applications__c ';
               queryStr += 'WHERE Id IN (SELECT genesis__Application__c FROM genesis__Application_Status_History__c ';
               queryStr += 'WHERE CreatedDate = TODAY AND genesis__New_Value__c = \'funded\')';
        Test.startTest();
            AllocationEngineCalloutBatch btch = new AllocationEngineCalloutBatch(queryStr, MW_AllocationEngineHandler.FINALIZED);
            jobId = Database.executeBatch(btch,batchSize);
        Test.stopTest();
        AsyncApexJob asapx = [SELECT Id, Status FROM AsyncApexJob WHERE Id =: jobId];
        System.assertEquals('Completed',asapx.Status);
    }
    static MW_Settings__c getMWSettings(){
        MW_Settings__c mwSettings = new MW_Settings__c();
        mwSettings.Allocation_Engine_Deployment_Mode__c = 'DARK_MODE';
        mwSettings.Allocation_Engine_Service_URL_FMT__c = 'http://localhost:8080/{0}';
        mwSettings.Allocation_Engine_Cancel_Statuses__c = 'Declined,Expired,Withdrawn,Decline_Manual_Review,Expired-Withdrawn';
        mwSettings.Allocation_Engine_Batch_Size__c = 50;
        return mwSettings;
    }
}