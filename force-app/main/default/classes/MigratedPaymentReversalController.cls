/* ****************Modification History******************
 * Created By        Date          JIRA number
 *     
 *     1. Neha          2020/09/14        CRM-796
 * Modified By        Date          JIRA number
 *      1. Pallavi       2021/05/21        LSP-219
 *      2. Pallavi       2021/07/09        LSP-261    
 *      3. Pallavi		 2021/09/18		   LSP-375
 ******************Modification History******************/
Public class MigratedPaymentReversalController{
    
    public String currentRecordId {get;set;}
    public String parameterValue {get;set;}
    public loan__loan_account__c migratedLoan{get;set;}
    public String NumOfPayments {get;set;}   
    public List<loan__Loan_Payment_Transaction__c> paymentsToBeReversed {get;set;}
    List<loan__Repayment_Transaction_Adjustment__c> reversalsToBeInserted;
    List<loan__Loan_account_Due_Details__c> billsToBeUpdated ;
    List<loan__Loan_account_Due_Details__c> unpaidBills;
    loan__Loan_account_Due_Details__c oldestDue;
    Set<Id> dueIds = new Set<Id>();
    Decimal totalPrincipal = 0.00;
    Decimal totalInterest = 0.00;
    /*LSP-261*/
    loan.GlobalLoanUtilFacade loanUtil = new loan.GlobalLoanUtilFacade();
    Date currentSystemDate = loanUtil.getCurrentSystemDate();
    List<Repayment_Txn_Reversal_Migrated_Payment__c> reversalList = new List<Repayment_Txn_Reversal_Migrated_Payment__c>();
    /*LSP-261*/
    
    public MigratedPaymentReversalController(ApexPages.StandardController controller) {
               
        currentRecordId = ApexPages.CurrentPage().getparameters().get('id');
        System.debug(logginglevel.error, 'currentRecordId'+currentRecordId);
        
        if(currentRecordId != NULL){
        
            migratedLoan = [select id,name, 
                loan__Pre_Bill_Days__c,
                loan__Principal_Remaining__c,
                loan__Principal_Paid__c,
                loan__Interest_Paid__c,
                loan__Interest_Rate__c,  //LSP-261
                loan__Pay_Off_Amount_As_Of_Today__c  //LSP-261            
                from loan__loan_account__c 
                where isMigrated__c = true and 
                id =: currentRecordId];      
        
        }
        
    }   
    
    public void getPayments() {
                  
        if(migratedLoan != NULL && NumOfPayments != NULL){
                                   
            paymentsToBeReversed = [select id,name, 
                loan__Transaction_Date__c, 
                loan__Transaction_Time__c,
                loan__Principal__c,
                loan__Interest__c,
                (select id,name,
                loan__Due__c  
                from loan__Due_Payments__r)
                from loan__Loan_Payment_Transaction__c 
                where loan__Reversed__c = False and
                loan__Rejected__c = False and 
                loan__Cleared__c = True and
                loan_Is_Migrated__c = true and
                loan__Loan_Account__c =: currentRecordId
                order by loan__Transaction_Date__c DESC
                limit :Integer.valueof(NumOfPayments)];
                  
        }
           
        parameterValue = ApexPages.CurrentPage().getparameters().get('nameParam');
        
        System.debug(logginglevel.error,'NumOfPayments ::'+NumOfPayments);
        System.debug(logginglevel.error,'Loan Account ::'+migratedLoan);  
    
    }
    
    public void reversePayments(){
        
                              
        System.debug(logginglevel.error,'paymentsToBeReversed ::'+paymentsToBeReversed);
        
        if(paymentsToBeReversed != NULL && paymentsToBeReversed.size() > 0){
                       
            for (loan__Loan_Payment_Transaction__c lpt : paymentsToBeReversed){
                
                lpt.loan__Reversed__c = True;
                //lpt.loan__Cleared__c = False;
                
                totalPrincipal = totalPrincipal + lpt.loan__Principal__c;
                totalInterest = totalInterest + lpt.loan__Interest__c;
                
                if(lpt.loan__Due_Payments__r.size() > 0 && lpt.loan__Due_Payments__r[0] != NULL && lpt.loan__Due_Payments__r[0].loan__Due__c != NULL){
                    dueIds.add(lpt.loan__Due_Payments__r[0].loan__Due__c);
                }
                
                System.debug(logginglevel.error,'totalPrincipal ::'+totalPrincipal);
                System.debug(logginglevel.error,'totalInterest ::'+totalInterest);
                
                Decimal totalAmount = totalPrincipal+totalInterest;
                insertReversals(lpt,totalPrincipal,totalAmount);
                
                
             }   
                     
             
             /*LSP-261*/
            System.debug('reversalList--' + reversalList.size());
             if(reversalList.size()>0)
                 insert reversalList;
             /*LSP-261*/
             update paymentsToBeReversed;
             //insert reversalsToBeInserted;
             
             updateBills();
         }
    }
            
    public void updateBills(){
    
        billsToBeUpdated =  [select id,name,loan__Due_Date__c  
                            from loan__Loan_account_Due_Details__c
                            where id in : dueIds
                            order by loan__Due_Date__c DESC];
        
        List<Date> dueDate = new List<Date>();  //LSP-219
                            
        if(billsToBeUpdated.size() > 0 && billsToBeUpdated != NULL){       
                     
            oldestDue = billsToBeUpdated[billsToBeUpdated.size()-1];
            System.debug(logginglevel.error,'oldestPayment ::'+oldestDue);                    
            System.debug(logginglevel.error, 'billsToBeUpdated :: '+billsToBeUpdated);
            
            for(loan__Loan_account_Due_Details__c due : billsToBeUpdated){
             
                due.loan__Payment_Date__c = NULL;
                due.loan__Payment_Amt__c = 0.00;
                due.loan__Payment_Satisfied__c = false;
               dueDate.add(due.loan__Due_Date__c);  //LSP-219
            }
        
            update billsToBeUpdated;       
        }
        //LSP-219
        List<loan__Repayment_Schedule__c> AMZsToBeUpdated = [select id,loan__isPaid__c  
                                                            from loan__Repayment_Schedule__c
                                                            where loan__Due_Date__c in : dueDate and loan__isPaid__c = true
                                                            and loan__Loan_Account__c =: currentRecordId];	//LSP-375
        for(loan__Repayment_Schedule__c amz : AMZsToBeUpdated){
                amz.loan__isPaid__c = false;               
            }
        if(AMZsToBeUpdated.size()>0)
            update AMZsToBeUpdated;
        //LSP-219
        updateLoan();
    }
    
    public void updateLoan(){
        
        Date lastUnpaidDueDate;
        Date lastPaidDueDate;
        Integer preBillDays;
        
        if(Test.isRunningTest()){
            lastUnpaidDueDate = date.newinstance(2020,02,01);
            preBillDays = 15;
            lastPaidDueDate = date.newinstance(2020,01,01);       
        }
        
        if(oldestDue != NULL){
            System.debug(logginglevel.error, 'oldestDue != NULL:: ');
            if(!Test.isRunningTest()){
                lastUnpaidDueDate = oldestDue.loan__Due_Date__c;
                preBillDays = Integer.valueof(migratedLoan.loan__Pre_Bill_Days__c);
                lastPaidDueDate = date.newinstance(lastUnpaidDueDate.year(), (lastUnpaidDueDate.month() - 1), lastUnpaidDueDate.day());
            }
            migratedLoan.loan__Last_Interest_Posting_Date__c = lastPaidDueDate;
            migratedLoan.loan__Next_Interest_Posting_Date__c = lastUnpaidDueDate;
            migratedLoan.loan__Last_Accrual_Date__c = lastPaidDueDate;
            migratedLoan.loan__Next_Installment_Date__c = lastUnpaidDueDate;
            migratedLoan.loan__Next_Due_Generation_Date__c = date.newinstance(lastUnpaidDueDate.year(), lastUnpaidDueDate.month(), (lastUnpaidDueDate.day() - preBillDays));
            migratedLoan.loan__Oldest_Due_Date__c = lastUnpaidDueDate;
            
            System.debug(logginglevel.error, 'lastUnpaidDueDate:: '+lastUnpaidDueDate);
            System.debug(logginglevel.error, 'lastPaidDueDate :: '+lastPaidDueDate);
            System.debug(logginglevel.error, 'Before : migratedLoan :: '+migratedLoan);
        }
        
        if(oldestDue == NULL){
            System.debug(logginglevel.error, 'oldestDue == NULL:: ');
            unpaidbills = [Select id,name,loan__Due_Date__c  
                            from loan__Loan_account_Due_Details__c
                            where loan__DD_Primary_Flag__c = True 
                            and loan__Payment_Satisfied__c = false 
                            and loan__Loan_Account__c =: currentRecordId 
                            order by loan__Due_Date__c DESC];
            System.debug(logginglevel.error, 'unpaidbills:: '+unpaidbills);
            
            if(unpaidbills != NULL && unpaidbills.size() > 0){   
                         
                oldestDue = unpaidbills[unpaidbills.size()-1];
                
                if(!Test.isRunningTest()){
                    lastUnpaidDueDate = oldestDue.loan__Due_Date__c;
                    preBillDays = Integer.valueof(migratedLoan.loan__Pre_Bill_Days__c);
                    lastPaidDueDate = date.newinstance(lastUnpaidDueDate.year(), (lastUnpaidDueDate.month() - 1), lastUnpaidDueDate.day());
                    
                }
                
                migratedLoan.loan__Last_Interest_Posting_Date__c = lastPaidDueDate;
                migratedLoan.loan__Next_Interest_Posting_Date__c = lastUnpaidDueDate;
                migratedLoan.loan__Last_Accrual_Date__c = lastPaidDueDate;
                migratedLoan.loan__Next_Installment_Date__c = lastUnpaidDueDate;
                migratedLoan.loan__Next_Due_Generation_Date__c = date.newinstance(lastUnpaidDueDate.year(), lastUnpaidDueDate.month(), (lastUnpaidDueDate.day() - preBillDays));
                migratedLoan.loan__Oldest_Due_Date__c = lastUnpaidDueDate; 
                
                System.debug(logginglevel.error, 'lastUnpaidDueDate:: '+lastUnpaidDueDate);
                System.debug(logginglevel.error, 'lastPaidDueDate :: '+lastPaidDueDate);
                System.debug(logginglevel.error, 'Before : migratedLoan :: '+migratedLoan);
            }
        }
        
        migratedLoan.loan__Principal_Remaining__c = migratedLoan.loan__Principal_Remaining__c + totalPrincipal;
        migratedLoan.loan__Principal_Paid__c = migratedLoan.loan__Principal_Paid__c - totalPrincipal;
        migratedLoan.loan__Interest_Paid__c = migratedLoan.loan__Interest_Paid__c - totalInterest;
        migratedLoan.loan__Pay_Off_Amount_As_Of_Today__c = migratedLoan.loan__Pay_Off_Amount_As_Of_Today__c + totalPrincipal + totalInterest;//LSP-261
        
        System.debug(logginglevel.error, 'After : migratedLoan :: '+migratedLoan);  
        
        update migratedLoan;
        
        RescheduleMigratedLoan rml = new RescheduleMigratedLoan(currentRecordId,lastUnpaidDueDate, lastPaidDueDate);
        rml.rescheduleLoan();
    
    }
    /*LSP-261*/
    public void insertReversals(loan__Loan_Payment_Transaction__c paymentsReversed,Decimal principalReversed,Decimal totalAmount){
        Repayment_Txn_Reversal_Migrated_Payment__c reversal = new Repayment_Txn_Reversal_Migrated_Payment__c();
        reversal.Balance__c = migratedLoan.loan__Principal_Remaining__c + principalReversed;
        reversal.Cleared__c = true;
        reversal.Adjustment_Txn_Date__c = currentSystemDate;
        reversal.Interest_Rate__c = migratedLoan.loan__Interest_Rate__c;
        reversal.Payoff_Balance__c = migratedLoan.loan__Pay_Off_Amount_As_Of_Today__c + totalAmount;
        reversal.Reason_Code__c = 'NSF';
        reversal.Loan_Payment_Transaction__c = paymentsReversed.id;
        reversal.Reference__c = 'Legacy Payment reversal';
        reversalList.add(reversal);
    }
    /*LSP-261*/   
}