/* ****************Modification History******************
 * Modified By        Date          JIRA number
 *	1. Galla        2020/04/21     CRM-467
 *	Inserted Account
 *	Updated loan Account value and loan Routing Number with 9 digits to loan Bank Account
 *	2. Anusha			2021/10/22		LSP-379-Closure tolerance LPT's  payment mode set to ACH - CLS case #02892604
 ******************Modification History******************/
@IsTest
public class UpdatePaymentModeValue_Test {
    @testSetup
    public static void testSetup(){
        loan__Payment_Mode__c lp=new loan__Payment_Mode__c();
        lp.Name='Waived';
        lp.loan__Summary__c=False;
        lp.loan__Master_Archive_Object__c=False;
        lp.loan__Summary_Record_Id__c='TestRec';
        lp.loan__Archived__c=False;
        Insert lp;        
        
        //Create a Account
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Account_External_ID__c = 'Test';
        acc.peer__Last_Name__c = 'Tester';//LSP-379
        insert acc;
        
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn(); 
        
        List<filegen__File_Metadata__c> metadata = Test.loadData(filegen__File_Metadata__c.sObjectType,'CustomTestMetaData');
        loan.TestHelper.setupACHParameters();
        loan.TestHelper2.createFileGenMetaData();
        loan__Bank_Account__c collectionTrustBA = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123234324',
                                                                            loan__Bank_Name__c = 'Some Bank',
                                                                            loan__Routing_Number__c = '999999999',
                                                                            loan__Account_Type__c = 'Checking',
                                                                            loan__Account_Usage__c = 'Collections Trust Account',
                                                                            Unmasked_Bank_Account_Number__c = '123234324',
                                                                            loan__Active__c = True,
                                                                            loan__Account__c = acc.id);
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
        
        Contact a1 = new Contact(LastName='TestACH');
        insert a1;
        
        loan__Bank_Account__c ba = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
                                                             loan__Bank_Name__c = 'Some Bank',
                                                             loan__Routing_Number__c = '999999999',
                                                             loan__Account_Type__c = 'Checking',
                                                             Unmasked_Bank_Account_Number__c = '123234324',
                                                             loan__Contact__c = a1.id,
                                                             loan__Active__c = True,
                                                             loan__Account__c = acc.id);
        insert ba;
        
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
        
        loan__Loan_Payment_Transaction__c payment = new loan__Loan_Payment_Transaction__c();
        payment.loan__Cleared__c = true;
        payment.loan__Payment_Mode__c = pMode.id;
        payment.loan__Transaction_Amount__c  = 100;
        payment.loan__Transaction_Date__c = loan.TestHelper.systemDate;
        payment.loan__Loan_Account__c  = dummylaMonthly.id;
        payment.loan__Automated_Payment_Setup__c = aPS.id;
        payment.loan__Closure_Tolerance_Payment__c = false;
        Insert payment;
	}
    
    @isTest
    public static void UpdatePaymentModeValueSuccess(){   
        loan__Payment_Mode__c lpm = [Select Id,Name from loan__Payment_Mode__c where name ='Waived' limit 1];
        loan__Loan_Payment_Transaction__c lpt = [Select Id,loan__Payment_Mode__c from loan__Loan_Payment_Transaction__c limit 1];
        System.assert(lpt.loan__Payment_Mode__c != lpm.Id);
        
        lpt.loan__Closure_Tolerance_Payment__c = true;//LSP-379
        update lpt;
        
        loan__Loan_Payment_Transaction__c lptUpdated = [Select Id,loan__Payment_Mode__c from loan__Loan_Payment_Transaction__c where Id =:lpt.Id];
        System.assertEquals(lpm.Id, lptUpdated.loan__Payment_Mode__c);//LSP-379
    }
    
    @isTest
    public static void UpdatePaymentModeValueException(){   
        loan__Payment_Mode__c lpm = [Select Id,Name from loan__Payment_Mode__c where name ='Waived' limit 1];
        loan__Loan_Payment_Transaction__c lpt = [Select Id,loan__Payment_Mode__c from loan__Loan_Payment_Transaction__c limit 1];    
        
        Test.startTest();
        UpdatePaymentModeValue.usedOnlyForTest = true;
        lpt.loan__Closure_Tolerance_Payment__c = true;//LSP-379
        update lpt;
        Test.stopTest();
        
        loan__Loan_Payment_Transaction__c lptUpdated = [Select Id,loan__Payment_Mode__c from loan__Loan_Payment_Transaction__c where Id =:lpt.Id];
        System.assert(!(lptUpdated.loan__Payment_Mode__c == lpm.Id));        
        Loan__batch_process_log__c bpl = [select id, name, loan__message__c, loan__Log_Level__c,loan__Origin__c from Loan__batch_process_log__c limit 1];
        System.assertEquals('ERROR', bpl.loan__Log_Level__c);
        System.assertEquals('UpdatePaymentModeValue', bpl.loan__Origin__c);
    }
}