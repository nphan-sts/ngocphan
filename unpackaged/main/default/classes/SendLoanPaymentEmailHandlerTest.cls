/* overwrite qa branch version */
@isTest
private class SendLoanPaymentEmailHandlerTest{
  @testSetup
  static void setupTestData(){
    test.startTest();
    Account loanAccObj = new Account(
        name='Test',
        cnotify__Email__c='test@testOrg.com',
        peer__First_Name__c ='TestPeerFName',
        peer__Last_Name__c ='TestPeerLName'
    );
    insert loanAccObj;
    Account loanAcc = [Select Id from Account where Name Like '%Test%'];
    System.assertEquals(true, loanAcc!=null);
    Contact conObj = new Contact(
        AccountId = loanAcc.id, 
        LastName = 'TestLName',
        Email = 'Test@Test.com'
    );
    Insert conObj; 
    Contact con = [Select Id from Contact where LastName = 'TestLName'];
    System.assertEquals(true, con!=null);
    
    test.stopTest();
  }
  static testMethod void SendMailTest_UseCase1(){
    List<Account> acc  =  [SELECT Id,Name,cnotify__Email__c from Account where Name Like '%Test%'];
    System.assertEquals(true,acc.size()>0);
    List<Contact> con  =  [SELECT Id,AccountId,LastName,Email from Contact where LastName Like '%Test%'];
    System.assertEquals(true,con.size()>0);
    List<OrgWideEmailAddress> owea = [select Id from OrgWideEmailAddress where DisplayName = 'PayOff' LIMIT 1];
    List<EmailTemplate> templateId =  [select id, name from EmailTemplate where developername = 'Manual_Payment_Selected']; 
    SendLoanPaymentEmailHandler.SendMail(templateId[0].id,acc[0].Id,con[0].Id,owea[0].Id,'acc@test.com');
  }
  static testMethod void ManualPaymentModeTest_UseCase1(){
    List<Account> acc  =  [SELECT Id,Name,cnotify__Email__c from Account];
    System.assertEquals(true,acc.size()>0);
    List<Contact> con  =  [SELECT Id,AccountId,LastName from Contact];
    System.assertEquals(true,con.size()>0);
    Map<Id, String> accMap = new Map<Id, String>();
    accMap.put(acc[0].Id, acc[0].cnotify__Email__c);
    SendLoanPaymentEmailHandler.ManualPaymentMode(new List<ID>());
    try{
        SendLoanPaymentEmailHandler.SendMail('01p2F000000GiS7','01p2F000000GiS7','01p2F000000GiS7','01p2F000000GiS7','acc@test.com');
    }
    catch(exception e){}
  }
}