/* ****************Modification History*****************************************************************
 * Modified by      Date            JIRA number
  *    Pallavi      2020/12/15      CRM-845
  *    Anusha		2020/06/04      LSP-223
 ******************Modification History*****************************************************************/
@isTest(SeeAllData = false)
public class TestWSSetupAPS {
    
    /*@testSetup
    static void createMWSetting() {
        MW_Settings__c m = new MW_Settings__c();
        m.API_User_Filter__c = 'efe,cef';
        insert m;
    }*/
    
    
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


        Account acc = new Account(Name = 'SF');
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
    static void testACH(){

        loan.TestHelper.systemDate = Date.newInstance(2016, 1, 15);
        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();

        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000);
        insert acc;

        lAcct.loan__Loan_Status__c = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        lAcct.loan__Account__c = acc.id;
        lAcct.loan__Contact__c = null;
        lAcct.lead_Guid__c = 'qwertt';
        update lAcct;

        loan.TestHelper.createDayProcessForFullYear(loan.Testhelper.systemDate);

        loan.GlobalProcessFacade.moveSystemToDate(loan.TestHelper.systemDate.addDays(10), false);

        loan__Payment_Mode__c pMode = [SELECT ID FROM loan__Payment_Mode__c LIMIT 1];

        //back-dated payment = LAD = systemDate+8 after this
        loan__Loan_Payment_Transaction__c loanPayTxn = new loan__Loan_Payment_Transaction__c(loan__Transaction_Date__c = loan.TestHelper.systemDate.addDays(8),
                                                                                 loan__Payment_Mode__c = pMode.id,
                                                                                 loan__Transaction_Amount__c = 200,
                                                                                 loan__Loan_Account__c = lAcct.id);
        insert loanPayTxn;


        loan__Bank_Account__c bankAcc = new loan__Bank_Account__c(loan__Account__c = acc.id,
                                                                  loan__Active__c = true,
                                                                  loan__Bank_Account_Number__c = '12345',
                                                                  loan__Bank_Name__c = 'Test Bank',
                                                                  loan__Routing_Number__c = '999999999',  //CRM-845
                                                                  loan__Account_Type__c = 'Checking',  //pallavi
                                                                  Unmasked_Bank_Account_Number__c = '12345');
        insert bankAcc;


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI =  '/services/apexrest/OTPOMBPEndpoint';
        req.httpMethod = 'POST';

        String jsonStr = '{"leadGuid" :"'+lAcct.lead_Guid__c+'",  "bankAccountId" : "' + bankAcc.id + '"' +
            + ', "debitDate" : "' + String.valueOf(loan.TestHelper.systemDate.addDays(5)) +
            + '", "type" : "ONE TIME" '
            + ', "feeAmount" : ' + 100 +
            '}';
        req.requestBody = Blob.valueOf(jsonStr);

        RestContext.request = req;
        RestContext.response = res;

        Response results = WSSetupAPS.createAPSSetup();
        System.debug('-----11111:-----' + results.errorMessage);
        //System.assert(results.status.equalsIgnoreCase(Constants.ERROR));



        RestRequest req1 = new RestRequest();
        RestResponse res1 = new RestResponse();

        req1.requestURI =  '/services/apexrest/OTPOMBPEndpoint';
        req1.httpMethod = 'POST';

        jsonStr = '{"leadGuid":"'+lAcct.lead_Guid__c+'", "bankAccountId" : "' + bankAcc.id + '"' +
            + ', "debitDate" : "' + String.valueOf(loan.TestHelper.systemDate.addDays(10)) +
            + '", "type" : "ONE TIME" '
            + ', "feeAmount" : ' + 100 +
            '}';

        req1.requestBody = Blob.valueOf(jsonStr);

        RestContext.request = req1;
        RestContext.response = res1;

        Response results1 = WSSetupAPS.createAPSSetup();
        //System.assert(results.status.equalsIgnoreCase(Constants.ERROR));
    }

    // Success case
    @isTest
    static void test_OneTimeACH(){

        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();

        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000);
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
        Response results = WSSetupAPS.createAPSSetup();
        System.debug('res:'+results);
        //Test.stopTest();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.SUCCESS));
        loan__Automated_Payment_Setup__c automatedPaymentSetup = [select id,name,loan__installment_payment__c
                                                                 from loan__Automated_Payment_Setup__c 
                                                                  where loan__cl_contract__c=:lAcct.id];
        System.assertEquals(automatedPaymentSetup.loan__installment_payment__c,false);  //CRM-845
        /*CRM-845*/
        loan__Loan_account_Due_Details__c bill = new loan__Loan_account_Due_Details__c(loan__DD_Primary_Flag__c = true,
                                                                                      loan__Payment_Satisfied__c = false,
                                                                                      loan__Due_Date__c = System.today().adddays(2),
                                                                                      loan__Loan_Account__c = lAcct.id);
        insert bill;
        RestContext.request = req;
        RestContext.response = res;

        results = WSSetupAPS.createAPSSetup();
        Test.stopTest();
        /*CRM-845*/
    }
    
    @isTest
    static void test_ACHFalse(){

        loan__ACH_Parameters__c achParameters = createACHParameters(false, false);
        loan__Loan_Account__c lAcct = createLoanAccount();

        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000);
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
        System.debug('res:'+results);
        Test.stopTest();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.ERROR));
        
    }
    
    @isTest
    static void test_ACHLeadIDNull(){

        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();

        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000);
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
        System.debug('res:'+results);
        Test.stopTest();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.ERROR));
        
    }
    
    @isTest
    static void test_ACHLeadIDInvalid(){

        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();

        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000);
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
        System.debug('res:'+results);
        Test.stopTest();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.ERROR));
        
    }
    
    @isTest
    static void test_ACHDebitDateNotPresent(){

        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();

        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000);
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
        System.debug('res:'+results);
        Test.stopTest();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.ERROR));
        
    }
    
    @isTest
    static void test_ACHAmountTypeNull(){

        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();

        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000);
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
        System.debug('res:'+results);
        Test.stopTest();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.ERROR));
        
    }
    
    @isTest
    static void test_ACHrequestNull(){

        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();

        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000);
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
        System.debug('res:'+results);
        Test.stopTest();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.ERROR));
        
    }
    
    @isTest
    static void test_ACHPaymentModeNull(){

        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();

        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000);
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
        System.debug('res:'+results);
        Test.stopTest();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.ERROR));
        
        
    }
    
    //LSP-223 - start
    @isTest
    static void testCOContracts(){

        loan__ACH_Parameters__c achParameters = createACHParameters(true, true);
        loan__Loan_Account__c lAcct = createLoanAccount();
        
        loan__Org_Parameters__c org = loan.CustomSettingsUtil.getOrgParameters();
        System.debug('org params: '+org.loan__Enable_New_Spread_Option__c);
        org.loan__Disable_Triggers__c = true;
        org.loan__Enable_New_Spread_Option__c = true;
        upsert org;
        System.debug('org params..: '+org.loan__Enable_New_Spread_Option__c);
        System.debug('enable new spread: '+loan.CustomSettingsUtil.getOrgParameters());
		
        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000);
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
		List<loan__loan_account__C> lll =[select id, name, loan__Loan_Status__c from loan__loan_account__C where  lead_Guid__c =:lAcct.lead_Guid__c];
        system.debug('loan status: '+lll.get(0).loan__Loan_Status__c);
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
        System.debug('res:'+results);
        //Test.stopTest();
        System.assert(results.status.equalsIgnoreCase(peer.Constants.SUCCESS));
        loan__Automated_Payment_Setup__c automatedPaymentSetup = [select id,name,loan__installment_payment__c
                                                                 from loan__Automated_Payment_Setup__c 
                                                                  where loan__cl_contract__c=:lAcct.id];
        System.assertEquals(automatedPaymentSetup.loan__installment_payment__c,false);
        
        loan__Loan_account_Due_Details__c bill = new loan__Loan_account_Due_Details__c(loan__DD_Primary_Flag__c = true,
                                                                                      loan__Payment_Satisfied__c = false,
                                                                                      loan__Due_Date__c = System.today().adddays(2),
                                                                                      loan__Loan_Account__c = lAcct.id);
        insert bill;
        RestContext.request = req;
        RestContext.response = res;

        results = WSSetupAPS.createAPSSetup();
        Test.stopTest();
    }
    //LSP-223 - end
}