/* ****************Modification History*****************************************************************
 * 
 * Modified by      		Date        JIRA number
 * 1.   Pallavi/Neha      2020/12/11  CRM-1056 CPD issue/Reverting issue (short-term fix) - Case #02430069 
 * 2.   Shakul            2022/07/18    LSP-864(Mapping lastPaymentDate to Active Maturity Date instead of Maturity Date)
 ******************Modification History*****************************************************************/
@RestResource(urlMapping='/ChangePaymentDate/*') 
global with sharing class WebServiceChangePaymentDate {
    
    public static loan__Loan_Account__c LAtobeUpdated;
    public static String CPDNote;
    
    global class Response {
        public String status;
        public String errorCode;
        public String errorMessage;
        public String successMessage;
        public Response(){
            errorCode = PayoffConstants.ERROR;
            status = PayoffConstants.FAIL;
        }
    }

    @HttpPost
    global static Response ChangePaymentDate() {

        Response res = new Response();
        RestRequest req = RestContext.request;
        Map<String, Object> reqParams = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
        String leadId;
        Date paymentDate;
        Date CPDExpireDate;
        String CPDReason;
        
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        Date systemDate = util.getCurrentSystemDate();
        Date transactionDate = systemDate;
        /*CRM-1056*/
        if(test.isRunningTest())
            systemDate = System.today();
        /*CRM-1056*/

        Date repaymentStartDate;
        Date secondPaymentDate = null;
        Date lastPaymentDate;
        Integer noOfInstallments = null;
        Integer interestOnlyPeriod = 0;
        Decimal interestRate;
        String frequencyOfPayment;
        Boolean maintainDelinquency = true;
        Boolean actualInterestOnlyPayments = False;
        Integer amortizationTerm;
        Integer dueDay;
        String stepUpOption = null;
        Decimal interestOnlyPaymentAmt = 0;
        Boolean regenerateInvAmzSchedule = True;
        Date generatedBillDate;
        Boolean checkFutureBillFlag = False;

        try {
            
            if (reqParams.get('Id') != null) {
                leadId = (String)reqParams.get('Id');
            }
            if (reqParams.get('paymentDate') != null) {
                paymentDate = Date.valueOf((String)reqParams.get('paymentDate'));
            }
            if (reqParams.get('CPDReason') != null) {
                CPDReason = (String)reqParams.get('CPDReason');
            }
            if (reqParams.get('expiryDate') != null) {
                CPDExpireDate = Date.valueOf((String)reqParams.get('expiryDate'));
            }
            if (reqParams.get('CPDNote') != null) {
                CPDNote = (String)reqParams.get('CPDNote');
            }
            
            
            System.debug('sfaf'+leadId);
            LAtobeUpdated = [Select id,name,
                             loan__Last_Installment_Date__c,
                             loan__Interest_Rate__c,
                             loan__Frequency_of_Loan_Payment__c,
                             loan__Pmt_Amt_Cur__c,
                             loan__Next_Installment_Date__c,
                             loan__Maturity_Date_Current__c,
                             loan__Term_Cur__c,
                             (Select id,name,
                              loan__Is_Archived__c,
                              loan__Due_Date__c
                              from loan__Repayment_Schedule__r),
                             (select id,name,loan__Due_Date__c
                             from loan__Dues_Details__r where 
                             loan__Payment_Satisfied__c  = false 
                             and loan__DD_Primary_Flag__c = true  
                             // and loan__Payment_Amt__c = 0.00
                             order by loan__Due_Date__c DESC limit 1),
                             (select id,name from loan__Repayment_Plan__r),
                             CPD_Reason__c,
                             CPD_Expire_Date__c
                             from loan__Loan_Account__c
                             where lead_guid__c =: leadId limit 1];

            System.debug('Name**'+LAtobeUpdated.name);

            if(LAtobeUpdated != null && LAtobeUpdated.CPD_Expire_Date__c != null && LAtobeUpdated.CPD_Expire_Date__c > systemDate) {
                res.errorCode = 'INVALID_INPUT';
                res.errorMessage = 'This Borrower is not eligible for CPD till ' + LAtobeUpdated.CPD_Expire_Date__c;
                res.status = peer.Constants.ERROR;
                return res;

            } else if (LAtobeUpdated == null ) {
                res.errorCode = 'INVALID_INPUT';
                res.errorMessage = 'Please check the Lead Id as there are no contracts for the provided leadId:'+leadId;
                res.status = peer.Constants.ERROR;
                return res;
            }
            
      if(!LAtobeUpdated.loan__Dues_Details__r.isempty() || LAtobeUpdated.loan__Dues_Details__r.size()>0)  //pallavi(LOS-191)
              generatedBillDate = LAtobeUpdated.loan__Dues_Details__r[0].loan__Due_Date__c;
            System.debug(logginglevel.error,'Next bill present : DUE Date :: '+generatedBillDate);
            System.debug(logginglevel.error,'Payment Date :: '+paymentDate);
                       
            repaymentStartDate = Date.newInstance(paymentDate.year(),paymentDate.month(),paymentDate.day());
  
            lastPaymentDate = LAtobeUpdated.loan__Maturity_Date_Current__c; //LSP-864
            System.debug(logginglevel.error,'lastPaymentDate'+lastPaymentDate);
            interestRate = LAtobeUpdated.loan__Interest_Rate__c;
            frequencyOfPayment = LAtobeUpdated.loan__Frequency_of_Loan_Payment__c;
            dueDay = paymentDate.day();
            System.debug(logginglevel.error,'DUEDAY'+dueDay);

            Integer terms = getRemainingTerm();

            if(LAtobeUpdated.loan__Repayment_Plan__r != null && LAtobeUpdated.loan__Repayment_Plan__r.size() != 0) {

                delete LAtobeUpdated.loan__Repayment_Plan__r;

            }

            List<clcommon__Repayment_Plan__c> repaymentPlan = new List<clcommon__Repayment_Plan__c>();
            
            if(generatedBillDate != null && generatedBillDate > systemDate){  //pallavi(LOS-191)
            
                System.debug(logginglevel.error,'In IF block : repaymentplan'); 
            
                checkFutureBillFlag = True;
                LAtobeUpdated.CPD_Unpaid_Due_Date__c = generatedBillDate;
                
                res.successMessage ='Change Payment Date Request Submitted Successfully.!!';
                res.status = peer.Constants.SUCCESS;
                          
            }else{
            
                System.debug(logginglevel.error,'In ELSE block : repaymentplan');
            
                repaymentPlan.add(new clcommon__Repayment_Plan__c(clcommon__Sequence_Number__c = 1,
                                                                  clcommon__Payment_Type__c = 'Equal Monthly Installments',
                                                                  clcommon__Payment_Amount__c = LAtobeUpdated.loan__Pmt_Amt_Cur__c,
                                                                  clcommon__Payment_Start_Date__c = Date.newInstance(paymentDate.year(),paymentDate.month(),paymentDate.day()),
                                                                  clcommon__Number_Of_Payments__c = terms,
                                                                  clcommon__Due_Day__c = paymentDate.day(),
                                                                  clcommon__Effective_Date__c = systemDate,
                                                                  loan__Loan_Account__c = LAtobeUpdated.id));            
            //}
            
            insert repaymentPlan;
            System.Debug('repaymentStartDate***' + repaymentStartDate);
			 loan.LoanRescheduleParameters rescheduleParams = new loan.LoanRescheduleParameters(LAtobeUpdated.id,
                                                                                               transactionDate,
                                                                                               repaymentStartDate,
                                                                                               secondPaymentDate,
                                                                                               lastPaymentDate,
                                                                                               noOfInstallments,
                                                                                               interestOnlyPeriod,
                                                                                               interestRate,
                                                                                               frequencyOfPayment,
                                                                                               maintainDelinquency,
                                                                                               actualInterestOnlyPayments,
                                                                                               amortizationTerm,
                                                                                               dueDay,
                                                                                               stepUpOption,
                                                                                               interestOnlyPaymentAmt,
                                                                                               regenerateInvAmzSchedule);

            List<loan.LoanRescheduleParameters.ProposedRepaymentPlan> repaymentPlanList = rescheduleParams.getRepaymentPlan();
            System.debug(logginglevel.error,'repaymentPlanList +++++'+repaymentPlanList);
            rescheduleParams.setRepaymentPlan(repaymentPlanList);

            loan.LoanActionFactory factory = new loan.LoanActionFactory();
            loan.LoanAction7 loanAction = factory.getLoanAction7API();
            System.debug(logginglevel.error,'rescheduleParams +++++'+rescheduleParams);
            loanAction.rescheduleALoan(rescheduleParams);

            res.successMessage ='Payment date upated Successfully!!';
            res.status = peer.Constants.SUCCESS;
            
            }
            
            if (LAtobeUpdated != null){
                LAtobeUpdated.CPD_Date__c = paymentDate;
                LAtobeUpdated.Future_Bill_Pending__c = checkFutureBillFlag;
                                
                /*CRM-1056*/
                if(!checkFutureBillFlag){
                    LAtobeUpdated.loan__Next_Installment_Date__c = repaymentStartDate;
                    LAtobeUpdated.loan__Due_Day__c = repaymentStartDate.day();
                }
                /*CRM-1056*/

                if (LAtobeUpdated.CPD_Expire_Date__c == null) {
                    if (CPDReason != null) { LAtobeUpdated.CPD_Reason__c = CPDReason; }
                    if (CPDExpireDate != null) {LAtobeUpdated.CPD_Expire_Date__c = CPDExpireDate; }    
                }

                update LAtobeupdated;
            }
            
            System.debug(logginglevel.error,'Checking if CPDNOte is NULL :: '+CPDNote);
            if (CPDNote != null){
                
                System.debug(logginglevel.error,'Calling insert CPDNOte');
                insertCPDNote();
            
            }

        } catch (Exception e) {
            
            res.errorCode = 'INVALID_INPUT';
            res.errorMessage = e.getMessage() +'Line Number:'+e.getLineNumber();
            System.debug(logginglevel.error,'line number'+e.getLineNumber());
            System.debug(logginglevel.error,'error stackTrace'+e.getStackTraceString());

            res.status = peer.Constants.ERROR;
            return res;
        }
        
        return res;
    }


    public static Integer getRemainingTerm() {

        Integer remainingTerm;

        if (LAtobeUpdated.loan__Next_Installment_Date__c != null && LAtobeUpdated.loan__Maturity_Date_Current__c != null) {
            remainingTerm = (Integer)(loan.DateUtil.cyclesBetween(LAtobeUpdated.loan__Next_Installment_Date__c,
                                                                  LAtobeUpdated.loan__Maturity_Date_Current__c, //loan__Last_Installment_Date__c LOS - 259. Changed by Neha.
                                                                  LAtobeUpdated.loan__Frequency_of_Loan_Payment__c));

            System.debug(logginglevel.error,'remainingTerm in IF'+remainingTerm);

        }
        /*else {
            remainingTerm = (Integer)LAtobeUpdated.loan__Term_Cur__c - 1;
           System.debug(logginglevel.error,'remainingTerm in ELSE'+remainingTerm);

           }*/

        System.debug(logginglevel.error,'remainingTerm'+remainingTerm);
        return remainingTerm;
    }
    
    public static void insertCPDNote(){
    
        Note CPDContractNote = new Note();
        CPDContractNote.ParentId = LAtobeUpdated.Id;
        CPDContractNote.Body = CPDNOte;
        CPDContractNote.Title = 'CPD Note via Member Portal';
        
        System.debug(logginglevel.error,'CPDContractNote'+CPDContractNote);
        
        insert CPDContractNote;
    
    }

}