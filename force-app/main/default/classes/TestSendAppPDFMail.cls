/* ****************Modification History******************
* Modified By       Date                    JIRA Number
*   Shakul        22/3/2022          LSP-602 (Refactored Test Class)	
******************Modification History******************/
@isTest
public class TestSendAppPDFMail{
    @TestSetup
    public static void testSetup(){
        //Creating Account
         Account acc = new Account(
            peer__First_Name__c ='Account',
            peer__Last_Name__c = 'Test',
            loan__Investor__c= false,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = String.valueOf(math.random()).right(9)
            );
        insert acc;

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

        //Creating Application Document Category
        genesis__Application_Document_Category__c docCat = new genesis__Application_Document_Category__c();
        docCat.genesis__Application__c = app.id;
        docCat.Name = 'Generated Documents';
        docCat.genesis__Active__c = true;
        insert docCat;

        Attachment att = new Attachment();
        att.ParentId = app.id;
        att.Name = 'Credit Score Notice';
        att.Body = Blob.valueOf('Test Attachment');
        insert att;
    }

    /*Created By: Shakul Siddharth
      Purpose: To verify overall logic in SendAppPDFMail and check Deal Room Attachment creation*/
    public static testMethod void testAppCatInsert(){
        Test.startTest();
        genesis__Applications__c testApp = [SELECT id FROM genesis__Applications__c LIMIT 1];      
        SendAppPDFMail.SaveAttachment(testApp.id);
        Test.stopTest();
        List<genesis__AppDocCatAttachmentJunction__c> listofJuncs = [SELECT id FROM genesis__AppDocCatAttachmentJunction__c];
        System.assertEquals(true, listofJuncs.size()>0);
    }
}