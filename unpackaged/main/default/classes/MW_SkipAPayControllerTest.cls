@isTest
private class MW_SkipAPayControllerTest {
    @testSetup
    static void dataSetup() {
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
        
        loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
        org.loan__Disable_Triggers__c = true;
        upsert org; 
        
        genesis__org_parameters__c genesisOrg = genesis__Org_Parameters__c.getOrgDefaults();
        genesisOrg.genesis__Disable_Triggers__c = true;
        upsert genesisOrg;
   
        //Creating Account
         Account acc = new Account(
            Name = 'Test',
            peer__Last_Name__c = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123456789'//LSP-3 updated to 9 digits as the testcase was failing
            );
        insert acc;
        
        
        LoanPaymentDays__c lpdays = new LoanPaymentDays__c();
        lpdays.AutoPaymentRemainder__c= 3;
        lpdays.ManualPaymentRemainder__c= 5;
        insert lpdays;
        
        loan__Loan_Product__c loanProdObj = new loan__Loan_Product__c(name='TestProduct'); 
        insert loanProdObj;
        
            
         //Creating Conpany
        genesis__Company__c comp = genesis.TestHelper.createCompany(); 
        comp.Name = 'payoff';
        update comp;
       
         //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        
        //creating CL Product
        clcommon__CL_Product__c pr = new clcommon__CL_Product__c();
        pr.loan__Lending_Product__c = dummyLp.id;
        pr.clcommon__Product_Name__c = 'P1';
        insert pr;
      
          Account account_Obj = new Account(
            Name = 'Test',
            peer__Last_Name__c = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com'
        );
        Insert account_Obj;
       
        genesis__applications__c application = new genesis__applications__c();
        application.genesis__Product_Type__c = 'LOAN';
        application.genesis__Loan_Amount__c = 6700;
        application.genesis__status__c = 'NEW - ENTERED';
        application.genesis__Term__c = 12;
        application.genesis__Payment_Frequency__c = 'MONTHLY';
        application.genesis__Interest_Rate__c = 10;
        application.genesis__Days_Convention__c = 'ACTUAL/ACTUAL';
        application.genesis__Expected_Start_Date__c = system.today();
        application.genesis__Expected_First_Payment_Date__c = system.today().addDays(60);
        application.genesis__Expected_Close_Date__c = system.today().addDays(30);
        application.genesis__Interest_Calculation_Method__c = 'Declining Balance';
        application.genesis__Interest_Only_Period__c = 0;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Account__c = account_Obj.Id;
        application.genesis__Total_Estimated_Interest__c=500;
        application.genesis__Valid_Pricing_Flag__c=false;
        application.genesis__Probability__c=100.00;
        application.genesis__Payment_Amount__c=523.80;
        application.genesis__Company__c = comp.id;
        application.genesis__CL_Product__c = pr.id;
        insert application;
        
        loan__Loan_Account__c lacc = new loan__Loan_Account__c(
                                            loan__Account__c= acc.Id,
                                            loan__Product_Type__c='Flexible Amz Loan',
                                            loan__Loan_Amount__c =1000,
                                            loan__Loan_Product_Name__c=loanProdObj.Id,
                                            loan__Payment_Amount__c=100,
                            loan__Principal_Remaining__c = 500,
                                            loan__Previous_Installment_Date__c= system.today(),
                            application__c = application.id, 
                            loan__First_Installment_Date__c = Date.newInstance(2019, 03, 01),
                            loan__Next_Installment_Date__c = Date.newInstance(2019, 09, 01), 
                            loan__Maturity_Date_Current__c = Date.newInstance(2021, 03, 01), 
                            loan__Frequency_of_Loan_Payment__c = '6',  
                            U_LoanModForbearDt__c = 0,
                            loan__Last_Installment_Date__c = Date.newInstance(2019, 03, 01),
            loan__Loan_Status__c = 'Active - Good Standing',
            loan__Interest_Rate__c = 10,
            loan__Term_Cur__c = 12,
            Skipped_a_pay_Date__c = null,
            Skipped_a_Pay__c = false
                            );
        insert lacc;
    }

    static testMethod void testPost() {
        loan__Loan_Account__c loan = [ SELECT Id, Name, Skipped_a_Pay__c FROM loan__Loan_Account__c LIMIT 1 ];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/skipapay/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{ "loanId": "' + loan.id + '", "numberOfSkips": 1}');
        RestContext.request = req;
        RestContext.response= res;
        MW_SkipAPayController.SkipAPayController();
        System.debug(res.responseBody.toString());
        system.assertEquals(true, loan.Skipped_a_Pay__c, 'Skip a pay');
    }
}
