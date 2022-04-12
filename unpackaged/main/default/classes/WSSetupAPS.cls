/* ****************Modification History*****************************************************************
* Modified by      Date            JIRA number
*    Pallavi       2020/01/14    LOS-225 Add installment payment flag check logic to webservice in CLS
*    Pallavi       2020/01/27    LOS-28(Remove references to InvestorAccount field on CL contract)
*    Neha          2020/11/18    CRM-845
* 	  Anusha		2021/03/3	  LSP-186 LAI-00076377 - error message from CLS lately for payments posted via the API CLS case #02613860
* 	  Anusha		2021/05/11	  LSP-97  Support Manual Payers (+auto payers) Making Principal Only Payments
* 	  Anusha		2021/05/11	  LSP-224 Revisit installment flag logic - Payoff payment goes to excess or P/I instead closing the loan Case#: 02701590
* 	  Anusha		2021/05/13    LSP-223 Charged Off loans - Submit recover payment from Member Portal
* 	  Anusha		2021/08/23	  LSP-328.1 Changes to create payoff payments through webservice
*	  Anusha		2021/10/21	  LSP-328.2 Changes to map payoffLPT to NACHA
*	  Anusha		2021/11/09	  LSP-328.3 skipping transaction date validation on LPT object to allow future payoffpayment creation
*	  Anusha		2021/11/25	  LSP-328.4 Normal LPT should get created when transaction amount is less than todays payoff amount
*    Mohan Kiran    2021/12/30    LSP-245 Added code to capture every request and responses made to this endpoint to batch process log object in salesforce.
*	Bhavya Maliwal  2022/03/22    LSP-694 Added the code to filter out if the APS creation is for the Bill for which the Debit date lies under 
the pre bill days of the future bill which will get generated within the duration of APS creation and Debit Date.
******************Modification History*****************************************************************/

@RestResource(urlMapping='/OTPOMBPEndpoint/*')
global class WSSetupAPS {
    
    public static final String ERROR_RESPONSE = 'Error Response: ';
    
    @HttpPost
    global static Response createAPSSetup() {
        Response res = null;
        RestRequest req = RestContext.request;
        RestResponse restRes = RestContext.response;
        Boolean isLockBasedACHEnabled = false;
        Boolean isMultiplePaymentMethodEnabled = false;
        
        loan__ACH_Parameters__c achParameters = loan.CustomSettingsUtil.getACHParameters();
        if(!achParameters.loan__Use_Lock_Based_ACH__c && !achParameters.loan__Multiple_Payment_Method_Support__c) {
            String message = 'Either Lock Based ACH or Multiple Payment Method Support must be enabled to use this feature.';
            res = new Response(peer.Constants.ERROR, peer.Constants.INTERNAL_ERROR, message);
            restRes.statusCode = peer.Constants.HTTP_BAD_REQUEST;
            /*LSP-245*/
            
            createBatchProcessingLog('Error', Null, ERROR_RESPONSE+res);
            return res;
            
        } else if(achParameters.loan__Use_Lock_Based_ACH__c && achParameters.loan__Multiple_Payment_Method_Support__c
                  || !achParameters.loan__Use_Lock_Based_ACH__c && achParameters.loan__Multiple_Payment_Method_Support__c) {
                      isLockBasedACHEnabled = false;
                      isMultiplePaymentMethodEnabled = true;
                  } else if(achParameters.loan__Use_Lock_Based_ACH__c && !achParameters.loan__Multiple_Payment_Method_Support__c) {
                      isLockBasedACHEnabled = true;
                      isMultiplePaymentMethodEnabled = false;
                  }
        
        loan__Org_Parameters__c loanOrgParams = loan.CustomSettingsUtil.getOrgParameters();
        Boolean isNewSpreadEnabled = loanOrgParams.loan__Enable_New_Spread_Option__c;
        
        //Decide if Loan Account is to be picked directly from Loan Account's ID or using Name.
        /*String fieldName = peer__CustomSettingsUtil.getAPIConfig().loan__Loan_Id_Field__c;
if(fieldName == null){
fieldName = Constants.DEFAULT_ID;
}*/
        
        /*String leadId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1,req.requestURI.length());
// Loan Account validation check.
System.debug(leadId+'  '+req.requestURI);
*/
        
        RequestBodyParser.RequestBodyParams reqParams = RequestBodyParser.getJsonParamsFromRequest(req);
        if(reqParams == null) {
            res = new Response(peer.Constants.ERROR, peer.Constants.INVALID_INPUT, 'Unable to parse request Params');
            restRes.statusCode = peer.Constants.HTTP_BAD_REQUEST;
            
            // LSP-245 - Bad Request
            
            createBatchProcessingLog('Error', Null , ERROR_RESPONSE+res); 
            
            // END- LSP-245
            return res;
        }
        
        Map<String, Object> params = reqParams.getParams();
        
        // Expected input attributes.
        Id loanAccountId;
        Id bankAccountId;
        String leadId = params.get('leadGuid') != null ? (String) params.get('leadGuid') : null;
        System.debug('leadId'+leadId);
        if(leadId == null) {
            res = new Response(peer.Constants.ERROR, peer.Constants.INVALID_INPUT, 'Lead ID is null');
            restRes.statusCode = peer.Constants.HTTP_BAD_REQUEST;
            /*LSP-245 - Lead id null error*/
            
            createBatchProcessingLog('Error',Null, ERROR_RESPONSE+res); 
            
            /*END- LSP-245*/
            return res;
        }
        Boolean isActive;
        Decimal transactionAmount;
        Decimal feeAmount;
        
        String amountType;
        String frequency;
        String paymentModeName;
        String type;
        String manualSpreadName;
        String chargeoffspreadname = 'Default Write Off Recovery Spread';//LSP-223
        
        Date debitDate;
        Date recurringACHEndDate;
        Date recurringACHStartDate;
        Date setupDate;
        Boolean installmentPayment;
        Boolean payoffPayment = false;//LSP-328.1
        
        
        
        /*LSP-245 - Member portal input(Info)*/
        
        createBatchProcessingLog('Info',leadId , 'Request Information: '+reqParams);
        
        /*END- LSP-245*/
        
        
        List<loan__Loan_Account__c> loanAccountsList = [Select Id, Name,loan__Loan_Status__c,loan__Maturity_Date_Current__c, //LSP-223 (added loan__Loan_Status__c)
                                                        loan__Contact__c, loan__Account__c, loan__Last_Accrual_Date__c, 
                                                        loan__Product_Type__c,loan__Pay_Off_Amount_As_Of_Today__c,loan__Write_off_Tolerance_Amount__c //LSP-328.1 (added loan__Pay_Off_Amount_As_Of_Today__c,loan__Write_off_Tolerance_Amount__c)
                                                        from loan__loan_account__c
                                                        where lead_Guid__c =: leadId];
        if (loanAccountsList.size() == 0) {
            res = new Response(peer.Constants.ERROR, peer.Constants.INVALID_INPUT, 'Loan Account Not found');
            restRes.statusCode = peer.Constants.HTTP_BAD_REQUEST;
            
            createBatchProcessingLog('Error',leadId , ERROR_RESPONSE+res);
            
            return res;
        }
        
        loan__Loan_Account__c loanAccount = loanAccountsList[0];
        
        
        // Debit Date is mandatory.
        if(params.get('debitDate') == null) {
            res = new Response(peer.Constants.ERROR, peer.Constants.INVALID_INPUT,'ACH Debit Date is Null');
            restRes.statusCode = peer.Constants.HTTP_BAD_REQUEST;
            
            /*Start-LSP-245*/
            createBatchProcessingLog('Error', leadId , ERROR_RESPONSE+res);
            /*END-LSP-245*/
            
            return res;
        }
        
        // Payment Mode validation check.
        if(isMultiplePaymentMethodEnabled && params.get('paymentModeName') == null) {
            String message = 'Payment Mode Name is required.';
            res = new Response(peer.Constants.ERROR, peer.Constants.INVALID_INPUT, message);
            restRes.statusCode = peer.Constants.HTTP_BAD_REQUEST;
            /*LSP-245*/
            createBatchProcessingLog('Error',leadId,ERROR_RESPONSE+res);
            /*END-LSP-245*/
            return res;
        }
        
        // Amount Type validation check.
        if(isMultiplePaymentMethodEnabled && params.get('amountType') == null) {
            String message = 'Amount Type is required.';
            res = new Response(peer.Constants.ERROR, peer.Constants.INVALID_INPUT, message);
            restRes.statusCode = peer.Constants.HTTP_BAD_REQUEST;
            /*LSP-245*/
            createBatchProcessingLog('Error',leadId , ERROR_RESPONSE+res);
            return res;
        }
        
        
        //get the spread name. We would use this for searching spread-id
        if(isMultiplePaymentMethodEnabled && isNewSpreadEnabled) {
            manualSpreadName = (String) params.get('manualSpreadName');
        }
        
        try {
            bankAccountId = params.get('bankAccountId') != null ? (String) params.get('bankAccountId') : null;
            
            isActive = params.get('isActive') != null ? (Boolean) params.get('isActive') : true;
            transactionAmount = params.get('transactionAmount') != null ? (Decimal) params.get('transactionAmount') : null;
            feeAmount = params.get('feeAmount') != null ? (Decimal) params.get('feeAmount') : null;// Used for older One Time ACH only.
            
            type = params.get('type') != null ? (String) params.get('type') : null;
            paymentModeName = (params.get('paymentModeName')!=null?getPaymentMode(leadId):null);
            frequency = (String) params.get('frequency');
            amountType = (String) params.get('amountType');
            installmentPayment = params.get('installmentOmbp') != null ? (Boolean) params.get('installmentOmbp') : false;
            
            debitDate = Date.valueOf((String) params.get('debitDate'));
            payoffPayment = params.get('payoffPayment') != null ? (Boolean)params.get('payoffPayment'): false; //LSP-328.1
            
            System.debug(LoggingLevel.ERROR, 'about to check debit date validation');
            
            //LSP-186 - start
            //Would like to explicitly check for LOAN, LOC and FLEXIBLE_AMZ. But the Loan package is not upgraded yet
            /*if(!loanAccount.loan__Product_Type__c.equalsIgnoreCase(loan.LoanConstants.AMZ)
&& (type != null && type.equalsIgnoreCase(loan.LoanConstants.ONE_TIME))
&& debitDate  < loanAccount.loan__Last_Accrual_Date__c) { 
String message = 'Debit Date for One Time ACH is before Last  Accrual Date';
res = new Response(peer.Constants.ERROR, peer.Constants.INVALID_INPUT, message);
restRes.statusCode = peer.Constants.HTTP_BAD_REQUEST;
return res;
}
System.debug(LoggingLevel.ERROR, 'checked debit date validation complete');*/
            //LSP-186 - end
            
            recurringACHStartDate = params.get('recurringACHStartDate') != null ? Date.valueOf((String) params.get('recurringACHStartDate')) : debitDate;
            recurringACHEndDate = params.get('recurringACHEndDate') != null ? Date.valueOf((String) params.get('recurringACHEndDate')) : loanAccount.loan__Maturity_Date_Current__c;
            setupDate = params.get('setupDate') != null ? Date.valueOf((String) params.get('setupDate')) : debitDate;
            
        } catch(Exception e) {
            
            createBatchProcessingLog('Error',leadId,ERROR_RESPONSE+ e.getMessage() + 'Exception caused at line number -'+e.getLineNumber() + 'at the apex class : '+e.getStackTraceString());
            
            system.debug(LoggingLevel.Error, 'exception caught 1 : ' + e.getMessage() +e.getstacktraceString());
            String message = 'Unknown Exception : ' + e.getMessage();
            res = new Response(peer.Constants.ERROR, peer.Constants.INVALID_INPUT, message);
            restRes.statusCode = peer.Constants.HTTP_BAD_REQUEST;
            return res;
        }
        
        try {
            if(isMultiplePaymentMethodEnabled) {
                //LSP-328.1 - start
                if(payoffPayment == true){//Create payoff payment and inactive one time APS if the request has payoffPayment flag true                    
                    if(loanAccount.loan__Pay_Off_Amount_As_Of_Today__c != null && loanAccount.loan__Write_off_Tolerance_Amount__c != null){
                        //LSP-328.2 Changes to map payoffLPT to NACHA - start
                        loan__Automated_Payment_Setup__c automatedPaymentSetup = new loan__Automated_Payment_Setup__c();
                        automatedPaymentSetup.loan__CL_Contract__c = loanAccount.id;
                        automatedPaymentSetup.loan__Active__c = false;
                        automatedPaymentSetup.loan__Type__c = 'ONE TIME';
                        automatedPaymentSetup.loan__Bank_Account__c = getBankAccountId(bankAccountId,loanAccount);
                        automatedPaymentSetup.loan__Frequency__c = frequency;
                        automatedPaymentSetup.loan__Payment_Mode__c = getPaymentModeId(paymentModeName);
                        automatedPaymentSetup.loan__Amount_Type__c = amountType;
                        automatedPaymentSetup.loan__Transaction_Amount__c = transactionAmount;
                        automatedPaymentSetup.loan__Debit_Date__c = debitDate;
                        automatedPaymentSetup.loan__Recurring_ACH_Start_Date__c = recurringACHStartDate;
                        automatedPaymentSetup.loan__Recurring_ACH_End_Date__c = recurringACHEndDate;
                        automatedPaymentSetup.loan__Setup_Date__c = setupDate; 
                        automatedPaymentSetup.loan__Installment_Payment__c = false;
                        automatedPaymentSetup.loan__Loan_Payment_Spread__c = getPaymentSpreadId( manualSpreadName);
                        insert automatedPaymentSetup;
                        
                        //LSP-328.2 Changes to map payoffLPT to NACHA - end                            
                        loan__loan_payment_transaction__c payoffLpt = new loan__loan_payment_transaction__c();
                        payoffLpt.loan__loan_Account__c = loanAccount.Id;
                        payoffLpt.loan__Transaction_Date__c = debitDate;                            
                        payoffLpt.loan__Transaction_Amount__c = transactionAmount;
                        payoffLpt.loan__payment_Mode__c = getPaymentModeId(paymentModeName);
                        payoffLpt.loan__Installment_Payment__c = false;
                        payoffLPT.loan__Automated_Payment_Setup__c = automatedPaymentSetup.id;//LSP-328.2 attaching newly created inactive APS to payoff LPT
                        payoffLPT.loan__Skip_Validation__c = true;//LSP-328.3 skipping transaction date validation on LPT object
                        
                        if(transactionAmount >= (loanAccount.loan__Pay_Off_Amount_As_Of_Today__c - loanAccount.loan__Write_off_Tolerance_Amount__c)){    
                            payoffLpt.loan__Early_Total_Repayment_of_the_Loan__c = true;
                        }else{
                            //LSP-328.4 - start
                            payoffLpt.loan__Early_Total_Repayment_of_the_Loan__c = false;
                            payoffLpt.loan__Loan_Payment_Spread__c = getPaymentSpreadId(manualSpreadName);
                            payoffLpt.loan__Installment_Payment__c = updateInstallmentFlag(loanAccount.id, debitDate,transactionAmount);
                            payoffLPT.Payoff_Rejection_Reason__c = 'Transaction amount: '+transactionAmount +' is not sufficient to payoff the loan';
                            //LSP-328.4 - end
                        }
                        insert payoffLpt;
                        res = new Response(peer.Constants.SUCCESS, '', '');
                        res.contents.add(payoffLpt);
                        restRes.statuscode = peer.Constants.HTTP_OK;
                        //Whenever a request or response is made ,or an exception is caught in try catch block, HM has started following a routine to insert (request, response success details or exception details) in Batch Processing Log
                        
                        createBatchProcessingLog('INFO', leadId, 'Success Response: '+res);
                        return res;
                    }
                    res = new Response(peer.Constants.ERROR, '', 'Check if loan account has required information');
                    //Whenever a request or response is made ,or an exception is caught in try catch block, HM has started following a routine to insert (request, response success details or exception details) in Batch Processing Log
                    
                    createBatchProcessingLog('Error',leadId , ERROR_RESPONSE+res);
                    return res;
                }
                //LSP-328.1 - end
                
                // Second param paymentModeId is passed null. Because we are setting paymentModeName in setter method
                // from where Payment Mode Id will be fetched.
                /*PS-4350/LOS-192*/
                Integer count = 0;
                if(type.equalsIgnoreCase('RECURRING'))
                    count = [Select count() from loan__Automated_Payment_Setup__c where loan__CL_Contract__c =: loanAccount.id
                             AND loan__Active__c = true and loan__Type__c = 'RECURRING'];
                loan__Automated_Payment_Setup__c automatedPaymentSetup = new loan__Automated_Payment_Setup__c();
                
                if(count == 0){                    
                    /*PS-4350/LOS-192*/
                    automatedPaymentSetup.loan__CL_Contract__c = loanAccount.id;
                    automatedPaymentSetup.loan__Active__c = isActive;
                    automatedPaymentSetup.loan__Type__c = type;
                    automatedPaymentSetup.loan__Bank_Account__c = getBankAccountId(bankAccountId,loanAccount);
                    automatedPaymentSetup.loan__Frequency__c = frequency;
                    automatedPaymentSetup.loan__Payment_Mode__c = getPaymentModeId(paymentModeName);
                    automatedPaymentSetup.loan__Amount_Type__c = amountType;
                    automatedPaymentSetup.loan__Transaction_Amount__c = transactionAmount;
                    automatedPaymentSetup.loan__Debit_Date__c = debitDate;
                    automatedPaymentSetup.loan__Recurring_ACH_Start_Date__c = recurringACHStartDate;
                    automatedPaymentSetup.loan__Recurring_ACH_End_Date__c = recurringACHEndDate;
                    automatedPaymentSetup.loan__Setup_Date__c = setupDate;   
                    //LSP-223 (added a condition for charge off loans)
                    if(loanAccount.loan__Loan_Status__c.equalsIgnoreCase(loan.LoanConstants.LOAN_STATUS_CLOSED_WRITTEN_OFF)){
                        automatedPaymentSetup.loan__Loan_Payment_Spread__c = getPaymentSpreadId(chargeoffspreadname); 
                    }else{
                        automatedPaymentSetup.loan__Loan_Payment_Spread__c = getPaymentSpreadId( manualSpreadName);
                    } System.debug('automatedPaymentSetup.loan__Loan_Payment_Spread__c: '+automatedPaymentSetup.loan__Loan_Payment_Spread__c);
                    
                    if(manualSpreadName != NULL){
                        System.debug(logginglevel.error,'In IF :: manualSpreadName != NULL ');
                        automatedPaymentSetup.loan__Installment_Payment__c = installmentPayment;
                        
                    }else{
                        System.debug(logginglevel.error,'In ELSE :: manualSpreadName == NULL ');
                        automatedPaymentSetup.loan__Installment_Payment__c = updateInstallmentFlag(loanAccount.id, debitDate, transactionAmount);
                        
                    }                   
                    
                    //set Dates.
                    insert automatedPaymentSetup;
                    if(automatedPaymentSetup == null) {
                        System.debug(LoggingLevel.DEBUG, '-----Create Automated Payment Setup Error-----');
                        res = new Response(peer.Constants.ERROR, peer.Constants.UNKNOWN_EXCEPTION, '');
                        restRes.statusCode = peer.Constants.HTTP_INTERNAL_ERROR;
                        return res;
                    }
                } //PS-4350/LOS-192
                /*PS-4350/LOS-192*/
                if(count==0)
                    res = new Response(peer.Constants.SUCCESS, '', '');
                else
                    res = new Response(peer.Constants.ERROR, '', 'The contract already has an active APS'); 
                /*PS-4350/LOS-192*/
                res.contents.add(automatedPaymentSetup);
                restRes.statuscode = peer.Constants.HTTP_OK;
                
                /*LSP-245 - Success response*/
                
                createBatchProcessingLog('INFO', leadId , 'Success Response: '+res);
                /*END- LSP-245*/
            }
            
        }
        
        
        catch (Exception e) {
            
            createBatchProcessingLog('Error',leadId,ERROR_RESPONSE+ e.getMessage() + 'Exception caused at line number -'+e.getLineNumber() + 'at the apex class : '+e.getStackTraceString());
            
            
            system.debug(LoggingLevel.Error, 'exception caught 2 : ' + e.getMessage());
            res = new Response(peer.Constants.ERROR, peer.Constants.UNKNOWN_EXCEPTION, e.getMessage()+' at line number'+e.getLineNumber());
            restRes.statuscode = peer.Constants.HTTP_INTERNAL_ERROR;
            return res;
        }
        
        return res;
    }
    
    public static Id getPaymentModeId(String paymentModeName) {
        //[SELECT Id, Name FROM loan__Payment_Mode__c WHERE Name = :paymentModeName LIMIT 1];
        List<loan__Payment_Mode__c> paymentModesList = [SELECT Id, Name FROM loan__Payment_Mode__c WHERE Name = :paymentModeName LIMIT 1];
        if(paymentModesList.size() == 0) {
            throw new APSException('Invalid Payment Mode name: ' + paymentModeName);
        }
        
        return paymentModesList[0].Id;
        
    }
    
    public static Id getPaymentSpreadId(String paymentSpreadName) {//LSP-223 (generalized the parameter name)
        if(String.isNotBlank(paymentSpreadName)) {
            List<loan__Loan_Payment_Spread__c> pmtSpreads = [SELECT Id,Name,loan__Order_Of_Payment__c FROM loan__Loan_Payment_Spread__c WHERE Name = :paymentSpreadName];
            if(pmtSpreads == null || pmtSpreads.size() == 0) {
                throw new APSException('Invalid Spread provided: ' + paymentSpreadName);
            }
            return pmtSpreads.get(0).Id;
        }
        return null;
    }
    
    public static Id getBankAccountId(Id bankAccountId,loan__loan_account__c loanAccount) {
        System.debug(LoggingLevel.DEBUG, '-----Bank Account Id in setBankAccountID method: ' + bankAccountId);
        if(bankAccountId == null) {
            
            List<loan__Bank_Account__c> borrowerBanks = new List<loan__Bank_Account__c>();
            // Bank Account validation check.
            if(loanAccount.loan__Contact__c != null){
                //Security Fix : [SELECT Id FROM loan__Bank_Account__c WHERE loan__Contact__c= :loanAccount.loan__Contact__c AND loan__Active__c = true AND loan__Account_Usage__c = 'Borrower/Investor Account' limit 1];]
                borrowerBanks = [SELECT Id FROM loan__Bank_Account__c WHERE loan__Contact__c= :loanAccount.loan__Contact__c AND loan__Active__c = true AND loan__Account_Usage__c = 'Borrower/Investor Account' limit 1];
            }
            
            if(loanAccount.loan__Account__c != null){
                //Security Fix : SELECT Id FROM loan__Bank_Account__c WHERE loan__Account__c = :loanAccount.loan__Account__c AND loan__Active__c = true AND loan__Account_Usage__c = 'Borrower/Investor Account' limit 1];
                
                borrowerBanks = [SELECT Id FROM loan__Bank_Account__c WHERE loan__Account__c = :loanAccount.loan__Account__c AND loan__Active__c = true AND loan__Account_Usage__c = 'Borrower/Investor Account' limit 1];
            }
            
            if(borrowerBanks.size() == 0) {
                throw new APSException('No active bank account records found for this borrower.');
            }
            bankAccountId = borrowerBanks[0].Id;
        } else {
            // Verify if the Bank Account Id is a valid Id.
            List<loan__Bank_Account__c> bankAccountsList = [SELECT Id, loan__Active__c, loan__Account_Usage__c
                                                            FROM loan__Bank_Account__c
                                                            WHERE ID = :bankAccountId];
            if (bankAccountsList.size() == 0) {
                throw new APSException('Bank Account doesnot exists');
            }
            
            loan__Bank_Account__c bankAccount = bankAccountsList[0];
            System.debug(LoggingLevel.DEBUG, '-----Bank Account Fetched-----: ' + bankAccount);
            
            if (!bankAccount.loan__Active__c) {
                throw new APSException('Bank Account is not Active');
            }
            
            return bankAccount.Id;
        }
        return bankAccountId;
    }
    
    public static String getPaymentMode(String LeadId){
        
        loan__Automated_Payment_Configuration__c apc = null;
        
        loan__Loan_Account__c loanAccount = getloanAccountDetails(LeadId);
        
        /*LOS-28*/
        loan__Investor_Loan__c investor = [select id,name,loan__Account__c from loan__Investor_Loan__c where loan__Loan__c =: loanAccount.id and (loan__Status__c IN ('Active','Closed - Written Off')) limit 1];//LSP-223
        /*LOS-28*/
        
        try{
            apc = [Select id,name, loan__Payment_Mode__r.Name From loan__Automated_Payment_Configuration__c Where loan__Bank_Account__r.loan__Account__c =:investor.loan__Account__c limit 1];  //LOS-28
        }
        catch(exception ex) {    
            loan__batch_process_log__c logs = new loan__batch_process_log__c(loan__Message__c='Error in assignToUnderwriterQueue:  '+ex.getlinenumber()+'Error: '+ex.getMessage() + loanAccount.name);             
            insert logs;             
            throw new ints.IntegrationException('NO APC FOUND FOR THIS INVESTOR');         
        }
        return apc.loan__Payment_Mode__r.Name;
    }
    
    public static loan__Loan_Account__c getloanAccountDetails(String LeadId) {
        loan__Loan_Account__c loanAcc = [select id, name, lead_Guid__c                      //Investor_Account__c  LOS-28
                                         from loan__Loan_Account__c where lead_Guid__c=:LeadId];
        
        
        return loanAcc;
    }
    
    global static boolean updateInstallmentFlag(Id contractID, Date txnDate, Decimal txnAmount){
        System.debug(logginglevel.error,'In updateInstallmentFlag :: ');
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        Date systemdate = util.getcurrentsystemdate();
        Boolean installmentFlagValue;
        loan__Loan_account_Due_Details__c futureBill;
        
        loan__loan_account__c LA = [select id,name,
                                    loan__Delinquent_Amount__c,
                                    loan__Loan_Status__c,
                                    loan__Oldest_Due_Date__c,//LSP-694
                                    loan__Next_Due_Generation_Date__c,
                                    loan__Next_Installment_Date__c, 
                                    loan__Last_Accrual_Date__c,//LSP-223 added LAD
                                    (select id,name,
                                     loan__Due_Date__c,loan__Transaction_Date__c 
                                     from loan__Dues_Details__r
                                     where loan__Due_Date__c >: systemdate
                                     and loan__Due_Date__c >: txnDate
                                     and loan__Payment_Satisfied__c = False
                                     and loan__DD_Primary_Flag__c = true) 
                                    from loan__Loan_Account__c
                                    where id =: contractID];
        
        system.debug(logginglevel.error,' Loan Account :: '+LA);
        
        if (LA.loan__Dues_Details__r != NULL && LA.loan__Dues_Details__r.size() > 0){
            futureBill =  new loan__Loan_account_Due_Details__c();
            futureBill = LA.loan__Dues_Details__r[0];
            System.debug(logginglevel.error,'futureBill ::' +futureBill);
        }
        
        /*Installment payment logic:
* Any additional payment done, should go towards principal component and not to excess
* When borrower does payoff payment, the loan should get closed, it should not create excess transaction
* To support auto/manual payers to make principal only payments 
* When one time APS is created with debit date < LAD(when LAD > system date), then the installment flag should be true 
*/
        
        if(LA.loan__Loan_Status__c.equalsIgnoreCase('Active - Good Standing')
           && futureBill != NULL ){        
               installmentFlagValue = true;
               System.debug(logginglevel.error,'In IF ::' +installmentFlagValue);
               
           }
        //LSP-97 and LSP-224 - start
        else if((LA.loan__Loan_Status__c.equalsIgnoreCase('Active - Good Standing') && LA.loan__Last_Accrual_Date__c > systemdate)){
            installmentFlagValue = true;
            System.debug(logginglevel.error,'IF Future LAD  ::' +installmentFlagValue);            
        }//LSP-97 and LSP-224 - end
        else if(LA.loan__Loan_Status__c.equalsIgnoreCase('Active - Good Standing')
                && futureBill == NULL && LA.loan__Next_Due_Generation_Date__c <= txnDate
                && LA.loan__Next_Installment_Date__c > txnDate){
                    //LSP-694 start
                    installmentFlagValue =(LA.loan__Oldest_Due_Date__c >= txnDate);
                    //LSP-694 end
                    System.debug(logginglevel.error,'IN 1st ELSE IF ::' +installmentFlagValue);            
                }
        else if(LA.loan__Loan_Status__c.equalsIgnoreCase('Active - Bad Standing')
                && futureBill != NULL && txnAmount > LA.loan__Delinquent_Amount__c ){
                    installmentFlagValue = true;
                    System.debug(logginglevel.error,'IN 2nd ELSE IF ::' +installmentFlagValue);
                    
                }else if(LA.loan__Loan_Status__c.equalsIgnoreCase('Active - Bad Standing')
                         && futureBill == NULL && txnAmount > LA.loan__Delinquent_Amount__c 
                         && LA.loan__Next_Due_Generation_Date__c <= txnDate
                         && LA.loan__Next_Installment_Date__c > txnDate){
                             installmentFlagValue = true;
                             System.debug(logginglevel.error,'IN 3rd ELSE IF ::' +installmentFlagValue);
                             
                         }else{        
                             installmentFlagValue = false;
                             System.debug(logginglevel.error,'In ELSE ::' +installmentFlagValue);
                         }
        
        System.debug(logginglevel.error,'installmentFlagValue :: '+installmentFlagValue);        
        return installmentFlagValue;                            
    }
    
    public static void createBatchProcessingLog(string logLevel, string leadGuid, object messageDetails){
        
        loan__Batch_Process_Log__c batchLogMPInput = new loan__Batch_Process_Log__c();
        
        batchLogMPInput.loan__Origin__c = 'WSSetupAPS';
        batchLogMPInput.loan__Log_Level__c = logLevel;
        batchLogMPInput.loan__Batch_Id__c = 'LeadGuid : '+leadGuid;
        batchLogMPInput.loan__Message__c = ''+messageDetails;
        
        insert batchLogMPInput;
    }
    
}