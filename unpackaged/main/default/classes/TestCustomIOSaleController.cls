/*
* Description: Test class for CustomIOSaleController.
*/
/* ****************Modification History******************
 * Last Modified by        Date          JIRA number
 *      1. Pallavi        2020/01/27     LOS-28(Remove references to InvestorAccount field on CL contract)
 *      
 ******************Modification History******************/
@isTest
public Class TestCustomIOSaleController{
    
    
    public static testmethod void test(){
        Test.StartTest();
        
        loan__Org_Parameters__c loanorg = loan.CustomSettingsUtil.getOrgParameters();
        loanorg.Manual_Payer_Lending_product_name__c = 'Manual Payer';
        loanorg.Auto_Payer_Lending_Product_Name__c = 'Auto Payer';
        upsert loanorg;
        
        //Creating loan account 
        loan.TestHelper.createSeedDataForTesting();
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
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        System.debug('dummyOffice'+dummyOffice.name);

        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP1 = loan.TestHelper.createLoanProduct(dummyOffice,
                            dummyAccount, 
                            curr, 
                            dummyFeeSet);
        dummyLP1.name = 'Auto Payer';
        dummyLP1.loan__Pre_Bill_Days__c = 5;
        upsert dummyLP1;
        
        //Create investor acc
         Account invacc = new Account(
            Name = 'Testinv',
            loan__Investor__c= True,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert invacc;
                          
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
                            dummyAccount, 
                            curr, 
                            dummyFeeSet);
        dummyLP.name = 'Manual Payer';
        dummyLP.loan__Pre_Bill_Days__c = 5;
        upsert dummyLP;

        
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();        
        dummyLoanPurpose.loan__Loan_Purpose_Code__c = 'Refinance';
        account dummyClient = new account(); 
        dummyClient.Name = 'Payoff';
        dummyClient.peer__Last_Name__c = 'Account';
        dummyClient.peer__First_Name__c = 'Test';
        insert dummyClient;
        
        
        loan__Payment_Mode__c pm = new loan__Payment_Mode__c();
        pm.name = 'Wire';
        insert pm;
        
        //investor bank acc.
        loan__Bank_Account__c bainv = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
                                                 loan__Bank_Name__c = 'Some Bank',
                                                 loan__Routing_Number__c = '99999999',
                                                 loan__Account_Type__c = 'Checking',
                                                 loan__Active__c = true,
                                                 Unmasked_Bank_Account_Number__c = '99999999',
                                                 loan__Account__c = invacc.id);
        insert bainv;
        
        loan__Automated_Payment_Configuration__c invaps = new loan__Automated_Payment_Configuration__c();
        invaps.loan__Payment_Mode__c = pm.id;
        invaps.loan__Bank_Account__c = bainv.id;
        invaps.loan__Filegen_Class__c = 'CustomLoanPaymentTxnNACHAGen';
        invaps.loan__Folder_Name__c = 'ACU';
        invaps.loan__File_Type__c = 'CSV';
        invaps.loan__Event__c = 'LOAN PAYMENT';
        insert invaps;
        
        
        loan__Bank_Account__c ba = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
                                                 loan__Bank_Name__c = 'Some Bank',
                                                 loan__Routing_Number__c = '99999999',
                                                 loan__Account_Type__c = 'Checking',
                                                 loan__Active__c = true,
                                                 Unmasked_Bank_Account_Number__c = '99999999',
                                                 loan__Account__c = dummyClient.id);
        insert ba;
        
        
        //Create Investor fund txn
        loan__Investor_Fund_Transaction__c ift = new loan__Investor_Fund_Transaction__c();
        ift.loan__Account__c = invacc.id;
        ift.loan__Cleared__c = True;
        ift.loan__Transaction_Amount__c = 100000;
        ift.loan__Transaction_Date__c = Date.today().adddays(-30);
        ift.loan__Payment_Mode__c = pm.id;
        insert ift;
        
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
        //loanAccount.Investor_Account__c = invacc.id;  //commented(LOS-28)
        upsert loanAccount;  
        system.assertNotEquals(loanAccount.id,null,'LoanAccount not inserted');
        
        //Create Investment Order
        loan__Investor_Loan__c ilt = loan.TestHelper2.createInvestmentOrder(invacc,loanAccount,1600);
        
        ApexPages.StandardController stdctrl = new ApexPages.StandardController(ilt);
        CustomIOSaleController ctopc = new CustomIOSaleController(stdctrl);
        ctopc.ioForSale = ilt;
        //ctopc.newIO =   ;
        //ctopc.sysDate = ;
       // ctopc.success = ;
        ctopc.salePrice = 1000;
        //ctopc.numberOfSharesSold = ;
        ctopc.isPreview = True;
        ctopc.preview();
        ctopc.executeSale();
        
        Test.stopTest();

    }
}