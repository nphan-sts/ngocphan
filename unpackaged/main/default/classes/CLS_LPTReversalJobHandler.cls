public class CLS_LPTReversalJobHandler {
    
    loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
    public static loan__Loan_Account__c loan;
    
    
    public CLS_LPTReversalJobHandler(loan__Loan_Account__c loan){
        System.debug('Loan:'+loan);
        loan = loan;
        
        List<loan__Other_Transaction__c> listOtherTxn = loan.loan__Other_Loan_Transactions__r;
        if(listOtherTxn.Size()>0 && listOtherTxn != null){
            batch.loan__Log_Level__c = 'ERROR';
            batch.loan__Message__c = 'Loan Contract has Other Transactions';
            batch.loan__Batch_Id__c = 'LPTReversalJobHandler';
            insert batch;
        }else{
            System.debug('Loan:'+loan);
            CLS_LPTReversalJobHandler.LPTReversal(loan);
        }
    }
    
    public static void LPTReversal(loan__Loan_Account__c loan){
        
        try{
            system.debug('Loan:'+loan.Id);
            List<loan__Loan_Payment_Transaction__c> LPTListtoBeReversed = [Select Id,Name,loan__Transaction_Date__c,Custom_Reverse__c
                                                                           FROM loan__Loan_Payment_Transaction__c 
                                                                           WHERE loan__Loan_Account__c =: loan.Id 
                                                                           AND loan__Reversed__c = false 
                                                                           AND Custom_Reverse__c = false
                                                                           AND loan__Rejected__c = false
                                                                           AND loan__Cleared__c = true ORDER BY loan__Transaction_Date__c DESC];
            System.debug('LPT List:'+LPTListtoBeReversed);
            List<loan__Loan_Payment_Transaction__c> lptTOBeUpdate = new List<loan__Loan_Payment_Transaction__c>();
            List<loan__Repayment_Transaction_Adjustment__c> reversalsToBeInserted = new List<loan__Repayment_Transaction_Adjustment__c>();
            
            //inserting repayment txn
            for(loan__Loan_Payment_Transaction__c lpt : LPTListtoBeReversed){
                //custom reverse flag
                lpt.Custom_Reverse__c = true;
                lptTOBeUpdate.add(lpt);
                
                loan__Repayment_Transaction_Adjustment__c reversalTxn  = new loan__Repayment_Transaction_Adjustment__c();
                reversalTxn.loan__Loan_Payment_Transaction__c = lpt.id;
                reversalTxn.loan__Adjustment_Txn_Date__c = date.today();
                reversalTxn.loan__Reason_Code__c = 'Human Error'; //has to be updated by the client
                reversalTxn.loan__Reference__c = 'UpdatedByScript'; //has to be updated by the client
                //reversalsToBeInserted.add(reversalTxn);
                System.debug('reversalsToBeInserted:'+reversalTxn);
                insert reversalTxn;
            }
            if(lptTOBeUpdate != null && lptTOBeUpdate.size() > 0){ 
                System.debug('lptTOBeUpdate:'+lptTOBeUpdate);
                update lptTOBeUpdate;
            }

            
        }catch(exception e){
            loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
            System.debug('ERROR: '+e.getLineNumber()+'---'+e.getMessage());
            batch.loan__Log_Level__c = 'ERROR';
            batch.loan__Message__c = 'ERROR at:'+e.getLineNumber()+'--'+e.getMessage();
            batch.loan__Batch_Id__c = 'LPTReversalJobHandler';
            insert batch;
        }
    }
    
    
}