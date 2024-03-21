/**
 * Data Migration Batch Job --> This will pick the Pending data from Staging tables and process them. 
 * If succeed, data will be migrated to the actual Contract and related tables; else, Error will be shown and status will be marked as Failed.
 * 
 * @author - Nikhil Chawra
 * **/

Global class DM_MigrationJob implements Database.Batchable<sObject> 
{   
    public String migrationBatchType;
    public static String migrationBatchType;
    public List<DM_Loan_Account__c> errorUpdate = new List<DM_Loan_Account__c>();
    public List<Dm_ValidationWrapper> validationWrapperList = new List<DM_ValidationWrapper>();
    public DM_Metadata_Config_Wrapper configWrapper;
    public Integer thread = 0;	//pallavi
    public Integer queryLimit = 0;	//pallavi

    public List<DM_StagingObject_Query_Generator__c> queryGenerate = [Select id,DM_object_name__c,DM_Query_Fields__c,DM_Parent_Object__c
                                                        from DM_StagingObject_Query_Generator__c
                                                        where DM_Active__c = true and DM_isChild_of_anotherObject__c = true];

    Map<String,DM_StagingObject_Query_Generator__c> MapQueryGenerate = new  Map<String,DM_StagingObject_Query_Generator__c>();
	Map<String,List<sObject>> queryChildContracts = new Map<String,List<sObject>>();	// for optimisation
  
    global DM_MigrationJob(){
         //call the class and initialize the wrapper instance here.
         configWrapper = ParserUtil.getParser();  
         for(DM_StagingObject_Query_Generator__c QueryGen : queryGenerate){
            MapQueryGenerate.put(QueryGen.DM_object_name__c,QueryGen);
        }       
    }
    
    //BatchType Constructor provided to process any specific Data. 
    global DM_MigrationJob(String batchType){
        configWrapper = ParserUtil.getParser(); 
        migrationBatchType = batchType;
        for(DM_StagingObject_Query_Generator__c QueryGen : queryGenerate){
            MapQueryGenerate.put(QueryGen.DM_object_name__c,QueryGen);
        }
    }
    
    /*pallavi*/
    global DM_MigrationJob(String batchType,Integer threadNumber){
        configWrapper = ParserUtil.getParser();
        migrationBatchType = batchType;
        thread = threadNumber;   
        for(DM_StagingObject_Query_Generator__c QueryGen : queryGenerate){
            MapQueryGenerate.put(QueryGen.DM_object_name__c,QueryGen);
        } 
    }
    
    global DM_MigrationJob(Integer threadNumber){
        configWrapper = ParserUtil.getParser();
        thread = threadNumber; 
        for(DM_StagingObject_Query_Generator__c QueryGen : queryGenerate){
            MapQueryGenerate.put(QueryGen.DM_object_name__c,QueryGen);
        }   
    }
    
    /*global DM_MigrationJob(Integer threadNumber,Integer qryLimit){
        configWrapper = ParserUtil.getParser();
        thread = threadNumber;
        queryLimit = qryLimit;
        for(DM_StagingObject_Query_Generator__c QueryGen : queryGenerate){
            MapQueryGenerate.put(QueryGen.DM_object_name__c,QueryGen);
        }   
    }*/
    
    /*pallavi*/
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        DM_SqlQueryGenerator sqlQuery = new DM_SqlQueryGenerator();  
        //**modified by NehaDM. added - DM_Disbursal_Transaction_Distribution__c, DM_Multi_Step_Loan_Setup__c      
        return Database.getQueryLocator(sqlQuery.GetQueryString(migrationBatchType,thread));
    }//END start

    global void execute(Database.BatchableContext BC, List<DM_Loan_Account__c> dmList) 
    {
        system.debug('scope list '+dmList.size()+ 'list '+dmList);
        Boolean dataCreationFlag = false; 
        
        DM_Validate_Impl handler = new DM_Validate_Impl();
        validationWrapperList = handler.validateDMRules(dmList,configWrapper);
        DM_Data_Creation dataCreation;
        For(DM_ValidationWrapper valWrapper : validationWrapperList){
            if(valWrapper.Success){
                system.debug('validation Wrap Success');
                dataCreationFlag = true;
            }else{
                dataCreationFlag = false;
                //failed valWrapper send for updation
                errorUpdate.add(new DM_Loan_Account__c(Id=dmList[0].Id, DM_Error__c= valWrapper.errorMessage, DM_Invalid_Data__c=True, migration_status__c='Failed'));
                system.debug('Failed');
                break;
            }//END Else
        }//END For 
        
        if(!errorUpdate.isEmpty())
            update errorUpdate;
        
        List<DM_StagingObject_Query_Generator__c> generateQuery = [Select id,DM_object_name__c,DM_Query_Fields__c,DM_Parent_API_Name__c
                                                                from DM_StagingObject_Query_Generator__c
                                                                where DM_Active__c = true
                                                                and DM_isChild_of_Contract__c = true ];
        for(DM_StagingObject_Query_Generator__c objectFields : generateQuery){
            String query = 'Select ' + objectFields.DM_Query_Fields__c + ' from ' + objectFields.DM_object_name__c + ' where '+objectFields.DM_Parent_API_Name__c+ ' in: dmList';
            query.removeEnd(',');
            if(objectFields.DM_object_name__c == 'dm_Repayment_Schedule__c'){
                query = query + ' order by DM_Due_Date__c';
            }
            System.debug('query ' + query);
            List<sObject> childData = Database.query(query);
            System.debug('childData ' + childData);
            queryChildContracts.put(objectFields.DM_object_name__c, childData);
        }
            
        if(dataCreationFlag){
            dataCreation = new DM_Data_Creation();
            dataCreation.DataCreation(dmList,MapQueryGenerate,queryChildContracts);
        }//END IF(dataCreationFlag)
    }//END execute
    
    global void finish(Database.BatchableContext BC) {
        system.debug('Finish Batch Job');
    }//END finish
}//END DM_MigrationJob