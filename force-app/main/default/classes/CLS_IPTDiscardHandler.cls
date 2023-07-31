public class CLS_IPTDiscardHandler {
    
    loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
    public loan__Loan_Account__c loanAcctoUpdate;
    
    public CLS_IPTDiscardHandler(loan__Loan_Account__c loan){
        try{
            this.loanAcctoUpdate = loan;
            loanAcctoUpdate.loan__Next_Interest_Posting_Date__c = loanAcctoUpdate.loan__Accrual_Start_Date__c;
            loanAcctoUpdate.loan__Principal_Posted__c = 0;
            loanAcctoUpdate.loan__Next_Installment_Date__c = loanAcctoUpdate.loan__Expected_Repayment_Start_Date__c;
            loanAcctoUpdate.loan__Interest_Posted__c = 0;
            loanAcctoUpdate.loan__Last_Interest_Posting_Date__c = null;
            update loanAcctoUpdate;
            //discard IPT
            discardIPT();
        }catch(exception e){
            System.debug('ERROR:'+e.getLineNumber()+'---'+e.getMessage());
            batch.loan__Log_Level__c = 'ERROR';
            batch.loan__Message__c = 'ERROR at:'+e.getLineNumber()+'--'+e.getMessage();
            batch.loan__Batch_Id__c = 'IPTDiscardHandler';
            insert batch;
        }
        
    }
    
    public void discardIPT(){
        
        List<loan__Interest_Posting_Transaction__c> iptList = [SELECT Id,Name,loan__Discarded__c FROM loan__Interest_Posting_Transaction__c
                                                               WHERE loan__Loan_Contract__c=:loanAcctoUpdate.Id AND loan__Discarded__c = false];
        
        List<loan__Interest_Posting_Transaction__c> iptListToDiscard = new List<loan__Interest_Posting_Transaction__c>();
        if(iptList.Size()>0 && iptList != null){
            for(loan__Interest_Posting_Transaction__c ipt:iptList){
                ipt.loan__Discarded__c = true;
                iptListToDiscard.add(ipt);
            }
            
            if(iptListToDiscard != null && iptListToDiscard.Size()>0){
                update iptListToDiscard;
            }
        }  
    }
}