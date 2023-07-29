/***********Modification History**************
Pallavi         LOS-156         2019-11-21
/********************************************/
@isTest
public class TestDeactivatebankAccounts {
    
    @isTest static Void deactivateBankAccount(){
        test.startTest(); 
        Account acc = new Account(
            Name = 'Test1',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName1', 
            City__c='TestCity',
            State__c='TestState',
            ZIP_Code__c='123456'
        );
        Insert acc;
       
        
        loan__bank_account__c bank = new loan__bank_account__c();
        bank.Account_Number__c = '123456800';
        bank.loan__Account__c = acc.id;
        bank.loan__Routing_Number__c = '999999999';
        bank.loan__Account_Type__c = 'Saving';
        bank.loan__Bank_Name__c='ABc';
        bank.Unmasked_Bank_Account_Number__c='123456800';
        bank.loan__Account_Usage__c = 'Borrower/Investor Account';  //LOS-156
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
         Bank_Account__c = bank.id  //pallavi
        );      
        Insert app;
        
        /*ints__Yodlee_User_Credentials__c yodleeCred = new ints__Yodlee_User_Credentials__c();
        yodleeCred.ints__Account__c = acc.id;
        yodleeCred.ints__Yodlee_Username__c = 'xyz';
        yodleeCred.ints__Yodlee_Password__c = 'abc';
        yodleeCred.yodlee_Account_count__c = 1;
        insert yodleeCred;*/
        
        DeactivateBankAccountsforApplications.deactivateBankAccount(app.Id);
        Test.stopTest();
    }

}