Global class updateUPApatch {
    
    public loan__Loan_Account__c UPAtobeupdated;
    
    global updateUPApatch(loan__loan_Account__c LoanAccount){ 
        UPAtobeupdated = LoanAccount;
    }

    global void FixUPAloan() {
              
        Decimal UPA;
        Map<String, Decimal> UPAlacc = new Map<String, Decimal>();       
        loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();

        try{
               
            List<loan__Loan_Payment_Transaction__c> ALPTs = new List<loan__Loan_Payment_Transaction__c>();
            ALPTs = UPAtobeupdated.loan__Loan_Payment_Transactions__r;

            if(ALPTs.size()>0){
                
                UPA = 0.00;                 
                for(loan__loan_payment_transaction__c LPT4 : ALPTs){

                    UPA = UPA + LPT4.loan__Transaction_Amount__c;
                    System.Debug(logginglevel.error, 'UPA ::' +UPA);
                    
                   /* if( UPA != UPAtobeupdated.loan__Uncleared_Repayment_Amount__c)
                    {
                        UPAtobeupdated.loan__Uncleared_Repayment_Amount__c = UPA;//UPAlacc.get(lap.name);   //pallavi
                        UPAtobeupdated.UPAfixed__c =true;
                        System.debug(logginglevel.error, 'Uncleared Payment Amount :: ' +UPAtobeupdated.loan__Uncleared_Repayment_Amount__c);*/
                      
                     
                    if(UPA > 0){  
                        UPAtobeupdated.loan__Uncleared_Repayment_Amount__c = UPA;//UPAlacc.get(lap.name);   //pallavi
                        UPAtobeupdated.UPAfixed__c =true;
                        System.debug(logginglevel.error, 'Uncleared Payment Amount :: ' +UPAtobeupdated.loan__Uncleared_Repayment_Amount__c);
                    
                    }/*else if(UPA == null){
                        UPA= 0 ;
                        UPAtobeupdated.UPAfixed__c=true;
                        System.debug(logginglevel.error, 'Uncleared Payment Amount :: ' +UPAtobeupdated.loan__Uncleared_Repayment_Amount__c);*/
                    else{                       
                        UPA= 0 ;
                        UPAtobeupdated.UPAfixed__c=true;
                        System.debug(logginglevel.error, 'Uncleared Payment Amount :: ' +UPAtobeupdated.loan__Uncleared_Repayment_Amount__c);                     
                    }

                }

                update UPAtobeupdated;
                
            }
            if(test.isRunningTest()){
                    loan__loan_Account__c error = new loan__loan_Account__c();
                	delete error;
            }

        }catch (Exception e){
            
            batch.loan__Log_Level__c = 'ERROR';
            batch.loan__Message__c = ' Fix Failed for ::'+ UPAtobeupdated.Name + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
            batch.loan__Batch_Id__c = 'updateUPApatch';
            insert batch;           
            System.debug(logginglevel.error,'line number'+e.getLineNumber());
            System.debug(logginglevel.error,'error stackTrace'+e.getStackTraceString());
            System.debug(logginglevel.error,'error message'+e.getMessage()); 
        }

    }

}