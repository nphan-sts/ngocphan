@RestResource(urlMapping='/repayment-schedule/contract-id/*')
global with sharing class MW_RetrieveRSbyContractId {
    @HttpGet
    global static void MW_RetrieveRSbyContractId() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            String contractId = req.params.get('contract-id');
            if (String.isBlank(contractId)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('contract id is required');
                return;
            }

            List<Loan__Repayment_Schedule__c> repaymentSchedules = [
                SELECT
                Id,
                ReplayId,
                Name,
                CreatedDate,
                CreatedById,
                LastModifiedDate,
                LastModifiedById,
                loan__Loan_Account__c,
                loan__Balance__c,
                loan__Barcode_Subtype__c,
                loan__Barcode_Type__c,
                loan__Date_Paid__c,
                loan__Due_Amount__c,
                loan__Due_Date__c,
                loan__Due_Interest_On_Overdue__c,
                loan__Due_Interest__c,
                loan__Due_Principal__c,
                loan__Id__c,
                loan__Installment_Snapshot__c,
                loan__Interest_Accrued_Not_Due__c,
                loan__Is_Archived__c,
                loan__Is_Billed__c,
                loan__Is_Partially_Paid__c,
                loan__Paid_Fees__c,
                loan__Paid_Interest_On_Overdue__c,
                loan__Paid_Interest__c,
                loan__Paid_Principal__c,
                loan__Paid_Total__c,
                loan__Past_Due_Date__c,
                loan__Total_Installment__c,
                loan__Transaction_Amount__c,
                loan__Unpaid_Fees__c,
                loan__Unpaid_Installment__c,
                loan__Unpaid_Interest__c,
                loan__Unpaid_Overdue_Interest__c,
                loan__Unpaid_Principal__c,
                loan__isPaid__c,
                loan__Total_Due_Fees__c,
                loan__Total_Paid_Fees__c,
                loan__Archived__c,
                loan__Is_Posted__c,
                loan__Loan_Disbursal_Transaction__c,
                loan__Master_Archive_Object__c,
                loan__Summary_Record_Id__c,
                loan__Summary__c,
                loan__Waived_Interest__c,
                loan__Interest_Rounding_Error__c,
                loan__Due_Fee1__c,
                loan__Is_Fee_Posted__c,
                loan__TDS_Amount_Paid__c,
                loan__TDS_Amount__c,
                External_Id__c,
                isBilledwasUnchecked__c,
                isDeleted
                FROM Loan__Repayment_Schedule__c
                WHERE loan__Loan_Account__c = :contractId 
            ];
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(repaymentSchedules));
        }
        catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(e.getMessage());
        }
    }
}
