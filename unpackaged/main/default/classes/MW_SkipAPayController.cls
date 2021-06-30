@RestResource(urlMapping='/skipapay/')
global with sharing class MW_SkipAPayController {
	@HttpPost
	global static void SkipAPayController() {
		RestResponse res = RestContext.response;
		try {
			RestRequest req = RestContext.request;
			Id loanId;
			Integer numberOfSkips;
			Map<String, Object> reqParams = (Map<String, Object>) JSON.deserializeUntyped(
				req.requestBody.toString()
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

			ForBearanceLoanHelper helper = new ForBearanceLoanHelper(
				loan,
				numberOfSkips
			);
			RestResponse temp = new RestResponse();
			temp = helper.rescheduleLoan(new Map<String, String>());
			res.statusCode = temp.statusCode;
			res.responseBody = temp.responseBody;

		} catch (Exception e) {
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
