/* ****************Modification History******************
*    Created By        	 Date			Version
*1. Bhavya Maliwal        2022/03/01     LSP-616 Initial Version,renamed method, modified code for validation errors

******************Modification History******************/
@isTest
public class TestDocumentReduction{
    /*Created By : Bhavya Maliwal
Method name : documentReductionpayStubReduction
Purpose : to cover code satisfying payStubReduction
*/
    testmethod static void documentReductionpayStubReduction(){
        //Creating Account
        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            peer__Last_Name__c='TestLName2',
            cnotify__Email__c = 'abc2@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123123167'
        );
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
        //Creating Application
        genesis__Applications__c app1= new genesis__Applications__c(
            genesis__Due_Day__c = 15,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            Borrower_s_Email__c = null,
            genesis__Account__c = acc.Id,
            Application_Start_DateV2__c = system.Today(),
            DocuSignFlag__c=true,
            genesis__Status__c = 'agent_verified',
            genesis__Draw_Period_End_Date__c = system.Today()
        );
        insert app1;
        System.assertEquals(null,app1.Borrower_s_Email__c,'Borrower Email is not null');
        
        Credit_Policy__c crPolicy = new Credit_Policy__c();
        crPolicy.Net_Disposable_Income_NDI__c = '1200';
        crPolicy.Application__c =app1.id;
        insert crPolicy;
        
        test.startTest();
        DocumentReduction.payStubReduction(app1.id);
        test.stopTest();
    }
}