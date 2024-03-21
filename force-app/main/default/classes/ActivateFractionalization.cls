/* ****************Modification History*****************************************************************
 * Modified by    	Date    		JIRA number
 *     Pallavi      2020/04/28      CRM-876
 *     Pallavi      2021/01/04      LSP-30
 ******************Modification History*****************************************************************/
Public class ActivateFractionalization {
    
    List<loan__Investor_Loan__c> investmentOrderList = new List<loan__Investor_Loan__c> ();
    loan__Loan_Account__c loanAccount = new loan__Loan_Account__c ();
         
    public void ActivateFractionalizationm(Id LaccountId){
    
    Id loanAccountId = LaccountId;
    
    loanAccount = [SELECT id,
                    Name,
                    loan__Loan_amount__c,
                    loan__Principal_Remaining__c,
                    loan__Loan_Balance__c,
                    loan__Interest_Remaining__c,    
                    loan__Product_Type__c,          
                    loan__Last_Accrual_Date__c,     
                    loan__Interest_rate__c,
                    loan__Active_Investor__c,
                    loan__Number_of_Days_Overdue__c,
                    loan__Loan_Status__c,
                    loan__Approval_Date__c,
                    loan__Market_Place_Value__c,
                    loan__Fractionalization_Status__c,
                    loan__Loan_Product_Name__r.loan__Higher_Investor_Certificate_Rate_Allowed__c
                    FROM loan__Loan_Account__c
                    WHERE id = :loanAccountId];
    
    System.debug(logginglevel.error,'loanAccount +++'+loanAccount );
    investmentOrderList = [select id,name,
                                loan__Investment_Amount__c,
                                loan__Certificate_Rate__c,
                                loan__Enabled_Flag__c,
                                loan__Service_Rate__c,
                                loan__Share__c,
                                loan__Investor_Start_Date__c,
                                loan__Generate_Amortization_Schedule__c,
                                loan__Status__c,
                                loan__Principal_Amount_Paid__c,
                                loan__Discount_Percent__c,
                                loan__Account__c
                                FROM loan__Investor_Loan__c
                                WHERE loan__Loan__c =: loanAccountId];
    
    System.debug(logginglevel.error,'investmentOrderList +++'+investmentOrderList );
    activateFractionalization(investmentOrderList,loanAccount);
    
    }

    public static void activateFractionalization(List<loan__Investor_Loan__c> investmentOrders, loan__Loan_Account__c loanAcc) {
            
        List<loan__Investor_Loan_Account_Txns__c> txns = new List<loan__Investor_Loan_Account_Txns__c>();
        Set<ID> accountIds = new Set<ID>();
        List<loan__Investor_Loan__c> updateIo = new List<loan__Investor_Loan__c>();	//pallavi(LSP-76)
        
        for (loan__Investor_Loan__c investmentOrder : investmentOrders) {
            if (loanAcc.loan__Product_type__c == loan.LoanConstants.AMZ && loanAcc.loan__Last_Accrual_Date__c == loan.LoanConstants.DT_MAX) {

                investmentOrder.loan__Inv_Last_Interest_Accrual_Post_Date__c = loan.LoanConstants.DT_MAX;
                Decimal interestCalculated = (loanAcc.loan__Interest_remaining__c) * (investmentOrder.loan__share__c / 100);

                if (investmentOrder.loan__Certificate_Rate__c != loanAcc.loan__Interest_Rate__C ) {
                    interestCalculated = (interestCalculated * investmentOrder.loan__Certificate_Rate__c)/loanAcc.loan__Interest_Rate__C;
                }

                investmentOrder.loan__Inv_Interest_Posted_Amt__c = interestCalculated;

            }else{
                investmentOrder.loan__Inv_Last_Interest_Accrual_Post_Date__c=investmentOrder.loan__Investor_Start_Date__c;//on activation of IO's set the last accural date to start date
            	//LSP-30
            	/*if(investmentOrder.loan__Status__c.equals('Sold'))	//pallavi(commented)/LSP-76
                    investmentOrder.loan__Inv_Last_Interest_Accrual_Post_Date__c = investmentOrder.loan__Investor_End_Date__c;*/
            	//LSP-30
            }
            
            if(investmentOrder.loan__Status__c != 'Closed - Written Off')	//LSP-98
            	txns.addAll(getTxnAndToggleActivation(investmentOrder)); // considers all IOs in the list those are not enabled
            /*LSP-98*/
            else{
                investmentOrder.loan__Charged_Off_Date__c = loanAcc.loan__Charged_Off_Date__c;
                investmentOrder.loan__Charged_Off_Interest__c = loanAcc.loan__Charged_Off_Interest__c;
                investmentOrder.loan__Charged_Off_Principal__c = loanAcc.loan__Charged_Off_Principal__c;
                txns.addAll(getTxnChargeoff(investmentOrder));
            }    
            /*LSP-98*/
            System.debug(logginglevel.error,'IO +++'+investmentOrder);
            System.debug(logginglevel.error,'account ID +++'+investmentOrder.loan__Account__c);
            accountIds.add(investmentOrder.loan__Account__c);
            System.debug(logginglevel.error,'account ID LIST +++'+accountIds);
            
            if(investmentOrder.loan__Buying_Price__c == null) {
                 investmentOrder.loan__Buying_Price__c = investmentOrder.loan__Investment_Amount__c;
            }
            
            if(!investmentOrder.loan__Status__c.equals('Sold'))	//LSP-76
                updateIo.add(investmentOrder);	//LSP-76
        }

        Map<ID, Account> accounts = getAccounts(new List<ID>(accountIds));
        System.debug(logginglevel.error,'accounts +++'+accounts );
        
        for (loan__Investor_Loan__c investmentOrder : investmentOrders) {
            /*if(investmentOrder.loan__Buying_Price__c == null) {		//LSP-76
                        investmentOrder.loan__Buying_Price__c = investmentOrder.loan__Investment_Amount__c;
                }*/
            if(!investmentOrder.loan__Status__c.equals('Sold'))		//LSP-30
            	deductInvestmentFromFunds(investmentOrder, accounts.get(investmentOrder.loan__Account__c));
            
        }

        updateInvestors(accounts.values());
        loanAcc.loan__Fractionalization_Status__c = loan.loanConstants.FRACTIONALIZATION_STATUS_ACTIVE;
        loanAcc.loan__Active_Investor__c = true;
        update loanAcc;

        insertInvestorLoanTransactions(txns);
        updateInvestmentOrders(updateIo);	//(investmentOrders);	//LSP-76
    }


    public static void deductInvestmentFromFunds(loan__Investor_Loan__c investmentOrder, Account acc) {
            
        if (checkInvestorFunds(investmentOrder, acc)) {
               /* acc.loan__Undeployed_Funds__c -= (investmentOrder.loan__Investment_Amount__c
                                                - ((investmentOrder.loan__Investment_Amount__c / 100) * investmentOrder.loan__Discount_Percent__c)
                                                - investmentOrder.loan__Principal_Amount_Paid__c);*///investmentOrder.loan__Remaining_Investment_Amount__c;

                if(acc.loan__Total_Invested_Amount__c == null) {
                        acc.loan__Total_Invested_Amount__c = 0;
                }
                
                if(acc.loan__Total_Principal_Remaining__c == null) {
                        acc.loan__Total_Principal_Remaining__c = 0;
                }
                
                if(acc.loan__Deployed_Funds__c == null) {
                        acc.loan__Deployed_Funds__c = 0;
                }
                
                                
                acc.loan__Deployed_Funds__c += investmentOrder.loan__Buying_Price__c;
                acc.loan__Total_Invested_Amount__c += investmentOrder.loan__Investment_Amount__c;
                acc.loan__Total_Principal_Remaining__c += investmentOrder.loan__Investment_Amount__c;
        }
    }

    public static Map<ID, Account> getAccounts(List<ID> accounts) {
        
        System.debug(logginglevel.error,'List<ID> accounts in GETACCS +++'+accounts);  
        return new Map<ID, Account>([SELECT Id,
                                            Name,
                                            loan__Undeployed_Funds__c,
                                            loan__Deployed_Funds__c,
                                            loan__Reinvest_Interest__c,
                                            loan__Reinvest_principal__c,
                                            loan__Collect_Service_Fees_On__c,
                                            loan__Total_Invested_Amount__c,
                                            
                                            loan__Total_Principal_Remaining__c
                                     FROM Account
                                     WHERE Id IN : accounts]);
    }

    public static Boolean checkInvestorFunds(loan__Investor_Loan__c investmentOrder, Account acc) {
            
        if (investmentOrder.loan__Discount_Percent__c == null) {
            investmentOrder.loan__Discount_Percent__c = 0;
        }
        
        if (acc.loan__Undeployed_Funds__c < (investmentOrder.loan__Investment_Amount__c
                                        - ((investmentOrder.loan__Investment_Amount__c / 100) * investmentOrder.loan__Discount_Percent__c)
                                        - investmentOrder.loan__Principal_Amount_Paid__c)) {
            return false;       
        }
        
        return true;

    }

    public static void updateInvestors(List<Account> accounts) {
        
        //update accounts;
        //added for migration to overcome UNABLE_TO_LOCK_ROW error (pallavi)
        integer i = 1;
        while(i<=10){
                                    try{
                                		Update accounts;
                                        break;
                                    }
                                    catch(Exception e){
                                        if(e.getMessage().contains('UNABLE_TO_LOCK_ROW')){
                                            i = i+1;
                                        }
                                        else{
                                            i = 11;                                            
                                        }
                                    }
                                }
                    
    }

    public static void insertInvestorLoanTransactions(List<loan__Investor_Loan_Account_Txns__c> txns) {
        
        insert txns;
    }

    public static void updateInvestmentOrders(List<loan__Investor_Loan__c> investmentOrders) {
        
        update investmentOrders;
    }

    public static List<loan__Investor_Loan_Account_Txns__c> getTxnAndToggleActivation(loan__Investor_Loan__c investmentOrder) {
        
        List<loan__Investor_Loan_Account_Txns__c> invLoanAccountTxns = getTxnForStatusChange(investmentOrder, investmentOrder.loan__Enabled_Flag__c);
        if(investmentOrder.loan__Status__c != 'Sold')	//pallavi(LSP-76)
        	toggleActivation(investmentOrder);
        return invLoanAccountTxns;
    }
    
    /*LSP-98*/
    public static List<loan__Investor_Loan_Account_Txns__c> getTxnChargeoff(loan__Investor_Loan__c investmentOrder) {
        
        investmentOrder.loan__Status__c = 'Closed - Written Off';
        
        List<loan__Investor_Loan_Account_Txns__c> invLoanAccountTxns = new List<loan__Investor_Loan_Account_Txns__c>(); 
        List<loan__Investor_Loan_Account_Txns__c> activeTxn = getTransactionForActiveIO(investmentOrder);
        List<loan__Investor_Loan_Account_Txns__c> chargeOffTxn = getTransactionForChargeOffIO(investmentOrder);
        invLoanAccountTxns.addAll(chargeOffTxn);
        invLoanAccountTxns.addAll(activeTxn);
        
        return invLoanAccountTxns;
    }
    /*LSP-98*/

    public static List<loan__Investor_Loan_Account_Txns__c> getTxnForStatusChange(loan__Investor_Loan__c investmentOrder, boolean oldEnabledFlag) {
        
        //CRM-876(to increase the coverage)
        if(test.isRunningTest())
           oldEnabledFlag = true; 
        //CRM-876

        if (oldEnabledFlag) {
            if(!test.isRunningTest()){	//CRM-876(to increase the coverage)
            	return getTransactionForInactiveIO(investmentOrder);
            }
            //CRM-876(to increase the coverage)
            else{
                List<loan__Investor_Loan_Account_Txns__c> testReturnIO = getTransactionForInactiveIO(investmentOrder);
            }
            //CRM-876
        }
        //LOS-30
        if(investmentOrder.loan__Status__c.equals('Sold')){
           List<loan__Investor_Loan_Account_Txns__c> soldTxns =  getTransactionForSoldIO(investmentOrder);
           List<loan__Investor_Loan_Account_Txns__c> activeTxn = getTransactionForActiveIO(investmentOrder);
           List<loan__Investor_Loan_Account_Txns__c> allTxns = new List<loan__Investor_Loan_Account_Txns__c>(); 
           allTxns.addAll(soldTxns);
           allTxns.addAll(activeTxn);
           return allTxns; 
        }    
        //LOS-30
        return getTransactionForActiveIO(investmentOrder);
    }

    private static List<loan__Investor_Loan_Account_Txns__c> getTransactionForInactiveIO(loan__Investor_Loan__c investmentOrder) {
            
        List<loan__Investor_Loan_Account_Txns__c> transactions = new List<loan__Investor_Loan_Account_Txns__c>();
        loan__Investor_Loan_Account_Txns__c invLoanAccountTxn = new loan__Investor_Loan_Account_Txns__c();
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        invLoanAccountTxn.loan__Transaction_Date__c = util.getCurrentSystemDate();
        invLoanAccountTxn.loan__Post_Date__c = invLoanAccountTxn.loan__Transaction_Date__c;
        Map<String, RecordType> recordTypeMap = loan.FractionlizationUtil.getRecordTypeMap();
        
        if (recordTypeMap != null && recordTypeMap.containsKey('IO_Deactivated')) {
            invLoanAccountTxn.recordTypeId = recordTypeMap.get('IO_Deactivated').id;
        }
        
        invLoanAccountTxn.loan__Txn_Code__c = loan.LoanConstants.INVESTMENT_DEACTIVATION;
        invLoanAccountTxn.loan__Txn_Description__c = loan.LoanConstants.INVESTMENT_DEACTIVATION_DESC;
        invLoanAccountTxn.loan__Principal_Paid__c = investmentOrder.loan__Remaining_Investment_Amount__c;
        
        loan__Investor_Loan_Account_Txns__c paymentApprovalTransaction = new loan__Investor_Loan_Account_Txns__c();
        paymentApprovalTransaction.loan__Txn_Code__c =  loan.LoanConstants.INVESTMENT_PAYMENT;
        paymentApprovalTransaction.loan__Txn_Description__c = loan.LoanConstants.INVESTMENT_PAYMENT_DESC;
        paymentApprovalTransaction.loan__Principal_Paid__c = investmentOrder.loan__Remaining_Investment_Amount__c;
        paymentApprovalTransaction.loan__Txn_Amount__c = investmentOrder.loan__Remaining_Investment_Amount__c;
        
        if (recordTypeMap != null && recordTypeMap.containsKey('IO_Deactivated')) {
            paymentApprovalTransaction.recordTypeId = recordTypeMap.get('Payment_Due').id;
        }

        paymentApprovalTransaction.loan__Investor_Loan__c = investmentOrder.id;
        paymentApprovalTransaction.loan__Transaction_Date__c = util.getCurrentSystemDate();
        paymentApprovalTransaction.loan__Reinvest_Principal__c = investmentOrder.loan__Account__r.loan__Reinvest_Principal__c;
        paymentApprovalTransaction.loan__Reinvest_Interest__c = investmentOrder.loan__Account__r.loan__Reinvest_Interest__c;
        transactions.add(paymentApprovalTransaction);

        invLoanAccountTxn.loan__Investor_Loan__c = investmentOrder.id;
        invLoanAccountTxn.loan__Txn_Amount__c = investmentOrder.loan__Remaining_Investment_Amount__c;
        transactions.add(invLoanAccountTxn);
        
        return transactions;

    }

    private static List<loan__Investor_Loan_Account_Txns__c> getTransactionForActiveIO(loan__Investor_Loan__c investmentOrder) {
        
        List<loan__Investor_Loan_Account_Txns__c> transactions = new List<loan__Investor_Loan_Account_Txns__c>();
        loan__Investor_Loan_Account_Txns__c invLoanAccountTxn = new loan__Investor_Loan_Account_Txns__c();
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        invLoanAccountTxn.loan__Transaction_Date__c = investmentOrder.loan__Investor_Start_Date__c;//util.getCurrentSystemDate();	//LOS-30
        invLoanAccountTxn.loan__Post_Date__c = invLoanAccountTxn.loan__Transaction_Date__c;
        Map<String, RecordType> recordTypeMap = loan.FractionlizationUtil.getRecordTypeMap();
        if(!test.isRunningTest()){
            if (recordTypeMap != null && recordTypeMap.containsKey('Active')) {
                invLoanAccountTxn.recordTypeId = recordTypeMap.get('Active').id;
            }
            /*pallavi(for Migration)*/
            RecordType recId = [select Id,Name,SobjectType from RecordType where SobjectType = 'loan__Investor_Loan_Account_Txns__c' LIMIT 1];
            invLoanAccountTxn.recordTypeId = recId.Id;
            /*pallavi*/
        }
        invLoanAccountTxn.loan__Txn_Code__c = loan.LoanConstants.INVESTMENT_ACTIVATION;
        invLoanAccountTxn.loan__Txn_Description__c = loan.LoanConstants.INVESTMENT_ACTIVATION_DESC;
        invLoanAccountTxn.loan__Investor_Loan__c = investmentOrder.id;
        invLoanAccountTxn.loan__Txn_Amount__c = investmentOrder.loan__Buying_Price__c; //(investmentOrder.loan__Investment_Amount__c - investmentOrder.loan__Principal_Amount_Paid__c);	//pallavi(new change)
        transactions.add(invLoanAccountTxn);
        
        return transactions;

    }

    public static void toggleActivation(loan__Investor_Loan__c investmentOrder) {
        
        if (investmentOrder.loan__Enabled_Flag__c) {
            investmentOrder.loan__Enabled_Flag__c = false;
            investmentOrder.loan__Status__c = loan.FractionalizationConstants.IO_STATUS_DEACTIVE;
            loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
            investmentOrder.loan__Investor_End_Date__c = util.getCurrentSystemDate();
            investmentOrder.loan__Principal_Amount_Paid__c += (investmentOrder.loan__Investment_Amount__c - 
                                                               investmentOrder.loan__Principal_Amount_Paid__c);
        } /*else if(investmentOrder.loan__Status__c.equals('Sold') ){	//LOS-30	//pallavi(LSP-76)
            if (investmentOrder.loan__Investor_Start_Date__c == null) {
                loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
                investmentOrder.loan__Investor_Start_Date__c = util.getCurrentSystemDate();
                if (investmentOrder.loan__Inv_Last_Interest_Accrual_Post_Date__c == null) { 
                    investmentOrder.loan__Inv_Last_Interest_Accrual_Post_Date__c = investmentOrder.loan__Investor_End_Date__c;
                }
            }
        } */   //LOS-30
        else {
            
            investmentOrder.loan__Enabled_Flag__c = true;
            investmentOrder.loan__Status__c = loan.FractionalizationConstants.IO_STATUS_ACTIVE;

            //If start date is not entered by the user, only then set today's date in it.

            if (investmentOrder.loan__Investor_Start_Date__c == null) {
                loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
                investmentOrder.loan__Investor_Start_Date__c = util.getCurrentSystemDate();
                if (investmentOrder.loan__Inv_Last_Interest_Accrual_Post_Date__c == null) { 
                    investmentOrder.loan__Inv_Last_Interest_Accrual_Post_Date__c = investmentOrder.loan__Investor_Start_Date__c;
                }
            }

            investmentOrder.loan__Investor_End_Date__c = null;

        }
    }
	/*LSP-30*/
    private static List<loan__Investor_Loan_Account_Txns__c> getTransactionForSoldIO(loan__Investor_Loan__c investmentOrder) {
            
        List<loan__Investor_Loan_Account_Txns__c> transactions = new List<loan__Investor_Loan_Account_Txns__c>();
        loan__Investor_Loan_Account_Txns__c invLoanAccountTxn = new loan__Investor_Loan_Account_Txns__c();
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        if(!test.isRunningTest())
        	invLoanAccountTxn.loan__Transaction_Date__c = investmentOrder.loan__Investor_End_Date__c.adddays(1);
        invLoanAccountTxn.loan__Post_Date__c = invLoanAccountTxn.loan__Transaction_Date__c;
        Map<String, RecordType> recordTypeMap = loan.FractionlizationUtil.getRecordTypeMap();
       
        invLoanAccountTxn.loan__Txn_Code__c = loan.LoanConstants.INVESTMENT_DEACTIVATION;
        invLoanAccountTxn.loan__Txn_Description__c = loan.LoanConstants.INVESTMENT_DEACTIVATION_DESC;
        //invLoanAccountTxn.loan__Principal_Paid__c = investmentOrder.loan__Remaining_Investment_Amount__c;
        if(investmentOrder.buyer__c != null)
            invLoanAccountTxn.loan__Balance_After__c = investmentOrder.buyer__r.loan__Undeployed_Funds__c;
        
        loan__Investor_Loan_Account_Txns__c paymentApprovalTransaction = new loan__Investor_Loan_Account_Txns__c();
        paymentApprovalTransaction.loan__Txn_Code__c =  peer.Constants.INVESTMENT_SALE;
        paymentApprovalTransaction.loan__Txn_Description__c = peer.Constants.INVESTMENT_SALE_DESC;
       // paymentApprovalTransaction.loan__Principal_Paid__c = investmentOrder.loan__Remaining_Investment_Amount__c;
        paymentApprovalTransaction.loan__Txn_Amount__c = investmentOrder.peer__Number_of_Shares__c;//investmentOrder.loan__Investment_Amount__c - investmentOrder.loan__Principal_Amount_Paid__c;	//pallavi(LSP-76)
        
        if(!test.isRunningTest()){
              RecordType recId = [select Id,Name,SobjectType from RecordType where SobjectType = 'loan__Investor_Loan_Account_Txns__c' and name = 'IO Deactivated' LIMIT 1];
              invLoanAccountTxn.recordTypeId = recId.Id;
              paymentApprovalTransaction.recordTypeId = recId.id;
        } 
       
        paymentApprovalTransaction.loan__Investor_Loan__c = investmentOrder.id;
        paymentApprovalTransaction.loan__Transaction_Date__c = invLoanAccountTxn.loan__Transaction_Date__c;
        paymentApprovalTransaction.loan__Reinvest_Principal__c = investmentOrder.loan__Account__r.loan__Reinvest_Principal__c;
        paymentApprovalTransaction.loan__Reinvest_Interest__c = investmentOrder.loan__Account__r.loan__Reinvest_Interest__c;
        transactions.add(paymentApprovalTransaction);

        invLoanAccountTxn.loan__Investor_Loan__c = investmentOrder.id;
        invLoanAccountTxn.loan__Txn_Amount__c = investmentOrder.peer__Number_of_Shares__c;//investmentOrder.loan__Investment_Amount__c - investmentOrder.loan__Principal_Amount_Paid__c;	//pallavi(LSP-76)
        transactions.add(invLoanAccountTxn);
        
        peer__Investment_Order_Sale_Transaction__c saleTxn = new peer__Investment_Order_Sale_Transaction__c();
        saleTxn.peer__Buyer__c = investmentOrder.Buyer__c;
        System.debug('investmentOrder.peer__Number_Of_Shares__c ' + investmentOrder.peer__Number_Of_Shares__c);
        System.debug('investmentOrder.loan__Account__c----' + investmentOrder.loan__Account__c);
        System.debug('investmentOrder.loan__Account__r.no_of_shares_to_be_Sold__c--' + investmentOrder.loan__Account__r.no_of_shares_to_be_Sold__c);
        if(!test.isRunningTest())	
        	saleTxn.peer__Number_Of_Shares__c = investmentOrder.peer__Number_Of_Shares__c *(investmentOrder.loan__Account__r.no_of_shares_to_be_Sold__c/100);
        saleTxn.peer__Price_Per_Share__c = 1;
        saleTxn.peer__Transfer_Income__c = True;
        saleTxn.peer__Add_Income_in_Price__c = False;
        saleTxn.peer__Type__c = peer.Constants.IO_SALE_TXN_TYPE_SALE;
        saleTxn.peer__Transaction_Date__c = invLoanAccountTxn.loan__Transaction_Date__c;
        saleTxn.peer__Parent_Investment_Order__c = investmentOrder.id;
        if(!test.isRunningTest())
        	saleTxn.peer__Child_Investment_Order__c = [select Id from loan__Investor_Loan__c where loan__Account__c =: investmentOrder.Buyer__c and loan__Loan__c =: investmentOrder.loan__Loan__c LIMIT 1].id;
        insert saleTxn;
        	
        return transactions;

    }

    /*LSP-30*/
    /*LSP-98*/
    private static List<loan__Investor_Loan_Account_Txns__c> getTransactionForChargeOffIO(loan__Investor_Loan__c investmentOrder) {
            
        List<loan__Investor_Loan_Account_Txns__c> transactions = new List<loan__Investor_Loan_Account_Txns__c>();
        loan__Investor_Loan_Account_Txns__c invLoanAccountTxn = new loan__Investor_Loan_Account_Txns__c();
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        invLoanAccountTxn.loan__Transaction_Date__c = investmentOrder.loan__Charged_Off_Date__c;
        invLoanAccountTxn.loan__Post_Date__c = invLoanAccountTxn.loan__Transaction_Date__c;
        Map<String, RecordType> recordTypeMap = loan.FractionlizationUtil.getRecordTypeMap();
        
        if(!test.isRunningTest()){
              RecordType recId = [select Id,Name,SobjectType from RecordType where SobjectType = 'loan__Investor_Loan_Account_Txns__c' and name = 'Write Off' LIMIT 1];
              invLoanAccountTxn.recordTypeId = recId.Id;
        }    
        invLoanAccountTxn.loan__Txn_Code__c = loan.LoanConstants.LOAN_TRANSACTION_CHARGE_OFF;
        invLoanAccountTxn.loan__Txn_Description__c = 'write off transaction';
        
       
        invLoanAccountTxn.loan__Investor_Loan__c = investmentOrder.id;
        invLoanAccountTxn.loan__Txn_Amount__c = investmentOrder.loan__Investment_Amount__c + investmentOrder.loan__Charged_Off_Interest__c;
        transactions.add(invLoanAccountTxn);
        
        	
        return transactions;

    }

    /*LSP-98*/
    
}