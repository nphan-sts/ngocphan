/* ****************Modification History*****************************************************************
 * 
 * Modified/created by     Date        JIRA number
 * 1. Venkat              2021/03/10   LOP-151 or PS-11367
 ******************Modification History*****************************************************************/

public class UpdateAPSTriggerHandler {
    
    public static Boolean isRecursive = false ;
    
    public void getTransactions(List<loan__Other_Transaction__c> transactionList)
    {   
        
        List<loan__Other_Transaction__c> chargeoffTrxns=[select id,name, loan__Charged_Off_Date__c, 
                                                         loan__Repayment_Start_Date__c,
                                                         loan__Txn_Date__c,
                                                         loan__Charged_Off_Interest__c,
                                                         loan__Charged_Off_Principal__c,
                                                         loan__Loan_Account__c      
                                                         from loan__Other_Transaction__c
                                                         where id IN:transactionList and loan__Transaction_Type__c = 'Charge Off'];
        
        
        if(chargeoffTrxns != null && chargeoffTrxns.size()>0 ) {
            System.debug('new chargeoff transactions ....'+ chargeoffTrxns);  
            
        List<loan__Other_Transaction__c> newTraxnsToUpdate = new List<loan__Other_Transaction__c>();
        List<loan__Loan_Account__c> loansToUpdate = new List<loan__Loan_Account__c>();
        Set<Id> contractIds= new Set<Id>();
        Map<Id,loan__Other_Transaction__c> lAandOldChargeoffTxn = new Map<Id,loan__Other_Transaction__c>();
        Map<Id,loan__Loan_Account__c> loanacountMap = new Map<Id,loan__Loan_Account__c>();     
            
            for(loan__Other_Transaction__c lOTranxs : chargeoffTrxns){
                contractIds.add(lOTranxs.loan__Loan_Account__c);
            }
            System.debug('loan accounts....'+ contractIds);
            
            
            List<loan__Loan_Account__c> contractList=[Select id, name, loan__Interest_Remaining__c, 
                                                      loan__Interest_Accrued_Not_Due__c,                                                      
                                                      loan__Interest_Posted__c,                                                      
                                                      loan__Charged_Off_Principal__c,
                                                      loan__Charged_Off_Date__c,
                                                      loan__Charged_Off_Interest__c,
                                                      loan__Principal_Remaining__c,
                                                      loan__last_accrual_date__c,
                                                      loan__interest_rate__c,
                                                      (select id, name, Createddate,
                                                       loan__Charged_Off_Principal__c,
                                                       loan__Charged_Off_Interest__c,
                                                       loan__Charged_Off_Date__c,
                                                       loan__Loan_Account__c 
                                                       from loan__Other_Loan_Transactions__r 
                                                       where loan__Transaction_Type__c='Charge Off' 
                                                       order by CreatedDate ASC LIMIT 1)
                                                      from loan__Loan_Account__c 
                                                      where Id IN : contractIds];  
            
            if(contractList!= null && contractList.size()>0 ) {                                                                             
                for(loan__Loan_Account__c writeOffLoan : contractList){
                    System.debug('writeoff loan ....'+ writeOffLoan );
                    loan__Other_Transaction__c oldWriteoffTrxn =  writeOffLoan.loan__Other_Loan_Transactions__r.get(0);
                    System.debug('old writeoff transaction ....'+ oldWriteoffTrxn );                           
                    lAandOldChargeoffTxn.put(writeOffLoan.id, oldWriteoffTrxn);                      
                    loanacountMap.put(writeOffLoan.id, writeOffLoan);
                }
            }
            
                        
            for(loan__Other_Transaction__c newchargeoffTrxn : chargeoffTrxns){
                Id contractId = newchargeoffTrxn.loan__Loan_Account__c;
                loan__Other_Transaction__c oldchargeofftrxn = lAandOldChargeoffTxn.get(contractId);
                loan__Loan_Account__c lac= loanacountMap.get(contractId);
                
                if(oldchargeofftrxn != null){ 
                    date chargedoffdate =null;
                    chargedoffdate = oldchargeofftrxn.loan__Charged_Off_Date__c;
                    newchargeoffTrxn.loan__Charged_Off_Date__c = chargedoffdate;
                    System.debug('chargedoff date updated on new writeoff trxn ....'+ newchargeoffTrxn.loan__Charged_Off_Date__c); 
                    
                    Decimal newchargedoffInterest ;
                    
                    
                    if( newchargeoffTrxn.loan__Charged_Off_Principal__c != oldchargeofftrxn.loan__Charged_Off_Principal__c){                                                       
                        Integer numberOfDays = Math.abs((lac.loan__last_accrual_date__c).daysBetween(oldchargeofftrxn.loan__Charged_Off_Date__c));
                        Decimal interestRate = lac.loan__interest_rate__c;
                        Decimal principal = lac.loan__Principal_Remaining__c;
                        Integer timecountingMethod = 360;//since the time counting method is 'Months and Days', we will take 360
                        newchargedoffInterest   = ((principal *numberOfDays*interestRate )/(timecountingMethod * 100));
                        System.debug('new chargedoff interest...'+newchargedoffInterest);
                       
                    }else{
                         newchargedoffInterest = oldchargeofftrxn.loan__Charged_Off_Interest__c;
                         }
                          newchargeoffTrxn.loan__Charged_Off_Interest__c = newchargedoffInterest;
                   
                    newTraxnsToUpdate.add(newchargeoffTrxn);
                    
                    
                    lac.loan__Charged_Off_Interest__c = newchargedoffInterest;
                    lac.loan__Charged_Off_Date__c = chargedoffdate;
                    System.debug('chargedoff date on loan account ....'+lac.loan__Charged_Off_Date__c);
                    loansToUpdate.add(lac);
                }
            }
            
           
            
            if(newTraxnsToUpdate != null && newTraxnsToUpdate .size()>0 ){
                update newTraxnsToUpdate;
            }
            if(loansToUpdate != null && loansToUpdate.size()>0 ){
              System.debug('Loan ids getting updated....'+loansToUpdate[0].id);
                update loansToUpdate;
            }
        }   
    }
}