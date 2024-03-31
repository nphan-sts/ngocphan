/* ****************Modification History******************
*    Created By        	 Date			Version
*1. Bhavya Maliwal        2022/07/07     Initial Version

******************Modification History******************/
@isTest
private class TestCustomBankAccountHandler {
    @testSetup
    static void setup() {
        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');

        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        system.debug(' Fee Junctions' + dummyFeeJunction);
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();

        loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
        org.loan__Disable_Triggers__c = true;
        upsert org;

        //Creating Account
        Account acc = MW_GlobalTestUtility.createTestAccount('Test', 'Test', 'abc@test.com', '123456789');
        insert acc;

        Account acc2 = MW_GlobalTestUtility.createTestAccount('Test2', 'Test2', 'abc2@test.com', '123456780');
        insert acc2;

        loan__Loan_Product__c loanProdObj = new loan__Loan_Product__c(name = 'TestProduct');
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

        Contact a1 = new Contact(LastName = 'TestACH');
        a1.AccountId = acc.Id;
        insert a1;

        Contact a2 = new Contact(LastName = 'TestACH2');
        a2.AccountId = acc2.Id;
        insert a2;

        loan__Bank_Account__c ba = MW_GlobalTestUtility.GetBankAccount();
        ba.loan__Contact__c = a1.id;
        ba.loan__Account__c = acc.id;
        insert ba;

        loan__Bank_Account__c ba2 = MW_GlobalTestUtility.GetBankAccount();
        ba2.loan__Bank_Account_Number__c = 'XXXXXXXX1210';
        ba2.Unmasked_Bank_Account_Number__c = '123450';
        ba2.loan__Contact__c = a2.id;
        ba2.loan__Account__c = acc2.id;
        insert ba2;

        genesis__Applications__c app = getApplication();
        app.genesis__Account__c = acc.Id;
        app.Bank_Account__c = ba.Id;
        insert app;

        genesis__Applications__c app2 = getApplication();
        app2.genesis__Account__c = acc2.Id;
        app2.genesis__Status__c = 'offer_accepted';
        app2.genesis__Loan_Amount__c = 1000;
        app2.Bank_Account__c = ba2.Id;
        insert app2;

        loan__Payment_Mode__c pMode1 = new loan__Payment_Mode__c(Name = 'ACH');
        insert pMode1;

        List<loan__Bank_Account__c> banks = [
            SELECT id
            FROM loan__Bank_Account__c
            WHERE loan__Account_usage__c = 'Borrower/Investor Account'
        ];

        system.debug('Bank Account' + banks);
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        system.debug('Global Loan util' + util);

        loan__Loan_Account__c lacc = getCLContract();
        lacc.loan__Account__c = acc.Id;
        lacc.loan__Contact__c = a1.ID;
        lacc.loan__Loan_Product_Name__c = loanProdObj.Id;
        lacc.lead_guid__c = 'TestClassGuid0';
        insert lacc;
        loan__Automated_Payment_Setup__c automatedPaymentSetup = getAPS();
        automatedPaymentSetup.loan__Bank_Account__c = banks[0].id;
        automatedPaymentSetup.loan__CL_Contract__C = lacc.Id;
        automatedPaymentSetup.loan__Payment_Mode__c = pMode1.Id;
        insert automatedPaymentSetup;

        loan__Loan_Account__c lacc2 = getCLContract();
        lacc2.loan__Account__c = acc2.Id;
        lacc2.loan__Contact__c = a2.ID;
        lacc2.loan__Loan_Product_Name__c = loanProdObj.Id;
        lacc2.lead_guid__c = 'TestClassGuid2';
        insert lacc2;

        loan__Automated_Payment_Setup__c automatedPaymentSetup2 = getAPS();
        automatedPaymentSetup2.loan__Bank_Account__c = banks[1].id;
        automatedPaymentSetup2.loan__CL_Contract__C = lacc2.Id;
        automatedPaymentSetup2.loan__Payment_Mode__c = pMode1.Id;
        insert automatedPaymentSetup2;

        MW_Settings__c mwSettings = MW_Settings__c.getOrgDefaults();
        mwSettings.Delete_Bank_Account_EndpointURL__c = 'testapi.com';
        mwSettings.LEADS_FE_EndpointURL__c = 'testapi.com';
        insert mwSettings;
    }
    /*Created By : Bhavya Maliwal
Method name : inactiveAPS
Purpose : to cover code satisfying if Bank Account gets inactive the corresponding APS gets inactive ; for CustomBankAccountHandler
*/
    @isTest
    static Void inactiveAPS() {
        test.startTest();
        loan__Bank_Account__c bankAccount = [
            SELECT id
            FROM loan__Bank_Account__c
            WHERE loan__Account_usage__c = 'Borrower/Investor Account'
            LIMIT 1
        ];

        bankAccount.loan__Active__c = false;
        bankAccount.Account_Number__c = 'Testing';
        update bankAccount;
        test.stopTest();
        loan__Automated_Payment_Setup__c apscheck = [
            SELECT id, loan__Active__c
            FROM loan__Automated_Payment_Setup__c
            WHERE loan__Bank_Account__c = :bankAccount.id
            LIMIT 1
        ];
        delete bankAccount;
        system.assert(!apscheck.loan__Active__c);
    }

    @isTest
    static Void testingDeleteBankAccount() {
        test.startTest();
        List<loan__Bank_Account__c> bankAccount = [
            SELECT id
            FROM loan__Bank_Account__c
            WHERE loan__Account_usage__c = 'Borrower/Investor Account' AND loan__Active__c = TRUE
        ];

        List<loan__Automated_Payment_Setup__c> apsList = [
            SELECT id
            FROM loan__Automated_Payment_Setup__c
            WHERE loan__Active__c = TRUE
        ];
        system.assert(apsList.size() > 0);

        delete bankAccount;

        test.stopTest();

        List<loan__Bank_Account__c> result = [
            SELECT id, loan__Active__c
            FROM loan__Bank_Account__c
            WHERE loan__Account_usage__c = 'Borrower/Investor Account' AND loan__Active__c = TRUE
        ];

        List<loan__Automated_Payment_Setup__c> apsListResult = [
            SELECT id, loan__Active__c
            FROM loan__Automated_Payment_Setup__c
            WHERE loan__Active__c = TRUE
        ];

        system.assert(result.size() == 0);
        system.assert(apsListResult.size() == 0);
    }

    static genesis__Applications__c getApplication() {
        return new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'funded',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c = 'Full Time',
            genesis__Loan_Amount__c = 1000
        );
    }

    static loan__Loan_Account__c getCLContract() {
        loan__Loan_Account__c lacc = new loan__Loan_Account__c(
            loan__Product_Type__c = 'Flexible Amz Loan',
            loan__Loan_Amount__c = 5000,
            loan__Payment_Amount__c = 439.70,
            loan__Principal_Remaining__c = 4243.60,
            loan__First_Installment_Date__c = Date.today() + 3,
            loan__Next_Installment_Date__c = Date.today() + 3,
            loan__Maturity_Date_Current__c = Date.today() + 365,
            loan__Frequency_of_Loan_Payment__c = 'Monthly',
            loan__last_billed_amount__c = null,
            loan__Last_Installment_Date__c = Date.today() + 365,
            loan__Loan_Status__c = 'Active - Good Standing',
            loan__Interest_Rate__c = 10,
            loan__Term_Cur__c = 12,
            Skipped_a_pay_Date__c = null,
            Skipped_a_Pay__c = false,
            loan__Disbursal_Date__c = Date.newInstance(2020, 5, 30),
            loan__Pmt_Amt_Cur__c = 500,
            loan__Pre_Bill_Days__c = 3
        );

        return lacc;
    }

    static loan__Automated_Payment_Setup__c getAPS() {
        return new loan__Automated_Payment_Setup__c(
            loan__Active__c = true,
            loan__Frequency__c = 'Monthly',
            loan__Type__c = 'ONE TIME',
            loan__Debit_Date__c = date.today()
        );
    }
}