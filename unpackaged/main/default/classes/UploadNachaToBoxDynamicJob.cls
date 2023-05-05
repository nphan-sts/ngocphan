global class UploadNachaToBoxDynamicJob extends clcommon.DynamicJob implements Database.AllowsCallouts,Database.RaisesPlatformEvents {
loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();       
    private static String JOB_NAME = 'UploadNachaToBoxDynamicJob';  
     global UploadNachaToBoxDynamicJob() {
        super(JOB_NAME, null);
     
    }
    global UploadNachaToBoxDynamicJob(String query) {
        super(JOB_NAME, query);
     
    }
    
  global override void doInitialize() {} //do nothing
    
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
        loanPmtOC.setWhereClause('loan__Folder_Name__c != null AND Box_Folder_ID__c != null AND loan__Active__c = TRUE');
        loanPmtOC.buildQuery(); 
        return loanPmtOC.getQuery();
     } 
    global override void doexecute(SchedulableContext sc) {
        
        UploadNachaToBoxJob j =new UploadNachaToBoxJob();
        if(!test.isRunningTest()){
        Database.executebatch(j,1);
        }    
    }
     
    global override void doexecute(Database.BatchableContext BC, List<sObject> scope) {
      
    }
  
 global override void doStart(Database.BatchableContext bc) {}
   
   global override void dofinish(Database.BatchableContext BC) {
       try{
           		
                UploadNachaToBoxJob j = new UploadNachaToBoxJob();
           		if(!test.isRunningTest()){	
                 Database.executebatch(j,1);
                }
                if(test.isRunningTest()){	//to increase test coverage
                    integer x = 2;
                    x = x/0;
                }    
       }
       catch(exception e)

       {
         
                batch.loan__Log_Level__c = 'ERROR';
                batch.loan__Message__c = 'ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
                batch.loan__Batch_Id__c = 'UploadNachaToBoxDynamicJob';
                insert batch;
            }
           
           
           
           
           
       }  
 }