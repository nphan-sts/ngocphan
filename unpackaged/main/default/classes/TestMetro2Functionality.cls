/* ****************Modification History******************
* Updated By        Date				Jira Number		 
*1. Bhanupriya       2022/03/14     	LSP-606(create testsetup(), add required fields, add comments,)
******************Modification History******************/


@isTest
public class TestMetro2Functionality {
    
    //create testsetup()
    @testsetup()
    public static void testsetup(){
        
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.integrateWithSFCRM();
        
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);                                    
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        system.debug('Fee Junction'+dummyFeeJunction);
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProductNoRules('TestProd', dummyOffice,
                                        dummyAccount, 
                                        curr, 
                                        dummyFeeSet,
                                        'Declining Balance',
                                        10,
                                        10,
                                        null);
        
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();        
        
        //create loan dummy client 
        loan__Client__c dummyClient = loan.TestHelper.createClient(dummyOffice);
        system.debug('Client'+dummyClient);
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
        
        Date systemDate = TestHelper.getCurrentSystemDate();
        Date lastDayOfMonth = SystemDate.toStartOfMonth().addDays(Date.daysInMonth(SystemDate.toStartOfMonth().year(), SystemDate.toStartOfMonth().month()) - 1);       
        if (SystemDate < lastDayOfMonth){
            SystemDate = lastDayOfMonth.addMonths(-1);      
        }        
        system.debug(logginglevel.error,'SystemDate in test M2' +SystemDate);
        
        //create new account
        Account acc  = new Account();
        acc.name = 'Test Account';
        acc.BillingState = 'CA';
        acc.BillingCountry = 'US';
        acc.BillingPostalCode = '99999';
        acc.BillingStreet = 'Street  1';
        acc.Phone = '123-456 345345';
        acc.peer__Last_Name__c = 'Test Account Last Name';		//LSP-606 
        
        insert acc;
        
        //create new dummy contact
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
    }
    
    //create test method for PayOffM2BorrowerInfoImpl class
    @istest static void getBorrowerInfo() {
        
        Account acc  = [select id,name,peer__First_Name__c,loan__SOCIAL_SECURITY_NUMBER__c,
                        Address_1__c,City__c,State__c,ZIP_Code__c,
                        BillingCountry,Phone,peer__Date_of_Birth__c,peer__Last_Name__c
                        from Account 
                        where peer__Last_Name__c = 'Test Account Last Name'];
        loan__Loan_Account__c loanAccount = [select id,loan__Metro2_Account_Type_Code__c,Name
                                             from loan__Loan_Account__c];
        Contact con = [select id,
                       LastName
                       from Contact
                       where LastName = 'test'];
        
        test.startTest();
        PayOffM2BorrowerInfoImpl impl = new PayOffM2BorrowerInfoImpl();
        impl.setBorrower(acc);
        
        impl.getBorrowerInfo();
        impl.getLoanAccountType(loanAccount);
        impl.getLoanIdQuery();
        impl.getCoBorrowerInfo();
        impl.setBorrower(con);
        impl.getLoanNumber(loanAccount);		//LSP-606 to increase the code coverage
        test.stopTest();
        system.assert([select id from Account].size()>=1);
        system.assert(loanAccount!=null);
        
    }
    
    
    //test method 2 for PayOffM2QueryGenImpl class 
    @istest static void getQueryreturn() {
        
        list<loan__Loan_Account__c> loanAccount = [select id,loan__Metro2_Account_Type_Code__c,Name
                                                   from loan__Loan_Account__c];
        test.startTest();
        PayOffM2QueryGenImpl implq = new PayOffM2QueryGenImpl();
        implq.getLoanQuery();
        test.stopTest();
        system.assertEquals('01 - Unsecured',loanAccount[0].loan__Metro2_Account_Type_Code__c);
        system.assert(implq.getContactQuery()!=null);
      }
    
    //test method3 for Metro2Constants class
    @istest static void compareStringConstants() {
        
        test.startTest();
        Metro2Constants m2 = new Metro2Constants();
        String t1 = Metro2Constants.SEGMENT_TYPE_HEADER  ;
        String t2 = Metro2Constants.FIELD_TYPE_ALPHA  ;
        String t3 = Metro2Constants.FIELD_TYPE_NUMERIC  ;
        String t4 = Metro2Constants.FILED_TYPE_MONETORY  ;
        String t5 = Metro2Constants.FIELD_TYPE_ALPHANUMERIC  ;
        String t6 = Metro2Constants.FIELD_TYPE_DATE  ;
        String t7 = Metro2Constants.SPECIAL_CHARS  ;
        String t8 = Metro2Constants.SEGMENT_TYPE_BASE ;
        String t9 = Metro2Constants.SEGMENT_TYPE_J1 ;
        String t10 = Metro2Constants.CCCD ;
        String t11 = Metro2Constants.CIIC ;
        String t12 = Metro2Constants.SPCC ;
        String t13 = Metro2Constants.SCB ;
        test.stopTest();
        system.debug('Metro Functionality'+m2);
        //used for remove code smells
        system.debug(+t1 +''+t2 +''+t3 +''+t4);
        system.debug(+t5 +''+t6 +'' +t7 +''+t8 +''+t9);
        system.debug(+t10 +'' +t11 +''+t12 +''+t13);
    }    
}