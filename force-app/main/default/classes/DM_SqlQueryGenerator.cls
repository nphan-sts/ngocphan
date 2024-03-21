/**
 * Utility Class to generate SOQL query on the basis of Objects provided to it. 
 * 
 * @author - Nikhil Chawra
 * 
 * modified by - Pallavi
 * **/

public with sharing class DM_SqlQueryGenerator 
{
    //Method will return SOQL - CL Contract as Parent and their related children(passed in the argument).
    public String GetQueryString(String migrationBatchType,Integer thread)
    {
        string query ='';
        string parent='';
        string status='pending';
        String finalQuery = '';
        String parentFields = '';
        List<DM_StagingObject_Query_Generator__c> generateQuery = [Select id,DM_object_name__c,DM_Query_Fields__c,DM_isChild_of_Contract__c
                                                                from DM_StagingObject_Query_Generator__c
                                                                where DM_Active__c = true and DM_isChild_of_Contract__c = false
                                                                and DM_isChild_of_anotherObject__c = false/*((DM_isChild_of_Contract__c = false
                                                                and DM_isChild_of_anotherObject__c = false)
                                                                or (DM_isChild_of_Contract__c = true))*/];
        for(DM_StagingObject_Query_Generator__c objectFields : generateQuery){
                if(objectFields.DM_isChild_of_Contract__c){
                    query = query + '(Select ' + objectFields.DM_Query_Fields__c + ' from ' +  objectFields.DM_object_name__c + '),';
                }
                else {
                    parent = objectFields.DM_object_name__c;
                    parentFields = objectFields.DM_Query_Fields__c;
                }
        }
        //query = query.removeEnd(',');

        //if(!test.isRunningTest()){
        
        if(thread == 0)
            finalQuery = 'Select ' + parentFields + ' from ' + parent + ' where migration_status__c =\''+ status + '\' ';

        else
            finalQuery = 'Select ' + parentFields + ' from ' + parent + ' where dm_Thread_Number__c = ' + thread + ' and migration_status__c =\''+ status + '\'';
        
        //}
        /*else{
            if(thread == 0)
            finalQuery = 'Select ' + parentFields + ', ' + query + ' from ' + parent + ' where migration_status__c =\''+ status + '\' LIMIT 1';

        else
            finalQuery = 'Select ' + parentFields + ', ' + query + ' from ' + parent + ' where dm_Thread_Number__c = ' + thread + ' and migration_status__c =\''+ status + '\' LIMIT 1';
        
        }*/

        System.debug('finalQuery ' + finalQuery);
        return finalQuery;
    }
    //Query to retrieve InvestmentOrder Children 
    public String GetQueryStringTemp(String srcObject, String parentId, Set<Id> dmIOIds)
    {
        string query ='';

        DM_StagingObject_Query_Generator__c generateQuery = [Select id,DM_object_name__c,DM_Query_Fields__c,DM_Parent_Object__c
                                                                    from DM_StagingObject_Query_Generator__c
                                                                    where DM_Active__c = true and DM_object_name__c =: srcObject];

        query = query + 'Select ' + generateQuery.DM_Query_Fields__c + ' from ' + generateQuery.DM_object_name__c + ' Where ' + generateQuery.DM_Parent_Object__c + ' in: dmIOIds';
     
        System.debug(query);
        return query;
    }
    //Query to retrieve Disbursal Txn Distribution 
    /*pallavi*/
    public String GetQueryStringTemp1(String srcObject,String parentId, Set<Id> dmLDTIds,Map<String,DM_StagingObject_Query_Generator__c> MapQueryGenerate)
    {
        string query ='';

        DM_StagingObject_Query_Generator__c generateQuery = MapQueryGenerate.get(srcObject);


        query = query + 'Select ' + generateQuery.DM_Query_Fields__c + ' from ' + srcObject + ' Where ' + generateQuery.DM_Parent_Object__c + ' in: dmLDTIds';
        System.debug(query);
        return query;
    }
    public String GetQueryStringTemp2(String srcObject,String parentId, Set<Id> dmLPTIds,Map<String,DM_StagingObject_Query_Generator__c> MapQueryGenerate)
    {
        string query ='';
        
        DM_StagingObject_Query_Generator__c generateQuery = MapQueryGenerate.get(srcObject);
     
        query = query + 'Select ' + generateQuery.DM_Query_Fields__c + ' from ' + srcObject + ' Where ' + generateQuery.DM_Parent_Object__c + ' in: dmLPTIds';

        System.debug(query);
        return query;
    }
    /*pallavi*/
}