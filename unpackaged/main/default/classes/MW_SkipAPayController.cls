/*****************************************************************************
  
    *  This Endpoint for processing skip a pay
    *  /* ****************Modification History*****************************************************************
    
    * Modified by      Date            JIRA number
    *  Mohan Kiran 	 2021/09/09	   LSP-292-Processing skip a pay for good standing and bad standing loans coming from callouts.
    * 
    ******************Modification History*****************************************************************
    *****************************************************************************/

@RestResource(urlMapping='/skipapay/')
global with sharing class MW_SkipAPayController {
    @HttpPost
    global static void SkipAPayController() {
        
                loan__Batch_Process_Log__c batchLogReq = new loan__Batch_Process_Log__c();
                loan__Batch_Process_Log__c batchLogRes = new loan__Batch_Process_Log__c();
        

        boolean isFromApiCallout; // LSP-292 Added for Skip a pay enhancement. For bad standing loans. only when skip a pay is called from API the skip a pay should be processed.
        
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        try {
            RestRequest req = RestContext.request;
            Id loanId;
            Integer numberOfSkips;
            Map<String, Object> reqParams = (Map<String, Object>) JSON.deserializeUntyped(
                req.requestBody.toString()  // insert batch record with request
            );
            if (
                reqParams.get('loanId') == null ||
                reqParams.get('numberOfSkips') == null
            ) {
                
                res.statusCode = 404;
                res.responseBody = Blob.valueOf('both LoanId and numberOfSkips is required');
            }
            
            loanId = (Id) reqParams.get('loanId');
            numberOfSkips = (Integer) reqParams.get('numberOfSkips');
            
             		batchLogReq.loan__Log_Level__c = 'INFO';
                    batchLogReq.loan__Message__c = 'The Parameters passed for Skip a Pay from member portal'+reqParams;                
                    batchLogReq.loan__Batch_Id__c = 'MW_SkipAPayController';
                    insert batchLogReq;
            
            loan__Loan_Account__c loan = [
                SELECT
                id,
                Name,
                lead_Guid__c,
                loan__First_Installment_Date__c,
                Application__r.genesis__Monthly_Debt_Payments__c,
                loan__Payment_Amount__c,
                loan__Loan_Status__c,
                loan__Accrual_Start_Date__c,
                Application__r.Loan_Origination_Date__c,
                loan__Last_Installment_Date__c,
                loan__Interest_Rate__c,
                loan__Frequency_of_Loan_Payment__c,
                loan__Pmt_Amt_Cur__c,
                loan__Next_Installment_Date__c,
                loan__Previous_Installment_Date__c,
                loan__Maturity_Date_Current__c,
                loan__Disbursal_Date__c,
                loan__Term_Cur__c,
                Skipped_a_pay_Date__c,
                Skipped_a_Pay__c,
                U_LoanModTermExt__c,
                loan__Oldest_Due_Date__c,
                U_LoanModForbearance__c,
                Hardship_New_Maturity_Date__c,
                U_LoanModForbearDt__c,
                Hardship_Request_Date__c,
                (
                    SELECT id, name, loan__Is_Archived__c, loan__Due_Date__c
                    FROM loan__Repayment_Schedule__r
                ),
                (SELECT id, name FROM loan__Repayment_Plan__r),
                CPD_Reason__c,
                CPD_Expire_Date__c
                FROM loan__Loan_Account__c
                WHERE Id = :loanId
                LIMIT 1
            ];
            system.debug('>>>>>>>>>>>>>>>>>>>>> loan.id' + loan.id);
            /*LSP-292 START */
            isFromApiCallout = true;
            ForBearanceLoanHelper helper = new ForBearanceLoanHelper(
                loan,
                numberOfSkips,
                isFromApiCallout
            );
            /*END-LSP-292*/
            RestResponse temp = new RestResponse();
            temp = helper.rescheduleLoan(new Map<String, String>());
            res.statusCode = temp.statusCode;
            res.responseBody = temp.responseBody;
            
            
        } catch (Exception e) { //add batch log records here
            	    batchLogRes.loan__Log_Level__c = 'ERROR';
                    batchLogRes.loan__Message__c = 'Error Message'+res.responseBody;                
                    batchLogRes.loan__Batch_Id__c = 'MW_SkipAPayController';
                    insert batchLogRes;
            
            System.debug(logginglevel.error, 'line number' + e.getLineNumber());
            System.debug(
                logginglevel.error,
                'error stackTrace' + e.getStackTraceString()
            );
            
            res.statusCode = 500;
            res.responseBody =  Blob.valueOf(e.getMessage());
        }
    }
}