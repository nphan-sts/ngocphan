/* ****************Modification History*****************************************************************
 * Modified by    	Date    		JIRA number
  *     Pallavi      2021/01/04      LSP-30
 ******************Modification History*****************************************************************/
global class ActivateFractionalizationBatch implements Database.batchable<sObject>{
             
    String query;
    Set<Id> loanAccountIdSet = new Set<Id>();
    Set<String> skipLoanStatus = new Set<String>{''};//{'Closed- Written Off'};	//LSP-98
    List<MigrationPhase__c> migrationPhase = MigrationPhase__c.getAll().values();
    String phase = migrationPhase[0].phase__c;
    
        
    global ActivateFractionalizationBatch (){
    
    String Status = 'Pending';   
        System.debug(logginglevel.error,'loanAccountIdSet +++'+loanAccountIdSet); 
        
        query = 'SELECT id FROM loan__Loan_Account__c where loan__Fractionalization_Status__c = \''+String.escapeSingleQuotes(Status)+'\' and loan__Loan_Status__c not in : skipLoanStatus'; 
        System.debug(logginglevel.error,'query+++'+query); 
                
    }       
    
    global ActivateFractionalizationBatch (Set<Id> LoanIdS){
       
    loanAccountIdSet = LoanIdS;
    System.debug(logginglevel.error,'loanAccountIdSet +++'+loanAccountIdSet); 
        
        query = 'SELECT id FROM loan__Loan_Account__c where Id in : loanAccountIdSet';
            
        System.debug(logginglevel.error,'query+++'+query); 
                
    }
    /*pallavi(for parallelization)*/
    global ActivateFractionalizationBatch (integer thread){
        String Status = 'Pending';
         
        query = 'SELECT id FROM loan__Loan_Account__c where loan__Thread_Number__c = ' + thread + ' and loan__Fractionalization_Status__c = \''+String.escapeSingleQuotes(Status)+'\'' +
            	' and DM_Migration_Phase__c = \'' +phase+ '\' and isMigrated__c = true'; 
            
        //System.debug(logginglevel.error,'query+++'+query); 
                
    }
    /*pallavi(for parallelization)*/
    global Database.QueryLocator start(Database.BatchableContext bc){
                              
        System.debug('IN Database.QueryLocator'+query);    
        return Database.getQueryLocator(query);
    
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        System.debug('----Method execute(+)scope----'+ scope);
        List<loan__loan_account__c> listOfLoans = (List<loan__loan_account__c>)scope;
        Set<id> LAIIDs = new Set<id>(); 
                
        for (loan__loan_account__c loan : listOfLoans){
        
            LAIIDs.add(loan.Id);    
        
        } 
        
        List <loan__Loan_Account__c> ListOfLAIandIOs = [SELECT id,  
                                                             Name,  
                                                             loan__Loan_amount__c,  
                                                             loan__Principal_Remaining__c,  
                                                             loan__Loan_Balance__c,  
                                                             loan__Interest_Remaining__c,      
                                                             loan__Product_Type__c,            
                                                             loan__Last_Accrual_Date__c,       
                                                             loan__Interest_rate__c,  
                                                             loan__Active_Investor__c,  
                                                             loan__Number_of_Days_Overdue__c,  
                                                             loan__Loan_Status__c,  
                                                             loan__Approval_Date__c,  
                                                             loan__Market_Place_Value__c,  
                                                             loan__Fractionalization_Status__c,  
                                                             loan__Loan_Product_Name__r.loan__Higher_Investor_Certificate_Rate_Allowed__c,
                                                             loan__Charged_Off_Date__c,	//LSP-98
                                                        	 loan__Charged_Off_Interest__c,	//LSP-98
                                                        	 loan__Charged_Off_Principal__c,	//LSP-98
                                                             (select id,name,  
                                                                     loan__Investment_Amount__c,  
                                                                     loan__Certificate_Rate__c,  
                                                                     loan__Enabled_Flag__c,  
                                                                     loan__Service_Rate__c,  
                                                                     loan__Share__c,  
                                                                     loan__Investor_Start_Date__c,  
                                                                     loan__Generate_Amortization_Schedule__c,  
                                                                     loan__Status__c,  
                                                                     loan__Principal_Amount_Paid__c,  
                                                                     loan__Discount_Percent__c,  
                                                                     loan__Account__c,
                                                              		 Buyer__c,		//LSP-30
                                                              		 loan__Investor_End_Date__c,		//LSP-30
                                                              		 peer__Number_Of_Shares__c,			//LSP-30
                                                              		 loan__Account__r.no_of_shares_to_be_Sold__c,	//LSP-30
                                                                     loan__Account__r.loan__Reinvest_Principal__c,	//LSP-30
                                                                     loan__Account__r.loan__Reinvest_Interest__c,	//LSP-30
                                                                     loan__Buying_Price__c,	//LSP-81,76
                                                                     loan__Charged_Off_Date__c,	//LSP-98 
                                                                     loan__Charged_Off_Interest__c,	//LSP-98
                                                              		 loan__Charged_Off_Principal__c	//LSP-98
                                                                     FROM loan__Investors_Loans__r
                                                                     where loan__Status__c in ('New','Sold','Closed - Written Off')) 	//LSP-30 ,LSP-98                     
                                                              FROM loan__Loan_Account__c where Id in : LAIIDs
                                                              and loan__Fractionalization_Status__c = 'Pending'];
                            
        for(loan__loan_account__c loan : ListOfLAIandIOs ){
        
            List<loan__Investor_Loan__c> investmentOrders = new List<loan__Investor_Loan__c>();
            if(loan.loan__Investors_Loans__r != null && loan.loan__Investors_Loans__r.size() > 0){
                investmentOrders = loan.loan__Investors_Loans__r;        
                ActivateFractionalization.activateFractionalization(investmentOrders, loan);
            }else{
                System.debug(logginglevel.ERROR,'NO IO PRESENT WITH STATUS *NEW* ON CL CONTRACT :'+loan.Name);
            }
        
        }
        
        
    } 
    
    public void finish(Database.BatchableContext BC){

    }
    
}