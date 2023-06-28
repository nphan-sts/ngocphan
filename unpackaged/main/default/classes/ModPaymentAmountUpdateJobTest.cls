@isTest
public with sharing class ModPaymentAmountUpdateJobTest {

    private static Date SYSTEM_DATE = Date.newInstance(2020, 03, 01);

    private static genesis__applications__c createApp(
        Decimal loanAmount, Account account_Obj, genesis__Company__c comp, clcommon__CL_Product__c pr, Integer term
        ) {
        genesis__applications__c application = MW_GlobalTestUtility.GetApplication();	
        application.genesis__Loan_Amount__c = loanAmount;	
        application.genesis__status__c = 'NEW - ENTERED';	
        application.genesis__Term__c = term;	
        application.genesis__Payment_Frequency__c = 'MONTHLY';	
        application.genesis__Expected_Start_Date__c = SYSTEM_DATE;
        application.Application_Start_DateV2__c = SYSTEM_DATE;	
        application.genesis__Expected_First_Payment_Date__c = SYSTEM_DATE.addDays(60);	
        application.genesis__Expected_Close_Date__c = SYSTEM_DATE.addDays(30);
        application.genesis__Interest_Only_Period__c = 0;	
        application.genesis__Total_Estimated_Interest__c=500;	
        application.genesis__Valid_Pricing_Flag__c=false;	
        application.genesis__Account__c = account_Obj.Id;
        application.genesis__Company__c = comp.id;	
        application.genesis__CL_Product__c = pr.id;		
        insert application;	

        return application;
    }

    private static loan__loan_Account__c createCLContract(
        Date firstInstallmentDate, Integer term, genesis__applications__c application, Decimal paymentAmount, Decimal paymentInstallment ) {

        Contact a1 = new Contact(LastName='TestACH');	
        insert a1;

        loan__Loan_Product__c loanProdObj = new loan__Loan_Product__c(name='TestProduct'); 	
        insert loanProdObj;	
        System.assertEquals('TestProduct', loanProdObj.Name,'Wrong Loan Product');

        loan__Loan_Account__c lacc = MW_GlobalTestUtility.GetCLContract();
        lacc.loan__First_Installment_Date__c = firstInstallmentDate;
        lacc.loan__Next_Installment_Date__c = firstInstallmentDate.addMonths(2);
        lacc.loan__Maturity_Date_Current__c = firstInstallmentDate.addMonths(term);
        lacc.loan__Last_Installment_Date__c = firstInstallmentDate.addMonths(12);
        lacc.loan__Disbursal_Date__c = firstInstallmentDate.addMonths(-1);
        lacc.application__c = application.id;
        lacc.loan__Payment_Amount__c = paymentAmount;
        lacc.loan__Pmt_Amt_Cur__c = paymentInstallment;
        lacc.loan__Account__c = application.genesis__Account__c;
        lacc.loan__Contact__c = a1.ID;
        lacc.loan__Loan_Product_Name__c= loanProdObj.Id;
        insert lacc;

        return lacc;

    }

    private static void createRepayment(
        loan__Loan_Account__c lacc, Integer seq,  Decimal paymentAmount, Integer noOfPayments, Date currentDate 
    ) {
        loan__Repayment_Schedule_Summary__c rsSummary = new loan__Repayment_Schedule_Summary__c();	
        rsSummary.loan__RSS_No_Of_Pmts__c = noOfPayments;	
        rsSummary.loan__Archived__c = false;	
        rsSummary.loan__RSS_Loan_Account__c = lacc.Id;
        rsSummary.loan__RSS_Primary_flag__c= true;
        rsSummary.loan__RSS_Seq__c = seq;
        rsSummary.loan__RSS_Repayment_Amt__c = paymentAmount;
        rsSummary.loan__RSS_Repayment_Dt__c = currentDate;

        insert rsSummary;

    }

    private static void createRepaymentPlan(
        loan__Loan_Account__c lacc, Integer sequence, Integer noOfPayments, Decimal paymentAmount, Date startDate
    ) {
        clcommon__Repayment_Plan__c repaymentPlan = new clcommon__Repayment_Plan__c();
        repaymentPlan.clcommon__Sequence_Number__c = sequence;
        repaymentPlan.clcommon__Payment_Type__c = 'Equal Monthly Installments';
        repaymentPlan.clcommon__Payment_Amount__c = paymentAmount; //lacc.loan__Pmt_Amt_Cur__c;
        repaymentPlan.clcommon__Number_Of_Payments__c = noOfPayments;
        repaymentPlan.loan__Loan_Account__c = lacc.id;
        repaymentPlan.clcommon__Payment_Start_Date__c = startDate;
        insert repaymentPlan;
    }

    @testSetup
    private static void testSetup() {
        loan.TestHelper.createSeedDataForTesting();	
        loan__Currency__c curr = loan.TestHelper.createCurrency();	
        //Create a dummy MF_Account	
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');	
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');	
        
        //Create a Fee Set	
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);                                    	
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();	
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);	

        System.debug('Fees Junction' +dummyFeeJunction);
        
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();	
        
        loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();	
        org.loan__Disable_Triggers__c = true;	
        upsert org;  	
        
        genesis__Org_Parameters__c genorg = genesis__Org_Parameters__c.getOrgDefaults();	
        genorg.genesis__Disable_Triggers__c = true;	
        upsert genorg;	
    
        LoanPaymentDays__c lpdays = new LoanPaymentDays__c();	
        lpdays.AutoPaymentRemainder__c= 3;	
        lpdays.ManualPaymentRemainder__c= 5;	
        insert lpdays;	

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
    

    }

    static testMethod void testFourRepayments() {

        Account account_Obj = [Select id from Account LIMIT 1];
        genesis__Company__c comp = [Select id from genesis__Company__c LIMIT 1]; 
        clcommon__CL_Product__c pr = [Select id from clcommon__CL_Product__c LIMIT 1];
        genesis__Applications__c application = createApp(10000,account_Obj,comp,pr, 48);

        loan__Loan_Account__c lacc = createCLContract(SYSTEM_DATE.addMonths(1), 48, application, 283.02, 200);

        createRepayment(lacc, 1, 283.02, 3, SYSTEM_DATE.addMonths(1));
        createRepayment(lacc, 2, 200, 5, SYSTEM_DATE.addMonths(4));
        createRepayment(lacc, 3, 296.80, 39, SYSTEM_DATE.addMonths(9));
        createRepayment(lacc, 4, 297.06, 1, SYSTEM_DATE.addMonths(48));
        createRepaymentPlan(lacc, 2, 5, 200 , SYSTEM_DATE.addMonths(4));


        Test.startTest();

        ModPaymentAmountUpdateJob job = new ModPaymentAmountUpdateJob('SELECT Id from loan__Loan_Account__c');

        Database.executeBatch(job, 200);

        Test.stopTest();

        loan__Loan_Account__c updateLoanAcc = [Select Id,Mod_Payment_Amount__c,Mod_End_Date__c FROM loan__Loan_Account__c LIMIT 1];

        clcommon__Repayment_Plan__c repaymentPlan = [Select clcommon__Payment_Amount__c, clcommon__Payment_Start_Date__c, clcommon__Number_Of_Payments__c from clcommon__Repayment_Plan__c limit 1];

        system.assertEquals(updateLoanAcc.Mod_End_Date__c,repaymentPlan.clcommon__Payment_Start_Date__c.addMonths(Integer.valueOf(repaymentPlan.clcommon__Number_Of_Payments__c)), 'wrong date');
        system.assertEquals(updateLoanAcc.Mod_Payment_Amount__c,repaymentPlan.clcommon__Payment_Amount__c, 'wrong amount');

    }
    static testMethod void testThreeRepayments() {
        Account account_Obj = [Select id from Account LIMIT 1];
        genesis__Company__c comp = [Select id from genesis__Company__c LIMIT 1]; 
        clcommon__CL_Product__c pr = [Select id from clcommon__CL_Product__c LIMIT 1];
        genesis__Applications__c application = createApp(10000,account_Obj,comp,pr, 48);

        loan__Loan_Account__c lacc = createCLContract(SYSTEM_DATE.addMonths(1), 48, application, 283.02, 200);

        createRepayment(lacc, 1, 200, 5, SYSTEM_DATE.addMonths(1));
        createRepayment(lacc, 2, 296.80, 42, SYSTEM_DATE.addMonths(6));
        createRepayment(lacc, 3, 255.72, 1, SYSTEM_DATE.addMonths(48));
        createRepaymentPlan(lacc, 1, 5, 200 , SYSTEM_DATE.addMonths(3));


        Test.startTest();

        ModPaymentAmountUpdateJob job = new ModPaymentAmountUpdateJob('SELECT Id from loan__Loan_Account__c');

        Database.executeBatch(job, 200);

        Test.stopTest();

        loan__Loan_Account__c updateLoanAcc = [Select Id,Mod_Payment_Amount__c,Mod_End_Date__c FROM loan__Loan_Account__c LIMIT 1];

        clcommon__Repayment_Plan__c repaymentPlan = [Select clcommon__Payment_Amount__c, clcommon__Payment_Start_Date__c, clcommon__Number_Of_Payments__c from clcommon__Repayment_Plan__c limit 1];

        system.assertEquals(updateLoanAcc.Mod_End_Date__c,repaymentPlan.clcommon__Payment_Start_Date__c.addMonths(Integer.valueOf(repaymentPlan.clcommon__Number_Of_Payments__c)), 'wrong date');
        system.assertEquals(updateLoanAcc.Mod_Payment_Amount__c,repaymentPlan.clcommon__Payment_Amount__c, 'wrong amount');
    }
    static testMethod void testThreeRepaymentWithNoRepaymentPlan() {
        Account account_Obj = [Select id from Account LIMIT 1];
        genesis__Company__c comp = [Select id from genesis__Company__c LIMIT 1]; 
        clcommon__CL_Product__c pr = [Select id from clcommon__CL_Product__c LIMIT 1];
        genesis__Applications__c application = createApp(10000,account_Obj,comp,pr, 48);

        loan__Loan_Account__c lacc = createCLContract(SYSTEM_DATE.addMonths(1), 48, application, 283.02, 200);

        createRepayment(lacc, 1, 200, 5, SYSTEM_DATE.addMonths(1));
        createRepayment(lacc, 2, 296.80, 42, SYSTEM_DATE.addMonths(6));
        createRepayment(lacc, 3, 255.72, 1, SYSTEM_DATE.addMonths(48));

        Test.startTest();

        ModPaymentAmountUpdateJob job = new ModPaymentAmountUpdateJob();

        Database.executeBatch(job, 200);

        Test.stopTest();

        loan__Loan_Account__c updateLoanAcc = [Select Id,Mod_Payment_Amount__c,Mod_End_Date__c FROM loan__Loan_Account__c LIMIT 1];

        system.assertEquals(null,updateLoanAcc.Mod_End_Date__c, 'should not be updated');
    }



    static testMethod void testModPaymentAmountUpdateJob() {  

        Test.startTest();

        ModPaymentAmountUpdateJob job = new ModPaymentAmountUpdateJob();

        String jobId = Database.executeBatch(job, 200);

        Test.stopTest();

        Assert.isTrue(jobId != null);

    }
}