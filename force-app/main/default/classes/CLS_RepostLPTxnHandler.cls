public class CLS_RepostLPTxnHandler {
    
    loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
    public loan__Loan_Account__c loan;
    
    public CLS_RepostLPTxnHandler(loan__Loan_Account__c loanAcc){
        this.loan = loanAcc;
        repostLPT();
        //update loan after repost
        /*List<loan__Interest_Posting_Transaction__c> iptList = [SELECT Id,Name,loan__Discarded__c,loan__Transaction_Creation_Date__c FROM loan__Interest_Posting_Transaction__c
                                                               WHERE loan__Loan_Contract__c=:loan.Id AND loan__Discarded__c = false ORDER BY loan__Transaction_Creation_Date__c DESC];
        loan.loan__Last_Accrual_Date__c = iptList[0].loan__Transaction_Creation_Date__c;//loanAcc.loan__Accrual_Start_Date__c;
        update loan; *///new
    }
    
    public void repostLPT(){
        
        try{
            List<loan__Automated_Payment_Setup__c> aps = [SELECT Id,Name,loan__Debit_Date__c FROM loan__Automated_Payment_Setup__c 
                                                          WHERE loan__CL_Contract__c=:loan.Id AND loan__Active__c=true AND loan__Type__c='RECURRING' LIMIT 1];
            
            //update APS
            if(aps != null && aps.size()>0){
                aps[0].loan__Debit_Date__c = loan.loan__Next_Installment_Date__c;
                update aps;
            }
            
            
            
            List<loan__Loan_Payment_Transaction__c> LPTReversed = [Select Id,Name,loan__Transaction_Date__c,loan__Loan_Account__c,
                                                                   loan__Payment_Mode__c,loan__Payment_Application_Mode__c,loan__Installment_Payment__c,
                                                                   loan__Transaction_Time__c,loan__Transaction_Amount__c,loan__Balance__c,
                                                                   loan__Principal__c,loan__Interest__c,loan__Excess__c,loan__Fees__c,
                                                                   loan__Clearing_Date__c,loan__Cleared__c,loan__Receipt_Date__c,
                                                                   loan__Sent_To_ACH_On__c, loan__Automated_Payment_Setup__c 
                                                                   FROM loan__Loan_Payment_Transaction__c 
                                                                   WHERE loan__Loan_Account__c =: loan.Id 
                                                                   AND loan__Reversed__c = true 
                                                                   AND Custom_Reverse__c = true 
                                                                   ORDER BY loan__Transaction_Date__c ASC];
            
            List<loan__Loan_Payment_Transaction__c> repostLPTList = new List<loan__Loan_Payment_Transaction__c>();
            if(LPTReversed.size()>0 && LPTReversed != null){
                for(loan__Loan_Payment_Transaction__c lpt : LPTReversed){
                    System.debug('Transaction Date:'+lpt.loan__Transaction_Date__c);
                    loan__Loan_Payment_Transaction__c newLPT  = new loan__Loan_Payment_Transaction__c();
                    newLPT.loan__Loan_Account__c = lpt.loan__Loan_Account__c;
                    newLPT.loan__Payment_Mode__c = lpt.loan__Payment_Mode__c;
                    newLPT.loan__Payment_Application_Mode__c = lpt.loan__Payment_Application_Mode__c;
                    newLPT.loan__Transaction_Date__c = lpt.loan__Transaction_Date__c;
                    newLPT.loan__Transaction_Time__c = lpt.loan__Transaction_Time__c;
                    newLPT.loan__Transaction_Amount__c = lpt.loan__Transaction_Amount__c;
                    newLPT.loan__Installment_Payment__c = lpt.loan__Installment_Payment__c;
                    //newLPT.loan__Balance__c=lpt.loan__Balance__c;
                    //newLPT.loan__Principal__c = lpt.loan__Principal__c;
                    //newLPT.loan__Interest__c = lpt.loan__Interest__c;
                    //newLPT.loan__Excess__c = lpt.loan__Excess__c;
                    //newLPT.loan__Fees__c = lpt.loan__Fees__c;
                    newLPT.loan__Receipt_Date__c = lpt.loan__Receipt_Date__c;
                    newLPT.loan__Interest_Rate__c = loan.loan__Interest_Rate__c;//new
                    newLPT.loan__IOA__c = 0; // new
                    newLPT.loan__Automated_Payment_Setup__c = lpt.loan__Automated_Payment_Setup__c != null ? lpt.loan__Automated_Payment_Setup__c : NULL; // new
                    newLPT.loan__Sent_to_ACH__c = true;
                    newLPT.loan__Sent_To_ACH_On__c = lpt.loan__Sent_To_ACH_On__c;
                    //repostLPTList.add(newLPT);
                    System.debug('repost LPT:'+newLPT);
                    insert newLPT;
                }
            }
            
            /*if(repostLPTList != null && repostLPTList.size() > 0){ 
                System.debug('repostLPTList:'+repostLPTList);
                insert repostLPTList;
            }*/
            
        }catch(exception e){
            System.debug(logginglevel.ERROR,'Exception in reposting Loan Payment Transactions for :'+loan.Name);
            batch.loan__Log_Level__c = 'ERROR';
            batch.loan__Message__c = ' Rposting failed::'+ loan.Name + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
            batch.loan__Batch_Id__c = 'RepostLPTTxnHandler';
            insert batch;
        }
    }
}