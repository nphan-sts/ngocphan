global class PaymentReversalsBatch implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = 'SELECT Id, loan__Loan_Account__r.Name FROM loan__Loan_Payment_Transaction__c WHERE loan__Transaction_Date__c = 2022-10-28 AND loan__Cleared__c = TRUE AND loan__Reversed__c = FALSE AND loan__Payment_Mode__r.Name != \'Waived\' AND loan__Loan_Account__r.Name NOT IN ( \'LAI-00574687\', \'LAI-00577525\', \'LAI-00079976\', \'LAI-00341021\', \'LAI-00011633\', \'LAI-00553408\', \'LAI-00081184\', \'LAI-00599905\', \'LAI-00539758\', \'LAI-00545713\', \'LAI-00129498\', \'LAI-00096446\', \'LAI-00607800\', \'LAI-00621275\' )' ;       
        System.debug(logginglevel.error,'query'+query);
        return Database.getQueryLocator(query);
        
    } 
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
            
            System.debug(logginglevel.error,'----Method execute(+)scope----'+ scope);
            List<loan__Loan_Payment_Transaction__c> records = (List<loan__Loan_Payment_Transaction__c>)scope;
            
            Set<Id> loanPaymentIds = new Set<Id>();
            for (loan__Loan_Payment_Transaction__c lpt : records) {
                loanPaymentIds.add(lpt.Id);
            }
            
            loan.LoanActionFactory factory = new loan.LoanActionFactory();
            loan.LoanAction2 loanAction = factory.getLoanAction2API();
            loanAction.reverseLoanPayment(loanPaymentIds,'other',' No Nacha');
        }
    
    global void finish(Database.BatchableContext bc){

        System.debug(LoggingLevel.INFO, 'Successful completion of job');
    }
}