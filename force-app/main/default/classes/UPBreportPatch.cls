Global class  UPBreportPatch {
    
    public loan__Loan_Account__c LAtobeUpdated;   
    global UPBreportPatch(loan__loan_Account__c LoanAccount){
        
        LAtobeUpdated = LoanAccount;
    }
    
    global void Reportupbloan() {
        
        Decimal totalPrincipalonLPTs;
        Decimal PrincipalDiff = 0.00;
        Decimal PrincipalforLA = 0.00;
        Decimal PrincipalDiff1= 0.00;
               
        loan__loan_account__c affectedLoans = new loan__loan_account__c();    
        loan__loan_account__c unaffectedLoans = new loan__loan_account__c();     
        loan__loan_account__c NegaffectedLoans = new loan__loan_account__c(); 
        List<loan__Loan_Payment_Transaction__c> LPTs = new List<loan__Loan_Payment_Transaction__c>(); 
        set<id> LPT1 = new set<id>();       
        
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        Date systemDate = util.getCurrentSystemDate();
        
        loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
        
        try{                       
           
            PrincipalforLA = LAtobeUpdated.loan__Principal_Paid__c;
            
            /*for(loan__Loan_Payment_Transaction__c lpt : LAtobeUpdated.loan__Loan_Payment_Transactions__r){
                LPTs.add(lpt);
            }*/  

            system.debug(LAtobeUpdated.loan__Loan_Payment_Transactions__r.size());       
          
            if(LAtobeUpdated.loan__Loan_Payment_Transactions__r.size() > 0){
             
                PrincipalDiff = 0.00; 
                totalPrincipalonLPTs = 0.00;
                PrincipalDiff1= 0.00;
                
                for(loan__loan_payment_transaction__c LPT3 : LAtobeUpdated.loan__Loan_Payment_Transactions__r){
                  
                    totalPrincipalonLPTs = totalPrincipalonLPTs + LPT3.loan__Principal__c;
                    System.debug(logginglevel.error, ' totalPrincipalonLPTs :: ' +totalPrincipalonLPTs);
                    
                } 
                
            }
           
            if(LAtobeUpdated.loan__Principal_Paid__c == totalPrincipalonLPTs){
                
                unaffectedLoans = LAtobeUpdated;
                System.debug(logginglevel.error,' UnAffected Loans :: ' +unaffectedLoans);
                System.debug(logginglevel.error, ' LA.loan__Principal_Paid__c :: ' +LAtobeUpdated.loan__Principal_Paid__c);
                System.debug(logginglevel.error, ' totalPrincipalonLPTs :: ' +totalPrincipalonLPTs); 
                
                /*pallavi(moving the update part here)*/
                UnaffectedLoans.datafixupb__c = true;
                UnaffectedLoans.UPBunaffected__c=true;
                //UnaffectedLoans.UPBfixed__c=true;  //Commented by Saryu as we will mark this as UPAfixed in the UPA batch
                update UnaffectedLoans;
                /*pallavi*/
            
            }else{

                PrincipalDiff = totalPrincipalonLPTs - PrincipalforLA;
                System.debug(logginglevel.error, 'PrincipalDiff :: ' +PrincipalDiff);
         
                PrincipalDiff1 = PrincipalforLA - totalPrincipalonLPTs;
                System.debug(logginglevel.error, 'PrincipalDiff1 :: ' +PrincipalDiff);
         
                if (totalPrincipalonLPTs > LAtobeUpdated.loan__Loan_Amount__c){
           
                   NegaffectedLoans = LAtobeUpdated;
                   NegaffectedLoans.Negprincipal__c=true; 
                   NegaffectedLoans.datafixupb__c=true;
                   update NegaffectedLoans;

                }
                          
                if(PrincipalDiff>=0){

                    affectedLoans = LAtobeUpdated;
                    affectedLoans.datafixupb__c=true;
                    System.debug(logginglevel.error, ' affectedLoans.loan__Principal_Paid__c :: ' +affectedLoans.loan__Principal_Paid__c);
                    System.debug(logginglevel.error, ' totalPrincipalonLPTs :: ' +totalPrincipalonLPTs); 
                    update affectedLoans;
                } 

            }
      
        }catch (Exception e) {
            
            batch.loan__Log_Level__c = 'ERROR';
            batch.loan__Message__c = ' Data fix failed for ::'+ LAtobeUpdated.Name + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
            batch.loan__Batch_Id__c = 'UPBreportPatch';
            insert batch;
            
            System.debug(logginglevel.error,'line number'+e.getLineNumber());
            System.debug(logginglevel.error,'error stackTrace'+e.getStackTraceString());
            System.debug(logginglevel.error,'error message'+e.getMessage()); 
            
        }        
        
    }
    
}