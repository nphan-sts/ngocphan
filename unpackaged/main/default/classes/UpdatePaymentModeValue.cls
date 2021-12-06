/******************************Modification History***********************
 * Modified by		Date			Jira
 * Anusha			22/10/2021		LSP-379 Closure tolerance LPT's  payment mode set to ACH - CLS case #02892604
 * 
 * ***********************************************************************/
Public class UpdatePaymentModeValue
{	
    @testVisible
    private static boolean usedOnlyForTest = false;//used only for test coverage
    @InvocableMethod
    Public static void PaymentModeVal(List<Id> LptId)
    {   
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
                if(Test.isRunningTest() && usedOnlyForTest == true){//added for test coverage - start
                	Integer testException = 10/0;
            	}//added for test coverage
               	Update updatelptList;
            }
        }catch(Exception e){
            System.debug('Error updating payment mode on closure tolerance payments: '+updatelptList);
            loan__Batch_Process_Log__c errorMsg = new loan__Batch_Process_Log__c();
            errorMsg.loan__Log_Level__c = 'Error';
            errorMsg.loan__Message__c = 'Error updating payment mode on closure tolerance payments: '+updatelptList;
            errorMsg.loan__Batch_Id__c = 'UpdatePaymentModeValue';
            errorMsg.loan__Origin__c = 'UpdatePaymentModeValue';
            insert errorMsg;
        }
    }
}