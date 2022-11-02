/******************Modification History*****************************************
 * Punith          2022-10-07          LSP-452**
 * ****************************************************************************/
public class InterestLossCalcHandler {
    public List<loan__Loan_Account__c> loanAccounts;
    public Map<Id, List<loan__Loan_Payment_Transaction__c>> loanId2PaymentMap;
    public Map<Id, List<loan__Other_Transaction__c>> loanId2OltMap;
    public Map<Id, loan__Other_Transaction__c> paymentId2OltMap;

    public InterestLossCalcHandler(List<loan__Loan_Account__c> loanAccounts) {
        this.loanAccounts = loanAccounts;
        initialize();
    }
    
    public void initialize() {
        Set<Id> loanIds = new Set<Id>();
        loanId2PaymentMap = new Map<Id, List<loan__Loan_Payment_Transaction__c>>();
        loanId2OltMap = new Map<Id, List<loan__Other_Transaction__c>>();
        paymentId2OltMap = new Map<Id, loan__Other_Transaction__c>();
        for (loan__Loan_Account__c loan : loanAccounts) {
            loanIds.add(loan.Id);
        }
        
        List<loan__Loan_Payment_Transaction__c> lpts = [SELECT Id,
                                                               Name,
                                                               loan__Transaction_Date__c,
                                                               loan__Transaction_Time__c,
                                                               CreatedDate,
                                                               loan__Loan_Account__c,
                                                               loan__Interest__c,
                                                               loan__Fees__c,
                                                               loan__Principal__c,
                                                               loan__Transaction_Amount__c,
                                                               loan__Reschedule_Threshold_Crossed__c,
                                                               loan__Early_Total_Repayment_of_the_Loan__c,
                                                               loan__Loan_Snapshot__c,
                                                               loan__Ipt_Snapshot__c
                                                        FROM loan__Loan_Payment_Transaction__c
                                                        WHERE loan__Loan_Account__c IN :loanIds
                                                          AND loan__Cleared__c = true
                                                          AND loan__Reversed__c = false
                                                          AND loan__Rejected__c = false
                                                          ORDER BY loan__Transaction_Date__c ASC, loan__Transaction_Time__c ASC
                                                       ];
        
        List<loan__Other_Transaction__c> olts = [SELECT Id,
                                                        Name,
                                                        CreatedDate,
                                                        loan__Loan_Account__c,
                                                        loan__Txn_Date__c,
                                                        loan__Transaction_Time__c,
                                                        loan__Transaction_Type__c,
                                                        loan__Txn_Amt__c,
                                                        loan__Loan_Snapshot__c,
                                                        loan__Loan_Payment_Id__c
                                                 FROM loan__Other_Transaction__c
                                                 WHERE loan__Loan_Account__c IN :loanIds
                                                   AND loan__Reversed__c = false
                                                   AND loan__Transaction_Type__c in (:loan.LoanConstants.LOAN_TRANSACTION_RESCHEDULE,:loan.LoanConstants.LOAN_TRANSACTION_RATE_CHANGE,:loan.LoanConstants.LOAN_TRANSACTION_PAYMENT_CHANGE,:loan.LoanConstants.LOAN_TRANSACTION_DUE_DAY_CHANGE)
                                                   ORDER BY loan__Txn_Date__c ASC, loan__Transaction_Time__c ASC
                                                ];
        
        for (loan__Loan_Payment_Transaction__c payment : lpts) {
            List<loan__Loan_Payment_Transaction__c> loanPayments = loanId2PaymentMap.get(payment.loan__Loan_Account__c);
            if(loanPayments == null) {
                loanPayments = new List<loan__Loan_Payment_Transaction__c>();
                loanId2PaymentMap.put(payment.loan__Loan_Account__c, loanPayments);
            }
            loanPayments.add(payment);
        }
        for (loan__Other_Transaction__c olt : olts) {
            List<loan__Other_Transaction__c> otherTxns = loanId2OltMap.get(olt.loan__Loan_Account__c);
            if(otherTxns == null) {
                otherTxns = new List<loan__Other_Transaction__c>();
                loanId2OltMap.put(olt.loan__Loan_Account__c, otherTxns);
            }
            otherTxns.add(olt);
            
            if(olt.loan__Transaction_Type__c == loan.LoanConstants.LOAN_TRANSACTION_RESCHEDULE && olt.loan__Loan_Payment_Id__c != null) {
                paymentId2OltMap.put((Id)olt.loan__Loan_Payment_Id__c, olt);
            }
        }
    }
    
    public void process() {
        for (loan__Loan_Account__c loanAccount : loanAccounts) {
            List<loan__Loan_Payment_Transaction__c> loanPayments = loanId2PaymentMap.get(loanAccount.Id);
            List<loan__Other_Transaction__c> otherTxns = loanId2OltMap.get(loanAccount.Id);
            List<LoanTransaction> loanTxns = new List<LoanTransaction>();
            for (loan__Loan_Payment_Transaction__c lpt : loanPayments) {
                DateTime lptTime = lpt.loan__Transaction_Time__c == null ? lpt.CreatedDate : lpt.loan__Transaction_Time__c;
                LoanTransaction txn = new LoanTransaction(lpt, lpt.loan__Transaction_Date__c, lptTime);
                loanTxns.add(txn);
            }
            for (loan__Other_Transaction__c olt : otherTxns) {
                DateTime oltTime = olt.loan__Transaction_Time__c == null ? olt.CreatedDate : olt.loan__Transaction_Time__c;
                LoanTransaction txn = new LoanTransaction(olt, olt.loan__Txn_Date__c, oltTime);
                if(olt.loan__Transaction_Type__c == loan.LoanConstants.LOAN_TRANSACTION_RESCHEDULE && olt.loan__Loan_Payment_Id__c != null) {
                    txn.setExcessPayment(true);
                }
                loanTxns.add(txn);
            }
            Comparator.sort(loanTxns, new DateWiseComparator());
            
            LoanDataStore dataStore = new LoanDataStore();
            dataStore.principalRemaining = loanAccount.loan__Loan_Amount__c;
            dataStore.interestRate = loanAccount.loan__Interest_Rate__c;
            dataStore.timeCountingMethod = loanAccount.loan__Time_Counting_Method__c;
            dataStore.accrualBaseCode = loan.LoanTransactionUtil.getAccrualBaseMethodCode(loanAccount);
            dataStore.interestCalculationMethod = loanAccount.loan__Interest_Calculation_Method__c;
            dataStore.paymentFrequency = loanAccount.loan__Frequency_Of_Loan_Payment__c;
            dataStore.lastAccrualDate = loanAccount.loan__Last_Disbursal_Date__c;
            
            Boolean excessPaymentDone = false;
            for (LoanTransaction loanTxn : loanTxns) {
                system.debug('****** loanTxn : ' + loanTxn);
                if (loanTxn.excessPayment) {
                    excessPaymentDone = true;
                }
                if (!excessPaymentDone) {
                    if(loanTxn.Txn instanceof loan__Loan_Payment_Transaction__c) {
                        loan__Loan_Payment_Transaction__c lpt = (loan__Loan_Payment_Transaction__c)loanTxn.Txn;
                        dataStore.principalRemaining -= lpt.loan__Principal__c;
                        dataStore.lastAccrualDate = loanTxn.txnDate;
                    }
                }
                else {
                    if (loanTxn.Txn instanceof loan__Loan_Payment_Transaction__c) {
                        if (dataStore.lastAccrualDate != loanTxn.txnDate) {
                            Decimal interestAmount = loan.InterestCalc.calcSI(dataStore.interestRate,
                                                                              dataStore.accrualBaseCode,
                                                                              dataStore.paymentFrequency,
                                                                              dataStore.principalRemaining,
                                                                              dataStore.lastAccrualDate,
                                                                              loanTxn.txnDate);
                            dataStore.interestRemaining += interestAmount;
                        }
                        loan__Loan_Payment_Transaction__c loanPayment = (loan__Loan_Payment_Transaction__c)loanTxn.Txn;
                        //Reduce the payment amount
                        Decimal txnAmount = loanPayment.loan__Transaction_Amount__c;
                        if(txnAmount < dataStore.interestRemaining && !loanPayment.loan__Reschedule_Threshold_Crossed__c) {
                            dataStore.interestRemaining -= txnAmount;
                            txnAmount = 0.0;
                        }
                        else {
                            if(!loanPayment.loan__Reschedule_Threshold_Crossed__c) {
                                txnAmount -= dataStore.interestRemaining;
                                dataStore.interestRemaining = 0.0;
                            }
                            if(txnAmount > 0) {
                                dataStore.principalRemaining -= txnAmount;
                                txnAmount = 0.0;
                            }
                        }
                        dataStore.lastAccrualDate = loanTxn.txnDate;
                    }
                    else if (loanTxn.Txn instanceof loan__Other_Transaction__c) {
                        dataStore.interestRemaining += loan.InterestCalc.calcSI(dataStore.interestRate,
                                                                              dataStore.accrualBaseCode,
                                                                              dataStore.paymentFrequency,
                                                                              dataStore.principalRemaining,
                                                                              dataStore.lastAccrualDate,
                                                                              loanTxn.txnDate);//Calculating the correct interest amount.
                        dataStore.lastAccrualDate = loanTxn.txnDate;
                    }
                }
                system.debug('****** interestRemaining :: ' + dataStore.interestRemaining);
                system.debug('****** principalRemaining :: ' + dataStore.principalRemaining);
            }
            Decimal interestLoss = dataStore.principalRemaining - loanAccount.loan__Principal_Remaining__c;
            interestLoss = loan.LoanTransactionUtil.getRoundedAmount(loanAccount, interestLoss);
            loanAccount.Interest_Amount_Loss__c = interestLoss;
            system.debug('****** interestLoss :: ' + interestLoss);
        }
        update loanAccounts;
    }
    
    public inherited sharing class LoanTransaction {
        Public Sobject Txn;
        Public Date txnDate;
        Public DateTime txnDateTime;
        public Boolean excessPayment = false;
        
        Public LoanTransaction(Sobject Txn, Date txnDate, DateTime txnDateTime) {
            this.Txn = Txn;
            this.txnDate = txnDate;
            this.txnDateTime = txnDateTime;
        }
        
        public void setExcessPayment(Boolean excessPayment) {
            this.excessPayment = excessPayment;
        }
    }
    
    private class LoanDataStore {
        public Decimal principalRemaining {get; set;}
        public Decimal interestRemaining {get; set;}
        public Decimal interestPosted {get; set;}
        public Decimal interestAccrued {get; set;}
        public Decimal feesRemaining {get; set;}
        public Decimal interestRate {get; set;}
        public Date lastAccrualDate {get; set;}
        public String timeCountingMethod {get; set;}
        public String interestCalculationMethod {get; set;}
        public String paymentFrequency {get; set;}
        public String accrualBaseCode {get; set;}
        
        private LoanDataStore() {
            principalRemaining = 0.0;
            interestRemaining = 0.0;
            interestPosted = 0.0;
            interestAccrued = 0.0;
            feesRemaining = 0.0;
            interestRate = 0.0;
        }
    }
    
    public inherited sharing class DatewiseComparator extends comparator {
        
        public DateWiseComparator() {}
        
        public override Integer compare(Object txn1, Object txn2) {
            if(((LoanTransaction)txn1).txnDate < ((LoanTransaction)txn2).txnDate) {
                return -1;
            }
            else if(((LoanTransaction)txn1).txnDate > ((LoanTransaction)txn2).txnDate) {
                return 1;
            }
            else {
                if(((LoanTransaction)txn1).txnDateTime != null && ((LoanTransaction)txn2).txnDateTime != null) {
                    if(((LoanTransaction)txn1).txnDateTime < ((LoanTransaction)txn2).txnDateTime) {
                        return -1;
                    }
                    else if(((LoanTransaction)txn1).txnDateTime > ((LoanTransaction)txn2).txnDateTime) {
                        return 1;
                    }
                }
                return 0;
            }
        }
    }
}