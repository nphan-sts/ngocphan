@isTest
public class MW_SendAANEmailsTest{
   testmethod static void testSendEmail(){
        
        //Creating Account
         Account acc = new Account(
            Name = 'Test',
            peer__Last_Name__c = 'LastName',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123123123'
            );
        insert acc;
        
        //Creating Application
        genesis__Applications__c app= new genesis__Applications__c(
                                            genesis__Due_Day__c = 20,
                                            genesis__Expected_First_Payment_Date__c = system.Today(),
                                            genesis__Expected_Start_Date__c = system.Today(),
                                            genesis__Funding_in_Tranches__c = true,
                                            Borrower_s_Email__c ='sadsf@sdsad.com',
                                            genesis__Account__c = acc.Id,
                                            Application_Start_DateV2__c = system.Today(),
                                            DocuSignFlag__c=true,
                                            genesis__Status__c = 'agent_verified',
                                            genesis__Draw_Period_End_Date__c = system.Today()
                                            );
        insert app;
        
        Attachment aanatt = new Attachment();
        aanatt.Name = 'Adverse Action Document '+ app.Id;
        aanatt.body = Blob.valueOf('Test AAN Send Email');
        aanatt.ParentId = app.Id;
        insert aanatt;
        
        Attachment csnatt = new Attachment();
        csnatt.Name = 'Credit Score Notice '+ app.Id;
        csnatt.body = Blob.valueOf('Test CSN Send Email');
        csnatt.ParentId = app.Id;
        insert csnatt;
      
        Test.startTest();  
        MW_SendAANEmails se = new MW_SendAANEmails(new set<Id>{app.Id},null);      
        Database.executeBatch(se,1);
        Test.stopTest();
   } 
}