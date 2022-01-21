/*
 * author: Anusha
 * This is handler class for CorrectLastBilledAmountBatch(for LSP-284)
 * 
 *****************Modification History*****************************************************************
 * 
 ******************Modification History*****************************************************************/
public class CorrectLastBilledAmountHandler {
    Set<String> lastPaymentDue;
    Set<String> neitherFirstNorLastPaymentDue;
    Set<String> firstPaymentDue;
    List<loan__loan_account__c> loanToUpdate = new List<loan__loan_account__c>();
    private String fromDate;
    private String toDate;
    
    public CorrectLastBilledAmountHandler(String fromDate, String toDate){
        this.fromDate = fromDate;
        this.toDate = toDate;
    }
    
    public void process(List<loan__loan_account__c> loanList,Set<String> lastPaymentDue,Set<String> neitherFirstNorLastPaymentDue,Set<String> firstPaymentDue){
        for(loan__loan_account__c la:loanList){
            if(la.loan__Last_Billed_Amount__c != null && la.loan__next_installment_date__c == la.loan__Maturity_Date_Current__c  && la.loan__Last_Billed_Amount__c != la.loan__Pmt_Amt_Cur__c){//loans for which last payment is due
                la.loan__Last_Billed_Amount__c = la.loan__Pmt_Amt_Cur__c;
                loanToUpdate.add(la);
                lastPaymentDue.add(la.Name);
            }else if(la.loan__Last_Billed_Amount__c != null && la.loan__next_installment_date__c != la.loan__Maturity_Date_Current__c && la.loan__Last_Billed_Amount__c != la.loan__Pmt_Amt_Cur__c){//loans for which neither first not last payment is due
                la.loan__Last_Billed_Amount__c = la.loan__Pmt_Amt_Cur__c;
                loanToUpdate.add(la);
                neitherFirstNorLastPaymentDue.add(la.Name);
            }else if(la.loan__Last_Billed_Amount__c == null){//loans for which first payment is due
                la.loan__Last_Billed_Amount__c = la.loan__Payment_Amount__c;
                loanToUpdate.add(la);
                firstPaymentDue.add(la.Name);
            }
        }
        System.debug('Number of loans for which last payment is due : '+lastPaymentDue.size());
        System.debug('Number of loans for which neither first not last payment is due : '+neitherFirstNorLastPaymentDue.size());
        System.debug('Number of loans for which first payment is due : '+firstPaymentDue.size());
        
        if(loanToUpdate.size() > 0){
            System.debug('Number of loans getting updated : '+loanToUpdate.size());
            try{
               update loanToUpdate; 
            }catch(Exception e){
                loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
                 batch.loan__Log_Level__c = 'ERROR';
                 batch.loan__Message__c = 'Loans failed to update:: '+loanToUpdate+' ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString();
                 batch.loan__Batch_Id__c = 'CorrectLastBilledAmountBatch';
                 insert batch;
            }
        }
    }
}