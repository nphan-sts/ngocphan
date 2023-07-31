// Changes made by Neha 

global class RescheduleLoanPostMigration {
    
    public loan__Loan_Account__c LAtobeUpdated1;
    public loan__Loan_Account__c LAtobeUpdated;
    //public List<loan__Loan_Account__c> LAtobeUpdated2;
    String leadId; 
    Date paymentDate; 
    
    global RescheduleLoanPostMigration(String leadGuid,Date nextPaymentDate){
    
        leadId = leadGuid;
        paymentDate = nextPaymentDate;
    
    }
    
    global RescheduleLoanPostMigration(loan__loan_Account__c LoanAccount){
        
        LAtobeUpdated1 = LoanAccount;
    }
    
    global RescheduleLoanPostMigration(){
        
    }
    
    /*global RescheduleLoanPostMigration(List<loan__loan_Account__c> LoanAccount){
        
        LAtobeUpdated2 = LoanAccount;
    }*/

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
        Boolean actualInterestOnlyPayments = false;
        Integer amortizationTerm;
        Integer dueDay;
        String stepUpOption = null;
        Decimal interestOnlyPaymentAmt = 0;
        Boolean regenerateInvAmzSchedule = true;
        loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();

        try {
            /*pallavi*/
            if(LAtobeUpdated1 != null){
                LAtobeUpdated = [Select id,name,lead_Guid__c,
                             loan__First_Installment_Date__c,
                             loan__Oldest_Due_Date__c,
                             Application__r.genesis__Monthly_Debt_Payments__c,
                             loan__Payment_Amount__c,
                             loan__Last_Payment_Date__c,
                             loan__Accrual_Start_Date__c,
                             Application__r.Loan_Origination_Date__c,
                             loan__Last_Installment_Date__c,
                             Last_RSS_date__c,
                             loan__Interest_Rate__c,
                             loan__Frequency_of_Loan_Payment__c,
                             loan__Pmt_Amt_Cur__c,
                             loan__Next_Installment_Date__c,
                             loan__Maturity_Date_Current__c,
                             loan__Term_Cur__c,
                             loan__Loan_Status__c,
                             loan__Last_Accrual_Date__c,
                             DM_Rescheduling_Error__c,	//LSP-27    
                             (Select id,name,
                              loan__Is_Archived__c,
                              loan__Due_Date__c
                              from loan__Repayment_Schedule__r),
                             (select id,name from loan__Repayment_Plan__r),
                             CPD_Reason__c,
                             CPD_Expire_Date__c
                             from loan__Loan_Account__c
                             where id =: LAtobeUpdated1.id limit 1];
            }
            /*pallavi*/
            if(leadId == NULL){
                
                leadId = LAtobeUpdated.lead_Guid__c;
            }
            
            if(paymentDate == NULL){
            
                paymentDate = LAtobeUpdated.loan__Next_Installment_Date__c;    //loan__Oldest_Due_Date__c;
                /*pallavi*/
                Date currentSystemDate = (new loan.GlobalLoanUtilFacade().getCurrentSystemDate());
                System.debug('currentSystemDate... '+currentSystemDate);
                loan__Repayment_Schedule__c forPaymentDate = [Select id,loan__Due_Date__c from loan__Repayment_Schedule__c
                                                             where loan__Loan_Account__c =: LAtobeUpdated1.id and
                                                             loan__Due_Date__c>:currentSystemDate and loan__Is_Archived__c = false
                                                             order by loan__Due_Date__c LIMIT 1];
                paymentDate = forPaymentDate.loan__Due_Date__c;
                /*pallavi*/
            }
            
            if(LAtobeUpdated1 == NULL){
            
                LAtobeUpdated = [Select id,name,lead_Guid__c,
                             loan__First_Installment_Date__c,
                             loan__Oldest_Due_Date__c,
                             Application__r.genesis__Monthly_Debt_Payments__c,
                             loan__Payment_Amount__c,
                             loan__Last_Payment_Date__c,
                             loan__Accrual_Start_Date__c,
                             Application__r.Loan_Origination_Date__c,
                             loan__Last_Installment_Date__c,
                             Last_RSS_date__c,
                             loan__Interest_Rate__c,
                             loan__Frequency_of_Loan_Payment__c,
                             loan__Pmt_Amt_Cur__c,
                             loan__Next_Installment_Date__c,
                             loan__Maturity_Date_Current__c,
                             loan__Term_Cur__c,
                             loan__Last_Accrual_Date__c,
                             loan__Loan_Status__c,
                             DM_Rescheduling_Error__c,	//LSP-27    
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
            
            System.debug('sfaf'+leadId);
                           
            System.debug(logginglevel.error,'Name**'+LAtobeUpdated.name);
            
            
            if (LAtobeUpdated == null ) {
                batch.loan__Log_Level__c = 'ERROR';
                batch.loan__Message__c = 'Please check the Lead Id as there are no contracts for the provided leadId ::'+ LAtobeUpdated.Name;                
                batch.loan__Batch_Id__c = 'RescheduleLoanPostMigration';
                
                insert batch;
                return;
            }

            //transactionDate = LAtobeUpdated.loan__Last_Payment_Date__c;  //temp//systemDate; //LAtobeUpdated.loan__Last_Payment_Date__c ;
            //if(LAtobeUpdated.loan__Loan_Status__c == 'Active - Good Standing')
                transactionDate = LAtobeUpdated.loan__Last_Accrual_Date__c;
           // else if(LAtobeUpdated.loan__Loan_Status__c == 'Active - Bad Standing')
           //     transactionDate = Date.newInstance(LAtobeUpdated.loan__Oldest_Due_Date__c.year(), LAtobeUpdated.loan__Oldest_Due_Date__c.month()-1,
           //                                        LAtobeUpdated.loan__Oldest_Due_Date__c.day());
            repaymentStartDate = Date.newInstance(paymentDate.year(),paymentDate.month(),paymentDate.day());
            // lastPaymentDate = LAtobeUpdated.loan__Last_Installment_Date__c;
            lastPaymentDate = LAtobeUpdated.Last_RSS_date__c;
            System.debug(logginglevel.error,'lastPaymentDate'+lastPaymentDate);
            interestRate = LAtobeUpdated.loan__Interest_Rate__c;
            frequencyOfPayment = LAtobeUpdated.loan__Frequency_of_Loan_Payment__c;
            dueDay = paymentDate.day();
            System.debug(logginglevel.error,'DUEDAY'+dueDay);

            Integer terms = getRemainingTerm();

           /* if(LAtobeUpdated.loan__Repayment_Plan__r != null && LAtobeUpdated.loan__Repayment_Plan__r.size() != 0) {

                delete LAtobeUpdated.loan__Repayment_Plan__r;  //pallavi(commented because we do not have to delete)

            //}*/
            /*CRM-990*/         
           List<MigrationPhase__c> migrationPhase = MigrationPhase__c.getAll().values();
           Double negligibleAmount = migrationPhase[0].ListIndexOutOfBound_NegligibleAmount__c  ;
            
            List<loan__Repayment_Schedule__c> checkNegligibleAmount = [Select id,loan__Total_Installment__c from loan__Repayment_Schedule__c
                                                                      where loan__Loan_Account__c =:LAtobeUpdated.id and
                                                                      loan__Due_Date__c =: lastPaymentDate]; 
            if(checkNegligibleAmount[0].loan__Total_Installment__c < negligibleAmount){    
                if(LAtobeUpdated.loan__Repayment_Plan__r.size() != 0){
                    List<clcommon__Repayment_Plan__c> repaymentPlanUpdate = [Select id,clcommon__Number_Of_Payments__c from clcommon__Repayment_Plan__c
                                                                      where loan__Loan_Account__c =: LAtobeUpdated.id
                                                                      order by clcommon__Sequence_Number__c desc Limit 1];
                    repaymentPlanUpdate[0].clcommon__Number_Of_Payments__c = repaymentPlanUpdate[0].clcommon__Number_Of_Payments__c-1;
                    update repaymentPlanUpdate;
                }
            }      
       /*CRM-990*/ 
            if(LAtobeUpdated.loan__Repayment_Plan__r.size() == 0){  //pallavi(insert rep plan only when not provided by HM)
            List<clcommon__Repayment_Plan__c> repaymentPlan = new List<clcommon__Repayment_Plan__c>();
            repaymentPlan.add(new clcommon__Repayment_Plan__c(clcommon__Sequence_Number__c = 1,
                                                              clcommon__Payment_Type__c = 'Equal Monthly Installments',
                                                              clcommon__Payment_Amount__c = LAtobeUpdated.loan__Pmt_Amt_Cur__c,
                                                              clcommon__Payment_Start_Date__c = Date.newInstance(paymentDate.year(),paymentDate.month(),paymentDate.day()),
                                                              clcommon__Number_Of_Payments__c = (terms),
                                                              clcommon__Due_Day__c = paymentDate.day(),
                                                              clcommon__Effective_Date__c = systemDate,
                                                              loan__Loan_Account__c = LAtobeUpdated.id));

            insert repaymentPlan;
            }
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
            
            //LAtobeUpdated.loan__Next_Due_Generation_Date__c = LAtobeUpdated.loan__Next_Installment_Date__c.addDays((Integer)(-1*((LAtobeUpdated.loan__Pre_Bill_Days__c!=null)?LAtobeUpdated.loan__Pre_Bill_Days__c:0)));
      //update LAtobeupdated;
            
            if (LAtobeUpdated != null && LAtobeUpdated.CPD_Expire_Date__c == null) {
                if (CPDReason != null) { LAtobeUpdated.CPD_Reason__c = CPDReason; }
                if (CPDExpireDate != null) {LAtobeUpdated.CPD_Expire_Date__c = CPDExpireDate; }
                
                // create a cutom field and flag it.
                
                update LAtobeupdated;
            }

        } catch (Exception e) {
            
            batch.loan__Log_Level__c = 'ERROR';
            batch.loan__Message__c = ' Reschedule Failed for ::'+ LAtobeUpdated.Name + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
            batch.loan__Batch_Id__c = 'RescheduleLoanPostMigration';
            insert batch;
            
            System.debug(logginglevel.error,'line number'+e.getLineNumber());
            System.debug(logginglevel.error,'error stackTrace'+e.getStackTraceString());
            System.debug(logginglevel.error,'error message'+e.getMessage());  //pallavi
            
            //LSP-27
            if(e.getMessage().containsIgnoreCase('Divide by 0'))
            	LAtobeupdated.DM_Rescheduling_Error__c = 'Divide by 0';
            else if(e.getMessage().containsIgnoreCase('List index out of bounds: 0'))
                LAtobeupdated.DM_Rescheduling_Error__c = 'List index out of bounds: 0';
            if(LAtobeupdated.DM_Rescheduling_Error__c <> '')
                update LAtobeupdated;
            //LSP-27

        }
        
    }
    
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

        try {
            
            //contract[0].Reschedule_Attempted__c = true;
            //System.debug('contract[0].Reschedule_Attempted__c----' + contract[0].Reschedule_Attempted__c);
            
            if(paymentDate == NULL){
            
                paymentDate = contract[0].loan__Next_Installment_Date__c;    //loan__Oldest_Due_Date__c;
                System.debug('paymentDate----' + paymentDate);
                /*pallavi*/
                Date currentSystemDate = (new loan.GlobalLoanUtilFacade().getCurrentSystemDate());
                System.debug('currentSystemDate-----' + currentSystemDate);
                
                loan__Repayment_Schedule__c forPaymentDate = [Select id,loan__Due_Date__c from loan__Repayment_Schedule__c
                                                             where loan__Loan_Account__c =: contract[0].id and
                                                             loan__Due_Date__c>:currentSystemDate and loan__Is_Archived__c = false
                                                             order by loan__Due_Date__c LIMIT 1];
                paymentDate = forPaymentDate.loan__Due_Date__c;
                /*pallavi*/
            }                           
            
            
            if (contract[0] == null ) {
                batch.loan__Log_Level__c = 'ERROR';
                batch.loan__Message__c = 'Please check the Lead Id as there are no contracts for the provided leadId ::'+ contract[0].Name;                
                batch.loan__Batch_Id__c = 'RescheduleLoanPostMigration';
                
                insert batch;
                return;
            }

            //transactionDate = systemDate; //LAtobeUpdated.loan__Last_Payment_Date__c ;
           // if(contract[0].loan__Loan_Status__c == 'Active - Good Standing')
                transactionDate = contract[0].loan__Last_Accrual_Date__c;
          //  else if(contract[0].loan__Loan_Status__c == 'Active - Bad Standing')
          //      transactionDate = Date.newInstance(contract[0].loan__Oldest_Due_Date__c.year(), contract[0].loan__Oldest_Due_Date__c.month()-1,
          //                                         contract[0].loan__Oldest_Due_Date__c.day());
                
             System.debug('transactionDate... '+transactionDate);
            repaymentStartDate = Date.newInstance(paymentDate.year(),paymentDate.month(),paymentDate.day());
            // lastPaymentDate = LAtobeUpdated.loan__Last_Installment_Date__c;
            lastPaymentDate = contract[0].Last_RSS_date__c;
            System.debug(logginglevel.error,'lastPaymentDate.. '+lastPaymentDate);
            interestRate = contract[0].loan__Interest_Rate__c;
            frequencyOfPayment = contract[0].loan__Frequency_of_Loan_Payment__c;
            dueDay = paymentDate.day();
            System.debug(logginglevel.error,'DUEDAY'+dueDay);

            Integer terms = getRemainingTerm1(contract[0]);

            /*if(contract[0].loan__Repayment_Plan__r != null && contract[0].loan__Repayment_Plan__r.size() != 0) {

                //delete contract[0].loan__Repayment_Plan__r; //pallavi(commented because we do not have to delete)

           // }*/
           
       /*CRM-990*/
       List<MigrationPhase__c> migrationPhase = MigrationPhase__c.getAll().values();
       Double negligibleAmount = migrationPhase[0].ListIndexOutOfBound_NegligibleAmount__c  ;     
            
        List<loan__Repayment_Schedule__c> checkNegligibleAmount = [Select id,loan__Total_Installment__c from loan__Repayment_Schedule__c
                                                                  where loan__Loan_Account__c =:contract[0].id and
                                                                  loan__Due_Date__c =: lastPaymentDate]; 
        if(checkNegligibleAmount[0].loan__Total_Installment__c < negligibleAmount){    
            if(contract[0].loan__Repayment_Plan__r.size() != 0){
                List<clcommon__Repayment_Plan__c> repaymentPlanUpdate = [Select id,clcommon__Number_Of_Payments__c from clcommon__Repayment_Plan__c
                                                                  where loan__Loan_Account__c =: contract[0].id
                                                                  order by clcommon__Sequence_Number__c desc Limit 1];
                repaymentPlanUpdate[0].clcommon__Number_Of_Payments__c = repaymentPlanUpdate[0].clcommon__Number_Of_Payments__c-1;
                update repaymentPlanUpdate;
            }
        }      
       /*CRM-990*/     
            
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

            /*if (contract[0] != null && contract[0].CPD_Expire_Date__c == null) {System.debug('inside contract CPD check block.. ');
                if (CPDReason != null) { contract[0].CPD_Reason__c = CPDReason; }
                if (CPDExpireDate != null) {contract[0].CPD_Expire_Date__c = CPDExpireDate; }
                
                // create a cutom field and flag it.
                
                update contract[0];
            }*/

        } catch (Exception e) {
            
            batch.loan__Log_Level__c = 'ERROR';
            batch.loan__Message__c = ' Reschedule Failed for ::'+ contract[0].Name + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
            batch.loan__Batch_Id__c = 'RescheduleLoanPostMigration';
            insert batch;
            
            System.debug(logginglevel.error,'line number'+e.getLineNumber());
            System.debug(logginglevel.error,'error stackTrace'+e.getStackTraceString());
            System.debug(logginglevel.error,'error message'+e.getMessage());  //pallavi
            
            //LSP-27
            if(e.getMessage().containsIgnoreCase('Divide by 0'))
            	contract[0].DM_Rescheduling_Error__c = 'Divide by 0';
            else if(e.getMessage().containsIgnoreCase('List index out of bounds: 0'))
                contract[0].DM_Rescheduling_Error__c = 'List index out of bounds: 0';
            if(contract[0].DM_Rescheduling_Error__c <> '')
                update contract[0];
            //LSP-27

        }
        
    }

    global void rescheduleFutureLADLoan(List<loan__loan_account__c> contract) {
              
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

        try {
            
            if(paymentDate == NULL){
            
                paymentDate = contract[0].loan__Next_Installment_Date__c; 
                System.debug('paymentDate----' + paymentDate);
                /*pallavi*/
                Date currentSystemDate = (new loan.GlobalLoanUtilFacade().getCurrentSystemDate());
                System.debug('currentSystemDate-----' + currentSystemDate);
                
                loan__Repayment_Schedule__c forPaymentDate = [Select id,loan__Due_Date__c from loan__Repayment_Schedule__c
                                                             where loan__Loan_Account__c =: contract[0].id and
                                                             loan__Due_Date__c>:currentSystemDate and loan__Is_Archived__c = false
                                                             order by loan__Due_Date__c LIMIT 1];
                paymentDate = forPaymentDate.loan__Due_Date__c;
                /*pallavi*/
            }                           
            
            
            if (contract[0] == null ) {
                batch.loan__Log_Level__c = 'ERROR';
                batch.loan__Message__c = 'Please check the Lead Id as there are no contracts for the provided leadId ::'+ contract[0].Name;                
                batch.loan__Batch_Id__c = 'RescheduleLoanPostMigration';
                
                insert batch;
                return;
            }

                transactionDate = contract[0].loan__Last_Accrual_Date__c;
                
            repaymentStartDate = Date.newInstance(paymentDate.year(),paymentDate.month(),paymentDate.day());
            lastPaymentDate = contract[0].Last_RSS_date__c;
            interestRate = contract[0].loan__Interest_Rate__c;
            frequencyOfPayment = contract[0].loan__Frequency_of_Loan_Payment__c;
            dueDay = paymentDate.day();

            Integer terms = getRemainingTerm1(contract[0]);

            if(contract[0].loan__Repayment_Plan__r != null && contract[0].loan__Repayment_Plan__r.size() != 0) {

                delete contract[0].loan__Repayment_Plan__r; //pallavi(commented because we do not have to delete)

           }
           update contract[0];
            List<clcommon__Repayment_Plan__c> repaymentPlan = new List<clcommon__Repayment_Plan__c>();
            repaymentPlan.add(new clcommon__Repayment_Plan__c(clcommon__Sequence_Number__c = 1,
                                                              clcommon__Payment_Type__c = 'Equal Monthly Installments',
                                                              clcommon__Payment_Amount__c = contract[0].loan__Pmt_Amt_Cur__c,
                                                              clcommon__Payment_Start_Date__c = Date.newInstance(paymentDate.year(),paymentDate.month(),paymentDate.day()),
                                                              clcommon__Number_Of_Payments__c = terms,//(terms - 1),
                                                              clcommon__Due_Day__c = paymentDate.day(),
                                                              clcommon__Effective_Date__c = systemDate,
                                                              loan__Loan_Account__c = contract[0].id));

            insert repaymentPlan;
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

            if (contract[0] != null && contract[0].CPD_Expire_Date__c == null) {System.debug('inside contract CPD check block.. ');
                if (CPDReason != null) { contract[0].CPD_Reason__c = CPDReason; }
                if (CPDExpireDate != null) {contract[0].CPD_Expire_Date__c = CPDExpireDate; }
                
                // create a cutom field and flag it.
                
                update contract[0];
            }

        } catch (Exception e) {
            
            batch.loan__Log_Level__c = 'ERROR';
            batch.loan__Message__c = ' Reschedule Failed for ::'+ contract[0].Name + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
            batch.loan__Batch_Id__c = 'RescheduleLoanPostMigration';
            insert batch;
            
            System.debug(logginglevel.error,'line number'+e.getLineNumber());
            System.debug(logginglevel.error,'error stackTrace'+e.getStackTraceString());
            System.debug(logginglevel.error,'error message'+e.getMessage());  //pallavi

        }
        
    }


    public Integer getRemainingTerm() {


        Integer remainingTerm;

        if (LAtobeUpdated.loan__Next_Installment_Date__c != null && LAtobeUpdated.Last_RSS_date__c != null) {
            remainingTerm = (Integer)(loan.DateUtil.cyclesBetween(LAtobeUpdated.loan__Next_Installment_Date__c,
                                                                  LAtobeUpdated.Last_RSS_date__c, //LAtobeUpdated.loan__Last_Installment_Date__c,
                                                                  LAtobeUpdated.loan__Frequency_of_Loan_Payment__c));

            System.debug(logginglevel.error,'remainingTerm in IF'+remainingTerm);

        }
        /*else {
            remainingTerm = (Integer)LAtobeUpdated.loan__Term_Cur__c - 1;
           System.debug(logginglevel.error,'remainingTerm in ELSE'+remainingTerm);

           }*/

        //remainingTerm = remainingTerm - 21;//pallavi(temp, for contracts that did not get rescheduled)
        System.debug(logginglevel.error,'remainingTerm'+remainingTerm);
        return remainingTerm;
    }
    
    public Integer getRemainingTerm1(loan__loan_account__c LAtobeUpdated2) {


        Integer remainingTerm;
        

        if (LAtobeUpdated2.loan__Next_Installment_Date__c != null && LAtobeUpdated2.Last_RSS_date__c != null) {
            remainingTerm = (Integer)(loan.DateUtil.cyclesBetween(LAtobeUpdated2.loan__Next_Installment_Date__c,
                                                                  LAtobeUpdated2.Last_RSS_date__c, //LAtobeUpdated2.loan__Last_Installment_Date__c,
                                                                  LAtobeUpdated2.loan__Frequency_of_Loan_Payment__c));    //pallav(commented)
            
            /*pallavi*/
            //remainingTerm = LAtobeUpdated2.loan__Next_Installment_Date__c.monthsBetween(LAtobeUpdated2.Last_RSS_date__c); 
            /*pallavi*/

        }
        System.debug(logginglevel.error,'remainingTerm'+remainingTerm);
        return remainingTerm;
    }

}