global class NachaAlertDynamicJob extends clcommon.DynamicJob implements Database.AllowsCallouts,Database.RaisesPlatformEvents {
    loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();       
    private static String JOB_NAME = 'NachaAlertDynamicJob';  
    
    global NachaAlertDynamicJob() {
        super(JOB_NAME, null);
    }
    global NachaAlertDynamicJob(String query) {
        super(JOB_NAME, query);
    }
    
    global override void doInitialize() {} 
    
    global override String getRuntimeQuery() {   
        mfiflexUtil.ExecutionContext ec = mfiflexUtil.ExecutionContext.getExecContext();
        mfiflexUtil.ObjectCache loanPmtOC = ec.getObject('Document');
        if(loanPmtOC != null) {
            ec.deleteObject('loan__Automated_Payment_Configuration__c');
        }
        loanPmtOC = ec.createObject('loan__Automated_Payment_Configuration__c',
                                    'loan__Automated_Payment_Configuration__c',
                                    '');
        loanPmtOC.addFields('id,name,loan__Folder_Name__c,Box_Folder_ID__c'); 
        loanPmtOC.setWhereClause('loan__Folder_Name__c != null AND Box_Folder_ID__c != null');
        loanPmtOC.buildQuery(); 
        return loanPmtOC.getQuery();
   } 
     
    global override void doexecute(SchedulableContext sc) {
          
    }
     
    global override void doexecute(Database.BatchableContext bc, List<sObject> scope) {}
  
    global override void doStart(Database.BatchableContext bc) {}
   
    global override void dofinish(Database.BatchableContext bc) {
        List<loan__Automated_Payment_Configuration__c> apcList = Database.query(getRuntimeQuery());

        LogsCalloutBatch logJob = new LogsCalloutBatch(apcList);
        
        if(!test.isRunningTest()){
            Database.executebatch(logJob);
        }  
    }  
 }