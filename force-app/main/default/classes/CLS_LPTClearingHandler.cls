public class CLS_LPTClearingHandler {
    
    public CLS_LPTClearingHandler(List<String> loanContract){
        
        List<loan__Loan_Account__c> loanAccList = [SELECT Id,Name FROM loan__Loan_Account__c WHERE Name IN: loanContract];
        for(loan__Loan_Account__c loan:loanAccList){
            Id batchId = Database.executeBatch(new CLS_LPTClearingJob(loan.Id), 1);
        }
    }
}