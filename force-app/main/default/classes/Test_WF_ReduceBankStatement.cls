@isTest
public class Test_WF_ReduceBankStatement {
    
    @isTest
    static void WF_ReduceBankStatement_test(){
        
        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com',
            Annual_Individual_Income__c = 10000 
        );
        Insert acc;
        genesis__Applications__c app = new genesis__Applications__c(
        genesis__Due_Day__c = 20,
        genesis__Expected_First_Payment_Date__c = system.Today(),
        genesis__Expected_Start_Date__c = system.Today(),
        genesis__Funding_in_Tranches__c = true,
        genesis__Account__c = acc.Id,        
        Application_Start_DateV2__c = system.Today(),
        genesis__Status__c = 'agent_verified',
        genesis__Draw_Period_End_Date__c = system.Today(),
        Employment_Status__c = 'Full Time',
        Sift_Status__c=30
        );      
        Insert app; 
        
        List<id> ids = new List<id>();
        ids.add(app.id);
        
        genesis__Document_Category__c docCat = new genesis__Document_Category__c(
            genesis__Category_Name__c = 'Test_Paystub_ID',
            genesis__Required__c = true
        );
        Insert docCat;
        genesis__Application_Document_Category__c appDocCat = new genesis__Application_Document_Category__c(
            Name = 'Bank Statement 1',
            genesis__Document_Category__c = docCat.Id,
            genesis__Application__c = app.Id,
            genesis__Required__c = true
        );
        Insert appDocCat;
        
        genesis__Application_Document_Category__c appDocCat1 = new genesis__Application_Document_Category__c(
            Name = 'Bank Statement 2',
            genesis__Document_Category__c = docCat.Id,
            genesis__Application__c = app.Id,
            genesis__Required__c = true
        );
        Insert appDocCat1;
        
        Test.startTest();
        WF_ReduceBankStatement.ReduceBankStatement(ids);
        Test.stopTest();
    }

}