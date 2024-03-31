/* ****************Modification History******************
* Modified By       Date                    JIRA Number
*   Shakul        10/3/2022          LSP-585 (Refactored Test Class)	
******************Modification History******************/
@isTest
public class TestInvestorReallocation{

    @TestSetup
    public static void testSetup(){
        //Creating Account
         Account acc = new Account(
            peer__First_Name__c ='Account',
            peer__Last_Name__c = 'Test',
            loan__Investor__c=false,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = string.valueOf(math.random()).right(9)
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
                                            Anniversary_Date__c = system.Today()+1,
                                            DocuSignFlag__c=true,
                                            genesis__Status__c = 'agent_verified',
                                            genesis__Draw_Period_End_Date__c = system.Today(),
                                            maturityDate__c = system.Today(),
                                            genesis__Maturity_Date__c = system.Today(),
                                            genesis__Term__c = 2,
                                            genesis__payment_frequency__c = 'MONTHLY'
                                            );
        insert app;

        //Creating Application Document Category
        genesis__Application_Document_Category__c document = new genesis__Application_Document_Category__c();
        document.Name = 'TIL Document';
        document.genesis__Active__c = true;
        document.genesis__Application__c = app.Id;
        insert document;
    }

    /*Created By: Shakul Siddharth
      Purpose: To test logic for Investor Reallocation class*/
    public static testMethod void testInvReAlloc(){
        Test.startTest();
        genesis__Applications__c testApp = [SELECT id FROM genesis__Applications__c LIMIT 1];
        InvestorReallocation.ResetDoc(testApp.id);
        Test.stopTest();
        genesis__Applications__c assertApp = [SELECT id, Anniversary_Date__c FROM genesis__Applications__c WHERE id =: testApp.id];
        System.assertEquals(null, assertApp.Anniversary_Date__c);
    }
}