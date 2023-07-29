// Changes made by Neha to test the datafix for CLS-1375

global class DataAccrualFixPatch {
    
    public loan__Loan_Account__c LAtobeUpdated;
    String leadId; // = '7f660666-2b29-8cd0-6def-89b182e58d3c';
    Date paymentDate; // = date.newinstance(2019,09,05);
    
    global DataAccrualFixPatch(String leadGuid,Date firstPaymentDate){
    
        leadId = leadGuid;
        paymentDate = firstPaymentDate;
    
    }
    
    global DataAccrualFixPatch(loan__loan_Account__c LoanAccount){
        
        LAtobeUpdated = LoanAccount;
    }

    global void rescheduleLoan() {
              
        Date CPDExpireDate;
        String CPDReason;
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        Date systemDate = util.getCurrentSystemDate();
        Date transactionDate;

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
        loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();

        try {
            
            if(leadId == NULL){
                
                leadId = LAtobeUpdated.lead_Guid__c;
            }
            
            if(paymentDate == NULL){
            
                paymentDate = LAtobeUpdated.loan__First_Installment_Date__c;
            }
            
            if(LAtobeUpdated == NULL){
            
                LAtobeUpdated = [Select id,name,lead_Guid__c,loan__First_Installment_Date__c,
                             Application__r.genesis__Monthly_Debt_Payments__c,
                             loan__Payment_Amount__c,
                             loan__Accrual_Start_Date__c,
                             Application__r.Loan_Origination_Date__c,
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
                             (select id,name from loan__Repayment_Plan__r),
                             CPD_Reason__c,
                             CPD_Expire_Date__c
                             from loan__Loan_Account__c
                             where lead_guid__c =: leadId limit 1];
                       
            }
        
            if(LAtobeUpdated.Application__r.genesis__Monthly_Debt_Payments__c != LAtobeUpdated.loan__Payment_Amount__c && LAtobeUpdated.loan__Accrual_Start_Date__c != LAtobeUpdated.Application__r.Loan_Origination_Date__c){//LAtobeUpdated.loan__Accrual_Start_Date__c != LAtobeUpdated.Application__r.Loan_Origination_Date__c
                
                LAtobeUpdated.loan__Accrual_Start_Date__c = LAtobeUpdated.Application__r.Loan_Origination_Date__c;
                LAtobeUpdated.loan__Last_Accrual_Date__c = LAtobeUpdated.Application__r.Loan_Origination_Date__c;
                LAtobeUpdated.loan__Payment_Amount__c = LAtobeUpdated.Application__r.genesis__Monthly_Debt_Payments__c;
                LAtobeUpdated.loan__Pmt_Amt_Cur__c = LAtobeUpdated.Application__r.genesis__Monthly_Debt_Payments__c;
                LAtobeUpdated.loan__Interest_Remaining__c = 0;
                //LAtobeUpdated.DataAccrualFix__c = True;	//to be changed wrt approach
                //LAtobeUpdated.DataAccrualFix__c = false;	//to be changed wrt approach
                
                update LAtobeUpdated;
            
            }
            
            System.debug('sfaf'+leadId);
            
            // requerying the Loan.
            
            LAtobeUpdated = [Select id,name,lead_Guid__c,loan__First_Installment_Date__c,
                             Application__r.genesis__Monthly_Debt_Payments__c,
                             loan__Payment_Amount__c,
                             loan__Accrual_Start_Date__c,
                             Application__r.Loan_Origination_Date__c,
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
                             (select id,name from loan__Repayment_Plan__r),
                             CPD_Reason__c,
                             CPD_Expire_Date__c
                             from loan__Loan_Account__c
                             where lead_guid__c =: leadId limit 1];
                             
            System.debug(logginglevel.error,'Name**'+LAtobeUpdated.name);
            
            
            if (LAtobeUpdated == null ) {
                batch.loan__Log_Level__c = 'ERROR';
                batch.loan__Message__c = 'Please check the Lead Id as there are no contracts for the provided leadId ::'+ LAtobeUpdated.Name;                
                batch.loan__Batch_Id__c = 'DataAccrualFixPatch';
                
                insert batch;
                return;
            }

            transactionDate = LAtobeUpdated.Application__r.Loan_Origination_Date__c;
            repaymentStartDate = Date.newInstance(paymentDate.year(),paymentDate.month(),paymentDate.day());
            lastPaymentDate = LAtobeUpdated.loan__Last_Installment_Date__c;
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
            repaymentPlan.add(new clcommon__Repayment_Plan__c(clcommon__Sequence_Number__c = 1,
                                                              clcommon__Payment_Type__c = 'Equal Monthly Installments',
                                                              clcommon__Payment_Amount__c = LAtobeUpdated.loan__Pmt_Amt_Cur__c,
                                                              clcommon__Payment_Start_Date__c = Date.newInstance(paymentDate.year(),paymentDate.month(),paymentDate.day()),
                                                              clcommon__Number_Of_Payments__c = terms,
                                                              clcommon__Due_Day__c = paymentDate.day(),
                                                              clcommon__Effective_Date__c = systemDate,
                                                              loan__Loan_Account__c = LAtobeUpdated.id));

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

            if (LAtobeUpdated != null && LAtobeUpdated.CPD_Expire_Date__c == null) {
                if (CPDReason != null) { LAtobeUpdated.CPD_Reason__c = CPDReason; }
                if (CPDExpireDate != null) {LAtobeUpdated.CPD_Expire_Date__c = CPDExpireDate; }
                //LAtobeUpdated.DataAccrualFix__c = false;	//to be changed wrt approach
                LAtobeUpdated.DataAccrualFix__c = true;	//to be changed wrt approach
                update LAtobeupdated;
            }

        } catch (Exception e) {
            
            batch.loan__Log_Level__c = 'ERROR';
            batch.loan__Message__c = ' Reschedule Failed for ::'+ LAtobeUpdated.Name + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
            batch.loan__Batch_Id__c = 'DataAccrualFixPatch';
            insert batch;
            
            System.debug(logginglevel.error,'line number'+e.getLineNumber());
            System.debug(logginglevel.error,'error stackTrace'+e.getStackTraceString());
            System.debug(logginglevel.error,'error message'+e.getMessage());	//pallavi

        }
        
    }


    public Integer getRemainingTerm() {

        List<loan__Repayment_Schedule__c> rsRecs = LAtobeUpdated.loan__Repayment_Schedule__r;

        Integer remainingTerm;

        if (LAtobeUpdated.loan__Next_Installment_Date__c != null && LAtobeUpdated.loan__Maturity_Date_Current__c != null) {
            remainingTerm = (Integer)(loan.DateUtil.cyclesBetween(LAtobeUpdated.loan__Next_Installment_Date__c,
                                                                  LAtobeUpdated.loan__Last_Installment_Date__c,
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

}