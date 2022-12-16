@IsTest
private class CertificateEmailSendBatchTest {

    @TestSetup
    static void setup() {

        MW_Settings__c mwSettings = new MW_Settings__c();
        mwSettings.Insurance_Certificate_Email_Send__c = true;
        mwSettings.Insurance_Certificate_Email_Batch_Size__c = 1;
        insert mwSettings;

        Folder folder = [
                SELECT Id, Name
                FROM   Folder
                WHERE  Name = 'Certificate Email'
                LIMIT  1
        ];

        /* make a csv as an attachment, just to test attachments */
        Document doc = new Document();
        doc.Name = 'Insurance Certificate';
        doc.Body = Blob.valueOf('col1,col2\nval1,val2');
        doc.ContentType = 'text/csv';
        doc.Type = 'csv';
        doc.Description='';
        doc.FolderId = folder.Id;
        insert doc;

        Account investor = MW_GlobalTestUtility.GetAccount('Investor');
        investor.Investor_Code__c = 'ACU';

        Contact contact = MW_GlobalTestUtility.GetContact();
        contact.Email = 'testbatch@happymoney.com';
        insert contact;

        Account member = MW_GlobalTestUtility.GetAccount('Member');
        member.Contact__c = contact.Id;
        member.State__c = 'VA';
        member.ZIP_Code__c = '22124';

        insert new List<Account> {investor, member};

        genesis__Applications__c app = MW_GlobalTestUtility.GetApplication();
        app.genesis__Account__c = member.Id;
        app.genesis__Contact__c = contact.Id;
        app.genesis__Status__c = PayoffConstants.AGENT_DOCUMENT_VERIFICATION_PENDING;
        app.Investor__c = investor.Id;
        app.Lead_ID__c = 'abc123';
        app.genesis__APR__c = 7.00;
        app.genesis__Interest_Rate__c = 6.99;
        app.Pricing_Tier__c = 't1';
        app.genesis__Term__c = 5;
        app.FICO__c = 740.00;
        app.Monthly_DTI__c = 12;
        app.Net_Disposable_Income_NDI_Num__c = 1200;
        app.Loan_Purpose__c = 'debt_consolidation';
        app.Credit_Policy_Approval_Models__c = null;
        app.genesis__Loan_Amount__c = 25000.00;
        app.utm_medium__c = 'medium';
        app.utm_source__c = 'source';
        app.utm_campaign__c = 'campaign';

        insert app;
    }

    /**
     * Test sending to a custom query that doesn't require a contract
     */
    @IsTest
    static void sendEmail() {

        String leadId = 'abc123';
        Set<Id> appIds = getApplicationIdByLeadId(leadId);
        String query = getScopeQuery();

        Test.startTest();
        CertificateEmailSendBatch batch = new CertificateEmailSendBatch(appIds, query);
        Id jobId = Database.executeBatch(batch, CertificateEmailSendBatch.getBatchSize());
        Test.stopTest();

        AsyncApexJob job = getAsyncApexJob(jobId);
        System.assertEquals('Completed', job.Status);

        List<loan__Batch_Process_Log__c> errors = getLoanBatchProcessLogsByType('Exception');
        System.assertEquals(0, errors.size());

        List<genesis__Application_Note__c> notes = getApplicationNotes(appIds);
        System.assertEquals(1, notes.size());
        System.assertEquals('Loan is covered by TruStage Payment Guard Insurance.', notes[0].genesis__Note__c);
    }

    /**
     * Job should complete even if an exception occurs in the processing and log in batch process logs
     */
    @IsTest
    static void logUnsentEmails() {

        String leadId = 'abc123';
        Set<Id> appIds = getApplicationIdByLeadId(leadId);
        String query = getMissingFieldScopeQuery();

        Test.startTest();
        CertificateEmailSendBatch batch = new CertificateEmailSendBatch(appIds, query);
        Id jobId = Database.executeBatch(batch, CertificateEmailSendBatch.getBatchSize());
        Test.stopTest();

        AsyncApexJob job = getAsyncApexJob(jobId);
        System.assertEquals('Completed', job.Status);

        List<loan__Batch_Process_Log__c> errors = getLoanBatchProcessLogsByType('Exception');
        System.assertEquals(1, errors.size());
        loan__Batch_Process_Log__c bpl = errors.get(0);

        System.debug(bpl);
        System.assert(bpl.loan__Message__c.contains('Error sending email for lead Ids (abc123)'));

        List<genesis__Application_Note__c> notes = getApplicationNotes(appIds);
        System.assertEquals(0, notes.size());
    }

    @IsTest
    static void writeLogs() {

        String leadInfo = 'abc123-info';
        String leadWarn = 'abc123-warn';
        String leadError = 'abc123-error';

        CertificateEmailSendBatch.log(LoggingLevel.INFO, 'info', leadInfo);
        CertificateEmailSendBatch.log(LoggingLevel.WARN, 'warn', leadWarn);
        CertificateEmailSendBatch.log(LoggingLevel.ERROR, 'error', leadError);
        CertificateEmailSendBatch.log(LoggingLevel.DEBUG, 'info', leadInfo);

        /* 2 because the debug call should default to info */
        List<loan__Batch_Process_Log__c> infos = getLoanBatchProcessLogsByType('Info');
        System.assertEquals(2, infos.size());
        for (loan__Batch_Process_Log__c info : infos) {
            System.assertEquals(leadInfo, info.App_Ids__c);
            System.assertEquals('info', info.loan__Message__c);
        }

        List<loan__Batch_Process_Log__c> warns = getLoanBatchProcessLogsByType('Warning');
        System.assertEquals(1, warns.size());
        System.assertEquals(leadWarn, warns.get(0).App_Ids__c);
        System.assertEquals('warn', warns.get(0).loan__Message__c);

        List<loan__Batch_Process_Log__c> errors = getLoanBatchProcessLogsByType('Exception');
        System.assertEquals(1, errors.size());
        System.assertEquals(leadError, errors.get(0).App_Ids__c);
        System.assertEquals('error', errors.get(0).loan__Message__c);
    }

    @IsTest
    static void errorToString() {
        System.assertEquals('No error provided', CertificateEmailSendBatch.errorToString(null));

        String errStr = CertificateEmailSendBatch.errorToString(new StringException());
        System.assert(errStr.contains('line number'));
        System.assert(errStr.contains('stack trace'));
    }

    @IsTest
    static void logEmailError() {
        for (genesis__Applications__c app : getApplications()) {
            CertificateEmailSendBatch.logEmailError(app, null);
        }
        List<loan__Batch_Process_Log__c> bpls = getLoanBatchProcessLogsByType('Exception');
        System.assertEquals(1, bpls.size());
        loan__Batch_Process_Log__c batchProcessLog = bpls.get(0);

        System.assertEquals('Unable to send email for lead guid abc123 due to No result provided.', batchProcessLog.loan__Message__c);
    }

    /**
     * Should just exit quietly
     */
    @IsTest
    static void executeBatchCoverageTest() {
        CertificateEmailSendBatch.executeBatch(new Set<Id>());
    }

    /**
     * Complete with no errors
     */
    @IsTest
    static void appToLeadIdsCoverageTest() {
        List<genesis__Applications__c> apps = getApplications();
        CertificateEmailSendBatch.appsToLeadIds(null);
        CertificateEmailSendBatch.appsToLeadIds(new List<genesis__Applications__c>());
        CertificateEmailSendBatch.appsToLeadIds(apps);
    }

    private static List<genesis__Applications__c> getApplications() {
         return [SELECT Id, Lead_ID__c FROM genesis__Applications__c];
    }

    static AsyncApexJob getAsyncApexJob(Id jobId) {
        return [
                SELECT Id,
                        JobItemsProcessed,
                        NumberOfErrors,
                        TotalJobItems,
                        Status
                FROM   AsyncApexJob
                WHERE  Id = :jobId
                LIMIT  1
        ];
    }

    static List<genesis__Application_Note__c> getApplicationNotes(Set<Id> appIds) {
        return [
                SELECT Id,
                        genesis__Application__c,
                        genesis__Note__c
                FROM   genesis__Application_Note__c
                WHERE  genesis__Application__c IN :appIds
        ];
    }

    static List<loan__Batch_Process_Log__c> getLoanBatchProcessLogsByType(String type) {
        return [
                SELECT Id, loan__Type__c, loan__Message__c, App_Ids__c
                FROM Loan__Batch_Process_Log__c
                WHERE loan__Type__c = :type
        ];
    }

    static Set<Id> getApplicationIdByLeadId(String leadId) {
        Set<Id> appIds = new Set<Id>();
        for (genesis__Applications__c app : [
                SELECT Id
                FROM genesis__Applications__c
                WHERE Lead_ID__c = :leadId
        ]) {
            appIds.add(app.Id);
        }

        return appIds;
    }

    /**
     * @return Simple query to produce apps from a passed in set of ids
     */
    static String getScopeQuery() {
        return 'SELECT Id, \n' +
                '        Lead_ID__c, \n' +
                '        genesis__Account__c, \n' +
                '        genesis__Contact__c\n' +
                'FROM    genesis__Applications__c \n' +
                'WHERE   Id IN :appIds';
    }

    /**
     * This query is missing the genesis__Contact__c field
     * The job should handle it correctly and not send the email
     * @return query
     */
    static String getMissingFieldScopeQuery() {
        return 'SELECT Id, \n' +
                '        Lead_ID__c, \n' +
                '        genesis__Account__c \n' +
                'FROM    genesis__Applications__c \n' +
                'WHERE   Id IN :appIds';
    }
}