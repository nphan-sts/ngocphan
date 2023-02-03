/*
 * @author :- Pallavi
* Generate TIL status changes to docusign_loan_docs_sent
* JIRA : CRM-135
*/
@isTest
public class TestGenerateTILatDocusisgn {
    
    @isTest
    public static void testGenerateDocusign(){
        Account account_Obj = new Account(
            Name = 'Test',
            peer__First_Name__c = 'TestFName',
            peer__Last_Name__c='TestLName',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com'
        );
        Insert account_Obj;
        
        List<ID> appId = new List<Id>();
        List<ID> appId1 = new List<Id>();
        
        Account investor_Obj = new Account(
            Name = 'Test',
            peer__First_Name__c = 'TestFName2',
            peer__Last_Name__c='TestLName2',
            loan__Investor__c=true,
            cnotify__Email__c = 'no-reply@testorganizatio.com'
        );
        Insert investor_Obj;
        
        CL_Document__c cs = new CL_Document__c();
        cs.Doc1__c = 'Credit Score Notice';
        cs.Doc2__c = 'TIL Document';
        cs.Doc3__c = 'Adverse Action Document';
        cs.UploadedBOX__c = 'UploadedBOX';
        insert cs;
        
        genesis__Applications__c genesis_applications_Obj = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Account__c = account_Obj.Id,        
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'Default Documents',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c = 'Full Time',
            Investor__c = investor_Obj.Id
        );      
        Insert genesis_applications_Obj;
        
        Attachment attachment = new Attachment(
            ParentId = genesis_applications_Obj.id, 
            Name = 'TIL', 
            IsPrivate = false, 
            Body = Blob.valueOf('Unit Test Attachment Body Two'), 
            Description = '15');
        insert attachment;
        
        genesis__Application_Document_Category__c adc = new genesis__Application_Document_Category__c();
        adc.name = 'TIL Document';
        adc.genesis__Application__c = genesis_applications_Obj.id;
        
        insert adc;
        
        appID.add(genesis_applications_Obj.id);
        
        Test.startTest();
        GenerateTILatDocusisgn.invoke_Generate_TIL(appId);
        Test.stopTest();

        List<Attachment> attachmentObj  = [SELECT Id,ParentId,Name,IsPrivate,Body,Description from Attachment];

        Assert.isTrue(attachmentObj.size()>0, 'true');
    }

}