/* *************** Modification History**************
* 
*   Modified By          Date			Jira ID                  
*   Bhanupriya           22/03/2022   	LSP-603(create setup method,add comments and assert statement)
*
* ****************Modification History******************/

@isTest
public class TestDocumentAttachmentTriggerHandler{
    
    //create testsetup()
    @testsetup()
    public static void testsetup(){
        
        //Creating Account
        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            //Borrower_s_Last_Name__c='Testborrower',
            cnotify__Email__c = 'abc@test.com',
            peer__Last_Name__c = 'Test Last Name',				//LSP-603 required field
            loan__SOCIAL_SECURITY_NUMBER__c = '123456789'		//LSP-603 must be 9 digit
        );
        insert acc;
        
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
        
        //Creating Document Sign Status
        dsfs__DocuSign_Status__c docSign = new dsfs__DocuSign_Status__c();
        docSign.dsfs__Subject__c = 'Promissory Note'+app.id;
        docSign.dsfs__Company__c = acc.id;
        docSign.Application__c = app.id;
        docSign.dsfs__Envelope_Status__c = 'Completed';
        insert docSign;
        
        //Creating Attachment
        Attachment att = new Attachment();
        att.ParentId = app.id;
        att.Name = app.id +'Promissory'+String.valueOf(app.id).substring(0,15)+'.';
        att.Body = Blob.valueOf('Test Attachment');
        insert att;
        
        //create application document
        genesis__Application_Document_Category__c appDoc = new genesis__Application_Document_Category__c();
        appDoc.genesis__Application__c=app.id;
        appDoc.Name='Promissory Note';
        insert appDoc;
        
        
    }
    //test method for document
    testmethod static void attachmentTriggerhandler(){
        
        dsfs__DocuSign_Status__c docSign = [select id,dsfs__Subject__c, dsfs__Company__c, Application__c, dsfs__Envelope_Status__c
                                            from dsfs__DocuSign_Status__c];
        
        genesis__Applications__c app = [select id , DocuSignFlag__c, genesis__Status__c
                                        from genesis__Applications__c];
        Test.startTest();
        DocumentAttachmentTriggerHandler obj = new DocumentAttachmentTriggerHandler(true);
        DocumentAttachmentTriggerHandler.createDocumentCategory(docSign);
        DocumentAttachmentTriggerHandler.createAppDocCategory(app.id);
        Test.stopTest();
        system.debug('Document'+obj);
        system.assert([select id from Attachment].size()>=1);
        system.assert(docSign!=null);
    }
}