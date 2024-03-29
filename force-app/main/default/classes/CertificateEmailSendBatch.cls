/**
 * LSP-1129: Batch class to send certificate of insurance emails.
 */
global class CertificateEmailSendBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {

    private static final String NOTE_CONTENT = 'Loan is covered by TruStage Payment Guard Insurance.';

    private static final String NOTE_SUBJECT = 'Membership';

    private static final String NOTE_TYPE = 'Internal';

    public Set<Id> appIds;

    public String query;

    static global Id executeBatch(Set<Id> appIds) {
        CertificateEmailSendBatch batch = new CertificateEmailSendBatch(appIds, null);
        return Database.executeBatch(batch, getBatchSize());
    }

    /**
     * @return Return a safe value for the batch size
     */
    static global Integer getBatchSize() {
        Decimal configSize = MW_Settings__c.getOrgDefaults().Insurance_Certificate_Email_Batch_Size__c;
        Integer batchSize = configSize == null || configSize == 0 ? 10 : configSize.intValue();
        return batchSize;
    }

    /**
     * @param appIds A list of app ids to query for
     * @param query A query which returns applications - must query: Id, Lead_Id__c, genesis__Contact__c
     */
    global CertificateEmailSendBatch(Set<Id> appIds, String query) {
        this.appIds = appIds;

        if (query != null) {
            this.query = query;
        } else {

            /*
            filter out application ids which do not have a valid contract
            this is possible if the application fails to convert to contract
             */
            this.query =
                    'SELECT Id, ' +
                    '       Lead_ID__c, ' +
                    '       genesis__Contact__c ' +
                    'FROM   genesis__Applications__c ' +
                    'WHERE  Id IN :appIds ' +
                    'AND    CL_Contract__c != NULL';
        }
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('CertificateEmailSendBatch appIds: ' + appIds);
        System.debug('CertificateEmailSendBatch query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<genesis__Applications__c> scope) {

        List<String> leadIds = new List<String>();

        try {

            if (!MW_Settings__c.getOrgDefaults().Insurance_Certificate_Email_Send__c) {
                log(LoggingLevel.INFO, 'Insurance_Certificate_Email_Send__c is false, ignoring send', appsToLeadIds(scope));
                return;
            }

            if (scope == null || scope.isEmpty()) {
                log(LoggingLevel.WARN, 'Found no apps to send certificate of insurance emails', null);
                return;
            }

            Map<Id, genesis__Applications__c> apps = new Map<Id, genesis__Applications__c>(scope);
            List<Id> sentAppIds = getSentAppIds(apps.keySet());
            List<String> sentLeadIds = new List<String>();

            for (Id id: sentAppIds) {
                if (apps.containsKey(id)) {
                    genesis__Applications__c removed = apps.remove(id);
                    sentLeadIds.add(removed.Lead_ID__c);
                }
            }

            if (apps.isEmpty()) {
                log(LoggingLevel.INFO, 'All apps in batch have already been sent insurance emails',
                        String.join(sentLeadIds, ','));
                return;
            }

            for (genesis__Applications__c app : apps.values()) {
                appIds.add(app.Id);
                leadIds.add(app.Lead_ID__c);
            }

            List<Id> successAppIds = sendEmailsAndReturnSuccesses(apps.values());

            addApplicationNotes(successAppIds);

        } catch (Exception e) {

            log(
                LoggingLevel.ERROR,
                String.format(
                    'Error sending email for lead Ids {0} failed due to {1}',
                    new List<Object> {
                            leadIds,
                            errorToString(e)
                    }),
                leadIds == null ? '' : String.join(leadIds, ',')
            );
        }
    }

    public void finish(Database.BatchableContext param1) {
    }

    /**
     * Send emails and return a list of application ids that were successfully sent
     * @param apps applications to send messages for
     *
     * @return list of application ids that were successfully sent
     */
    private static List<Id> sendEmailsAndReturnSuccesses(List<genesis__Applications__c> apps) {

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.EmailFileAttachment> atts = new List<Messaging.EmailFileAttachment>();

        EmailTemplate et = [
                SELECT Id, HtmlValue
                FROM   EmailTemplate
                WHERE  Name = 'Insurance Certificate'
                AND    Folder.Name = 'Payoff Email Templates'
                LIMIT 1
        ];

        Document doc = [
                SELECT Id, Name, Body
                FROM   Document
                WHERE  Name = 'Insurance Certificate'
                AND    Folder.Name = 'Certificate Email'
                LIMIT 1
        ];

        OrgWideEmailAddress orgWideEmailAddress = [
                SELECT Id, DisplayName, Address
                FROM   OrgWideEmailAddress
                WHERE  DisplayName = 'PayOff'
                LIMIT  1
        ];

        Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
        att.setFileName(doc.Name);
        att.setBody(doc.Body);
        att.setContentType('application/pdf');
        atts.add(att);


        System.debug('Current Certificate Email apps size: ' + apps.size());

        for (genesis__Applications__c app : apps) {

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setOrgWideEmailAddressId(orgWideEmailAddress.Id);
            mail.setReplyTo(orgWideEmailAddress.Address);
            mail.setTargetObjectId(app.genesis__Contact__c);
            mail.setWhatId(app.Id);
            mail.setTemplateId(et.Id);
            mail.setSaveAsActivity(false);
            mail.isTreatBodiesAsTemplate();
            mail.setFileAttachments(atts);
            mails.add(mail);
        }

        Messaging.SendEmailResult [] results = Messaging.sendEmail(mails);

        List<Id> successAppIds = new List<Id>();

        for (Integer i = 0; i < apps.size(); i++) {
            genesis__Applications__c app = apps.get(i);
            Messaging.SendEmailResult result = results[i];

            if (result.success) {
                successAppIds.add(app.Id);
            } else {
                logEmailError(app, result);
            }
        }
        return successAppIds;
    }

    /**
     * @param app application to log error for
     * @param result result of email send
     */
    @TestVisible
    private static void logEmailError(genesis__Applications__c app, Messaging.SendEmailResult result) {

        String cause = 'No result provided';
        if (result != null) {
            cause = getMessagesFromErrors(result.getErrors());
        }

        log(
            LoggingLevel.ERROR,
            String.format(
                    'Unable to send email for lead guid {0} due to {1}.',
                    new List<Object>{
                            app.Lead_ID__c,
                            cause
                    }
            ),
            app.Lead_ID__c);
    }

    /**
     * Add application notes for each application that was successfully sent an email
     * @param successAppIds application ids that were successfully sent an email
     */
    private static void addApplicationNotes(List<Id> successAppIds) {
        if (!successAppIds.isEmpty()) {
            List<genesis__Application_Note__c> notes = new List<genesis__Application_Note__c>();
            for (Id appId : successAppIds) {
                genesis__Application_Note__c note = new genesis__Application_Note__c();
                note.genesis__Application__c = appId;
                note.genesis__Note__c = NOTE_CONTENT;
                note.NoteSubject__c = NOTE_SUBJECT;
                note.NoteType__c = NOTE_TYPE;
                notes.add(note);
            }
            insert notes;
        }
    }

    /**
     * @param incomingIds The list of incoming app ids to consider
     *
     * @return The list of applications which have already sent the email
     */
    private static List<Id> getSentAppIds(Set<Id> incomingIds) {

        List<genesis__Application_Note__c> notes = [
                SELECT genesis__Application__c,
                       genesis__Note__c
                FROM   genesis__Application_Note__c
                WHERE  genesis__Application__c IN :incomingIds
                AND    NoteSubject__c = :NOTE_SUBJECT
                AND    NoteType__c = :NOTE_TYPE
        ];

        if (notes.isEmpty()) {
            return new List<Id>();
        }

        Set<Id> allIds = new Set<Id>();

        for (genesis__Application_Note__c note : notes) {
            if (note.genesis__Note__c == NOTE_CONTENT) {
                allIds.add(note.genesis__Application__c);
            }
        }

        return new List<Id>(allIds);
    }

    /**
     * Get a string of error messages from a list of errors
     * @param errors list of errors
     *
     * @return string of error messages
     */
    private static String getMessagesFromErrors(List<Messaging.SendEmailError> errors) {
        List<String> messages = new List<String>();
        if (errors == null || errors.isEmpty()) {
            return 'No errors provided';
        }
        for (Messaging.SendEmailError error : errors) {
            messages.add(error.message);
        }
        return String.join(messages, ', ');
    }

    /**
     * @param apps to get lead guids from
     *
     * @return a list of lead guids
     */
    @TestVisible
    private static String appsToLeadIds(List<genesis__Applications__c> apps) {
        if (apps == null || apps.isEmpty()) {
            return '';
        }
        List<String> leadIds = new List<String>();
        for (genesis__Applications__c app : apps) {
            leadIds.add(app.Lead_ID__c);
        }
        return String.join(leadIds, ',');
    }

    /**
     * Log a message
     *
     * @param logLevel Enum for acceptable levels
     * @param message A message to log
     * @param appIds A string field to identify one or more applications via logging
     */
    @TestVisible
    private static void log(LoggingLevel logLevel, String message, String appIds) {

        String type = null;

        switch on logLevel {
            when INFO {
                type = 'Info';
            }
            when WARN {
                type = 'Warning';
            }
            when ERROR {
                type = 'Exception';
            }
            when else {
                type = 'Info';
            }
        }

        loan__Batch_Process_Log__c bplog = new loan__Batch_Process_Log__c();
        bplog.loan__Origin__c = 'CertificateEmailSendBatch';
        bplog.loan__Message__c = message;
        bplog.App_Ids__c = appIds;
        bplog.loan__Type__c = type;
        bplog.loan__Time__c = Datetime.now();

        System.debug(logLevel, bplog.loan__Origin__c + ': ' + message);

        try {
            insert bplog;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error inserting batch process log: ' + errorToString(e));
        }
    }

    @TestVisible
    private static String errorToString(Exception e) {
        if (e == null) {
            return 'No error provided';
        }
        return String.format(
                'Error: {0}, line number: {1}, stack trace: {2}',
                new List<Object> {
                        e.getMessage(),
                        e.getLineNumber(),
                        e.getStackTraceString()
                });
    }
}