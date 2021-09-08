/* ****************Modification History******************
 * Created By        Date          JIRA number
 *      
 *      1. Neha          2021/01/10        LOP-4
 * Modified By        Date          JIRA number
 *      1. Pallavi       2021/01/25        LOP-4
 *      
 ******************Modification History******************/
@isTest
public class TestDeactivateYodleeAccounts {
    
    @isTest static Void deactivateBankAccount(){
        loan.TestHelper.createSeedDataForTesting();
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        genesis__Org_Parameters__c cso = new genesis__Org_Parameters__c(genesis__Disable_Triggers__c = true);
        insert cso;
        
        ints__Yodlee_Cobrand_Credentials__c ycc = new ints__Yodlee_Cobrand_Credentials__c();
        ycc.ints__APP_ID__c = '10003600';
        //ycc.ints__Application_Key__c = 
        //ycc.ints__APP_Secret__c =
        //ycc.ints__Auto_Register_User__c = 
        //ycc.ints__Callback_URL__c =
        ycc.ints__Cobrand_id__c = '4410018556';
        ycc.ints__Cobrand_Password__c = 'fpoie176bPIOY!T';
        ycc.ints__Cobrand_Username__c = 'payoff';
        ycc.FromDate_Attribute_value__c = 1100;
        ycc.ints__Node_URL__c = 'https://yieapnodestage.yodlee.com/authenticate/payoff/?channelAppName=yisandbox';
        ycc.ints__Rest_URL__c = 'https://stage.api.yodlee.com/ysl/payoff/v1/';
        ycc.ints__Soap_URL__c = 'https://stage.api.yodlee.com/ysl/payoff/v1/';
        
        insert  ycc;
        
        
        Account acc = MW_GlobalTestUtility.GetAccount('Member');
        Insert acc;
        
        ints__Yodlee_User_Credentials__c userCred = new ints__Yodlee_User_Credentials__c();
        userCred.ints__Account__c = acc.Id;
        userCred.ints__Yodlee_Username__c = 'testuserName';
        userCred.ints__Yodlee_Password__c = 'testpassword';
        userCred.yodlee_Account_count__c  =1;
        insert userCred;
        
        loan__bank_account__c bank = new loan__bank_account__c();
        bank.Account_Number__c = '123456800';
        bank.loan__Routing_Number__c = '999999999';
        bank.loan__Account__c = acc.id;
        bank.loan__Account_Type__c = 'Saving';
        bank.loan__Bank_Name__c='ABc';
        bank.Unmasked_Bank_Account_Number__c='123456800';
        bank.loan__Account_Usage__c = 'Borrower/Investor Account';  //LOS-156
        bank.loan__Bank_Account_Number__c = acc.Id;
        insert bank;
        
         genesis__Applications__c app = new genesis__Applications__c(
         genesis__Due_Day__c = 20,
         genesis__Expected_First_Payment_Date__c = system.Today(),
         genesis__Expected_Start_Date__c = system.Today(),
         genesis__Funding_in_Tranches__c = true,
         genesis__Account__c = acc.Id,        
         Application_Start_DateV2__c = system.Today(),
         genesis__Status__c = 'Decline_Manual_Review',
         genesis__Draw_Period_End_Date__c = system.Today(),
         Employment_Status__c = 'Full Time',
         genesis__Loan_Amount__c=1000,
         Bank_Account__c = bank.id 
        );      
        Insert app;
        
        Yodlee_User_Account__c Yodleeacc = new Yodlee_User_Account__c();
        Yodleeacc.Account_Number__c = 'xxxx3xxx'; 
        Yodleeacc.Account_Type__c = 'SAVINGS';
        Yodleeacc.Available_Balance__c = 65454.78;
        Yodleeacc.Current_Balance__c = 904478;
        Yodleeacc.Status__c = 'ACTIVE';
        Yodleeacc.verified__c = false;
        Yodleeacc.Yodlee_Account__c = acc.Id;
        Yodleeacc.Yodlee_Application__c = app.Id;
        Yodleeacc.YodleeBankAccountId__c = '44473248';
        Yodleeacc.Name = 'DagBank';
        insert Yodleeacc;
        
        List<Yodlee_User_Transaction__c> yodleeTxn = new List<Yodlee_User_Transaction__c>();
        
        Yodlee_User_Transaction__c yodlee = new Yodlee_User_Transaction__c();
        yodlee.Balance__c = 100;
        yodlee.Category__c = 'Test';
        yodlee.Yodlee_Account__c = acc.Id;
        yodlee.YodleeBankAccountId__c = '10563602';
        yodlee.Yodlee_Application__c = app.id;
        
        Yodlee_User_Transaction__c yodlee1 = new Yodlee_User_Transaction__c();
        yodlee1.Balance__c = 100;
        yodlee1.Category__c = 'Test';
        yodlee1.Yodlee_Account__c = acc.Id;
        yodlee1.YodleeBankAccountId__c = '10563603';
        yodlee1.Yodlee_Application__c = app.id;
        
        Yodlee_User_Transaction__c yodlee2 = new Yodlee_User_Transaction__c();
        yodlee2.Balance__c = 1000;
        yodlee2.Category__c = 'Test';
        yodlee2.Yodlee_Account__c = acc.Id;
        yodlee2.YodleeBankAccountId__c = '10563602';
        yodlee2.Yodlee_Application__c = app.id;
        
        Yodlee_User_Transaction__c yodlee3 = new Yodlee_User_Transaction__c();
        yodlee3.Balance__c = 1000;
        yodlee3.Category__c = 'Test';
        yodlee3.Yodlee_Account__c = acc.Id;
        yodlee3.YodleeBankAccountId__c = '10563603';
        yodlee3.Yodlee_Application__c = app.id;
        
        yodleeTxn.add(yodlee);
        yodleeTxn.add(yodlee1);
        yodleeTxn.add(yodlee2);
        yodleeTxn.add(yodlee3);
        
        insert yodleeTxn;
        /*LOP-4 update*/
        Expiry_Date__c expiryDate = new Expiry_Date__c();
        expiryDate.Application_Status_to_deactivate_Yodlee__c = 'Decline_Manual_Review,';
        expiryDate.Loan_Status_to_deactivate_Yodlee__c = 'Closed - Obligations met,';
        expiryDate.Yodlee_Acc_expiration_after__c = -1;
        insert expiryDate;
        /*LOP-4 update*/
        
        Test.setMock(HttpCalloutMock.class, new MockYodleeTransactionAPICallOut1());
               
        Test.startTest(); 
        YodleeDeactivateAccountsBatch b = new YodleeDeactivateAccountsBatch();
        
        String batchId = Database.executebatch(b,1);     
        
        /*LOP-4 update*/
        Set<String> YodleeAccId = new Set<String>();
        Set<Id> accountId = new Set<Id>();
        YodleeAccId.add(Yodleeacc.YodleeBankAccountId__c);
        accountId.add(Yodleeacc.Yodlee_Account__c);        
            
        YodleeDeactivateAccountsBatch b1 = new YodleeDeactivateAccountsBatch(YodleeAccId,accountId);
        /*LOP-4 update*/
        
        Test.stopTest();
        
        cso.genesis__Disable_Triggers__c = false;
        //update cso;

    }

}