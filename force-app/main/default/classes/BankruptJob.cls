global class BankruptJob implements Database.Batchable<sObject>{

    public String query;
    
    public BankruptJob(){
    
    }
    
    public BankruptJob(String q){
        query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        query = 'SELECT id, Name '+
                    +'FROM loan__loan_account__c'+
                    +' WHERE loan__account__r.Bankrupt__c = TRUE';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Loan__loan_account__c> scope){
    
                                                    
        list<loan__Loan_Block_Code__c> blockCode = new list<loan__Loan_Block_Code__c>();
        
        For(Loan__loan_account__c acc : scope){
            loan__Loan_Block_Code__c code = new loan__Loan_Block_Code__c();
            code.loan__Loan_Account__c = acc.id;
            code.loan__Block_Code__c = 'Bankruptcy (B)';
            code.loan__Block_Code_Applied_On__c = System.today();
            code.loan__Block_Code_Expires_On__c = date.newInstance(3000,12,31);
            blockCode.add(code);
        }
        insert blockCode;
    }
    
    global void finish(Database.BatchableContext BC){
    
    }
}