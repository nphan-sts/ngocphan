/*  This Helper called from APSTriggerHandler to fire a vaidation to the user when Payment mode is not same as Investor Account on Contract
*  /* ****************Modification History*****************************************************************

* Created by      Date            JIRA ticket number
* Mohan Kiran   06/07/2022           LSP-473

******************Modification History*****************************************************************
******************************************************************************/
public with sharing class APSValidationHelper {
    
    //Declaring variables 
    Map<id,loan__Automated_Payment_Setup__c> apsIdMap = new Map<id,loan__Automated_Payment_Setup__c> ();
    Map<id,String> contractIOMap = new Map<id,String>();
    List<loan__Investor_Loan__c> investorLoanList = new List< loan__Investor_Loan__c>();
    Map<String,String> oldType = new Map<String,String>();
    List<loan__Automated_Payment_Setup__c> APS;
    String APS_PM_VALIDATION_ERROR = Label.APSPMVaidationError;
    String APS_RP_VALIDATION_ERROR = Label.APSReccuringValidationError ;
    String paymentMode;
    String accountInvestorCode;
    
    // Method to recieve payment mode, loan account and APS records in trigger.new
    
    public void paymentmodeValidator(List<id> loanRecordId, List<loan__Automated_Payment_Setup__c> apsList ){
        try{
            //Map of Aps Ids and APS object
            for(loan__Automated_Payment_Setup__c aps:apsList){
                apsIdMap.put(aps.id,aps);
            }
            investorLoanList = [SELECT id,
                                loan__Loan__c,
                                loan__Account__c,
                                loan__Status__c,
                                loan__Account__r.Investor_Code__c FROM
                                loan__Investor_Loan__c WHERE
                                loan__Loan__c IN: loanRecordId AND 
                                loan__Status__c = 'Active'];
            
            //ContractIO map is a map of Investment order record and related account's investor code
            for(loan__Investor_Loan__c invLoan:investorLoanList){
                contractIOMap.put(invLoan.loan__Loan__c,invLoan.loan__Account__r.Investor_Code__c);
            }
            
            for(loan__Automated_Payment_Setup__c apsValidation:apsList){
                paymentMode = apsIdMap.get(apsValidation.id).Payment_Mode_Trimmed__c;
                accountInvestorCode = contractIOMap.get(apsIdMap.get(apsValidation.id).loan__CL_Contract__C);
                
                if((paymentMode!= 'Cash'&& paymentMode!= 'Debit Card' && paymentMode!= null) && !paymentMode.equalsIgnoreCase(accountInvestorCode)) 
                {
                    apsValidation.addError(APS_PM_VALIDATION_ERROR);  
                }

            }
            
        } //end try block
        
        catch(Exception e){
            System.debug('An Exception occured : '+e.getStackTraceString());
            throw new apsException(' The record couldnt be saved. An exception occured: '+e.getMessage());
        }
    }
    // existing code moved from trigger to helper
    
    public void recurringAPSValidator(list<id> loanRecordfromTrg, List<loan__Automated_Payment_Setup__c> apsRecordFromTrg){
        try{
            aps = [Select id,loan__CL_Contract__r.id,loan__Type__c,loan__Active__c from loan__Automated_Payment_Setup__c where loan__CL_Contract__c IN:loanRecordfromTrg
                   and loan__Type__c = 'Recurring' and loan__Active__c = true LIMIT 1];
            
            for(loan__Automated_Payment_Setup__c temp : APS){
                oldType.put(String.valueOf(temp.loan__CL_Contract__r.id),temp.loan__Type__c);
            }
            
            if(oldType.size() > 0){
                for(loan__Automated_Payment_Setup__c newAPS : apsRecordFromTrg){
                    if(oldType.containsKey(String.valueOf(newAPS.loan__CL_Contract__c)) && newAPS.loan__Type__c.equalsIgnoreCase('Recurring'))
                        newAPS.addError(APS_RP_VALIDATION_ERROR);  
                }
            }
        } // End of Try block
        catch(Exception e){ //Catch block
            System.debug('An Exception occured : '+e.getStackTraceString());
            throw new apsException(' The record couldnt be saved. An exception occured: '+e.getMessage());
        }
    }
    
}