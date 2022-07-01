/* ****************Modification History******************
 * Last Modified by     Date          JIRA number
 * 1. Shakul         2022/04/18     LSP-693 (Logic to Compute Interest Remaining Total)
 ******************Modification History******************/
trigger MW_LoanAccountTrigger on loan__Loan_Account__c (before update) {
    //START:LSP-693 (Adding all the active statuses to a set)
    Set<String> statusSet = new Set<String>();
    statusSet.add('Active - Good Standing');
    statusSet.add('Active - Bad Standing');
    statusSet.add('Active - Matured');
    statusSet.add('Active - Marked for Closure');
    //END:LSP-693 (Adding all the active statuses to a set)
    if (!loan.CustomSettingsUtil.getOrgParameters().loan__Disable_Triggers__c) {
        set<id> AppId = new set<id>();
        if (Trigger.isUpdate){
            for(loan__Loan_Account__c newLoanAcc :Trigger.New){
                
                loan__Loan_Account__c oldLoanAcc = Trigger.oldMap.get(newLoanAcc.id);
                system.debug('newLoanAcc.Application__c------->' + newLoanAcc.Application__c);
                if(oldLoanAcc.loan__Loan_Status__c  != newLoanAcc.loan__Loan_Status__c && newLoanAcc.loan__Loan_Status__c == 'Closed - obligations met'&&
                   newLoanAcc.Application__c != null)
                    AppId.add(newLoanAcc.Application__c);
                //START:LSP-693 (Logic to Compute Interest Remaining Total)
                if(newLoanAcc.loan__Product_Type__c == 'Flexible Amz Loan' && newLoanAcc.loan__Draw_Billing_Method__c == 'Interest Only' && statusSet.contains(newLoanAcc.loan__Loan_Status__c)){
                    if(newLoanAcc.loan__Last_Accrual_Date__c != null && oldLoanAcc.loan__Last_Accrual_Date__c != null && 
                       newLoanAcc.loan__Last_Accrual_Date__c != oldLoanAcc.loan__Last_Accrual_Date__c){
                           if(newLoanAcc.loan__Interest_Remaining__c != null && oldLoanAcc.loan__Interest_Remaining__c != null &&
                              oldLoanAcc.loan__Interest_Accrued_Not_Due__c != null && 
                              newLoanAcc.loan__Interest_Remaining__c != oldLoanAcc.loan__Interest_Remaining__c){
                                  if(oldLoanAcc.loan__Interest_Remaining__c == 0){
                                      newLoanAcc.Interest_Remaining_Total__c = oldLoanAcc.loan__Interest_Accrued_Not_Due__c;
                                  }
                                  else if(oldLoanAcc.loan__Interest_Remaining__c > 0 && newLoanAcc.Interest_Remaining_Total__c != null){
                                      newLoanAcc.Interest_Remaining_Total__c += oldLoanAcc.loan__Interest_Accrued_Not_Due__c;
                                  }
                              }
                       }
                    else{
                        if(newLoanAcc.loan__Interest_Remaining__c != null && oldLoanAcc.loan__Interest_Remaining__c != null &&
                           newLoanAcc.loan__Interest_Remaining__c != oldLoanAcc.loan__Interest_Remaining__c){
                               if(newLoanAcc.loan__Interest_Remaining__c == 0){
                                   newLoanAcc.Interest_Remaining_Total__c = 0;
                               }
                               else if(newLoanAcc.loan__Interest_Remaining__c > 0){
                                   newLoanAcc.Interest_Remaining_Total__c =  newLoanAcc.loan__Interest_Remaining__c;
                               }
                           }
                    }
                }
                //END:LSP-693 (Logic to Compute Interest Remaining Total)
            }
            system.debug('AppId------>'+AppId);
            set<id>BankAccountId = new set<id>();
            list<genesis__applications__c> apps = [select id, name, bank_account__c from genesis__applications__c where ID IN :AppId];
            
            for(genesis__applications__c app:apps){
                BankAccountId.add(app.bank_account__c);
            }
            
            List<loan__Bank_Account__c> BankAccId = [select id, name, loan__Active__c from loan__Bank_Account__c where Id IN :BankAccountId];
            for(loan__Bank_Account__c ba:BankAccId){
                ba.loan__Active__c = false;
            }
            update BankAccId;
        }
    }
}