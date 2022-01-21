@RestResource(urlMapping='/bill/contract-id/*')
global with sharing class MW_RetrieveBillsbyContractId {
    @HttpGet
    global static void MW_RetrieveBillsbyContractId() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            String contractId = req.params.get('contract-id');
            if (String.isBlank(contractId)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('contract id is required');
                return;
            }
            List<loan__Loan_account_Due_Details__c> bills = [
                SELECT 
                id,
                Name,
                CreatedDate,
                CreatedById,
                LastModifiedDate,
                LastModifiedById,
                loan__Loan_Account__c,
                loan__Balance_Amount__c,
                loan__Compounding_Interest_Billed__c,
                loan__DD_Primary_Flag__c,
                loan__Due_Amt__c,
                loan__Due_Date__c,
                loan__Due_Type_Description__c,
                loan__Due_Type__c,
                loan__Interest_Billed__c,
                loan__Interest_Paid__c,
                loan__Late_Charge_Applied__c,
                loan__Payment_Amt__c,
                loan__Payment_Date__c,
                loan__Payment_Satisfied__c,
                loan__Principal_Billed__c,
                loan__Principal_Paid__c,
                loan__Regular_Interest_Billed__c,
                loan__Remarks__c,
                loan__Rescheduled_flag__c,
                loan__Tolerance__c,
                loan__Transaction_Date__c,
                loan__Archived__c,
                loan__Balance__c,
                loan__Master_Archive_Object__c,
                loan__Payoff_Balance__c,
                loan__Summary_Record_Id__c,
                loan__Summary__c,
                loan__waiver_applied__c,
                loan__Actual_Tolerance_Amount__c,
                loan__Average_Daily_Balance__c,
                loan__Bill_Cycle_End_Date__c,
                loan__Bill_Cycle_Start_Date__c,
                loan__Closing_Balance__c,
                loan__Fees_Billed__c,
                loan__Fees_Due__c,
                loan__Fees_Paid__c,
                loan__Interest_Due__c,
                loan__Opening_Balance__c,
                loan__Payoff_As_Of_Previous_Bill__c,
                loan__Previous_Bill_Amount__c,
                loan__Satisfied_With_Tolerance__c,
                loan__Total_Amount_Disbursed__c,
                loan__Total_Payments_Received__c,
                loan__Next_Due_Date_Without_Holiday_Treatment__c,
                loan__TDS_Amount_Due__c,
                loan__TDS_Paid_Amount__c,
                loan__TDS_Percentage__c,
                loan__Total_Fees_Waived__c,
                loan__Total_Interest_Waived__c,
                External_Id__c,
                isMigrated__c,
                ToBeDeleted__c
                FROM loan__Loan_account_Due_Details__c
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
