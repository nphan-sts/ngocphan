/* ****************Modification History******************
* Modified By       Date                    JIRA Number
*   Shakul        10/3/2022          LSP-584 (Refactored Test Class)	
******************Modification History******************/
@isTest(SeeAllData = false)
public class Testuploadnachatoboxdynamicjob {
    @TestSetup
    public static void testSetup(){
        loan__Org_Parameters__c loanorg = loan.CustomSettingsUtil.getOrgParameters();
        loanorg.Manual_Payer_Lending_product_name__c = 'Manual Payer';
        loanorg.Auto_Payer_Lending_Product_Name__c = 'Auto Payer';
        upsert loanorg;
        
        Account invacc = new Account();
        invacc.peer__First_Name__c = 'investor';
        invacc.peer__Last_Name__c = 'testOne';
        invacc.loan__SOCIAL_SECURITY_NUMBER__c = '123456780';
        insert invacc;
        
        loan__Bank_Account__c bainv = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
                                                                loan__Bank_Name__c = 'Some Bank',
                                                                loan__Routing_Number__c = '999999999',
                                                                loan__Account_Type__c = 'Checking',
                                                                loan__Active__c = true,
                                                                Unmasked_Bank_Account_Number__c = '99999999',
                                                                loan__Account__c = invacc.id);
        insert bainv;
        
        loan__Payment_Mode__c pm = new loan__Payment_Mode__c();
        pm.name = 'Wire';
        insert pm;
        
        loan__Automated_Payment_Configuration__c invaps = new loan__Automated_Payment_Configuration__c();
        invaps.loan__Payment_Mode__c = pm.id;
        invaps.loan__Bank_Account__c = bainv.id;
        invaps.loan__Filegen_Class__c = 'CustomLoanPaymentTxnNACHAGen';
        invaps.loan__Folder_Name__c = 'ACU';
        invaps.loan__File_Type__c = 'CSV';
        invaps.loan__Event__c = 'LOAN PAYMENT';
        invaps.loan__Active__c = true;
        invaps.Box_Folder_ID__c = '48673238292';
        insert invaps;
        
        List<Document> docs= new list<Document>();
        for(integer i=0;i<5;i++){
            Document documents = new Document();
            documents.Body = Blob.valueOf('Some Text');
            documents.ContentType = 'application/pdf';
            documents.DeveloperName = 'my_document'+i;
            documents.IsPublic = true;
            documents.Name = 'My Document'+i;
            documents.FolderId = [select id from folder where name = 'ACU'].id;
            docs.add(documents);
        }
        insert docs;
    }

   /*Created By: Shakul Siddharth
   Purpose: To test logic for Dynamic query passing query as parameter to the constructor*/
    static testMethod void testDynamicQueryOneParam(){
        Test.startTest();
        String  query = 'Select id,name, Box_Folder_ID__c,loan__Folder_Name__c From loan__Automated_Payment_Configuration__c Where loan__Active__c = True limit 1';
        UploadNachaToBoxDynamicJob  dm = new UploadNachaToBoxDynamicJob(query);
        Database.executeBatch(dm,1);
        Test.StopTest();
        loan__Batch_Process_Log__c batch = [SELECT id , loan__Batch_Id__c FROM loan__Batch_Process_Log__c LIMIT 1];
        System.assertEquals('UploadNachaToBoxDynamicJob', batch.loan__Batch_Id__c);
    }

   /*Created By: Shakul Siddharth
   Purpose: To test logic for Dynamic query having no parameter in the constructor*/
    public static testMethod void testDynamicQuery(){
        Test.StartTest();
        UploadNachaToBoxDynamicJob dm = new UploadNachaToBoxDynamicJob();
        Database.executeBatch(dm,1);
        Test.StopTest();
        loan__Batch_Process_Log__c batch = [SELECT id , loan__Batch_Id__c FROM loan__Batch_Process_Log__c LIMIT 1];
        System.assertEquals('UploadNachaToBoxDynamicJob', batch.loan__Batch_Id__c);
    }

   /*Created By: Shakul Siddharth
   Purpose: To test logic for UploadNachaToBoxJob class*/
    public static testMethod void testUploadNachaToBoxJobClass(){
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class,new TestBoX_IntegMock());
        UploadNachaToBoxJob  dm = new UploadNachaToBoxJob();
        System.schedule('Test status Check', '0 0 23 * * ?', dm);
        Test.StopTest();
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
    }
}