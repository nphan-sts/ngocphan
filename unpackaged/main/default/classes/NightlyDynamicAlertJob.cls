global with sharing class NightlyDynamicAlertJob extends clcommon.DynamicJob implements Database.AllowsCallouts,Database.RaisesPlatformEvents{

    private static String JOB_NAME = 'NightlyDynamicAlertJob'; 

    global NightlyDynamicAlertJob() {
        super(JOB_NAME, null);
    }
    global NightlyDynamicAlertJob(String query) {
        super(JOB_NAME, query);
    }

    global override void doInitialize() {} 
    
    global override String getRuntimeQuery() {   
        mfiflexUtil.ExecutionContext ec = mfiflexUtil.ExecutionContext.getExecContext();
        mfiflexUtil.ObjectCache dagLog = ec.getObject('clcommon__DAG_Logging__c');
        if(dagLog != null) {
            ec.deleteObject('clcommon__DAG_Logging__c');
        }
        dagLog = ec.createObject('clcommon__DAG_Logging__c',
                                    'clcommon__DAG_Logging__c',
                                    '');
        dagLog.addFields('id,name,clcommon__Status__c,clcommon__Start_Time__c,clcommon__Finish_Time__c'); 
        dagLog.setWhereClause('CreatedDate = TODAY');
        dagLog.setOrderClause('CreatedDate DESC ');
        dagLog.setLimitClause('1');
        dagLog.buildQuery(); 
        return dagLog.getQuery();
   } 
     
    global override void doexecute(SchedulableContext sc) {
          
    }
     
    global override void doexecute(Database.BatchableContext bc, List<sObject> scope) {}
  
    global override void doStart(Database.BatchableContext bc) {}
   
    global override void dofinish(Database.BatchableContext bc) {
        //get TODAY DAG logging
        List<clcommon__DAG_Logging__c> dagLog = Database.query(getRuntimeQuery());

        if(!test.isRunningTest()){

            NightlyDynamicAlertHandler.sendSlackCallout(dagLog);

        }  
    }  
}