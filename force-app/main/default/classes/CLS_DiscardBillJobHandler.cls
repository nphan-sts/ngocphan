public class CLS_DiscardBillJobHandler{
    
    public loan__Loan_Account__c loanToUpdate;
    loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
    
    public CLS_DiscardBillJobHandler(loan__Loan_Account__c loan){
        try{
            this.loanToUpdate = loan;
            //invoke discard Bill
            discardBill();
            //update IPT created
            updateIPT();
            //update Loan Account
            updateLoanAccount();
        }catch(Exception e){
            System.debug(logginglevel.ERROR,'Bill Discard failed for :'+loan.Name);
            batch.loan__Log_Level__c = 'ERROR';
            batch.loan__Message__c = 'Discard Bill ::'+ loan.Name + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
            batch.loan__Batch_Id__c = 'CLS_DiscardBillJob';
            insert batch;
        }
        
    }
    
    public void discardBill(){
        
        List<loan__Loan_account_Due_Details__c> billList = [SELECT Id,Name,loan__DD_Primary_Flag__c,loan__Transaction_Date__c 
                                                            FROM loan__Loan_account_Due_Details__c 
                                                            WHERE loan__Loan_Account__c=:loanToUpdate.Id ORDER BY loan__Transaction_Date__c DESC];
        
        List<loan__Loan_account_Due_Details__c> billListToDiscard = new List<loan__Loan_account_Due_Details__c>();
        if(billList.size() > 0 && billList != null){
            for(loan__Loan_account_Due_Details__c bill:billList){
                bill.loan__DD_Primary_Flag__c = false;
                billListToDiscard.add(bill);
            }
            
            if(billListToDiscard != null && billListToDiscard.size() > 0){
                update billListToDiscard;
            } 
        }
    }
    
    public void updateIPT(){
        List<loan__Interest_Posting_Transaction__c> iptList = [SELECT Id,Name,loan__Discarded__c,loan__Is_Posted__c,loan__Is_Billed__c,loan__Transaction_Creation_Date__c,loan__Last_Accrual_Date__c,
                                                               loan__Transaction_Due_Date__c,loan__Status__c
                                                               FROM loan__Interest_Posting_Transaction__c
                                                               WHERE loan__Loan_Contract__c=:loanToUpdate.Id AND loan__Discarded__c=false
                                                               AND loan__Status__c=:'Closed'];
        
        if(iptList.size() > 0 && iptList != null){
            List<loan__Interest_Posting_Transaction__c> iptListToUpdate = new List<loan__Interest_Posting_Transaction__c>();
            for(loan__Interest_Posting_Transaction__c ipt:iptList){
                ipt.loan__Is_Posted__c = true;
                ipt.loan__Is_Billed__c = true;
                ipt.loan__Transaction_Creation_Date__c = Date.newInstance(ipt.loan__Transaction_Due_Date__c.year(), ipt.loan__Transaction_Due_Date__c.month()-1, ipt.loan__Transaction_Due_Date__c.day());
                ipt.loan__Last_Accrual_Date__c = ipt.loan__Transaction_Creation_Date__c;
                iptListToUpdate.add(ipt);
            }
            
            if(iptListToUpdate != null && iptListToUpdate.Size() > 0){
                update iptListToUpdate;
            }
        } 
        
    }
    
    public void updateLoanAccount(){
        
        List<AggregateResult> res= [SELECT SUM(loan__Interest_Posted__c),SUM(loan__Principal_Posted__c)
                                    FROM loan__Interest_Posting_Transaction__c
                                    WHERE loan__Loan_Contract__c=:loanToUpdate.Id AND loan__Discarded__c=false AND loan__Status__c='Closed'];
        if(res != null && res.Size()>0){
            loanToUpdate.loan__Previous_Installment_Date__c = null;
            loanToUpdate.loan__Next_Installment_Date__c = loanToUpdate.loan__First_Installment_Date__c;
            loanToUpdate.loan__Interest_Posted__c = (Double)res[0].get('expr0');
            loanToUpdate.loan__Principal_Posted__c = (Double)res[0].get('expr1');
            loanToUpdate.loan__Interest_Remaining__c = (Double)res[0].get('expr0');//new
            loanToUpdate.loan__Last_Accrual_Date__c = loanToUpdate.loan__Accrual_Start_Date__c;//new
            update loanToUpdate;
        }
    }
}