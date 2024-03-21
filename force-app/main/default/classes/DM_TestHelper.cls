public class DM_TestHelper {
    public static loan__Loan_Product__c createLoanProduct(
                                       String name,
                                       loan__Office_Name__c dummyOffice,
                                       loan__MF_Account__c dummyAcccount,
                                       loan__Currency__c curr,
                                       loan__Fee_Set__c dummyFeeSet,
                                       String productType) {
        Id prodRTId = Schema.SObjectType.loan__Loan_Product__c.getRecordTypeInfosByName().get('Loan Product Record Type').getRecordTypeId();
        
        loan__Loan_Product__c dummyLP = new loan__Loan_Product__c(Name=name,
            loan__Loan_Product_Type__c = productType,
            loan__Currency__c = (curr != null) ? curr.ID : null,
            loan__Fee_Set__c = (dummyFeeSet != null) ? dummyFeeSet.ID : null,
            loan__Accrual_Based_Accounting__c=true,
            loan__Accrue_Income_On_Suspended_Account__c=true,
            loan__Cash_Based_Accounting__c=false,
            loan__Maximum_Gap_Between_Installments__c=1,
            loan__Minimum_Gap_Between_Installments__c=1,
            loan__Max_Loan_Amount__c=30000,
            loan__Max_Overdue_Interest_Rate__c=24,
            loan__Minimum_Installment_Amount__c=100,
            loan__Min_Interest_Rate__c=1,
            loan__Min_Loan_Amount__c=0,
            loan__Min_Number_of_Installments__c=0,
            loan__Min_Overdue_Interest_Rate__c=10,
            loan__Product_Interest_Income_Account__c=dummyAcccount.Id,
            loan__Product_Int_On_Overdue_Income_Acc__c=dummyAcccount.Id,
            loan__Product_Loan_Control_Account__c=dummyAcccount.Id,
            loan__Product_Loan_Loss_Provision_Account__c=dummyAcccount.Id,
            loan__Product_Loan_Loss_Reserve_Account__c=dummyAcccount.Id,
            loan__Product_Overdue_Interest_Account__c=dummyAcccount.Id,
            loan__Product_Suspended_Interest_Account__c=dummyAcccount.Id,
            loan__Product_Suspended_Int_On_Overdue_Acc__c=dummyAcccount.Id,
            loan__Product_Write_Off_Recovery_Account__c=dummyAcccount.Id,
            loan__Product_Interest_Amortization_Account__c=dummyAcccount.Id,
            loan__Product_Excess_Account__c=dummyAcccount.Id,
            loan__Status__c='Active',
            recordTypeId=prodRTId
        );
            return dummyLP;
        }
    
        public static DM_Loan_Account__c createDMLOC(loan__Loan_Product__c dummyLP,
                                                         Decimal creditLimit,
                                                         Account dummyAccount,
                                                         loan__Fee_Set__c dummyFeeSet,
                                                         loan__Office_name__c dummyOffice,
                                                         Integer term,
                                                         String interestCalcMethod
                                                         ) {
            DM_Loan_Account__c loanAccount = new DM_Loan_Account__c();
            loanAccount.DM_Product_Type__c = 'Simple Loan';
            loanAccount.DM_Loan_Amount__c = 0;
            loanAccount.DM_Credit_Limit__c = creditLimit;
            loanAccount.DM_Credit_Limit_Current__c = creditLimit;
            loanAccount.migration_Status__C='Pending';   
            loanAccount.DM_Account__c= dummyAccount.Id; 
            if(dummyLP.Name =='Simple Loan'){     
                loanAccount.Batch_Type__c='Simple Loan'; 
                loanAccount.dm_custom_field_1__c = '12-12-2018';
                loanAccount.dm_custom_field_2__c = 'true';
                loanAccount.dm_custom_field_3__c = '1800';
                loanAccount.dm_custom_field_4__c = 'Testing';
                loanAccount.dm_custom_field_5__c = '123';
                loanAccount.dm_custom_field_6__c= 'false';
                if(interestCalcMethod =='Error'){ 
                    system.debug('Calc name error');
                    loanAccount.Batch_Type__c='Error';
                } 
            }    
            else if(dummyLP.Name =='Difficult Loan'){ 
                loanAccount.Batch_Type__c='Difficult Loan';
                loanAccount.dm_custom_field_1__c = 'True';
            }  
            loanAccount.DM_Number_of_Installments__c = term;
            loanAccount.DM_Contractual_Interest_Rate__c = loanAccount.DM_Interest_Rate__c;
            loanAccount.DM_Fee_Set__c = (dummyFeeSet != null) ? dummyFeeSet.ID : null;
            loanAccount.DM_Product__c = dummyLP.ID;
            loanAccount.DM_Overdue_Interest_Rate__c = 12;
            loanAccount.DM_Expected_Disbursal_Date__c = Date.today().addDays(-20);
            loanAccount.DM_Repayment_Tied_to_Meeting_Schedule__c = false;
            loanAccount.DM_Repayment_Procedure__c = 'Equal Monthly Installments';
            loanAccount.DM_Interest_Calculation_Method__c = interestCalcMethod;
            loanAccount.DM_Expected_Repayment_Start_Date__c = Date.today().addDays(31);//Date.today().addDays(-5);	//pallavi(test class was failing)
            loanAccount.DM_Branch__c = dummyOffice.ID;
            loanAccount.DM_Oldest_Due_Date__c = loanAccount.DM_Expected_Repayment_Start_Date__c;
            loanAccount.DM_First_Installment_Date__c = loanAccount.DM_Expected_Repayment_Start_Date__c;
            loanAccount.DM_Next_Installment_Date__c = loanAccount.DM_First_Installment_Date__c;
            loanAccount.DM_Disbursal_Date__c = loanAccount.DM_Expected_Disbursal_Date__c;
            loanAccount.DM_Term_Cur__c = loanAccount.DM_Number_of_Installments__c;
            loanAccount.DM_Principal_Remaining__c = 0;
            Integer dueday = loanAccount.DM_First_Installment_Date__c.day();
            loanAccount.DM_Due_Day__c = dueday;
            loanAccount.DM_Contractual_Due_Day__c = dueday;
            loanAccount.DM_Interest_Only_Period__c = 0;
            loanAccount.DM_Interest_Only_Payment_Amt__c = 0;
            loanAccount.DM_Loan_Account_External_Id__c = string.valueOf(math.random()).right(4);//'1234';		//pallavi
            loanAccount.dm_Skipped_a_Pay__c = true;	//LSP-22                                                 
            System.debug('loanAccount----' + loanAccount.id);                                                 
            return loanAccount;
    }//END createDMLOC
    
    public static DM_Loan_Disbursal_Transaction__c fundLoan(DM_Loan_Account__c loanAccount,
                                                         Date currentSystemDate,
                                                         loan__Payment_Mode__c pmode,
                                                         loan__Bank_Account__c bankAccount
                                                        ) {

        DM_Loan_Disbursal_Transaction__c disbTxn = new DM_Loan_Disbursal_Transaction__c();
        disbTxn.DM_Disbursal_Date__c = currentSystemDate;
        disbTxn.DM_Disbursed_Amt__c = loanAccount.DM_Loan_Amount__c;
        disbTxn.DM_CL_Contract__c = loanAccount.id;
        disbTxn.DM_Mode_of_Payment__c =  pMode.id;
        disbTxn.DM_bank_Account__c = bankAccount.id;
        disbTxn.DM_External_Id__c = '123';                                                            
        return disbTxn;
    }//END fundLoan
    
    /*pallavi*/
    public static DM_Loan_Disbursal_Transaction__c fundLoan1(DM_Loan_Account__c loanAccount,
                                                         Date currentSystemDate,
                                                         loan__Payment_Mode__c pmode,
                                                         loan__Bank_Account__c bankAccount
                                                        ) {

        DM_Loan_Disbursal_Transaction__c disbTxn = new DM_Loan_Disbursal_Transaction__c();
        disbTxn.DM_Disbursal_Date__c = currentSystemDate;
        disbTxn.DM_Disbursed_Amt__c = loanAccount.DM_Loan_Amount__c;
        disbTxn.DM_CL_Contract__c = loanAccount.id;
        disbTxn.DM_Mode_of_Payment__c =  pMode.id;
        disbTxn.DM_bank_Account__c = bankAccount.id;
        disbTxn.DM_External_Id__c = '1234';                                                            
        return disbTxn;
    }//END fundLoan1
    /*pallavi*/
    
    public static DM_Automated_Payment_Setup__c createAutomatedPaymentSetup(String type,
                                                                          String amountType,
                                                                          loan__Bank_Account__c bank,
                                                                          DM_Loan_Account__c lAcc,
                                                                          String frequency,
                                                                          loan__Payment_Mode__c pMode,
                                                                          Date debitDate,
                                                                          Integer debitDay) {
        DM_Automated_Payment_Setup__c automatedPaymentSetup = new DM_Automated_Payment_Setup__c();
        automatedPaymentSetup.DM_Active__c = true;
        automatedPaymentSetup.DM_Amount_Type__c = amountType;
        automatedPaymentSetup.DM_Bank_Account__c = bank.id;
        automatedPaymentSetup.DM_CL_Contract__C = lAcc.Id;
        automatedPaymentSetup.DM_Frequency__c = frequency;
        automatedPaymentSetup.DM_Payment_Mode__c = pMode.Id;
        automatedPaymentSetup.DM_Recurring_ACH_End_Date__c = debitDate.addDays(180);
        automatedPaymentSetup.DM_Type__c = type;
        automatedPaymentSetup.DM_Recurring_ACH_Start_Date__c = debitDate;
        automatedPaymentSetup.DM_Debit_Date__c = debitDate;
        automatedPaymentSetup.DM_External_Id__c = '123';
        
        return automatedPaymentSetup;
    }
    
    public static DM_Bill__c createUnpaidDue(DM_Loan_Account__c loanAccount, Decimal dueAmount) {
        DM_Bill__c due = new DM_Bill__c(DM_CL_Contract__c = loanAccount.Id,
                                        DM_Due_Amt__c = dueAmount,
                                        DM_Due_Date__c = Date.Today(),
                                        DM_Due_Type_Description__c = 'BILL',
                                        DM_Due_Type__c = 1,
                                        DM_External_Id__c='123');
        return due;
    }//END createUnpaidDue
    /*pallavi*/
    public static DM_Bill__c createUnpaidDue1(DM_Loan_Account__c loanAccount, Decimal dueAmount) {
        DM_Bill__c due = new DM_Bill__c(DM_CL_Contract__c = loanAccount.Id,
                                        DM_Due_Amt__c = dueAmount,
                                        DM_Due_Date__c = Date.Today(),
                                        DM_Due_Type_Description__c = 'BILL',
                                        DM_Due_Type__c = 1,
                                        DM_External_Id__c='1234');
        return due;
    }//END createUnpaidDue1
    /*pallavi*/
    
    public static DM_Charge__c createUnpaidCharge(DM_Loan_Account__c loanAccount, loan__Fee__c fee, Decimal chargeAmount) {
        DM_Charge__c charge = new DM_Charge__c(DM_CL_Contract__c = loanAccount.Id,
                                            DM_Original_Amount__c = chargeAmount,
                                            DM_Date__c = Date.Today(),
                                            DM_Calculated_Interest3__c = chargeAmount,
                                            DM_Fee__c = fee.Id,
                                            DM_External_Id__c ='123');
        return charge;
    }//END createUnpaidCharge
    
     public static DM_Loan_Payment_Transaction__c createLoanPayment(Id lAccountId,
                                                            Decimal transactionAmount,
                                                            Date transDate,
                                                            DM_Automated_Payment_Setup__c aPS,
                                                            loan__Payment_Mode__c pMode,
                                                            Date retryOn) {
        DM_Loan_Payment_Transaction__c payment = new DM_Loan_Payment_Transaction__c();
        payment.DM_Transaction_Date__c = transDate;
        payment.DM_Transaction_Amount__c = transactionAmount;
        payment.CL_Contract__c = lAccountId;
        payment.DM_External_Id__c = '123';
        payment.DM_Receipt_Date__c= Date.today();                                                       
        payment.DM_Skip_Validation__c = true;
        if (aPS != null){
            payment.DM_Automated_Payment_Setup__c = aPS.Id;
            payment.DM_Payment_Mode__c = aPS.Payment_Mode__c;
        }
        loan__Payment_Mode__c pm = new loan__Payment_Mode__c();	//pallavi
        pm.name = 'ACH';
        insert pm;
        
        payment.DM_Payment_Mode__c = pm.id;	//pallavi                                                       
        return payment;
    }//END createLoanPaymentWithoutCommit
    
    /*pallavi*/
    public static DM_Loan_Payment_Transaction__c createLoanPayment1(Id lAccountId,
                                                            Decimal transactionAmount,
                                                            Date transDate,
                                                            DM_Automated_Payment_Setup__c aPS,
                                                            loan__Payment_Mode__c pMode,
                                                            Date retryOn) {
        DM_Loan_Payment_Transaction__c payment = new DM_Loan_Payment_Transaction__c();
        payment.DM_Transaction_Date__c = transDate;
        payment.DM_Transaction_Amount__c = transactionAmount;
        payment.CL_Contract__c = lAccountId;
        payment.DM_External_Id__c = '1234';
        payment.DM_Receipt_Date__c= Date.today();                                                       
        payment.DM_Skip_Validation__c = true;
        if (aPS != null){
            payment.DM_Automated_Payment_Setup__c = aPS.Id;
            payment.DM_Payment_Mode__c = aPS.Payment_Mode__c;
        }
        loan__Payment_Mode__c pm = new loan__Payment_Mode__c();	//pallavi
        pm.name = 'ACH';
        insert pm;
        
        payment.DM_Payment_Mode__c = pm.id;	//pallavi                                                       
        return payment;
    }//END createLoanPayment1WithoutCommit
    /*pallavi*/
  
    public static DM_Repayment_Schedule_Summary__c CreateRSSData(DM_Loan_Account__c loanAccount,Decimal Amount) {
        DM_Repayment_Schedule_Summary__c rss = new DM_Repayment_Schedule_Summary__c();
        rss.DM_RSS_No_Of_Pmts__c = 1;
        rss.DM_RSS_Repayment_Amt__c = amount;
        rss.DM_CL_Contract__c = loanAccount.id;
        rss.DM_RSS_Repayment_Dt__c =  Date.today().addDays(-1);
        rss.DM_External_Id__c = '123';
        rss.DM_RSS_Seq__c = 1;
        return rss;
    }//END CreateRSSData
    
    public static DM_Repayment_Schedule__c CreateAmzScheduleData(DM_Loan_Account__c loanAccount,Decimal Amount ) {
        DM_Repayment_Schedule__c repaySch = new DM_Repayment_Schedule__c();
        repaySch.DM_Loan_Product__c = loanAccount.Id;
        repaySch.DM_Due_Date__c = Date.Today().addDays(30);
        repaySch.DM_Due_Interest__c = 40.00 ;
        repaySch.DM_Balance__c = 800;
        repaySch.DM_Paid_Principal__c=amount;  
        repaySch.DM_External_Id__C = '123';   
        return repaySch;                                                
    }//END CreateAmzScheduleData 
    
    /*pallavi*/
    public static DM_Repayment_Schedule__c CreateAmzScheduleData1(DM_Loan_Account__c loanAccount,Decimal Amount ) {
        DM_Repayment_Schedule__c repaySch = new DM_Repayment_Schedule__c();
        repaySch.DM_Loan_Product__c = loanAccount.Id;
        repaySch.DM_Due_Date__c = Date.Today().addDays(30);
        repaySch.DM_Due_Interest__c = 40.00 ;
        repaySch.DM_Balance__c = 800;
        repaySch.DM_Paid_Principal__c=amount;  
        repaySch.DM_External_Id__C = '1234';   
        return repaySch;                                                
    }//END CreateAmzScheduleData 
    /*pallavi*/
    
    public static DM_Interest_Posting_Transaction__c create_DMInterestPostingTransaction(Id loanId,Date sysDate,
                                                                            Decimal principalPosted,Decimal interestPosted,
                                                                            Decimal principalPaid,Decimal interestPaid,
                                                                            boolean isCapitalized,Date capitalizationDate,
                                                                            Decimal paymentAmount,Date paymentDate,
                                                                            String transactionType,
                                                                            Boolean isBilled,
                                                                            Boolean isPosted,
                                                                            Date transactionPostingDate,
                                                                            Date transactionDueDate) {

        DM_Interest_Posting_Transaction__c ipt = new DM_Interest_Posting_Transaction__C();
        ipt.DM_CL_Contract__c = loanId;
        ipt.DM_Principal_Posted__c = principalPosted;
        ipt.DM_Principal_Paid__c = principalPaid;
        ipt.DM_Interest_Posted__c = interestPosted;
        ipt.DM_Interest_Paid__c = interestPaid;
        //ipt.DM_Is_Capitalized__c = isCapitalized;
        ipt.DM_Capitalization_Date__c = capitalizationDate;
        ipt.DM_Payment_Amount__c = paymentAmount;
        ipt.DM_Payment_Date__c = paymentDate;
        ipt.DM_Transaction_Creation_Date__c = sysDate;
        ipt.DM_Transaction_Posting_Date__c = transactionPostingDate;
        ipt.DM_Transaction_Due_Date__c = transactionDueDate;
        ipt.DM_Is_Billed__c = isBilled;
        ipt.DM_Interest_Posting_Type__c = transactionType;
        ipt.DM_External_Id__c = '123';
        ipt.DM_Due_Amount__c = ((ipt.DM_Principal_Posted__c == null) ? 0.00:ipt.DM_Principal_Posted__c) + ((ipt.DM_Interest_Posted__c == null) ? 0.00:ipt.DM_Interest_Posted__c);

        return ipt;
    }        
        
    public static DM_Accrual_Entry__c create_DMAccruals(Id loanId, Id accountingEntry,
                                                                            Date transactionDate,
                                                                            Decimal dmAmount,
                                                                            Boolean Is_Archive,
                                                                            Boolean isMasterArchive,
                                                                            Boolean isGLPosted,
                                                                            Boolean Is_Internal_Accounting_Generated,
                                                                            Boolean DM_Internal_Accounting_Reversal_Generated
                                                                           ){
            DM_Accrual_Entry__c dmAccr = new DM_Accrual_Entry__c();                                                               
            dmAccr.DM_CL_Contract__c=loanId;
            dmAccr.DM_Accounting_Entry__c=accountingEntry;
            dmAccr.DM_Transaction_Date__c = transactionDate;
            dmAccr.DM_GL_Posted__c = IsGLPosted;
            dmAccr.DM_Master_Archive_Object__c= IsMasterArchive;
            dmAccr.DM_Amount__c = dmAmount;
            dmAccr.DM_Archive__c=Is_Archive;
            dmAccr.DM_Internal_Accounting_Generated__c=Is_Internal_Accounting_Generated;
            dmAccr.Internal_Accounting_Reversal_Generated__c=DM_Internal_Accounting_Reversal_Generated;
            dmAccr.DM_External_id__c = '123';
            return dmAccr;
    }   
    
    public static DM_Investment_Order__c createInvestmentOrder(Account a,
                                                    DM_Loan_Account__c l,
                                                    Decimal amt) {
        DM_Investment_Order__c io = new DM_Investment_Order__c (
                                    DM_Account__c = a.Id,
                                    DM_Certificate_Rate__c= 5,
                                    DM_Interest_Service_Rate__c= 1,
                                    DM_Created_Loan_Principal_Remaining__c= l.DM_Principal_Remaining__c,
                                    DM_Start_Date__c= system.Today(),
                                    DM_Loan__c = l.Id,
                                    DM_Enabled__c = true,
                                    DM_Status__c = 'Active',
                                    DM_External_Id__c = '456',
                                    DM_Investment_Amount__c = amt
                                    );
        return io;
    }
    
    public static DM_Disbursal_Transaction_Distribution__c createDDTD() {	//pallavi
        DM_Disbursal_Transaction_Distribution__c dt = new DM_Disbursal_Transaction_Distribution__c (
                                    DM_Distribution_Type__c = 'Disbursement',
            						DM_Distribution_Amount__c = 1000,
            						DM_Name_of_Entity__c = 'test'
                                    );
        return dt;
    }
    
    public static DM_Multi_Step_Loan_Setup__c createRSS(DM_Loan_Account__c l) {	//pallavi
        DM_Multi_Step_Loan_Setup__c rss = new DM_Multi_Step_Loan_Setup__c (
                                    DM_Start_Date__c = System.today(),
            						DM_Interest_Rate__c = 5,
            						DM_Loan_Account__c = l.id,
            						DM_External_Id__c = '1234',
            						DM_Sequence__c = 1
                                    );
        return rss;
    }
    
    public static DM_Investor_Loan_Transaction__c createDMInvestorPaymentTxn(DM_Investment_Order__c io,
                                                    Decimal p,
                                                    Decimal i,
                                                    Decimal f, Id dmLPT) {
        DM_Investor_Loan_Transaction__c ioPayment = new DM_Investor_Loan_Transaction__c(
                                                        DM_Investment_Order__c = io.Id,
                                                        DM_Fees__c= f,
                                                        DM_Principal__c= p,
                                                        DM_Interest__c = i,
                                                        DM_Transaction_Date__c =  system.today(),
                                                        DM_Transaction_Code__c = 'PAYMENT APPROVAL',
                                                        DM_Loan_Payment_Transaction__c= dmLpt,
                                                        DM_External_id__C ='123'
                                                        );
        return ioPayment;
    }
    public static DM_Contingency_Status_Code__c createContingency(DM_Loan_Account__c l) {	//LSP-55
        DM_Contingency_Status_Code__c contingency = new DM_Contingency_Status_Code__c (
                                                    DM_Contingency_Status_Code_Applied_On__c = System.today(),
                                                    DM_Contingency_Status_Code__c = 'No Communication (X)',
                                                    DM_CL_Contract__c = l.id,
                                                    DM_External_Id__c = '123456',
                                                    DM_Suspend_Communication__c = true
                                                    );
        return contingency;
    }
    public static DM_StagingObject_Query_Generator__c stagingObjGen(boolean active,
                                                                   boolean c1,
                                                                   boolean c,
                                                                   String objName,
                                                                   String parentAPIname,
                                                                   String fields,
                                                                   String parentObj){
                                                                       
           DM_StagingObject_Query_Generator__c queryGen = new DM_StagingObject_Query_Generator__c(DM_Active__c = active,
                                                                                                 DM_isChild_of_anotherObject__c = c1,
                                                                                                 DM_isChild_of_Contract__c = c,
                                                                                                 DM_object_name__c = objName,
                                                                                                 DM_Query_Fields__c = fields,
                                                                                                 DM_Parent_Object__c = parentObj,
                                                                                                 DM_Parent_API_Name__c = parentAPIname);
           return queryGen;
        
    }
}//END DM_TestHelper