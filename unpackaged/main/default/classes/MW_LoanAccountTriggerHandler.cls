public class MW_LoanAccountTriggerHandler {
    
    public static void updatePlacedStatusFields(List<loan__Loan_Account__c> newList, map<Id,loan__Loan_Account__c> oldMap){
        try{
            Timezone tz = Timezone.getTimeZone('America/Los_Angeles');
            
            for(loan__Loan_Account__c newLoan : newList){
                loan__Loan_Account__c oldLoan = oldMap.get(newLoan.Id);
                if(oldLoan.Placement_Status__c == null && oldLoan.Placement_Status__c != newLoan.Placement_Status__c){
                    newLoan.Placement_Status_StartDate__c = newLoan.Placement_Status__c + '  ' + DateTime.newInstance(System.Now().getTime() + tz.getOffset(System.Now()));
                }else if(oldLoan.Placement_Status__c != null && oldLoan.Placement_Status__c != newLoan.Placement_Status__c){
                    newLoan.Placement_Status_StartDate__c = newLoan.Placement_Status__c + '  ' + DateTime.newInstance(System.Now().getTime() + tz.getOffset(System.Now()));
                    newLoan.Placement_Status_EndDate__c = oldLoan.Placement_Status__c + '  ' + DateTime.newInstance(System.Now().getTime() + tz.getOffset(System.Now()));
                }
            }
        }catch(Exception exe){
            MW_LogUtility.error('MW_LoanAccountTriggerHandler', '', '', 'updatePlacedStatusFields', exe);
        }
    }
}