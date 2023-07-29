global class updateUPAbatch implements Database.batchable<sObject>{
             
   String query;
   Set<Id> loanAccountIdSet = new Set<Id>();
   

    loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();      
    
    global updateUPAbatch (Set<Id> LoanIDs){
       
    loanAccountIdSet = LoanIDs;
    System.debug(logginglevel.error,'loanAccountIdSet +++'+loanAccountIdSet); 
        
        /* query = 'Select id,name,loan__Loan_Status__c,loan__Principal_Remaining__c, '+		//pallavi(commented)
                     'loan__Uncleared_Repayment_Amount__c,'+
                     'loan__Principal_Paid__c,'+
                     'loan__Interest_Paid__c,'+
                     'loan__Interest_Remaining__c,'+
                     '(Select id,name,'+
                     'loan__Principal__c,'+
                     'loan__interest__c,'+
                     'loan__Reversed__c,'+
                     'loan__cleared__c,' +
                     'loan__rejected__c ' +
                     'from loan__Loan_Payment_Transactions__r'+ 
                     ' order by loan__Transaction_Date__c desc)'+   
                     'from loan__Loan_Account__c'+
                     ' where Id in : loanAccountIdSet'+
                     ' and datafixupb__c = true';
            
    
        System.debug(logginglevel.error,'query+++'+query); */
                
    }
    /*pallavi*/
    global updateUPAbatch(){		//if possible use this and don't pass contract ids since datafixupb__c will 
        							//be true only on those contracts or which UPBfixbatch was run. the batch will automatically pick such contracts
        System.debug('default constructor');
    }
    /*pallavi*/
    global Database.QueryLocator start(Database.BatchableContext bc){
                              
        //System.debug('IN Database.QueryLocator'+query);
        /*pallavi*/
       /* query = 'Select id,name,loan__Loan_Status__c,loan__Principal_Remaining__c, '+		//pallavi
                     'loan__Uncleared_Repayment_Amount__c,'+
                     'loan__Principal_Paid__c,'+
                     'loan__Interest_Paid__c,'+
                     'loan__Interest_Remaining__c,'+
                     '(Select id,name,'+
                     'loan__Principal__c,'+
                     'loan__interest__c,'+
                     'loan__Transaction_Amount__c ' +
                     'from loan__Loan_Payment_Transactions__r '+
            		 'where loan__cleared__c = false '+		//pallavi
            		 'and loan__rejected__c = false ' +		//pallavi
            		 'and loan__Reversed__c = false)'  +		//pallavi
                    // ' order by loan__Transaction_Date__c desc)'+   	//pallavi(commented)
                     'from loan__Loan_Account__c'+
                     ' where datafixupb__c = true' +
                     ' and UPAfixed__c = False'; */
        
        
    //Saryu updated query to also reflect txns which have been marked as cleared but do not have split and hence there should be the txn amount in the uncleared amount    
 query = 'Select id,name,loan__Loan_Status__c,loan__Principal_Remaining__c,loan__Uncleared_Repayment_Amount__c,loan__Principal_Paid__c,loan__Interest_Paid__c,loan__Interest_Remaining__c,'+
'(select id, name, loan__Principal__c,loan__interest__c,loan__Transaction_Amount__c from loan__Loan_Payment_Transactions__r where ((loan__Reversed__c=false and loan__Cleared__c=false and loan__Rejected__c=false) or ((loan__Reversed__c=false and loan__Cleared__c=true and loan__Rejected__c=false) AND ( loan__Principal__c= 0 and loan__Excess__c =0 and loan__Interest__c =0 and loan__Fees__c=0))))  '+
'from loan__Loan_Account__c where datafixupb__c = true and UPAfixed__c = false';
        
        if(loanAccountIdSet.size()>0){
            query = query + ' and Id in : loanAccountIdSet';
        }
        
        /*pallavi*/
        
        System.debug(logginglevel.error,'query+++'+query);
        return Database.getQueryLocator(query);
    
    }
    
    global void execute(Database.BatchableContext BC, List<loan__loan_account__c> loanAccounts){
        
        List<loan__loan_account__c> listOfLoans = loanAccounts;//(List<loan__loan_account__c>)scope; 	//pallavi
        
        System.debug('count----' + listOfLoans.size());
                 
        for(loan__loan_account__c loan : listOfLoans ){
        
        //System.debug(logginglevel.error, 'Processing Loan :: '+loan.name);
            
            try{   
                                                                       
                updateUPApatch updateUPA = new updateUPApatch(loan);
                updateUPA.FixUPAloan();
                
            }catch(Exception e){
                
                
                batch.loan__Log_Level__c = 'ERROR';
                batch.loan__Message__c = ' Fix Failed for ::'+ loan.Name + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
                batch.loan__Batch_Id__c = 'updateUPAbatch';
                insert batch;
            }
        
        }
        
    } 
    
    public void finish(Database.BatchableContext BC){
        
      
        System.debug('finish batch job');      
    }        
}