/* ****************Modification History******************************************************************
 * Last Modified by    Date    		JIRA number
 *     Pallavi      2020/06/09    	CRM-655(Bug - AAN sent to Authorized contact)(improving the test coverage)
 ******************Modification History*****************************************************************/
@isTest
public class TestAttachPDFtoApplication{
   testmethod static void method1(){
        
        //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');


       /*CRM-655*/
        Contact c = new Contact(Lastname = 'AB',
                                Firstname = 'CD',
                                Email = 'ab@abc.com',
                                Accountid = acc.id);

        insert c;

        Contact c1 = new Contact(Lastname = 'BA',
                                Firstname = 'CD',
                                Email = 'ba@abc.com',
                                Accountid = acc.id);

        insert c1;
        /*CRM-655*/
        
        //Creating Application
        genesis__Applications__c app= new genesis__Applications__c(
                                            genesis__Due_Day__c = 20,
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
        insert app;
        System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');
        
        Test.startTest();        
        AttachPDFtoApplication.SaveAttachment(app.id,true,true);
        Test.stopTest();
   } 
}