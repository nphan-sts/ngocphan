public class MW_BankAccountUpdateSync {
    public static void sendUpdatesToMatcha(
        map<Id, loan__Bank_Account__c> newMap,
        map<Id, loan__Bank_Account__c> oldMap
    ) {
        List<BankAccountDetails> bankAccPaylodList = new List<BankAccountDetails>();
        list<string> statusList = Label.MW_ExcludeAppStatusForBankAccountSync.split(';');
        map<Id, String> accAppIdMap = new Map<Id, String>();
        set<Id> accIds = new Set<Id>();

        for (loan__Bank_Account__c bankAcc : newMap.values()) {
            accIds.add(bankAcc.loan__Account__c);
        }

        for (genesis__applications__c app : [
            SELECT Id, Lead_ID__c, genesis__Account__c
            FROM genesis__applications__c
            WHERE genesis__Account__c IN :accIds AND genesis__Status__c NOT IN :statusList
        ]) {
            accAppIdMap.put(app.genesis__Account__c, app.Lead_ID__c);
        }
        Boolean sendBankSync = false;
        for (Id bankId : newMap.keyset()) {
            loan__Bank_Account__c bankAccRec = newMap.get(bankId);
            loan__Bank_Account__c oldBankAccRec = oldMap.get(bankId);
            if (bankAccRec != null && bankAccRec.loan__Active__c) {
                BankAccountDetails bankAccPaylod = new BankAccountDetails();

                if (
                    bankAccRec.Unmasked_Bank_Account_Number__c != oldBankAccRec.Unmasked_Bank_Account_Number__c ||
                    bankAccRec.loan__Routing_Number__c != oldBankAccRec.loan__Routing_Number__c ||
                    bankAccRec.loan__Account_Type__c != oldBankAccRec.loan__Account_Type__c ||
                    bankAccRec.loan__Bank_Name__c != oldBankAccRec.loan__Bank_Name__c ||
                    bankAccRec.First_Name__c != oldBankAccRec.First_Name__c ||
                    bankAccRec.Last_Name__c != oldBankAccRec.Last_Name__c
                ) {
                    sendBankSync = true;
                }

                bankAccPaylod.bank_account_number = bankAccRec.Unmasked_Bank_Account_Number__c;
                bankAccPaylod.routing_number = bankAccRec.loan__Routing_Number__c;
                bankAccPaylod.account_type = bankAccRec.loan__Account_Type__c;
                bankAccPaylod.bank_name = bankAccRec.loan__Bank_Name__c;
                bankAccPaylod.first_name = bankAccRec.First_Name__c;
                bankAccPaylod.last_name = bankAccRec.Last_Name__c;

                if (accAppIdMap.get(bankAccRec.loan__Account__c) != null && sendBankSync) {
                    bankAccPaylod.lead_guid = accAppIdMap.get(bankAccRec.loan__Account__c);
                    bankAccPaylodList.add(bankAccPaylod);
                }
            }
        }
        if (bankAccPaylodList.size() > 0) {
            BankAccountPayload bap = new BankAccountPayload('sync_bank_account', bankAccPaylodList);
            Sync_bankAccount(JSON.serialize(bap, true), JSON.serialize(accAppIdMap.values(), true));
        }
    }
    @Future(callout=true)
    public static void Sync_bankAccount(string bankAccPaylod, string appIds) {
        system.debug('bankAccPaylod====>' + bankAccPaylod);
        system.debug('appIds====>' + appIds);
        MW_WebhookHandler.CallWebHookIntegration(bankAccPaylod, appIds, '');
    }

    public static void sendDeletesToMatcha(map<Id, loan__Bank_Account__c> bankAccMap) {
        for (genesis__applications__c app : [
            SELECT Id, Lead_ID__c, Bank_Account__c, Member_ID__c, Payment_Mode__c, genesis__Status__c
            FROM genesis__applications__c
            WHERE Bank_Account__c IN :bankAccMap.keySet()
        ]) {
            ApplicationPayload appPayload = new ApplicationPayload();

            appPayload.lead_id = app.Lead_ID__c;
            appPayload.member_id = app.Member_ID__c;

            if (app.genesis__Status__c == PayoffConstants.FUNDED) {
                DeletedBankAccountDetail deletedBankAccPayload = new DeletedBankAccountDetail();

                deletedBankAccPayload.deleted_at = System.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSS') + 'Z';
                deletedBankAccPayload.payment_method = app.Payment_Mode__c;

                appPayload.bank_account = deletedBankAccPayload;
                syncDeletedbankAccount(JSON.serialize(appPayload, true), app.Id);
            } else {
                appPayload.bank_account = null;
                appPayload.cls_bank_account_status = null;
                appPayload.fraud_bank_account = null;
                syncDeletedbankAccount(JSON.serialize(appPayload), app.Id);
            }
        }
    }

    @Future(callout=true)
    public static void syncDeletedbankAccount(string appPayload, string appId) {
        system.debug('appPayload====>' + appPayload);
        system.debug('appId====>' + appId);
        callWebHookIntegrationOnBankAccountDelete(appPayload, appId, '');
    }

    static String callWebHookIntegrationOnBankAccountDelete(String reqbody, String appId, String leadId) {
        try {
            String deleteBankAccountEndpoint = MW_Settings__c.getInstance().Delete_Bank_Account_EndpointURL__c;

            if (String.isBlank(deleteBankAccountEndpoint)) {
                return 'Success';
            }
            String certName = MW_Settings__c.getInstance().CertificateNameForLEADS__c;

            MW_LogUtility.info('MW_BankAccountUpdateSync', appId, leadId, 'sendUpdatesToMatcha', reqbody);

            HTTPResponse res = sendRequest(reqbody, certName, deleteBankAccountEndpoint);

            String response;

            MW_LogUtility.info('MW_BankAccountUpdateSync', appId, leadId, 'sendUpdatesToMatcha', res.getBody(), res);

            if (res.getStatusCode() == 200) {
                response = res.getBody();
            }
        } catch (Exception e) {
            MW_LogUtility.error('MW_WebhookHandler', appId, leadId, 'sendUpdatesToMatcha', e);
            System.debug(
                'Error: ' + e.getLineNumber() + ' Desc. ' + e.getMessage() + ' Stack: ' + e.getStackTraceString()
            );
            return 'Fail';
        }
        return 'Success';
    }

    public static HTTPResponse sendRequest(String reqbody, String certName, String endpoint) {
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Cache-Control', 'no-cache');
        if (certName != null)
            req.setClientCertificateName(certName);
        System.debug('WebHook request :: >>' + reqbody);

        req.setEndpoint(endpoint);
        req.setbody(reqbody);
        Http http = new Http();
        req.setTimeout(120000);
        System.debug('Request:: >>' + req);
        HTTPResponse res = http.send(req);
        System.debug('Response :: >> ' + res);

        return res;
    }

    public class BankAccountDetails {
        public string lead_guid;
        public string bank_account_number;
        public string routing_number;
        public string account_type;
        public string bank_name;
        public string first_name;
        public string last_name;

        public BankAccountDetails() {
        }
    }
    public class BankAccountPayload {
        public string type;
        public List<BankAccountDetails> data;

        public BankAccountPayload(string type, List<BankAccountDetails> bankAccounts) {
            this.type = type;
            this.data = bankAccounts;
        }
    }
    public class DeletedBankAccountDetail {
        public String deleted_at;
        public string payment_method;
    }
    public class ApplicationPayload {
        public string member_id;
        public string lead_id;
        public DeletedBankAccountDetail bank_account;
        public string cls_bank_account_status;
        public string fraud_bank_account;
    }
}