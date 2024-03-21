Global class DM_DataCleanUp_Staging implements Database.Batchable<sObject> {
    
    String query;
    String status = 'Failed';
    public Integer thread = 0;
    List<MigrationPhase__c> migrationPhase = MigrationPhase__c.getAll().values();
    String phase = migrationPhase[0].phase__c;
    String id = '';
    List<DM_Repayment_Schedule_Summary__c> rss = new List<DM_Repayment_Schedule_Summary__c>();
    List<DM_Automated_Payment_Setup__c> aps = new List<DM_Automated_Payment_Setup__c>();
    List<DM_Investment_Order__c> io = new List<DM_Investment_Order__c>();
    List<DM_Repayment_Plan__c> rep = new List<DM_Repayment_Plan__c>();
    List<DM_Loan_Disbursal_Transaction__c> ldt = new List<DM_Loan_Disbursal_Transaction__c>();
    List<DM_Loan_Payment_Transaction__c> lpt = new List<DM_Loan_Payment_Transaction__c>();
    List<DM_Repayment_Schedule__c> amz = new List<DM_Repayment_Schedule__c>();
    List<DM_Contingency_Status_Code__c> contingency = new List<DM_Contingency_Status_Code__c>();
    List<id> app = new List<id>();
    List<id> acc = new List<id>();
    List<dm_Loan_Account__c> LoansToBeDeleted = new List<dm_Loan_Account__c>();
    List<Account> accDel = new List<Account>();
    List<String> extId = new List<String>();
    
    global DM_DataCleanUp_Staging(Integer threadNumber){
   			thread = threadNumber;
    } 
    
    global DM_DataCleanUp_Staging(){
        
    } 
        
    global Database.QueryLocator start(Database.BatchableContext BC){      
        
        query  = 'Select id,DM_Application__c,DM_Account__c,DM_Loan_Account_External_Id__c, '+
                        '(Select id from DM_Repayment_Schedule_Summarys__r ), '+
                        '(Select id from DM_Automated_Payment_Setups__r ), '+
                        '(Select id from DM_Investment_Orders__r ), '+ 
                        '(Select id from DM_Repayment_Plans__r ), '+ 
                        '(Select id from DM_Loan_Disbursal_Transactions__r ), '+
                        '(Select id from DM_Loan_Payment_Transactions__r ), '+
                        '(Select id from DM_Repayment_Schedules__r ),'+
            			'(Select id from Contingency_Status_Codes__r ) ' + 	
                        'from dm_Loan_Account__c where '+
                        'Migrated_CL_Contract__c = \'' + id + '\'' ; 	
        if(thread != 0)
           query = query + ' and dm_Thread_Number__c = ' + thread; 
                        
        System.debug(query);
        return Database.getQueryLocator(query);
    }
     global void execute(Database.BatchableContext BC,List<Sobject> scope){
        
        LoansToBeDeleted = (List<dm_Loan_Account__c>)scope;

        System.debug('LoansToBeDeleted ' + LoansToBeDeleted);
        
            for(dm_Loan_Account__c loan : LoansToBeDeleted){
                rep.addall(loan.DM_Repayment_Plans__r);
                amz.addall(loan.DM_Repayment_Schedules__r);
                io.addall(loan.DM_Investment_Orders__r);
                rss.addall(loan.DM_Repayment_Schedule_Summarys__r);
                APS.addall(loan.DM_Automated_Payment_Setups__r);
                LPT.addall(loan.DM_Loan_Payment_Transactions__r);
                LDT.addall(loan.DM_Loan_Disbursal_Transactions__r);
                app.add(loan.DM_Application__c);
                acc.add(loan.DM_Account__c);
                contingency.addall(loan.Contingency_Status_Codes__r);
                extId.add('BA-'+loan.DM_Loan_Account_External_Id__c);
            }
                     	        
         	
            Delete rep ;
            Delete amz ;
            Delete io ;
            delete aps;
            delete rss;
            delete contingency;
         
            List<DM_Due_Payment__c> DMdue = [select id from DM_Due_Payment__c where DM_Loan_Payment_Transaction__c in: LPT];
            delete DMdue;
            delete LPT;
         
            List<DM_Disbursal_Transaction_Distribution__c> DMDDT = [select id from DM_Disbursal_Transaction_Distribution__c where DM_Loan_Disbursal_Transaction__c in: LDT];

            delete DMDDT;
            delete LDT;
         
            List<Credit_Policy__c> creditPolicy = [select id from Credit_Policy__c where Application__c in: app];
            delete creditPolicy;
            
            List<genesis__applications__C> appDel = [select id from genesis__applications__C where Id in: app];
         	
         	List<loan__loan_account__c> loan = [select id from loan__loan_account__c where loan__Account__c in: acc limit 1];
         
         	
           List<loan__Bank_Account__c> bankAccount = [select id from loan__Bank_Account__c where loan__Account__c in: acc
                                                     and Bank_Account_External_Id__c in: extId];
           delete bankAccount;
         	
         	if(loan.size() == 0){
                /*List<Contact> con = [select id from Contact where accountId in: acc];
                delete con;*/	// gets automatically deleted
               
                accDel = [select id from Account where Id in: acc];
            }    
            
            Delete LoansToBeDeleted;
            delete appDel;
           try{
            if(accDel.size()>0)
            	delete accDel;
           }    
           catch(Exception e){
              System.debug('account connected with app');
           }  
         
     }
     global void finish(Database.BatchableContext BC){
                
        system.debug('Finish Batch Job');
        
    }
    
}