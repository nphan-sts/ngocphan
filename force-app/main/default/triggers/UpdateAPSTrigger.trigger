/* ****************Modification History*****************************************************************
 * 
 * Modified by              Date        JIRA number
 * 1. Pallavi/Neha        2020/12/11  CRM-1056 CPD issue/Reverting issue (short-term fix) - Case #02430069 
 * 2. Venkat              2021/03/10  LOP-151 or PS-11367
 * 3. Anusha              2021/04/12  LSP-124 Update the logic in UpdateAPSTrigger to avoid duplicate LPT creation - Case# 02596077
 ******************Modification History*****************************************************************/
trigger UpdateAPSTrigger on loan__Other_Transaction__c (after insert, after update) {
    //added disable trigger condition check - CRM-437
    if (!loan.CustomSettingsUtil.getOrgParameters().loan__Disable_Triggers__c) {
    if(trigger.isInsert && trigger.isAfter) {
        Set<Id> loanId = new Set<Id>();
        Set<Date> repaymentStartDates = new Set<Date>();//LSP-124
        list<loan__Other_Transaction__c> otherTxn = [select id,name,loan__old_due_day__c,loan__repayment_start_date__c,
                                                            loan__due_date__c,loan__new_due_day__c,
                                                            loan__loan_account__r.loan__next_installment_date__c
                                                     from loan__Other_Transaction__c
                                                     where id in:trigger.new and loan__Transaction_Type__c = 'Reschedule'];
        if(otherTxn != null && otherTxn.size()>0 ) {
            Map<Id,loan__Other_Transaction__c> otherTxnMap = new Map<Id,loan__Other_Transaction__c>();
            
            for(loan__Other_Transaction__c other:otherTxn) {
                otherTxnMap.put(other.loan__loan_account__c,other);
                loanId.add(other.loan__loan_account__c);
                repaymentStartDates.add(other.loan__repayment_start_date__c);//LSP-124
            }
            
            /*Map<Id,loan__loan_account__c> loanMap = new Map<Id,loan__loan_account__c>([select id,name,loan__next_installment_date__c,
                                                                                           (select id, name ,loan__due_date__c,loan__loan_account__c 
                                                                                            from loan__repayment_schedule__r 
                                                                                            where loan__Is_Archived__c = false order by loan__due_date__c)
                                                                                       from loan__loan_account__c
                                                                                       where id in:loanId]);*/
            list<loan__automated_payment_setup__c> aps = [select id,name,loan__CL_Contract__c,loan__Payment_Mode__c  from loan__automated_payment_setup__c 
                                                          where loan__CL_Contract__c in:loanId and loan__Type__c='RECURRING' and loan__active__c =true];//LSP-124 added loan__Payment_Mode__c in the query
            list<loan__automated_payment_setup__c> updatedAps = new list<loan__automated_payment_setup__c>();

            //LSP-124 start
            Map<Id, loan__Loan_Payment_Transaction__c> loanLptMap = new Map<Id,loan__Loan_Payment_Transaction__c>();
            Set<Id> paymentModes = new Set<Id>();
            for(loan__automated_payment_setup__c ap : aps) {
                paymentModes.add(ap.loan__Payment_Mode__c);        
            }

            List<loan__loan_payment_transaction__c> lpts = [select id, name, loan__Transaction_Date__c,
                                                            loan__loan_account__c,
                                                            loan__Payment_Mode__c,
                                                            loan__Automated_Payment_Setup__c
                                                            FROM loan__loan_payment_transaction__c
                                                            WHERE loan__Transaction_Date__c in:repaymentStartDates
                                                            AND loan__Payment_Mode__c in:paymentModes
                                                            AND loan__Loan_Account__c in:loanId];
            for(loan__loan_payment_transaction__c lpt:lpts){
                loanLptMap.put(lpt.loan__loan_account__c, lpt);
            }
            //LSP-124 end                                                          
                                                                        
            for(loan__automated_payment_setup__c ap : aps) {
                //LSP-124 start
                Id contractId = ap.loan__CL_Contract__c;
                loan__loan_payment_transaction__c paymentTxn = loanLptMap.get(contractId);
                Date repaymentStartDate = otherTxnMap.get(ap.loan__CL_Contract__c).loan__repayment_start_date__c;
                //check if lpt exists for the combination of repaymentStartDate and paymentMode on APS for any contract,if it doesn't, only then update debit date on APS
                if(paymentTxn == null 
                    || (paymentTxn != null && !(repaymentStartDate == paymentTxn.loan__transaction_date__c
                        && ap.loan__payment_mode__c == paymentTxn.loan__Payment_Mode__c && paymentTxn.loan__Automated_Payment_Setup__c == ap.Id))){ //LSP-124 end
                    ap.loan__Debit_Date__c = otherTxnMap.get(ap.loan__CL_Contract__c).loan__repayment_start_date__c;
                    ap.loan__Debit_Day__c = ap.loan__Debit_Date__c.day();   //CRM-1056
                    updatedAps.add(ap);
                }
            }
            
            if(updatedAps.size()>0) {
                try {
                    update updatedAps;
                    System.debug('Updated list of APS: '+updatedAps);
                } catch (Exception e) {
                    loan__batch_process_log__c logs = new loan__batch_process_log__c();
                    logs.loan__Origin__c = 'Exception';
                    logs.loan__Message__c = 'Error occured in APS Update Trigger at line number '+e.getLineNumber()+' because of error :'+e.getMessage();
                    logs.loan__Date__c = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
                    insert logs;
                }
            }
        }

    } 
    //Changes related to LOP-151 or PS-11367, starts here
        if(trigger.isAfter && trigger.isUpdate){
        
         if(!UpdateAPSTriggerHandler.isRecursive){
             UpdateAPSTriggerHandler.isRecursive = true;
             
             //added below handler call as part of LOP-151 or PS-11367
             UpdateAPSTriggerHandler handler = new  UpdateAPSTriggerHandler();        
             handler.getTransactions(Trigger.new);
          
        }
     }
     //Changes related to LOP-151 or PS-11367, ends here
   }
}