public with sharing class MW_DeliveryStatusHandler {

    public static void handleStatus(genesis__Applications__c app) {
        try {
            if (app.Delivery_Partner_Code__c == 'CRB') {
                CRBStatusHandler handler = new CRBStatusHandler();
                handler.handleStatus(app);
            }
            app.Delivery_Processed_Date__c = DateTime.now();
            update app;
        }
        catch (Exception e) {
            MW_LogUtility.error('MW_DeliveryStatusHandler', app.Id, app.Lead_Id__c, 'handleStatus', e);
            if (app.Delivery_Processed_Date__c == null) {  // Retry only one time
                app.Delivery_Processed_Date__c = DateTime.newInstance(1900, 1, 1, 0, 0, 0);
                update app;
			    retryHandleStatus(app.Id);
            }
            else {
                app.Delivery_Processed_Date__c = null;
                update app;
            }
		}
    }

    @Future(callout=true)
    public static void retryHandleStatus(Id appId) {
        genesis__Applications__c app = [SELECT Id, Lead_ID__c, Delivery_Partner_Code__c, Delivery_Id__c, Delivery_Status__c,
                                            Delivery_Message__c, Delivery_Processed_Date__c
                                        FROM genesis__Applications__c
                                        WHERE Id = :appId];

        handleStatus(app);
    }

    private static void notifyBizOps(genesis__Applications__c app) {
        EmailTemplate template = [SELECT id
                            FROM EmailTemplate
                            WHERE name = 'Delivery Status'
                            LIMIT 1];

        OrgWideEmailAddress orgWideEmail = [select Id from OrgWideEmailAddress where DisplayName = 'PayOff' LIMIT 1];
        Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(template.Id, UserInfo.getUserId(), app.Id);

        message.setOrgWideEmailAddressId(orgWideEmail.Id);
        message.setToAddresses(new String[] { MW_Settings__c.getOrgDefaults().BizOps_Delivery_Notification__c });
        message.setSaveAsActivity(false);
        message.setTreatTargetObjectAsRecipient(false);

        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

        if (results[0].success) {
            System.debug('MW_DeliveryStatusHandler.notifyBizOps sent email successfully.');
        }
        else {
            System.debug('MW_DeliveryStatusHandler.notifyBizOps failed to send email: ' + results[0].errors[0].message);
        }
    }

    private class CRBStatusHandler {
        private Map<String, String> notificationStatuses = new Map<String, String> {
            'Approved' => 'Approved',
            'Rejected' => 'Rejected',
            'Returned' => 'Returned',
            'Cancelled' => 'Cancelled',
            'NotFullyFunded' => 'NotFullyFunded',
            'InReverse' => 'InReverse',
            'PartialFailure' => 'PartialFailure',
            'FundingFailed' => 'FundingFailed',
            'ComplianceFailed' => 'ComplianceFailed'
        };

        private Map<String, String> resolutionStatuses = new Map<String, String> {
            'InReverse' => 'InReverse',
            'Cancelled' => 'Cancelled',
            'ComplianceFailed' => 'ComplianceFailed',
            'Rejected' => 'Rejected',
            'Returned' => 'Returned',
            'NotFullyFunded' => 'NotFullyFunded',
            'PartialFailure' => 'PartialFailure',
            'FundingFailed' => 'FundingFailed'
        };

        public void handleStatus(genesis__Applications__c app) {
            if (resolutionStatuses.containsKey(app.Delivery_Status__c)) {
                app.Delivery_Internal_Status__c = 'Pending Resolution';
            }
            if (notificationStatuses.containsKey(app.Delivery_Status__c)) {
                notifyBizOps(app);
            }
        }
    }
}