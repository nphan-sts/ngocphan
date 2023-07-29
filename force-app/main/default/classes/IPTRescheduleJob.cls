/*******************************************************************************************************
 * 
 * @author Anusha
 * 
 * This class is to run IPTjob from CL contract details page and also from list view of CL contracts
 * This generates IPT for both single and multiple contracts
 * InterestPostingAmzJob of managed package is called interally.
 * 
 *********************************************************************************************************/
 
global class IPTRescheduleJob {
    
    Webservice static void runIPTJob(List<Id> LoanId)
    {
         Boolean submitNextJob = False;
         Integer batchNumber = null;
         Id ProcessingId;
         Set<Id> loanIDs = new Set<Id>();
         loanIDs.addAll(LoanId);
         loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
         try{
             List<loan__Loan_Account__c> loanAcc = [Select Id,loan__Branch__r.loan__Current_System_Date__c from loan__Loan_Account__c where Id in:LoanId];
             Date sodDate = loanAcc.get(0).loan__Branch__r.loan__Current_System_Date__c;
                
             String query = loan.ProcessJobQueryUtil4.getInterestPostingAmzJobQuery(sodDate, batchNumber);
             //where clause is generate this way to avoid 'only variable references are allowed in dynamic soql/sosl' error
             String loanIdList = '(\'';
                 for(loan__Loan_Account__c loan:loanAcc){
                     loanIdList = loanIdList+loan.id;
                     loanIdList = loanIdList+'\',\'';
                 }
             String finalIdList = LoanIdList.substring(loanIdList.indexOf('('),loanIdList.length()-2);
             finalIdList = finalIdList + ')';
             String finalQuery = query + ' and Id in '+ finalIdList;
             System.debug(logginglevel.error, 'finalQuery to be sent to InterestPostingAmzJob: ' +finalQuery);
                
             loan.InterestPostingAmzJob i = new loan.InterestPostingAmzJob(finalQuery, sodDate, submitNextJob,loanIDs);
             processingId = database.executeBatch(i,1);   
         }catch(Exception e){
             System.debug('Batch processing failed with exception: '+e.getMessage());
             batch.loan__Log_Level__c = 'ERROR';
            batch.loan__Message__c = 'IPT generation failed for one or more loans in ::'+ loanIDs + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
            batch.loan__Batch_Id__c = 'IPTRescheduleJob';
            insert batch;
         }
         System.debug(' Batch processig completed for ProcessingId: '+processingId);
        }    
}