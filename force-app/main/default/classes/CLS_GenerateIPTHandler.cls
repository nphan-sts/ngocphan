public class CLS_GenerateIPTHandler {
    
    public static String generateIPT(List<String> contractNames){
        
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        Date sodDate = util.getCurrentSystemDate();
        
        Boolean submitNextJob = False;
        Integer batchNumber =null;
        Set<Id> loanIds = new Set<Id>();
        
        try{
            String query = '';
            if(contractNames!=null && contractNames.size() > 0){
                String contractNamesStr = '';
                for (String contractName : contractNames) {
                    contractNamesStr = contractNamesStr + '\'' + String.escapeSingleQuotes(contractName) + '\'' + ',';
                }
                contractNamesStr = contractNamesStr.substring(0, contractNamesStr.length() - 1); 
                
                query = loan.ProcessJobQueryUtil4.getInterestPostingAmzJobQuery(sodDate, batchNumber);
                String finalQuery = query + ' and Name IN ('+contractNamesStr+')';
                System.debug(logginglevel.error, 'finalQuery' +finalQuery);
                List<loan__Loan_Account__c> loanContractList = [SELECT Id,Name FROM loan__Loan_Account__c WHERE Name IN: contractNames];
                if(loanContractList != null && loanContractList.Size()>0){
                    for(loan__Loan_Account__c loan:loanContractList){
                        loanIds.add(loan.Id);
                    } 
                }
                
                //invoke managed job
                loan.InterestPostingAmzJob i = new loan.InterestPostingAmzJob(finalquery, sodDate, submitNextJob,loanIDs);
                Id jobId=database.executeBatch(i,1);
                
                //sleep
                //CLS_GenerateBillHandler.sleep(10000);
                
                AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                                  TotalJobItems, CreatedBy.Email, ExtendedStatus
                                  from AsyncApexJob where Id =: jobId];
                
                if(a.Status == 'Completed'){
                    return 'Completed';
                }else if(a.Status == 'Aborted' || a.Status == 'Failed'){
                    return 'Failed';
                }
            }
        }catch(Exception e){
            System.debug(logginglevel.ERROR,'IPT Generation Failed.');
            loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
            batch.loan__Log_Level__c = 'ERROR';
            batch.loan__Message__c = 'IPT Generation :: :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
            batch.loan__Batch_Id__c = 'CLS_GenerateIPTHandler';
            insert batch;
        }
        return 'Processing';
        
    }
    
    /*public static void sleep(Long milliSeconds){
        Long timeDiff = 0;
        DateTime firstTime = System.now();
        do{
            timeDiff = System.now().getTime() - firstTime.getTime();
        }
        while(timeDiff <= milliSeconds);
    }*/
}