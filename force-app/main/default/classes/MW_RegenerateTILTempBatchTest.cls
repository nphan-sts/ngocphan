@isTest
public class MW_RegenerateTILTempBatchTest {
    
    
    
    public static testMethod void testWF_tilRegenerate(){
        
        Account account_Obj = new Account(
            Name = 'Test',
            peer__Last_Name__c = 'LastName',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com'
        );
        Insert account_Obj;
        
        Account investor_Obj = new Account(
            Name = 'Test',
            peer__Last_Name__c = 'LastName',
            loan__Investor__c=true,
            cnotify__Email__c = 'no-reply@testorganizatio.com',
            Investor_Code__c='FTCU'
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
            genesis__Status__c = 'funded', 
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c = 'Full Time',
            Investor__c = investor_Obj.Id,
            Lead_Id__c = '4b98b422-d77c-7a95-a741-1c63994743c6',
            LeadGUID_XX_BoxFolderID__c =' 123213213'
        );      
        Insert genesis_applications_Obj; 
        
        genesis__Application_Document_Category__c appDoc = new genesis__Application_Document_Category__c();
        appDoc.Box_URl__c = 'https://happymoney.app.box.com/file/538729346459';
        appDoc.Name = 'TIL Document';
        
        appDoc.genesis__Application__c = genesis_applications_Obj.Id;
        insert appDoc;
        
        Attachment attach=new Attachment();  
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.Description = 'TIL Document';
        attach.parentId=genesis_applications_Obj.Id;
        insert attach;

        
        Datetime startDate = datetime.newInstance(2019, 10, 10);
        Datetime endDate = datetime.newInstance(2019, 10, 12);
        system.debug('startDate==='+startDate);
        system.debug('endDate==='+endDate);
        
        set<string> skipLoanStatusSet = new set<string>();
        skipLoanStatusSet.add('Review');
        skipLoanStatusSet.add('Decline_Manual_Review');
        skipLoanStatusSet.add('Declined');
        skipLoanStatusSet.add('Expired');
        skipLoanStatusSet.add('Withdrawn');
        skipLoanStatusSet.add('Default Documents');
        skipLoanStatusSet.add('offer_shown');
        set<String> appStatuses = new set<String>();
        appStatuses.add(genesis_applications_Obj.Lead_Id__c);
        Test.startTest();
        MW_RegenerateTILTempBatch rbcth = new MW_RegenerateTILTempBatch(startDate,endDate,skipLoanStatusSet,'NA',appStatuses);
        Database.executeBatch(rbcth,1);
        Test.stopTest();
    }


}