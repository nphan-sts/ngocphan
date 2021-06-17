Public class UpdatePaymentModeValue
{
    @InvocableMethod
    Public static void PaymentModeVal(List<Id> LptId)
    {   
        Id paymentId = LptId[0];
        loan__Payment_Mode__c pm =new loan__Payment_Mode__c();
        pm = [Select Id,Name from loan__Payment_Mode__c where Name = 'Waived' Limit 1];       
        loan__Loan_Payment_Transaction__c lpt = new loan__Loan_Payment_Transaction__c(id = paymentId);
        lpt.loan__Payment_Mode__c = pm.Id;
        
        Update lpt;
        
    }
}