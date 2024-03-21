/* ****************Modification History******************
* Modified By       Date                    JIRA Number
*   Shakul        15/3/2022          LSP-597 (Refactored Test Class)	
******************Modification History******************/
@isTest
public class TestUpdateAccountInfo{
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
    }

    /*Created By: Shakul Siddharth
    Purpose: To verify logic for Account's Last Updated Date from JSON Response*/
   public static testMethod void testUpdateLastDate(){
        Account testAcc = [SELECT id FROM Account LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new TestGetAccountContainerMock());
        Test.startTest();
        UpdateAccountInfo.getLastUpdate(testAcc.id);
        Test.stopTest();
        Account assertAcc = [SELECT id, Last_Update_Date__c FROM Account WHERE Id =: testAcc.Id];
        System.assertEquals('2015-09-20', assertAcc.Last_Update_Date__c);
   }
}