/* ****************Modification History******************
*    Created By        	 Date			Version
*1. Bhavya Maliwal        2022/03/01     LSP-612 Initial Version,method name update, added assert, code modification as per validations

******************Modification History******************/
@isTest
public class TestHelperUtility{
    /*Created By : Bhavya Maliwal
Method name : helperUtilityOriginationDateCreateLog
Purpose : to cover code satisfying getNextOriginationDate,createLog,createLogs method
*/
    testmethod static void helperUtilityOriginationDateCreateLog(){
        Date currentSystemDate = Date.newInstance(2016,03,12);  //Saturday
        Date currentSystemDate1 = Date.newInstance(2016,03,10);
        String message = 'Test message';
        String origin ='Test';
        Test.startTest();
        //Creating Account
        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            peer__Last_Name__c='TestLName2',
            loan__SOCIAL_SECURITY_NUMBER__c = '123123123'
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
        
        Date result=HelperUtility.getNextOriginationDate(currentSystemDate);
        Date res=HelperUtility.getNextOriginationDate(currentSystemDate1);
        HelperUtility.createLog(message,origin,currentSystemDate);
        HelperUtility.createLogs(srList,origin);
        Test.stopTest();
        system.assertEquals(true, result==currentSystemDate+1);
        system.assertEquals(true, res==currentSystemDate-1);
    }
}