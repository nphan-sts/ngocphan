/* ****************Modification History*****************************************************************
 * Modified by      Date            JIRA number
 *    Pallavi       2020/01/14    LOS-225 Add installment payment flag check logic to webservice in CLS
 *    Pallavi       2020/01/27    LOS-28(Remove references to InvestorAccount field on CL contract)
 *    Neha          2020/11/18    CRM-845
 * 	  Anusha		2021/03/3	  LSP-186 LAI-00076377 - error message from CLS lately for payments posted via the API CLS case #02613860
 ******************Modification History*****************************************************************/
@RestResource(urlMapping='/OTPOMBPEndpoint/*')
global class WSSetupAPS {
    
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
        
        Date debitDate;
        Date recurringACHEndDate;
        Date recurringACHStartDate;
        Date setupDate;
        Boolean installmentPayment;
        
        List<loan__Loan_Account__c> loanAccountsList = [Select Id, Name, loan__Maturity_Date_Current__c, 
                                                        loan__Contact__c, loan__Account__c, loan__Last_Accrual_Date__c, 
                                                        loan__Product_Type__c
                                                        from loan__loan_account__c
                                                        where lead_Guid__c =: leadId];
        if (loanAccountsList.size() == 0) {
            res = new Response(peer.Constants.ERROR, peer.Constants.INVALID_INPUT, 'Loan Account Not found');
            restRes.statusCode = peer.Constants.HTTP_BAD_REQUEST;
            return res;
        }
        
        loan__Loan_Account__c loanAccount = loanAccountsList[0];
        
        
        // Debit Date is mandatory.
        if(params.get('debitDate') == null) {
            res = new Response(peer.Constants.ERROR, peer.Constants.INVALID_INPUT,'ACH Debit Date is Null');
            restRes.statusCode = peer.Constants.HTTP_BAD_REQUEST;
            return res;
        }
        
        // Payment Mode validation check.
        if(isMultiplePaymentMethodEnabled && params.get('paymentModeName') == null) {
            String message = 'Payment Mode Name is required.';
            res = new Response(peer.Constants.ERROR, peer.Constants.INVALID_INPUT, message);
            restRes.statusCode = peer.Constants.HTTP_BAD_REQUEST;
            return res;
        }
        
        // Amount Type validation check.
        if(isMultiplePaymentMethodEnabled && params.get('amountType') == null) {
            String message = 'Amount Type is required.';
            res = new Response(peer.Constants.ERROR, peer.Constants.INVALID_INPUT, message);
            restRes.statusCode = peer.Constants.HTTP_BAD_REQUEST;
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
            system.debug(LoggingLevel.Error, 'exception caught 1 : ' + e.getMessage() +e.getstacktraceString());
            String message = 'Unknown Exception : ' + e.getMessage();
            res = new Response(peer.Constants.ERROR, peer.Constants.INVALID_INPUT, message);
            restRes.statusCode = peer.Constants.HTTP_BAD_REQUEST;
            return res;
        }
        
        try {
            if(isMultiplePaymentMethodEnabled) {
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
                automatedPaymentSetup.loan__Loan_Payment_Spread__c = getPaymentSpreadId( manualSpreadName);
                
                if(manualSpreadName != NULL){
                    System.debug(logginglevel.error,'In IF :: manualSpreadName != NULL ');
                    automatedPaymentSetup.loan__Installment_Payment__c = installmentPayment;
                
                }else{
                    System.debug(logginglevel.error,'In ELSE :: manualSpreadName == NULL ');
                    automatedPaymentSetup.loan__Installment_Payment__c = updateInstallmentFlag(loanAccount.id, debitDate, transactionAmount);
                    
                }
                               
                /*                
                //LOS-225
                if(type.equalsIgnoreCase('ONE TIME') && (automatedPaymentSetup.loan__Loan_Payment_Spread__r.loan__Order_Of_Payment__c != 'Principal')
                  &&(automatedPaymentSetup.loan__Loan_Payment_Spread__r.loan__Order_Of_Payment__c != 'Interest'))  
                    automatedPaymentSetup.loan__Installment_Payment__c= true;
                else
                    automatedPaymentSetup.loan__Installment_Payment__c = installmentPayment;
                //LOS-225
                */
                
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
            }
        } catch (Exception e) {
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
    
    public static Id getPaymentSpreadId(String manualSpreadName) {
        if(String.isNotBlank(manualSpreadName)) {
            List<loan__Loan_Payment_Spread__c> pmtSpreads = [SELECT Id,Name,loan__Order_Of_Payment__c FROM loan__Loan_Payment_Spread__c WHERE Name = :manualSpreadName];
            if(pmtSpreads == null || pmtSpreads.size() == 0) {
                throw new APSException('Invalid Spread provided: ' + manualSpreadName);
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
        loan__Investor_Loan__c investor = [select id,name,loan__Account__c from loan__Investor_Loan__c where loan__Loan__c =: loanAccount.id and loan__Status__c = 'Active' limit 1];
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
                                    loan__Next_Due_Generation_Date__c,
                                    loan__Next_Installment_Date__c, 
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
                                    
        if(LA.loan__Loan_Status__c.equalsIgnoreCase('Active - Good Standing')
           && futureBill != NULL ){        
            installmentFlagValue = true;
            System.debug(logginglevel.error,'In IF ::' +installmentFlagValue);
        
        }else if(LA.loan__Loan_Status__c.equalsIgnoreCase('Active - Good Standing')
           && futureBill == NULL && LA.loan__Next_Due_Generation_Date__c <= txnDate
           && LA.loan__Next_Installment_Date__c > txnDate){
           installmentFlagValue = true;
            System.debug(logginglevel.error,'IN 1st ELSE IF ::' +installmentFlagValue);            
        
        }else if(LA.loan__Loan_Status__c.equalsIgnoreCase('Active - Bad Standing')
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
       
}