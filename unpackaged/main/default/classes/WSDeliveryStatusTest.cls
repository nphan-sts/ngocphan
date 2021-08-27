@isTest
private class WSDeliveryStatusTest {
    @isTest static void testUpdateStatus() {
        genesis__Org_Parameters__c cso = new
            genesis__Org_Parameters__c(genesis__Disable_Triggers__c = true);
        insert cso;
        
        Account acct = TestDataFactory.createTestAccount();
        acct.peer__First_Name__c = 'FirstName';
        acct.peer__Last_Name__c = 'LastName';
        insert acct;
        
        Account inv = TestDataFactory.createTestInvestor();
        inv.Investor_Code__c = 'TEST';
        insert inv;
        
        genesis__Applications__c app = TestDataFactory.createTestApplication(acct.Id, inv.Id, '9ffffff9-9fff-f999-ff99-9f9f9f9f9f9f',
            Date.today().addDays(2), 'agent_document_verification_pending');

        app.Delivery_Partner_Code__c = 'CRB';
        app.Delivery_Id__c = '1234567890';
        insert app;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Application/Delivery/Status';
        req.addHeader('Content-Type', 'application/json');

        req.httpMethod = 'POST';

        WSDeliveryStatus.StatusPayload payload = new WSDeliveryStatus.StatusPayload();
        payload.delivery_partner_code = 'CRB';
        payload.delivery_id = '1234567890';
        payload.delivery_status = 'Approved';
        payload.delivery_message = '';
        req.requestBody = Blob.valueOf(JSON.serialize(payload));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        WSDeliveryStatus.updateStatus();
        Test.stopTest();

        System.assertEquals(res.statusCode, 200);
    }

    @isTest static void testUpdateStatus400PartnerCode() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Application/Delivery/Status';

        req.httpMethod = 'POST';

        WSDeliveryStatus.StatusPayload payload = new WSDeliveryStatus.StatusPayload();
        payload.delivery_id = '1234567890';
        payload.delivery_status = 'Approved';
        req.requestBody = Blob.valueOf(JSON.serialize(payload));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        WSDeliveryStatus.updateStatus();
        Test.stopTest();

        System.assertEquals(400, res.statusCode);
        System.assertEquals('delivery_partner_code is required', res.responseBody.toString());
    }

    @isTest static void testUpdateStatus400Id() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Application/Delivery/Status';

        req.httpMethod = 'POST';

        WSDeliveryStatus.StatusPayload payload = new WSDeliveryStatus.StatusPayload();
        payload.delivery_partner_code = 'CRB';
        payload.delivery_status = 'Approved';
        req.requestBody = Blob.valueOf(JSON.serialize(payload));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        WSDeliveryStatus.updateStatus();
        Test.stopTest();

        System.assertEquals(400, res.statusCode);
        System.assertEquals('delivery_id is required', res.responseBody.toString());
    }

    @isTest static void testUpdateStatus400Status() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Application/Delivery/Status';

        req.httpMethod = 'POST';

        WSDeliveryStatus.StatusPayload payload = new WSDeliveryStatus.StatusPayload();
        payload.delivery_partner_code = 'CRB';
        payload.delivery_id = '1234567890';
        req.requestBody = Blob.valueOf(JSON.serialize(payload));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        WSDeliveryStatus.updateStatus();
        Test.stopTest();

        System.assertEquals(400, res.statusCode);
        System.assertEquals('delivery_status is required', res.responseBody.toString());
    }

    @isTest static void testUpdateStatus500() {
        Account acct = TestDataFactory.createTestAccount();
        insert acct;

        Account inv = TestDataFactory.createTestInvestor();
        inv.Investor_Code__c = 'TEST';
        insert inv;

        genesis__Applications__c app = TestDataFactory.createTestApplication(acct.Id, inv.Id, '9ffffff9-9fff-f999-ff99-9f9f9f9f9f9f',
            Date.today().addDays(2), 'agent_document_verification_pending');

        app.Delivery_Partner_Code__c = 'CRB';
        app.Delivery_Id__c = '1234567890';
        insert app;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Application/Delivery/Status';

        req.httpMethod = 'POST';

        WSDeliveryStatus.StatusPayload payload = new WSDeliveryStatus.StatusPayload();
        payload.delivery_partner_code = 'CRB';
        payload.delivery_id = '0000000000';
        payload.delivery_status = 'Approved';
        req.requestBody = Blob.valueOf(JSON.serialize(payload));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        WSDeliveryStatus.updateStatus();
        Test.stopTest();

        System.assertEquals(500, res.statusCode);
        System.assertEquals('Cannot find application with delivery_partner_code - delivery_id: ' +
            payload.delivery_partner_code + ' - ' + payload.delivery_id, res.responseBody.toString());
    }
}