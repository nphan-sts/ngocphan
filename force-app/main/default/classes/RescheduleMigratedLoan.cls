public class RescheduleMigratedLoan {
    
    public loan__Loan_Account__c lAtobeUpdated;   
    Date repaymentStartDate;
    Date transactionDate;
    Id CLContractId;
    
    loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
    loan.globalLoanUtilFacade util = new loan.globalLoanUtilFacade();
    Date systemDate = util.getCurrentSystemDate();
       
    public RescheduleMigratedLoan(Id contractId,Date repaymentDate, Date txnDate){  
        CLContractId = contractId;
        repaymentStartDate = repaymentDate;
        transactionDate = txnDate;
        System.debug(logginglevel.error, ' In RescheduleMigratedLoan : LoanID: '+CLContractId +' ** repaymentStartDate :: '+repaymentStartDate +' ** transactionDate :: '+transactionDate); 
    }
    
    public void rescheduleLoan() {
               
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
        
        try {      
                           
            if(lAtobeUpdated == null){
                lAtobeUpdated = [Select id,name,lead_Guid__c,loan__First_Installment_Date__c,
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
                             loan__Term_Cur__c,loan__Application_Date__c,                            
                             loan__Disbursal_Date__c,
                             (Select id,name,
                              loan__Is_Archived__c,
                              loan__Due_Date__c
                              from loan__Repayment_Schedule__r),
                             (select id,name from loan__Repayment_Plan__r)                              
                             from loan__Loan_Account__c
                             where Id =: CLContractId limit 1];
                       
            }
            
            System.debug('CLContractId..: '+CLContractId);           
                    
            if (lAtobeUpdated == null ) {
                batch.loan__Log_Level__c = 'ERROR';
                batch.loan__Message__c = 'Please check the Lead Id as there are no contracts for the provided CLContractId ::'+ lAtobeUpdated.Name;                
                batch.loan__Batch_Id__c = 'RescheduleMigratedLoan';
                insert batch;
                return;
            }
            
            //set repayment date            
            System.debug(logginglevel.error, ' lAtobeUpdated.Id: '+lAtobeUpdated.Id +' systemDate: '+systemDate);                                                                                 
            //repaymentStartDate = amortSchedule.get(Integer.valueOf(numberOfSkips)).loan__due_date__c;
            
            system.debug('repaymentStartDate is: '+repaymentStartDate);
                       
            lastPaymentDate = (lAtobeUpdated.loan__Maturity_Date_Current__c);
            interestRate = lAtobeUpdated.loan__Interest_Rate__c;
            frequencyOfPayment = lAtobeUpdated.loan__Frequency_of_Loan_Payment__c;
            if(repaymentStartDate != null){
                dueDay = repaymentStartDate.day();
            }
            System.debug(logginglevel.DEBUG,'Current Maturity Date: '+lastPaymentDate +' DUEDAY: '+dueDay);

            Integer terms = getRemainingTerm();
                
            if(lAtobeUpdated.loan__Repayment_Plan__r != null && lAtobeUpdated.loan__Repayment_Plan__r.size() != 0) {
                delete lAtobeUpdated.loan__Repayment_Plan__r;
            }

            List<clcommon__Repayment_Plan__c> repaymentPlan = new List<clcommon__Repayment_Plan__c>();
            repaymentPlan.add(new clcommon__Repayment_Plan__c(clcommon__Sequence_Number__c = 1,
                                                              clcommon__Payment_Type__c = 'Equal Monthly Installments',
                                                              clcommon__Payment_Amount__c = lAtobeUpdated.loan__Pmt_Amt_Cur__c,                                                              
                                                              clcommon__Payment_Start_Date__c = repaymentStartDate,
                                                              clcommon__Number_Of_Payments__c = (terms - 1),
                                                              clcommon__Due_Day__c = dueDay,
                                                              clcommon__Effective_Date__c = systemDate,// can be transactionDate
                                                              loan__Loan_Account__c = lAtobeUpdated.id));
                                                              
            System.debug(logginglevel.DEBUG,'Repayment PLAN :: '+repaymentPlan);
            insert repaymentPlan;
            
            loan.LoanRescheduleParameters rescheduleParams = new loan.LoanRescheduleParameters(lAtobeUpdated.id,
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
            System.debug(logginglevel.DEBUG,'repaymentPlanList.. : '+repaymentPlanList);
            rescheduleParams.setRepaymentPlan(repaymentPlanList);

            loan.LoanActionFactory factory = new loan.LoanActionFactory();
            loan.LoanAction7 loanAction = factory.getLoanAction7API();
            System.debug(logginglevel.DEBUG,'rescheduleParams.. : '+rescheduleParams);
            loanAction.rescheduleALoan(rescheduleParams);            
            
            //check if reschedule is successful
            
            System.debug('Call to rescheduleALoan of loanAction ends..');
            
            //lAtobeUpdated.loan__Next_Installment_Date__c = repaymentStartDate;
            //lAtobeUpdated.loan__Maturity_Date_Current__c = lastPaymentDate;
            if((lAtobeUpdated.loan__Loan_Status__c).equals('Active - Good Standing')){
                lAtobeUpdated.loan__Oldest_Due_Date__c = repaymentStartDate;
                System.debug('loan__Oldest_Due_Date__c is updated to: '+lAtobeUpdated.loan__Oldest_Due_Date__c);
            }
            
            update lAtobeUpdated;      

        } catch (Exception e) {          
            batch.loan__Log_Level__c = 'ERROR';
            batch.loan__Message__c = ' Reschedule Failed for ::'+ lAtobeUpdated.Name + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
            batch.loan__Batch_Id__c = 'RescheduleMigratedLoan';
            insert batch;
            
            System.debug(logginglevel.error,'line number'+e.getLineNumber());
            System.debug(logginglevel.error,'error stackTrace'+e.getStackTraceString());
            System.debug(logginglevel.error,'error message'+e.getMessage());

        }
        
    }

    /*
     *  Calculates remaining number of payments to be done
     *  returns integer 
     * 
     */
    public Integer getRemainingTerm() {
    
        Integer remainingTerm;
        if (lAtobeUpdated.loan__Next_Installment_Date__c != null && lAtobeUpdated.loan__Maturity_Date_Current__c != null) {
            remainingTerm = (Integer)(loan.DateUtil.cyclesBetween(transactionDate, //lAtobeUpdated.loan__Next_Installment_Date__c,
                                                                  lAtobeUpdated.loan__Maturity_Date_Current__c,
                                                                  lAtobeUpdated.loan__Frequency_of_Loan_Payment__c));
                                                                  
            System.debug(logginglevel.error,'remainingTerm in IF :: '+remainingTerm);
        }
        System.debug(logginglevel.error,'remainingTerm ::'+remainingTerm);
        return remainingTerm;
    }
    
}