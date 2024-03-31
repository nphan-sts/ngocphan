@isTest
public class TestAvgDailyBalance{
   testmethod static void method1(){
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
        
        Yodlee_User_Transaction__c yodlee = new Yodlee_User_Transaction__c();
        yodlee.Yodlee_Application__c = app.id;
        yodlee.Yodlee_Account__c = acc.id;
        yodlee.Balance__c = 1200.00;
        yodlee.Transaction_Date__c = system.today();
        
        Yodlee_User_Transaction__c yodlee1 = new Yodlee_User_Transaction__c();
        yodlee1.Yodlee_Application__c = app.id;
        yodlee1.Yodlee_Account__c = acc.id;
        yodlee1.Balance__c = 1200.00;
        yodlee1.Transaction_Date__c = Date.newInstance(2017,02,13);
        
        List<Yodlee_User_Transaction__c> yodleeList = new List<Yodlee_User_Transaction__c>();
        yodleeList.add(yodlee);
        yodleeList.add(yodlee1);
        insert yodleeList;
        System.debug(yodleeList);
        
        test.startTest();
        AvgDailyBalance obj = new AvgDailyBalance();
        obj.countAvgDailyBalance(yodleeList);
        test.stopTest();
   }
}