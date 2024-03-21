@isTest
Private Class BorrowersEmailIDonDocumentObjectTest{
    @testSetUp
    Static Void setupTestData(){    
    
    test.startTest();
    Account account_Obj = new Account(
        Name = 'Test',
        loan__Investor__c=False,
        cnotify__Email__c = 'no-reply@testorganization.com'
    );
    Insert account_Obj;
    
    Account acc = [select Id, cnotify__Email__c from Account  where loan__Investor__c=false LIMIT 1];
    System.assertEquals(true, acc.cnotify__Email__c != null);
    
    genesis__Applications__c genesis_applications_Obj = new genesis__Applications__c(
        genesis__Due_Day__c = 20,
        genesis__Expected_First_Payment_Date__c = system.Today(),
        genesis__Expected_Start_Date__c = system.Today(),
        genesis__Funding_in_Tranches__c = true,
        genesis__Account__c = acc.Id,        
        Application_Start_DateV2__c = system.Today(),
        DocuSignFlag__c=true,
        genesis__Status__c = 'agent_verified',
        genesis__Draw_Period_End_Date__c = system.Today()
    );
    
    Insert genesis_applications_Obj; 
    
    genesis__Applications__c app = [Select Id, Name, Application_Email__c from genesis__Applications__c Where Id=: genesis_applications_Obj.Id];
    System.assertEquals(true, app.Application_Email__c != Null);
    System.assertEquals('no-reply@testorganization.com',app.Application_Email__c);
    
    genesis__Application_Document_Category__c ADCObj = new genesis__Application_Document_Category__c(
        Name = 'Test AppDocCategory',        
        genesis__Application__c = app.Id);
    Insert ADCObj; 
    
    genesis__Application_Document_Category__c adc = [Select Id, Application_Email__c From genesis__Application_Document_Category__c where Name = 'Test AppDocCategory'];
    System.assertEquals('no-reply@testorganization.com',  adc.Application_Email__c); 
    
    test.stopTest();    
    }
    
    static TestMethod Void test_getBorrowersEmailId_UseCase1(){
        List<Id> lstADC = new List<Id>();
        for(genesis__Application_Document_Category__c adc : [Select Id From genesis__Application_Document_Category__c where Name = 'Test AppDocCategory'])
        {
            lstADC.Add(adc.Id);
        }
        BorrowersEmailIDonDocumentObject.getBorrowersEmailId(lstADC);
        genesis__Application_Document_Category__c adc = [SELECT Borrower_s_Email__c From genesis__Application_Document_Category__c WHERE Id =: lstADC[0]];
        System.assertEquals('no-reply@testorganization.com', adc.Borrower_s_Email__c);
    }
}