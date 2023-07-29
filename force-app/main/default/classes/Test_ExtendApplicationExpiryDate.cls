/* ****************Modification History******************
 * Created by       Date        JIRA number
 *     Pallavi      2020/07/13  CRM-744 Batch Job to Extend Expiration Date for All Applications in ADVP Status
 ******************Modification History******************/
@isTest
public class Test_ExtendApplicationExpiryDate {

    @isTest
    static void testMethod1(){
        CL_Document__c doc = new CL_Document__c();
        doc.Doc1__c = 'Credit File';
        doc.Doc2__c = 'Til File';
        insert doc;

        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');

        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount,dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);

        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();

        //Creating Account
        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c = True,
            Amount_Invested__c = 1200,
            Number_Of_Applications_Invested__c =3,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123',
            Investor_Code__c = 'TNA'
            );
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
        TLO_URL_Config__c tlo = new TLO_URL_Config__c();
        tlo.TLO_URL__c = 'https://doppio-leads-dev.int.payoff.com/';
        tlo.TLOURLappname__c = 'verification';   
        insert tlo;
        
        genesis__Applications__c app= new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            Borrower_s_Email__c = null,
            Bureau_SSN__c ='21616590',
            Loan_Doc_Signed_On__c = Date.newInstance(2013,12,13),
            Anniversary_Date__c = null,
            Investor__c = acc.id,
            Invested_Amount__c =1000,
            genesis__Account__c = acc.Id,
            genesis__loan_amount__c = 1000,
            DocuSignFlag__c=true,
            genesis__Status__c = 'agent_document_verification_pending',
            genesis__term__c = 36,
            genesis__payment_frequency__c = 'Monthly',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Application_Start_DateV2__c = System.today()
            );
        insert app;
        System.debug('created date ' + app.createdDate);
        ExtendApplicationExpiryDate_BatchJob b = new ExtendApplicationExpiryDate_BatchJob();
        database.executeBatch(b,1);
    }
}