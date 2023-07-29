/**
 * Class - To perform validation on contracts after migration
 *
 * 
 * @author - Pallavi
 * **/
public class Post_actualObj_TestHelper {
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
    
        public static loan__Loan_Account__c createDMLOC(loan__Loan_Product__c dummyLP,
                                                         Decimal creditLimit,
                                                         Account dummyAccount,
                                                         loan__Fee_Set__c dummyFeeSet,
                                                         loan__Office_name__c dummyOffice,
                                                         loan__Payment_Mode__c	pmode,
                                                         Integer term
                                                         ) {
            loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
            loanAccount.loan__Product_Type__c = 'Auto Payer';
            loanAccount.loan__Loan_Amount__c = 0;
            loanAccount.loan__Credit_Limit__c = creditLimit;
            loanAccount.loan__Credit_Limit_Current__c = creditLimit;
            loanAccount.loan__Account__c= dummyAccount.Id; 
            loanAccount.loan__Number_of_Installments__c = term;
            loanAccount.loan__Contractual_Interest_Rate__c = loanAccount.loan__Interest_Rate__c;
            loanAccount.loan__Fee_Set__c = (dummyFeeSet != null) ? dummyFeeSet.ID : null;
            loanAccount.loan__Loan_Product_Name__c = dummyLP.ID;
            loanAccount.loan__Overdue_Interest_Rate__c = 12;
            loanAccount.loan__Expected_Disbursal_Date__c = null;//Date.today().addDays(-20);
            loanAccount.loan__Repayment_Tied_to_Meeting_Schedule__c = false;
            loanAccount.loan__Repayment_Procedure__c = 'Equal Monthly Installments';
            //loanAccount.loan__Interest_Calculation_Method__c = interestCalcMethod;
            loanAccount.loan__Expected_Repayment_Start_Date__c = null;//Date.today().addDays(31);//Date.today().addDays(-5);	//pallavi(test class was failing)
            loanAccount.loan__Branch__c = dummyOffice.ID;
            loanAccount.loan__Oldest_Due_Date__c = loanAccount.loan__Expected_Repayment_Start_Date__c;
            loanAccount.loan__First_Installment_Date__c = null;//loanAccount.loan__Expected_Repayment_Start_Date__c;
            loanAccount.loan__Next_Installment_Date__c = null;
            loanAccount.loan__Disbursal_Date__c = Date.today().addDays(-20);//loanAccount.loan__Expected_Disbursal_Date__c;
            loanAccount.loan__Term_Cur__c = 0;//loanAccount.loan__Number_of_Installments__c;
            loanAccount.loan__Principal_Remaining__c = 0;
            Integer dueday = 0;//loanAccount.loan__First_Installment_Date__c.day();
            loanAccount.loan__Due_Day__c = dueday;
            loanAccount.loan__Contractual_Due_Day__c = dueday;
            loanAccount.loan__Interest_Only_Period__c = 0;
            loanAccount.loan__Interest_Only_Payment_Amt__c = 0;
            loanAccount.loan__Loan_Account_External_Id__c = string.valueOf(math.random()).right(4);
            loanAccount.loan__Loan_Status__c = 'Active- Good Standing';
            loanAccount.loan__Payment_Mode__c = pmode.id;
            loanAccount.DM_ActivateIO_and_IPT__c = true;
            loanAccount.Post_Migration_Validation_Status__c = 'Pending';  
            loanAccount.loan__la_amortization_frequency__c = '';
            loanAccount.loan__LA_Amortized_Balance_Type__c = '';
            loanAccount.loan__Fees_Remaining__c = -100;
            loanAccount.loan__Charged_Off_Date__c = null;
            loanAccount.loan__Charged_Off_Fees__c = null;
            loanAccount.loan__Charged_Off_Interest__c = null;
            loanAccount.loan__Charged_Off_Principal__c = null;
            return loanAccount;
    }//END createDMLOC
    
    public static loan__Loan_Disbursal_Transaction__c fundLoan(loan__Loan_Account__c loanAccount,
                                                         Date currentSystemDate,
                                                         loan__Payment_Mode__c pmode,
                                                         loan__Bank_Account__c bankAccount
                                                        ) {

        loan__Loan_Disbursal_Transaction__c disbTxn = new loan__Loan_Disbursal_Transaction__c();
        disbTxn.loan__Disbursal_Date__c = currentSystemDate;
        //disbTxn.loan__Disbursed_Amt__c = loanAccount.loan__Loan_Amount__c;
        disbTxn.loan__Loan_Account__c = loanAccount.id;
        //disbTxn.loan__Mode_of_Payment__c =  pMode.id;
        //disbTxn.loan__bank_Account__c = bankAccount.id;
        //disbTxn.External_Id__c = '123';      
        disbTxn.loan__Loan_Disbursal_Transaction_Type__c = 'DM-Regular';                                                      
        return disbTxn;
    }//END fundLoan
    
    
    public static loan__Automated_Payment_Setup__c createAutomatedPaymentSetup(String type,
                                                                          String amountType,
                                                                          loan__Bank_Account__c bank,
                                                                          loan__Loan_Account__c lAcc,
                                                                          String frequency,
                                                                          loan__Payment_Mode__c pMode,
                                                                          Date debitDate,
                                                                          Integer debitDay) {
        loan__Automated_Payment_Setup__c automatedPaymentSetup = new loan__Automated_Payment_Setup__c();
        automatedPaymentSetup.loan__Active__c = true;
        automatedPaymentSetup.loan__Amount_Type__c = amountType;
        automatedPaymentSetup.loan__Bank_Account__c = bank.id;
        automatedPaymentSetup.loan__CL_Contract__C = lAcc.Id;
        automatedPaymentSetup.loan__Frequency__c = frequency;
        automatedPaymentSetup.loan__Payment_Mode__c = pMode.Id;
        automatedPaymentSetup.loan__Recurring_ACH_End_Date__c = debitDate.addDays(180);
        automatedPaymentSetup.loan__Type__c = type;
        //automatedPaymentSetup.loan__Recurring_ACH_Start_Date__c = debitDate;
        //automatedPaymentSetup.loan__Debit_Date__c = debitDate;
        //automatedPaymentSetup.External_Id__c = '123';
        
        return automatedPaymentSetup;
    }
    
    public static loan__Loan_account_Due_Details__c createUnpaidDue(loan__Loan_Account__c loanAccount, Decimal dueAmount) {
        loan__Loan_account_Due_Details__c due = new loan__Loan_account_Due_Details__c(loan__Loan_Account__c = loanAccount.Id,
                                                                                      loan__Payment_Satisfied__c = true,
                                                                                      loan__Payment_Date__c = null,
                                                                                      loan__Principal_Paid__c = null,
                                       // loan__Due_Amt__c = dueAmount,
                                        loan__Due_Date__c = Date.Today().addDays(30)//Date.Today()
                                       // loan__Due_Type_Description__c = 'BILL',
                                       // loan__Due_Type__c = 1,
                                       /*External_Id__c='123'*/);
        return due;
    }//END createUnpaidDue
    public static loan__Multi_Step_Loan_Setup__c createMSLS(loan__Loan_Account__c loanAccount){
        loan__Multi_Step_Loan_Setup__c rate = new loan__Multi_Step_Loan_Setup__c(loan__Loan_Account__c = loanAccount.Id,
                                                                                loan__Start_Date__c = Date.today(),
                                                                                loan__Interest_Rate__c = null,
                                                                                loan__Rate_Change_Date_Next__c = null,
                                                                                loan__Sequence__c = 1,
                                                                                External_Id__c = null
                                                                                );
        return rate;
    }
    public static loan__Due_Payment__c createDP(loan__Loan_Payment_Transaction__c lp){
      loan__Due_Payment__c due = new loan__Due_Payment__c(loan__Fees__c = null,
                                                         loan__Payment_Amount__c = null,
                                                         loan__Principal__c = null,
                                                         External_Id__c = null,
                                                         loan__Interest__c = null,
                                                         loan__Loan_Payment_Transaction__c = lp.id,
                                                         loan__Due__c = null
                                                         );
       return due;
    }
    
    public static loan__Disbursal_Txn_Distribution__c createDTD(loan__Loan_Disbursal_Transaction__c LDT){
        loan__Disbursal_Txn_Distribution__c disb = new loan__Disbursal_Txn_Distribution__c(loan__Loan_Disbursal_Transaction__c = LDT.id,
                                                                                          loan__Distribution_Type__c = null,
                                                                                          loan__Distribution_Amount__c = null,
                                                                                          loan__Name_of_Entity__c = null,
                                                                                          External_Id__c = null
                                                                                          );
        return disb;
    }
   /* public static DM_Bill__c createUnpaidDue1(DM_Loan_Account__c loanAccount, Decimal dueAmount) {
        DM_Bill__c due = new DM_Bill__c(DM_CL_Contract__c = loanAccount.Id,
                                        DM_Due_Amt__c = dueAmount,
                                        DM_Due_Date__c = Date.Today(),
                                        DM_Due_Type_Description__c = 'BILL',
                                        DM_Due_Type__c = 1,
                                        DM_External_Id__c='1234');
        return due;
    }//END createUnpaidDue1*/
    
    public static loan__Charge__c createUnpaidCharge(loan__Loan_Account__c loanAccount, loan__Fee__c fee, Decimal chargeAmount) {
        loan__Charge__c charge = new loan__Charge__c(loan__Loan_Account__c = loanAccount.Id,
                                            loan__Original_Amount__c = chargeAmount,
                                            loan__Date__c = Date.Today(),
                                            loan__Calculated_Interest3__c = chargeAmount,
                                            loan__Fee__c = fee.Id,
                                            External_Id__c ='123');
        return charge;
    }//END createUnpaidCharge
    
     public static loan__Loan_Payment_Transaction__c createLoanPayment(Id lAccountId,
                                                            Decimal transactionAmount,
                                                            Date transDate,
                                                            loan__Automated_Payment_Setup__c aPS,
                                                            loan__Payment_Mode__c pMode,
                                                            Date retryOn) {
        loan__Loan_Payment_Transaction__c payment = new loan__Loan_Payment_Transaction__c();
        //payment.loan__Transaction_Date__c = transDate;
        payment.loan__Transaction_Amount__c = transactionAmount;
        payment.loan__Loan_Account__c = lAccountId;
        payment.External_Id__c = '';
        //payment.loan__Receipt_Date__c= Date.today();                                                       
        payment.loan__Skip_Validation__c = true;
        payment.loan__Principal__c = 0;//null;
        payment.loan__Interest__c = 0;//null;  
        
        loan__Payment_Mode__c pm = new loan__Payment_Mode__c();
        pm.name = 'ACH';
        insert pm;
                                                                
        payment.loan__Payment_Mode__c = pm.Id;                                                        
        /*if (aPS != null){
            payment.loan__Automated_Payment_Setup__c = aPS.Id;
            payment.loan__Payment_Mode__c = aPS.loan__Payment_Mode__c;
        }*/
        return payment;
    }//END createLoanPaymentWithoutCommit
    
    public static loan__Loan_Payment_Transaction__c createLoanPayment1(Id lAccountId,
                                                            Decimal transactionAmount,
                                                            Date transDate,
                                                            loan__Automated_Payment_Setup__c aPS,
                                                            loan__Payment_Mode__c pMode,
                                                            Date retryOn) {
        loan__Loan_Payment_Transaction__c payment = new loan__Loan_Payment_Transaction__c();
        payment.loan__Transaction_Date__c = transDate;
        payment.loan__Transaction_Amount__c = transactionAmount;
        payment.loan__Loan_Account__c = lAccountId;
        payment.External_Id__c = '1234';
        payment.loan__Receipt_Date__c= Date.today();                                                       
        payment.loan__Skip_Validation__c = true;
        payment.loan__Principal__c = 0;//null;
        payment.loan__Interest__c = 0;//null;                                                        
        if (aPS != null){
            payment.loan__Automated_Payment_Setup__c = aPS.Id;
            payment.loan__Payment_Mode__c = aPS.loan__Payment_Mode__c;
        }
        return payment;
    }//END createLoanPayment1WithoutCommit
  
    public static loan__Repayment_Schedule_Summary__c CreateRSSData(loan__Loan_Account__c loanAccount,Decimal Amount) {
        loan__Repayment_Schedule_Summary__c rss = new loan__Repayment_Schedule_Summary__c();
        //rss.loan__RSS_No_Of_Pmts__c = 1;
        //rss.loan__RSS_Repayment_Amt__c = amount;
        rss.loan__RSS_Loan_Account__c = loanAccount.id;
        //rss.loan__RSS_Repayment_Dt__c =  Date.today().addDays(-1);
        //rss.External_Id__c = '123';
        //rss.loan__RSS_Seq__c = 1;
        return rss;
    }//END CreateRSSData
    
    public static loan__Repayment_Schedule__c CreateAmzScheduleData(loan__Loan_Account__c loanAccount,Decimal Amount ) {
        loan__Repayment_Schedule__c repaySch = new loan__Repayment_Schedule__c();
        repaySch.loan__Loan_Account__c = loanAccount.Id;
        repaySch.loan__Due_Date__c = Date.Today().addDays(30);
        repaySch.loan__Due_Interest__c = null;//40.00 ;
        repaySch.loan__Balance__c = null;//800;
        repaySch.loan__Paid_Principal__c=amount;  
        repaySch.External_Id__C = '123';  
        repaySch.loan__Due_Principal__c = null;
        return repaySch;                                                
    }//END CreateAmzScheduleData 
    
    public static loan__Repayment_Schedule__c CreateAmzScheduleData1(loan__Loan_Account__c loanAccount,Decimal Amount ) {
        loan__Repayment_Schedule__c repaySch = new loan__Repayment_Schedule__c();
        repaySch.loan__Loan_Account__c = loanAccount.Id;
        repaySch.loan__Due_Date__c = Date.Today().addDays(60);
        repaySch.loan__Due_Interest__c = null;//40.00 ;
        repaySch.loan__Balance__c = null;//800;
        repaySch.loan__Paid_Principal__c=amount;  
        repaySch.External_Id__C = '1234';
        repaySch.loan__Due_Principal__c = null;
        return repaySch;                                                
    }//END CreateAmzScheduleData 
    
    public static loan__Interest_Posting_Transaction__c create_InterestPostingTransaction(Id loanId,Date sysDate,
                                                                            Decimal principalPosted,Decimal interestPosted,
                                                                            Decimal principalPaid,Decimal interestPaid,
                                                                            boolean isCapitalized,Date capitalizationDate,
                                                                            Decimal paymentAmount,Date paymentDate,
                                                                            String transactionType,
                                                                            Boolean isBilled,
                                                                            Boolean isPosted,
                                                                            Date transactionPostingDate,
                                                                            Date transactionDueDate) {

        loan__Interest_Posting_Transaction__c ipt = new loan__Interest_Posting_Transaction__c();
        ipt.loan__Loan_Contract__c = loanId;
        ipt.loan__Principal_Posted__c = principalPosted;
        ipt.loan__Principal_Paid__c = principalPaid;
        ipt.loan__Interest_Posted__c = interestPosted;
        ipt.loan__Interest_Paid__c = interestPaid;
        //ipt.DM_Is_Capitalized__c = isCapitalized;
        ipt.loan__Capitalization_Date__c = capitalizationDate;
        ipt.loan__Payment_Amount__c = paymentAmount;
        ipt.loan__Payment_Date__c = paymentDate;
        ipt.loan__Transaction_Creation_Date__c = sysDate;
        ipt.loan__Transaction_Posting_Date__c = transactionPostingDate;
        ipt.loan__Transaction_Due_Date__c = transactionDueDate;
        ipt.loan__Is_Billed__c = isBilled;
        ipt.loan__Interest_Posting_Type__c = transactionType;
        ipt.loan__External_Id__c = '123';
        ipt.loan__Due_Amount__c = ((ipt.loan__Principal_Posted__c == null) ? 0.00:ipt.loan__Principal_Posted__c) + ((ipt.loan__Interest_Posted__c == null) ? 0.00:ipt.loan__Interest_Posted__c);

        return ipt;
    }        
        
    public static loan__Accrual_Entry__c create_DMAccruals(Id loanId, Id accountingEntry,
                                                                            Date transactionDate,
                                                                            Decimal dmAmount,
                                                                            Boolean Is_Archive,
                                                                            Boolean isMasterArchive,
                                                                            Boolean isGLPosted,
                                                                            Boolean Is_Internal_Accounting_Generated,
                                                                            Boolean DM_Internal_Accounting_Reversal_Generated
                                                                           ){
            loan__Accrual_Entry__c dmAccr = new loan__Accrual_Entry__c();                                                               
            dmAccr.loan__Loan_Account__c=loanId;
            dmAccr.loan__Accounting_Entry__c=accountingEntry;
            dmAccr.loan__Transaction_Date__c = transactionDate;
            dmAccr.loan__GL_Posted__c = IsGLPosted;
            dmAccr.loan__Master_Archive_Object__c= IsMasterArchive;
            dmAccr.loan__Amount__c = dmAmount;
            dmAccr.loan__Archived__c=Is_Archive;
            dmAccr.loan__Internal_Accounting_Generated__c=Is_Internal_Accounting_Generated;
            dmAccr.loan__Internal_Accounting_Reversal_Generated__c=DM_Internal_Accounting_Reversal_Generated;
            dmAccr.External_id__c = '123';
            return dmAccr;
    }   
    
    public static loan__Investor_Loan__c createInvestmentOrder(Account a,
                                                    loan__Loan_Account__c l,
                                                    Decimal amt) {
        loan__Investor_Loan__c io = new loan__Investor_Loan__c (
                                    loan__Account__c = null,//a.Id,
                                    loan__Certificate_Rate__c= 5,
                                    loan__Service_Rate__c= 1,
                                    loan__Loan_Principal_Remaining__c= l.loan__Principal_Remaining__c,
                                    loan__Loan__c = l.Id,
                                    loan__Enabled_Flag__c = true,
                                    loan__Status__c = null,//'Active',
                                    External_Id__c = '',
                                    loan__Investment_Amount__c = amt,
            						loan__Discount_Percent__c = null,
            						loan__Late_Fees_Amount_Paid__c = null,
            						loan__Interest_Amount_Paid__c = null,
            						loan__Interest_Exempted_From_Service_Fee__c = null,
            						loan__Inv_Interest_Posted_Amt__c = null,
            						loan__Interest_Rate_On_Due_Interest__c = null,
            						loan__Interest_Rate_On_Due_IOA__c = null,
            						loan__Interest_Rate_On_Due_Principal__c = null,
            						loan__Interest_Rounding_Error__c = null,
            						loan__Minimum_Service_Fee__c = null,
            						loan__Principal_Amount_Paid__c = null,
            						loan__Rebate_Amount_Paid__c = null,
            						loan__Total_Amount_Paid__c = null,
            						loan__Write_Off_Amount__c = null,
                                    loan__Charged_Off_Date__c = null,
                                    loan__Charged_Off_Fees__c = null,
                                    loan__Charged_Off_Interest__c = null,
                                    loan__Charged_Off_Principal__c = null
                                    );
        return io;
    }
    
    public static loan__Investor_Loan_Account_Txns__c createDMInvestorPaymentTxn(loan__Investor_Loan__c io,
                                                    Decimal p,
                                                    Decimal i,
                                                    Decimal f, Id dmLPT) {
        loan__Investor_Loan_Account_Txns__c ioPayment = new loan__Investor_Loan_Account_Txns__c(
                                                        loan__Investor_Loan__c = io.Id,
                                                        loan__Late_Fees_Paid__c= f,
                                                        loan__Principal_Paid__c= p,
                                                        loan__Interest_Paid__c = i,
                                                        loan__Transaction_Date__c =  system.today(),
                                                        loan__Txn_Code__c = 'PAYMENT APPROVAL',
                                                        loan__Loan_Payment_Transaction__c= dmLpt,
                                                        External_id__C ='123'
                                                        );
        return ioPayment;
    }
    public static DM_PrimaryObject_Query_Generator__c primaryObjGen(boolean active,
                                                                   boolean c1,
                                                                   boolean c,
                                                                   String objName,
                                                                   String parentObjAPIname,
                                                                   String fields,
                                                                   String parentObj){
                                                                       
           DM_PrimaryObject_Query_Generator__c queryGen = new DM_PrimaryObject_Query_Generator__c(DM_Active__c = active,
                                                                                                 DM_isChild_of_anotherObject__c = c1,
                                                                                                 DM_isChild_of_Contract__c = c,
                                                                                                 DM_object_name__c = objName,
                                                                                                 DM_Query_Fields__c = fields,
                                                                                                 DM_Parent_Object__c = parentObj,
                                                                                                 DM_Parent_API_Name__c = parentObjAPIname);
           return queryGen;
        
    }
}