Global class DM_DataCleanUp implements Database.Batchable<sObject> {
    
    String query;
    List<loan__Interest_Posting_Transaction__c> IPTStobedeleted = new List<loan__Interest_Posting_Transaction__c>() ;
    List<loan__Investor_Loan__c> IOtobedeleted = new List<loan__Investor_Loan__c>();
    List<clcommon__Repayment_Plan__c> RepaymentPlantobedeleted = new List<clcommon__Repayment_Plan__c>();
    List<loan__Automated_Payment_Setup__c> APS = new List<loan__Automated_Payment_Setup__c>();
    List<loan__Loan_Payment_Transaction__c> LPT = new List<loan__Loan_Payment_Transaction__c>();
    List<id> acc = new List<id>();
    List<id> app = new List<id>();
    List<loan__Loan_Disbursal_Transaction__c> LDT = new List<loan__Loan_Disbursal_Transaction__c>();
    List<DM_Primary_Objects_Validation__c> dmCon = new List<DM_Primary_Objects_Validation__c>();
    List<loan__Loan_Account__c> LoansToBeDeleted = new List<loan__Loan_Account__c>();
    String id = 'a1h2f000000KPitAAG';

    String status = 'Failed';
    List<MigrationPhase__c> migrationPhase = MigrationPhase__c.getAll().values();
    String phase = migrationPhase[0].phase__c;
   
    global Database.QueryLocator start(Database.BatchableContext BC){      
        
        query  = 'Select id, '+
                        '(Select id from loan__Interest_Posting_Transactions__r ), '+
                        '(Select id from loan__Investors_Loans__r ), '+
                        '(Select id from loan__Repayment_Plan__r ), '+ 
                        '(Select id from loan__Automated_Payment_Setup__r ), '+ 
                        '(Select id from loan__Loan_Payment_Transactions__r ), '+
                        '(Select id from loan__Loan_Disbursal_Transactions__r ), '+
            			'(Select id from DM_Primary_Objects_Validations__r ) '+
                        'from loan__Loan_Account__c where isMigrated__c = true '+
                        'and (DM_Post_Migration_Validation_Status__c = \'' + status+ '\' or loan__invalid_data__c = true) and DM_Migration_Phase__c = \'' +phase+ '\'' ;
                        
        System.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<Sobject> scope){
        
        LoansToBeDeleted = (List<loan__Loan_Account__c>)scope;

        System.debug('LoansToBeDeleted ' + LoansToBeDeleted);
        
            for(loan__Loan_Account__c loan : LoansToBeDeleted){
    
                
                IPTStobedeleted.addall(loan.loan__Interest_Posting_Transactions__r);
                IOtobedeleted.addall(loan.loan__Investors_Loans__r);
                RepaymentPlantobedeleted.addall(loan.loan__Repayment_Plan__r);
                APS.addall(loan.loan__Automated_Payment_Setup__r);
                LPT.addall(loan.loan__Loan_Payment_Transactions__r);
                LDT.addall(loan.loan__Loan_Disbursal_Transactions__r);
                dmCon.addAll(loan.DM_Primary_Objects_Validations__r);
            }
        
            Delete IPTStobedeleted ;
            Delete IOtobedeleted ;
            Delete RepaymentPlantobedeleted ;
            delete aps;
        	delete dmCon;

            List<loan__Due_Payment__c> DPD = [select id from loan__Due_Payment__c where loan__Loan_Payment_Transaction__c in :LPT];
            delete DPD;

            delete LPT;

        //List<dm_loan_account__c> dmNotMigrated = [select id,DM_Application__c,DM_Account__c from dm_loan_account__c where Migrated_CL_Contract__c = '' limit 1];
        

        /*List<dm_Loan_Account__c> dmContract = new List<dm_Loan_Account__c>();
        dmContract.addall(dmNotMigrated);
        dmContract.addall(dmCon);
        System.debug('dmContract ' + dmContract);*/

        /*List<Contact> con = [select id from Contact where accountId in: acc];
        delete con;

        List<loan__Bank_Account__c> bankAccount = [select id from loan__Bank_Account__c where loan__Account__c in: acc];
        delete bankAccount;

        List<Account> accDel = [select id from Account where Id in: acc];

        List<Credit_Policy__c> creditPolicy = [select id from Credit_Policy__c where Application__c in: app];
        delete creditPolicy;

        List<genesis__applications__C> appDel = [select id from genesis__applications__C where Id in: app];*/
        

        List<loan__Disbursal_Txn_Distribution__c> distribution = [select id from loan__Disbursal_Txn_Distribution__c where loan__Loan_Disbursal_Transaction__c in: ldt];
        delete distribution;

        delete LDT;

       

        //add dm objects here
        
       /* List<DM_Repayment_Schedule__c> DMamz = [select id from DM_Repayment_Schedule__c where DM_Loan_Product__c in: dmContract];
         delete DMamz;

        List<DM_Automated_Payment_Setup__c> DMaps = [select id from DM_Automated_Payment_Setup__c where DM_CL_Contract__c in: dmContract];
         delete DMaps;

        List<DM_Multi_Step_Loan_Setup__c> DMRSS = [select id from DM_Multi_Step_Loan_Setup__c where DM_Loan_Account__c in: dmContract];
        delete DMRSS;

        List<DM_Investment_Order__c> DMIO = [select id from DM_Investment_Order__c where DM_Loan__c in: dmContract];
        delete DMIO;

        List<DM_Repayment_Plan__c> DMrepPlan = [select id from DM_Repayment_Plan__c where DM_CL_Contract__c in: dmContract];
        delete DMrepPlan;

        List<DM_Loan_Disbursal_Transaction__c> DMLDT = [select id from DM_Loan_Disbursal_Transaction__c where DM_CL_Contract__c in: dmContract];

        List<DM_Disbursal_Transaction_Distribution__c> DMDDT = [select id from DM_Disbursal_Transaction_Distribution__c where DM_Loan_Disbursal_Transaction__c in: DMLDT];

        delete DMDDT;
        delete DMLDT;

        List<DM_Loan_Payment_Transaction__c> DMLPT = [select id from DM_Loan_Payment_Transaction__c where CL_Contract__c in: dmContract];

        List<DM_Due_Payment__c> DMdue = [select id from DM_Due_Payment__c where DM_Loan_Payment_Transaction__c in: DMLPT];
        delete DMdue;
        delete DMLPT;   

        List<DM_Repayment_Schedule_Summary__c> RSS = [select id from DM_Repayment_Schedule_Summary__c where DM_CL_Contract__c in: dmContract];
        System.debug('LoansToBeDeleted ' + LoansToBeDeleted);
        delete RSS;

        delete dmContract;
        delete appDel;
        delete accDel;*/
        Delete LoansToBeDeleted ;
                      
        }
    
    global void finish(Database.BatchableContext BC){
                
        system.debug('Finish Batch Job');
        
    }

}