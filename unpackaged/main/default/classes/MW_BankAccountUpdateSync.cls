public class MW_BankAccountUpdateSync{
    public static void sendUpdatesToMatcha(map<Id,loan__Bank_Account__c> newMap, map<Id,loan__Bank_Account__c> OldMap){
        List<BankAccountDetails> bankAccPaylodList = new List<BankAccountDetails>();
        list<string> statusList = Label.MW_ExcludeAppStatusForBankAccountSync.split(';');
        map<Id,String> accAppIdMap = new map<Id,String>();
        set<Id> accIds = new set<Id>();
        
        for(loan__Bank_Account__c bankAcc : newMap.values()){
            accIds.add(bankAcc.loan__Account__c);
        }
        
        for(genesis__applications__c app : [select Id,Lead_ID__c,genesis__Account__c from genesis__applications__c 
                                            where genesis__Account__c IN : accIds AND 
                                            genesis__Status__c NOT IN : statusList]){
            accAppIdMap.put(app.genesis__Account__c,app.Lead_ID__c);
        }
        Boolean sendBankSync = false;
        for(Id bankId : newMap.keyset()){
            loan__Bank_Account__c bankAccRec = newMap.get(bankId);
            loan__Bank_Account__c oldBankAccRec = OldMap.get(bankId);
            if(bankAccRec != null && bankAccRec.loan__Active__c){
                BankAccountDetails bankAccPaylod = new BankAccountDetails();
                
                if(bankAccRec.Unmasked_Bank_Account_Number__c != oldBankAccRec.Unmasked_Bank_Account_Number__c ||
                    bankAccRec.loan__Routing_Number__c != oldBankAccRec.loan__Routing_Number__c ||
                    bankAccRec.loan__Account_Type__c != oldBankAccRec.loan__Account_Type__c ||
                    bankAccRec.loan__Bank_Name__c != oldBankAccRec.loan__Bank_Name__c ||
                    bankAccRec.First_Name__c != oldBankAccRec.First_Name__c ||
                    bankAccRec.Last_Name__c != oldBankAccRec.Last_Name__c)
                {
                    sendBankSync = true;
                }
                
                bankAccPaylod.bank_account_number = bankAccRec.Unmasked_Bank_Account_Number__c;
                bankAccPaylod.routing_number = bankAccRec.loan__Routing_Number__c;
                bankAccPaylod.account_type = bankAccRec.loan__Account_Type__c;
                bankAccPaylod.bank_name = bankAccRec.loan__Bank_Name__c;
                bankAccPaylod.first_name = bankAccRec.First_Name__c;
                bankAccPaylod.last_name = bankAccRec.Last_Name__c;
                                        
                if(accAppIdMap.get(bankAccRec.loan__Account__c) != null && sendBankSync){
                    bankAccPaylod.lead_guid = accAppIdMap.get(bankAccRec.loan__Account__c);
                    bankAccPaylodList.add(bankAccPaylod);
                }
            }
        }
        if(bankAccPaylodList.size() > 0){
            BankAccountPayload bap = new BankAccountPayload('sync_bank_account',bankAccPaylodList);
            Sync_bankAccount(JSON.serialize(bap,true),JSON.serialize(accAppIdMap.values(),true));
        }
    }
    @Future(callout=true)
    public static void Sync_bankAccount(string bankAccPaylod,string appIds){
        system.debug('bankAccPaylod====>'+bankAccPaylod);
        system.debug('appIds====>'+appIds);
        MW_WebhookHandler.CallWebHookIntegration(bankAccPaylod,appIds, '');
    }
    public class BankAccountDetails{
        public string lead_guid;
        public string bank_account_number;
        public string routing_number;
        public string account_type;
        public string bank_name;
        public string first_name;
        public string last_name;
        
        public BankAccountDetails(){}
    }
    public class BankAccountPayload{
        public string type;
        public List<BankAccountDetails> data;
        
        public BankAccountPayload(string type,List<BankAccountDetails> bankAccounts){
            this.type = type;
            this.data = bankAccounts;
        }
    }
    
}