@isTest
private class APSWarningMSGExtensionTest {

    @testSetup 
    static void setup(){
        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();

        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');

        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);                                    
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);

        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();

        loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
        org.loan__Disable_Triggers__c = true;
        upsert org;  

        genesis__Org_Parameters__c genorg = genesis__Org_Parameters__c.getOrgDefaults();
        genorg.genesis__Disable_Triggers__c = true;
        upsert genorg;

        LoanPaymentDays__c lpdays = MW_GlobalTestUtility.GetLoanPaymentDays();
        insert lpdays;

        loan__Loan_Product__c loanProdObj = MW_GlobalTestUtility.GetLoanProduct(); 
        insert loanProdObj;

        genesis__Company__c comp = genesis.TestHelper.createCompany(); 
        comp.Name = 'payoff';
        update comp;        

        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);

        clcommon__CL_Product__c pr = new clcommon__CL_Product__c();
        pr.loan__Lending_Product__c = dummyLp.id;
        pr.clcommon__Product_Name__c = 'P1';
        insert pr;

        Account account_Obj = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com'
        );
        Insert account_Obj;

        Account acc = MW_GlobalTestUtility.GetAccount('Member');
        insert acc;

        Contact a1 = MW_GlobalTestUtility.GetContact();
        insert a1;

        loan__Bank_Account__c ba = MW_GlobalTestUtility.GetBankAccount();
        ba.Unmasked_Bank_Account_Number__c = acc.Id;
        ba.loan__Contact__c = a1.id;
        ba.loan__Account__c = acc.id;

        insert ba;

        loan__Payment_Mode__c pMode  =  MW_GlobalTestUtility.GetPMode();
        insert pMode;


        loan__Payment_Mode__c pMode1  =  MW_GlobalTestUtility.GetPMode1();
        insert pMode1;

        genesis__applications__c objApp = MW_GlobalTestUtility.GetApplication();
        objApp.genesis__Account__c = account_Obj.Id;
        objApp.genesis__Company__c = comp.id;
        objApp.genesis__CL_Product__c = pr.id;
        insert objApp;


        loan__Loan_Account__c lacc = MW_GlobalTestUtility.GetCLContract();
        lacc.loan__Account__c= acc.Id;
        lacc.loan__Contact__c= a1.ID;
        lacc.loan__Loan_Product_Name__c=loanProdObj.Id;
        lacc.application__c = objApp.id;
        insert lacc;
        loan__Automated_Payment_Setup__c lautopay = new loan__Automated_Payment_Setup__c();
        lautopay.loan__Active__c = true;
        lautopay.loan__Amount_Type__c = 'CURRENT PAYMENT AMOUNT';
        lautopay.loan__Debit_Date__c = Date.newInstance(2021, 09, 05);
        lautopay.loan__Bank_Account__c = ba.Id;
        lautopay.loan__CL_Contract__c = lacc.Id;
        lautopay.External_Id__c = 'testlauto01234';
        lautopay.loan__Transaction_Amount__c = 12345;
        lautopay.loan__Type__c = 'ONE TIME';
        lautopay.Email__c = 'abc@gmail.com';
        insert lautopay;
	MW_Settings__c payOffSettings = new MW_Settings__c();
        payOffSettings.APS_Cutofftime__c = '16:00:00';
        insert payOffSettings;
    }

    @isTest
    static void testErrorMessage() {
        loan__Automated_Payment_Setup__c lauto = [SELECT External_Id__c, CreatedDate, loan__Active__c,Email__c,
                                                  loan__CL_Contract__c, loan__Transaction_Amount__c,
                                                  loan__Type__c, loan__Bank_Account__c, loan__Debit_Date__c
                                                  FROM loan__Automated_Payment_Setup__c WHERE External_Id__c='testlauto01234'];
        ApexPages.StandardController autoPage = new ApexPages.StandardController(lauto);
        APSWarningMSGExtension toastExt = new APSWarningMSGExtension(autoPage);
        PageReference pageRef = Page.APSWarningMSG;
        pageRef.getParameters().put('id', String.valueOf(lauto.Id));

        Test.setCurrentPage(pageRef);
        String message = toastExt.getErrorMessage();
        System.assertEquals(message, toastExt.WARNING_MESSAGE,'Warning message displayed');
    }

    @isTest
    static void testHolidayErrorMessage() {
        loan__Automated_Payment_Setup__c lauto = [SELECT External_Id__c, CreatedDate, loan__Active__c,Email__c,
                                                  loan__CL_Contract__c, loan__Transaction_Amount__c,
                                                  loan__Type__c, loan__Bank_Account__c, loan__Debit_Date__c
                                                  FROM loan__Automated_Payment_Setup__c WHERE External_Id__c='testlauto01234'];
        User u = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
        System.runAs(u) {
          	Holiday hDay = new Holiday();
            hDay.ActivityDate = Date.newInstance(2021, 09, 06);
            hDay.Name = 'Green Day';
            hDay.Description = 'Green environment day';
            insert hDay;  
        }

        Test.startTest();
        	lauto.loan__Debit_Date__c = Date.newInstance(2021,09,06);
            update lauto;
        Test.stopTest();
        ApexPages.StandardController autoPage = new ApexPages.StandardController(lauto);
        APSWarningMSGExtension toastExt = new APSWarningMSGExtension(autoPage);
        PageReference pageRef = Page.APSWarningMSG;
        pageRef.getParameters().put('id', String.valueOf(lauto.Id));

        Test.setCurrentPage(pageRef);
        String message = toastExt.getErrorMessage();
        System.assertEquals(message, toastExt.WARNING_MESSAGE,'Warning message displayed');
    }

    @isTest
    static void testNoErrorMessage() {
        loan__Automated_Payment_Setup__c lauto = [SELECT External_Id__c, CreatedDate, loan__Active__c,Email__c,
                                                  loan__CL_Contract__c, loan__Transaction_Amount__c,
                                                  loan__Type__c, loan__Bank_Account__c, loan__Debit_Date__c
                                                  FROM loan__Automated_Payment_Setup__c WHERE External_Id__c='testlauto01234'];
        User u = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()]; //Profile.Name = 'System Administrator'
        System.runAs(u) {
          	Holiday hDay = new Holiday();
            hDay.ActivityDate = Date.newInstance(2001, 09, 21);
            hDay.Name = 'Green Day';
            hDay.Description = 'Green environment day';
            insert hDay;  
        }
		//Test.setCreatedDate(lauto.id, lauto.loan__Debit_Date__c);
        Test.startTest();
        	lauto.loan__Debit_Date__c = Date.newInstance(2021,09,15);
            update lauto;
            
        
        ApexPages.StandardController autoPage = new ApexPages.StandardController(lauto);
        APSWarningMSGExtension toastExt = new APSWarningMSGExtension(autoPage);
        PageReference pageRef = Page.APSWarningMSG;
        pageRef.getParameters().put('id', String.valueOf(lauto.Id));

        Test.setCurrentPage(pageRef);
        String message = toastExt.getErrorMessage();

        Test.stopTest();
        System.assertEquals('', message, 'No Warning message displayed');
        
    }

}
