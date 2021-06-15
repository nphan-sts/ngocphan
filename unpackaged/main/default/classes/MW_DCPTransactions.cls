public with sharing class MW_DCPTransactions {

    public class DCPClass {
        public String lead_id;
        public List<TransactionClass> dcp;
        public Datetime dcp_confirmation_date;
    }

    public class TransactionClass {
        //insert dcp values
        public String balance;
        public String bank_name;
        public String id;

        //update dcp values
        public String transaction_id;
        public String credit_card_number;
        public Double payoff_amount;
        public Boolean braintree_verification_failed;
        public String arcus_failed_message;
        
        public String member_code;
        public String portfolio_type;
        public String account_number;
        public Date date_opened;
        public Boolean arcus_eligible;
    }

    public static void storeDCPTransactions(List<genesis__Applications__c> apps, String transactionsString){
        DCPClass dcpObj = (DCPClass) JSON.deserialize(transactionsString, DCPClass.class);
        try {
            List<DCp_Arcus_Transactions__c> newTransactions = new List<DCp_Arcus_Transactions__c>();
            for(TransactionClass eachTran: dcpObj.dcp) {
                DCp_Arcus_Transactions__c transactionObj = new DCp_Arcus_Transactions__c();
                transactionObj.FE_Id__c = eachTran.id;
                transactionObj.Account__c = apps[0].genesis__Account__c;
                transactionObj.Application__c = apps[0].id;
                if(eachTran.credit_card_number !=null)
                transactionObj.Card_Number__c = eachTran.credit_card_number;
                if(eachTran.bank_name !=null)
                transactionObj.Bank_Name__c = eachTran.bank_name;
                if(eachTran.payoff_amount !=null)
                transactionObj.Requested_Amount__c = eachTran.payoff_amount;
                if(eachTran.transaction_id !=null)
                transactionObj.Transaction_Id__c = eachTran.transaction_id;
                if(eachTran.braintree_verification_failed != null){
                    transactionObj.Braintree_Verification_Failed__c = eachTran.braintree_verification_failed;
                }
                if(eachTran.arcus_failed_message !=null)
                transactionObj.Arcus_Failed_Message__c = eachTran.arcus_failed_message;
                if(eachTran.transaction_id != null) {
                    transactionObj.Status__c = 'On Hold';
                    transactionObj.Pay_at_Funding__c = true;
                }
                if(eachTran.member_code !=null){
                    transactionObj.Member_Code__c = eachTran.member_code;
                }
                if(eachTran.portfolio_type !=null){
                    transactionObj.Portfolio_Type__c = eachTran.portfolio_type;
                }
                if(eachTran.account_number !=null){
                    transactionObj.Account_Number__c = eachTran.account_number;
                }
                if(eachTran.date_opened !=null){
                    transactionObj.Date_Opened__c = eachTran.date_opened;
                }
                if(eachTran.arcus_eligible !=null){
                    transactionObj.Arcus_Eligible__c = eachTran.arcus_eligible;
                }
                newTransactions.add(transactionObj);
            }
            if(newTransactions.size() > 0) {
                //upsert using external id
                upsert newTransactions FE_Id__c;
            }
        }
        catch(Exception e){
            MW_LogUtility.error('MW_DCPTransactions', apps[0].id, '', 'storeDCPTransactions', e);
        }
    }
}