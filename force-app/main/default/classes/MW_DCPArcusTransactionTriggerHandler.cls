/*
12/1/2023: LPC-1347.
*/
public class MW_DCPArcusTransactionTriggerHandler {
    public class MW_DCPTransactionPayload {
        public string type;
        public List<MW_DCPTransactionData> data;
        public MW_DCPTransactionPayload() {
        }
    }
    public class MW_DCPTransactionData {
        public string member_id;
        public string lead_id;
        public string lead_guid;
        public string transaction_id;
        public string id;
        public Boolean pay_at_funding;
        public string payoff_amount;
        public MW_DCPTransactionData() {
        }
    }

    public static void processUpdateTriggers(
        List<DCp_Arcus_Transactions__c> newList,
        map<Id, DCp_Arcus_Transactions__c> oldMap,
        map<Id, DCp_Arcus_Transactions__c> newMap
    ) {
        if (!MW_Utilities.isFrontEndUserUpdate()) {
            sendUpdatestoFE(newList, oldMap, newMap);
        }
    }

    public static void sendUpdatestoFE(
        List<DCp_Arcus_Transactions__c> newList,
        map<Id, DCp_Arcus_Transactions__c> oldMap,
        map<Id, DCp_Arcus_Transactions__c> newMap
    ) {
        map<Id, Id> dcpAppIdMap = new Map<Id, Id>();
        for (DCp_Arcus_Transactions__c dcpTrnx : newList) {
            // Check if Pay at Funding is changed
            if (oldMap.get(dcpTrnx.Id).Pay_at_Funding__c != dcpTrnx.Pay_at_Funding__c) {
                dcpAppIdMap.put(dcpTrnx.Id, dcpTrnx.Application__c);
            }
        }
        if (dcpAppIdMap.values().size() > 0) {
            map<Id, genesis__Applications__c> appMap = new Map<Id, genesis__Applications__c>(
                [
                    SELECT Id, Lead_ID__c, Member_ID__c, LEAD_ID_ExtKey__c
                    FROM genesis__Applications__c
                    WHERE Id IN :dcpAppIdMap.values()
                ]
            );
            MW_DCPTransactionPayload payload = new MW_DCPTransactionPayload();
            payload.type = 'dcp_transaction';
            payload.data = new List<MW_DCPTransactionData>();
            String appId = '', leadId = '';

            for (Id dcptrnxId : dcpAppIdMap.keySet()) {
                DCp_Arcus_Transactions__c dcpRec = newMap.get(dcptrnxId);
                genesis__Applications__c appRec = appMap.get(dcpAppIdMap.get(dcptrnxId));
                MW_DCPTransactionData dataRec = new MW_DCPTransactionData();
                dataRec.member_id = appRec.Member_ID__c;
                dataRec.lead_id = appRec.LEAD_ID_ExtKey__c;
                dataRec.lead_guid = appRec.Lead_ID__c;
                dataRec.transaction_id = dcpRec.Transaction_Id__c;
                dataRec.id = dcpRec.FE_Id__c;
                dataRec.pay_at_funding = dcpRec.Pay_at_Funding__c;
                dataRec.payoff_amount = dcpRec.Requested_Amount__c != null
                    ? String.valueOf(dcpRec.Requested_Amount__c)
                    : '';
                payload.data.add(dataRec);
                appId = appId + appRec.Id + ';';
                leadId = leadId + appRec.Lead_ID__c + ';';
            }
            system.debug('payload.data====>' + payload.data);
            system.debug('payload====>' + JSON.serialize(payload));
            MW_WebhookHandler.CallWebHookIntegration1(JSON.serialize(payload), appId, leadId);
        }
    }

    public static void addDcpTransaction(List<DCp_Arcus_Transactions__c> arcusList) {
        try {
            List<DCP_Transaction__c> dcpList = new List<DCP_Transaction__c>();

            List<DCp_Arcus_Transactions__c> arcusWithLeadGuidList = [
                SELECT
                    Id,
                    Application__c,
                    Application__r.Lead_ID__c,
                    Account__c,
                    Account_Number__c,
                    Bank_Name__c,
                    Card_Number__c,
                    Date_Opened__c,
                    DCP_Callout_done__c,
                    DCP_Callout_successful__c,
                    Arcus_Eligible__c,
                    Member_Code__c,
                    Paid_Amount__c,
                    Pay_at_Funding__c,
                    Portfolio_Type__c,
                    Requested_Amount__c,
                    Status__c,
                    FE_Id__c,
                    Transaction_Id__c,
                    Arcus_Failed_Message__c,
                    Arcus_Failure_Response__c
                FROM DCp_Arcus_Transactions__c
                WHERE Id IN :arcusList
            ];

            for (DCp_Arcus_Transactions__c dcpArcus : arcusWithLeadGuidList) {
                DCP_Transaction__c objDcp = new DCP_Transaction__c(
                    Account__c = dcpArcus.Account__c,
                    Account_Number__c = dcpArcus.Account_Number__c,
                    Application__c = dcpArcus.Application__c,
                    Lead_ID__c = dcpArcus.Application__r.Lead_ID__c,
                    Bank_Name__c = dcpArcus.Bank_Name__c,
                    Card_Number__c = dcpArcus.Card_Number__c,
                    Date_Opened__c = dcpArcus.Date_Opened__c,
                    DCP_Callout_done__c = dcpArcus.DCP_Callout_done__c,
                    DCP_Callout_successful__c = dcpArcus.DCP_Callout_successful__c,
                    DCP_Eligible__c = dcpArcus.Arcus_Eligible__c,
                    Member_Code__c = dcpArcus.Member_Code__c,
                    Paid_Amount__c = dcpArcus.Paid_Amount__c,
                    Pay_at_Funding__c = dcpArcus.Pay_at_Funding__c,
                    Portfolio_Type__c = dcpArcus.Portfolio_Type__c,
                    Requested_Amount__c = dcpArcus.Requested_Amount__c,
                    Status__c = dcpArcus.Status__c,
                    Transaction_Id__c = dcpArcus.FE_Id__c,
                    Vendor_Transaction_Id__c = dcpArcus.Transaction_Id__c,
                    Vendor__c = 'ARCUS',
                    Vendor_Failure_Message__c = dcpArcus.Arcus_Failed_Message__c,
                    Vendor_Failure_Response__c = dcpArcus.Arcus_Failure_Response__c
                );

                dcpList.Add(objDcp);
            }

            if (dcpList.size() > 0) {
                insert dcpList;
            }
        } catch (Exception ex) {
            MW_LogUtility.ExceptionDO expRex = new MW_LogUtility.ExceptionDO(ex);

            MW_LogUtility_Queueable.Log log = new MW_LogUtility_Queueable.Log();
            log.message = JSON.serialize(expRex);
            log.apexClass = 'MW_DCPArcusTransactionTriggerHandler';
            log.label = 'AddDcpTransaction';
            log.type = 'Error';
            MW_LogUtility_Queueable job = new MW_LogUtility_Queueable(log);
            System.enqueueJob(job);
        }
    } //end of public static void sendUpdatestoFE

    public static void updateDcpTransaction(
        List<DCp_Arcus_Transactions__c> pNewRecords,
        Map<Id, DCp_Arcus_Transactions__c> pOldMap,
        Map<Id, DCp_Arcus_Transactions__c> pNewMap
    ) {
        try {
            Set<String> setArcusTransactionIds = new Set<String>();
            for (DCp_Arcus_Transactions__c dcpArcus : pNewRecords) {
                if (string.isNotblank(dcpArcus.FE_Id__c)) {
                    setArcusTransactionIds.Add(dcpArcus.FE_Id__c);
                }
            }

            Map<String, DCP_Transaction__c> mapDcpTransaction = new Map<String, DCP_Transaction__c>();

            List<DCP_Transaction__c> listDcpTransaction = [
                SELECT
                    Id,
                    Account__c,
                    Account_Number__c,
                    Application__c,
                    Bank_Name__c,
                    Card_Number__c,
                    Date_Opened__c,
                    DCP_Callout_done__c,
                    DCP_Callout_successful__c,
                    DCP_Eligible__c,
                    Lead_Id__c,
                    Member_Code__c,
                    Paid_Amount__c,
                    Pay_at_Funding__c,
                    Portfolio_Type__c,
                    Requested_Amount__c,
                    Status__c,
                    Transaction_Id__c,
                    Vendor_Failure_Message__c,
                    Vendor_Failure_Response__c
                FROM DCP_Transaction__c
                WHERE Transaction_Id__c IN :setArcusTransactionIds
            ];

            for (DCP_Transaction__c dcpTransctn : listDcpTransaction) {
                mapDcpTransaction.put(dcpTransctn.Transaction_Id__c, dcpTransctn);
            }

            for (DCp_Arcus_Transactions__c dcpArcus : pNewRecords) {
                if (string.isNotblank(dcpArcus.FE_Id__c)) {
                    DCP_Transaction__c dcpTransctn = mapDcpTransaction.get(dcpArcus.FE_Id__c);
                    if (dcpTransctn != null) {
                        dcpTransctn.Account__c = dcpArcus.Account__c;
                        dcpTransctn.Account_Number__c = dcpArcus.Account_Number__c;
                        dcpTransctn.Bank_Name__c = dcpArcus.Bank_Name__c;
                        dcpTransctn.Card_Number__c = dcpArcus.Card_Number__c;
                        dcpTransctn.Date_Opened__c = dcpArcus.Date_Opened__c;
                        dcpTransctn.DCP_Callout_done__c = dcpArcus.DCP_Callout_done__c;
                        dcpTransctn.DCP_Callout_successful__c = dcpArcus.DCP_Callout_successful__c;
                        dcpTransctn.DCP_Eligible__c = dcpArcus.Arcus_Eligible__c;
                        dcpTransctn.Member_Code__c = dcpArcus.Member_Code__c;
                        dcpTransctn.Paid_Amount__c = dcpArcus.Paid_Amount__c;
                        dcpTransctn.Pay_at_Funding__c = dcpArcus.Pay_at_Funding__c;
                        dcpTransctn.Portfolio_Type__c = dcpArcus.Portfolio_Type__c;
                        dcpTransctn.Requested_Amount__c = dcpArcus.Requested_Amount__c;
                        dcpTransctn.Status__c = dcpArcus.Status__c;
                        dcpTransctn.Transaction_Id__c = dcpArcus.FE_Id__c;
                        dcpTransctn.Vendor_Transaction_Id__c = dcpArcus.Transaction_Id__c;
                        dcpTransctn.Vendor_Failure_Message__c = dcpArcus.Arcus_Failed_Message__c;
                        dcpTransctn.Vendor_Failure_Response__c = dcpArcus.Arcus_Failure_Response__c;
                    }
                }
            }

            if (listDcpTransaction.size() > 0) {
                update listDcpTransaction;
            }
        } catch (Exception ex) {
            MW_LogUtility.ExceptionDO expRex = new MW_LogUtility.ExceptionDO(ex);
            MW_LogUtility_Queueable.Log log = new MW_LogUtility_Queueable.Log();
            log.message = JSON.serialize(expRex);
            log.apexClass = 'MW_DCPArcusTransactionTriggerHandler';
            log.label = 'AddDcpTransaction';
            log.type = 'Error';
            MW_LogUtility_Queueable job = new MW_LogUtility_Queueable(log);
            System.enqueueJob(job);
        }
    } //end of public static void UpdateDcpTransaction
}