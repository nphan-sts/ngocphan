@isTest
public class TestHelperUtility{
   testmethod static void method1(){
       Date currentSystemDate = Date.newInstance(2016,03,12);  //Saturday
       Date currentSystemDate1 = Date.newInstance(2016,03,10);
       String message = 'Test message';
       String origin ='Test';
       Test.startTest();
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
        
        list<Attachment> attachments = new list<Attachment>();
        Attachment att = new Attachment();
        att.ParentId = acc.id;
        att.Name = 'Credit Score Notice';
        att.Body = Blob.valueOf('Test Attachment');
        attachments.add(att);
        Database.SaveResult[] srList = Database.insert(attachments, false);
        
        HelperUtility.getNextOriginationDate(currentSystemDate);
        HelperUtility.getNextOriginationDate(currentSystemDate1);
        HelperUtility.createLog(message,origin,currentSystemDate);
        HelperUtility.createLogs(srList,origin);
        Test.stopTest();
       
   }
}