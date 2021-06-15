@isTest
public class TestDocumentAttachmentTriggerHandler{
   testmethod static void method1(){
       //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            //Borrower_s_Last_Name__c='Testborrower',
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
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
        att.Name = app.id +'Promissory'+app.id+'.';
        att.Body = Blob.valueOf('Test Attachment');
        insert att;
        
        genesis__Application_Document_Category__c appDoc = new genesis__Application_Document_Category__c();
        appDoc.genesis__Application__c=app.id;
        appDoc.Name='Promissory Note';
        insert appDoc;
        
        Test.startTest();
        DocumentAttachmentTriggerHandler obj = new DocumentAttachmentTriggerHandler(true);
        DocumentAttachmentTriggerHandler.createDocumentCategory(docSign);
        DocumentAttachmentTriggerHandler.createAppDocCategory(app.id);
        Test.stopTest();
    }
}