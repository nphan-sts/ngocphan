/* ****************Modification History******************
 * Created By        Date          JIRA number
 *1. Pallavi        2021/03/12     LSP-27
 *      
 ******************Modification History******************/
global class RescheduleFailedLoansPostMigration {
    
    Date paymentDate; 
    Date currentSystemDate = (new loan.GlobalLoanUtilFacade().getCurrentSystemDate());

    global void rescheduleLoan_throughBatch(List<loan__loan_account__c> contract) {
              
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
        Boolean actualInterestOnlyPayments = false;
        Integer amortizationTerm;
        Integer dueDay;
        String stepUpOption = null;
        Decimal interestOnlyPaymentAmt = 0;
        Boolean regenerateInvAmzSchedule = true;
        loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
        Savepoint sp;
        

        try {
                        
            if(paymentDate == NULL){
            
                paymentDate = contract[0].loan__Next_Installment_Date__c;    //loan__Oldest_Due_Date__c;
                
                loan__Repayment_Schedule__c forPaymentDate = [Select id,loan__Due_Date__c from loan__Repayment_Schedule__c
                                                             where loan__Loan_Account__c =: contract[0].id and
                                                             loan__Due_Date__c>:currentSystemDate and loan__Is_Archived__c = false
                                                             order by loan__Due_Date__c LIMIT 1];
                paymentDate = forPaymentDate.loan__Due_Date__c;
                  
            }                           
                      
            transactionDate = contract[0].loan__Last_Accrual_Date__c;
            
            List<MigrationPhase__c> migrationPhase = MigrationPhase__c.getAll().values();
       		Integer reduceTerms = (Integer)migrationPhase[0].NumberOfTermsToReduce__c;     
             
            repaymentStartDate = Date.newInstance(paymentDate.year(),paymentDate.month(),paymentDate.day());
            List<loan__Repayment_Schedule__c> forLastPaymentDate = [Select id,loan__Due_Date__c from loan__Repayment_Schedule__c
                                                             where loan__Loan_Account__c =: contract[0].id and loan__Is_Archived__c = false
                                                             and loan__Due_Date__c>:currentSystemDate       
                                                             order by loan__Due_Date__c desc];
            if(forLastPaymentDate.size() >= reduceTerms)
            	lastPaymentDate = forLastPaymentDate[reduceTerms].loan__Due_Date__c;
            System.debug(logginglevel.error,'lastPaymentDate.. '+lastPaymentDate);
            if(contract[0].loan__Maturity_Date_Current__c < lastPaymentDate){
                      /*batch.loan__Log_Level__c = 'ERROR';
                      batch.loan__Message__c = 'AMZ date greater than current maturity date ::'+ contract[0].Name;                
                      batch.loan__Batch_Id__c = 'RescheduleFailedLoansPostMigration';
                
                	  insert batch;
                      return;*/
                      integer newTerm = 0; 
                      for(loan__Repayment_Schedule__c temp : forLastPaymentDate){
                          if(temp.loan__Due_Date__c > contract[0].loan__Maturity_Date_Current__c)
                              newTerm ++;
                          else{
                              lastPaymentDate = temp.loan__Due_Date__c;
                              break;
                         }
                      } 
                      reduceTerms = newTerm;
                      if(contract[0].loan__Maturity_Date_Current__c < lastPaymentDate){
                          batch.loan__Log_Level__c = 'ERROR';
                          batch.loan__Message__c = 'AMZ date greater than current maturity date ::'+ contract[0].Name;                
                          batch.loan__Batch_Id__c = 'RescheduleFailedLoansPostMigration';
                
                          insert batch;
                          return;
                      }    
            }  
            interestRate = contract[0].loan__Interest_Rate__c;
            frequencyOfPayment = contract[0].loan__Frequency_of_Loan_Payment__c;
            dueDay = paymentDate.day();
            System.debug(logginglevel.error,'DUEDAY'+dueDay);

            Integer terms = getRemainingTerm(contract[0],lastPaymentDate);
			
            sp = Database.setSavepoint();
   				
            if(contract[0].loan__Repayment_Plan__r.size() != 0){
                List<clcommon__Repayment_Plan__c> repaymentPlanUpdate = [Select id,clcommon__Number_Of_Payments__c from clcommon__Repayment_Plan__c
                                                                  where loan__Loan_Account__c =: contract[0].id
                                                                  order by clcommon__Sequence_Number__c desc Limit 1];
                repaymentPlanUpdate[0].clcommon__Number_Of_Payments__c = repaymentPlanUpdate[0].clcommon__Number_Of_Payments__c-reduceTerms;
                update repaymentPlanUpdate;
            }
                                       
              
            
      if(contract[0].loan__Repayment_Plan__r.size() == 0){  //pallavi(insert rep plan only when not provided by HM)
            List<clcommon__Repayment_Plan__c> repaymentPlan = new List<clcommon__Repayment_Plan__c>();
            repaymentPlan.add(new clcommon__Repayment_Plan__c(clcommon__Sequence_Number__c = 1,
                                                              clcommon__Payment_Type__c = 'Equal Monthly Installments',
                                                              clcommon__Payment_Amount__c = contract[0].loan__Pmt_Amt_Cur__c,
                                                              clcommon__Payment_Start_Date__c = Date.newInstance(paymentDate.year(),paymentDate.month(),paymentDate.day()),
                                                              clcommon__Number_Of_Payments__c = (terms),
                                                              clcommon__Due_Day__c = paymentDate.day(),
                                                              clcommon__Effective_Date__c = systemDate,
                                                              loan__Loan_Account__c = contract[0].id));

            insert repaymentPlan;
            }
            System.Debug('repaymentStartDate***' + repaymentStartDate);
            loan.LoanRescheduleParameters rescheduleParams = new loan.LoanRescheduleParameters(contract[0].id,
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
            
            contract[0].loan__Maturity_Date_Current__c = lastPaymentDate;
            update contract;

        } catch (Exception e) {
            
            Database.rollback(sp);
            batch.loan__Log_Level__c = 'ERROR';
            batch.loan__Message__c = ' Reschedule Failed for ::'+ contract[0].Name + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
            batch.loan__Batch_Id__c = 'RescheduleFailedLoansPostMigration';
            insert batch;
            
            System.debug(logginglevel.error,'line number'+e.getLineNumber());
            System.debug(logginglevel.error,'error stackTrace'+e.getStackTraceString());
            System.debug(logginglevel.error,'error message'+e.getMessage());

        }
        
    }

    public Integer getRemainingTerm(loan__loan_account__c LAtobeUpdated,Date lastPaymentDate) {


        Integer remainingTerm;
        

        if (LAtobeUpdated.loan__Next_Installment_Date__c != null && lastPaymentDate != null) {
            remainingTerm = (Integer)(loan.DateUtil.cyclesBetween(LAtobeUpdated.loan__Next_Installment_Date__c,
                                                                  LAtobeUpdated.Last_RSS_date__c,
                                                                  LAtobeUpdated.loan__Frequency_of_Loan_Payment__c));
          
        }
        System.debug(logginglevel.error,'remainingTerm'+remainingTerm);
        return remainingTerm;
    }

}