/**
 * Created by ilazarte on 5/27/22.
 *
 * These methods were refactored out from ApplicationExpiryUpdate and ApplicationExpiryUpdateTEMP
 * This class should be completely stateless!
 *
 * Test this class by running tests for both ApplicationExpiryUpdate and ApplicationExpiryUpdateTEMP
 */

global class ApplicationExpiryUpdateHandler {

    /**
     * The main execution logic
     *
     * @param CSD The target system date as a string
     * @param currentSystemDate The target system date
     * @param scope The application scope
     * @param notifyIds Ids to to send to Allocation Engine Batch
     */
    public static void execute(String CSD,
                               Date currentSystemDate,
                               List<SObject> scope,
                               Set<Id> notifyIds) {

        System.debug('----Method execute(+)scope----' + scope);
        System.debug(LoggingLevel.INFO, 'ApplicationExpiryUpdate CSD: ' + CSD);

        QueueSobject declinedQue;
        QueueSobject expiredQue;
        Manual_Adverse_Action_Decline__c actionDecline;

        try {
            expiredQue = [
                    SELECT Queue.Id,
                           Queue.Name,
                           QueueId
                    FROM   QueueSobject
                    WHERE  SobjectType = 'genesis__Applications__c'
                    AND    Queue.Name =: 'Expired Queue'
            ];
        } catch (Exception e) {
            System.debug('Exception' + e);
            throw new ints.IntegrationException('Expired Queue is not setup');
        }

        try {
            declinedQue = [
                    SELECT Queue.Id,
                           Queue.Name,
                           QueueId
                    FROM   QueueSobject
                    WHERE  SobjectType = 'genesis__Applications__c'
                    AND    Queue.Name = :'Declined'
            ];
        } catch (Exception e) {
            System.debug('Exception' + e);
            throw new ints.IntegrationException('Declined Queue is not setup');
        }

        try {
            actionDecline = [
                    SELECT Id,
                            Name
                    FROM   Manual_Adverse_Action_Decline__c
                    WHERE  Decline_Name__c = 'insufficient tradeline balance'
            ];
        } catch (Exception e) {
            System.debug('Exception' + e);
            throw new ints.IntegrationException('Manual adverse action is not setup');
        }

        List<genesis__Applications__c > listOfApp = (List<genesis__Applications__c >) scope;
        List<genesis__Applications__c > listOfAppTobeUpdated = new List<genesis__Applications__c>();

        Set<String> pre_qual_status = new Set<String>{'pre_qual_collected','partner_pre_qual_shown','partner_offer_estimates',
                'offer_shown','offer_accepted'};


        Set<String> verification_status = new Set<String>{'loan_details_shown','credit_score_notice_shown','ach_accepted','kba_disclosure_accepted',
                'kba_success','dcp_accepted','til_accepted','agent_verification_pending',
                'agent_document_verification_pending','agent_verified'};

        Set<String> docs_status = new Set<String>{'hard_inquiry_disclosure_accepted','docusign_loan_docs_sent','docusign_loan_docs_complete',
                'pre_funding','funded'};

        for(genesis__Applications__c  app : listOfApp){
            if (app.Credit_Policy__r.size() == 0) {
                ApplicationExpiryUpdateHandler.setExpired(app, pre_qual_status, verification_status, docs_status, expiredQue, currentSystemDate, notifyIds);
            } else {
                ApplicationExpiryUpdateHandler.setExpiredWithdrawn(app, pre_qual_status, verification_status, docs_status, expiredQue, currentSystemDate, notifyIds);
            }
            listOfAppTobeUpdated.add(app);
        }

        System.debug(LoggingLevel.INFO, 'All notifyIds: ' + notifyIds);
        update listOfAppTobeUpdated;
    }

    /**
     * Set expired scenario
     *
     * @param app App to potentially expire
     * @param pre_qual_status pre qual status list
     * @param verification_status  verification status list
     * @param docs_status  docs status list
     * @param expiredQue Expired Queue
     * @param currentSystemDate Date for run
     * @param notifyIds Ids to to send to Allocation Engine Batch
     */
    private static void setExpired(genesis__Applications__c app,
                                   Set<String> pre_qual_status,
                                   Set<String> verification_status,
                                   Set<String> docs_status,
                                   QueueSobject expiredQue,
                                   Date currentSystemDate,
                                   Set<Id> notifyIds) {

        if ((app.Expiry_Date__c != null && app.Expiry_Date__c == currentSystemDate) && (app.genesis__Status__c != null && app.genesis__Status__c != 'funded')) {

            if (pre_qual_status.contains(app.genesis__Status__c)) {
                app.Expiration_Tag__c = 'expired_pre_qual';
            } else if (verification_status.contains(app.genesis__Status__c)) {
                app.Expiration_Tag__c = 'expired_verification';
            } else if (docs_status.contains(app.genesis__Status__c)) {
                app.Expiration_Tag__c = 'expired_docs';
            }

            if (app.DocuSign_EnvelopeId__c != null) {
                System.debug('app.DocuSign_EnvelopeId__c...' + app.DocuSign_EnvelopeId__c);
                SendEnvDocuSignAPI.voidDocuSignEnvelope(app.DocuSign_EnvelopeId__c);
            }

            app.genesis__Status__c = 'Expired';
            app.OwnerId = expiredQue.Queue.Id;
            notifyIds.add(app.Id);
        }
    }

    /**
     * Set expired withdrawn scenario
     *
     * @param app App to potentially set to expired withdrawn
     * @param pre_qual_status pre qual status list
     * @param verification_status verification status list
     * @param docs_status doc status list
     * @param expiredQue expired queue
     * @param currentSystemDate Date for run
     * @param notifyIds Ids to to send to Allocation Engine Batch
     */
    private static void setExpiredWithdrawn(genesis__Applications__c app,
                                            Set<String> pre_qual_status,
                                            Set<String> verification_status,
                                            Set<String> docs_status,
                                            QueueSobject expiredQue,
                                            Date currentSystemDate,
                                            Set<Id> notifyIds) {

        if (app.Credit_Policy__r.size() > 0 && app.Expiry_Date__c != null && app.Expiry_Date__c == currentSystemDate) {

            if (pre_qual_status.contains(app.genesis__Status__c)) {
                app.Expiration_Tag__c = 'expired_pre_qual';
            } else if (verification_status.contains(app.genesis__Status__c)) {
                app.Expiration_Tag__c = 'expired_verification';
            } else if (docs_status.contains(app.genesis__Status__c)) {
                app.Expiration_Tag__c = 'expired_docs';
            }

            if (app.DocuSign_EnvelopeId__c != null) {
                System.debug('app.DocuSign_EnvelopeId__c...' + app.DocuSign_EnvelopeId__c);
                SendEnvDocuSignAPI.voidDocuSignEnvelope(app.DocuSign_EnvelopeId__c);
            }

            app.genesis__Status__c = 'Expired-Withdrawn';
            app.OwnerId = expiredQue.Queue.Id;
            notifyIds.add(app.Id);
        }
    }
}