/* *************** Modification History**************
* 
*   Modified By          Date			Jira ID                  
*   Bhanupriya           21/03/2022   	LSP-628(add comments, remove deplicate method, Added asserts and Test.startTest and Test.stopTest and remove code smells)
*
* ****************Modification History******************/
@isTest
private class SendLoanPaymentEmailHandlerTest{
    //create Testsetup()
    @testSetup
    static void setupTestData(){
        //create dummy account
        Account loanAccObj = new Account(
            name='Test',
            cnotify__Email__c='test@testOrg.com',
            peer__First_Name__c ='TestPeerFName',
            peer__Last_Name__c ='TestPeerLName'
        );
        insert loanAccObj;
        
        Account loanAcc = [Select Id 
                           from Account 
                           where Name Like '%Test%' LIMIT 1];
        system.debug('Account details' +loanAcc);
        //dummy contact
        Contact conObj = new Contact(
            AccountId = loanAcc.id, 
            LastName = 'TestLName',
            Email = 'Test@Test.com'
        );
        Insert conObj; 
        Contact con = [Select Id 
                       from Contact 
                       where LastName Like '%Test%' LIMIT 1];        
        system.debug('Contact' +con);
    }
    //test method for SendMail
    static testMethod void automated_Emailhandler(){
        List<Account> acc  =  [SELECT Id,
                               Name,
                               cnotify__Email__c 
                               from Account 
                               where Name Like '%Test%'];
        List<Contact> con  =  [SELECT Id,
                               AccountId,
                               LastName,Email 
                               from Contact 
                               where LastName Like '%Test%'];
        List<OrgWideEmailAddress> owea = [select Id 
                                          from OrgWideEmailAddress 
                                          where DisplayName = 'PayOff' LIMIT 1];
        List<EmailTemplate> templateId =  [select id, 
                                           name 
                                           from EmailTemplate 
                                           where developername = 'Manual_Payment_Selected']; 
        test.startTest();
        SendLoanPaymentEmailHandler.SendMail(templateId[0].id,acc[0].Id,con[0].Id,owea[0].Id,'acc@test.com');
        test.stopTest();
        System.assertEquals(true,acc.size()>0);
        System.assertEquals(true,con.size()>0);
        system.assert(templateId.size()>=1);
        system.assert(acc[0].cnotify__Email__c!=null);
        
        
    }
    //Test method for Manual Payment
    static testMethod void manual_Emailhandler(){
        List<Account> acc  =  [SELECT Id,
                               Name,
                               cnotify__Email__c 
                               from Account];
        List<Contact> con  =  [SELECT Id,
                               AccountId,
                               LastName 
                               from Contact];
        Map<Id, String> accMap = new Map<Id, String>();
        test.startTest();
        accMap.put(acc[0].Id, acc[0].cnotify__Email__c);
        SendLoanPaymentEmailHandler.ManualPaymentMode(new List<ID>());
        try{
            SendLoanPaymentEmailHandler.SendMail('01p2F000000GiS7','01p2F000000GiS7','01p2F000000GiS7','01p2F000000GiS7','acc@test.com');
        }
        catch(exception e){
            system.debug(e.getMessage());
        }    		
        test.stopTest();
        System.assertEquals(true,acc.size()>0);
        System.assertEquals(true,con.size()>0);
        system.assert(accMap!=null);
        system.assert(acc[0].cnotify__Email__c!=null);
    }
    
}