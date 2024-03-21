/*to be run only if some data gets missed while the original migration*
* author - Pallavi*/

Global class DM_SpecificObjects_MigrationJob implements Database.Batchable<sObject> {
    
    public String migrationBatchType;
    public static String migrationBatchType;
    public String migrationPhase;
    public List<DM_Loan_Account__c> errorUpdate = new List<DM_Loan_Account__c>();
    public List<Dm_ValidationWrapper> validationWrapperList = new List<DM_ValidationWrapper>();
    public DM_Metadata_Config_Wrapper configWrapper;
    public Integer thread = 0;
    
    global DM_SpecificObjects_MigrationJob(){
        configWrapper = ParserUtil.getParser();
    }

	global DM_SpecificObjects_MigrationJob(String migrationPhase){
        configWrapper = ParserUtil.getParser();
        migrationPhase = migrationPhase;
    }    
	
    global Database.QueryLocator start(Database.BatchableContext BC){
        DM_SpecificObjects_SqlQueryGenerator sqlQuery = new DM_SpecificObjects_SqlQueryGenerator(); 
        System.debug('query fired... '+sqlQuery.GetQueryString('DM_Repayment_Schedule_Summary__c;DM_Loan_Payment_Transaction__c;DM_Loan_Disbursal_Transaction__c;DM_Charge__c;DM_Bill__c;DM_Automated_Payment_Setup__c;DM_Repayment_Schedule__c;DM_Investment_Order__c;DM_Interest_Posting_Transaction__c;DM_Accrual_Entry__c;DM_Multi_Step_Loan_Setup__c;DM_Loan_Account__c'));
        return Database.getQueryLocator(sqlQuery.GetQueryString('DM_Repayment_Schedule_Summary__c;DM_Loan_Payment_Transaction__c;DM_Loan_Disbursal_Transaction__c;DM_Charge__c;DM_Bill__c;DM_Automated_Payment_Setup__c;DM_Repayment_Schedule__c;DM_Investment_Order__c;DM_Interest_Posting_Transaction__c;DM_Accrual_Entry__c;DM_Multi_Step_Loan_Setup__c;DM_Loan_Account__c'));
    }
    global void execute(Database.BatchableContext BC,List<DM_Loan_Account__c> dmList){
        System.debug('scope list '+dmList.size()+ 'list '+dmList);
        DM_SpecificObjects_Data_Creation dataCreation = new DM_SpecificObjects_Data_Creation();
        dataCreation.DataCreation(dmList);
        System.debug('test');
    }
    global void finish(Database.BatchableContext BC){
        system.debug('Finish Batch Job');
    }
}