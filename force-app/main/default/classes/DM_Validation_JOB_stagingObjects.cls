global class DM_Validation_JOB_stagingObjects implements Database.Batchable<sObject> {
    Integer thread = 0;
    Integer queryLimit = 0;
    public List<DM_StagingObject_Query_Generator__c> queryGenerate = [Select id,DM_object_name__c,DM_Query_Fields__c,DM_Parent_Object__c
                                                        from DM_StagingObject_Query_Generator__c
                                                        where DM_Active__c = true and DM_isChild_of_anotherObject__c = true];

    Map<String,DM_StagingObject_Query_Generator__c> MapQueryGenerate = new  Map<String,DM_StagingObject_Query_Generator__c>();
    Map<String,List<sObject>> queryChildContracts = new Map<String,List<sObject>>();
    global DM_Validation_JOB_stagingObjects(){
        for(DM_StagingObject_Query_Generator__c QueryGen : queryGenerate){
            MapQueryGenerate.put(QueryGen.DM_object_name__c,QueryGen);
        }    
                
    }
    /*pallavi*/
    global DM_Validation_JOB_stagingObjects(Integer threadNumber){
        thread = threadNumber;  
        for(DM_StagingObject_Query_Generator__c QueryGen : queryGenerate){
            MapQueryGenerate.put(QueryGen.DM_object_name__c,QueryGen);
        }     
    }
    /*global DM_Validation_JOB_stagingObjects(Integer threadNumber,Integer qryLimit){
        thread = threadNumber; 
        queryLimit = qryLimit;
        for(DM_StagingObject_Query_Generator__c QueryGen : queryGenerate){
            MapQueryGenerate.put(QueryGen.DM_object_name__c,QueryGen);
        }     
    }*/
    /*pallavi*/
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String migrationBatchType = null;	//changed
        DM_SqlQueryGenerator_forValidation sqlQuery = new DM_SqlQueryGenerator_forValidation();  
        //System.debug('query... '+sqlQuery.GetQueryString('DM_Repayment_Schedule_Summary__c;DM_Loan_Payment_Transaction__c;DM_Loan_Disbursal_Transaction__c;DM_Charge__c;DM_Bill__c;DM_Automated_Payment_Setup__c;DM_Repayment_Schedule__c;DM_Investment_Order__c;DM_Interest_Posting_Transaction__c;DM_Accrual_Entry__c;DM_Multi_Step_Loan_Setup__c;DM_Loan_Account__c',migrationBatchType,thread));
		return Database.getQueryLocator(sqlQuery.GetQueryString(migrationBatchType,thread));   
    }
    global void execute(Database.BatchableContext BC,List<dm_Loan_Account__c> ContractList)
    {
        system.debug('scope list '+ContractList.size());
        
         List<DM_StagingObject_Query_Generator__c> generateQuery = [Select id,DM_object_name__c,DM_Query_Fields__c,DM_Parent_API_Name__c
                                                                from DM_StagingObject_Query_Generator__c
                                                                where DM_Active__c = true
                                                                and DM_isChild_of_Contract__c = true ];
        for(DM_StagingObject_Query_Generator__c objectFields : generateQuery){
            String query = 'Select ' + objectFields.DM_Query_Fields__c + ' from ' + objectFields.DM_object_name__c + ' where '+objectFields.DM_Parent_API_Name__c+ ' in: ContractList';
            System.debug('query ' + query);
            List<sObject> childData = Database.query(query);
            queryChildContracts.put(objectFields.DM_object_name__c, childData);
        }
        
        DM_Validation_stagingObjects_Handler handler = new DM_Validation_stagingObjects_Handler();
        handler.ValidationWrapper(ContractList,MapQueryGenerate,queryChildContracts);
     }
      global void finish(Database.BatchableContext BC) {
         system.debug('Finish Batch Job');
    }
}