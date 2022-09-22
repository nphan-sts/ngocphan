/* ****************Modification History******************
*    Created By        	 Date			Version
*1. Bhavya Maliwal        2022/04/21     Initial Version

******************Modification History******************/
@isTest
private class TestDataAccrualFixBatch{

    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    @testSetup static void setup() {

        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','20000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','40000 - INCOME');

        //Create a Fee Set

        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);

        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();



        loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
        org.loan__Disable_Triggers__c = true;
        upsert org;

        //Creating Account
        Account acc = new Account(
                Name = 'Test',
                loan__Investor__c=False,
                peer__Last_Name__c = 'TestLasName',
                cnotify__Email__c = 'abc@test.com',
                loan__SOCIAL_SECURITY_NUMBER__c = '123345987'
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

        /*pallavi*/

        //Creating Conpany
        genesis__Company__c comp = genesis.TestHelper.createCompany();
        comp.Name = 'payoff';
        update comp;


        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
                dummyAccount,
                curr,
                dummyFeeSet);

        //creating CL Product
        clcommon__CL_Product__c pr = new clcommon__CL_Product__c();
        pr.loan__Lending_Product__c = dummyLp.id;
        pr.clcommon__Product_Name__c = 'P1';
        insert pr;

        Account account_Obj = new Account(
                Name = 'Test',
                loan__Investor__c=False,
                peer__Last_Name__c = 'TestLasName',
                cnotify__Email__c = 'no-reply@testorganization.com'
        );
        Insert account_Obj;

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
        application.genesis__Interest_Rate__c = 120;
        application.genesis__Account__c = account_Obj.Id;
        application.genesis__Total_Estimated_Interest__c=500;
        application.genesis__Valid_Pricing_Flag__c=false;
        application.genesis__Probability__c=100.00;
        application.genesis__Payment_Amount__c=523.80;
        application.genesis__Company__c = comp.id;
        application.genesis__CL_Product__c = pr.id;
        insert application;
        /*pallavi*/

        loan__Loan_Account__c lacc = new loan__Loan_Account__c(
                loan__Account__c= acc.Id,
                loan__Product_Type__c='Flexible Amz Loan',
                loan__Loan_Amount__c =1000,
                loan__Loan_Product_Name__c=loanProdObj.Id,
                loan__Payment_Amount__c=100,
                loan__Previous_Installment_Date__c= system.today(),
                application__c = application.id,	//pallavi
                DataAccrualFix__c = true,	//pallavi
                loan__First_Installment_Date__c = Date.newInstance(2019, 03, 01),	//pallavi
                loan__Next_Installment_Date__c = Date.newInstance(2019, 09, 01),	//pallavi
                loan__Maturity_Date_Current__c = Date.newInstance(2021, 03, 01),	//pallavi
                loan__Frequency_of_Loan_Payment__c = '6',	//pallavi
                loan__Last_Installment_Date__c = Date.newInstance(2019, 03, 01)		//pallavi
        );
        insert lacc;
    }
    /*Created By : Bhavya Maliwal
Method name : DataAccrualFixBatchExecution
Purpose : to cover code satisfying DataAccrualFixBatch and DataAccrualFixPatch
*/
    Testmethod static void dataAccrualFixBatchExecution(){

        List<loan__Loan_Account__c> LAList1 = new List<loan__Loan_Account__c>();
        Set<Id> LoanIdset = new Set<Id>();

        for(loan__Loan_Account__c temp:[SELECT ID,
                loan__Previous_Installment_Date__c,
                loan__Account__r.cnotify__Email__c,
                loan__Loan_Product_Name__r.name,
                loan__Payment_Amount__c,
                loan__Next_Installment_Date__c,
                loan__Account__r.ID,Borrowers_First_Name__c,
                loan__Account__r.Borrower_s_Last_Name__c,
                loan__Loan_Product_Name__c,
                Application__c,
                Application__r.genesis__Monthly_Debt_Payments__c,
                loan__Accrual_Start_Date__c,
                Application__r.Loan_Origination_Date__c
        from loan__Loan_Account__c]){
            temp.loan__Payment_Amount__c = 1000;
            temp.Application__r.genesis__Monthly_Debt_Payments__c = 1100;
            temp.loan__Accrual_Start_Date__c = Date.newInstance(2019, 01, 01);
            temp.Application__r.Loan_Origination_Date__c = Date.newInstance(2019, 02, 01);
            LAList1.add(temp);

            LoanIdset.add(temp.id);
        }
        update LAList1;

        test.startTest();
        DataAccrualFixBatch job = new DataAccrualFixBatch(LoanIdset);
        Database.executeBatch(job,1);
        test.stopTest();
        loan__Loan_Account__c la=[Select id,DataAccrualFix__c from loan__Loan_Account__c limit 1];
        system.assert(la.DataAccrualFix__c);
    }


}