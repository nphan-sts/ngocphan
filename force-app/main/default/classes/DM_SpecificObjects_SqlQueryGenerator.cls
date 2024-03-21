/*author - Pallavi*/
public with sharing class DM_SpecificObjects_SqlQueryGenerator {
    
    public String GetQueryString(String srcObject)
    {
        string query ='';
        string parent='';
        string status='Success';
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = new Map <String, Schema.SObjectField>();
        for(String sObj : srcObject.split(';')){
            fieldMap =schemaMap.get(sObj).getDescribe().fields.getMap();
            String queryFields = Null;
            for(Schema.SObjectField sField :fieldMap.values())
            {
                schema.describefieldresult dfield = sfield.getDescribe();
                if(queryFields != Null)
                {
                    queryFields = queryFields + ',' + dfield.getname();
                }
                else
                {
                    queryFields = dfield.getname();
                }
            } 
            
            /*pallavi*/
            if(sobj == 'DM_Multi_Step_Loan_Setup__c'){
                sobj = 'DM_Rate_Schedule_Setups__r';
                query += '(Select '+queryFields+ ' from '+sobj +'),';
            }
            /*pallavi*/
            else if(sobj !='DM_Loan_Account__c'){
                sobj = sobj.replace('__c','s__r');
                query += '(Select '+queryFields+ ' from '+sobj +'),';
            }
            else{
                query= query.removeEnd(',');
                parent = 'select '+queryFields+','+query+' from '+sobj + ' where Migration_status__c = \'' +status+ '\'';
            }           
        }
        System.debug(parent);
        return parent;
    }
    
    //Query to retrieve InvestmentOrder Children 
    /*public String GetQueryStringTemp(String srcObject, String parentId, Set<Id> dmIOIds)
    {
        string query ='';
        string parent='';
        string status='pending';
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = new Map <String, Schema.SObjectField>();
        for(String sObj : srcObject.split(';')){
            fieldMap =schemaMap.get(sObj).getDescribe().fields.getMap();
            String queryFields = Null;
            for(Schema.SObjectField sField :fieldMap.values())
            {
                schema.describefieldresult dfield = sfield.getDescribe();
                if(queryFields != Null)
                {
                    queryFields = queryFields + ',' + dfield.getname();
                }
                else
                {
                    queryFields = dfield.getname();
                }
            } 
            
            if(sobj =='DM_Investor_Loan_Transaction__c'){
                //sobj = sobj.replace('__c','s__r');
                query = 'Select '+queryFields+ ' from '+sobj + ' where DM_Investment_Order__c IN :dmIOIds';
            }       
        }
        System.debug(query);
        return query;
    }*/
    //Query to retrieve Disbursal Txn Distribution 
    /*pallavi*/
    /*public String GetQueryStringTemp1(String srcObject, String parentId, Set<Id> dmLDTIds)
    {
        string query ='';
        string parent='';
        string status='pending';
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = new Map <String, Schema.SObjectField>();
        for(String sObj : srcObject.split(';')){
            fieldMap =schemaMap.get(sObj).getDescribe().fields.getMap();
            String queryFields = Null;
            for(Schema.SObjectField sField :fieldMap.values())
            {
                schema.describefieldresult dfield = sfield.getDescribe();
                if(queryFields != Null)
                {
                    queryFields = queryFields + ',' + dfield.getname();
                }
                else
                {
                    queryFields = dfield.getname();
                }
            } 
            
            if(sobj =='DM_Disbursal_Transaction_Distribution__c'){
                System.debug('dmLDTIds----' + dmLDTIds);
                query = 'Select '+queryFields+ ' from '+sobj + ' where dm_Loan_Disbursal_Transaction__c IN :dmLDTIds';
                System.debug('query DM_Disbursal_Transaction_Distribution__c----' + query);
            }        
        }
        System.debug(query);
        return query;
    }*/
    public String GetQueryStringTemp2(String srcObject, String parentId, Set<Id> dmLPTIds)
    {
        string query ='';
        string parent='';
        string status='pending';
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = new Map <String, Schema.SObjectField>();
        for(String sObj : srcObject.split(';')){
            fieldMap =schemaMap.get(sObj).getDescribe().fields.getMap();
            String queryFields = Null;
            for(Schema.SObjectField sField :fieldMap.values())
            {
                schema.describefieldresult dfield = sfield.getDescribe();
                if(queryFields != Null)
                {
                    queryFields = queryFields + ',' + dfield.getname();
                }
                else
                {
                    queryFields = dfield.getname();
                }
            } 
            
            if(sobj == 'DM_Due_Payment__c'){
                System.debug('dmLPTIds----' + dmLPTIds);
                query = 'Select '+queryFields+ ' from '+sobj + ' where DM_Loan_Payment_Transaction__c IN :dmLPTIds';
                System.debug('query DM_Due_Payment__c----' + query);
            }        
        }
        System.debug(query);
        return query;
    }
    /*pallavi*/

}