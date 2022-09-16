/* ****************Modification History*****************************************************************
* Modified by      Date            JIRA number
*    Pallavi      2020/12/15      CRM-845
*    Anusha		2020/06/04      LSP-223
*    Anusha		2021/08/26		LSP-328.1
*	 Anusha		2021/10/21		LSP-328.2
* 	 Anusha		2021/11/09		LSP-328.3
*	 Anusha		2021/11/26		LSP-328.4
******************Modification History*****************************************************************/
@isTest(SeeAllData = false)
public class TestWSSetupAPS {
    
    static loan__ACH_Parameters__c createACHParameters(Boolean useLockBasedACH, Boolean multiplePaymentSupport) {
        loan__ACH_Parameters__c ach = new loan__ACH_Parameters__c();
        ach.loan__Organization_Name__c = 'Cloud Lending Inc';
        ach.loan__ACH_ID__c = '4TGD2212-B';
        ach.loan__Fed_Tax_Id__c = '4TGD2211-A';
        ach.loan__Days_In_Advance_To_Create_File__c = 1;
        ach.loan__Lock_Period_for_Investor_Funds__c = 3;
        ach.loan__Lock_Period_for_Loan_Payments__c = 3;
        ach.loan__Use_Lock_Based_ACH__c = useLockBasedACH;
        ach.loan__Multiple_Payment_Method_Support__c = multiplePaymentSupport;
        insert ach;
        return ach;
    }
    static loan__Loan_Account__c createLoanAccount() {       
        //Creating Seed Data for Testing
        loan.TestHelper.createSeedDataForTesting();
        
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct('Loan Product',
                                                                          dummyOffice,
                                                                          dummyAccount,
                                                                          curr,
                                                                          dummyFeeSet,
                                                                          'Interest Only',
                                                                          40,
                                                                          12,
                                                                          null);
        
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        Account acc = new Account(Name = 'SF',peer__Last_Name__c = 'Test');//LSP-328
        insert acc;
        
        loan__Payment_Mode__c paymentMode = new loan__Payment_Mode__c(name='ACH');
        insert paymentMode;
        //Create a dummy Loan Account
        loan__Loan_Account__c loanAccount = loan.TestHelper.createLoanAccountForAccountObj(dummyLP,
                                                                                           acc,
                                                                                           dummyFeeSet,
                                                                                           dummyLoanPurpose,
                                                                                           dummyOffice);
        return loanAccount;
    }
    @isTest
    static void testAPSWithDebitDateLessthanLAD(){ //LSP-328 -- prior to LSP-186, if debit date for one time ACH was before LAD, webservice was not creating APS. After LSP-186, it creates APS       
        loan.TestHelper.systemDate = Date.newInstance(2016, 1, 15);
        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();
        
        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000,peer__Last_Name__c = 'test');//LSP-328
        insert acc;        
        
        loan.TestHelper.createDayProcessForFullYear(loan.Testhelper.systemDate);
        
        loan.GlobalProcessFacade.moveSystemToDate(loan.TestHelper.systemDate.addDays(10), false);
        
        lAcct.loan__Loan_Status__c = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        lAcct.loan__Account__c = acc.id;
        lAcct.loan__Contact__c = null;
        lAcct.lead_Guid__c = 'qwertt';
        lAcct.loan__Last_Accrual_Date__c = loan.TestHelper.systemDate.addDays(8);//LSP-328 updating LAD
        update lAcct;
        
        loan__Payment_Mode__c pMode = [SELECT ID FROM loan__Payment_Mode__c LIMIT 1];
        
        //back-dated payment = LAD = systemDate+8 after this
        loan__Loan_Payment_Transaction__c loanPayTxn = new loan__Loan_Payment_Transaction__c(loan__Transaction_Date__c = loan.TestHelper.systemDate.addDays(8),
                                                                                             loan__Payment_Mode__c = pMode.id,
                                                                                             loan__Transaction_Amount__c = 200,
                                                                                             loan__Loan_Account__c = lAcct.id);
        insert loanPayTxn;
        
        Account invacc = new Account(
            Name = 'Investor',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Number_Of_Applications_Invested__c = 3, 
            Total_No_of_Application_Limit__c = 30,
            Last_Application_assigned_on__c = system.now()-7,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName2',
            no_of_shares_to_be_Sold__c = 1,
            Number_of_Days__c = 0,
            loan__Active__c = 'YES', 
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456'
        );
        Insert invacc;
        loan__Bank_Account__c bankAcc = new loan__Bank_Account__c(loan__Account__c = invacc.id,
                                                                  loan__Active__c = true,
                                                                  loan__Bank_Account_Number__c = '12345',
                                                                  loan__Bank_Name__c = 'Test Bank',
                                                                  loan__Routing_Number__c = '999999999',  //CRM-845
                                                                  loan__Account_Type__c = 'Checking',  //pallavi
                                                                  Unmasked_Bank_Account_Number__c = '12345');
        insert bankAcc;
        loan__Bank_Account__c collectionTrustBA = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
                                                                            loan__Bank_Name__c = 'Some Bank',
                                                                            Unmasked_Bank_Account_Number__c = '123234324',
                                                                            loan__Routing_Number__c = '999999991',  //CRM-845
                                                                            loan__Account_Type__c = 'Checking',
                                                                            loan__Account_Usage__c = 'Collections Trust Account',
                                                                            loan__Account__c = acc.id,
                                                                            loan__Active__c = True);
        insert collectionTrustBA;
        loan__Payment_Mode__c paymentMode = [select id,name from loan__Payment_Mode__c where name='ACH' limit 1];
        loan__Automated_Payment_Configuration__c apc = loan.TestHelper2.createAutomatedPaymentConfiguration('LOAN PAYMENT',
                                                                                                            paymentMode,
                                                                                                            collectionTrustBA,
                                                                                                            'loan.LoanPaymentTxnNACHAGen'); 
        apc.loan__Bank_Account__c = bankAcc.id;
        update apc;
        list<loan__Investor_Loan__c> ioList = new list<loan__Investor_Loan__c>();
        
        loan__Investor_Loan__c lo = new loan__Investor_Loan__c();
        lo.loan__Certificate_Rate__c                   = 1.0;
        lo.Buyer__c                                    = invacc.id;
        lo.loan__Service_Rate__c                       = 10.0;
        lo.loan__Account__c                            = invacc.id;
        lo.loan__Loan__c                               = lAcct.id;
        lo.loan__Share__c                              = 100;
        lo.loan__Status__c                             = 'Active';
        lo.loan__Enabled_Flag__c                       =  true;
        lo.loan__Inv_Accrued_Interest_Amt__c           =  0;
        lo.loan__Investment_Amount__c                  = 1000;
        lo.loan__Principal_Amount_Paid__c              = 2;
        lo.loan__Loan_Principal_Remaining__c           =1000;
        lo.loan__Investor_Start_Date__c                = Date.newInstance(2016, 1, 15);
        insert lo;
        
        lAcct.loan__Account__c = invacc.id;
        update lAcct;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI =  '/services/apexrest/OTPOMBPEndpoint';
        req.httpMethod = 'POST';
        
        String jsonStr = '{"leadGuid" :"'+lAcct.lead_Guid__c+'",  "bankAccountId" : "' + bankAcc.id + '"' +
            + ', "debitDate" : "' + String.valueOf(loan.TestHelper.systemDate.addDays(5)) +
            + '", "type" : "ONE TIME","paymentModeName":"ACH","amountType":"FIXED AMOUNT" '
            + ', "feeAmount" : ' + 100 +
            '}';
        req.requestBody = Blob.valueOf(jsonStr);
        
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        Response results = WSSetupAPS.createAPSSetup();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.SUCCESS));//LSP-328
        List<loan__Automated_Payment_Setup__c> automatedPaymentSetup = [select id,name,loan__installment_payment__c
                                                                        from loan__Automated_Payment_Setup__c 
                                                                        where loan__cl_contract__c=:lAcct.id];
        System.assert(automatedPaymentSetup.size()>0);//LSP-328
        RestRequest req1 = new RestRequest();
        RestResponse res1 = new RestResponse();
        
        req1.requestURI =  '/services/apexrest/OTPOMBPEndpoint';
        req1.httpMethod = 'POST';
        
        jsonStr = '{"leadGuid":"'+lAcct.lead_Guid__c+'", "bankAccountId" : "' + bankAcc.id + '"' +
            + ', "debitDate" : "' + String.valueOf(loan.TestHelper.systemDate.addDays(10)) +
            + '", "type" : "ONE TIME","paymentModeName":"ACH","amountType":"FIXED AMOUNT" '
            + ', "feeAmount" : ' + 100 +
            '}';
        
        req1.requestBody = Blob.valueOf(jsonStr);
        
        RestContext.request = req1;
        RestContext.response = res1;
        
        Response results1 = WSSetupAPS.createAPSSetup();
        Test.stopTest();
        System.assert(results1.status.equalsIgnoreCase(peer.Constants.SUCCESS));//LSP-328
        List<loan__Automated_Payment_Setup__c> automatedPaymentSetups = [select id,name,loan__installment_payment__c
                                                                         from loan__Automated_Payment_Setup__c 
                                                                         where loan__cl_contract__c=:lAcct.id];
        System.assert(automatedPaymentSetups.size()==2);//LSP-328
    }
    
    @isTest
    static void testAPSSuccessCase(){       
        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();
        
        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000,peer__Last_Name__c = 'test');//LSP-328
        insert acc;
        
        Account invacc = new Account(
            Name = 'Investor',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Number_Of_Applications_Invested__c = 3, 
            Total_No_of_Application_Limit__c = 30,
            Last_Application_assigned_on__c = system.now()-7,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName2',
            no_of_shares_to_be_Sold__c = 1,
            Number_of_Days__c = 0,
            loan__Active__c = 'YES', 
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456'
        );
        Insert invacc;
        
        loan__Bank_Account__c bankAcc = new loan__Bank_Account__c(loan__Account__c = invacc.id,
                                                                  loan__Active__c = true,
                                                                  loan__Bank_Account_Number__c = '12345',
                                                                  loan__Bank_Name__c = 'Test Bank',
                                                                  loan__Routing_Number__c = '999999999',  //CRM-845
                                                                  Unmasked_Bank_Account_Number__c = '12345',
                                                                  loan__Account_Type__c = 'Checking'  );//pallavi
        loan__Bank_Account__c collectionTrustBA = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
                                                                            loan__Bank_Name__c = 'Some Bank',
                                                                            Unmasked_Bank_Account_Number__c = '123234324',
                                                                            loan__Routing_Number__c = '999999999',  //CRM-845
                                                                            loan__Account_Type__c = 'Checking',
                                                                            loan__Account_Usage__c = 'Collections Trust Account',
                                                                            loan__Account__c = acc.id,
                                                                            loan__Active__c = True);
        insert bankAcc ;
        lAcct.loan__Loan_Status__c = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        lAcct.loan__Account__c = acc.id;
        lAcct.loan__Contact__c = null;
        lAcct.lead_Guid__c = 'qwertt';
        //lAcct.Investor_Account__c = acc.id;  //commented(LOS-28)
        update(lAcct);
        loan__Payment_Mode__c paymentMode = [select id,name from loan__Payment_Mode__c where name='ACH' limit 1];
        loan__Automated_Payment_Configuration__c apc = loan.TestHelper2.createAutomatedPaymentConfiguration('LOAN PAYMENT',
                                                                                                            paymentMode,
                                                                                                            collectionTrustBA,
                                                                                                            'loan.LoanPaymentTxnNACHAGen');
        
        
        apc.loan__Bank_Account__c = bankAcc.id;
        update apc;
        
        list<loan__Investor_Loan__c> ioList = new list<loan__Investor_Loan__c>();     
        loan__Investor_Loan__c lo = new loan__Investor_Loan__c();
        lo.loan__Certificate_Rate__c                   = 1.0;
        lo.Buyer__c                                    = invacc.id;
        lo.loan__Service_Rate__c                       = 10.0;
        lo.loan__Account__c                            = invacc.id;
        lo.loan__Loan__c                               = lAcct.id;
        lo.loan__Share__c                              = 100;
        lo.loan__Status__c                             = 'Active';
        lo.loan__Enabled_Flag__c                       =  true;
        lo.loan__Inv_Accrued_Interest_Amt__c           =  0;
        lo.loan__Investment_Amount__c                  = 1000;
        lo.loan__Principal_Amount_Paid__c              = 2;
        lo.loan__Loan_Principal_Remaining__c           =1000;
        lo.loan__Investor_Start_Date__c                = System.today();
        
        insert lo;
        
        lAcct.loan__Account__c = invacc.id;
        update lAcct;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI =  '/services/apexrest/OTPOMBPEndpoint';
        req.httpMethod = 'POST';
        
        String jsonStr = '{"leadGuid" :"'+lAcct.lead_Guid__c+'",  "bankAccountId" : "' + bankAcc.id + '", "transactionAmount" : ' + 1000
            + ', "debitDate" : "' + String.valueOf(Date.today()) +
            + '", "type" : "ONE TIME", "paymentModeName":"ACH", "amountType":"FIXED AMOUNT","installmentOmbp": '+true+
            + ', "feeAmount" : ' + 100 +
            '}';
        req.requestBody = Blob.valueOf(jsonStr);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        loan__Loan_account_Due_Details__c bill = new loan__Loan_account_Due_Details__c(loan__DD_Primary_Flag__c = true,
                                                                                       loan__Payment_Satisfied__c = false,
                                                                                       loan__Due_Date__c = System.today().adddays(2),
                                                                                       loan__Loan_Account__c = lAcct.id);
        insert bill;       
        Response results = WSSetupAPS.createAPSSetup();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.SUCCESS));
        List<loan__Automated_Payment_Setup__c> automatedPaymentSetups = [select id,name,loan__installment_payment__c
                                                                         from loan__Automated_Payment_Setup__c 
                                                                         where loan__cl_contract__c=:lAcct.id];
        System.assert(automatedPaymentSetups.size()>0);//LSP-328
        System.assertEquals(true, automatedPaymentSetups[0].loan__installment_payment__c);//LSP-328 - when unpaid future bill exists on a good standing loan, installment flag should be true on APS
        Test.stopTest();
    }
    
    @isTest
    static void testAPSwithLADgreaterthanSystemDate(){  
        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();
        
        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000,peer__Last_Name__c = 'test');//LSP-328
        insert acc;
        
        Account invacc = new Account(
            Name = 'Investor',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Number_Of_Applications_Invested__c = 3, 
            Total_No_of_Application_Limit__c = 30,
            Last_Application_assigned_on__c = system.now()-7,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName2',
            no_of_shares_to_be_Sold__c = 1,
            Number_of_Days__c = 0,
            loan__Active__c = 'YES', 
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456'
        );
        Insert invacc;
        
        loan__Bank_Account__c bankAcc = new loan__Bank_Account__c(loan__Account__c = invacc.id,
                                                                  loan__Active__c = true,
                                                                  loan__Bank_Account_Number__c = '12345',
                                                                  loan__Bank_Name__c = 'Test Bank',
                                                                  loan__Routing_Number__c = '999999999',  //CRM-845
                                                                  Unmasked_Bank_Account_Number__c = '12345',
                                                                  loan__Account_Type__c = 'Checking'  );//pallavi
        loan__Bank_Account__c collectionTrustBA = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
                                                                            loan__Bank_Name__c = 'Some Bank',
                                                                            Unmasked_Bank_Account_Number__c = '123234324',
                                                                            loan__Routing_Number__c = '999999999',  //CRM-845
                                                                            loan__Account_Type__c = 'Checking',
                                                                            loan__Account_Usage__c = 'Collections Trust Account',
                                                                            loan__Account__c = acc.id,
                                                                            loan__Active__c = True);
        insert bankAcc ;
        lAcct.loan__Loan_Status__c = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        lAcct.loan__Account__c = acc.id;
        lAcct.loan__Contact__c = null;
        lAcct.lead_Guid__c = 'qwertt';
        lAcct.loan__Last_Accrual_Date__c = Date.today().addDays(20);
        //lAcct.Investor_Account__c = acc.id;  //commented(LOS-28)
        update(lAcct);
        loan__Payment_Mode__c paymentMode = [select id,name from loan__Payment_Mode__c where name='ACH' limit 1];
        loan__Automated_Payment_Configuration__c apc = loan.TestHelper2.createAutomatedPaymentConfiguration('LOAN PAYMENT',
                                                                                                            paymentMode,
                                                                                                            collectionTrustBA,
                                                                                                            'loan.LoanPaymentTxnNACHAGen');
        
        
        apc.loan__Bank_Account__c = bankAcc.id;
        update apc;
        
        list<loan__Investor_Loan__c> ioList = new list<loan__Investor_Loan__c>();     
        loan__Investor_Loan__c lo = new loan__Investor_Loan__c();
        lo.loan__Certificate_Rate__c                   = 1.0;
        lo.Buyer__c                                    = invacc.id;
        lo.loan__Service_Rate__c                       = 10.0;
        lo.loan__Account__c                            = invacc.id;
        lo.loan__Loan__c                               = lAcct.id;
        lo.loan__Share__c                              = 100;
        lo.loan__Status__c                             = 'Active';
        lo.loan__Enabled_Flag__c                       =  true;
        lo.loan__Inv_Accrued_Interest_Amt__c           =  0;
        lo.loan__Investment_Amount__c                  = 1000;
        lo.loan__Principal_Amount_Paid__c              = 2;
        lo.loan__Loan_Principal_Remaining__c           =1000;
        lo.loan__Investor_Start_Date__c                = System.today();
        
        insert lo;
        
        lAcct.loan__Account__c = invacc.id;
        update lAcct;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI =  '/services/apexrest/OTPOMBPEndpoint';
        req.httpMethod = 'POST';
        
        String jsonStr = '{"leadGuid" :"'+lAcct.lead_Guid__c+'",  "bankAccountId" : "' + bankAcc.id + '", "transactionAmount" : ' + 1000
            + ', "debitDate" : "' + String.valueOf(Date.today()) +
            + '", "type" : "ONE TIME", "paymentModeName":"ACH", "amountType":"FIXED AMOUNT","installmentOmbp": '+true+
            + ', "feeAmount" : ' + 100 +
            '}';
        req.requestBody = Blob.valueOf(jsonStr);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();    
        Response results = WSSetupAPS.createAPSSetup();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.SUCCESS));
        List<loan__Automated_Payment_Setup__c> automatedPaymentSetups = [select id,name,loan__installment_payment__c
                                                                         from loan__Automated_Payment_Setup__c 
                                                                         where loan__cl_contract__c=:lAcct.id];
        System.assert(automatedPaymentSetups.size()>0);//LSP-328
        System.assertEquals(true, automatedPaymentSetups[0].loan__installment_payment__c);//LSP-328 - when LAD on loan is greater than system date,APS gets created with installment flag enabled
        Test.stopTest();
    }
    
    @isTest
    static void testAPSSuccessCase1BadStandingLoan(){       
        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();
        
        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000,peer__Last_Name__c = 'test');//LSP-328
        insert acc;
        
        Account invacc = new Account(
            Name = 'Investor',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Number_Of_Applications_Invested__c = 3, 
            Total_No_of_Application_Limit__c = 30,
            Last_Application_assigned_on__c = system.now()-7,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName2',
            no_of_shares_to_be_Sold__c = 1,
            Number_of_Days__c = 0,
            loan__Active__c = 'YES', 
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456'
        );
        Insert invacc;
        
        loan__Bank_Account__c bankAcc = new loan__Bank_Account__c(loan__Account__c = invacc.id,
                                                                  loan__Active__c = true,
                                                                  loan__Bank_Account_Number__c = '12345',
                                                                  loan__Bank_Name__c = 'Test Bank',
                                                                  loan__Routing_Number__c = '999999999',  //CRM-845
                                                                  Unmasked_Bank_Account_Number__c = '12345',
                                                                  loan__Account_Type__c = 'Checking'  );//pallavi
        loan__Bank_Account__c collectionTrustBA = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
                                                                            loan__Bank_Name__c = 'Some Bank',
                                                                            Unmasked_Bank_Account_Number__c = '123234324',
                                                                            loan__Routing_Number__c = '999999999',  //CRM-845
                                                                            loan__Account_Type__c = 'Checking',
                                                                            loan__Account_Usage__c = 'Collections Trust Account',
                                                                            loan__Account__c = acc.id,
                                                                            loan__Active__c = True);
        insert bankAcc ;
        lAcct.loan__Loan_Status__c = 'Active - Bad Standing';
        lAcct.loan__Account__c = acc.id;
        lAcct.loan__Contact__c = null;
        lAcct.lead_Guid__c = 'qwertt';
        lAcct.loan__Delinquent_Amount__c = 200;
        update(lAcct);
        loan__Payment_Mode__c paymentMode = [select id,name from loan__Payment_Mode__c where name='ACH' limit 1];
        loan__Automated_Payment_Configuration__c apc = loan.TestHelper2.createAutomatedPaymentConfiguration('LOAN PAYMENT',
                                                                                                            paymentMode,
                                                                                                            collectionTrustBA,
                                                                                                            'loan.LoanPaymentTxnNACHAGen');
        
        
        apc.loan__Bank_Account__c = bankAcc.id;
        update apc;
        
        list<loan__Investor_Loan__c> ioList = new list<loan__Investor_Loan__c>();     
        loan__Investor_Loan__c lo = new loan__Investor_Loan__c();
        lo.loan__Certificate_Rate__c                   = 1.0;
        lo.Buyer__c                                    = invacc.id;
        lo.loan__Service_Rate__c                       = 10.0;
        lo.loan__Account__c                            = invacc.id;
        lo.loan__Loan__c                               = lAcct.id;
        lo.loan__Share__c                              = 100;
        lo.loan__Status__c                             = 'Active';
        lo.loan__Enabled_Flag__c                       =  true;
        lo.loan__Inv_Accrued_Interest_Amt__c           =  0;
        lo.loan__Investment_Amount__c                  = 1000;
        lo.loan__Principal_Amount_Paid__c              = 2;
        lo.loan__Loan_Principal_Remaining__c           =1000;
        lo.loan__Investor_Start_Date__c                = System.today();
        
        insert lo;
        
        lAcct.loan__Account__c = invacc.id;
        update lAcct;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI =  '/services/apexrest/OTPOMBPEndpoint';
        req.httpMethod = 'POST';
        
        String jsonStr = '{"leadGuid" :"'+lAcct.lead_Guid__c+'",  "bankAccountId" : "' + bankAcc.id + '", "transactionAmount" : ' + 1000
            + ', "debitDate" : "' + String.valueOf(Date.today()) +
            + '", "type" : "ONE TIME", "paymentModeName":"ACH", "amountType":"FIXED AMOUNT","installmentOmbp": '+true+
            + ', "feeAmount" : ' + 400 +
            '}';
        req.requestBody = Blob.valueOf(jsonStr);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        loan__Loan_account_Due_Details__c bill = new loan__Loan_account_Due_Details__c(loan__DD_Primary_Flag__c = true,
                                                                                       loan__Payment_Satisfied__c = false,
                                                                                       loan__Due_Date__c = System.today().adddays(2),
                                                                                       loan__Loan_Account__c = lAcct.id);
        insert bill;
        Response results = WSSetupAPS.createAPSSetup();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.SUCCESS));
        List<loan__Automated_Payment_Setup__c> automatedPaymentSetups = [select id,name,loan__installment_payment__c
                                                                         from loan__Automated_Payment_Setup__c 
                                                                         where loan__cl_contract__c=:lAcct.id];
        System.assert(automatedPaymentSetups.size()>0);//LSP-328
        System.assertEquals(true, automatedPaymentSetups[0].loan__installment_payment__c);//LSP-328 - if trx amount>delinquent amount on loan and future, APS should get created with installment payment flag true
        Test.stopTest();
    }
    
    @isTest
    static void testAPSSuccessCase2ForBadStandingLoan(){       
        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();
        
        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000,peer__Last_Name__c = 'test');//LSP-328
        insert acc;
        
        Account invacc = new Account(
            Name = 'Investor',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Number_Of_Applications_Invested__c = 3, 
            Total_No_of_Application_Limit__c = 30,
            Last_Application_assigned_on__c = system.now()-7,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName2',
            no_of_shares_to_be_Sold__c = 1,
            Number_of_Days__c = 0,
            loan__Active__c = 'YES', 
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456'
        );
        Insert invacc;
        
        loan__Bank_Account__c bankAcc = new loan__Bank_Account__c(loan__Account__c = invacc.id,
                                                                  loan__Active__c = true,
                                                                  loan__Bank_Account_Number__c = '12345',
                                                                  loan__Bank_Name__c = 'Test Bank',
                                                                  loan__Routing_Number__c = '999999999',  //CRM-845
                                                                  Unmasked_Bank_Account_Number__c = '12345',
                                                                  loan__Account_Type__c = 'Checking'  );//pallavi
        loan__Bank_Account__c collectionTrustBA = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
                                                                            loan__Bank_Name__c = 'Some Bank',
                                                                            Unmasked_Bank_Account_Number__c = '123234324',
                                                                            loan__Routing_Number__c = '999999999',  //CRM-845
                                                                            loan__Account_Type__c = 'Checking',
                                                                            loan__Account_Usage__c = 'Collections Trust Account',
                                                                            loan__Account__c = acc.id,
                                                                            loan__Active__c = True);
        insert bankAcc ;
        lAcct.loan__Loan_Status__c = 'Active - Bad Standing';
        lAcct.loan__Account__c = acc.id;
        lAcct.loan__Contact__c = null;
        lAcct.lead_Guid__c = 'qwertt';
        lAcct.loan__Delinquent_Amount__c = 200;
        lAcct.loan__Next_Due_Generation_Date__c = Date.today().adddays(-5);
        lAcct.loan__Next_Installment_Date__c = Date.today().adddays(5);
        update(lAcct);
        loan__Payment_Mode__c paymentMode = [select id,name from loan__Payment_Mode__c where name='ACH' limit 1];
        loan__Automated_Payment_Configuration__c apc = loan.TestHelper2.createAutomatedPaymentConfiguration('LOAN PAYMENT',
                                                                                                            paymentMode,
                                                                                                            collectionTrustBA,
                                                                                                            'loan.LoanPaymentTxnNACHAGen');
        
        
        apc.loan__Bank_Account__c = bankAcc.id;
        update apc;
        
        list<loan__Investor_Loan__c> ioList = new list<loan__Investor_Loan__c>();     
        loan__Investor_Loan__c lo = new loan__Investor_Loan__c();
        lo.loan__Certificate_Rate__c                   = 1.0;
        lo.Buyer__c                                    = invacc.id;
        lo.loan__Service_Rate__c                       = 10.0;
        lo.loan__Account__c                            = invacc.id;
        lo.loan__Loan__c                               = lAcct.id;
        lo.loan__Share__c                              = 100;
        lo.loan__Status__c                             = 'Active';
        lo.loan__Enabled_Flag__c                       =  true;
        lo.loan__Inv_Accrued_Interest_Amt__c           =  0;
        lo.loan__Investment_Amount__c                  = 1000;
        lo.loan__Principal_Amount_Paid__c              = 2;
        lo.loan__Loan_Principal_Remaining__c           =1000;
        lo.loan__Investor_Start_Date__c                = System.today();        
        insert lo;
        
        lAcct.loan__Account__c = invacc.id;
        update lAcct;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI =  '/services/apexrest/OTPOMBPEndpoint';
        req.httpMethod = 'POST';
        
        String jsonStr = '{"leadGuid" :"'+lAcct.lead_Guid__c+'",  "bankAccountId" : "' + bankAcc.id + '", "transactionAmount" : ' + 1000
            + ', "debitDate" : "' + String.valueOf(Date.today()) +
            + '", "type" : "ONE TIME", "paymentModeName":"ACH", "amountType":"FIXED AMOUNT","installmentOmbp": '+true+
            + ', "feeAmount" : ' + 400 +
            '}';
        req.requestBody = Blob.valueOf(jsonStr);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();        
        Response results = WSSetupAPS.createAPSSetup();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.SUCCESS));
        List<loan__Automated_Payment_Setup__c> automatedPaymentSetups = [select id,name,loan__installment_payment__c
                                                                         from loan__Automated_Payment_Setup__c 
                                                                         where loan__cl_contract__c=:lAcct.id];
        System.assert(automatedPaymentSetups.size()>0);//LSP-328
        System.assertEquals(true, automatedPaymentSetups[0].loan__installment_payment__c);//LSP-328
        Test.stopTest();
    }
    
    @isTest
    static void testAPSSuccessCaseForGoodStandingLoan(){       
        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();
        
        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000,peer__Last_Name__c = 'test');//LSP-328
        insert acc;
        
        Account invacc = new Account(
            Name = 'Investor',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Number_Of_Applications_Invested__c = 3, 
            Total_No_of_Application_Limit__c = 30,
            Last_Application_assigned_on__c = system.now()-7,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName2',
            no_of_shares_to_be_Sold__c = 1,
            Number_of_Days__c = 0,
            loan__Active__c = 'YES', 
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456'
        );
        Insert invacc;
        
        loan__Bank_Account__c bankAcc = new loan__Bank_Account__c(loan__Account__c = invacc.id,
                                                                  loan__Active__c = true,
                                                                  loan__Bank_Account_Number__c = '12345',
                                                                  loan__Bank_Name__c = 'Test Bank',
                                                                  loan__Routing_Number__c = '999999999',  //CRM-845
                                                                  Unmasked_Bank_Account_Number__c = '12345',
                                                                  loan__Account_Type__c = 'Checking'  );//pallavi
        loan__Bank_Account__c collectionTrustBA = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
                                                                            loan__Bank_Name__c = 'Some Bank',
                                                                            Unmasked_Bank_Account_Number__c = '123234324',
                                                                            loan__Routing_Number__c = '999999999',  //CRM-845
                                                                            loan__Account_Type__c = 'Checking',
                                                                            loan__Account_Usage__c = 'Collections Trust Account',
                                                                            loan__Account__c = acc.id,
                                                                            loan__Active__c = True);
        insert bankAcc ;
        lAcct.loan__Loan_Status__c = 'Active - Good Standing';
        lAcct.loan__Account__c = acc.id;
        lAcct.loan__Contact__c = null;
        lAcct.lead_Guid__c = 'qwertt';
        lAcct.loan__Next_Due_Generation_Date__c = Date.today().adddays(-5);
        lAcct.loan__Next_Installment_Date__c = Date.today().adddays(5);
        update(lAcct);
        loan__Payment_Mode__c paymentMode = [select id,name from loan__Payment_Mode__c where name='ACH' limit 1];
        loan__Automated_Payment_Configuration__c apc = loan.TestHelper2.createAutomatedPaymentConfiguration('LOAN PAYMENT',
                                                                                                            paymentMode,
                                                                                                            collectionTrustBA,
                                                                                                            'loan.LoanPaymentTxnNACHAGen');
        
        
        apc.loan__Bank_Account__c = bankAcc.id;
        update apc;
        
        list<loan__Investor_Loan__c> ioList = new list<loan__Investor_Loan__c>();     
        loan__Investor_Loan__c lo = new loan__Investor_Loan__c();
        lo.loan__Certificate_Rate__c                   = 1.0;
        lo.Buyer__c                                    = invacc.id;
        lo.loan__Service_Rate__c                       = 10.0;
        lo.loan__Account__c                            = invacc.id;
        lo.loan__Loan__c                               = lAcct.id;
        lo.loan__Share__c                              = 100;
        lo.loan__Status__c                             = 'Active';
        lo.loan__Enabled_Flag__c                       =  true;
        lo.loan__Inv_Accrued_Interest_Amt__c           =  0;
        lo.loan__Investment_Amount__c                  = 1000;
        lo.loan__Principal_Amount_Paid__c              = 2;
        lo.loan__Loan_Principal_Remaining__c           =1000;
        lo.loan__Investor_Start_Date__c                = System.today();        
        insert lo;
        
        lAcct.loan__Account__c = invacc.id;
        update lAcct;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI =  '/services/apexrest/OTPOMBPEndpoint';
        req.httpMethod = 'POST';
        
        String jsonStr = '{"leadGuid" :"'+lAcct.lead_Guid__c+'",  "bankAccountId" : "' + bankAcc.id + '", "transactionAmount" : ' + 1000
            + ', "debitDate" : "' + String.valueOf(Date.today()) +
            + '", "type" : "ONE TIME", "paymentModeName":"ACH", "amountType":"FIXED AMOUNT","installmentOmbp": '+true+
            + ', "feeAmount" : ' + 400 +
            '}';
        req.requestBody = Blob.valueOf(jsonStr);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();        
        Response results = WSSetupAPS.createAPSSetup();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.SUCCESS));
        List<loan__Automated_Payment_Setup__c> automatedPaymentSetups = [select id,name,loan__installment_payment__c
                                                                         from loan__Automated_Payment_Setup__c 
                                                                         where loan__cl_contract__c=:lAcct.id];
        System.assert(automatedPaymentSetups.size()>0);//LSP-328
        System.assertEquals(true, automatedPaymentSetups[0].loan__installment_payment__c);//LSP-328
        Test.stopTest();
    }
    
    @isTest
    static void testAPSFailureCase(){
        loan__ACH_Parameters__c achParameters = createACHParameters(false, false);
        loan__Loan_Account__c lAcct = createLoanAccount();
        
        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000,peer__Last_Name__c = 'test');//LSP-328
        insert acc;
        
        lAcct.loan__Loan_Status__c = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        lAcct.loan__Account__c = acc.id;
        lAcct.loan__Contact__c = null;
        lAcct.lead_Guid__c = 'qwertt';
        update(lAcct);
        
        loan__Bank_Account__c bankAcc = new loan__Bank_Account__c(loan__Account__c = acc.id,
                                                                  loan__Active__c = true,
                                                                  loan__Bank_Account_Number__c = '12345',
                                                                  loan__Bank_Name__c = 'Test Bank',
                                                                  loan__Routing_Number__c = '999999999',  //CRM-845
                                                                  loan__Account_Type__c = 'Checking',  //pallavi
                                                                  Unmasked_Bank_Account_Number__c = '12345');
        insert bankAcc ;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI =  '/services/apexrest/OTPOMBPEndpoint';
        req.httpMethod = 'POST';
        
        String jsonStr = '{"leadGuid" :"'+lAcct.lead_Guid__c+'",  "bankAccountId" : "' + bankAcc.id + '", "transactionAmount" : ' + 1000
            + ', "debitDate" : "' + String.valueOf(Date.today()) +
            + '", "type" : "ONE TIME", "paymentModeName":"ACH", "amountType":"FIXED AMOUNT","installmentOmbp": '+true+
            + ', "feeAmount" : ' + 100 +
            '}';
        req.requestBody = Blob.valueOf(jsonStr);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        Response results = WSSetupAPS.createAPSSetup();
        Test.stopTest();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.ERROR));//Either Lock Based ACH or Multiple Payment Method Support must be enabled to use this feature
        System.assertEquals(peer.Constants.HTTP_BAD_REQUEST, res.statusCode);//LSP-328         
    }
    
    @isTest
    static void testAPSwithLeadIDNull(){
        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();
        
        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000,peer__Last_Name__c = 'test');//LSP-328
        insert acc;
        
        lAcct.loan__Loan_Status__c = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        lAcct.loan__Account__c = acc.id;
        lAcct.loan__Contact__c = null;
        update(lAcct);
        
        loan__Bank_Account__c bankAcc = new loan__Bank_Account__c(loan__Account__c = acc.id,
                                                                  loan__Active__c = true,
                                                                  loan__Bank_Account_Number__c = '12345',
                                                                  loan__Bank_Name__c = 'Test Bank',
                                                                  loan__Routing_Number__c = '999999999',  //CRM-845
                                                                  loan__Account_Type__c = 'Checking',  //pallavi
                                                                  Unmasked_Bank_Account_Number__c = '12345');
        insert bankAcc ;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI =  '/services/apexrest/OTPOMBPEndpoint';
        req.httpMethod = 'POST';
        
        String jsonStr = '{  "bankAccountId" : "' + bankAcc.id + '", "transactionAmount" : ' + 1000
            + ', "debitDate" : "' + String.valueOf(Date.today()) +
            + '", "type" : "ONE TIME", "paymentModeName":"ACH", "amountType":"FIXED AMOUNT","installmentOmbp": '+true+
            + ', "feeAmount" : ' + 100 +
            '}';
        req.requestBody = Blob.valueOf(jsonStr);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        Response results = WSSetupAPS.createAPSSetup();
        Test.stopTest();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.ERROR));
        System.assertEquals(peer.Constants.HTTP_BAD_REQUEST, res.statusCode);//LSP-328
    }
    
    @isTest
    static void testAPSwithLeadIDInvalid(){
        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();
        
        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000,peer__Last_Name__c = 'test');//LSP-328
        insert acc;
        
        lAcct.loan__Loan_Status__c = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        lAcct.loan__Account__c = acc.id;
        lAcct.loan__Contact__c = null;
        update(lAcct);
        
        loan__Bank_Account__c bankAcc = new loan__Bank_Account__c(loan__Account__c = acc.id,
                                                                  loan__Active__c = true,
                                                                  loan__Bank_Account_Number__c = '12345',
                                                                  loan__Bank_Name__c = 'Test Bank',
                                                                  loan__Routing_Number__c = '999999999',  //CRM-845
                                                                  loan__Account_Type__c = 'Checking',  //pallavi
                                                                  Unmasked_Bank_Account_Number__c = '12345');
        insert bankAcc ;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI =  '/services/apexrest/OTPOMBPEndpoint';
        req.httpMethod = 'POST';
        
        String jsonStr = '{ "leadGuid" :"abc", "bankAccountId" : "' + bankAcc.id + '", "transactionAmount" : ' + 1000
            + ', "debitDate" : "' + String.valueOf(Date.today()) +
            + '", "type" : "ONE TIME", "paymentModeName":"ACH", "amountType":"FIXED AMOUNT","installmentOmbp": '+true+
            + ', "feeAmount" : ' + 100 +
            '}';
        req.requestBody = Blob.valueOf(jsonStr);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        Response results = WSSetupAPS.createAPSSetup();
        Test.stopTest();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.ERROR));
        System.assertEquals(peer.Constants.HTTP_BAD_REQUEST, res.statusCode);//LSP-328
    }
    
    @isTest
    static void testAPSwithDebitDateNotPresent(){
        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();
        
        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000,peer__Last_Name__c = 'test');//LSP-328
        insert acc;
        
        lAcct.loan__Loan_Status__c = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        lAcct.loan__Account__c = acc.id;
        lAcct.loan__Contact__c = null;
        lAcct.lead_Guid__c = 'ewgfewf';
        update(lAcct);
        
        loan__Bank_Account__c bankAcc = new loan__Bank_Account__c(loan__Account__c = acc.id,
                                                                  loan__Active__c = true,
                                                                  loan__Bank_Account_Number__c = '12345',
                                                                  loan__Bank_Name__c = 'Test Bank',
                                                                  loan__Routing_Number__c = '999999999',  //CRM-845
                                                                  loan__Account_Type__c = 'Checking',  //pallavi
                                                                  Unmasked_Bank_Account_Number__c = '12345');
        insert bankAcc ;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI =  '/services/apexrest/OTPOMBPEndpoint';
        req.httpMethod = 'POST';
        
        String jsonStr = '{ "leadGuid" :"'+lAcct.lead_Guid__c+'", "bankAccountId" : "' + bankAcc.id + '", "transactionAmount" : ' + 1000
            + ', "type" : "ONE TIME", "paymentModeName":"ACH", "amountType":"FIXED AMOUNT","installmentOmbp": '+true+
            + ', "feeAmount" : ' + 100 +
            '}';
        req.requestBody = Blob.valueOf(jsonStr);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        Response results = WSSetupAPS.createAPSSetup();
        Test.stopTest();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.ERROR));
        System.assertEquals(peer.Constants.HTTP_BAD_REQUEST, res.statusCode);//LSP-328
    }
    
    @isTest
    static void testAPSwithAmountTypeNull(){
        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();
        
        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000,peer__Last_Name__c = 'test');//LSP-328
        insert acc;
        
        lAcct.loan__Loan_Status__c = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        lAcct.loan__Account__c = acc.id;
        lAcct.loan__Contact__c = null;
        lAcct.lead_Guid__c = 'ewgfewf';
        update(lAcct);
        
        loan__Bank_Account__c bankAcc = new loan__Bank_Account__c(loan__Account__c = acc.id,
                                                                  loan__Active__c = true,
                                                                  loan__Bank_Account_Number__c = '12345',
                                                                  loan__Bank_Name__c = 'Test Bank',
                                                                  loan__Routing_Number__c = '999999999',  //CRM-845
                                                                  loan__Account_Type__c = 'Checking',  //pallavi
                                                                  Unmasked_Bank_Account_Number__c = '12345');
        insert bankAcc ;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI =  '/services/apexrest/OTPOMBPEndpoint';
        req.httpMethod = 'POST';
        
        String jsonStr = '{ "leadGuid" :"'+lAcct.lead_Guid__c+'", "bankAccountId" : "' + bankAcc.id + '", "transactionAmount" : ' + 1000+
            + ', "debitDate" : "' + String.valueOf(Date.today()) +
            + '", "type" : "ONE TIME", "paymentModeName":"ACH", "installmentOmbp": '+true+
            + ', "feeAmount" : ' + 100 +
            '}';
        req.requestBody = Blob.valueOf(jsonStr);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        Response results = WSSetupAPS.createAPSSetup();
        Test.stopTest();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.ERROR));
        System.assertEquals(peer.Constants.HTTP_BAD_REQUEST, res.statusCode);//LSP-328
    }
    
    @isTest
    static void testAPSwithRequestNull(){
        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();
        
        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000, peer__Last_Name__c = 'test');//LSP-328
        insert acc;
        
        lAcct.loan__Loan_Status__c = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        lAcct.loan__Account__c = acc.id;
        lAcct.loan__Contact__c = null;
        lAcct.lead_Guid__c = 'ewgfewf';
        update(lAcct);
        
        loan__Bank_Account__c bankAcc = new loan__Bank_Account__c(loan__Account__c = acc.id,
                                                                  loan__Active__c = true,
                                                                  loan__Bank_Account_Number__c = '12345',
                                                                  loan__Bank_Name__c = 'Test Bank',
                                                                  loan__Routing_Number__c = '999999999',  //CRM-845
                                                                  loan__Account_Type__c = 'Checking',  //pallavi
                                                                  Unmasked_Bank_Account_Number__c = '12345');
        insert bankAcc ;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI =  '/services/apexrest/OTPOMBPEndpoint';
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        Response results = WSSetupAPS.createAPSSetup();
        Test.stopTest();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.ERROR));
        System.assertEquals(peer.Constants.HTTP_BAD_REQUEST, res.statusCode);//LSP-328
    }
    
    @isTest
    static void testAPSwithPaymentModeNull(){
        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();
        
        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000, peer__Last_Name__c = 'test');//LSP-328
        insert acc;        
        
        loan__Bank_Account__c bankAcc = new loan__Bank_Account__c(loan__Account__c = acc.id,
                                                                  loan__Active__c = true,
                                                                  loan__Bank_Account_Number__c = '12345',
                                                                  loan__Bank_Name__c = 'Test Bank',
                                                                  loan__Routing_Number__c = '999999999',  //CRM-845
                                                                  loan__Account_Type__c = 'Checking',  //pallavi
                                                                  Unmasked_Bank_Account_Number__c = '12345' );
        loan__Bank_Account__c collectionTrustBA = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
                                                                            loan__Bank_Name__c = 'Some Bank',
                                                                            Unmasked_Bank_Account_Number__c = '123234324',
                                                                            loan__Routing_Number__c = '999999999',  //CRM-845(for field custm validation)
                                                                            loan__Account_Type__c = 'Checking',
                                                                            loan__Account_Usage__c = 'Collections Trust Account',
                                                                            loan__Account__c = acc.id,
                                                                            loan__Active__c = True);
        insert bankAcc ;
        lAcct.loan__Loan_Status__c = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        lAcct.loan__Account__c = acc.id;
        lAcct.loan__Contact__c = null;
        lAcct.lead_Guid__c = 'qwertt';
        // lAcct.Investor_Account__c = acc.id;  //commented(LOS-28)
        update(lAcct);
        loan__Payment_Mode__c paymentMode = [select id,name from loan__Payment_Mode__c where name='ACH' limit 1];
        loan__Automated_Payment_Configuration__c apc = loan.TestHelper2.createAutomatedPaymentConfiguration('LOAN PAYMENT',
                                                                                                            paymentMode,
                                                                                                            collectionTrustBA,
                                                                                                            'loan.LoanPaymentTxnNACHAGen');
        
        apc.loan__Bank_Account__c = bankAcc.id;
        update apc;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI =  '/services/apexrest/OTPOMBPEndpoint';
        req.httpMethod = 'POST';
        
        String jsonStr = '{"leadGuid" :"'+lAcct.lead_Guid__c+'",  "bankAccountId" : "' + bankAcc.id + '", "transactionAmount" : ' + 1000
            + ', "debitDate" : "' + String.valueOf(Date.today()) +
            + '", "type" : "ONE TIME", "amountType":"FIXED AMOUNT","installmentOmbp": '+true+
            + ', "feeAmount" : ' + 100 +
            '}';
        req.requestBody = Blob.valueOf(jsonStr);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        Response results = WSSetupAPS.createAPSSetup();
        Test.stopTest();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.ERROR));
        System.assertEquals(peer.Constants.HTTP_BAD_REQUEST, res.statusCode);//LSP-328       
    }
    //LSP-223 - start
    @isTest
    static void testAPSForCOContracts(){
        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();
        
        loan__Org_Parameters__c org = loan.CustomSettingsUtil.getOrgParameters();
        org.loan__Disable_Triggers__c = true;
        org.loan__Enable_New_Spread_Option__c = true;
        upsert org;
        
        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000,peer__Last_Name__c = 'test');//LSP-328
        insert acc;
        lAcct.loan__Loan_Status__c = loan.LoanConstants.LOAN_STATUS_CLOSED_WRITTEN_OFF;
        lAcct.loan__Account__c = acc.id;
        lAcct.loan__Contact__c = null;
        lAcct.lead_Guid__c = 'qwertt';
        update(lAcct);
        
        Account invacc = new Account(
            Name = 'Investor',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Number_Of_Applications_Invested__c = 3, 
            Total_No_of_Application_Limit__c = 30,
            Last_Application_assigned_on__c = system.now()-7,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName2',
            no_of_shares_to_be_Sold__c = 1,
            Number_of_Days__c = 0,
            loan__Active__c = 'YES', 
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456'
        );
        Insert invacc;
        
        loan__Bank_Account__c bankAcc = new loan__Bank_Account__c(loan__Account__c = invacc.id,
                                                                  loan__Active__c = true,
                                                                  loan__Bank_Account_Number__c = '12345',
                                                                  loan__Bank_Name__c = 'Test Bank',
                                                                  loan__Routing_Number__c = '999999999',
                                                                  Unmasked_Bank_Account_Number__c = '12345',
                                                                  loan__Account_Type__c = 'Checking'  );
        loan__Bank_Account__c collectionTrustBA = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
                                                                            loan__Bank_Name__c = 'Some Bank',
                                                                            Unmasked_Bank_Account_Number__c = '123234324',
                                                                            loan__Routing_Number__c = '999999999',  //CRM-845
                                                                            loan__Account_Type__c = 'Checking',
                                                                            loan__Account_Usage__c = 'Collections Trust Account',
                                                                            loan__Account__c = acc.id,
                                                                            loan__Active__c = True);
        insert bankAcc ;
        
        loan__Payment_Mode__c paymentMode = [select id,name from loan__Payment_Mode__c where name='ACH' limit 1];
        loan__Automated_Payment_Configuration__c apc = loan.TestHelper2.createAutomatedPaymentConfiguration('LOAN PAYMENT',
                                                                                                            paymentMode,
                                                                                                            collectionTrustBA,
                                                                                                            'loan.LoanPaymentTxnNACHAGen');
        apc.loan__Bank_Account__c = bankAcc.id;
        update apc;        
        
        list<loan__Investor_Loan__c> ioList = new list<loan__Investor_Loan__c>();
        
        loan__Investor_Loan__c lo = new loan__Investor_Loan__c();
        lo.loan__Certificate_Rate__c                   = 1.0;
        lo.Buyer__c                                    = invacc.id;
        lo.loan__Service_Rate__c                       = 10.0;
        lo.loan__Account__c                            = invacc.id;
        lo.loan__Loan__c                               = lAcct.id;
        lo.loan__Share__c                              = 100;
        lo.loan__Status__c                             = 'Closed - Written Off';
        lo.loan__Enabled_Flag__c                       =  true;
        lo.loan__Inv_Accrued_Interest_Amt__c           =  0;
        lo.loan__Investment_Amount__c                  = 1000;
        lo.loan__Principal_Amount_Paid__c              = 2;
        lo.loan__Loan_Principal_Remaining__c           =1000;
        lo.loan__Investor_Start_Date__c                = System.today();         
        
        insert lo;
        
        lAcct.loan__Account__c = invacc.id;
        update lAcct;
        
        loan__Loan_Payment_Spread__c coSpread = new loan__Loan_Payment_Spread__c();
        coSpread.Name = 'Default Write Off Recovery Spread';
        coSpread.loan__Order_Of_Payment__c = 'Principal';
        insert coSpread;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI =  '/services/apexrest/OTPOMBPEndpoint';
        req.httpMethod = 'POST';
        String jsonStr = '{"leadGuid" :"'+lAcct.lead_Guid__c+'",  "bankAccountId" : "' + bankAcc.id + '", "transactionAmount" : ' + 1000
            + ', "debitDate" : "' + String.valueOf(Date.today()) +
            + '", "type" : "ONE TIME", "paymentModeName":"ACH", "amountType":"FIXED AMOUNT","installmentOmbp": '+true+
            + ', "feeAmount" : ' + 100 +
            '}';
        req.requestBody = Blob.valueOf(jsonStr);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        Response results = WSSetupAPS.createAPSSetup();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.SUCCESS));
        loan__Automated_Payment_Setup__c automatedPaymentSetup = [select id,name,loan__installment_payment__c,
                                                                  loan__Loan_Payment_Spread__r.name
                                                                  from loan__Automated_Payment_Setup__c 
                                                                  where loan__cl_contract__c=:lAcct.id];
        System.assertEquals(automatedPaymentSetup.loan__installment_payment__c,false);
        System.assertEquals('Default Write Off Recovery Spread', automatedPaymentSetup.loan__Loan_Payment_Spread__r.name);
        Test.stopTest();
    }
    //LSP-223 - end    
    //LSP-328 - start
    @isTest
    static void testPayoffPaymentSuccess(){
        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();
        
        loan__Org_Parameters__c org = loan.CustomSettingsUtil.getOrgParameters();
        org.loan__Disable_Triggers__c = true;
        org.loan__Enable_New_Spread_Option__c = true;
        upsert org;
        
        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000,peer__Last_Name__c = 'test');//LSP-328
        insert acc;
        lAcct.loan__Loan_Status__c = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        lAcct.loan__Account__c = acc.id;
        lAcct.loan__Contact__c = null;
        lAcct.lead_Guid__c = 'qwertt';
        lAcct.loan__Write_off_Tolerance_Amount__c = 10;
        lAcct.loan__Pay_Off_Amount_As_Of_Today__c = 400;
        update(lAcct);
        
        Account invacc = new Account(
            Name = 'Investor',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Number_Of_Applications_Invested__c = 3, 
            Total_No_of_Application_Limit__c = 30,
            Last_Application_assigned_on__c = system.now()-7,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName2',
            no_of_shares_to_be_Sold__c = 1,
            Number_of_Days__c = 0,
            loan__Active__c = 'YES', 
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456'
        );
        Insert invacc;
        
        loan__Bank_Account__c bankAcc = new loan__Bank_Account__c(loan__Account__c = invacc.id,
                                                                  loan__Active__c = true,
                                                                  loan__Bank_Account_Number__c = '12345',
                                                                  loan__Bank_Name__c = 'Test Bank',
                                                                  loan__Routing_Number__c = '999999999',
                                                                  Unmasked_Bank_Account_Number__c = '12345',
                                                                  loan__Account_Type__c = 'Checking'  );
        loan__Bank_Account__c collectionTrustBA = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
                                                                            loan__Bank_Name__c = 'Some Bank',
                                                                            Unmasked_Bank_Account_Number__c = '123234324',
                                                                            loan__Routing_Number__c = '999999999',
                                                                            loan__Account_Type__c = 'Checking',
                                                                            loan__Account_Usage__c = 'Collections Trust Account',
                                                                            loan__Account__c = acc.id,
                                                                            loan__Active__c = True);
        insert bankAcc ;
        
        loan__Payment_Mode__c paymentMode = [select id,name from loan__Payment_Mode__c where name='ACH' limit 1];
        loan__Automated_Payment_Configuration__c apc = loan.TestHelper2.createAutomatedPaymentConfiguration('LOAN PAYMENT',
                                                                                                            paymentMode,
                                                                                                            collectionTrustBA,
                                                                                                            'loan.LoanPaymentTxnNACHAGen');
        
        
        apc.loan__Bank_Account__c = bankAcc.id;
        update apc;        
        
        list<loan__Investor_Loan__c> ioList = new list<loan__Investor_Loan__c>();
        
        loan__Investor_Loan__c lo = new loan__Investor_Loan__c();
        lo.loan__Certificate_Rate__c                   = 1.0;
        lo.Buyer__c                                    = invacc.id;
        lo.loan__Service_Rate__c                       = 10.0;
        lo.loan__Account__c                            = invacc.id;
        lo.loan__Loan__c                               = lAcct.id;
        lo.loan__Share__c                              = 100;
        lo.loan__Status__c                             = 'Active';
        lo.loan__Enabled_Flag__c                       =  true;
        lo.loan__Inv_Accrued_Interest_Amt__c           =  0;
        lo.loan__Investment_Amount__c                  = 1000;
        lo.loan__Principal_Amount_Paid__c              = 2;
        lo.loan__Loan_Principal_Remaining__c           =1000;
        lo.loan__Investor_Start_Date__c                = System.today();        
        insert lo;
        
        lAcct.loan__Account__c = invacc.id;
        update lAcct;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI =  '/services/apexrest/OTPOMBPEndpoint';
        req.httpMethod = 'POST';
        String jsonStr = '{"leadGuid" :"'+lAcct.lead_Guid__c+'",  "bankAccountId" : "' + bankAcc.id + '", "transactionAmount" : ' + 390
            + ', "debitDate" : "' + String.valueOf(Date.today()) +
            + '", "type" : "ONE TIME", "paymentModeName":"ACH", "amountType":"FIXED AMOUNT","installmentOmbp": '+true+
            + ', "feeAmount" : ' + 100 + ',"payoffPayment":'+true+
            '}';
        req.requestBody = Blob.valueOf(jsonStr);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        Response results = WSSetupAPS.createAPSSetup();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.SUCCESS));
        loan__loan_Payment_transaction__c payofflpt = [select id,name,loan__installment_payment__c,loan__Early_Total_Repayment_of_the_Loan__c,loan__payment_Mode__c,loan__Automated_Payment_Setup__c,loan__Automated_Payment_Setup__r.loan__Active__c  
                                                       from loan__loan_Payment_transaction__c 
                                                       where loan__loan_Account__c=:lAcct.id];
        System.assertEquals(payofflpt.loan__installment_payment__c,false);
        System.assertEquals(payofflpt.loan__Early_Total_Repayment_of_the_Loan__c,true);
        System.assert(payofflpt.loan__Automated_Payment_Setup__c != null);//LSP-328.2 When payoff LPT gets created, APS is mapped to it for NACHA mapping
        System.assert(!payofflpt.loan__Automated_Payment_Setup__r.loan__Active__c);//LSP-328.2 APS status should be inactive
        Test.stopTest();
        List<loan__batch_process_log__c> successLog = [select id, name,loan__Log_Level__c from loan__batch_process_log__c where loan__Origin__c = 'WSSetupAPS'];
        System.assert(successLog.size()>0);
        System.assertEquals('INFO', successLog.get(0).loan__Log_Level__c);
    }
    @isTest
    static void testFutureDatedPaymentCreation(){
        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();
        
        loan__Org_Parameters__c org = loan.CustomSettingsUtil.getOrgParameters();
        org.loan__Disable_Triggers__c = true;
        org.loan__Enable_New_Spread_Option__c = true;
        upsert org;
        
        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000,peer__Last_Name__c = 'test');//LSP-328
        insert acc;
        lAcct.loan__Loan_Status__c = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        lAcct.loan__Account__c = acc.id;
        lAcct.loan__Contact__c = null;
        lAcct.lead_Guid__c = 'qwertt';
        lAcct.loan__Write_off_Tolerance_Amount__c = 10;
        lAcct.loan__Pay_Off_Amount_As_Of_Today__c = 400;
        update(lAcct);
        
        Account invacc = new Account(
            Name = 'Investor',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Number_Of_Applications_Invested__c = 3, 
            Total_No_of_Application_Limit__c = 30,
            Last_Application_assigned_on__c = system.now()-7,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName2',
            no_of_shares_to_be_Sold__c = 1,
            Number_of_Days__c = 0,
            loan__Active__c = 'YES', 
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456'
        );
        Insert invacc;
        
        loan__Bank_Account__c bankAcc = new loan__Bank_Account__c(loan__Account__c = invacc.id,
                                                                  loan__Active__c = true,
                                                                  loan__Bank_Account_Number__c = '12345',
                                                                  loan__Bank_Name__c = 'Test Bank',
                                                                  loan__Routing_Number__c = '999999999',
                                                                  Unmasked_Bank_Account_Number__c = '12345',
                                                                  loan__Account_Type__c = 'Checking'  );
        loan__Bank_Account__c collectionTrustBA = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
                                                                            loan__Bank_Name__c = 'Some Bank',
                                                                            Unmasked_Bank_Account_Number__c = '123234324',
                                                                            loan__Routing_Number__c = '999999999',
                                                                            loan__Account_Type__c = 'Checking',
                                                                            loan__Account_Usage__c = 'Collections Trust Account',
                                                                            loan__Account__c = acc.id,
                                                                            loan__Active__c = True);
        insert bankAcc ;
        
        loan__Payment_Mode__c paymentMode = [select id,name from loan__Payment_Mode__c where name='ACH' limit 1];
        loan__Automated_Payment_Configuration__c apc = loan.TestHelper2.createAutomatedPaymentConfiguration('LOAN PAYMENT',
                                                                                                            paymentMode,
                                                                                                            collectionTrustBA,
                                                                                                            'loan.LoanPaymentTxnNACHAGen');
        
        
        apc.loan__Bank_Account__c = bankAcc.id;
        update apc;        
        
        list<loan__Investor_Loan__c> ioList = new list<loan__Investor_Loan__c>();
        
        loan__Investor_Loan__c lo = new loan__Investor_Loan__c();
        lo.loan__Certificate_Rate__c                   = 1.0;
        lo.Buyer__c                                    = invacc.id;
        lo.loan__Service_Rate__c                       = 10.0;
        lo.loan__Account__c                            = invacc.id;
        lo.loan__Loan__c                               = lAcct.id;
        lo.loan__Share__c                              = 100;
        lo.loan__Status__c                             = 'Active';
        lo.loan__Enabled_Flag__c                       =  true;
        lo.loan__Inv_Accrued_Interest_Amt__c           =  0;
        lo.loan__Investment_Amount__c                  = 1000;
        lo.loan__Principal_Amount_Paid__c              = 2;
        lo.loan__Loan_Principal_Remaining__c           =1000;
        lo.loan__Investor_Start_Date__c                = System.today();        
        insert lo;
        
        lAcct.loan__Account__c = invacc.id;
        update lAcct;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI =  '/services/apexrest/OTPOMBPEndpoint';
        req.httpMethod = 'POST';
        String jsonStr = '{"leadGuid" :"'+lAcct.lead_Guid__c+'",  "bankAccountId" : "' + bankAcc.id + '", "transactionAmount" : ' + 390
            + ', "debitDate" : "' + String.valueOf(Date.today().addDays(2)) +
            + '", "type" : "ONE TIME", "paymentModeName":"ACH", "amountType":"FIXED AMOUNT","installmentOmbp": '+true+
            + ', "feeAmount" : ' + 100 + ',"payoffPayment":'+true+
            '}';
        req.requestBody = Blob.valueOf(jsonStr);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        Response results = WSSetupAPS.createAPSSetup();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.SUCCESS));
        loan__loan_Payment_transaction__c payofflpt = [select id,name,loan__installment_payment__c,loan__Early_Total_Repayment_of_the_Loan__c,loan__payment_Mode__c,loan__Automated_Payment_Setup__c,loan__Automated_Payment_Setup__r.loan__Active__c  
                                                       from loan__loan_Payment_transaction__c 
                                                       where loan__loan_Account__c=:lAcct.id];
        System.assertEquals(payofflpt.loan__installment_payment__c,false);
        System.assertEquals(payofflpt.loan__Early_Total_Repayment_of_the_Loan__c,true);
        System.assert(payofflpt.loan__Automated_Payment_Setup__c != null);//LSP-328.2 When payoff LPT gets created, APS is mapped to it for NACHA mapping
        System.assert(!payofflpt.loan__Automated_Payment_Setup__r.loan__Active__c);//LSP-328.2 APS status should be inactive
        Test.stopTest();
        List<loan__batch_process_log__c> successLog = [select id, name,loan__Log_Level__c from loan__batch_process_log__c where loan__Origin__c = 'WSSetupAPS'];
        System.assert(successLog.size()>0);
        System.assertEquals('INFO', successLog.get(0).loan__Log_Level__c);
    }
    //LSP-328.4 - start
    @isTest
    static void testPayoffPaymentWhenTransactionAmountisLess(){
        
        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();
        
        loan__Org_Parameters__c org = loan.CustomSettingsUtil.getOrgParameters();
        org.loan__Disable_Triggers__c = true;
        org.loan__Enable_New_Spread_Option__c = true;
        upsert org;
        
        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000,peer__Last_Name__c = 'test');//LSP-328
        insert acc;
        lAcct.loan__Loan_Status__c = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        lAcct.loan__Account__c = acc.id;
        lAcct.loan__Contact__c = null;
        lAcct.lead_Guid__c = 'qwertt';
        lAcct.loan__Write_off_Tolerance_Amount__c = 10;
        lAcct.loan__Pay_Off_Amount_As_Of_Today__c = 400;
        update(lAcct);
        
        Account invacc = new Account(
            Name = 'Investor',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Number_Of_Applications_Invested__c = 3, 
            Total_No_of_Application_Limit__c = 30,
            Last_Application_assigned_on__c = system.now()-7,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName2',
            no_of_shares_to_be_Sold__c = 1,
            Number_of_Days__c = 0,
            loan__Active__c = 'YES', 
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456'
        );
        Insert invacc;
        
        loan__Bank_Account__c bankAcc = new loan__Bank_Account__c(loan__Account__c = invacc.id,
                                                                  loan__Active__c = true,
                                                                  loan__Bank_Account_Number__c = '12345',
                                                                  loan__Bank_Name__c = 'Test Bank',
                                                                  loan__Routing_Number__c = '999999999',
                                                                  Unmasked_Bank_Account_Number__c = '12345',
                                                                  loan__Account_Type__c = 'Checking'  );
        loan__Bank_Account__c collectionTrustBA = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
                                                                            loan__Bank_Name__c = 'Some Bank',
                                                                            Unmasked_Bank_Account_Number__c = '123234324',
                                                                            loan__Routing_Number__c = '999999999',
                                                                            loan__Account_Type__c = 'Checking',
                                                                            loan__Account_Usage__c = 'Collections Trust Account',
                                                                            loan__Account__c = acc.id,
                                                                            loan__Active__c = True);
        insert bankAcc ;
        
        loan__Payment_Mode__c paymentMode = [select id,name from loan__Payment_Mode__c where name='ACH' limit 1];
        loan__Automated_Payment_Configuration__c apc = loan.TestHelper2.createAutomatedPaymentConfiguration('LOAN PAYMENT',
                                                                                                            paymentMode,
                                                                                                            collectionTrustBA,
                                                                                                            'loan.LoanPaymentTxnNACHAGen');
        
        
        apc.loan__Bank_Account__c = bankAcc.id;
        update apc;        
        
        list<loan__Investor_Loan__c> ioList = new list<loan__Investor_Loan__c>();
        
        loan__Investor_Loan__c lo = new loan__Investor_Loan__c();
        lo.loan__Certificate_Rate__c                   = 1.0;
        lo.Buyer__c                                    = invacc.id;
        lo.loan__Service_Rate__c                       = 10.0;
        lo.loan__Account__c                            = invacc.id;
        lo.loan__Loan__c                               = lAcct.id;
        lo.loan__Share__c                              = 100;
        lo.loan__Status__c                             = 'Active';
        lo.loan__Enabled_Flag__c                       =  true;
        lo.loan__Inv_Accrued_Interest_Amt__c           =  0;
        lo.loan__Investment_Amount__c                  = 1000;
        lo.loan__Principal_Amount_Paid__c              = 2;
        lo.loan__Loan_Principal_Remaining__c           =1000;
        lo.loan__Investor_Start_Date__c                = System.today();
        
        
        insert lo;
        
        lAcct.loan__Account__c = invacc.id;
        update lAcct;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI =  '/services/apexrest/OTPOMBPEndpoint';
        req.httpMethod = 'POST';
        String jsonStr = '{"leadGuid" :"'+lAcct.lead_Guid__c+'",  "bankAccountId" : "' + bankAcc.id + '", "transactionAmount" : ' + 300
            + ', "debitDate" : "' + String.valueOf(Date.today()) +
            + '", "type" : "ONE TIME", "paymentModeName":"ACH", "amountType":"FIXED AMOUNT","installmentOmbp": '+true+
            + ', "feeAmount" : ' + 100 + ',"payoffPayment":'+true+
            '}';
        req.requestBody = Blob.valueOf(jsonStr);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        Response results = WSSetupAPS.createAPSSetup();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.SUCCESS));
        loan__loan_Payment_transaction__c payofflpt = [select id,name,loan__installment_payment__c,loan__Early_Total_Repayment_of_the_Loan__c,loan__payment_Mode__c,loan__Automated_Payment_Setup__c,loan__Automated_Payment_Setup__r.loan__Active__c,Payoff_Rejection_Reason__c   
                                                       from loan__loan_Payment_transaction__c 
                                                       where loan__loan_Account__c=:lAcct.id];
        System.assertEquals(payofflpt.loan__Early_Total_Repayment_of_the_Loan__c,false);//LSP-328.4 Normal LPT should get created if transaction amount is less than todays payoff amount
        System.assert(payofflpt.loan__Automated_Payment_Setup__c != null);
        System.assertEquals(payofflpt.Payoff_Rejection_Reason__c, 'Transaction amount: 300 is not sufficient to payoff the loan');
        System.assert(!payofflpt.loan__Automated_Payment_Setup__r.loan__Active__c);
        Test.stopTest();
        List<loan__batch_process_log__c> successLog = [select id, name,loan__Log_Level__c from loan__batch_process_log__c where loan__Origin__c = 'WSSetupAPS'];
        System.assert(successLog.size()>0);
        System.assertEquals('INFO', successLog.get(0).loan__Log_Level__c);
    }//LSP-328.4 - end
    
    @isTest
    static void testPayoffPaymentWithIncorrectData(){
        
        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();
        
        loan__Org_Parameters__c org = loan.CustomSettingsUtil.getOrgParameters();
        org.loan__Disable_Triggers__c = true;
        org.loan__Enable_New_Spread_Option__c = true;
        upsert org;
        
        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000,peer__Last_Name__c = 'test');//LSP-328
        insert acc;
        lAcct.loan__Loan_Status__c = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        lAcct.loan__Account__c = acc.id;
        lAcct.loan__Contact__c = null;
        lAcct.lead_Guid__c = 'qwertt';
        lAcct.loan__Write_off_Tolerance_Amount__c = null;
        lAcct.loan__Pay_Off_Amount_As_Of_Today__c = 400;
        update(lAcct);
        
        Account invacc = new Account(
            Name = 'Investor',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Number_Of_Applications_Invested__c = 3, 
            Total_No_of_Application_Limit__c = 30,
            Last_Application_assigned_on__c = system.now()-7,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName2',
            no_of_shares_to_be_Sold__c = 1,
            Number_of_Days__c = 0,
            loan__Active__c = 'YES', 
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456'
        );
        Insert invacc;
        
        loan__Bank_Account__c bankAcc = new loan__Bank_Account__c(loan__Account__c = invacc.id,
                                                                  loan__Active__c = true,
                                                                  loan__Bank_Account_Number__c = '12345',
                                                                  loan__Bank_Name__c = 'Test Bank',
                                                                  loan__Routing_Number__c = '999999999',
                                                                  Unmasked_Bank_Account_Number__c = '12345',
                                                                  loan__Account_Type__c = 'Checking'  );
        loan__Bank_Account__c collectionTrustBA = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
                                                                            loan__Bank_Name__c = 'Some Bank',
                                                                            Unmasked_Bank_Account_Number__c = '123234324',
                                                                            loan__Routing_Number__c = '999999999',
                                                                            loan__Account_Type__c = 'Checking',
                                                                            loan__Account_Usage__c = 'Collections Trust Account',
                                                                            loan__Account__c = acc.id,
                                                                            loan__Active__c = True);
        insert bankAcc ;
        
        loan__Payment_Mode__c paymentMode = [select id,name from loan__Payment_Mode__c where name='ACH' limit 1];
        loan__Automated_Payment_Configuration__c apc = loan.TestHelper2.createAutomatedPaymentConfiguration('LOAN PAYMENT',
                                                                                                            paymentMode,
                                                                                                            collectionTrustBA,
                                                                                                            'loan.LoanPaymentTxnNACHAGen');
        
        
        apc.loan__Bank_Account__c = bankAcc.id;
        update apc;        
        
        list<loan__Investor_Loan__c> ioList = new list<loan__Investor_Loan__c>();
        
        loan__Investor_Loan__c lo = new loan__Investor_Loan__c();
        lo.loan__Certificate_Rate__c                   = 1.0;
        lo.Buyer__c                                    = invacc.id;
        lo.loan__Service_Rate__c                       = 10.0;
        lo.loan__Account__c                            = invacc.id;
        lo.loan__Loan__c                               = lAcct.id;
        lo.loan__Share__c                              = 100;
        lo.loan__Status__c                             = 'Active';
        lo.loan__Enabled_Flag__c                       =  true;
        lo.loan__Inv_Accrued_Interest_Amt__c           =  0;
        lo.loan__Investment_Amount__c                  = 1000;
        lo.loan__Principal_Amount_Paid__c              = 2;
        lo.loan__Loan_Principal_Remaining__c           =1000;
        lo.loan__Investor_Start_Date__c                = System.today();
        
        
        insert lo;
        
        lAcct.loan__Account__c = invacc.id;
        update lAcct;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI =  '/services/apexrest/OTPOMBPEndpoint';
        req.httpMethod = 'POST';
        String jsonStr = '{"leadGuid" :"'+lAcct.lead_Guid__c+'",  "bankAccountId" : "' + bankAcc.id + '", "transactionAmount" : ' + 400
            + ', "debitDate" : "' + String.valueOf(Date.today()) +
            + '", "type" : "ONE TIME", "paymentModeName":"ACH", "amountType":"FIXED AMOUNT","installmentOmbp": '+true+
            + ', "feeAmount" : ' + 100 + ',"payoffPayment":'+true+
            '}';
        req.requestBody = Blob.valueOf(jsonStr);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        Response results = WSSetupAPS.createAPSSetup();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.ERROR));
        Test.stopTest();
        List<loan__batch_process_log__c> successLog = [select id, name,loan__Log_Level__c from loan__batch_process_log__c where loan__Origin__c = 'WSSetupAPS'];
        System.assert(successLog.size()>0);
        System.assertEquals('INFO', successLog.get(0).loan__Log_Level__c);
    }//LSP - 328 end
}