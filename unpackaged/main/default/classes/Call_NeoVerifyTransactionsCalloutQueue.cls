/* ****************Modification History******************************************
 * Created By        Date          JIRA number
 *1. Pallavi        2020/08/13     CRM-755(Make NeoVerify Initiated Manually)
 *      
 ******************Modification History******************************************/
global class Call_NeoVerifyTransactionsCalloutQueue {
    
    webservice static String callMWNeoVerifyTransactions(Id applicationId){
        Set<Id> appId = new Set<Id>();
        appId.add(applicationId);
        ID jobId = System.enqueueJob(new MW_NeoVerifyTransactionsCalloutQueue(appId));
        System.debug('in Call_NeoVerifyTransactionsCalloutQueue----' + jobId);
        MW_Callout__c newCalloutJob = new MW_Callout__c();
        newCalloutJob.JobID__c = jobID;
        newCalloutJob.Status__c = 'Queued';
        insert newCalloutJob;
        return 'Transactions sent';
    }

}