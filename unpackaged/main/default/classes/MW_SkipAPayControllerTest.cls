@isTest	
private class MW_SkipAPayControllerTest {	
    @testSetup static void setup(){	
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
        
        genesis__Org_Parameters__c genorg = genesis__Org_Parameters__c.getOrgDefaults();	
        genorg.genesis__Disable_Triggers__c = true;	
        upsert genorg;	
        //comm	
        //Creating Account	
        Account acc = new Account(	
            Name = 'Test',	
            peer__Last_Name__c = 'Test',	
            loan__Investor__c=False,	
            cnotify__Email__c = 'abc@test.com',	
            loan__SOCIAL_SECURITY_NUMBER__c = '123456789'	
        );	
        insert acc;	
        System.assertEquals('Test',acc.Name,'Wrong Account');	
        
        LoanPaymentDays__c lpdays = new LoanPaymentDays__c();	
        lpdays.AutoPaymentRemainder__c= 3;	
        lpdays.ManualPaymentRemainder__c= 5;	
        insert lpdays;	
        
        loan__Loan_Product__c loanProdObj = new loan__Loan_Product__c(name='TestProduct'); 	
        insert loanProdObj;	
        System.assertEquals('TestProduct', loanProdObj.Name,'Wrong Loan Product');	
        
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
        
        Contact a1 = new Contact(LastName='TestACH');	
        insert a1;	
        
        
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
        application.genesis__Account__c = account_Obj.Id;	
        application.genesis__Total_Estimated_Interest__c=500;	
        application.genesis__Valid_Pricing_Flag__c=false;	
        application.genesis__Probability__c=100.00;	
        application.genesis__Payment_Amount__c=523.80;	
        application.genesis__Company__c = comp.id;	
        application.genesis__CL_Product__c = pr.id;	
        insert application;	
        
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();	
        Date systemDate = util.getCurrentSystemDate();	
        loan__Loan_Account__c lacc = new loan__Loan_Account__c(	
            loan__Account__c= acc.Id,	
            loan__Contact__c= a1.ID,	
            loan__Product_Type__c='Flexible Amz Loan',	
            loan__Loan_Amount__c =5000,	
            loan__Loan_Product_Name__c=loanProdObj.Id,	
            loan__Payment_Amount__c=439.70, 	
            loan__Principal_Remaining__c = 4243.60,	
            loan__Previous_Installment_Date__c= system.today(),	
            application__c = application.id, 	
            loan__First_Installment_Date__c = systemDate.addMonths(1),	
            loan__Next_Installment_Date__c = systemDate.addMonths(2), 	
            loan__Maturity_Date_Current__c = systemDate.addMonths(12), 	
            loan__Frequency_of_Loan_Payment__c = 'Monthly',  	
            loan__Last_Installment_Date__c = systemDate.addMonths(12),	
            loan__Loan_Status__c = 'Active - Good Standing',	
            loan__Interest_Rate__c = 10,	
            loan__Term_Cur__c = 12,	
            Skipped_a_pay_Date__c = null,	
            Skipped_a_Pay__c = false,	
            lead_guid__c = 'TestClassGuid0',	
            loan__Disbursal_Date__c = systemDate	
        );	
        insert lacc; 	
        
        loan__Repayment_Schedule_Summary__c repaymentScheduleSummary = new loan__Repayment_Schedule_Summary__c();	
        repaymentScheduleSummary.loan__RSS_No_Of_Pmts__c = 12;	
        repaymentScheduleSummary.loan__Archived__c = false;	
        repaymentScheduleSummary.loan__RSS_Loan_Account__c = lacc.Id;	
        insert repaymentScheduleSummary;	
        
        
        loan__Repayment_Schedule__c loanRepaymentSchedule7 = new loan__Repayment_Schedule__c();	
        loanRepaymentSchedule7.loan__Due_Date__c = systemDate.addMonths(1);	
        loanRepaymentSchedule7.loan__Loan_Account__c = lacc.Id;	
        loanRepaymentSchedule7.loan__Is_Archived__c = false;	
        loanRepaymentSchedule7.loan__Balance__c = 2188.70;	
        loanRepaymentSchedule7.loan__Due_Amount__c = 2188.70;	
        loanRepaymentSchedule7.loan__isPaid__c = false;	
        loanRepaymentSchedule7.loan__Is_Billed__c = false;	
        insert loanRepaymentSchedule7;	
        
        loan__Repayment_Schedule__c loanRepaymentSchedule8 = new loan__Repayment_Schedule__c();	
        loanRepaymentSchedule8.loan__Due_Date__c = systemDate.addMonths(2);	
        loanRepaymentSchedule8.loan__Loan_Account__c = lacc.Id;	
        loanRepaymentSchedule8.loan__Is_Archived__c = false;	
        loanRepaymentSchedule8.loan__Balance__c = 2188.70;	
        loanRepaymentSchedule8.loan__Due_Amount__c = 2188.70;	
        loanRepaymentSchedule8.loan__isPaid__c = false;	
        loanRepaymentSchedule8.loan__Is_Billed__c = false;	
        insert loanRepaymentSchedule8;	
        
        loan__Repayment_Schedule__c loanRepaymentSchedule9 = new loan__Repayment_Schedule__c();	
        loanRepaymentSchedule9.loan__Due_Date__c = systemDate.addMonths(3);	
        loanRepaymentSchedule9.loan__Loan_Account__c = lacc.Id;	
        loanRepaymentSchedule9.loan__Is_Archived__c = false;	
        loanRepaymentSchedule9.loan__Balance__c = 2188.70;	
        loanRepaymentSchedule9.loan__Due_Amount__c = 2188.70;	
        loanRepaymentSchedule9.loan__isPaid__c = false;	
        loanRepaymentSchedule9.loan__Is_Billed__c = false;	
        insert loanRepaymentSchedule9;     	
    }	
    //Valid loan id
    static testMethod void testPostwithValidLoanId() {	
        List<loan__Loan_Account__c> count = [ SELECT Id FROM loan__Loan_Account__c ];	
        loan__Loan_Account__c loan = [ SELECT Id, Name,
                                      loan__Loan_Status__c,Skipped_a_Pay__c,
                                      U_LoanModForbearance__c,U_LoanModForbearDt__c,U_LoanModTermExt__c
                                      FROM loan__Loan_Account__c LIMIT 1 ];	
        RestRequest req = new RestRequest(); 	
        RestResponse res = new RestResponse();             	
        req.requestURI = '/services/apexrest/skipapay/';	
        req.httpMethod = 'POST';	
        req.requestBody = Blob.valueOf('{ "loanId": "' + loan.id + '", "numberOfSkips": 1}');	
        RestContext.request = req;	
        RestContext.response= res;	
        MW_SkipAPayController.SkipAPayController();
        
      	ForBearanceLoanHelper helper = new ForBearanceLoanHelper( 'test', system.today() );
      	ForBearanceLoanHelper helper1 = new ForBearanceLoanHelper( loan, 1);
        
        
        system.assertEquals(loan.loan__Loan_Status__c, 'Active - Good Standing');
        system.assertEquals(loan.Skipped_a_Pay__c, False);
        system.assertEquals(loan.U_LoanModForbearance__c , null);
        system.assertEquals(loan.U_LoanModForbearDt__c, null);
        system.assertEquals(loan.U_LoanModTermExt__c, null);
        
      
    }	
    
   
    //False scenario
    static testMethod void testPostCallApiFalse() {
        
        loan__Loan_Account__c loan = [ SELECT Id, Name,lead_guid__C,Skipped_a_pay_Date__c,loan__Maturity_Date_Current__c,loan__Interest_Rate__c,
                                      loan__Loan_Status__c, Skipped_a_Pay__c,loan__Pmt_Amt_Cur__c,Hardship_New_Maturity_Date__c,loan__First_Installment_Date__c,loan__Frequency_of_Loan_Payment__c,
                                      loan__Next_Installment_Date__c ,
                                      loan__Oldest_Due_Date__c,U_LoanModForbearDt__c,U_LoanModForbearance__c,
                                      Hardship_Request_Date__c ,U_LoanModTermExt__c  FROM
                                      loan__Loan_Account__c where lead_guid__C = 'TestClassGuid0' ];	
        
        ForBearanceLoanHelper helper2 = new ForBearanceLoanHelper(loan,1,false);
        helper2.rescheduleLoan(new Map<String, String>());
       
        
        system.assertEquals(loan.loan__Loan_Status__c, 'Active - Good Standing');
        system.assertEquals(loan.Skipped_a_Pay__c, True);
        system.assertEquals(loan.U_LoanModForbearance__c , 1);
        system.assertEquals(loan.U_LoanModTermExt__c , 1);
    }
    //For bad standing loan
    static testMethod void testPostBadStandingLoan() {
        
        
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();	
        Date systemDate = util.getCurrentSystemDate();
        
        loan__Loan_Account__c loan = [ SELECT Id, Name,lead_guid__C,Skipped_a_pay_Date__c,loan__Maturity_Date_Current__c,loan__Interest_Rate__c,
                                      loan__Loan_Status__c, Skipped_a_Pay__c,loan__Pmt_Amt_Cur__c,Hardship_New_Maturity_Date__c,loan__First_Installment_Date__c,loan__Frequency_of_Loan_Payment__c,
                                      loan__Next_Installment_Date__c ,
                                      loan__Oldest_Due_Date__c,U_LoanModForbearDt__c,U_LoanModForbearance__c,
                                      Hardship_Request_Date__c ,U_LoanModTermExt__c FROM
                                      loan__Loan_Account__c where lead_guid__C = 'TestClassGuid0' ];
        loan.loan__Loan_Status__c = 'Active - Bad Standing';
        
        update loan;
        
        loan__Payment_Mode__c paymentmode = new loan__Payment_Mode__c();
        paymentmode.name = 'Cash';
        insert paymentmode;
        
        list<loan__Loan_Payment_Transaction__c> lptlist = new list<loan__Loan_Payment_Transaction__c>();
        
        loan__Loan_Payment_Transaction__c lpt = new loan__Loan_Payment_Transaction__c();
        
        
        lpt.loan__Loan_Account__c = loan.id;
        
        lpt.loan__Cleared__c = false;
        lpt.loan__Rejected__c = false;
        lpt.loan__Reversed__c = false;
        lpt.loan__Transaction_Date__c = Date.newInstance(2021, 06, 25);
        lpt.loan__Sent_to_ACH__c = false;
        lpt.loan__Loan_Snapshot__c = '';
        
        lpt.loan__Transaction_Amount__c = 2000;
        lpt.loan__Payment_Mode__c = paymentmode.id;
        lpt.loan__Transaction_Date__c = Date.newInstance(2021, 06, 25);
        lpt.loan__Receipt_Date__c = Date.newInstance(2021, 06, 25);
        insert lpt;
        lptlist.add(lpt);
        update lptlist;
        
        
        
        
        loan__Repayment_Schedule_Summary__c repaymentScheduleSummarySap = new loan__Repayment_Schedule_Summary__c();	
        repaymentScheduleSummarySap.loan__RSS_No_Of_Pmts__c = 12;	
        repaymentScheduleSummarySap.loan__Archived__c = false;	
        repaymentScheduleSummarySap.loan__RSS_Loan_Account__c = loan.Id;	
        insert repaymentScheduleSummarySap;	
        
        
        loan__Repayment_Schedule__c loanRepaymentScheduleSap = new loan__Repayment_Schedule__c();
        
        loanRepaymentScheduleSap.loan__Due_Date__c = systemDate.addMonths(1);	
        loanRepaymentScheduleSap.loan__Loan_Account__c = loan.Id;	
        loanRepaymentScheduleSap.loan__Is_Archived__c = false;	
        loanRepaymentScheduleSap.loan__Balance__c = 2188.70;	
        loanRepaymentScheduleSap.loan__Due_Amount__c = 2188.70;	
        loanRepaymentScheduleSap.loan__isPaid__c = false;	
        loanRepaymentScheduleSap.loan__Is_Billed__c = false;	
        insert loanRepaymentScheduleSap;
        
        ForBearanceLoanHelper helper2 = new ForBearanceLoanHelper(loan,2,true);
        
        helper2.rescheduleLoan(new Map<String, String>());
        
        helper2.checkIfLoanisEligibleForReschedule(lpt);
        
         
        system.assertEquals(loan.loan__Loan_Status__c, 'Active - Bad Standing');
        system.assertEquals(loan.Skipped_a_Pay__c, False);
        system.assertEquals(loan.U_LoanModForbearance__c , null);
        system.assertEquals(loan.U_LoanModForbearDt__c, null);
        system.assertEquals(loan.U_LoanModTermExt__c, null);
        
    }
    
    static testMethod void testSkippedaPayTrue() {
        
        
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();	
        Date systemDate = util.getCurrentSystemDate();
        
        loan__Loan_Account__c loan = [ SELECT Id, Name,lead_guid__C,Skipped_a_pay_Date__c,loan__Maturity_Date_Current__c,loan__Interest_Rate__c,
                                      loan__Loan_Status__c, Skipped_a_Pay__c,loan__Pmt_Amt_Cur__c,Hardship_New_Maturity_Date__c,loan__First_Installment_Date__c,loan__Frequency_of_Loan_Payment__c,
                                      loan__Next_Installment_Date__c ,
                                      loan__Oldest_Due_Date__c,U_LoanModForbearDt__c,U_LoanModForbearance__c,
                                      Hardship_Request_Date__c ,U_LoanModTermExt__c FROM
                                      loan__Loan_Account__c where lead_guid__C = 'TestClassGuid0' ];
       
        loan.loan__Loan_Status__c = 'Active - Bad Standing';
        loan.Skipped_a_Pay__c = true;
        loan.Skipped_a_pay_Date__c = system.today();
        update loan;
        
        loan__Payment_Mode__c paymentmode = new loan__Payment_Mode__c();
        paymentmode.name = 'Cash';
        insert paymentmode;
        
        list<loan__Loan_Payment_Transaction__c> lptlist = new list<loan__Loan_Payment_Transaction__c>();
        
        loan__Loan_Payment_Transaction__c lpt = new loan__Loan_Payment_Transaction__c();
        
        
        lpt.loan__Loan_Account__c = loan.id;
        
        lpt.loan__Cleared__c = false;
        lpt.loan__Rejected__c = false;
        lpt.loan__Reversed__c = false;
        lpt.loan__Sent_to_ACH__c = false;
        lpt.loan__Loan_Snapshot__c = '';
        
        lpt.loan__Transaction_Amount__c = 2000;
        lpt.loan__Payment_Mode__c = paymentmode.id;
        lpt.loan__Transaction_Date__c = system.today();
        lpt.loan__Receipt_Date__c = Date.newInstance(2021, 06, 25);
        insert lpt;
        lptlist.add(lpt);
        update lptlist;
        
        
        
        
        loan__Repayment_Schedule_Summary__c repaymentScheduleSummarySap = new loan__Repayment_Schedule_Summary__c();	
        repaymentScheduleSummarySap.loan__RSS_No_Of_Pmts__c = 12;	
        repaymentScheduleSummarySap.loan__Archived__c = false;	
        repaymentScheduleSummarySap.loan__RSS_Loan_Account__c = loan.Id;	
        insert repaymentScheduleSummarySap;	
        
        
        loan__Repayment_Schedule__c loanRepaymentScheduleSap = new loan__Repayment_Schedule__c();
        
        loanRepaymentScheduleSap.loan__Due_Date__c = Date.newInstance(2021, 06, 25);	
        loanRepaymentScheduleSap.loan__Loan_Account__c = loan.Id;	
        loanRepaymentScheduleSap.loan__Is_Archived__c = false;	
        loanRepaymentScheduleSap.loan__Balance__c = 2188.70;	
        loanRepaymentScheduleSap.loan__Due_Amount__c = 2188.70;	
        loanRepaymentScheduleSap.loan__isPaid__c = false;	
        loanRepaymentScheduleSap.loan__Is_Billed__c = false;	
        insert loanRepaymentScheduleSap;
        
        ForBearanceLoanHelper helper2 = new ForBearanceLoanHelper(loan,2,true);
        
        
        helper2.rescheduleLoan(new Map<String, String>());
        
        
        system.assertEquals(loan.loan__Loan_Status__c, 'Active - Bad Standing');
        system.assertEquals(loan.Skipped_a_Pay__c, True);
        system.assertEquals(loan.U_LoanModForbearance__c , null);
        system.assertEquals(loan.U_LoanModForbearDt__c, null);
        system.assertEquals(loan.U_LoanModTermExt__c, null);
        
    }
    
    static testMethod void testNotEligibleForReschedule() {
        
        
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();	
        Date systemDate = util.getCurrentSystemDate();
        
        loan__Loan_Account__c loan = [ SELECT Id, Name,lead_guid__C,Skipped_a_pay_Date__c,loan__Maturity_Date_Current__c,loan__Interest_Rate__c,
                                      loan__Loan_Status__c, Skipped_a_Pay__c,loan__Pmt_Amt_Cur__c,Hardship_New_Maturity_Date__c,loan__First_Installment_Date__c,loan__Frequency_of_Loan_Payment__c,
                                      loan__Next_Installment_Date__c ,
                                      loan__Oldest_Due_Date__c,U_LoanModForbearDt__c,U_LoanModForbearance__c,
                                      Hardship_Request_Date__c ,U_LoanModTermExt__c FROM
                                      loan__Loan_Account__c where lead_guid__C = 'TestClassGuid0' ];
       
        loan.Skipped_a_Pay__c = true;
        loan.Skipped_a_pay_Date__c = system.today();
        update loan;
        
        loan__Payment_Mode__c paymentmode = new loan__Payment_Mode__c();
        paymentmode.name = 'Cash';
        insert paymentmode;
        
        list<loan__Loan_Payment_Transaction__c> lptlist = new list<loan__Loan_Payment_Transaction__c>();
        
        loan__Loan_Payment_Transaction__c lpt = new loan__Loan_Payment_Transaction__c();
        
        
        lpt.loan__Loan_Account__c = loan.id;
        
        lpt.loan__Cleared__c = false;
        lpt.loan__Rejected__c = false;
        lpt.loan__Reversed__c = false;
        lpt.loan__Sent_to_ACH__c = false;
        lpt.loan__Loan_Snapshot__c = '';
        
        lpt.loan__Transaction_Amount__c = 2000;
        lpt.loan__Payment_Mode__c = paymentmode.id;
        lpt.loan__Transaction_Date__c = Date.newInstance(2021, 06, 25);
        lpt.loan__Receipt_Date__c = Date.newInstance(2021, 06, 25);
        insert lpt;
        lptlist.add(lpt);
        update lptlist;
        
        
        
        
        loan__Repayment_Schedule_Summary__c repaymentScheduleSummarySap = new loan__Repayment_Schedule_Summary__c();	
        repaymentScheduleSummarySap.loan__RSS_No_Of_Pmts__c = 12;	
        repaymentScheduleSummarySap.loan__Archived__c = false;	
        repaymentScheduleSummarySap.loan__RSS_Loan_Account__c = loan.Id;	
        insert repaymentScheduleSummarySap;	
        
        
        loan__Repayment_Schedule__c loanRepaymentScheduleSap = new loan__Repayment_Schedule__c();
        
        loanRepaymentScheduleSap.loan__Due_Date__c = Date.newInstance(2021, 06, 25);	
        loanRepaymentScheduleSap.loan__Loan_Account__c = loan.Id;	
        loanRepaymentScheduleSap.loan__Is_Archived__c = false;	
        loanRepaymentScheduleSap.loan__Balance__c = 2188.70;	
        loanRepaymentScheduleSap.loan__Due_Amount__c = 2188.70;	
        loanRepaymentScheduleSap.loan__isPaid__c = false;	
        loanRepaymentScheduleSap.loan__Is_Billed__c = false;	
        insert loanRepaymentScheduleSap;
        
        ForBearanceLoanHelper helper2 = new ForBearanceLoanHelper(loan,2,true);
        
        helper2.rescheduleLoan(new Map<String, String>());

        helper2.checkIfLoanisEligibleForReschedule(lpt);
        
        
        
        system.assertEquals(loan.loan__Loan_Status__c, 'Active - Good Standing');
        system.assertEquals(loan.Skipped_a_Pay__c, True);
        system.assertEquals(loan.U_LoanModForbearance__c , null);
        system.assertEquals(loan.U_LoanModForbearDt__c, null);
        system.assertEquals(loan.U_LoanModTermExt__c, null);
        
    }
    
}