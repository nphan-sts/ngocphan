/***********Modification History**************
Pallavi			LOS-156			2019-11-21
Bhavya Maliwal        2022/02/02     Initial Version(test class update ) 
/********************************************/
@isTest
public class TestDeactivatebankAccounts {
    /*Updated By : Bhavya Maliwal
Method name : deactivateBankAccount
Purpose : to cover code satisfying deactivation of an bank account for application is not in Active state
			for DeactivateBankAccountsforApplications 
*/ 
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
        bank.loan__Account_Type__c = 'Saving';
        bank.loan__Bank_Name__c='ABc';
        bank.Unmasked_Bank_Account_Number__c='123456800';
        bank.loan__Account_Usage__c = 'Borrower/Investor Account';
        bank.loan__Routing_Number__c='134312345';
        //LOS-156
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
            Bank_Account__c = bank.id	//pallavi
        );      
        Insert app;
        DeactivateBankAccountsforApplications.deactivateBankAccount(app.Id);
        loan__bank_account__c lba=[Select id,loan__active__c from loan__bank_account__c where id=:bank.id];
        system.assertEquals(TRUE, lba.loan__active__c==false);
        Test.stopTest();
    }
}