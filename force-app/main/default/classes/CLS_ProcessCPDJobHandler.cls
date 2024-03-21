/* ****************Modification History*****************************************************************
 * 
 * Modified by              Date        JIRA number
 * 1.   Pallavi/Neha      2020/12/11  CRM-1056 CPD issue/Reverting issue (short-term fix) - Case #02430069 
 ******************Modification History*****************************************************************/
public class CLS_ProcessCPDJobHandler{

    public static loan__loan_account__c LAtobeUpdated;
    
    public void ChangePaymentDate(loan__loan_account__c Loan) {

        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        Date systemDate = util.getCurrentSystemDate();
        Date transactionDate = systemDate;

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
        Boolean checkFutureBillFlag;
        Date paymentDate;
        loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();    //CRM-1056(to log errors)

        try {
            
            LAtobeUpdated = Loan;
            
            System.debug('Name**'+LAtobeUpdated.name);
            paymentDate = LAtobeUpdated.CPD_Date__c;
            repaymentStartDate = LAtobeUpdated.CPD_Date__c;
            
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
            
            
            
            System.debug(logginglevel.error,'In ELSE block : repaymentplan');
        
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
            
            Id LAId = LAtobeUpdated.Id;
            LAtobeUpdated = [Select id,name
                             from loan__Loan_Account__c
                             where Id =: LAId limit 1];
                             
            LAtobeUpdated.Future_Bill_Pending__c = False;
            /*CRM-1056*/
            LAtobeUpdated.loan__Next_Installment_Date__c = repaymentStartDate;
            LAtobeUpdated.loan__Due_Day__c = repaymentStartDate.day();
            /*CRM-1056*/

            update LAtobeUpdated;
            

        } catch (Exception e) { //CRM-1056
            
            batch.loan__Log_Level__c = 'ERROR';
            batch.loan__Message__c = ' Reschedule Failed for ::'+ LAtobeUpdated.Name + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
            batch.loan__Batch_Id__c = 'CLS_ProcessCPDJobHandler';
            insert batch;
            
            System.debug(logginglevel.error,'line number'+e.getLineNumber());
            System.debug(logginglevel.error,'error stackTrace'+e.getStackTraceString());

            
        }
        
    }


    public static Integer getRemainingTerm() {

        List<loan__Repayment_Schedule__c> rsRecs = LAtobeUpdated.loan__Repayment_Schedule__r;

        Integer remainingTerm;

        if (LAtobeUpdated.loan__Next_Installment_Date__c != null && LAtobeUpdated.loan__Maturity_Date_Current__c != null) {
            remainingTerm = (Integer)(loan.DateUtil.cyclesBetween(LAtobeUpdated.loan__Next_Installment_Date__c,
                                                                  LAtobeUpdated.loan__Maturity_Date_Current__c, //loan__Last_Installment_Date__c LOS - 259. Changed by Neha.
                                                                  LAtobeUpdated.loan__Frequency_of_Loan_Payment__c));

            System.debug(logginglevel.error,'remainingTerm in IF'+remainingTerm);

        }
        
        System.debug(logginglevel.error,'remainingTerm'+remainingTerm);
        return remainingTerm;
    }

}