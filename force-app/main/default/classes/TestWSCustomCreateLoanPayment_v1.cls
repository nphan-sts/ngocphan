@isTest
private class TestWSCustomCreateLoanPayment_v1 {

    @testSetup
    static void createSeedData() {
        
        Date d = Date.newInstance(2016, 02, 02);  // February 2nd, 2016.
        loan.TestHelper.systemDate = d;
        loan.TestHelper.createSeedDataForTesting();
        
        peer__Bank_Recon_Configuration__c bankConfig = peer__Bank_Recon_Configuration__c.getInstance();
        bankConfig.peer__Account_ID_Field__c = 'Name';
        bankConfig.peer__Auto_Create_Recon_Transaction__c = true;
        bankConfig.peer__Bank_Statement_Parser__c = 'TransactionLineParser';
        bankConfig.peer__Handle_Only_Exceptions__c = false;
        bankConfig.peer__Line_Separator__c = '\r\n';
        bankconfig.peer__Loan_ID_Field__c = 'Name';
        bankconfig.peer__Lock_Period_for_Bank_Recon__c = 0;
        insert bankConfig;
        loan__Org_Parameters__c orgParams = loan__Org_Parameters__c.getInstance();        
        orgParams.loan__Default_Tolerance_Rate__c = 0;
        orgParams.loan__Digits_After_Decimals__c = 2;
        orgParams.loan__Integrate_Salesforce_CRM__c = true;
        orgParams.peer__Disable_SMS_Verification__c = true;
        orgParams.loan__Log_Level__c = 'ERROR';
        orgParams.loan__Rounding_Mode__c = 'NEAREST';
        try {
            UserInfo.isCurrentUserLicensed('loan');
            orgParams.loan__Namespace_Prefix__c = 'loan';
        } catch (System.TypeException e) {
            orgParams.loan__Namespace_Prefix__c = '';
        }
        try {
            UserInfo.isCurrentUserLicensed('peer');
            orgParams.peer__Bazaar_Namespace__c = 'peer';
        } catch (System.TypeException e) {
            orgParams.peer__Bazaar_Namespace__c = '';
        }
        upsert orgParams;
                
        Test.startTest();
        //Set up office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice('OfficeNameXYZ', true);
        //Create day process records
        loan.TestHelper.createDayProcessForFullYear(d);
        //Create client
        loan__Client__c dummyClient = loan.TestHelper.createClient(dummyOffice);
        
        //Dummy account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
        
        //Create payment mode
        loan__Payment_Mode__c pmtMode = [SELECT Id FROM loan__Payment_Mode__c WHERE Name = 'Cash'];

        //Create Loan Product:
        loan__Loan_Product__c testProduct = new loan__Loan_Product__c(loan__Status__c = 'Active', 
                                                            Name = 'CreateLoanPaymentProduct',
                                                            loan__Interest_Calculation_Method__c = 'Declining Balance', 
                                                            loan__Frequency_Of_Loan_Payment__c  = 'Monthly', 
                                                            loan__Time_Counting_Method__c = 'Month and Days', 
                                                            loan__Max_Loan_Amount__c = 500000,
                                                            loan__Interest_Rate_Type__c = 'Fixed', 
                                                            loan__Min_Interest_Rate__c = 0, 
                                                            loan__Max_Interest_Rate__c = 100, 
                                                            loan__Default_Interest_Rate__c = 10
                                                            );
        insert testProduct;
        
        //Create contact for contract
        Contact borrower = new Contact(FirstName = 'Borrower', LastName = 'Person');
        insert borrower;
        
        // Create Loan contract
        loan__Loan_Account__c testLoanAccount = new loan__Loan_Account__c(loan__Loan_Product_Name__c = testProduct.Id,
                                                            loan__Contact__c = borrower.Id, 
                                                            loan__Loan_Amount__c = 16000, 
                                                            loan__Number_of_Installments__c = 8,
                                                            loan__Loan_Status__c = 'Approved',
                                                            loan__Client__c = dummyClient.Id);
        loan.BorrowerAPI1 bAPI = loan.APIFactory.getBorrowerAPI1();
        loan__Loan_Account__c newLoanAccount = bAPI.createContract(testLoanAccount, null, null);
        
        //Disburse the loan
        loan__Loan_Disbursal_Transaction__c distxn = new loan__Loan_Disbursal_Transaction__c();
        distxn.loan__Mode_of_Payment__c = pmtMode.Id;
        distxn.loan__Loan_Account__c = newLoanAccount.Id;
        loan.LoanDisbursalActionAPI a = new loan.LoanDisbursalActionAPI(distxn);
        a.disburseLoanAccount();
        
        Test.stopTest();
    }
    
    static testMethod void testSimplePayment() {

        loan__Loan_Product__c lp = [SELECT Id FROM loan__Loan_Product__c WHERE Name = 'CreateLoanPaymentProduct'];
        loan__Loan_Account__c lac = [SELECT Id
                                     FROM loan__Loan_Account__c 
                                     WHERE loan__Loan_Product_Name__c = :lp.Id];

        lac.loan__Interest_Remaining__c = 200;
        update lac;
        
        //Make a payment : 
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/v1/CustomcreateLoanPaymentTransaction';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;
        String jsonStr = '{"loanAccount" : "' + lac.id 
                           + '", "transactionDate" : "' + '2016-02-02'
                           + '", "transactionAmount" : ' + 300  
                           + '}';
        req.requestBody = Blob.valueOf(jsonStr);
        Test.startTest();
        Response results = WSCustomCreateLoanPayment_v1.createLoanPayment();
        Test.stopTest();
        
        lac = [SELECT Id,
                    loan__Interest_Remaining__c,
                    loan__Principal_Remaining__c,
                    loan__Interest_Paid__c,
                    loan__Principal_Paid__c
             FROM loan__Loan_Account__c 
             WHERE ID = :lac.Id];

        System.assertEquals(0, lac.loan__Interest_Remaining__c);
        System.assertEquals(15900, lac.loan__Principal_Remaining__c);
        System.assertEquals(200, lac.loan__Interest_Paid__c);
        System.assertEquals(100, lac.loan__Principal_Paid__c);
        
        loan__Loan_Payment_Transaction__c lpt = [SELECT Id, 
                                                        loan__Transaction_Amount__c,
                                                        loan__Principal__c,
                                                        loan__Interest__c
                                                 FROM loan__Loan_Payment_Transaction__c
                                                 WHERE loan__Loan_Account__c = :lac.Id];
        System.assertEquals(100, lpt.loan__Principal__c);
        System.assertEquals(200, lpt.loan__Interest__c);                                                  
    }
    
    static testMethod void testManualPayment() {
        
        loan__Loan_Product__c lp = [SELECT Id FROM loan__Loan_Product__c WHERE Name = 'CreateLoanPaymentProduct'];
        loan__Loan_Account__c lac = [SELECT Id
                                     FROM loan__Loan_Account__c 
                                     WHERE loan__Loan_Product_Name__c = :lp.Id];
        
        lac.loan__Interest_Remaining__c = 200;
        update lac;
        
        //Make a manually spread payment : 
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/v1/CustomcreateLoanPaymentTransaction';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;
        String jsonStr = '{"loanAccount" : "' + lac.id 
                           + '", "transactionDate" : "' + '2016-02-02'
                           + '", "principal" : ' + 150 
                           + ', "interest" : ' + 75
                           + ', "manualPayment" : ' + 'true'
                           + ', "installmentPayment" : ' + 'true'
                           + '}';
        req.requestBody = Blob.valueOf(jsonStr);
        System.debug('Le json :: ' + jsonStr);
        Test.startTest();
        Response results = WSCustomCreateLoanPayment_v1.createLoanPayment();
        Test.stopTest();
        
        lac = [SELECT Id,
                    loan__Interest_Remaining__c,
                    loan__Principal_Remaining__c,
                    loan__Interest_Paid__c,
                    loan__Principal_Paid__c
             FROM loan__Loan_Account__c 
             WHERE ID = :lac.Id];

        System.assertEquals(125, lac.loan__Interest_Remaining__c);
        System.assertEquals(15850, lac.loan__Principal_Remaining__c);
        System.assertEquals(75, lac.loan__Interest_Paid__c);
        System.assertEquals(150, lac.loan__Principal_Paid__c);
        
        loan__Loan_Payment_Transaction__c lpt = [SELECT Id, 
                                                        loan__Transaction_Amount__c,
                                                        loan__Principal__c,
                                                        loan__Interest__c
                                                 FROM loan__Loan_Payment_Transaction__c
                                                 WHERE loan__Loan_Account__c = :lac.Id];
        System.assertEquals(150, lpt.loan__Principal__c);
        System.assertEquals(75, lpt.loan__Interest__c);                                                  
    }
    
    static testMethod void testManualPayment1() {
        
        loan__Loan_Product__c lp = [SELECT Id FROM loan__Loan_Product__c WHERE Name = 'CreateLoanPaymentProduct'];
        loan__Loan_Account__c lac = [SELECT Id
                                     FROM loan__Loan_Account__c 
                                     WHERE loan__Loan_Product_Name__c = :lp.Id];
        
        lac.loan__Interest_Remaining__c = 200;
        update lac;
        
        //Make a manually spread payment : 
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/v1/CustomcreateLoanPaymentTransaction';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;
        /*String jsonStr = '{"loanAccount" : "' + lac.id 
                           + '", "manualPayment" : ' + 'true'
                           + ', "installmentPayment" : ' + 'true'
                           + '}';
        req.requestBody = Blob.valueOf(jsonStr);
        System.debug('Le json :: ' + jsonStr);*/
        Test.startTest();
        Response results = WSCustomCreateLoanPayment_v1.createLoanPayment();
        Test.stopTest();
        
        /*lac = [SELECT Id,
                    loan__Interest_Remaining__c,
                    loan__Principal_Remaining__c,
                    loan__Interest_Paid__c,
                    loan__Principal_Paid__c
             FROM loan__Loan_Account__c 
             WHERE ID = :lac.Id];

        System.assertEquals(125, lac.loan__Interest_Remaining__c);
        System.assertEquals(15850, lac.loan__Principal_Remaining__c);
        System.assertEquals(75, lac.loan__Interest_Paid__c);
        System.assertEquals(150, lac.loan__Principal_Paid__c);
        
        loan__Loan_Payment_Transaction__c lpt = [SELECT Id, 
                                                        loan__Transaction_Amount__c,
                                                        loan__Principal__c,
                                                        loan__Interest__c
                                                 FROM loan__Loan_Payment_Transaction__c
                                                 WHERE loan__Loan_Account__c = :lac.Id];
        System.assertEquals(150, lpt.loan__Principal__c);
        System.assertEquals(75, lpt.loan__Interest__c); */                                                 
    }
    
}