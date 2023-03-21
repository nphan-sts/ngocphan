@isTest
public with sharing class NachaAlertDynamicJobTest {
    @TestSetup
    public static void testSetup(){
        MW_Settings__c setting = MW_GlobalTestUtility.GetSettings();
        setting.Slack_mentions_for_Nacha_alert__c = 'test@user.com';
        insert setting;
        
        clcommon__DAG_Schedule__c dagFileGen = new clcommon__DAG_Schedule__c();
        dagFileGen.clcommon__DAG_Name__c    = 'Payment - Filegen - Upload to Box';
        insert dagFileGen;
        
        clcommon__DAG_Logging__c dagLogging = new clcommon__DAG_Logging__c(
			clcommon__Status__c = 'Success',
            clcommon__DAG__c = dagFileGen.Id
		);
		insert dagLogging;

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

    @isTest
    static void testNachaAlertDynamicJob() {
        Test.startTest();
        NachaAlertDynamicJob job = new NachaAlertDynamicJob();
        String jobID = Database.executeBatch(job,1);
        Test.StopTest();
        
        Assert.isTrue(jobID != null,'job runs 1');
    }

    /*Created By: Ngoc Phan
    Purpose: To test logic for Dynamic query passing query as parameter to the constructor*/
    @isTest
    static void testDynamicQueryOneParam(){
        Test.startTest();
        String  query = 'Select id,name, Box_Folder_ID__c,loan__Folder_Name__c From loan__Automated_Payment_Configuration__c Where loan__Active__c = True limit 1';
        NachaAlertDynamicJob job = new NachaAlertDynamicJob(query);
        String jobID = Database.executeBatch(job);
        Test.StopTest();
        
        Assert.isTrue(jobID != null,'job runs 2');
    }

    @isTest
    static void testLogsCalloutBatch() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpSlackCalloutMock());

        List<loan__Automated_Payment_Configuration__c> apcList = [Select id, loan__Folder_Name__c FROM loan__Automated_Payment_Configuration__c];
        LogsCalloutBatch job = new LogsCalloutBatch(apcList, System.now());
        String jobID = Database.executeBatch(job);
        Test.StopTest();
        
        Assert.isTrue(jobID != null,'job runs 3');
    }

    /**
     * Increase code coverage LogsCalloutBatch Constructor with 4 params
     */
    @isTest
    static void testLogsCalloutBatch2() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpSlackCalloutMock());

        List<loan__Automated_Payment_Configuration__c> apcList = [Select id, loan__Folder_Name__c FROM loan__Automated_Payment_Configuration__c];

        List<String> folderList = new List<String>();

        for(loan__Automated_Payment_Configuration__c aPC : apcList) {
            folderList.add(aPC.loan__Folder_Name__c);
        }

        List<Document> docList = [Select id from Document];

        Set<Id> docIdSet = new Set<Id>();

        Set<Id> failSet = new Set<Id>();

        for(Document doc : docList) {
            docIdSet.add(doc.Id);
        }

        LogsCalloutBatch job = new LogsCalloutBatch(folderList, docIdSet.size(), docIdSet , failSet);
        String jobID = Database.executeBatch(job);
        Test.StopTest();
        
        Assert.isTrue(jobID != null,'job runs 4');
    }
    
    
    @isTest
    static void testNightlyJobFailure() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpSlackCalloutMock());
        
        List<String> apexListDummy = new List<String>();
        apexListDummy.add('StartOfDayDynamicJob');
        
        LogsCalloutBatchHelper.sendFailureNightlyJobAlerts(apexListDummy, System.now());
        
        Test.StopTest();
    }
}