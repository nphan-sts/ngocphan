/*Author : Vishal Lakkammanavar - CLS */

global class InterestFixBatch {
    
    public loan__Loan_Account__c LAtobeUpdated;   
    global InterestFixBatch(loan__loan_Account__c LoanAccount){
        
        LAtobeUpdated = LoanAccount;
    }
    
    global void FixInterestloan() {
            
        system.debug('Inside FixInterestloan');
    
        Decimal totalPrincipalonLPTs;
        Decimal PrincipalDiff = 0.00;
        Decimal InterestDiff = 0.00;
        Decimal PrincipalforLA = 0.00;
        Decimal InterestRemainingforLA = 0.00;
        Decimal InterestPaidforLA = 0.00;
        Decimal InterestSum = 0.00;
        Decimal IPTInterest = 0.00;
        Decimal RepaymentDueInterest = 0.00;
        Decimal InterestRemainingtobeupdated = 0.00;
        Boolean toFix = false;
                 
        loan__loan_account__c affectedLoans = new loan__loan_account__c();         
        loan__loan_account__c affectedLoans1 = new loan__loan_account__c();    
        
        set<id> LPT1 = new set<id>();
        
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        Date systemDate = util.getCurrentSystemDate();
        
        loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
        
        try{
                      
            List<loan__Loan_Payment_Transaction__c> LPTs = new List<loan__Loan_Payment_Transaction__c>();
            List<loan__Interest_Posting_Transaction__c> IPTs = new List<loan__Interest_Posting_Transaction__c>();           
            List<loan__Repayment_Schedule__c> AMZs = new List<loan__Repayment_Schedule__c>();
            
            PrincipalforLA = LAtobeUpdated.loan__Principal_Paid__c;
            InterestPaidforLA = LAtobeUpdated.loan__Interest_Paid__c;
            InterestRemainingforLA = LAtobeUpdated.loan__Interest_Remaining__c;
            
            for(loan__Loan_Payment_Transaction__c lpt : LAtobeUpdated.loan__Loan_Payment_Transactions__r){ 
                LPTs.add(lpt);
            }  
            system.debug(LPTs.size());
            
            for(loan__Interest_Posting_Transaction__c IPT : LAtobeUpdated.loan__Interest_Posting_Transactions__r){
                IPTs.add(ipt);
            }
       
            
            for(loan__Repayment_Schedule__c AMZ : LAtobeUpdated.loan__Repayment_Schedule__r){
                AMZs.add(AMZ);
            }
            
            if(LPTs.size() > 0){
             
                PrincipalDiff = 0.00; 
                InterestSum = 0.00;
                totalPrincipalonLPTs = 0.00;
                
                for(loan__loan_payment_transaction__c LPT3 : LPTs){
                  
                    totalPrincipalonLPTs = totalPrincipalonLPTs + LPT3.loan__Principal__c;
                    InterestSum = InterestSum + LPT3.loan__Interest__c;
                    System.debug(logginglevel.error, ' totalInterestonLPTs :: ' +InterestSum);
                    System.debug(logginglevel.error, ' totalPrincipalonLPTs :: ' +totalPrincipalonLPTs);
                    
                } 
                
            }
            
            if(IPTs.size() > 0){
             
                for(loan__Interest_Posting_Transaction__c IPT3 : IPTs){

                    IPTInterest = IPTInterest + IPT3.loan__Interest_Posted__c;   
                } 
                
            }
            
            /*Repayment schedule Due Interest Vishal*/
            
            if(AMZs.size() > 0){
             for(loan__Repayment_Schedule__c AMZ3 : AMZs){
              RepaymentDueInterest = RepaymentDueInterest + AMZ3.loan__Due_Interest__c;
              }
            }
            
                    
                if(RepaymentDueInterest == InterestPaidforLA ) {
                 affectedLoans = LAtobeUpdated;

                    if(InterestPaidforLA == InterestSum ) {
                   
                   System.debug(logginglevel.error, ' RepaymentDueInterest :: ' + RepaymentDueInterest);
                   System.debug(logginglevel.error, ' InterestPaidforLA :: ' + InterestPaidforLA); 
                   
                   
                   if( InterestRemainingforLA > 0.0){
                                 
                  affectedLoans.Loan__interest_Remaining__c = InterestRemainingtobeupdated ;
                 
                 System.debug(logginglevel.error, ' affectedLoans.Loan__interest_Remaining__c :: ' + affectedLoans.Loan__interest_Remaining__c); 
                  
                  }
                  
                 }

                 if(InterestPaidforLA != InterestSum) {
                 
                   InterestPaidforLA = InterestSum;
                   
                   InterestRemainingtobeupdated = RepaymentDueInterest - InterestPaidforLA;
                    
                   affectedLoans.Loan__interest_Remaining__c = InterestRemainingtobeupdated ;
                   affectedLoans.Loan__interest_Paid__c = InterestPaidforLA;
                   
                  }
                  
              affectedLoans.IR_Fixed__c = true;
              
              update affectedLoans;
             }


              else if( RepaymentDueInterest > InterestPaidforLA ){
                 
                 System.debug(logginglevel.error, ' RepaymentDueInterest :: ' + RepaymentDueInterest);
                 System.debug(logginglevel.error, ' InterestPaidforLA :: ' + InterestPaidforLA); 
                  
                 affectedLoans1 = LAtobeUpdated;
                     
                  if(InterestPaidforLA != InterestSum){
                      InterestPaidforLA = InterestSum;
                      
                   } 
                
                 InterestRemainingtobeupdated  = RepaymentDueInterest - InterestPaidforLA;
                 System.debug(logginglevel.error, ' affectedLoans1.InterestRemainingtobeupdated :: ' + InterestRemainingtobeupdated); 
                 affectedLoans1.Loan__interest_Paid__c = InterestPaidforLA ;           
                 affectedLoans1.Loan__interest_Remaining__c = InterestRemainingtobeupdated ;
                 System.debug(logginglevel.error, ' affectedLoans1.Loan__interest_Remaining__c :: ' + affectedLoans1.Loan__interest_Remaining__c ); 
                affectedLoans1.IR_Fixed__c = true;
                update affectedLoans1;
              }
              
                   
            }
       
         catch (Exception e) {
            
            batch.loan__Log_Level__c = 'ERROR';
            batch.loan__Message__c = ' Data fix failed for ::'+ LAtobeUpdated.Name + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
            batch.loan__Batch_Id__c = 'InterestFixBatch';
            insert batch;
            
            System.debug(logginglevel.error,'line number'+e.getLineNumber());
            System.debug(logginglevel.error,'error stackTrace'+e.getStackTraceString());
            System.debug(logginglevel.error,'error message'+e.getMessage()); 
            
        }       
        
    }   
}