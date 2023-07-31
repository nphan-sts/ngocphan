/* ****************Modification History******************
 * Created By        Date          JIRA number
 *1. Pallavi        2020/09/22     CRM-878(KBA fail interaction MW - FE - CLS change to add the button)
 ******************Modification History******************/
@isTest
public class TestManualKBApass {
    
    @testSetup
    static void setup(){
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
        Contact c = new Contact(AccountId = acc.id,
                                LastName = 'name',
                                FirstName = 'test',
                                Email = 'abc@happymoney.com');
        insert c;
        
        genesis__Applications__c app = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Account__c = acc.Id,        
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'kba_fail',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c = 'Full Time',
            genesis__Loan_Amount__c=1000
        );      
        Insert app;
    }
    @isTest
    static void testMethod1(){
        genesis__Applications__c app = [select id from genesis__Applications__c];
        test.startTest();
        ManualKBApass.passKBAmanually(app.id);    
        test.stopTest();
    }
}