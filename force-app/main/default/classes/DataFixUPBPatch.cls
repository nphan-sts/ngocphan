/*Author : Saryu */

Global class DataFixUPBPatch {
    
    public loan__Loan_Account__c LAtobeUpdated;   
    global DataFixUPBPatch(loan__loan_Account__c LoanAccount){
        
        LAtobeUpdated = LoanAccount;
    }
    
    global void Fixupbloan() {
            
        system.debug('Inside Fixupbloan');
    
        Decimal totalPrincipalonLPTs;
        Decimal PrincipalDiff = 0.00;
        Decimal InterestDiff = 0.00;
        Decimal PrincipalforLA = 0.00;
        Decimal InterestforLA = 0.00;
        Decimal InterestSum = 0.00;
        Decimal IPTInterest = 0.00;
        Decimal UPA = 0;
        Decimal FIR = 0; 
        Decimal TMP = 0;
            
        loan__loan_account__c affectedLoans = new loan__loan_account__c();         
        loan__loan_account__c unaffectedLoans = new loan__loan_account__c();    
        loan__loan_account__c negaffectedLoans = new loan__loan_account__c();
        
        set<id> LPT1 = new set<id>();
        
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        Date systemDate = util.getCurrentSystemDate();
        
        loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
        
        try{
                      
            List<loan__Loan_Payment_Transaction__c> LPTs = new List<loan__Loan_Payment_Transaction__c>();
            List<loan__Interest_Posting_Transaction__c> IPTs = new List<loan__Interest_Posting_Transaction__c>();  //pallavi           
            
            PrincipalforLA = LAtobeUpdated.loan__Principal_Paid__c;
            InterestforLA = LAtobeUpdated.loan__Interest_Paid__c;
            
            for(loan__Loan_Payment_Transaction__c lpt : LAtobeUpdated.loan__Loan_Payment_Transactions__r){  //pallavi(to avoid child record error)
                LPTs.add(lpt);
            }  

            system.debug(LPTs.size());
            
            /*pallavi*/
            for(loan__Interest_Posting_Transaction__c IPT : LAtobeUpdated.loan__Interest_Posting_Transactions__r){
                IPTs.add(ipt);
            }
            /*pallavi*/
            
            if(LPTs.size() > 0){
             
                PrincipalDiff = 0.00; //Added by saryu for initialisation
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
            
            if(LAtobeUpdated.datafixupb__c==true && LAtobeUpdated.UPBunaffected__c==true){
                
                unaffectedLoans = LAtobeUpdated;
              
            }else{

                PrincipalDiff = totalPrincipalonLPTs - PrincipalforLA;
                //InterestDiff = InterestSum - InterestforLA;
                System.debug(logginglevel.error, 'Interest Diff :: ' +InterestDiff);
                System.debug(logginglevel.error, 'PrincipalDiff :: ' +PrincipalDiff);
                
              if ( LAtobeUpdated.datafixupb__c==true && LAtobeUpdated.negprincipal__c==true && LAtobeUpdated.UPBunaffected__c==false){

                  NegaffectedLoans = LAtobeUpdated;
                  
                   /*select id,name,loan__Loan_Status__c,negprincipal__c, datafixupb__c, UPBunaffected__c,UPBfixed__c 
                   from loan__Loan_Account__c where datafixupb__c=true and negprincipal__c=true and UPBunaffected__c=false //Query
                   
                   NegaffectedLoans.loan__Principal_Paid__c = totalPrincipalonLPTs;//TPlpts.get(la1.name);    //pallavi
                  System.debug(logginglevel.error,' Final Principal :: ' +NegaffectedLoans.loan__Principal_Paid__c);
                   NegaffectedLoans.loan__Principal_Remaining__c = NegaffectedLoans.loan__Principal_Remaining__c - PrincipalDiff;               
                
                    NegaffectedLoans.loan__Interest_Paid__c = InterestSum;// affectedLoans.loan__Interest_Paid__c + Interestsplit;
                    System.debug(logginglevel.error,'Interest Paid ::' +NegaffectedLoans.loan__Interest_Paid__c);               
                
                    FIR = IPTInterest -InterestSum;
                    
                    if(FIR != NegaffectedLoans.Loan__interest_Remaining__c){
                        
                        if(FIR > 0 ){
                            NegaffectedLoans.Loan__interest_Remaining__c = FIR;
                        }else{
                            NegaffectedLoans.Loan__interest_Remaining__c = 0;
                        }
                    }
                }   */  
                
                    
               update NegaffectedLoans; //Extended logic for negative affected loans to be decided after total no. of Loans.
                }
                
                if(PrincipalDiff>=0){ 

                    affectedLoans = LAtobeUpdated;//affectedLoans.add(LAtobeUpdated.id);    //pallavi
                    
                    System.debug(logginglevel.error, ' LAtobeUpdated.loan__Principal_Paid__c :: ' +LAtobeUpdated.loan__Principal_Paid__c);
                    System.debug(logginglevel.error, ' totalPrincipalonLPTs :: ' +totalPrincipalonLPTs); 
                
                    /*pallavi(moving the update part here)*/
                    affectedLoans.loan__Principal_Paid__c = totalPrincipalonLPTs;//TPlpts.get(la1.name);    //pallavi
                    System.debug(logginglevel.error,' Final Principal :: ' +affectedLoans.loan__Principal_Paid__c);
                    affectedLoans.loan__Principal_Remaining__c = affectedLoans.loan__Principal_Remaining__c - PrincipalDiff;               
                
                    //Interestsplit = InterestDiff; //Saryu - We don't need interestsplit anymore, directly pulling value from interest on LPT
                    //System.debug(logginglevel.error,'Interest Split ::' +Interestsplit);
                    affectedLoans.loan__Interest_Paid__c = InterestSum;// affectedLoans.loan__Interest_Paid__c + Interestsplit;/*Saryu*/
                    System.debug(logginglevel.error,'Interest Paid ::' +affectedLoans.loan__Interest_Paid__c);               
                
                    FIR = IPTInterest -InterestSum;
                    
                    if(FIR != affectedLoans.Loan__interest_Remaining__c){
                        
                        if(FIR > 0 ){
                            affectedLoans.Loan__interest_Remaining__c = FIR;
                        }else{
                            affectedLoans.Loan__interest_Remaining__c = 0;
                        }
                    }
                }     
                
                //affectedLoans.datafixupb__c = true; //commented by Saryu as we are updating this in the batch job
                affectedLoans.UPBfixed__c=true;
                update affectedLoans;
                    
            }  
                
        } catch (Exception e) {
            
            batch.loan__Log_Level__c = 'ERROR';
            batch.loan__Message__c = ' Data fix failed for ::'+ LAtobeUpdated.Name + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
            batch.loan__Batch_Id__c = 'DataFixUPBPatch';
            insert batch;
            
            System.debug(logginglevel.error,'line number'+e.getLineNumber());
            System.debug(logginglevel.error,'error stackTrace'+e.getStackTraceString());
            System.debug(logginglevel.error,'error message'+e.getMessage()); 
            
        }       
        
    }   
    
}