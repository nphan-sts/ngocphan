/*******************************************************************************************************
 * 
 * @author Anusha
 * 
 * This class is to run bill generation job from CL contract details page and also from list view of CL contracts
 * This generates new bill if bill generation date is less than or equal to SOD date for both single and multiple contracts
 * BillingAmzJob of managed package is called interally.
 * 
 *********************************************************************************************************/

global class BillsGenerationJob {
    
    Webservice static void runBillingJob(List<Id> LoanId)
    {   
        Id processingId;
        Boolean submitNextJob = False;
        Integer batchNumber = null;
        Set<ID> loanIds = new Set<ID>();
        loanIDs.addall(LoanId);
        loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
        try{
            List<loan__Loan_Account__c> loanAcc = [Select Id,loan__Branch__r.loan__Current_System_Date__c from loan__Loan_Account__c where Id=:LoanId];
       		Date sodDate = loanAcc.get(0).loan__Branch__r.loan__Current_System_Date__c;
        	System.debug('SystemDate: '+sodDate);
        	String query = loan.ProcessJobQueryUtil4.getBillingAmzJobQuery(sodDate, batchNumber);
            //where clause to avoid 'only variable references are allowed in dynamic soql/sosl' error
            String loanIdList = '(\'';
            for(loan__Loan_Account__c loan:loanAcc){
                loanIdList = loanIdList+loan.id;
                loanIdList = loanIdList+'\',\'';
            }
            String finalWhere = LoanIdList.substring(loanIdList.indexOf('('),loanIdList.length()-2);
            finalWhere = finalWhere + ')';
            String finalQuery = query + ' and Id in '+finalWhere;
            System.debug(logginglevel.error, 'Query sent to BillingAmzJob: ' +finalQuery);
            
            loan.BillingAmzJob amzJob = new loan.BillingAmzJob(finalQuery, sodDate, submitNextJob, loanIds);
            processingId = database.executeBatch(amzJob,1);
        }catch(Exception e){
            System.debug('Batch processing failed with exception: '+e.getMessage());
            batch.loan__Log_Level__c = 'ERROR';
            batch.loan__Message__c = ' Bill generation failed for one or more loans in ::'+ loanIDs + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
            batch.loan__Batch_Id__c = 'BillsGenerationJob';
            insert batch;
        }      
        System.debug('Bill generation job completed with processing id : '+processingId);
        
    }    
}