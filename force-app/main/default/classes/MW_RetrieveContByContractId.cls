@RestResource(urlMapping='/contingency/contract-id/*')
global with sharing class MW_RetrieveContByContractId {
    @HttpGet
    global static void  MW_RetrieveContByContractId() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            String contractId = req.params.get('contract-id');
            if (String.isBlank(contractId)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('contract id is required');
                return;
            }
            List<loan__Loan_Block_Code__c> bills = [
                SELECT
                Id,
                Name,
                CreatedDate,
                CreatedById,
                LastModifiedDate,
                LastModifiedById,
                loan__Loan_Account__c,
                loan__Archived__c,
                loan__Block_Code_Applied_On__c,
                loan__Block_Code_Expires_On__c,
                loan__Block_Code_Expiry_Processed__c,
                loan__Block_Code_Revoked_On__c,
                loan__Block_Code_Revoked__c,
                loan__Block_Code__c,
                loan__Master_Archive_Object__c,
                loan__Minutes_To_Expire_Code__c,
                loan__Other_Transaction__c,
                loan__Stop_Accruals__c,
                loan__Summary_Record_Id__c,
                loan__Summary__c,
                loan__Suspend_ACH__c,
                loan__Suspend_Charges__c,
                loan__Suspend_Communication__c,
                loan__Suspend_Disbursals__c,
                loan__Contingency_Status_Code_Setup__c,
                loan__Invalidate_Contract__c,
                loan__Stop_Accrual_Entries__c,
                External_Id__c
                FROM loan__Loan_Block_Code__c
                WHERE loan__Loan_Account__c = :contractId
            ];
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(bills));
        }
        catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(e.getMessage());
        }
    }
}