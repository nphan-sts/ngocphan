/**
 * Class - To perform validation on contracts after migration
 *
 * 
 * @author - Pallavi
 * **/
global class Post_actualObj_ValidationJob implements Database.Batchable<sObject> {
    public Integer thread = 0;
    public Integer queryLimit = 0;
    public List<DM_PrimaryObject_Query_Generator__c> queryGenerate = [Select id,DM_object_name__c,DM_Query_Fields__c,DM_Parent_Object__c
                                                        from DM_PrimaryObject_Query_Generator__c
                                                        where DM_Active__c = true and DM_isChild_of_anotherObject__c = true];

    Map<String,DM_PrimaryObject_Query_Generator__c> MapQueryGenerate = new  Map<String,DM_PrimaryObject_Query_Generator__c>();
	Map<String,List<sObject>> queryChildContracts = new Map<String,List<sObject>>();

    global Post_actualObj_ValidationJob(){
        for(DM_PrimaryObject_Query_Generator__c QueryGen : queryGenerate){
            MapQueryGenerate.put(QueryGen.DM_object_name__c,QueryGen);
        }
                
    }
    
    global Post_actualObj_ValidationJob(Integer threadNumber){
        thread = threadNumber;    
        for(DM_PrimaryObject_Query_Generator__c QueryGen : queryGenerate){
            MapQueryGenerate.put(QueryGen.DM_object_name__c,QueryGen);
        }
    }
    
    /*global Post_actualObj_ValidationJob(Integer threadNumber,Integer qryLimit){
        thread = threadNumber;    
        queryLimit = qryLimit;
        for(DM_PrimaryObject_Query_Generator__c QueryGen : queryGenerate){
            MapQueryGenerate.put(QueryGen.DM_object_name__c,QueryGen);
        }
    }*/
    
    global Database.QueryLocator start(Database.BatchableContext BC)		//run with scope 1
    {
        Post_actualObj_SqlQueryGenerator sqlQuery = new Post_actualObj_SqlQueryGenerator();  
        return Database.getQueryLocator(sqlQuery.GetQueryString(thread)); //loan__Interest_Posting_Transaction__c
    }
    global void execute(Database.BatchableContext BC,List<loan__Loan_Account__c> ContractList)
    {
        system.debug('scope list '+ContractList.size());
        
        List<DM_PrimaryObject_Query_Generator__c> generateQuery = [Select id,DM_object_name__c,DM_Query_Fields__c,DM_Parent_API_Name__c
                                                                from DM_PrimaryObject_Query_Generator__c
                                                                where DM_Active__c = true
                                                                and DM_isChild_of_Contract__c = true ];
        for(DM_PrimaryObject_Query_Generator__c objectFields : generateQuery){
            String query = 'Select ' + objectFields.DM_Query_Fields__c + ' from ' + objectFields.DM_object_name__c + ' where '+objectFields.DM_Parent_API_Name__c+ ' in: ContractList';
            // CRM-904
            if(objectFields.DM_object_name__c == 'loan__Repayment_Schedule__c'){
                query = query + ' and loan__Is_Archived__c = false';
            }
            // CRM-904
            // pallavi(correcting the validation)
            if(objectFields.DM_object_name__c == 'loan__Loan_account_Due_Details__c'){
                query = query + ' and loan__DD_Primary_Flag__c = true';
            }  
            // pallavi(correcting the validation)
            System.debug('query ' + query);
            List<sObject> childData = Database.query(query);
            queryChildContracts.put(objectFields.DM_object_name__c, childData);
        }
        
        Post_actualObj_ValidationHandler handler = new Post_actualObj_ValidationHandler();
        handler.ValidationWrapper(ContractList,MapQueryGenerate,queryChildContracts);
     }
      global void finish(Database.BatchableContext BC) {
         system.debug('Finish Batch Job');
    }
}