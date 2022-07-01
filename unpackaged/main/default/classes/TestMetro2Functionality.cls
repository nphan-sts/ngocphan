@isTest
public class TestMetro2Functionality {

    Testmethod static void testPayOffM2BorrowerInfoImpl() {
        
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.integrateWithSFCRM();
        
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);                                    
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProductNoRules(
                            'TestProd',
                            dummyOffice,
                            dummyAccount, 
                            curr, 
                            dummyFeeSet,
                            'Declining Balance',
                            10,
                            10,
                            null);
        
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();        
        
        loan__Client__c dummyClient = loan.TestHelper.createClient(dummyOffice);
        
        loan__Metro2_Parameters__c m2Params = loan.CustomSettingsUtil.getMetro2Parameters();
        m2Params.loan__Identification_Number__c='ABCID';
        m2Params.loan__Experian_Identifier__c='DAZVD';
        m2Params.loan__Program_Date__c=Date.newInstance(2015, 5, 12);
        m2Params.loan__Program_Revision_Date__c=Date.newInstance(2015, 5, 12);
        m2Params.loan__Reporter_Name__c='ABC';
        m2Params.loan__Reporter_Phone__c='4129733110';
        m2Params.loan__Reporter_Address__c='ADDRESS';
        m2Params.loan__Metro2_Query_Class__c = 'LPM2QueryGenImpl';
        m2Params.loan__Borrower_Info_Class__c = 'LPM2BorrowerInfoImpl';
        upsert m2Params;

        Date SystemDate = TestHelper.getCurrentSystemDate();
        Date lastDayOfMonth = SystemDate.toStartOfMonth().addDays(Date.daysInMonth(SystemDate.toStartOfMonth().year(), SystemDate.toStartOfMonth().month()) - 1);       
        if (SystemDate < lastDayOfMonth){
            SystemDate = lastDayOfMonth.addMonths(-1);      
        }        
        system.debug(logginglevel.error,'SystemDate in test M2' +SystemDate);
        
        Account acc  = new Account();
        acc.name = 'Test Account';
        acc.BillingState = 'CA';
        acc.BillingCountry = 'US';
        acc.BillingPostalCode = '99999';
        acc.BillingStreet = 'Street  1';
        acc.Phone = '123-456 345345';
        
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'test';
        insert con;
        
        //Create a dummy Loan Account
        loan__Loan_Account__c loanAccount = loan.TestHelper.createLoanAccountForAccountObj(dummyLP,
                                                    acc,
                                                    dummyFeeSet,
                                                    dummyLoanPurpose,
                                                    dummyOffice);
        loanAccount.loan__Loan_Status__c = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        loanAccount.loan__Fees_Remaining__c  = 100;
        loanAccount.loan__Interest_Remaining__c = 500;
        loanAccount.loan__disbursal_date__c = systemDate.addDays(-10);
        loanAccount.loan__Principal_Remaining__c = 1000;
        loanAccount.loan__Pay_off_Amount_As_Of_Today__c = loanAccount.loan__Fees_Remaining__c + loanAccount.loan__Principal_Remaining__c;
        loanAccount.loan__Last_Accrual_Date__c = Date.Today();
        loanAccount.loan__Account__c = acc.Id;
        loanAccount.loan__Previous_Installment_Date__c = Date.Today().addDays(-30);
        loanAccount.loan__Last_Payment_Date__c = Date.Today().addDays(-30);
        loanAccount.loan__Last_Payment_Amount__c = 100;
        loanAccount.loan__First_Installment_Date__c = systemDate.addDays(-10);
        loanAccount.loan__Include_In_Metro2_File__c = true;
        loanAccount.loan__Loan_Effective_Date__c = Date.Today();
        loanAccount.loan__Metro2_Account_highest_bal_amount__c = 10000;
        loanAccount.loan__Time_Counting_Method__c = loan.LoanConstants.TIME_COUNTING_ACTUAL_DAYS;
        loanAccount.loan__Metro2_Account_Status_Code__c='11';
        loanAccount.loan__Metro2_Payment_History__c='BBBBBBBBBBBBBBBBBBBBBBBB';
        loanAccount.loan__Metro2_Account_Type_Code__c='01 - Unsecured';
        loanAccount.loan__Metro2_Payment_Rating__c='00';
        loanAccount.loan__Metro2_Portfolio_Type__c='Installment';
        loanAccount.loan__Metro2_Account_highest_bal_amount__c = 100000;
        loanAccount.loan__Metro2_Special_Comment__c = 'SC';
        loanAccount.loan__Charged_Off_Fees__c = 0;
        loanAccount.loan__Charged_Off_Interest__c = 0;
        loanAccount.loan__Pmt_Amt_Cur__c = 100;
        loanAccount.loan__Charged_Off_Principal__c = 0;
        loanAccount.loan__Term_Cur__c = 24;
        loanAccount.loan__Delinquent_Amount__c = 0;
        loanAccount.loan__Frequency_of_Loan_Payment__c = 'Monthly';
        loanAccount.loan__Metro2_First_Delinquency_Date__c  = Date.Today().addDays(-10); 
        loanAccount.loan__Metro2_Account_pmt_history_date__c = systemDate.addDays(-10);
        loanAccount.loan__Last_Payment_Amount__c = 100;
        loanAccount.loan__Pmt_Amt_Cur__c = 100;
        loanAccount.loan__Last_Payment_Date__c = Date.Today().addDays(-10);  
        loanAccount.loan__Charged_Off_Fees__c = 0;
        loanAccount.loan__Charged_Off_Interest__c= 0;
        loanAccount.loan__Charged_Off_Principal__c = 0;
        //loanAccount.name = 'test-account';
        //Metro2_Special_Comment__c=
        
        update loanAccount;
        
        PayOffM2BorrowerInfoImpl impl = new PayOffM2BorrowerInfoImpl();
        impl.setBorrower(acc);
        
        impl.getBorrowerInfo();
        impl.getLoanAccountType(loanAccount);
        impl.getLoanIdQuery();
        impl.getCoBorrowerInfo();
        //impl.getLoanNumber(loanAccount);
        impl.setBorrower(con);
    }
    
    Testmethod static void testPayOffM2QueryGenImpl() {
        
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.integrateWithSFCRM();
        
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);                                    
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProductNoRules(
                            'TestProd',
                            dummyOffice,
                            dummyAccount, 
                            curr, 
                            dummyFeeSet,
                            'Declining Balance',
                            10,
                            10,
                            null);
        
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();        
        
        loan__Client__c dummyClient = loan.TestHelper.createClient(dummyOffice);
        
        loan__Metro2_Parameters__c m2Params = loan.CustomSettingsUtil.getMetro2Parameters();
        m2Params.loan__Identification_Number__c='ABCID';
        m2Params.loan__Experian_Identifier__c='DAZVD';
        m2Params.loan__Program_Date__c=Date.newInstance(2015, 5, 12);
        m2Params.loan__Program_Revision_Date__c=Date.newInstance(2015, 5, 12);
        m2Params.loan__Reporter_Name__c='ABC';
        m2Params.loan__Reporter_Phone__c='4129733110';
        m2Params.loan__Reporter_Address__c='ADDRESS';
        m2Params.loan__Metro2_Query_Class__c = 'LPM2QueryGenImpl';
        m2Params.loan__Borrower_Info_Class__c = 'LPM2BorrowerInfoImpl';
        upsert m2Params;

        Date SystemDate = TestHelper.getCurrentSystemDate();
        Date lastDayOfMonth = SystemDate.toStartOfMonth().addDays(Date.daysInMonth(SystemDate.toStartOfMonth().year(), SystemDate.toStartOfMonth().month()) - 1);       
        if (SystemDate < lastDayOfMonth){
            SystemDate = lastDayOfMonth.addMonths(-1);      
        }        
        system.debug(logginglevel.error,'SystemDate in test M2' +SystemDate);
        
        Account acc  = new Account();
        acc.name = 'Test Account';
        acc.BillingState = 'CA';
        acc.BillingCountry = 'US';
        acc.BillingPostalCode = '99999';
        insert acc;
        
        //Create a dummy Loan Account
        loan__Loan_Account__c loanAccount = loan.TestHelper.createLoanAccountForAccountObj(dummyLP,
                                                    acc,
                                                    dummyFeeSet,
                                                    dummyLoanPurpose,
                                                    dummyOffice);
        loanAccount.loan__Loan_Status__c = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        loanAccount.loan__Fees_Remaining__c  = 100;
        loanAccount.loan__Interest_Remaining__c = 500;
        loanAccount.loan__disbursal_date__c = systemDate.addDays(-10);
        loanAccount.loan__Principal_Remaining__c = 1000;
        loanAccount.loan__Pay_off_Amount_As_Of_Today__c = loanAccount.loan__Fees_Remaining__c + loanAccount.loan__Principal_Remaining__c;
        loanAccount.loan__Last_Accrual_Date__c = Date.Today();
        loanAccount.loan__Account__c = acc.Id;
        loanAccount.loan__Previous_Installment_Date__c = Date.Today().addDays(-30);
        loanAccount.loan__Last_Payment_Date__c = Date.Today().addDays(-30);
        loanAccount.loan__Last_Payment_Amount__c = 100;
        loanAccount.loan__First_Installment_Date__c = systemDate.addDays(-10);
        loanAccount.loan__Include_In_Metro2_File__c = true;
        loanAccount.loan__Loan_Effective_Date__c = Date.Today();
        loanAccount.loan__Metro2_Account_highest_bal_amount__c = 10000;
        loanAccount.loan__Time_Counting_Method__c = loan.LoanConstants.TIME_COUNTING_ACTUAL_DAYS;
        loanAccount.loan__Metro2_Account_Status_Code__c='11';
        loanAccount.loan__Metro2_Payment_History__c='BBBBBBBBBBBBBBBBBBBBBBBB';
        loanAccount.loan__Metro2_Account_Type_Code__c='01 - Unsecured';
        loanAccount.loan__Metro2_Payment_Rating__c='00';
        loanAccount.loan__Metro2_Portfolio_Type__c='Installment';
        loanAccount.loan__Metro2_Account_highest_bal_amount__c = 100000;
        loanAccount.loan__Metro2_Special_Comment__c = 'SC';
        loanAccount.loan__Charged_Off_Fees__c = 0;
        loanAccount.loan__Charged_Off_Interest__c = 0;
        loanAccount.loan__Pmt_Amt_Cur__c = 100;
        loanAccount.loan__Charged_Off_Principal__c = 0;
        loanAccount.loan__Term_Cur__c = 24;
        loanAccount.loan__Delinquent_Amount__c = 0;
        loanAccount.loan__Frequency_of_Loan_Payment__c = 'Monthly';
        loanAccount.loan__Metro2_First_Delinquency_Date__c  = Date.Today().addDays(-10); 
        loanAccount.loan__Metro2_Account_pmt_history_date__c = systemDate.addDays(-10);
        loanAccount.loan__Last_Payment_Amount__c = 100;
        loanAccount.loan__Pmt_Amt_Cur__c = 100;
        loanAccount.loan__Last_Payment_Date__c = Date.Today().addDays(-10);  
        loanAccount.loan__Charged_Off_Fees__c = 0;
        loanAccount.loan__Charged_Off_Interest__c= 0;
        loanAccount.loan__Charged_Off_Principal__c = 0;
        //Metro2_Special_Comment__c=
        
        update loanAccount;
        
        PayOffM2QueryGenImpl impl = new PayOffM2QueryGenImpl();
        impl.getLoanQuery();
    }
    
    Testmethod static void TestMetro2Constants() {
    
        Metro2Constants M2 = new Metro2Constants();
        String T1 = Metro2Constants.SEGMENT_TYPE_HEADER  ;
        String T2 = Metro2Constants.FIELD_TYPE_ALPHA  ;
        String T3 = Metro2Constants.FIELD_TYPE_NUMERIC  ;
        String T4 = Metro2Constants.FILED_TYPE_MONETORY  ;
        String T5 = Metro2Constants.FIELD_TYPE_ALPHANUMERIC  ;
        String T6 = Metro2Constants.FIELD_TYPE_DATE  ;
        String T7 = Metro2Constants.SPECIAL_CHARS  ;
        String T8 = Metro2Constants.SEGMENT_TYPE_BASE ;
        String T9 = Metro2Constants.SEGMENT_TYPE_J1 ;
        String T10 = Metro2Constants.CCCD ;
        String T11 = Metro2Constants.CIIC ;
        String T12 = Metro2Constants.SPCC ;
        String T13 = Metro2Constants.SCB ;
    }


}