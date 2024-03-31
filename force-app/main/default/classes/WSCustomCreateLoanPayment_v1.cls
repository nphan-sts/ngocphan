@RestResource(urlMapping='/v1/CustomcreateLoanPaymentTransaction/*')
global class WSCustomCreateLoanPayment_v1 {
    /*
        To create a LPT, following parameters : 
        * @param loanAccount               The loan account for which the transaction is being passed
        * @param paymentMode               Payment mode, if null, ACH will be applied
        * @param transactionDate           Payment transaction date
        * @param transactionAmount         LPT amount
        * @param principal                 When manual payment - specify principal amount.
        * @param interest                  When manual payment - specify interest amount.
        * @param fees                      When manual payment - specify fees amount.
        * @param manualPayment             Indicate true if manual payment is to be made.
        * @param installmentPayment        Indicate true if it is an installment payment.
        * @param payoff                    Indicate as true if it is a payoff - future use - not currently handled.
        * @param prepaymentPenalty         Prepayment penalty amount - future use - not currently handled.
        
        Other optional parameters :
        * @param accountId                 user account ID
        * @param smsToken                  SMS token to be verified
        * @param smsUniqueId               unique ID related to SMS
        * @param ipAddress                 IP address
    */
    
    @HttpPost
    global static Response createLoanPayment() {
        Response res = new Response();
        RestRequest req = RestContext.request;
        RestResponse restRes = RestContext.response;
        
        RequestBodyParser.RequestBodyParams reqParams = RequestBodyParser.getJsonParamsFromRequest(req);
        if(reqParams == null) {
            res.errorMessage = 'Unable to Parse';
            res.errorCode = 'INVALID_INPUT';
            res.status = 'ERROR';
            restRes.statuscode = 400;
            return res;
        }
        
        Map<String, Object> params = reqParams.getParams();
        
        //Parameters - all : 
        Id loanAccount;
        Id paymentMode;
        String datePassed;
        Decimal transactionAmount;
        Decimal principal;
        Decimal interest;
        Decimal fees;
        Boolean manualPayment;
        Boolean installmentPayment;
        Boolean payoff;
        Decimal prepaymentPenalty;
        
        String accountId;
        String smsToken;
        String smsUniqueId;
        String ipAddress;
    
        try{
            loanAccount = params.get('loanAccount') != null ? (String)params.get('loanAccount') : null;
            paymentMode = params.get('paymentMode')!= null ? (String)params.get('paymentMode') : null;
            datePassed = params.get('transactionDate') != null ? (String)params.get('transactionDate') : null;
            transactionAmount = params.get('transactionAmount') != null ? (Decimal)params.get('transactionAmount') : null;
            principal = params.get('principal') != null ? (Decimal)params.get('principal') : null;
            interest = params.get('interest') != null ? (Decimal)params.get('interest') : null;
            fees = params.get('fees') != null ? (Decimal)params.get('fees') : null;
            manualPayment = params.get('manualPayment') != null ? (Boolean)params.get('manualPayment') : false;
            installmentPayment = params.get('installmentPayment') != null ? (Boolean)params.get('installmentPayment') : false;
            payoff = params.get('payoff') != null ? (Boolean)params.get('payoff') : false;
            prepaymentPenalty = params.get('prepaymentPenalty') != null ? (Decimal)params.get('prepaymentPenalty') : null;
            
            accountId = params.get('accountId') != null ? (String)params.get('accountId') : null;
            smsToken = params.get('smsToken') != null ? (String)params.get('smsToken') : null;
            smsUniqueId = params.get('smsUniqueId') != null ? (String)params.get('smsUniqueId') : null;
            ipAddress = params.get('ipAddress') != null ? (String)params.get('ipAddress') : null;
        }
        catch (Exception e) {
            res.errorMessage = e.getMessage();
            res.errorCode = 'INVALID_INPUT';
            res.status = 'ERROR';
            restRes.statuscode = 400;
            return res;
        }
        
        Date transactionDate;
        
        try {
            peer.WSSMSService smsService= new peer.WSSMSService();   
             if(accountId != null && smsToken != null && smsUniqueId != null && ipAddress != null) {
                 if(!smsService.verifySms(accountId, smsToken, smsUniqueId)){
                    res.errorCode = smsService.smsErrorCode;
                    res.status = 'Error';
                    return res;
                }
            }
            
            if (datePassed != null) {
                transactionDate = Date.valueOf(datePassed);
            }
            else {
                loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
                transactionDate = util.getCurrentSystemDate();                
            }
        }
        catch (Exception e) {
            res.errorCode = 'INVALID_INPUT';
            res.status = e.getMessage();
            return res;
        }
        
        if(paymentMode == null) {
            paymentMode = [SELECT Id FROM loan__Payment_Mode__c WHERE Name = 'ACH'].Id;
        }
        
        //No need to validate existance, CL Loan will do that. 
        if(loanAccount == null) {
            throw new peer.MarketPlaceException('Loan Account cannot be null.');
        }
        loan__Org_Parameters__c orgParams = loan__Org_Parameters__c.getInstance();
        try{
            CustomFractionalizationAPI3 obj = new CustomFractionalizationAPI3();
            loan__Loan_Payment_Transaction__c lpt = obj.createLoanPayment(loanAccount,
                                                                          paymentMode,
                                                                          transactionDate,
                                                                          transactionAmount,
                                                                          principal,
                                                                          interest,
                                                                          fees,
                                                                          manualPayment,
                                                                          installmentPayment,
                                                                          payoff,
                                                                          prepaymentPenalty); 
            if(smsUniqueId != null && !orgParams.peer__Disable_SMS_Verification__c){
                lpt.peer__Verification__c = smsUniqueId;
                update lpt;
            }                                                     
            //res.content.add(lpt);
            res.status = 'SUCCESS';
            return res;
        }
        catch(Exception e) {
            System.debug('Trace :: ' + e.getStackTraceString());
            res.errorCode = 'API_EXCEPTION';
            res.status = e.getMessage();
        }
        return res;
    }
}