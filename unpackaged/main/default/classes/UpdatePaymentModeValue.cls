/******************************Modification History***********************
 * Modified by		Date			Jira
 * Anusha			22/10/2021		LSP-379 Closure tolerance LPT's  payment mode set to ACH - CLS case #02892604
 * 
 * ***********************************************************************/
Public class UpdatePaymentModeValue
{
    @InvocableMethod
    Public static void PaymentModeVal(List<Id> LptId)
    {   
        /*Id paymentId = LptId[0];
        loan__Payment_Mode__c pm =new loan__Payment_Mode__c();
        pm = [Select Id,Name from loan__Payment_Mode__c where Name = 'Waived' Limit 1];       
        loan__Loan_Payment_Transaction__c lpt = new loan__Loan_Payment_Transaction__c(id = paymentId);
        lpt.loan__Payment_Mode__c = pm.Id;
        
        Update lpt;*/ //commented as part of LSP-379
        List<loan__Loan_Payment_Transaction__c> lptList = [select id, name,
                                                           loan__Payment_Mode__c from
                                                           loan__Loan_Payment_Transaction__c
                                                           where id in:LptId];
        loan__Payment_Mode__c pm = [Select Id,Name from loan__Payment_Mode__c where Name = 'Waived' Limit 1]; 
        List<loan__Loan_Payment_Transaction__c> updatelptList = new List<loan__Loan_Payment_Transaction__c>();
        for(loan__Loan_Payment_Transaction__c pmt:lptList){
        	pmt.loan__Payment_Mode__c = pm.Id;            
            updatelptList.add(pmt);
		}
        try{
            if(!updatelptList.isEmpty()){
               Update updatelptList; 
            }
        }catch(Exception e){
            System.debug('Error updating payment mode on closure tolerance payments: '+updatelptList);
        }
    }
}