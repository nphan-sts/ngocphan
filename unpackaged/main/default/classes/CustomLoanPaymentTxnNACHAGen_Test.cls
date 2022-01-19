/* ****************Modification History******************
 * Modified By        Date          JIRA number
 *1. Galla        2020/04/21     CRM-467
 *Inserted Account
 *Updated loan Account value and loan Routing Number with 9 digits to loan Bank Account

	Anusha 		2020/11/05 CRM -986   New test method is added - 'testLatinConversionWithSpace'

    Shakul      2021/12/02  LSP-374   New Test method for missing bank account

 ******************Modification History******************/
@IsTest
public class CustomLoanPaymentTxnNACHAGen_Test {
    
    Public static testMethod Void CustomLoanPaymentTxnNACHAGen()
    { 
        Integer linecount = 0;
        Double blocks = 0.0;
        Long routingHash=427199009;
        loan.TransactionSweepToACHState state=new loan.TransactionSweepToACHState();
        map<string,integer> countMap=new map<string,integer>();
        countMap.put('test',1);
        state.o2=countMap;
       
       // loan.TransactionSweepToACHState state='';
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Account_External_ID__c = 'Test';
        acc.peer__Last_Name__c = 'Account';	//LSP-16
        insert acc;
        
        Contact a1 = new Contact(LastName='TestACH');
        insert a1;
        
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn(); 
        
        List<filegen__File_Metadata__c> metadata = Test.loadData(filegen__File_Metadata__c.sObjectType,'CustomTestMetaData');
        loan.TestHelper.setupACHParameters();
        loan.TestHelper2.createFileGenMetaData();
        //loan.TestHelper2.createOrgBankAccounts();
        // Updated loan Account value and loan Routing Number with 9 digits to loan Bank Account
        loan__Bank_Account__c collectionTrustBA = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
                                                                            loan__Bank_Name__c = 'Some Bank',
                                                                            loan__Routing_Number__c = '999999999',
                                                                            loan__Account_Type__c = 'Checking',
                                                                            loan__Account_Usage__c = 'Collections Trust Account',
                                                                            loan__Contact__c = a1.id,
                                                                            Unmasked_Bank_Account_Number__c = '123234324',
                                                                            loan__Active__c = True,
                                                                            loan__Account__c = acc.id
                                                                           );
        insert collectionTrustBA ;
        
        loan__Transaction_Approval_Config__c c = loan.CustomSettingsUtil.getApprovalConfig();
        c.loan__Payment__c = false;
        upsert c;
        
        loan__ACH_Parameters__c ach = loan.CustomSettingsUtil.getACHParameters();
        ach.loan__Days_In_Advance_To_Create_File__c = 0;
        ach.loan__Multiple_Payment_Method_Support__c =true;
        upsert ach;
        
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        loan__Payment_Mode__c pMode = [select id from loan__Payment_Mode__c where Name= 'ACH'];
        loan__Payment_Mode__c pMode1 = [select id from loan__Payment_Mode__c where Name = 'Cash'];
        
        loan__Bank_Account__c bank = [select id from loan__Bank_Account__c where loan__Account_usage__c=:loan.FractionalizationConstants.COLLECTIONS_TRUST_ACCOUNT limit 1];
        
        loan.TestHelper2.createAutomatedPaymentConfiguration(loan.LoanConstants.LOAN_PAYMENT,pMode,bank,'CustomLoanPaymentTxnNACHAGen');
        loan.TestHelper2.createAutomatedPaymentConfiguration(loan.LoanConstants.LOAN_PAYMENT,pMode1,bank,'CustomLoanPaymentTxnNACHAGen');
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
                                                                          dummyAccount, 
                                                                          curr, 
                                                                          dummyFeeSet);
        
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
      
        // Updated loan Account value and loan Routing Number with 9 digits to loan Bank Account
        loan__Bank_Account__c ba = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
                                                             loan__Bank_Name__c = 'Some Bank',
                                                             loan__Routing_Number__c = '999999999',
                                                             loan__Account_Type__c = 'Checking',
                                                             loan__Account_Usage__c = 'Collections Trust Account',
                                                             Unmasked_Bank_Account_Number__c = '123234324',
                                                             loan__Contact__c = a1.id,
                                                             loan__Account__c = acc.id);
        insert ba;
        
        Test.startTest();
        //Updated loan Loan Account
        loan__Loan_Account__c dummylaMonthly = loan.TestHelper.createLoanAccountForContactObj(dummyLP,
                                                                                              a1,
                                                                                              dummyFeeSet,
                                                                                              dummyLoanPurpose,
                                                                                              dummyOffice);
        
        
        dummylaMonthly.loan__Account__c = acc.Id;
        dummylaMonthly.loan__Loan_Status__c = 'Active - Good Standing';
        dummylaMonthly.loan__ACH_On__c=True;
        
        update dummylaMonthly;
        
        loan__Loan_Disbursal_Transaction__c disbTxn = new loan__Loan_Disbursal_Transaction__c();
        disbTxn.loan__Disbursal_Date__c = loan.TestHelper.systemDate;
        disbTxn.loan__Disbursed_Amt__c = dummylaMonthly.loan__Loan_Amount__c;
        disbTxn.loan__Loan_Account__c = dummylaMonthly.id;
        disbTxn.loan__Mode_of_Payment__c =  pMode.id;
        
        insert disbTxn;
        disbTxn.loan__Cleared__c =true;
        update disbTxn;
        
        loan__Automated_Payment_Setup__c aPS = loan.TestHelper2.createAutomatedPaymentSetup(loan.LoanConstants.RECURRING,loan.LoanConstants.FIXED_AMOUNT,ba,dummylaMonthly,'Monthly',pMode);
        loan__Automated_Payment_Setup__c aPS1 = loan.TestHelper2.createAutomatedPaymentSetup(loan.LoanConstants.ONE_TIME,loan.LoanConstants.FIXED_AMOUNT,ba,dummylaMonthly,'Monthly',pMode1);
        
        
        loan__Automated_Payment_Configuration__c lap=new loan__Automated_Payment_Configuration__c();
        lap.loan__Trace_Number_Prefix__c='testteasdf';
        lap.loan__Filegen_Class__c='testtest';
        lap.loan__Folder_Name__c='Test';
        lap.loan__Immediate_Destination__c='Test';
        lap.loan__Immediate_Origin__c='Test';
        lap.loan__Immediate_Origin_Name__c='Test';
        lap.loan__Reference_Code__c='test';
        lap.loan__Company_Identification__c='Test';
        lap.loan__Originating_DFI_Identification__c='Test';
        
        
        Insert lap;
        
        loan__Loan_Payment_Transaction__c dummyPmt2 = new loan__Loan_Payment_Transaction__c();
        dummyPmt2.loan__Cleared__c = false;
        dummyPmt2.loan__Payment_Mode__c = pMode.id;
        dummyPmt2.loan__Transaction_Amount__c  = 100;
        dummyPmt2.loan__Transaction_Date__c = loan.TestHelper.systemDate;
        dummyPmt2.loan__Loan_Account__c  = dummylaMonthly.id;
        //dummyPmt2.loan__Trace_Number_Prefix__c=123456;
        dummyPmt2.loan__Automated_Payment_Setup__c = aPS.id;
      
        
        Insert dummyPmt2;
        
        
          User loggedUser = [select Id, Name,username, 
                           CompanyName,
                           loan__Current_Branch__c
                           from User where Id = :UserInfo.getUserId()];
        

        Date da = date.today();
        Loan__loan_account__c loanContract = new loan__loan_account__c();
        loanContract.loan__Account__c = acc.Id;
        //loanContract.loan__Account__r.Name = acc.Name;
        //loanContract.loan__Loan_Purpose__c=dummyLoanPurpose.id;
        //loanContract.loan__Fee_Set__c = dummyFeeSet.id;
        //loanContract.loan__Loan_Product_Name__c = dummyLoanLP.id;
        loanContract.OwnerId = loggedUser.id;
        loanContract.loan__ACH_On__c=True;
        //loanContract.loan__Branch__c = dummyClient.id;
        loanContract.loan__Overdue_Interest_Rate__c=12; 
        loanContract.loan__Frequency_of_Loan_Payment__c='Monthly'; 
        //loanContract.loan__Client__c = dummyClient.id;
        loanContract.loan__First_Installment_Date__c= da.addMonths(1); 
        loanContract.loan__Expected_Disbursal_Date__c=da; 
        loanContract.loan__Repayment_Tied_to_Meeting_Schedule__c=false; 
        loanContract.loan__Repayment_Procedure__c='Equal Monthly Installments'; 
        loanContract.loan__Interest_Calculation_Method__c='Declining Balance'; 
        loanContract.loan__Expected_Repayment_Start_Date__c=da.addMonths(1); 
        loanContract.loan__Contractual_Due_Day__c=3; 
        loanContract.loan__Due_Day__c=3; 
        loanContract.loan__Next_Due_Generation_Date__c=da.addMonths(1); 
        loanContract.loan__Next_Installment_Date__c=da.addMonths(1); 
        loanContract.loan__Last_Installment_Date__c=da.addYears(1); 
        loanContract.loan__Maturity_Date_Current__c=da.addYears(1); 
        loanContract.loan__la_next_amortization_date__c=da; 
        loanContract.loan__LA_Amortization_Enabled__c=true; 
        loanContract.loan__LA_Amortized_Balance_Type__c='Interest'; 
        loanContract.loan__LA_Amortization_Frequency__c='Monthly'; 
        loanContract.loan__Delinquency_Grace_Days__c=10; 
        loanContract.loan__Interest_Remaining__c=0;
        loanContract.loan__Loan_Amount__c =1000;
        loanContract.loan__Number_of_Days_Overdue__c = 91; 
        loanContract.loan__Excess__c=0;
        loanContract.loan__Delinquent_Amount__c=0; 
        loanContract.loan__Pmt_Amt_Cur__c=1200; 
        //loanContract.loan__Branch__c=dummyCompany.id; 
        loanContract.loan__Oldest_Due_Date__c=da.addMonths(1); 
        loanContract.loan__Term_Cur__c=12;  
        loanContract.loan__Disbursal_Date__c=da; 
        loanContract.loan__Last_Accrual_Date__c=da; 
        loanContract.loan__Loan_Status__c='Active - Good Standing';
        
        insert loanContract;
        
        loan__Loan_Account__c LLA=[Select Id,Name,loan__Account__r.Name,loan__Loan_Status__c,loan__Last_Accrual_Date__c,loan__Disbursal_Date__c,loan__Term_Cur__c,
                               loan__Oldest_Due_Date__c,loan__Pmt_Amt_Cur__c,loan__Delinquent_Amount__c,loan__Excess__c,loan__Number_of_Days_Overdue__c,
                                loan__LA_Amortization_Frequency__c from Loan__loan_account__c where Id=:loanContract.Id];
        //LLA.loan__Account__c=acc.id;
        //Update LLA;
        
        
        system.debug('##loanContract'+loanContract);
        
        
        loan__Loan_Payment_Transaction__c lptValue=[Select Id,name,loan__Transaction_Amount__c,loan__Loan_Account__r.Id,loan__Loan_Account__r.loan__Account__r.Name,loan__Payment_Mode__c,loan__Cleared__c,loan__Automated_Payment_Setup__r.loan__Bank_Account__r.Unmasked_Bank_Account_Number__c,loan__Automated_Payment_Setup__r.loan__Bank_Account__r.loan__Routing_Number__c,loan__Automated_Payment_Setup__r.loan__Bank_Account__r.loan__Account_Type__c,loan__Loan_Account__c,loan__Transaction_Date__c from loan__Loan_Payment_Transaction__c  Where Id=:dummyPmt2.Id];
        lptValue.loan__Automated_Payment_Setup__r.loan__Bank_Account__r.loan__Routing_Number__c='100';
        lptValue.loan__Loan_Account__r.loan__Account__c=LLA.Id;
        Update lptValue;

        
        List<filegen__File_Header_Record__c> fhrlist=new List<filegen__File_Header_Record__c>();
        
        filegen__File_Header_Record__c fhr=new filegen__File_Header_Record__c();
        fHR.filegen__Immediate_Destination__c = 'immediateDestination';
        fHR.filegen__Immediate_Origin__c = 'immediateOrigin';
        fHR.filegen__Creation_Date__c = system.today();
        fHR.filegen__Creation_Time__c = 'myTime';
        fHR.filegen__ID_Modifier__c = 'abc';
        fHR.filegen__Immediate_Destination_Name__c = 'immediateDestinationName';
        fHR.filegen__Immediate_Origin_Name__c = 'immediateOriginName';
        fHR.filegen__Reference_Code__c = 'referenceCode';
        fhrlist.add(fHR);
        
        
        
        filegen__File_Header_Record__c fhr1=new filegen__File_Header_Record__c();
        fhr1.filegen__Immediate_Destination__c = 'immediateDestination';
        fhr1.filegen__Immediate_Origin__c = 'immediateOrigin';
        fhr1.filegen__Creation_Date__c = System.Today();
        fhr1.filegen__Creation_Time__c = 'myTime';
        fhr1.filegen__ID_Modifier__c = 'abc';
        fhr1.filegen__Immediate_Destination_Name__c = 'immediateDestinationName';
        fhr1.filegen__Immediate_Origin_Name__c = 'immediateOriginName';
        fhr1.filegen__Reference_Code__c = 'referenceCode';
        fhrlist.add(fhr1);
        
        Insert fhrlist;
        
        
        List<filegen__Batch_Control_Record__c> fbrlist=new List<filegen__Batch_Control_Record__c>();
        filegen__Batch_Control_Record__c bCR=new filegen__Batch_Control_Record__c();
        bCR.filegen__Service_Class_Code__c = '225';
        bCR.filegen__Entry_Addenda_Count__c = 'Test';
        bCR.filegen__Entry_Hash__c ='Test';
        bCR.filegen__Total_Debit_Entry_Dollar_Amount__c ='Test';
        String companyIdentificationq = '';
        String originatingDFIIdentificationq = '';
        bCR.filegen__Company_Identification__c = companyIdentificationq;
        bCR.filegen__Originating_DFI_Identification__c = originatingDFIIdentificationq;
        bCR.filegen__Batch_Number__c = '0000123';
        fbrlist.add(bCR);
        
        
        filegen__Batch_Control_Record__c bCR1=new filegen__Batch_Control_Record__c();
        bCR1.filegen__Service_Class_Code__c = '225';
        bCR1.filegen__Entry_Addenda_Count__c = 'Test';
        bCR1.filegen__Entry_Hash__c = 'TestTest';
        bCR1.filegen__Total_Debit_Entry_Dollar_Amount__c ='Test';
        String companyIdentification = '';
        String originatingDFIIdentification = 'Test';
        bCR1.filegen__Company_Identification__c = companyIdentification;
        bCR1.filegen__Originating_DFI_Identification__c = originatingDFIIdentification;
        bCR1.filegen__Batch_Number__c = '0000123';
        fbrlist.add(bCR1);
        
        Insert fbrlist;
        
        
        
        
       List<filegen__File_Control_Record__c> frr=new List<filegen__File_Control_Record__c>();
        filegen__File_Control_Record__c fCR = new filegen__File_Control_Record__c();
       Integer linecount1 = 5;
       Double blocks1 = math.ceil((double.valueOf(linecount1))/10);
        fCR.filegen__Batch_Count__c = '000001';
        fCR.filegen__Block_Count__c = String.valueOf(Integer.valueOf(blocks));
        fCR.filegen__Entry_Addenda_Count__c = 'Test';
        fCR.filegen__Entry_Hash__c = 'routingHash';
        fCR.filegen__total_debit_entry_dollar_amount_in_fil__c = 'Test';
        frr.add(fCR);
        
        filegen__File_Control_Record__c fCR1 = new filegen__File_Control_Record__c();
        Integer linecount2 = 5;
        Double blocks2 = math.ceil((double.valueOf(linecount2))/10);
        fCR1.filegen__Batch_Count__c = '000001';
        fCR1.filegen__Block_Count__c = String.valueOf(Integer.valueOf(blocks2));
        fCR1.filegen__Entry_Addenda_Count__c = 'Test';
        fCR1.filegen__Entry_Hash__c = 'routingHash';
        fCR1.filegen__total_debit_entry_dollar_amount_in_fil__c = 'Test';
        frr.add(fCR1);
        
        Insert frr;

system.debug('##frr'+frr);

        
        
        List<loan__Loan_Payment_Transaction__c>  lpt=new List<loan__Loan_Payment_Transaction__c>();
        
        loan__Loan_Payment_Transaction__c dummyPmt = new loan__Loan_Payment_Transaction__c();
        dummyPmt.loan__Cleared__c = false;
        dummyPmt.loan__Payment_Mode__c = pMode.id;
        dummyPmt.loan__Transaction_Amount__c  = 100;
        dummyPmt.loan__Transaction_Date__c = loan.TestHelper.systemDate;
        dummyPmt.loan__Loan_Account__c  = dummylaMonthly.id;
        dummyPmt.loan__Automated_Payment_Setup__c = aPS.id;
        //dummyPmt.loan__Trace_Number_Prefix__c=123456;
        lpt.add(dummyPmt);
        //sert dummyPmt;
        
        loan__Loan_Payment_Transaction__c dummyPmt1 = new loan__Loan_Payment_Transaction__c();
        dummyPmt1.loan__Cleared__c = false;
        //dummyPmt1.Name='TestTest';
        dummyPmt1.loan__Payment_Mode__c = pMode.id;
        dummyPmt1.loan__Transaction_Amount__c  = 100;
        dummyPmt1.loan__Transaction_Date__c = loan.TestHelper.systemDate;
        dummyPmt1.loan__Loan_Account__c  = dummylaMonthly.id;
        dummyPmt1.loan__Automated_Payment_Setup__c = aPS.id;
        
        lpt.add(dummyPmt1);
        
        insert lpt;
        
        CustomLoanPaymentTxnNACHAGen cus=new CustomLoanPaymentTxnNACHAGen();
        List<loan__Loan_Payment_Transaction__c> lptList = cus.requeryScope(lpt);
        System.assertEquals(2, lptList.size());
        cus.getSimpleFileName();
        cus.getEntries(state,lpt);
        cus.getHeader(state,fhrlist);
        cus.getTrailer(state,lpt);
        cus.generateFileHeaderRecord(state); 
        filegen__Batch_Header_Record__c fbhr = cus.generateBatchHeaderRecord();
        System.assertEquals('PPD', fbhr.filegen__SEC_Code__c);
        cus.generateBatchControlRecord(fbrlist);
        cus.generateFileControlRecord(frr);
        cus.LatinConversion('ÀÁÂÃĀĂȦÄẢÅǍȀȂĄÇĆ');    
        cus.generateEntryDetailRecord(LLA,lptValue); 
        cus.rightPadString('',10,'');
        Test.stopTest();
        
    }
    //CRM - 986 - start
    public static testMethod void testLatinConversionWithSpace(){
        CustomLoanPaymentTxnNACHAGen cus=new CustomLoanPaymentTxnNACHAGen();
        String convertedStr = cus.LatinConversion('Test€and™');
        System.debug('converted: '+convertedStr);
        System.assertEquals('Test and ', convertedStr);
    }
    //CRM - 986 - end
  
    //START: Added test method to cover missing bank account logic (LSP-374)
    public static testmethod void testMissingBankAccount(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        loan.TransactionSweepToACHState state=new loan.TransactionSweepToACHState();
        map<string,integer> countMap=new map<string,integer>();
        countMap.put('test',1);
        state.o2=countMap;
            
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Account_External_ID__c = 'Test';
        acc.peer__Last_Name__c = 'Account';
        insert acc;
        
        Contact a1 = new Contact(LastName='TestACH');
        insert a1;
        
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();
        
        loan.TestHelper.setupACHParameters();
        loan.TestHelper2.createFileGenMetaData();
        
        loan__Transaction_Approval_Config__c c = loan.CustomSettingsUtil.getApprovalConfig();
        c.loan__Payment__c = false;
        upsert c;
        
        loan__ACH_Parameters__c ach = loan.CustomSettingsUtil.getACHParameters();
        ach.loan__Days_In_Advance_To_Create_File__c = 0;
        ach.loan__Multiple_Payment_Method_Support__c =true;
        upsert ach;
        
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        loan__Payment_Mode__c pMode = [select id from loan__Payment_Mode__c where Name= 'ACH'];

        loan__Bank_Account__c collectionTrustBA = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
                                                                            loan__Bank_Name__c = 'Some Bank',
                                                                            loan__Routing_Number__c = '999999999',
                                                                            loan__Account_Type__c = 'Checking',
                                                                            loan__Account_Usage__c = 'Collections Trust Account',
                                                                            loan__Contact__c = a1.id,
                                                                            Unmasked_Bank_Account_Number__c = '123234324',
                                                                            loan__Active__c = True,
                                                                            loan__Account__c = acc.id
                                                                           );
        insert collectionTrustBA ;
        
        loan__Bank_Account__c bank = [select id from loan__Bank_Account__c where loan__Account_usage__c=:loan.FractionalizationConstants.COLLECTIONS_TRUST_ACCOUNT limit 1];
        
        loan.TestHelper2.createAutomatedPaymentConfiguration(loan.LoanConstants.LOAN_PAYMENT,pMode,bank,'CustomLoanPaymentTxnNACHAGen');
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
                                                                          dummyAccount, 
                                                                          curr, 
                                                                          dummyFeeSet);
        
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
      
        // Updated loan Account value and loan Routing Number with 9 digits to loan Bank Account
        loan__Bank_Account__c ba = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
                                                             loan__Bank_Name__c = 'Some Bank',
                                                             loan__Routing_Number__c = '999999999',
                                                             loan__Account_Type__c = 'Checking',
                                                             loan__Account_Usage__c = 'Collections Trust Account',
                                                             Unmasked_Bank_Account_Number__c = '123234324',
                                                             loan__Contact__c = a1.id,
                                                             loan__Account__c = acc.id);
        insert ba;
        
        //Updated loan Loan Account
        loan__Loan_Account__c dummylaMonthly = loan.TestHelper.createLoanAccountForContactObj(dummyLP,
                                                                                              a1,
                                                                                              dummyFeeSet,
                                                                                              dummyLoanPurpose,
                                                                                              dummyOffice);
        
        
        dummylaMonthly.loan__Account__c = acc.Id;
        dummylaMonthly.loan__Loan_Status__c = 'Active - Good Standing';
        dummylaMonthly.loan__ACH_On__c=True;
        
        update dummylaMonthly;
        
        loan__Loan_Disbursal_Transaction__c disbTxn = new loan__Loan_Disbursal_Transaction__c();
        disbTxn.loan__Disbursal_Date__c = loan.TestHelper.systemDate;
        disbTxn.loan__Disbursed_Amt__c = dummylaMonthly.loan__Loan_Amount__c;
        disbTxn.loan__Loan_Account__c = dummylaMonthly.id;
        disbTxn.loan__Mode_of_Payment__c =  pMode.id;
        
        insert disbTxn;
        disbTxn.loan__Cleared__c =true;
        update disbTxn;
        
        loan__Automated_Payment_Setup__c aPS = loan.TestHelper2.createAutomatedPaymentSetup(loan.LoanConstants.RECURRING,loan.LoanConstants.FIXED_AMOUNT,ba,dummylaMonthly,'Monthly',pMode);
        aPS.loan__Bank_Account__c = null;
        aPS.loan__CL_Contract__c = null;
        update aPS;
        
        loan__Loan_Payment_Transaction__c payment = new loan__Loan_Payment_Transaction__c();
        payment.loan__Cleared__c = false;
        payment.loan__Payment_Mode__c = pMode.id;
        payment.loan__Transaction_Amount__c  = 100;
        payment.loan__Transaction_Date__c = loan.TestHelper.systemDate.addDays(-1);
        payment.loan__Loan_Account__c  = dummylaMonthly.id;
        payment.loan__Automated_Payment_Setup__c = aPS.id;
        
        insert payment;
        
        Test.startTest();
        loan.LoanPaymentFilegenJob lp = new loan.LoanPaymentFilegenJob();
        Database.executeBatch(lp, 1);
        Test.stopTest();

        loan__Data_Migration_Error__c Dme =  [select id, loan__Error_Message__c from loan__Data_Migration_Error__c LIMIT 1];
        System.assertEquals(System.Label.Loan_BankAccountMissing, Dme.loan__Error_Message__c.substringAfterLast(':').trim());
    }
    //END: Added test method to cover missing bank account logic (LSP-374)
}