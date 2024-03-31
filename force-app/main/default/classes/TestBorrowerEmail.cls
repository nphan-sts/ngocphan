/* ****************Modification History******************
*    Created By        	 Date			Version
*1. Bhavya Maliwal        2022/03/02     LSP-626 Initial Version, modified code for validation errors,added assert,updated code

******************Modification History******************/
@isTest
Public class TestBorrowerEmail{
    /*Created By : Bhavya Maliwal
Method name : updateBorEmail
Purpose : to cover code satisfying Borrower's email update if email is null
*/
    TestMethod static void updateBorEmail(){
        Test.startTest();
        loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
        org.loan__Disable_Triggers__c = true;
        upsert org;
        System.assertEquals(true,org.loan__Disable_Triggers__c,'Trigger is Active');
        System.debug('=========trigger==========='+org.loan__Disable_Triggers__c);
        
        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            peer__Last_Name__c='TestLName2',
            cnotify__Email__c='test@qa.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123123123'
        );
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
        List<Id> appIDlist = new List<Id>();
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
        
        appIDlist.add(app.id); 
        System.debug('==========appIDList=========='+appIDlist);
        System.debug('==========appIDList=========='+app.Borrower_s_Email__c);    
        BorrowerEmail.getBorrowerEmail(appIDlist);
        Test.stopTest();
        genesis__Applications__c ap= [Select id,Borrower_s_Email__c from genesis__Applications__c LIMIT 1];
        System.assert(ap.Borrower_s_Email__c!=null);
    }
}