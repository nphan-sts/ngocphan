@isTest
private class IncomeCalculatorTriggerHandlerTest {
    @isTest
    static void testTriggerEvents() {
        
        genesis__Applications__c app = MW_GlobalTestUtility.GetApplication();
        insert app;
        
        List<Income_Calculators__c> newRecords = new List<Income_Calculators__c>();
        Income_Calculators__c inc1 = new Income_Calculators__c(
            Type__c = 'Paystub - Salary',   
            Pay_Period_Start_Date__c = System.TODAY() - 30,
            Pay_Period_End_Date__c = System.TODAY(), 
            Amount__c = 1000,
            Frequency_Type__c = 'Weekly',
            YTD__c = false,
            Application__c = app.Id
        );
        Income_Calculators__c inc2 = new Income_Calculators__c(
            Type__c = 'Paystub - Salary',   
            Pay_Period_Start_Date__c = System.TODAY() - 30,
            Pay_Period_End_Date__c = System.TODAY(), 
            Amount__c = 1000,
            Frequency_Type__c = 'Bi-Weekly',
            YTD__c = false,
            Application__c = app.Id
        );
        Income_Calculators__c inc3 = new Income_Calculators__c(
            Type__c = 'Paystub - Salary',   
            Pay_Period_Start_Date__c = System.TODAY() - 30,
            Pay_Period_End_Date__c = System.TODAY(), 
            Amount__c = 1000,
            Frequency_Type__c = 'Semi-Monthly',
            YTD__c = false,
            Application__c = app.Id
        );
        Income_Calculators__c inc4 = new Income_Calculators__c(
            Type__c = 'Paystub - Salary',   
            Pay_Period_Start_Date__c = System.TODAY() - 30,
            Pay_Period_End_Date__c = System.TODAY(), 
            Amount__c = 1000,
            Frequency_Type__c = 'Monthly',
            YTD__c = false,
            Application__c = app.Id
        );
        Income_Calculators__c inc5 = new Income_Calculators__c(
            Type__c = 'Paystub - Salary',   
            Pay_Period_Start_Date__c = System.TODAY() - 30,
            Pay_Period_End_Date__c = System.TODAY(), 
            Amount__c = 1000,
            Frequency_Type__c = 'Annually',
            YTD__c = false,
            Application__c = app.Id
        );
        Income_Calculators__c inc6 = new Income_Calculators__c(
            Type__c = 'Paystub - Salary',   
            Pay_Period_Start_Date__c = System.TODAY() - 30,
            Pay_Period_End_Date__c = System.TODAY(), 
            Amount__c = 1000,
            Frequency_Type__c = 'Weekly',
            YTD__c = true,
            Application__c = app.Id
        );
        Income_Calculators__c inc7 = new Income_Calculators__c(
            Type__c = 'Paystub - Salary',   
            Pay_Period_Start_Date__c = System.TODAY() - 30,
            Pay_Period_End_Date__c = System.TODAY(), 
            Amount__c = 1000,
            Frequency_Type__c = 'Bi-Weekly',
            YTD__c = true,
            Application__c = app.Id
        );
        Income_Calculators__c inc8 = new Income_Calculators__c(
            Type__c = 'Paystub - Salary',   
            Pay_Period_Start_Date__c = System.TODAY() - 30,
            Pay_Period_End_Date__c = System.TODAY(), 
            Amount__c = 1000,
            Frequency_Type__c = 'Semi-Monthly',
            YTD__c = true,
            Application__c = app.Id
        );
        Income_Calculators__c inc9 = new Income_Calculators__c(
            Type__c = 'Paystub - Salary',   
            Pay_Period_Start_Date__c = System.TODAY() - 30,
            Pay_Period_End_Date__c = System.TODAY(), 
            Amount__c = 1000,
            Frequency_Type__c = 'Monthly',
            YTD__c = true,
            Application__c = app.Id
        );
        Income_Calculators__c inc10 = new Income_Calculators__c(
            Type__c = 'Paystub - Salary',   
            Pay_Period_Start_Date__c = System.TODAY() - 30,
            Pay_Period_End_Date__c = System.TODAY(), 
            Amount__c = 1000,
            Frequency_Type__c = 'Annually',
            YTD__c = true,
            Application__c = app.Id
        );
        newRecords.add(inc1);
        newRecords.add(inc2);
        newRecords.add(inc3);
        newRecords.add(inc4);
        newRecords.add(inc5);
        newRecords.add(inc6);
        newRecords.add(inc7);
        newRecords.add(inc8);
        newRecords.add(inc9);
        newRecords.add(inc10);
        insert newRecords;
        
        newRecords[0].Amount__c = 1500;
        update newRecords[0];
        
        List<Income_Calculators__c> YTDInc = [SELECT Id FROM Income_Calculators__c WHERE YTD__c = true];
        system.assertEquals(5,YTDInc.size());
    }    
}