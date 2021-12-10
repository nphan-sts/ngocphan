@RestResource(urlMapping='/bank-account/contract-id/*')
global with sharing class MW_RetrieveBankAcctbyAccountId {
    @HttpGet
    global static void MW_RetrieveBankAcctbyAccountId() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            String contractId = req.params.get('contract-id');
            if (String.isBlank(contractId)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('contract id is required');
                return;
            }
            List<loan__Bank_Account__c> bankAccounts = [
                SELECT
                Id,
                OwnerId,
                IsDeleted,
                Name,
                CreatedDate,
                CreatedById,
                LastModifiedDate,
                LastModifiedById,
                loan__ACH_Code__c,
                loan__Account_Type__c,
                loan__Account_Usage__c,
                loan__Account__c,
                loan__Active__c,
                loan__Bank_Account_Number__c,
                loan__Bank_Name__c,
                loan__Contact__c,
                loan__Routing_Number__c,
                loan__Archived__c,
                loan__Master_Archive_Object__c,
                loan__Signature_Line__c,
                loan__Summary_Record_Id__c,
                loan__Summary__c,
                peer__Account_Age__c,
                peer__Allow_for_Direct_Credit__c,
                peer__Branch_Code__c,
                peer__Savings_No__c,
                peer__Savings_Other__c,
                peer__Savings_Pensions__c,
                peer__Working_Place_Type__c,
                Account_Holder__c,
                Account_Number_Con_Info__c,
                Account_Number__c,
                Bank_Account_External_Id__c,
                Bank_Name_Derived__c,
                First_Name__c,
                Last_Name__c,
                Name_Matches__c,
                Name_on_Account__c,
                Source__c,
                Unmask_Con_Info__c,
                Unmask__c,
                Unmasked_Bank_Account_Number__c,
                Verified_by_linked_bank_account__c,
                YodleeBank_Accounts__c,
                BankACctMatch__c
                FROM loan__Bank_Account__c
                WHERE loan__Account__c = :contractId 
            ];
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(bankAccounts));
        }
        catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(e.getMessage());
        }
    }
}
