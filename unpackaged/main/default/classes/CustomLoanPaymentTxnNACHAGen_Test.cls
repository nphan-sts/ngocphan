/* ****************Modification History******************
* Modified By        Date          JIRA number
*1. Galla        2020/04/21     CRM-467
*Inserted Account
*Updated loan Account value and loan Routing Number with 9 digits to loan Bank Account

Anusha 		2020/11/05 CRM -986   New test method is added - 'testLatinConversionWithSpace'

Shakul      2021/12/02  LSP-374   New Test method for missing bank account
Shakul      2022/02/15  LSP-505   Refactored test class
Bhavya		2022/05/24  LSP-380	  Refactored test class for LSP-380
******************Modification History******************/

@IsTest
public class CustomLoanPaymentTxnNACHAGen_Test {
    
    @TestSetup
    public static void testSetup(){

        loan__ACH_Parameters__c ach = loan.CustomSettingsUtil.getACHParameters();
        ach.loan__Days_In_Advance_To_Create_File__c = 0;
        ach.loan__Multiple_Payment_Method_Support__c =true;
        ach.loan__Organization_Name__c = 'Cloud Lending Inc';
        ach.loan__Use_Lock_Based_ACH__c = true;
        upsert ach;

        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Account_External_ID__c = 'Test';
        acc.peer__Last_Name__c = 'Account';
        insert acc;

        Contact a1 = new Contact(LastName='TestACH');
        insert a1;

        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        
        loan.TestHelper2.createFileGenMetaData();
        
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        

        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();

        
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,dummyAccount,curr,dummyFeeSet);
        
        loan__Payment_Mode__c pMode = [SELECT id, name FROM loan__Payment_Mode__c WHERE Name= 'ACH'];
        
        loan__Bank_Account__c ba = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
                                                             loan__Bank_Name__c = 'Some Bank',
                                                             loan__Routing_Number__c = '999999999',
                                                             loan__Account_Type__c = 'Checking',
                                                             loan__Account_Usage__c = 'Collections Trust Account',
                                                             Unmasked_Bank_Account_Number__c = '123234324',
                                                             loan__Contact__c = a1.id,
                                                             loan__Account__c = acc.id,
                                                             loan__Active__c = true);
        insert ba;
        
        loan__Loan_Account__c dummylaMonthly = loan.TestHelper.createLoanAccountForContactObj(dummyLP,a1,dummyFeeSet,dummyLoanPurpose,
                                                                                              dummyOffice);
        

        dummylaMonthly.loan__Account__c = acc.Id;
        dummylaMonthly.loan__Loan_Status__c = 'Active - Good Standing';
        dummylaMonthly.loan__ACH_On__c=true;
        dummylaMonthly.loan__Borrower_ACH__c = ba.id;
        update dummylaMonthly;

        
        loan__Automated_Payment_Configuration__c aPC = loan.TestHelper2.createAutomatedPaymentConfiguration(loan.LoanConstants.LOAN_PAYMENT,pMode,ba,'CustomLoanPaymentTxnNACHAGen');
        apc.loan__Immediate_Destination__c = '2222222222';
        update apc;
     
        loan__Automated_Payment_Setup__c aPS = loan.TestHelper2.createAutomatedPaymentSetup(loan.LoanConstants.RECURRING,loan.LoanConstants.FIXED_AMOUNT,ba,dummylaMonthly,'Monthly',pMode);

        List<loan__Loan_Payment_Transaction__c>  lpt=new List<loan__Loan_Payment_Transaction__c>();
        
        loan__Loan_Payment_Transaction__c dummyPmt = new loan__Loan_Payment_Transaction__c();
        dummyPmt.loan__Cleared__c = false;
        dummyPmt.loan__Payment_Mode__c = pMode.id;
        dummyPmt.loan__Transaction_Amount__c  = 100;
        dummyPmt.loan__Transaction_Date__c = loan.TestHelper.systemDate;
        dummyPmt.loan__Loan_Account__c  = dummylaMonthly.id;
        dummyPmt.loan__Automated_Payment_Setup__c = aPS.id;
        lpt.add(dummyPmt);
        
        loan__Loan_Payment_Transaction__c dummyPmt1 = new loan__Loan_Payment_Transaction__c();
        dummyPmt1.loan__Cleared__c = false;
        dummyPmt1.loan__Payment_Mode__c = pMode.id;
        dummyPmt1.loan__Transaction_Amount__c  = 100;
        dummyPmt1.loan__Transaction_Date__c = loan.TestHelper.systemDate;
        dummyPmt1.loan__Loan_Account__c  = dummylaMonthly.id;
        dummyPmt1.loan__Automated_Payment_Setup__c = aPS.id;
        
        lpt.add(dummyPmt1);
        
        insert lpt;
    }
    /*Created By: Shakul Siddharth

Description: To test the logic for file name generation */

    static testMethod void testSimpleFileName(){
        Test.startTest();
        CustomLoanPaymentTxnNACHAGen cus=new CustomLoanPaymentTxnNACHAGen();
        String msg = cus.getSimpleFileName();
        Test.stopTest();
        System.assertEquals('Loan_Payments_ACH', msg);
    }

    
    /*Created By: Shakul Siddharth
Description: To test the logic for entry level description if multiple payment mode is supported in NACHA file */

    static testMethod void testGetEntries(){

        loan.TransactionSweepToACHState state = getACHState();

        List<loan__Loan_Payment_Transaction__c> lpt = [SELECT Id FROM loan__Loan_Payment_Transaction__c];
        Test.startTest();
        CustomLoanPaymentTxnNACHAGen cus=new CustomLoanPaymentTxnNACHAGen();
        List<String> msgs = cus.getEntries(state,lpt);
        Test.stopTest();
        System.assertEquals(msgs.isEmpty(), false);
    }

    
    /*Created By: Shakul Siddharth
Description: To test the logic for header level description in NACHA file with multi pay support*/

    static testMethod void testGetHeader(){

        loan.TransactionSweepToACHState state = getACHState();

        List<loan__Loan_Payment_Transaction__c> lpt = [SELECT id FROM loan__Loan_Payment_Transaction__c];
        Test.startTest();

        List<filegen__File_Header_Record__c> fhrList = getFileHeaderRecords();
        insert fhrList;

        CustomLoanPaymentTxnNACHAGen cus = new CustomLoanPaymentTxnNACHAGen();
        cus.getEntries(state, lpt);
        String msg = cus.getHeader(state, fhrList);
        Test.stopTest();

        System.assertEquals('2222222222', getApc().loan__Immediate_Destination__c);
        System.assert(String.isNotBlank(msg));
    }

    /**
     * Test the left padding configuration flag enabled and disabled
     */
    static testMethod void testGetHeaderWithLeftPadding() {

        loan.TransactionSweepToACHState state = getACHState();

        loan__Automated_Payment_Configuration__c ap = getApc();
        ap.loan__Immediate_Destination__c = '987656789';
        update ap;

        Test.startTest();
        List<filegen__File_Header_Record__c> frs = getFileHeaderRecords();
        insert frs;

        CustomLoanPaymentTxnNACHAGen cus=new CustomLoanPaymentTxnNACHAGen();
        cus.getEntries(state, [SELECT Id FROM loan__Loan_Payment_Transaction__c]);
        String flagDisabledMsg = cus.getHeader(state, frs);

        MW_Settings__c mwSettings = MW_Settings__c.getOrgDefaults();
        mwSettings.US_Bank_Enabled__c = true;
        insert mwSettings;

        String flagEnabledMsg = cus.getHeader(state, frs);

        Test.stopTest();

        System.debug('actualFlagOff: ' + flagDisabledMsg);
        System.debug('flagEnabledMsg: ' + flagEnabledMsg);

        System.assertEquals('987656789', getApc().loan__Immediate_Destination__c);

        System.assert(flagDisabledMsg.contains('0987656789') && !flagDisabledMsg.contains(' 987656789'));
        System.assert(flagEnabledMsg.contains(' 987656789') && !flagEnabledMsg.contains('0987656789'));
    }

    /*Created By: Shakul Siddharth
Description: To test the logic for trailer level description in NACHA file*/
    static testMethod void testGetTrailer(){

        loan.TransactionSweepToACHState state = getACHState();

        List<loan__Loan_Payment_Transaction__c> lpt = [SELECT id FROM loan__Loan_Payment_Transaction__c];
        Test.startTest();
        CustomLoanPaymentTxnNACHAGen cus=new CustomLoanPaymentTxnNACHAGen();
        cus.getEntries(state,lpt);
        String msg = cus.getTrailer(state,lpt);
        Test.stopTest();
        System.assert(String.isNotBlank(msg));
    }
    
    /*Created By: Shakul Siddharth
Description: To test header level functionality without multiple payment support*/
    static testMethod void testGetHeader_WithoutMultiPaySupport(){

        loan.TransactionSweepToACHState state = getACHState();

        loan__ACH_Parameters__c ach = [SELECT id, loan__Multiple_Payment_Method_Support__c FROM loan__ACH_Parameters__c];
        List<loan__Loan_Payment_Transaction__c> lpt = [SELECT id FROM loan__Loan_Payment_Transaction__c];
        Test.startTest();
        
        List<filegen__File_Header_Record__c> fhrList = getFileHeaderRecords();
        insert fhrList;
        
        ach.loan__Multiple_Payment_Method_Support__c = false;
        update ach;
        
        CustomLoanPaymentTxnNACHAGen cus=new CustomLoanPaymentTxnNACHAGen();
        cus.getEntries(state,lpt);
        
        String msg = cus.getHeader(state,fhrList);
        Test.stopTest();
        System.assert(String.isNotBlank(msg));
    }

    static testMethod void testGetHeader_WithoutMultiPaySupportLeftPadChar() {

        loan.TransactionSweepToACHState state = getACHState();

        loan__ACH_Parameters__c achSettings = loan.CustomSettingsUtil.getACHParameters();
        achSettings.loan__Immediate_Destination__c = '987656789';
        upsert achSettings;

        loan__ACH_Parameters__c ach = [SELECT Id, loan__Multiple_Payment_Method_Support__c FROM loan__ACH_Parameters__c];
        List<loan__Loan_Payment_Transaction__c> lpt = [SELECT Id FROM loan__Loan_Payment_Transaction__c];
        Test.startTest();

        List<filegen__File_Header_Record__c> fhrList = getFileHeaderRecords();
        insert fhrList;

        ach.loan__Multiple_Payment_Method_Support__c = false;
        update ach;

        CustomLoanPaymentTxnNACHAGen cus = new CustomLoanPaymentTxnNACHAGen();
        cus.getEntries(state, lpt);

        String flagDisabledMsg = cus.getHeader(state,fhrList);

        MW_Settings__c mwSettings = MW_Settings__c.getOrgDefaults();
        mwSettings.US_Bank_Enabled__c = true;
        insert mwSettings;

        String flagEnabledMsg = cus.getHeader(state,fhrList);
        Test.stopTest();

        System.debug('flagDisabledMsg: ' + flagDisabledMsg);
        System.debug('flagEnabledMsg: ' + flagEnabledMsg);

        System.assert(flagDisabledMsg.contains('0987656789') && !flagDisabledMsg.contains(' 987656789'));
        System.assert(flagEnabledMsg.contains(' 987656789') && !flagEnabledMsg.contains('0987656789'));
    }

    /**
     * @return an instance of TransactionSweepToACHState
     */
    private static loan.TransactionSweepToACHState getACHState() {
        loan.TransactionSweepToACHState state = new loan.TransactionSweepToACHState();
        Map<String, Integer> countMap = new Map<String, Integer>();
        countMap.put('test', 1);
        state.o2 = countMap;
        return state;
    }

    /**
     * @return The first Automated Payment Configuration record
     */
    private static loan__Automated_Payment_Configuration__c getApc() {
        return [
                SELECT Id,
                        loan__Immediate_Destination__c
                FROM loan__Automated_Payment_Configuration__c
                LIMIT 1
        ];
    }

    /**
     * @return Get file header records for test setup
     */
    private static List<filegen__File_Header_Record__c> getFileHeaderRecords() {
        List<filegen__File_Header_Record__c> frs = new List<filegen__File_Header_Record__c>();
        filegen__File_Header_Record__c fr = new filegen__File_Header_Record__c();
        fr.filegen__Immediate_Destination__c = 'immediateDestination';
        fr.filegen__Immediate_Origin__c = 'immediateOrigin';
        fr.filegen__Creation_Date__c = System.today();
        fr.filegen__Creation_Time__c = 'myTime';
        fr.filegen__ID_Modifier__c = 'abc';
        fr.filegen__Immediate_Destination_Name__c = 'immediateDestinationName';
        fr.filegen__Immediate_Origin_Name__c = 'immediateOriginName';
        fr.filegen__Reference_Code__c = 'referenceCode';
        frs.add(fr);
        return frs;
    }
}