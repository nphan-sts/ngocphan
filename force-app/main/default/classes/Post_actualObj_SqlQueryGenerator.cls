/**
 * Class - To perform validation on contracts after migration
 *
 * 
 * @author - Pallavi
 * **/
public with sharing class Post_actualObj_SqlQueryGenerator 
{
    //Method will return SOQL - CL Contract as Parent and their related children(passed in the argument).
    public String GetQueryString(Integer thread)
    {
        string query ='';
        string parent='';
        String finalQuery = '';
        String parentFields = '';
        
        String status = 'Pending';
        
        List<DM_PrimaryObject_Query_Generator__c> generateQuery = [Select id,DM_object_name__c,DM_Query_Fields__c,DM_isChild_of_Contract__c
                                                                from DM_PrimaryObject_Query_Generator__c
                                                                where DM_Active__c = true and DM_isChild_of_Contract__c = false
                                                                and DM_isChild_of_anotherObject__c = false/*((DM_isChild_of_Contract__c = false
                                                                and DM_isChild_of_anotherObject__c = false)
                                                                or (DM_isChild_of_Contract__c = true))*/];
        for(DM_PrimaryObject_Query_Generator__c objectFields : generateQuery){
                if(objectFields.DM_isChild_of_Contract__c){
                    query = query + '(Select ' + objectFields.DM_Query_Fields__c + ' from ' +  objectFields.DM_object_name__c + '),';
                }
                else {
                    parent = objectFields.DM_object_name__c;
                    parentFields = objectFields.DM_Query_Fields__c;
                }
        }
        query = query.removeEnd(',');
        
        if(thread == 0)
            finalQuery = 'Select ' + parentFields + ' from ' + parent + ' where DM_Post_Migration_Validation_Status__c =\''+ status + '\' ';

        else
            finalQuery = 'Select ' + parentFields  + ' from ' + parent + ' where loan__Thread_Number__c = ' + thread + ' and DM_Post_Migration_Validation_Status__c =\''+ status + '\' ';
       
        System.debug('finalQuery ' + finalQuery);
        return finalQuery;
    }
    
    //Query to retrieve InvestmentOrder Children 
    public String GetQueryStringTemp(String srcObject, String parentId, Set<Id> IOIds)
    {
        string query ='';

        DM_PrimaryObject_Query_Generator__c generateQuery = [Select id,DM_object_name__c,DM_Query_Fields__c,DM_Parent_Object__c
                                                                    from DM_PrimaryObject_Query_Generator__c
                                                                    where DM_Active__c = true and DM_object_name__c =: srcObject];

        query = query + 'Select ' + generateQuery.DM_Query_Fields__c + ' from ' + generateQuery.DM_object_name__c + ' Where ' + generateQuery.DM_Parent_Object__c + ' in: IOIds';
     
        System.debug(query);
        return query;
    }
    //Query to retrieve Disbursal Txn Distribution 
    /*pallavi*/
    public String GetQueryStringTemp1(String srcObject, String parentId, Set<Id> LDTIds,Map<String,DM_PrimaryObject_Query_Generator__c> MapQueryGenerate)
    {
        string query ='';

        DM_PrimaryObject_Query_Generator__c generateQuery = MapQueryGenerate.get(srcObject);


        query = query + 'Select ' + generateQuery.DM_Query_Fields__c + ' from ' + srcObject + ' Where ' + generateQuery.DM_Parent_Object__c + ' in: LDTIds';
        System.debug(query);
        return query;
    }
    public String GetQueryStringTemp2(String srcObject, String parentId, Set<Id> LPTIds,Map<String,DM_PrimaryObject_Query_Generator__c> MapQueryGenerate)
    {
        string query ='';
        
        DM_PrimaryObject_Query_Generator__c generateQuery = MapQueryGenerate.get(srcObject);

        query = query + 'Select ' + generateQuery.DM_Query_Fields__c + ' from ' + srcObject + ' Where ' + generateQuery.DM_Parent_Object__c + ' in: LPTIds';

        System.debug(query);
        return query;
    }
    /*pallavi*/
}