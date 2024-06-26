/**
 *
 * 
 * @author - Neha
 * **/
@isTest
public class Test_DM_DataCleanUp {

    @TestSetup
    static void testData(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;

        MigrationPhase__c phase = new MigrationPhase__c();
        phase.name = 'phase1';
        phase.phase__c = 'phase1';
        insert phase;

        loan__Trigger_Parameters__c triggerParam = new loan__Trigger_Parameters__c();
        triggerParam.loan__Disable_Loan_Account_Trigger__c=true;
        insert triggerParam;

        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();

        Account a2 = MW_GlobalTestUtility.GetAccount('Investor');
        a2.peer__First_Name__c = 'Bull';
        a2.peer__Last_Name__c = 'Frank';
        a2.loan__Undeployed_Funds__c = 999999;
        a2.loan__Investor__c = true;
        insert a2;
        loan.CustomSettingsUtil.getNS();
        //Create Borrower 
        Account b1 = MW_GlobalTestUtility.GetAccount('Member');
        b1.peer__First_Name__c = 'ShoeString';
        b1.peer__Last_Name__c = 'Budget';
        insert b1;

        loan.TestHelper.systemDate = Date.today();
        Id rtId = Schema.SObjectType.loan__Office_Name__c.getRecordTypeInfosByDeveloperName().get('Root_Branch').getRecordTypeId();

        loan__Currency__c curr = loan.TestHelper.createCurrency();
        loan__office_Type__c testBranchType = new loan__Office_Type__c(Name='Data Migration',
                loan__Office_Type_Short_Code__c='TestSC' );
        insert testBranchType;

        loan__MF_Account__c a1 = loan.TestHelper.createMFAccount('TestAccountForOffice', '10000 - ASSETS');

        loan__Branch_Location__c testLoc = new loan__Branch_Location__c(Name='Data Migration',
                loan__Address_Line_1__c = 'Add1',
                loan__Address_Line_2__c = 'Add2',
                loan__State__c = 'MH',
                loan__Phone__C = '32323232',
                loan__Zip_code__c = 33333
        );
        insert testLoc;

        loan__Office_Name__c dummyOffice = new loan__Office_Name__c(Name='PayOff Inc.',
                loan__Office_Location__c = testLoc.ID,
                loan__Office_Short_Name__c = 'XXXCSN',
                loan__Cash_Account__c = a1.Id,
                loan__Check_Account__c = a1.Id,
                loan__Bank_Account_Checks__c = a1.Id,
                loan__Inward_Check_Clearance_Account__c = a1.Id,
                loan__Outward_Check_Clearance_Account__c= a1.Id,
                loan__Profit_and_Loss_Account__c = a1.Id,
                loan__Loan_Schedule_tied_to_Meeting_Schedule__c = false,
                loan__Mark_Suspended_After_Days__c = 180,
                loan__State__c = 'Active',
                loan__Write_Off_Suggestion_Days__c = 90,
                loan__Office_Type__c = testBranchType.ID,
                loan__Days_in_advance_to_create_Collection_Rep__c=1,
                loan__Current_System_Date__c = Date.Today().addDays(-30),
                RecordTypeId = rtId,
                loan__Is_Branch__c=true);
        insert dummyOffice;

        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();

        loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        List<loan__Loan_Product__c> loanProductList = new List<loan__Loan_Product__c>();
        loan__Loan_Product__c simpleLP = Post_actualObj_TestHelper.createLoanProduct('Auto Payer',dummyOffice,
                dummyAccount, curr, dummyFeeSet, 'Loan');
        loanProductList.add(simpleLP);

        loan__Loan_Product__c difficultLP = DM_TestHelper.createLoanProduct('Difficult Loan',dummyOffice,
                dummyAccount, curr, dummyFeeSet, 'Loan');
        loanProductList.add(difficultLP);

        loan__Loan_Product__c errorLp = DM_TestHelper.createLoanProduct('Simple Loan',dummyOffice,
                dummyAccount, curr, dummyFeeSet, 'Loan');
        loanProductList.add(errorLp);


        insert loanProductList;

        loan__Payment_Mode__c pMode = new loan__Payment_Mode__c(name='Cash');
        insert pMode;

        loan__Bank_Account__c bankAccount = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
                loan__Active__c = true,
                loan__Bank_Name__c = 'Some Bank',
                loan__Routing_Number__c = '999999999',
                loan__Account_Type__c = 'Savings',
                loan__Account_Usage__c = 'Borrower/Investor Account',
                loan__Account__c = b1.id,
                Unmasked_Bank_Account_Number__c = '12345');	//pallavi
        insert bankAccount;


        List<loan__Loan_Account__c> dmLoanList = new List<loan__Loan_Account__c>();
        loan__Loan_Account__c dmloan = Post_actualObj_TestHelper.createDMLOC(simpleLP,0.0,b1,dummyFeeSet,dummyOffice,pMode,5);
        dmloan.DM_Migration_Phase__c = 'phase1';
        dmloan.isMigrated__c = true;
        dmLoanList.add(dmloan);
        insert dmLoanList;

        DM_Primary_Objects_Validation__c ab = new DM_Primary_Objects_Validation__c(CL_Contract__c = dmloan.id,
                DM_Validation_Status__c = 'Failed');
        insert ab;

        dmloan.DM_Primary_Objects_Validation__c = ab.id;
        update dmloan;

        loan__Loan_Disbursal_Transaction__c ldt =  Post_actualObj_TestHelper.fundLoan(dmLoan, Date.Today(), pmode,bankAccount);
        insert ldt;

        loan__Disbursal_Txn_Distribution__c dtd = Post_actualObj_TestHelper.createDTD(ldt);
        insert dtd;

        loan__Loan_account_Due_Details__c bill =  Post_actualObj_TestHelper.createUnpaidDue(dmLoan, 6500.00);
        insert bill;

        loan__Repayment_Schedule_Summary__c dm_RSS = Post_actualObj_TestHelper.CreateRSSData(dmLoan, 600.00);
        insert dm_RSS;

        loan__Charge__c charge =  Post_actualObj_TestHelper.createUnpaidCharge(dmLoan, dummyFee, 100.00 );
        insert charge;

        loan__Repayment_Schedule__c amzSchedule = Post_actualObj_TestHelper.CreateAmzScheduleData(dmLoan, 1000.00);
        insert amzSchedule;

        loan__Automated_Payment_Setup__c aps =  Post_actualObj_TestHelper.createAutomatedPaymentSetup('DO it later', '', bankAccount,
                dmLoan, '', pMode, Date.Today(),1);
        insert aps;
        System.debug('aps----' + aps);

        loan__Loan_Payment_Transaction__c lpt = Post_actualObj_TestHelper.createLoanPayment(dmLoan.Id, 10000.00,Date.today(),aPS, pMode, null);
        insert lpt;

        loan__Due_Payment__c due = Post_actualObj_TestHelper.createDP(lpt);
        insert due;

        loan__Interest_Posting_Transaction__c ipt = Post_actualObj_TestHelper.create_InterestPostingTransaction(dmLoan.Id,system.Today(),12758.00,1598.00,8900.90,890.00,false,system.Today(),234500.00,system.Today().addDays(-5),
                'Regular',true,false,system.today().addDays(-10),system.today().addDays(30));
        insert ipt;

        clcommon__Accounting_Entry__c accountingEntry = new clcommon__Accounting_Entry__c(clcommon__Transaction_Creation_Date__c=System.Today(),clcommon__Transaction_Date__c=System.Today());
        insert accountingEntry;

        loan__Investor_Loan__c dmInvOrder = Post_actualObj_TestHelper.createInvestmentOrder(a2,dmLoan,70000);
        insert dmInvOrder;

        loan__Investor_Loan_Account_Txns__c dmILT = Post_actualObj_TestHelper.createDMInvestorPaymentTxn(dmInvOrder,11000.00,1100,300,lpt.Id);
        insert dmILT;

        loan__Multi_Step_Loan_Setup__c dmRate = Post_actualObj_TestHelper.createMSLS(dmLoan);
        insert dmRate;

    }//END testData
    @isTest
    static void testMehod_1(){

        User u = [Select Id from User limit 1];
        system.runAs(u){
            Test.startTest();
            DM_DataCleanUp dm = new DM_DataCleanUp();
            Database.executeBatch(dm,1);
            Test.stopTest();
        }//END system.runAs(u)
    }//END RunJobTemp_IsTest 
}