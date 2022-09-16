/*
* Description: Test class for ChangeTypeOfPayerController.
*/
/* ****************Modification History******************
* Last Modified by        Date          JIRA number
*      1. Pallavi        2020/01/27     LOS-28(Remove references to InvestorAccount field on CL contract)
*
* 		2. Bhanupriya	  2022/02/08	 LSP-523
* 	Purpose:-	create setup method and create dummy account and loan account for Manual payer and auto payer
* 				create two methods for Manual payer and Auto Payer
* 				adding assert statements and starttest() and stoptest() methods
******************Modification History******************/
@isTest
public Class TestChangeTypeOfPayerController{
    
    //Create setup method
    @testSetup
    public static void testsetup(){
        
        loan__Org_Parameters__c loanorg = loan.CustomSettingsUtil.getOrgParameters();
        loanorg.Manual_Payer_Lending_product_name__c = 'Manual Payers';
        loanorg.Auto_Payer_Lending_Product_Name__c = 'Auto Payers';
        upsert loanorg;
        
        //Creating loan account 
        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccounts = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccounts = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccounts ,dummyAccounts);
        dummyFee.loan__Amount__c = 4;
        dummyFee.loan__Time_Of_Charge__c = 'Other';
        upsert dummyFee;
        loan__Fee_Set__c dummyFeeSets = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSets);
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        System.debug('dummyOffice'+dummyOffice.name);
        system.debug('LOan Fee Junction' +dummyFeeJunction);

        //Create a dummy Loan Product for Auto Payer
        loan__Loan_Product__c dummyLP1 = loan.TestHelper.createLoanProduct(dummyOffice,
                                                                           dummyAccounts,
                                                                           curr,
                                                                           dummyFeeSets);
        dummyLP1.name = 'Auto Payers';
        dummyLP1.loan__Pre_Bill_Days__c = 4;
        upsert dummyLP1;

        //Create dummy Lending product for Manual Payer
        loan__Loan_Product__c dummyLPs = loan.TestHelper.createLoanProduct(dummyOffice,
                                                                          dummyAccounts,
                                                                          curr,
                                                                          dummyFeeSets);
        dummyLPs.name = 'Manual Payers';
        dummyLPs.loan__Pre_Bill_Days__c = 4;
        upsert dummyLPs;

        
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();        
        dummyLoanPurpose.loan__Loan_Purpose_Code__c = 'Refinance';
        //create account for dummy client(Manual Payers)
        account dummyClient = new account();
        dummyClient.Name = 'Payoff';
        dummyClient.peer__Last_Name__c = 'Account Name';
        dummyClient.peer__First_Name__c = 'Test Name';
        insert dummyClient;
        
        //create account for dummy client(Auto Payers)
        account dummyClient1 = new account();
        dummyClient1.Name = 'Payoff1';
        dummyClient1.peer__Last_Name__c = 'Account1 LName';
        dummyClient1.peer__First_Name__c = 'Test1 FName';
        insert dummyClient1;


        // Create Investor Account
        Account invacc = new Account(           //LOS-28
            Name = 'Investor Name',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Number_Of_Applications_Invested__c = 6,
            Total_No_of_Application_Limit__c = 40,
            Last_Application_assigned_on__c = system.now()-7,
            Total_Investment_Limit__c = 100000,
            loan__Undeployed_Funds__c = 50000,
            cnotify__Email__c = 'no-replys@testorganization.com',
            peer__First_Name__c = 'Test Ft Name1',
            peer__Last_Name__c='Test Lt Name2',
            no_of_shares_to_be_Sold__c = 2,
            Number_of_Days__c = 0,
            loan__Active__c = 'YES', 
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='213654'
        );
        Insert invacc;
        
        loan__Payment_Mode__c pm = new loan__Payment_Mode__c();
        pm.name = 'Wire';
        insert pm;
        
        //investor bank acc.
        loan__Bank_Account__c bainva = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '6421',
                                                                loan__Bank_Name__c = 'Some Bank',
                                                                loan__Routing_Number__c = '954997698',
                                                                loan__Account_Type__c = 'Checking',
                                                                loan__Active__c = true,
                                                                Unmasked_Bank_Account_Number__c = '97969589',
                                                                loan__Account__c = invacc.id);
        insert bainva;
        
        
        loan__Automated_Payment_Configuration__c invaps = new loan__Automated_Payment_Configuration__c();
        invaps.loan__Payment_Mode__c = pm.id;
        invaps.loan__Bank_Account__c = bainva.id;
        invaps.loan__Filegen_Class__c = 'CustomLoanPaymentTxnNACHAGen';
        invaps.loan__Folder_Name__c = 'ACU';
        invaps.loan__File_Type__c = 'CSV';
        invaps.loan__Event__c = 'LOAN PAYMENT';
        insert invaps;
        
        
        loan__Bank_Account__c bacc = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '7531',
                                                             loan__Bank_Name__c = 'Some Banks',
                                                             loan__Routing_Number__c = '877664433',
                                                             loan__Account_Type__c = 'Checking',
                                                             loan__Active__c = true,
                                                             Unmasked_Bank_Account_Number__c = '99594477',
                                                             loan__Account__c = dummyClient.id);
        insert bacc;
        
        
        //Create a dummy Loan Account for Manual Payer
        loan__Loan_Account__c loanAccount = loan.TestHelper.createLoanAccountForAccountObj(dummyLPs,
                                                                                           dummyClient,
                                                                                           dummyFeeSets,
                                                                                           dummyLoanPurpose,
                                                                                           dummyOffice);
        loanAccount.loan__Number_of_Installments__c     = 11;
        loanAccount.Loan__Loan_Status__c                = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        loanAccount.Loan__Fees_Remaining__c             = 200;
        loanAccount.Loan__Interest_Remaining__c         = 600;
        loanAccount.Loan__Principal_Remaining__c        = 1000;
        loanAccount.Loan__Fractionalization_Status__c   = loan.LoanConstants.FRACTIONALIZATION_STATUS_ACTIVE;
        loanAccount.Loan__Pay_off_Amount_As_Of_Today__c = loanAccount.loan__Fees_Remaining__c + loanAccount.loan__Principal_Remaining__c;
        loanAccount.loan__Delinquent_Amount__c             = 5000;
        loanAccount.loan__Next_Due_Generation_Date__c = date.today().adddays(15);
        loanAccount.loan__Interest_Rate__c              = 10.0; //LOS-28

        upsert loanAccount;  
        system.assertNotEquals(loanAccount.id,null,'LoanAccount not inserted');
        
        //create bank account for Auto Payer
        loan__Bank_Account__c ba1 = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '1211',
                                                              loan__Bank_Name__c = 'Some Bank ',
                                                              loan__Routing_Number__c = '986743299',
                                                              loan__Account_Type__c = 'Checking',
                                                              loan__Active__c = true,
                                                              Unmasked_Bank_Account_Number__c = '99999999',
                                                              loan__Account__c = dummyClient1.id);
        insert ba1;


        // create dummy loan account for Auto Payer
        loan__Loan_Account__c loanAccount1 = loan.TestHelper.createLoanAccountForAccountObj(dummyLP1,
                                                                                            dummyClient1,
                                                                                            dummyFeeSets,
                                                                                            dummyLoanPurpose,
                                                                                            dummyOffice);
        loanAccount1.loan__Number_of_Installments__c     = 12;
        loanAccount1.Loan__Loan_Status__c                = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        loanAccount1.Loan__Fees_Remaining__c             = 100;
        loanAccount1.Loan__Interest_Remaining__c         = 500;
        loanAccount1.Loan__Principal_Remaining__c        = 1000;
        loanAccount1.Loan__Fractionalization_Status__c   = loan.LoanConstants.FRACTIONALIZATION_STATUS_ACTIVE;
        loanAccount1.Loan__Pay_off_Amount_As_Of_Today__c = loanAccount1.loan__Fees_Remaining__c + loanAccount1.loan__Principal_Remaining__c;
        loanAccount1.loan__Delinquent_Amount__c             = 5000;
        loanAccount1.loan__Next_Due_Generation_Date__c = date.today().adddays(15);
        upsert loanAccount1;
        system.assertNotEquals(loanAccount1.id,null,'LoanAccount not inserted');

        /*LOS-28*/
        //create Investor order
        loan__Investor_Loan__c lo = new loan__Investor_Loan__c();
        lo.loan__Certificate_Rate__c                   = 7.0;
        lo.Buyer__c                                    = invacc.id;
        lo.loan__Service_Rate__c                       = 10.0;
        lo.loan__Account__c                            = invacc.id;
        lo.loan__Loan__c                               = loanAccount.id;
        lo.loan__Share__c                              = 100;
        lo.loan__Status__c                             = 'Active';
        lo.loan__Enabled_Flag__c                       =  true;
        lo.loan__Inv_Accrued_Interest_Amt__c           =  0;
        lo.loan__Investment_Amount__c                  = 1000;
        lo.loan__Principal_Amount_Paid__c              = 2;
        lo.loan__Loan_Principal_Remaining__c           =1000;
        lo.loan__Investor_Start_Date__c                = System.today();

        insert lo;

    }

    //create test method for Manual Payer Loan
    //Purpose :- to check Manual Payer Loan updated into auto payer loan

    public static testmethod void manualpayerToAutoPayer(){
        
        loan__Org_Parameters__c orgParam = loan.CustomSettingsUtil.getOrgParameters();
        List<loan__Loan_Product__c> autoProductList = [Select id,name,
                                                       loan__Pre_Bill_Days__c
                                                       From loan__Loan_Product__c
                                                       Where name = : orgParam.Auto_Payer_Lending_Product_Name__c];
        List<loan__Loan_Product__c> mProductList = [Select id,name,
                                                    loan__Pre_Bill_Days__c
                                                    From loan__Loan_Product__c
                                                    Where name = : orgParam.Manual_Payer_Lending_product_name__c];
        System.debug('Manual Product +++ ' + mProductList);

        List<Account> acclist = [select id,
                                 peer__Last_Name__c
                                 from Account
                                 where peer__Last_Name__c='Account Name'];

        loan__Loan_Account__c loanAccount = [select id,
                                             loan__Loan_Product_Name__c,
                                             loan__Next_Due_Generation_Date__c
                                             from loan__Loan_Account__c
                                             where loan__Account__c=: acclist[0].id];
        System.debug('loanAccount +++ ' + loanAccount);
        Test.StartTest();
        ApexPages.StandardController stdctrl = new ApexPages.StandardController(loanAccount);
        ChangeTypeOfPayerController ctopc = new ChangeTypeOfPayerController(stdctrl);
        ctopc.loanAccId = loanAccount.id;
        ctopc.loanAcc = loanAccount;
        ctopc.changeAppStatus();
        ctopc.confirmChanges();
        
        Test.stopTest();


        system.assert(loanAccount.loan__Loan_Product_Name__c == autoProductList[0].id, 'Manual payer to Auto Payer');

    }

    //create test method for Auto Payer Loan
    //Purpose :- to check auto Payer Loan updated into Manual payer loan

    public static testmethod void autopayerToManualpayer(){

        loan__Org_Parameters__c orgParam = loan.CustomSettingsUtil.getOrgParameters();
        List<loan__Loan_Product__c> autoProductList = [Select id,name,
                                                       loan__Pre_Bill_Days__c
                                                       From loan__Loan_Product__c
                                                       Where name = : orgParam.Auto_Payer_Lending_Product_Name__c];

        List<loan__Loan_Product__c> mProductList = [Select id,
                                                    name,
                                                    loan__Pre_Bill_Days__c
                                                    From loan__Loan_Product__c
                                                    Where name = : orgParam.Manual_Payer_Lending_product_name__c];

        System.debug('Auto Product +++ ' + autoProductList);

        List<Account> acclist = [select id,
                                 peer__Last_Name__c
                                 from Account
                                 where peer__Last_Name__c='Account1 LName'];


        loan__Loan_Account__c loanAccount1 = [select id,
                                              loan__Account__c,
                                              loan__Loan_Product_Name__c,
                                              loan__Next_Due_Generation_Date__c
                                              from loan__Loan_Account__c
                                              where loan__Account__c=: acclist[0].id];
        System.debug('loanAccount +++ ' + loanAccount1);

        Test.StartTest();
        
        ApexPages.StandardController stdctrl = new ApexPages.StandardController(loanAccount1);
        ChangeTypeOfPayerController ctopc = new ChangeTypeOfPayerController(stdctrl);
        ctopc.loanAccId = loanAccount1.id;
        ctopc.loanAcc = loanAccount1;
        ctopc.changeAppStatus();
        Test.stopTest();

        system.assert(loanAccount1.loan__Loan_Product_Name__c == mProductList[0].id , 'Auto Payer to Manual payer ');
    }


}