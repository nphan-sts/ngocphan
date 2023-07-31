public class MW_DCPArcusTransactionTriggerHandler {
    public class MW_DCPTransactionPayload {
        public string type;
        public List<MW_DCPTransactionData> data;
        public MW_DCPTransactionPayload(){}
    }
    public class MW_DCPTransactionData{
        public string member_id;
        public string lead_id;
        public string lead_guid;
        public string transaction_id;
        public string id;
        public Boolean pay_at_funding;
        public string payoff_amount;
        public MW_DCPTransactionData(){}
    }
    
    public static void processUpdateTriggers(List<DCp_Arcus_Transactions__c> newList, map<Id,DCp_Arcus_Transactions__c> oldMap,map<Id,DCp_Arcus_Transactions__c> newMap){
        if(!MW_Utilities.isFrontEndUserUpdate()){
            sendUpdatestoFE(newList,oldMap,newMap);
        }
    }
    public static void sendUpdatestoFE(List<DCp_Arcus_Transactions__c> newList, map<Id,DCp_Arcus_Transactions__c> oldMap,map<Id,DCp_Arcus_Transactions__c> newMap){
        map<Id,Id> dcpAppIdMap = new map<Id,Id>();
        for(DCp_Arcus_Transactions__c dcpTrnx : newList){
            // Check if Pay at Funding is changed
            if(oldMap.get(dcpTrnx.Id).Pay_at_Funding__c != dcpTrnx.Pay_at_Funding__c){
                dcpAppIdMap.put(dcpTrnx.Id,dcpTrnx.Application__c);
            }
        }
        if(dcpAppIdMap.values().size() > 0){
            map<Id,genesis__Applications__c> appMap = new map<Id,genesis__Applications__c>
                                                    (
                                                        [select Id,Lead_ID__c,Member_ID__c,LEAD_ID_ExtKey__c
                                                        from genesis__Applications__c
                                                        where Id IN : dcpAppIdMap.values()]
                                                    );
            MW_DCPTransactionPayload payload = new MW_DCPTransactionPayload();
            payload.type = 'dcp_transaction';
            payload.data = new list<MW_DCPTransactionData>();
            String appId = '',leadId = '';
            
            for(Id dcptrnxId : dcpAppIdMap.keySet()){
                DCp_Arcus_Transactions__c dcpRec = newMap.get(dcptrnxId);
                genesis__Applications__c appRec = appMap.get(dcpAppIdMap.get(dcptrnxId));
                MW_DCPTransactionData dataRec = new MW_DCPTransactionData();
                dataRec.member_id = appRec.Member_ID__c;
                dataRec.lead_id = appRec.LEAD_ID_ExtKey__c;
                dataRec.lead_guid = appRec.Lead_ID__c;
                dataRec.transaction_id = dcpRec.Transaction_Id__c;
                dataRec.id = dcpRec.FE_Id__c;
                dataRec.pay_at_funding = dcpRec.Pay_at_Funding__c;
                dataRec.payoff_amount = dcpRec.Requested_Amount__c != null?String.valueOf(dcpRec.Requested_Amount__c):'';
                payload.data.add(dataRec);
                appId = appId + appRec.Id + ';';
                leadId = leadId + appRec.Lead_ID__c + ';';
            }  
            system.debug('payload.data====>'+payload.data);
            system.debug('payload====>'+JSON.serialize(payload));
            MW_WebhookHandler.CallWebHookIntegration1(JSON.serialize(payload),appId,leadId);
        }
    }
}