@isTest
public class TestSendAppPDFMail{
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
        SendAppPDFMail.SaveAttachment(app.id);
        Test.stopTest();
   } 
   testmethod static void method2(){
        
        //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
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
        
        //Creating Application Document Category
        genesis__Application_Document_Category__c docCat = new genesis__Application_Document_Category__c();
        docCat.genesis__Application__c = app.id;
        docCat.Name = 'Generated Documents';
        docCat.genesis__Active__c = true;
        insert docCat;
        
        Test.startTest();
        list<Attachment> attachments = new list<Attachment>();
        Attachment att = new Attachment();
        att.ParentId = app.id;
        att.Name = 'Credit Score Notice';
        att.Body = Blob.valueOf('Test Attachment');
        attachments.add(att);
        Database.SaveResult[] srList = Database.insert(attachments, false);
            
        for (Database.SaveResult sr : srList) {
            if(sr.isSuccess()) 
                SendAppPDFMail.sendEmail(app.id, sr.getId());
        }
        
        Test.stopTest();
   }
  
}