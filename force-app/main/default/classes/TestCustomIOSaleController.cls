/*
* Description: Test class for CustomIOSaleController.
*/
/* ****************Modification History******************
 * Last Modified by        Date          JIRA number
 *      1. Pallavi        2020/01/27     LOS-28(Remove references to InvestorAccount field on CL contract)
 *      2. Shakul         2022/03/29     LSP-562 (Refactored Test Class)
 ******************Modification History******************/
@isTest
public Class TestCustomIOSaleController{
    
    
    @TestSetup
    public static void testSetup(){
        //Create investor acc
        List<Account> listAcc = new List<Account>();
         Account invacc = new Account(
            peer__First_Name__c ='Account',
            peer__Last_Name__c = 'Test',
            loan__Investor__c= true,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = String.valueOf(math.random()).right(9),
            loan__Undeployed_Funds__c = 1601
            );
        listAcc.add(invacc);

        Account dummyClient = new Account(); 
        dummyClient.Name = 'Payoff';
        dummyClient.peer__Last_Name__c = 'AccountOne';
        dummyClient.peer__First_Name__c = 'TestOne';
        listAcc.add(dummyClient);
        insert listAcc;

        //Creating loan account 
        loan.TestHelper.createSeedDataForTesting();
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();

        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');

        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount); 
        dummyFee.loan__Amount__c = 3;      
        dummyFee.loan__Time_Of_Charge__c = 'Other';
        upsert dummyFee;
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);

        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
                            dummyAccount, 
                            curr, 
                            dummyFeeSet);
        dummyLP.name = 'Manual Payer';
        dummyLP.loan__Pre_Bill_Days__c = 5;
        upsert dummyLP;

        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose(); 

        peer__Note_Type__c nt = new peer__Note_Type__c(peer__Denomination__c = 10);
        insert nt;

        //Create a dummy Loan Account
        loan__Loan_Account__c loanAccount = loan.TestHelper.createLoanAccountForAccountObj(dummyLP,
                                                    dummyClient,
                                                    dummyFeeSet,
                                                    dummyLoanPurpose,
                                                    dummyOffice);
        loanAccount.loan__Number_of_Installments__c     = 12;                                  
        loanAccount.Loan__Loan_Status__c                = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        loanAccount.Loan__Fees_Remaining__c             = 100;
        loanAccount.Loan__Interest_Remaining__c         = 500;
        loanAccount.Loan__Principal_Remaining__c        = 1000;
        loanAccount.Loan__Fractionalization_Status__c   = loan.LoanConstants.FRACTIONALIZATION_STATUS_ACTIVE;
        loanAccount.Loan__Pay_off_Amount_As_Of_Today__c = loanAccount.loan__Fees_Remaining__c + loanAccount.loan__Principal_Remaining__c;
        loanAccount.loan__Delinquent_Amount__c             = 5000;
        loanAccount.loan__Next_Due_Generation_Date__c = date.today().adddays(15);
        loanAccount.peer__Note_Type__c = nt.id;
        upsert loanAccount;
        //Create Investment Order
        loan.TestHelper2.createInvestmentOrder(invacc,loanAccount,1600);
    }

    /*Created By: Shakul Siddharth
      Purpose: To check Preview Method in CustomIOSaleController class*/
    public static testMethod void checkPreviewMethod(){
        loan__Investor_Loan__c ilt = [SELECT id, loan__Inv_Accrued_Interest_Amt__c, loan__Principal_Amount_Paid__c,
                                        loan__Account__c FROM loan__Investor_Loan__c];
        ilt.loan__Principal_Amount_Paid__c = 798;
        ilt.loan__Inv_Accrued_Interest_Amt__c = 800;
        update ilt;
        ApexPages.StandardController stdctrl = new ApexPages.StandardController(ilt);
        CustomIOSaleController ctopc = new CustomIOSaleController(stdctrl);
        ctopc.salePrice = 1000;
        ctopc.newIO = ilt;
        ctopc.preview();
        System.assertEquals(false, ctopc.success);
    }
    
    /*Created By: Shakul Siddharth
      Purpose: To check Execute Sale Method in CustomIOSaleController class*/
    public static testMethod void checkExecSaleMethod(){
        loan__Investor_Loan__c ilt = [SELECT id, peer__Number_of_Shares__c FROM loan__Investor_Loan__c];
        ApexPages.StandardController stdctrl = new ApexPages.StandardController(ilt);
        CustomIOSaleController ctopc = new CustomIOSaleController(stdctrl);
        ctopc.isPreview = true;
        ctopc.executeSale();
        System.assertEquals(false, ctopc.success);
    }
}