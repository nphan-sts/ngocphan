global Class BankRupt{

    @InvocableMethod
    public static void MarkBankRupt(List<id> AccId){
    
    	Block_code__c block = Block_code__c.getInstance();
        
        List<Loan__loan_account__c> contract = [SELECT id, name
                                                   FROM Loan__loan_Account__c 
                                                   WHERE loan__loan_Status__c like 'Active%' AND
                                                   loan__account__c in :AccId];
        System.debug('Loan Account --> ' + contract);                       
        list<loan__Loan_Block_Code__c> blockCode = new list<loan__Loan_Block_Code__c>();                    
        For(loan__loan_Account__c acc : contract){
            loan__Loan_Block_Code__c code = new loan__Loan_Block_Code__c();
            code.loan__Loan_Account__c = acc.id;
            code.loan__Block_Code__c = 'Bankruptcy (B)';
            code.loan__Block_Code_Applied_On__c = System.today();
            code.loan__Block_Code_Expires_On__c = date.newInstance(3000,12,31);
            code.loan__Suspend_ACH__c = block.Stop_Accruals__c;
            code.loan__Suspend_Charges__c = block.Suspend_Charges__c;
            code.loan__Stop_Accruals__c = block.Stop_Accruals__c;
            code.loan__Suspend_Communication__c = block.Suspend_Communication__c;
            code.loan__Suspend_Disbursals__c = block.Suspend_Disbursals__c;
            blockCode.add(code);
        
        }
        
        insert blockCode;
    }
}