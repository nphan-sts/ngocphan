/*Author : Vishal Lakkammanavar - CLS*/

global class APSAmountTypeUpdate implements Database.Batchable<sObject> {
    
    String query = '';
    public Set<Id> lacc = new Set<Id>();
    Date systemDate = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
    public List<String> status = new List<String>();
    public List<String> loantype = new List<String>();
    public List<String> Producttype = new List<String>();
    public List<String> Amttype = new List<String>();
     
    loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
    
    global APSAmountTypeUpdate(){
       
        System.debug('default constructor');
        status.add('Active - Good Standing');
        status.add('Active - Bad Standing');
        loantype.add('Recurring');
        Producttype.add('Auto Payer');
        Amttype.add('CURRENT PAYMENT AMOUNT');
        
        /*query = 'Select id,name,loan__Amount_Type__c ' +
                'from loan__Automated_Payment_Setup__c where loan__Type__c in: loantype ' +
                'and loan__Active__c = true ' +
                'and loan__CL_Contract__r.loan__Invalid_Data__c = false ' + 
                'and loan__CL_Contract__r.loan__Loan_Status__c in: status ' + 
                'and loan__Amount_Type__c in: Amttype '; */
        
        /*For HM :*/
        query = 'Select id,name,loan__Amount_Type__c ' +
                'from loan__Automated_Payment_Setup__c where loan__Type__c in: loantype ' +
                'and loan__Active__c = true ' +
                'and loan__CL_Contract__r.loan__Loan_Product_Name__r.name in : Producttype ' +
                'and loan__CL_Contract__r.loan__Invalid_Data__c = false ' + 
                'and loan__CL_Contract__r.loan__Loan_Status__c in: status ' + 
                'and loan__Amount_Type__c in: Amttype ';
    }
        
  
     global APSAmountTypeUpdate(Set<Id> lContract){
        status.add('Active - Good Standing');
        status.add('Active - Bad Standing');
        loantype.add('Recurring');
        Producttype.add('Auto Payer');
        Amttype.add('CURRENT PAYMENT AMOUNT');
         lacc = lContract;
         
            query = 'Select id,name,loan__Amount_Type__c ' +
                'from loan__Automated_Payment_Setup__c where loan__Type__c in: loantype ' +
                'and loan__Active__c = true ' +
                'and loan__CL_Contract__r.loan__Invalid_Data__c = false ' + 
                'and loan__CL_Contract__r.loan__Loan_Status__c in: status ' + 
                'and id in : lacc';
    }
         
     
     global APSAmountTypeUpdate(Set<Id> lContract,String query1){   

        status.add('Active - Good Standing');
        status.add('Active - Bad Standing');
        lacc = lContract;
        query = query1;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        if(test.isRunningTest()){
         systemDate = System.today();
         }
       // System.debug('query ' + query);
       // return Database.getQueryLocator(query);
       
            if(query.length() == 0){
              
          query = 'Select id,name,loan__Amount_Type__c ' +
                'from loan__Automated_Payment_Setup__c where loan__Type__c in: loantype ' +
                'and loan__Active__c = true ' +
                'and loan__CL_Contract__r.loan__Invalid_Data__c = false ' + 
                'and loan__CL_Contract__r.loan__Loan_Status__c in: status ';             
        
        }

        System.debug('query ' + query);
        return Database.getQueryLocator(query);
    }
       

    global void execute(Database.BatchableContext BC, List<loan__Automated_Payment_Setup__c> aps){
        List<loan__Automated_Payment_Setup__c> objsToUpdate = new List<loan__Automated_Payment_Setup__c>();
        List<loan__Automated_Payment_Setup__c> APStobeUpdated = [Select id,name,loan__Amount_Type__c 
                                                                 from loan__Automated_Payment_Setup__c
                                                                 where loan__Type__c ='RECURRING' and 
                                                                 loan__Active__c =true and 
                                                                 loan__CL_Contract__r.loan__Invalid_Data__c = false 
                                                                 and loan__CL_Contract__r.loan__Loan_Status__c 
                                                                 in ('Active - Good Standing' ,'Active - Bad Standing' ) 
                                                                 and loan__Amount_Type__c = 'CURRENT PAYMENT AMOUNT'
                                                                 and  loan__CL_Contract__r.loan__Loan_Product_Name__r.name ='Auto Payer'
                                                                 and Id in : aps];
                                               
                                                               
        System.debug(logginglevel.error, ' APStobeUpdated :: ' +APStobeUpdated ); 
        for(loan__Automated_Payment_Setup__c apsupdate: APStobeUpdated ){
         
         //for(loan__Automated_Payment_Setup__c apsupdate: aps ){
            
               system.debug('Inside forupdate block::');
               apsupdate.loan__Amount_Type__c ='LAST BILLED AMOUNT' ;
                objsToUpdate.add(apsupdate);
                               
               // APSAmountTypeFixBatch dataFix = new APSAmountTypeFixBatch(apsupdate);
               //dataFix.FixAPS();

         } update objsToUpdate;

          
       // System.debug('count ' + APStobeUpdated.size());

    }
    
    global void finish(Database.BatchableContext BC){
      
      System.debug('finish batch job');
     }
}