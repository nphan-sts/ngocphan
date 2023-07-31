@isTest
 Public class TestInvestorlimitsReset{
 
    TestMethod static void method1(){
        //Creating Account
        Account acc = new Account(
                Name = 'Test',
                Total_Investment_Limit__c=2,
                Amount_Invested__c = 1000.00,
                Total_No_of_Application_Limit__c= 5,
                Number_Of_Applications_Invested__c = 2,
                loan__Investor__c=True,
                cnotify__Email__c = 'abc@test.com',
                loan__SOCIAL_SECURITY_NUMBER__c = '123'
                );
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');
    
        Test.startTest();
        String CRON_EXP = '0 0 0 15 3 ? *';
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new InvestorlimitsReset());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        Test.stopTest();
        
    }
 }