/***********Modification History**************
Pallavi			LOS-156			2019-11-21
/********************************************/
public class DeactivateBankAccountsforApplications {
    
    public static void deactivateBankAccount(Id appId) {
        
        List<String> deactivateStatus = System.Label.BankDeactivateStatus.split(',');
        list<genesis__applications__c> apps = [select id,name,genesis__account__c,Bank_Account__c,Bank_Account__r.loan__active__c from genesis__applications__c	//pallavi(LOS-156)
                                               where id =: appId and genesis__status__c in:deactivateStatus];
        
        List<Id> accountsId = new List<Id>();
        for(genesis__applications__c a:apps) {
            accountsId.add(a.genesis__account__c);
        }
        
        /*list<loan__bank_account__c> banks = [select id,name ,loan__active__c	//pallavi(LOS-156)(commented)
                                            from loan__bank_account__c
                                            where loan__account__c in: accountsId];*/
        
        
        /*if(banks!=null && banks.size()>0) {	//pallavi(LOS-156)(commented)
            List<loan__bank_account__c> deactivatebankAccount = new List<loan__bank_account__c>();
            for(loan__bank_account__c b:banks) {
                b.loan__active__c = false;   
                deactivatebankAccount.add(b);
            }*/
       /*pallavi(LOS-156)*/
        List<Id> bankaccountsId = new List<Id>();
        
        for(genesis__applications__c a:apps) {
            bankaccountsId.add(a.Bank_Account__c);
        }
        
         list<loan__bank_account__c> banks = [select id,name ,loan__active__c
                                            from loan__bank_account__c
                                            where id in: bankaccountsId];
        
        if(!bankaccountsId.isEmpty() && bankaccountsId.size()>0){
            List<loan__bank_account__c> deactivatebankAccount = new List<loan__bank_account__c>();
            for(loan__bank_account__c b:banks){
                b.loan__active__c = false;
                deactivatebankAccount.add(b);
            }
           /*pallavi(LOS-156)*/
                try {
                    if(deactivatebankAccount!=null && deactivatebankAccount.size()>0)	//pallavi
                    	update deactivatebankAccount;
                } catch (Exception e) {
                    loan__batch_process_log__c bpl = new loan__batch_process_log__c();
                    bpl.loan__message__c = e.getMessage() + 'at line number:'+e.getLineNumber();
                    bpl.loan__Origin__c = 'DeactivateBankAccounts';
                    bpl.loan__Log_Level__c = 'Exception';
                    insert bpl;
                }
        }
        
    }

}