/* ****************Modification History******************************************
 * Created By        Date          JIRA number
 *1. Pallavi        2020/08/13     CRM-755(Make NeoVerify Initiated Manually)
 *      
 ******************Modification History******************************************/
@isTest
public class Test_Call_NeoVerifyTxnsCalloutQueue {
	
    @isTest
    public static void testmethod1(){
        
        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        
        //Dummy GLAccount
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        
        //Dummy Office insert
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr);                                    
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        
        //creating CL Product
        clcommon__CL_Product__c pr = new clcommon__CL_Product__c();
        pr.loan__Lending_Product__c = dummyLp.id;
        pr.clcommon__Product_Name__c = 'P1';
        insert pr;
        
        Date currentSystemDate = (new loan.GlobalLoanUtilFacade().getCurrentSystemDate());
        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com'
        );
        Insert acc;
         
        //Create Application
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
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Account__c = acc.Id;
        application.genesis__Total_Estimated_Interest__c=500;
        application.genesis__Valid_Pricing_Flag__c=false;
        application.genesis__Probability__c=100.00;
        application.genesis__Payment_Amount__c=523.80;
        application.genesis__CL_Product__c = pr.id;
        application.Application_Start_DateV2__c = currentSystemDate.adddays(-30);
        insert application;
        
        Test.startTest();
        String res = Call_NeoVerifyTransactionsCalloutQueue.callMWNeoVerifyTransactions(application.id);
        Test.stopTest();
    }
}