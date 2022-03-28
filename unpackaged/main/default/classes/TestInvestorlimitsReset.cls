/* ****************Modification History******************
 * Updated By        Date				Jira Number		 
 *1. Bhanupriya       2022/03/011     	LSP-610	(add testsetup(),and Add required fields,comments and assert statements)
 ******************Modification History******************/

@isTest
 Public class TestInvestorlimitsReset{
     
     //create testsetup method
     @testsetup()
     public static void testsetup(){
         	
        //Creating Account
        Account acc = new Account(
                                Name = 'Test',
                                Total_Investment_Limit__c=2,
                                Amount_Invested__c = 1000.00,
                                Total_No_of_Application_Limit__c= 5,
                                Number_Of_Applications_Invested__c = 2,
                                loan__Investor__c=True,
                                cnotify__Email__c = 'abc@test.com',
                                peer__Last_Name__c = 'Test Last Name',				//LSP-610
                                loan__SOCIAL_SECURITY_NUMBER__c = '123456789'		//LSP-610
                                );
        	insert acc;
       
     }
 //Test method 1 
    TestMethod static void method1(){
        
                Test.startTest();
                String cRON_EXP = '0 0 0 15 3 ? *';
                String jobId = System.schedule('ScheduleApexClassTest',  cRON_EXP, new InvestorlimitsReset());
                CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
                System.assertEquals(CRON_EXP, ct.cronExpression);
                System.assertEquals(0, ct.TimesTriggered);
                Test.stopTest();
        		}
   
 }