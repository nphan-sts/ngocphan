/* ****************Modification History******************************************************************
 * Last Modified by    Date    		JIRA number
 *     Pallavi      2020/06/09    	CRM-655(Bug - AAN sent to Authorized contact)(improving the test coverage)
 * 	Bhanupriya		2022/03/01		LSP-553(Create testsetup method , add required fields,assert statement )
 ******************Modification History*****************************************************************/
@isTest
public class TestAttachPDFtoApplication{
    
    //Create testSetup() method
    @testSetup
    public static void testSetup(){
        
        //Creating Account
         	Account acc = new Account(
                                Name = 'Test',
                                loan__Investor__c=False,
                                cnotify__Email__c = 'abc@test.com',
                                peer__Last_Name__c = 'Test Last Name',		//LSP-553 required field
                                loan__SOCIAL_SECURITY_NUMBER__c = '123456789' 	//LSP-553 must be 9 digit
                                );
        	insert acc;

       /*CRM-655*/
        //create dummy contact
        	Contact c = new Contact(Lastname = 'AB',
                                Firstname = 'CD',
                                Email = 'ab@abc.com',
                                Accountid = acc.id);

        	insert c;
		//create contact
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
        
    }
    //test method
    testmethod static void adverseattachment(){
        
        	genesis__Applications__c app = [select id,genesis__Status__c,
                                            Borrower_s_Email__c,genesis__Due_Day__c
                                           from genesis__Applications__c where genesis__Status__c = 'agent_verified'];
        	 Test.startTest();        
        	 AttachPDFtoApplication.SaveAttachment(app.id,true,true);
        	 Test.stopTest(); 
      		 System.assertNotEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');   
        	 system.assert([select id from genesis__Applications__c].size()>=1);
        	
    }
}