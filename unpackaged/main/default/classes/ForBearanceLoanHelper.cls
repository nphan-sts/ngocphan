/*****************************************************************************
    *  author Anusha
    *
    *  This is a helper class to perform rescheduling of a loan
    *  Result: Loan is rescheduled and loan maturity date is moved accordingly
    *
    *  /* ****************Modification History*****************************************************************
    
    * Modified by      Date            JIRA number
    *  Pallavi       2020/01/14    CRM-952 (Completely automate the SAP processing for LoanOps/Produce errors/logs for failures.)
    *  Anusha        2021/02/17    LSP-3 (Completely automate the SAP processing for LoanOps)
    *  Mohan Kiran   2021/09/09    LSP-292-Processing skip a pay for bad standing loans coming from callouts.
    *  Mohan Kiran   2022/07/14    LSP-836 - SAP processing within 45 days should not update Hardship request date. If the date difference between
                                                first skip and 2nd skip are less than 45 days, the hardship request date is not altered.
    *  Shakul        2022/08/16    LSP-912 - Changing SAP behavior to not maintaining delinquency irrespective of good/bad loans
    *  Shakul        2022/12/05    LSP-1104 - Changing logic to get remaining terms based on due date of Amortization schedules.
    ******************Modification History*****************************************************************
    ******************************************************************************/
    global class ForBearanceLoanHelper {
        
        public loan__Loan_Account__c lAtobeUpdated;
        public Integer numberOfSkips = 1;
        public boolean isFromAPI ;//This is to identify if the class is called from Endpoint. Only calls coming from endpoint process bad standing loans
        String leadId;
        Date repaymentStartDate;
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        Date systemDate = util.getCurrentSystemDate();
        loan__Batch_Process_Log__c batch = new loan__Batch_Process_Log__c();
        boolean isEligibleForReschedule = false;
        Map<String,String> contractSAPerror; //CRM-952
        static final Integer SAP_CHECK_DAYS = 45; // LSP-836 - 45 days check between first skipped date and present transaction date

        
        global ForBearanceLoanHelper(String leadGuid,Date repaymentDate){  
            leadId = leadGuid;
            repaymentStartDate = repaymentDate;
            isFromAPI = false;
        }
        
        global ForBearanceLoanHelper(loan__loan_Account__c loanAccount, Integer numberOfSkipsSent){  
            lAtobeUpdated = loanAccount;
            numberOfSkips = numberOfSkipsSent;
            isFromAPI = false;
        }
        
        /* START-LSP-292 Block1 SAP for badloans 
    * This constructor gets called when the Skip a pay end point is called.*/
        
        global ForBearanceLoanHelper(loan__loan_Account__c loanAccount, Integer numberOfSkipsSent, boolean isFromApiCallout){  
            lAtobeUpdated = loanAccount;
            numberOfSkips = numberOfSkipsSent;
            isFromAPI = isFromApiCallout;
            
        }
        /*END-LSP-292-Block1*/
        
        global RestResponse rescheduleLoan(Map<String,String> contractSAPerror) { //CRM-952
            RestResponse res = new RestResponse();
            Date CPDExpireDate;
            String CPDReason;
            this.contractSAPerror = contractSAPerror;
            
            Date transactionDate = systemDate; //reschedule transaction date
            
            Date secondPaymentDate = null;
            Date lastPaymentDate;
            Integer noOfInstallments = null;
            Integer interestOnlyPeriod = 0;
            Decimal interestRate;
            String frequencyOfPayment;
            Boolean maintainDelinquency = false; //LSP-912: Changing it to false irrespective of good/bad loans and invoking origination
            /* START-LSP-292 Block2 
    *Maintain Delinquency flag should be set to false when the active bad standing loan comes from processing
    */
            /*Commenting below code as part of LSP-912
            if(lAtobeUpdated!= null && isFromAPI && lAtobeUpdated.loan__Loan_Status__c == 'Active - Bad Standing'){
                
                maintainDelinquency = false;
                
            }*/
            
            /*END-LSP-292 Block2*/
            
            Boolean actualInterestOnlyPayments = False;
            Integer amortizationTerm;
            Integer dueDay;
            String stepUpOption = null;
            Decimal interestOnlyPaymentAmt = 0;
            Boolean regenerateInvAmzSchedule = True;
            /* LSP-836 - START */
            Integer sapdaysDifference;
            
            
            /*LSP-836 - END*/
            
            try {      
                if(leadId == null && lAtobeUpdated!=null){      //LSP-836 Added an extra null pointer check for lAtobeUpdated       
                    leadId = lAtobeUpdated.lead_Guid__c;
                }
                
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
                                     Skipped_a_pay_Date__c,
                                     Skipped_a_Pay__c,
                                     loan__Disbursal_Date__c,
                                     (Select id,name,
                                      loan__Is_Archived__c,
                                      loan__Due_Date__c
                                      from loan__Repayment_Schedule__r),
                                     (select id,name from loan__Repayment_Plan__r),
                                     CPD_Reason__c,
                                     CPD_Expire_Date__c,
                                     /* LSP-3 start */
                                     U_LoanModTermExt__c,
                                     loan__Oldest_Due_Date__c,
                                     U_LoanModForbearance__c,
                                     Hardship_New_Maturity_Date__c,
                                     U_LoanModForbearDt__c,
                                     Hardship_Request_Date__c
                                     /* LSP-3 end */
                                     from loan__Loan_Account__c
                                     where lead_guid__c =: leadId limit 1];
                    
                }
                
                System.debug('leadId..: '+leadId);    
                
                
                system.debug('Skipped_a_Pay__c: '+lAtobeUpdated.Skipped_a_Pay__c+' and Skipped_a_pay_Date__c: '+lAtobeUpdated.Skipped_a_pay_Date__c);
                
                //Before processing the loan, check if skip-a-pay action is already peformed for the loan, if yes log an exception and dont process that loan
                if(lAtobeUpdated.Skipped_a_Pay__c != null && lAtobeUpdated.Skipped_a_Pay__c == true){
                    if(lAtobeUpdated.Skipped_a_pay_Date__c != null && lAtobeUpdated.Skipped_a_pay_Date__c == systemDate){
                        batch.loan__Log_Level__c = 'ERROR';
                        batch.loan__Message__c = 'Pay is already skipped for this contract, hence not processed any further ::'+ lAtobeUpdated.Name;                
                        batch.loan__Batch_Id__c = 'ForBearanceLoanHelper';
                        insert batch;
                        contractSAPerror.put(lAtobeUpdated.Name,batch.loan__Message__c); //CRM-952
                        res.statusCode = 405;
                        res.responseBody = Blob.valueOf('{"message" : "' + batch.loan__Message__c + '"}');
                        return res;
                    }
                }
                
                
                //check if NACHA file s already sent. if yes, dont skip the payment, reschedule is not needed.. break and return            
                if(checkIfNachaisSent()){
                    //to check if payment for next month has to be skipped                
                    System.Debug('Nacha is already sent');
                    res.statusCode = 405;
                    
                    batch.loan__Log_Level__c = 'ERROR';
                    batch.loan__Message__c = 'Nacha is Already sent for this Loan Account : '+lAtobeUpdated.Name;                
                    batch.loan__Batch_Id__c = 'ForBearanceLoanHelper';
                    insert batch;
                    
                    res.responseBody = Blob.valueOf('{"message": "' + 'Nacha is already sent::'+ lAtobeUpdated.Name + '"}');
                    return res;
                }// if NACHA is not sent, loan is rescheduled as it is done for any other loan
                
                System.debug('isEligibleForReschedule----' + isEligibleForReschedule);  //pallavi
                
                if(isEligibleForReschedule == false){
                    res.statusCode = 405;
                    res.responseBody = Blob.valueOf('{"message": "' + 'Loan is not eligible for reschedule ::'+ lAtobeUpdated.Name + '"}');
                    
                    loan__Batch_Process_Log__c rescheduleBatch = new loan__Batch_Process_Log__c(); 
                    rescheduleBatch.loan__Log_Level__c = 'ERROR';
                    rescheduleBatch.loan__Message__c = 'This loan is not eligible for rescudeule. The Loan name is : '+lAtobeUpdated.Name;                
                    rescheduleBatch.loan__Batch_Id__c = 'ForBearanceLoanHelper';
                    insert rescheduleBatch;
                    return res; //don't process the loan if it is not eligible for rescheduling
                    
                }
                Date repaymentDueDate; //LSP-1104 - Created variable to set the due date from the amortization schedule
                //set repayment date
                Integer limitNumber = Integer.valueOf(numberOfSkips)+1;
                // Integer dueDateNumber =  Integer.valueOf(numberOfSkips)-1;
                System.debug('/ '+numberOfSkips + ' limit:'+limitNumber + ' lAtobeUpdated.Id: '+lAtobeUpdated.Id +' systemDate: '+systemDate);  
                if(lAtobeUpdated!= null && lAtobeUpdated.loan__Loan_Status__c == 'Active - Good Standing'){
                    List<loan__Repayment_Schedule__c> amortSchedule = [select id, name,
                                                                       loan__Due_Date__c,
                                                                       loan__is_Archived__c,
                                                                       loan__isPaid__c,
                                                                       loan__Is_Billed__c
                                                                       from loan__Repayment_Schedule__c
                                                                       where loan__Loan_Account__r.Id = :lAtobeUpdated.Id
                                                                       AND loan__is_Archived__c = false
                                                                       AND loan__isPaid__c = false
                                                                       AND loan__due_date__c >= :systemDate
                                                                       order by loan__Due_Date__c asc limit :limitNumber];
                    if(amortSchedule.size()>0){                                                
                        repaymentStartDate = amortSchedule.get(Integer.valueOf(numberOfSkips)).loan__due_date__c;
                        repaymentDueDate = amortSchedule.get(0).loan__due_date__c; //LSP-1104 - Setting the first due date which is not yet archived and paid from the repayment schedule
                    }
                    system.debug('repaymentStartDate is: '+repaymentStartDate);
                }
                
                /* START-LSP-292 Block3 
    * Setting the repaymentStartDate for bad standing loans. 
    * Check the repayment schedules for the last unpaid schedule, and fetch the date and add the number of skips
    */
                if(lAtobeUpdated!= null && lAtobeUpdated.loan__Loan_Status__c == 'Active - Bad Standing' && isFromAPI){
                    List<loan__Repayment_Schedule__c> amortSchedule = [select id, name,
                                                                       loan__Due_Date__c,
                                                                       loan__is_Archived__c,
                                                                       loan__isPaid__c,
                                                                       loan__Is_Billed__c
                                                                       from loan__Repayment_Schedule__c
                                                                       where loan__Loan_Account__r.Id = :lAtobeUpdated.Id
                                                                       AND loan__is_Archived__c = false
                                                                       AND loan__isPaid__c = false
                                                                       AND loan__due_date__c <= :systemDate
                                                                       order by loan__Due_Date__c asc];
                    if(amortSchedule.size()>0){                                                
                        repaymentStartDate = (amortSchedule.get(0).loan__due_date__c).addMonths(numberOfSkips);
                        repaymentDueDate = amortSchedule.get(0).loan__due_date__c; //LSP-1104 - Setting the first due date which is not yet archived and paid from the repayment schedule
                    }
                }
                system.debug('repaymentStartDate is: '+repaymentStartDate);
                /*END-LSP-292 Block3*/
                
                lastPaymentDate = (lAtobeUpdated.loan__Maturity_Date_Current__c).addMonths(numberOfSkips);//loan__Last_Installment_Date__c
                interestRate = lAtobeUpdated.loan__Interest_Rate__c;
                frequencyOfPayment = lAtobeUpdated.loan__Frequency_of_Loan_Payment__c;
                if(repaymentStartDate != null)
                    dueDay = repaymentStartDate.day();
                
                System.debug(logginglevel.DEBUG,'lastPaymentDate: '+lastPaymentDate +' DUEDAY: '+dueDay);
                
                Integer terms = getRemainingTerm(repaymentDueDate); //LSP-1104 - Passing the due date as a parameter to calculate remaining no of terms
                
                if(lAtobeUpdated.loan__Repayment_Plan__r != null && lAtobeUpdated.loan__Repayment_Plan__r.size() != 0) {
                    delete lAtobeUpdated.loan__Repayment_Plan__r;
                }
                
                List<clcommon__Repayment_Plan__c> repaymentPlan = new List<clcommon__Repayment_Plan__c>();
                repaymentPlan.add(new clcommon__Repayment_Plan__c(clcommon__Sequence_Number__c = 1,
                                                                  clcommon__Payment_Type__c = 'Equal Monthly Installments',
                                                                  clcommon__Payment_Amount__c = lAtobeUpdated.loan__Pmt_Amt_Cur__c,
                                                                  //clcommon__Payment_Start_Date__c = Date.newInstance(paymentDate.year(),paymentDate.month(),paymentDate.day()).addMonths(NumberOfMonthsToSkip),//Anusha
                                                                  clcommon__Payment_Start_Date__c = repaymentStartDate,
                                                                  clcommon__Number_Of_Payments__c = terms,
                                                                  clcommon__Due_Day__c = dueDay,
                                                                  clcommon__Effective_Date__c = systemDate,
                                                                  loan__Loan_Account__c = lAtobeUpdated.id));
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
                
                //check if reschedule is successful. If reschedule is a failure, then control will goto catch block and code after this doesn't get executed
                
                System.debug('Call to rescheduleALoan of loanAction ends..');
                lAtobeUpdated.loan__Next_Installment_Date__c = repaymentStartDate;
                lAtobeUpdated.loan__Maturity_Date_Current__c = lastPaymentDate;
                if(((lAtobeUpdated.loan__Loan_Status__c).equals('Active - Good Standing')) || 
                isFromAPI && (((lAtobeUpdated.loan__Loan_Status__c).equals('Active - Bad Standing'))) ){ //LSP-292 - Update Mod fields for badstanding loans
                       
                       /*LSP-3 start */
                       if(lAtobeUpdated.U_LoanModForbearance__c == null) lAtobeUpdated.U_LoanModForbearance__c = 0;
                       
                       /************************************************************
    Check if skip-a-pay is already done and current request is an extension to previous skip-a-pay.
    1. Dont change U_LoanModForbearDt__c in case of extension
    2. Add new number of skips to previous U_LoanModForbearance__c in case of extension
    Conditions to check if current skip-a-pay is an extenion to previous one:
    1. Skipped_a_Pay__c flag should be true
    2. previous U_LoanModForbearDt__c + previous number of skips should be equal to previous loan__Oldest_Due_Date__c. If its not equal,
    then loan__Oldest_Due_Date__c on the contract is changed because of repayment. so current skip-a-pay is not an extension
    [Note: Whenever skip-a-pay is performed U_LoanModForbearDt__c, U_LoanModForbearance__c and loan__Oldest_Due_Date__c are updated.
    loan__Oldest_Due_Date__c also gets updated whenever repayment is done on the contract.]
    *************************************************************/
                      
                       if(lAtobeUpdated.Skipped_a_Pay__c == true && lAtobeUpdated.U_LoanModForbearDt__c != null && lAtobeUpdated.loan__Oldest_Due_Date__c != null
                          && (lAtobeUpdated.U_LoanModForbearDt__c.addMonths(Integer.valueOf(lAtobeUpdated.U_LoanModForbearance__c)) == lAtobeUpdated.loan__Oldest_Due_Date__c)){
                              System.debug('This is an extension to already performed skip a pay. Hence not changing U_LoanModForbearDt__c. Adding the extended number of skips to U_LoanModForbearance__c');
                              lAtobeUpdated.U_LoanModForbearance__c = lAtobeUpdated.U_LoanModForbearance__c + numberOfSkips;
                          }else{
                              Date newLoanModForbearDt = (lAtobeUpdated.loan__Oldest_Due_Date__c == null ? lAtobeUpdated.loan__First_Installment_Date__c : lAtobeUpdated.loan__Oldest_Due_Date__c);
                              sapdaysDifference = (lAtobeUpdated.U_LoanModForbearDt__c == null || newLoanModForbearDt == null)? null : newLoanModForbearDt.daysBetween(lAtobeUpdated.U_LoanModForbearDt__c);
                              lAtobeUpdated.U_LoanModForbearDt__c = newLoanModForbearDt;
                              lAtobeUpdated.U_LoanModForbearance__c = numberOfSkips;
                              if(lAtobeUpdated.Skipped_a_Pay__c == false){
                                lAtobeUpdated.Hardship_Request_Date__c = systemDate;
                              }
                          }
                       /*LSP-3 end */
                       
                       lAtobeUpdated.loan__Oldest_Due_Date__c = repaymentStartDate;
                       /* START LSP-836 - The below block checks if the difference between last skipped date and the transaction date
                            1- If the difference is greater than 45 days - the hardship date is set to the system date
                            2- Hardship date is not altered otherwise if the difference is less than 45 days
                            START LPC-6 - Hardship Request Date not being updated with new requests
                            3- Hardship_Request_Date__c should be filled if it is null
                            4- Rules 1 and 2 mentioned above are no longer valid, the 45 days difference is applied between the current and new Loan Mod Forbearance Start Date */
                       
                        if((sapdaysDifference!=null && sapdaysDifference > SAP_CHECK_DAYS) || !lAtobeUpdated.Skipped_a_Pay__c 
                            || lAtobeUpdated.Hardship_Request_Date__c == null){
                              lAtobeUpdated.Hardship_Request_Date__c = systemDate;
                        }
                       /*END LSP-836*/
                       lAtobeUpdated.Skipped_a_Pay__c = true;
                   }
                
                lAtobeUpdated.Skipped_a_pay_Date__c = systemDate;//updating date on which skip-a-pay is performed
                lAtobeUpdated.Hardship_New_Maturity_Date__c = lAtobeUpdated.Hardship_New_Maturity_Date__c != null ? (lAtobeUpdated.Hardship_New_Maturity_Date__c).addMonths(Integer.valueOf(numberOfSkips)) : lastPaymentDate; //lastPaymentDate = (lAtobeUpdated.loan__Maturity_Date_Current__c).addMonths(numberOfSkips);
                lAtobeUpdated.U_LoanModTermExt__c = lAtobeUpdated.U_LoanModTermExt__c != null ? lAtobeUpdated.U_LoanModTermExt__c + Integer.valueOf(numberOfSkips):Integer.valueOf(numberOfSkips);
                
                update lAtobeUpdated;
                res.statusCode = 204;
                return res;
                
            } catch (Exception e) {          
                batch.loan__Log_Level__c = 'ERROR';
                batch.loan__Message__c = ' Reschedule Failed for ::'+ lAtobeUpdated.Name + '. :: ERROR :: '+e.getMessage() + ' :: StackTrace ::' +e.getStackTraceString() ;
                batch.loan__Batch_Id__c = 'ForBearanceLoanHelper';
                insert batch;
                contractSAPerror.put(lAtobeUpdated.Name,batch.loan__Message__c); //CRM-952
                System.debug(logginglevel.error,'line number'+e.getLineNumber());
                System.debug(logginglevel.error,'error stackTrace'+e.getStackTraceString());
                System.debug(logginglevel.error,'error message'+e.getMessage());
                
                res.statusCode = 500;
                res.responseBody = Blob.valueOf('{"message": "' + batch.loan__Message__c + '"}');
                return res;
            }
            
        }
        
        /*
    *  Calculates remaining number of payments to be done
    *  returns integer
    *
    */
        public Integer getRemainingTerm(Date repaymentDueDate) {
            
            Integer remainingTerm;
            //START:LSP-1104 - Replaced Next Due Date field on contract with due date passed as a parameter to the method
            if (repaymentDueDate != null && lAtobeUpdated.loan__Maturity_Date_Current__c != null) {
                remainingTerm = (Integer)(loan.DateUtil.cyclesBetween(repaymentDueDate,
                                                                      lAtobeUpdated.loan__Maturity_Date_Current__c,
                                                                      lAtobeUpdated.loan__Frequency_of_Loan_Payment__c)
                                         );
            }
            //END:LSP-1104 - Replaced Next Due Date field on contract with due date passed as a parameter to the method
            return remainingTerm;
        }
        
    /*
    *  Checks if NACHA is already sent for payment
    *  returns: boolean
    *
    */
        public boolean checkIfNachaisSent(){
            System.debug('Checking if Nacha is sent..');
            boolean isSentToNacha = false;
            List<loan__Loan_Payment_Transaction__c> lpt = [Select Id,Name,
                                                           loan__Loan_Account__c,
                                                           Loan__loan_account__r.Name,
                                                           loan__Rejected__c,
                                                           loan__Reversed__c,
                                                           loan__Transaction_Date__c,
                                                           loan__Sent_to_ACH__c,
                                                           loan__Cleared__c
                                                           From loan__Loan_Payment_Transaction__c
                                                           WHERE loan__Loan_Account__r.Id = :lAtobeUpdated.Id
                                                           AND loan__Cleared__c = false
                                                           AND loan__Rejected__c = false
                                                           AND loan__Reversed__c = false
                                                           order by loan__Transaction_Date__c desc  //pallavi(added order by)
                                                          ];
            if(lpt.size() > 0){
                
                if(lpt.get(0).loan__Sent_to_ACH__c == true){//skip the loan
                    isSentToNacha = true;
                    System.Debug('isSentToNacha: ' + lpt.get(0).name);
                    System.Debug('isSentToNacha: ' + isSentToNacha);
                    return isSentToNacha;
                } else{
                    //once we get the unprocessed payment and if isSentToNacha = false, check if the loan is eligible for reschedule
                    checkIfLoanisEligibleForReschedule(lpt.get(0));
                    System.Debug('isEligibleForReschedule: ' + isEligibleForReschedule);
                }
            }
            else        //pallavi(added else or else isEligibleForReschedule will always be true)
                isEligibleForReschedule = true; //if there are no payments created, do reshedule the loan
            return false;
        }
        
    /*
    *
    * Method to check whether the loan is eligible for reschedule
    *
    */
        public void checkIfLoanisEligibleForReschedule(loan__Loan_Payment_Transaction__c lpt){
            Date paymentTxnDate = lpt.loan__Transaction_Date__c;
            System.debug('paymentTxnDate: ' + paymentTxnDate +' and systemDate: '+systemDate);
            // if(paymentTxnDate >= systemDate){//reject the loan and then reschedule
            if((paymentTxnDate >= systemDate) ||
               ((paymentTxnDate < systemDate) && isFromAPI  && (lAtobeUpdated.loan__Loan_Status__c == 'Active - Bad Standing'))){ // reject the loan and then reschedule
                   //LSP-292 - Bad standing loans can have payment transaction date less than system date.
                   System.debug('isEligibleForReschedule is true'); //pallavi
                   lpt.loan__Rejected__c = true;
                   lpt.loan__Sent_to_ACH__c = true;
                   lpt.loan__Sent_To_ACH_On__c = systemDate;
                   lpt.loan__ACH_Filename__c = 'SkipAPayjobFileDiscard';
                   update lpt;
                   isEligibleForReschedule = true;
               }else{//if(paymentTxnDate < systemDate){
                    loan__Batch_Process_Log__c rescheduleFailBatch = new loan__Batch_Process_Log__c(); 

                   rescheduleFailBatch.loan__Log_Level__c = 'ERROR';
                   rescheduleFailBatch.loan__Message__c = 'There is an unprocessed payment on this contract, hence the loan cannot be rescheduled ::'+ lAtobeUpdated.Name;                
                   rescheduleFailBatch.loan__Batch_Id__c = 'ForBearanceLoanHelper';
                   insert rescheduleFailBatch;
                   contractSAPerror.put(lAtobeUpdated.Name,rescheduleFailBatch.loan__Message__c); //CRM-952
                   isEligibleForReschedule = false;    
               }
        }
    }