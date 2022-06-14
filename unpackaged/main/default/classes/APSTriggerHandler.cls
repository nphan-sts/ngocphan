/*  This handler called from CustomAutomatedPaymentSetupTrigger to fire a vaidation to the user when Payment mode is not same as Investor Account on Contract
*  /* ****************Modification History*****************************************************************

* Created by      Date            JIRA ticket number
* Mohan Kiran   06/07/2022           LSP-473

******************Modification History*****************************************************************
******************************************************************************/
public class APSTriggerHandler {
    
    List<loan__Automated_Payment_Setup__c> apsRecord = new List<loan__Automated_Payment_Setup__c>();
    List<id> clContractId = new list<id>();
    //Calling Helper Class
    APSValidationHelper validator = new APSValidationHelper();
    
    // Before Insert method
    public void beforeInsert(List<loan__Automated_Payment_Setup__c> apsRecordFromTrg){
        for(loan__Automated_Payment_Setup__c newAPS : apsRecordFromTrg){
            clContractId.add(newAPS.loan__CL_Contract__c);
        }
        //validate paymentmode and recurring APS validation in case of before insert
        validator.paymentmodeValidator(clContractId,apsRecordFromTrg);
        validator.recurringAPSValidator(clContractId,apsRecordFromTrg);
    }
    	//validate payment mode incase of before update
    public void beforeUpdate(List<loan__Automated_Payment_Setup__c> apsRecordFromTrg){
        for(loan__Automated_Payment_Setup__c newAPS : apsRecordFromTrg){
            clContractId.add(newAPS.loan__CL_Contract__c);
        }
        validator.paymentmodeValidator(clContractId,apsRecordFromTrg);
    }   
}