/* ****************Modification History******************
*    Created By        	 Date			Version
*1. Bhavya Maliwal        2022/02/23    LSP:572 Initial Version, method Name modified, Validation errors Corrected

******************Modification History******************/
@isTest
public class TestManualAttachPDFtoApplication{
    /*Created By : Bhavya Maliwal
Method name : ManualAttachPDFtoApplication_PositiveScenario
Purpose : to cover code satisfying ManualAttachPDFtoApplication
*/
    testmethod static void ManualAttachPDFtoApplication_PositiveScenario(){
        
        //Creating Account
        Account acc = new Account(
            Name = 'Test',
            peer__Last_Name__c='TestLName2',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123123123'
        );
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
        /*pallavi (LOS-123) correcting the Test class*/
        Account acc1 = new Account(
            Name = 'Test',
            loan__Investor__c=True,
            Amount_Invested__c = 1200,
            peer__Last_Name__c='TestLName2',
            Number_Of_Applications_Invested__c =3,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123123121',
            Investor_Code__c = 'TNA'
        );
        insert acc1;
        
        CL_Document__c doc = new CL_Document__c();
        doc.Doc1__c = 'Credit File';
        doc.Doc2__c = 'Til File';
        insert doc;
        /*pallavi (LOS-123) correcting the Test class*/
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
            genesis__Draw_Period_End_Date__c = system.Today(),
            investor__c= acc1.id,   //pallavi (LOS-123) correcting the Test class
            Invested_Amount__c = 100, //pallavi (LOS-123) correcting the Test class
            genesis__loan_amount__c = 100 //pallavi (LOS-123) correcting the Test class
        );
        insert app;
        System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');
        
        Test.startTest();        
        ManualAttachPDFtoApplication.attachPDFWebService(app.id,true,true);
        ManualAttachPDFtoApplication.ManualTILgenerate(app.id);
        Test.stopTest();
    } 
}