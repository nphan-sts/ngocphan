/* ****************Modification History******************
*    Created By        	 Date			Version
*1. Bhavya Maliwal        2022/03/01     LSP-615 Initial Version, added assert,renamed method, modified code for validation errors

******************Modification History******************/
@isTest
public class TestExpirationAlertEmail{
  /*Created By : Bhavya Maliwal
Method name : expirationAlertEmaildaysbeforeExpirationDate
Purpose : to cover code satisfying days before Expiration Date
*/
    testmethod static void expirationAlertEmaildaysbeforeExpirationDate(){
       //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            peer__Last_Name__c='TestLName2',
            cnotify__Email__c = 'abc1@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123123128'
            );
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
         //Creating Application
        genesis__Applications__c app1= new genesis__Applications__c(
                                            genesis__Due_Day__c = 30,
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
        
        Expiry_Date__c exp = new Expiry_Date__c();
        exp.No_of_days_for_Expiration__c= 30;
        insert exp;
        
        test.startTest();
        ExpirationAlertEmail.daysbeforeExpirationDate();
        test.stopTest();
        genesis__Applications__c ap=[Select id,Expiration_Date_for_Email_trigger__c from genesis__Applications__c LIMIT 1];
        system.assert(ap.Expiration_Date_for_Email_trigger__c!=null);
   }
}