@isTest
public class TestTalxIntegration {
    
    @isTest
    public static void testCallTalx(){
        //Creating custom setting
        TalxInt__c taxInt = new TalxInt__c();
        
        taxInt.APPID__c='https://test.ofx4.talx.com/verifierinterimct2/xmlb2b_router.dll';
        taxInt.APPVER__c= 1;
        taxInt.DTCLIENT__c='20170612131212';
        taxInt.Endpoint__c='https://test.ofx4.talx.com/verifierinterimct2/xmlb2b_router.dll';
        taxInt.LANGUAGE__c='ENG';
        taxInt.USERID__c='PayoffIntUsrTest@50005';
        taxInt.USERPASS__c='payoffTalx123!';
        taxInt.SetupOwnerId = UserInfo.getUserId();
        insert taxInt;
        
         //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123456789',
            peer__Last_Name__c = 'Test LastName',
            peer__First_Name__c = 'Test FirstName'
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
        List<Id> appIdlist = new List<Id>();
        appIdlist.add(app.id);
        
        System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');
        Test.setMock(HttpCalloutMock.class, new TestTalxResponseMock());
        Test.startTest();
        TalxIntegration.CallTalxResponse(app.id,acc.id);
        TalxIntegration.CallTalx(app.id,acc.id);
        TalxIntegration.CallTalx(appIdlist);
        Test.stopTest();


        }
}