@RestResource(urlMapping='/lpt/contract-id/*')
global with sharing class MW_RetrieveLptByContractId {
    @HttpGet
    global static void MW_RetrieveLptByContractId() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            String contractId = req.params.get('contract-id');
            if (String.isBlank(contractId)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('contract id is required');
                return;
            }
            List<loan__Loan_Payment_Transaction__C> lpts = [
                SELECT
                Id,
                Name,
                CreatedDate,
                CreatedById,
                LastModifiedDate,
                LastModifiedById,
                loan__Loan_Account__c,
                loan__ACH_Filename__c,
                loan__Affected_Installment_Ids__c,
                loan__Balance__c,
                loan__Balance_s_Snapshot__c,
                loan__Bank_Name__c,
                loan__Borrower_Email__c,
                loan__Check__c,
                loan__Cheque_Date__c,
                loan__Cheque_Number__c,
                loan__Cleared__c,
                loan__Clearing_Date__c,
                loan__Consolidated_Loan_Payment__c,
                loan__Custom_Logic__c,
                loan__Dues_Snapshot__c,
                loan__Early_Payment__c,
                loan__Early_Total_Repayment_of_the_Loan__c,
                loan__Excess__c,
                loan__Fee_Snapshot__c,
                loan__Fees__c,
                loan__Id__c,
                loan__Interest__c,
                loan__Late_Charge_Interest__c,
                loan__Late_Charge_Principal__c,
                loan__Loan_Snapshot__c,
                loan__Manual_Payment__c,
                loan__Missed_Loan_Installment__c,
                loan__Other_Charges_Interest__c,
                loan__Other_Charges_Principal__c,
                loan__Paid_to_Broker_Reversed__c,
                loan__Paid_to_Broker__c,
                loan__Paid_to_Investor_Reversed__c,
                loan__Paid_to_Investor__c,
                loan__Partial_Payment_del__c,
                loan__Payment_Application_Mode__c,
                loan__Payment_Mode__c,
                loan__Principal__c,
                loan__Receipt_Date__c,
                loan__Receipt_ID__c,
                loan__Refinance_Transaction__c,
                loan__Rejected__c,
                loan__Rejection_Reason__c,
                loan__Reversal_Reason__c,
                loan__Reversed__c,
                loan__Sent_To_ACH_On__c,
                loan__Sent_to_ACH__c,
                loan__Skip_Validation__c,
                loan__Total_Charges_Interest__c,
                loan__Total_Charges_Principal__c,
                loan__Transaction_Amount__c,
                loan__Transaction_Date__c,
                loan__Transaction_Time__c,
                loan__Write_Off_Recovery_Payment__c,
                loan__Cleared_Reversal_Txn_Count__c,
                loan__Applied_Spread__c,
                loan__Archived__c,
                loan__Automated_Payment_Setup__c,
                loan__Dependent_Payment_Transaction__c,
                loan__Force_No_Loan_Payoff__c,
                loan__IOA__c,
                loan__Interest_Rate__c,
                loan__Internal_Accounting_Generated__c,
                loan__Investor_Rebate_Amount_On_Payoff__c,
                loan__Investor_Rebate_Amount_On_Refinance__c,
                loan__Investor_Rebate_Amount_On_Writeoff__c,
                loan__Loan_Payment_Spread__c,
                loan__Master_Archive_Object__c,
                loan__Number_Of_Bills_Waived__c,
                loan__Payoff_Balance__c,
                loan__Protect_Principal__c,
                loan__Rebate_Amount__c,
                loan__Rejection_Date__c,
                loan__Retried__c,
                loan__Retry_Attempt_Number__c,
                loan__Retry_Attempt_for__c,
                loan__Retry_On__c,
                loan__Summary_Record_Id__c,
                loan__Summary__c,
                loan__protect_interest__c,
                loan__waived__c,
                peer__BTransaction_Hash__c,
                peer__Bank_Reference__c,
                peer__Bank_Statement_Date__c,
                peer__Bank_Statement_Exception__c,
                peer__Loan_Cancellation__c,
                peer__Verification__c,
                peer__Verified_From_Bank_Statement__c,
                loan__Closure_Tolerance_Payment__c,
                loan__Installment_Date__c,
                loan__Installment_Payment__c,
                loan__Payment_Type__c,
                loan__Rebate_Payment__c,
                loan__Reschedule_Threshold_Crossed__c,
                loan__Transaction_Creation_Date__c,
                Original_LPT_Reference__c,
                Payment_transaction_external_id__c,
                loan__Actual_TDS__c,
                loan__Backdated_Reschedule_Required__c,
                loan__Deposit_Snapshot__c,
                loan__Deposit__c,
                loan__Expected_TDS__c,
                loan__Ipt_Snapshot__c,
                loan__Product_Code__c,
                loan__Receipt_Amount__c,
                Principal_without_Reversal__c,
                Principal_with_reversal__c,
                Sum_Principal_Payment_Amount__c,
                Total_Interest__c,
                Clearing_issue_fixed__c,
                Posted_Date__c,
                Same_Clearing_date__c,
                createcreateddategreddategreatertrandate__c,
                Clearing_Date__c,
                External_Id__c,
                LAPro_Posted_Date__c,
                ToBeDeleted__c,
                loan_Is_Migrated__c,
                loan_Migrated_Reversal_Date__c,
                UpdatedByHMMW__c,
                updatedClearingDate__c,
                Routing_Hash_Issue__c,
                Custom_Reverse__c,
                Payments_generated_and_mapped_to_Nacha__c,
                payment_not_reposted__c
                FROM loan__Loan_Payment_Transaction__C
                WHERE loan__Loan_Account__c = :contractId 
            ];
             
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(lpts));
        }
        catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(e.getMessage());
        }
    }
}