/*  This handler called from CustomAutomatedPaymentSetupTrigger to fire a vaidation to the user when Payment mode is not same as Investor Account on Contract
*  /* ****************Modification History*****************************************************************

* Created by      Date            JIRA ticket number
* Mohan Kiran   06/07/2022           LSP-473

******************Modification History*****************************************************************
******************************************************************************/
public class APSTriggerHandler {
    
    List<loan__Automated_Payment_Setup__c> apsRecord;
    List<id> clContractId;
    //Helper Method
    APSValidationHelper validator = new APSValidationHelper();
    
        public void beforeInsert(list<id> loanRecordfromTrg, List<loan__Automated_Payment_Setup__c> apsRecordFromTrg){
        
        apsRecord = apsRecordFromTrg;
        clContractId = loanRecordfromTrg; 
        validator.paymentmodeValidator(clContractId,apsRecord);
        validator.recurringAPSValidator(clContractId,apsRecord);
        
    }
    
    public void beforeUpdate(list<id> loanRecordfromTrg, List<loan__Automated_Payment_Setup__c> apsRecordFromTrg){
        
        apsRecord = apsRecordFromTrg;
        clContractId = loanRecordfromTrg; 
        validator.paymentmodeValidator(clContractId,apsRecord);
    }
    

    
}