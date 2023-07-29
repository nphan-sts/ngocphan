@isTest
private class NeoVerifyResponseTest{
    
    @testSetup static void setup() {
        list<account> accList                  = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;
    }
    
    @isTest static void testReportStatusFail() {
        List<ID> alist = new List<ID>();

        for(genesis__Applications__c app:[select Id from genesis__Applications__c limit 99]){
            alist.add(app.id);
        }
        
        Account acc =[select id from Account limit 1];
        
        StaticResource sr = [select Body from StaticResource where Name='neoVerify' limit 1];
        String xmlString = sr.Body.toString();
       
        Test.setMock(HttpCalloutMock.class, new MW_NeoVerifyIntegrationHttpCalloutMock(xmlString, 200));
        NeoVerifyResponse nn = new NeoVerifyResponse();
        nn.parse(xmlString, String.valueOf(alist[0]), String.valueOf(acc.Id));
        
        NeoVerifyResponse.Discretionary_expenses gg = new NeoVerifyResponse.Discretionary_expenses();
        gg.restaurant='101.00';
        gg.auto='101.00';
        gg.clothing='102.00';
        gg.entertainment='104.00';
        gg.home_improvement='105.00';
        gg.household='107.00';
        gg.cash ='108.00';
        gg.other='109.00';
        
        NeoVerifyResponse.Period_summaries ee = new NeoVerifyResponse.Period_summaries();
        ee.month ='101.00';
        ee.cash_flow_total_income ='101.00';
        ee.cash_flow_net_income ='101.00';
        ee.payroll_income ='101.00';
        ee.other_income ='101.00';
        ee.total_income ='101.00';
        ee.living_expense ='101.00';
        ee.discretionary_expense ='101.00';
        ee.total_expense ='101.00'; 
        
         NeoVerifyResponse.Employments ee1 = new NeoVerifyResponse.Employments();
        ee1.employer ='101.00';
        ee1.first_pay_date1 ='101.00';
        ee1.last_pay_date1 ='101.00';
        ee1.paychecks =101;
        ee1.avg_paycheck ='101.00';
        ee1.pay_cycle ='101.00';
        ee1.next_day_date1 ='101.00';
        ee1.total_earnings ='101.00'; 
        
        NeoVerifyResponse.Living_expenses le = new NeoVerifyResponse.Living_expenses();
        le.utility = 'test1';
        le.insurance = 'test2';
        le.gasoline = 'test3';
        le.telecom = 'test1';
        le.other = 'test2';
        
         NeoVerifyResponse.Other_income oi = new NeoVerifyResponse.Other_income();
         oi.date1 = '10-02-1980';
        oi.amount = '101.01';
        oi.description = 'Uncategorizable';
        
        NeoVerifyResponse.Items its = new NeoVerifyResponse.Items();
         its.date1 = '10-02-1980';
        its.amount = '101.01';
        
        NeoVerifyResponse.Payday_loans pl = new NeoVerifyResponse.Payday_loans();
        pl.count = 10;
        pl.fees = '100.00';
        
        NeoVerifyResponse.Overdrafts od = new NeoVerifyResponse.Overdrafts();
        od.count = 10;
        od.fees = '100.00';
        
        NeoVerifyResponse.Accounts ac = new NeoVerifyResponse.Accounts();
        ac.name = 'test';
        ac.number_Z = '100.00';
        ac.FI = 'FI1';
        ac.balance = '1000.00';
        
        NeoVerifyResponse.Averages avg = new NeoVerifyResponse.Averages();
        avg.living_expenses = 'living_expenses';
        avg.discretionary_expenses = 'discretionary_expenses';
        
         NeoVerifyResponse nb =new NeoVerifyResponse();
         nb.requestBody='104.00';
         nb.responseBody='104.00';
         nb.integrationErrorStatus='104.00';
         nb.integrationErrorStatusCode='104.00';
         nb.errorMessage='104.00';
        nb.report_id = 'id1';
        nb.application_date = '12-05-1789';
        nb.report_start_date = '12-05-1998';
        nb.report_end_date = '12-05-2000';
        nb.Living_expenses = le;
        nb.Discretionary_expenses = gg;
        
         
        
    }
    
    
    
}