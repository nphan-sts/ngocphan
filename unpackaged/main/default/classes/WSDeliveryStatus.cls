@RestResource(urlMapping='/Application/Delivery/Status')
global with sharing class WSDeliveryStatus {

    @HttpPost
    global static void updateStatus() {
        String appId, leadId;

        RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		try {
            String jsonData = req.requestBody.toString();
            MW_LogUtility.info('WSDeliveryStatus', 'updateStatus', jsonData);

            StatusPayload payload = (StatusPayload) JSON.deserialize(jsonData, StatusPayload.class);
            if (String.isBlank(payload.delivery_partner_code)) {
                res.statusCode = 400;
				res.responseBody = Blob.valueOf('delivery_partner_code is required');
				return;
            }
            if (String.isBlank(payload.delivery_id)) {
                res.statusCode = 400;
				res.responseBody = Blob.valueOf('delivery_id is required');
				return;
            }
            if (String.isBlank(payload.delivery_status)) {
                res.statusCode = 400;
				res.responseBody = Blob.valueOf('delivery_status is required');
				return;
            }

            List<genesis__Applications__c> apps = [SELECT Id, Lead_ID__c, Delivery_Partner_Code__c, Delivery_Id__c, Delivery_Status__c, Delivery_Message__c,
                                                        Delivery_Processed_Date__c
                                                   FROM genesis__Applications__c
                                                   WHERE Delivery_Id__c = :payload.delivery_id AND Delivery_Partner_Code__c = :payload.delivery_partner_code];
            if (apps == null || apps.size() == 0) {
                String errorMsg = 'Cannot find application with delivery_partner_code - delivery_id: ' +
                    payload.delivery_partner_code + ' - ' + payload.delivery_id;
                MW_LogUtility.warn('WSDeliveryStatus', 'updateStatus', errorMsg);
                res.statusCode = 500;
                res.responseBody =  Blob.valueOf(errorMsg);
                return;
            }

            genesis__Applications__c app = apps[0];

            appId = app.Id;
            leadId = app.Lead_ID__c;

            app.Delivery_Status__c = payload.delivery_status;
            if (String.isNotBlank(payload.delivery_message)) {
                app.Delivery_Message__c = payload.delivery_message;
            }
            app.Delivery_Processed_Date__c = null;
            update app;

            MW_DeliveryStatusHandler.handleStatus(app);

            res.statusCode = 200;
		}
		catch (Exception e) {
            MW_LogUtility.error('WSDeliveryStatus', appId, leadId, 'updateStatus', e);
			res.statusCode = 500;
			res.responseBody = Blob.valueOf(e.getMessage());
		}
    }

    public class StatusPayload {
        public String delivery_partner_code;
        public String delivery_id;
        public String delivery_status;
        public String delivery_message;
    }
}