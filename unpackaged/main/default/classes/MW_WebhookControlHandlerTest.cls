@isTest
public with sharing class MW_WebhookControlHandlerTest  {

    static testMethod void TestTilRequest()
    {
        Test.startTest();

        list<account> accList                              = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        Attachment attach=new Attachment();
        attach.Name='TIL Document Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=appList[0].id;
        insert attach;

        RestRequest req    = new RestRequest();
        RestResponse res   = new RestResponse();

        req.requestURI         = '/services/apexrest/CL_MiddleWare';
        req.addParameter('RequestType', 'Til');
        req.addParameter('Lead_ID', 'c9149473-e69f-ee12-38a7-d18b0cba847d');
        req.httpMethod              = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        MW_WebhookControlHandler.handleGetRequest();
        Test.stopTest();
    }

    static testMethod void TestAANRequest()
    {
        Test.startTest();

        list<account> accList                              = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        Attachment attach=new Attachment();
        attach.Name='Adverse Action Document Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=appList[0].id;
        insert attach;

        RestRequest req    = new RestRequest();
        RestResponse res   = new RestResponse();

        req.requestURI         = '/services/apexrest/CL_MiddleWare';
        req.addParameter('RequestType', 'AAN');
        req.addParameter('Lead_ID', 'c9149473-e69f-ee12-38a7-d18b0cba847d');
        req.httpMethod              = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        MW_WebhookControlHandler.handleGetRequest();
        Test.stopTest();
    }

    static testMethod void TestCSNRequest()
    {
        Test.startTest();

        list<account> accList                              = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        Attachment attach=new Attachment();
        attach.Name='Credit Score notice Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=appList[0].id;
        insert attach;

        RestRequest req    = new RestRequest();
        RestResponse res   = new RestResponse();

        req.requestURI         = '/services/apexrest/CL_MiddleWare';
        req.addParameter('RequestType', 'CSN');
        req.addParameter('Lead_ID', 'c9149473-e69f-ee12-38a7-d18b0cba847d');
        req.httpMethod              = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        MW_WebhookControlHandler.handleGetRequest();
        Test.stopTest();
    }

    static testMethod void TestECARequest()
    {
        Test.startTest();

        list<account> accList                              = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        Folder folder  =[select id from Folder where name ='Payoff' LIMIT 1];
        Document doc =new Document();
        doc.Name='eca';
        doc.FolderId = folder.id;
        insert doc;

        RestRequest req    = new RestRequest();
        RestResponse res   = new RestResponse();

        req.requestURI         = '/services/apexrest/CL_MiddleWare';
        req.addParameter('RequestType', 'ECA');
        req.addParameter('Lead_ID', 'c9149473-e69f-ee12-38a7-d18b0cba847d');
        req.httpMethod              = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        MW_WebhookControlHandler.handleGetRequest();
        Test.stopTest();
    }

    static testMethod void TestInvalidLeadIDRequest()
    {
        Test.startTest();

        list<account> accList                              = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        RestRequest req    = new RestRequest();
        RestResponse res   = new RestResponse();

        req.requestURI         = '/services/apexrest/CL_MiddleWare';
        req.addParameter('Lead_ID', null);
        req.httpMethod              = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        String invalidMessage = MW_WebhookControlHandler.handleGetRequest();
        System.assertEquals('In Correct LeadID', invalidMessage);
        Test.stopTest();
    }

    static testMethod void TestKBA_18Request()
    {
        Test.startTest();

        list<account> accList                                  = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;
        appList[0].genesis__Loan_Amount__c=25000;
        update appList;

        RestRequest req    = new RestRequest();
        RestResponse res   = new RestResponse();

        StaticResource sr = [select Body from StaticResource where Name='KBA_18' limit 1];
        String xmlString = '{"kba_attempts": 11, "kba_18": "'+ sr.Body.toString() + '"}';

        System.debug(' REQUEST ' + xmlString);
        req.requestURI         = '/services/apexrest/CL_MiddleWare';
        req.addParameter('RequestType', 'KBA_18');
        req.addParameter('Lead_ID', 'c9149473-e69f-ee12-38a7-d18b0cba847d');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(xmlString);

        RestContext.request = req;
        RestContext.response = res;

        MW_WebhookControlHandler.handleRequest();
        Test.stopTest();
    }

    static testMethod void TestKBA_06Request()
    {
        Test.startTest();

        list<account> accList                                  = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        RestRequest req    = new RestRequest();
        RestResponse res   = new RestResponse();

        StaticResource sr = [select Body from StaticResource where Name='KBA_06' limit 1];
        String xmlString = sr.Body.toString();

        req.requestURI         = '/services/apexrest/CL_MiddleWare';
        req.addParameter('RequestType', 'KBA_06');
        req.addParameter('Lead_ID', 'c9149473-e69f-ee12-38a7-d18b0cba847d');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(xmlString);

        RestContext.request = req;
        RestContext.response = res;

        MW_WebhookControlHandler.handleRequest();
        Test.stopTest();
    }

    static testMethod void TestSoft_pullRequest()
    {
        Test.startTest();

        list<account> accList                              = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        RestRequest req    = new RestRequest();
        RestResponse res   = new RestResponse();

        StaticResource sr = [select Body from StaticResource where Name='credit_policy' limit 1];
        String xmlString = sr.Body.toString();

        req.requestURI         = '/services/apexrest/CL_MiddleWare';
        req.addParameter('RequestType', 'soft_pull');
        req.addParameter('Lead_ID', 'c9149473-e69f-ee12-38a7-d18b0cba847d');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(xmlString);

        RestContext.request = req;
        RestContext.response = res;

        MW_WebhookControlHandler.handleRequest();
        Test.stopTest();
    }

    static testMethod void TestCredit_policyRequest()
    {
        Test.startTest();

        list<account> accList                              = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        RestRequest req    = new RestRequest();
        RestResponse res   = new RestResponse();

        StaticResource sr = [select Body from StaticResource where Name='credit_policy' limit 1];
        String xmlString = sr.Body.toString();

        req.requestURI         = '/services/apexrest/CL_MiddleWare';
        req.addParameter('RequestType', 'credit_policy');
        req.addParameter('Lead_ID', 'c9149473-e69f-ee12-38a7-d18b0cba847d');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(xmlString);


        RestContext.request = req;
        RestContext.response = res;

        MW_WebhookControlHandler.handleRequest();
        Test.stopTest();
    }

    static testMethod void TestId_analyticsRequest()
    {
        Test.startTest();

        list<account> accList                              = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        RestRequest req    = new RestRequest();
        RestResponse res   = new RestResponse();

        StaticResource sr = [select Body from StaticResource where Name='Id_analytics' limit 1];
        String xmlString = sr.Body.toString();

        req.requestURI         = '/services/apexrest/CL_MiddleWare';
        req.addParameter('RequestType', 'Id_analytics');
        req.addParameter('Lead_ID', 'c9149473-e69f-ee12-38a7-d18b0cba847d');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(xmlString);


        RestContext.request = req;
        RestContext.response = res;

        MW_WebhookControlHandler.handleRequest();
        Test.stopTest();

    }

    static testMethod void TestId_hard_pullRequest()
    {
        Test.startTest();
        list<account> accList                              = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        RestRequest req    = new RestRequest();
        RestResponse res   = new RestResponse();

        StaticResource sr = [select Body from StaticResource where Name='hard_pull' limit 1];
        String xmlString = sr.Body.toString();

        req.requestURI         = '/services/apexrest/CL_MiddleWare';
        req.addParameter('RequestType', 'hard_pull');
        req.addParameter('Lead_ID', 'c9149473-e69f-ee12-38a7-d18b0cba847d');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(xmlString);

        RestContext.request = req;
        RestContext.response = res;


        MW_WebhookControlHandler.handleRequest();
        Test.stopTest();

    }

    static testMethod void TestSift_scoreRequest()
    {
        Test.startTest();

        list<account> accList                              = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        RestRequest req    = new RestRequest();
        RestResponse res   = new RestResponse();

        StaticResource sr = [select Body from StaticResource where Name='sift_endpoint' limit 1];
        String xmlString = sr.Body.toString();

        req.requestURI         = '/services/apexrest/CL_MiddleWare';
        req.addParameter('RequestType', 'sift_score');
        req.addParameter('Lead_ID', appList[0].LEAD_ID__C);
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(xmlString);

        RestContext.request = req;
        RestContext.response = res;

        MW_WebhookControlHandler.handleRequest();
        Test.stopTest();
    }

    static testMethod void TestUpdateDocusignStatusSift_scoreRequest()
    {
        list<account> accList                              = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;
        List<dsfs__DocuSign_Status__c>  docstatus = MW_DataFactoryTest.createDocusignStatus(1, appList[0].Id);
        insert docstatus;


    }


    static testMethod void TestACHAccount()
    {
        list<account> accList                              = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        RestRequest req    = new RestRequest();
        RestResponse res   = new RestResponse();

        String xmlString ='{\"genesis__Applications__c\":\"'+appList[0].id+'",\"loan__Bank_Account_Number__c\": \"1111110099\", \"loan__Routing_Number__c\": \"9900099\", \"loan__Account_Type__c\": \"Saving\",\"loan__Bank_Name__c\": \"BankName\",\"Unmasked_Bank_Account_Number__c\": \"Hello\", "Payment_Mode__c": "Auto", "First_Name__c": "Autoa", "Last_Name__c": "Autoa"}';

        req.requestURI         = '/services/apexrest/ACHAccount';
        req.requestBody = Blob.valueof(xmlString);
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        MW_WSACHAccount.ACHAccount();
        Test.stopTest();
    }

    static testMethod void TestNoLeadIdFound()
    {
        Test.startTest();

        list<account> accList                                  = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        RestRequest req    = new RestRequest();
        RestResponse res   = new RestResponse();

        StaticResource sr = [select Body from StaticResource where Name='KBA_06' limit 1];
        String xmlString = sr.Body.toString();

        req.requestURI         = '/services/apexrest/CL_MiddleWare';
        req.addParameter('RequestType', 'KBA_06');
        req.addParameter('Lead_ID', 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXXX');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(xmlString);

        RestContext.request = req;
        RestContext.response = res;

        String handlerResponse = MW_WebhookControlHandler.handleRequest();
        System.assertEquals('No Application exist with this lead idXXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXXX', handlerResponse);

        Test.stopTest();
    }

    static testMethod void TestPasteCount(){
        Test.startTest();
        list<account> accList = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        RestRequest req    = new RestRequest();
        RestResponse res   = new RestResponse();

        StaticResource sr = [select Body from StaticResource where Name='paste_count' limit 1];
        String xmlString = sr.Body.toString();

        req.requestURI         = '/services/apexrest/CL_MiddleWare';
        req.addParameter('RequestType', 'paste_count');
        req.addParameter('Lead_ID', 'c9149473-e69f-ee12-38a7-d18b0cba847d');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(xmlString);

        RestContext.request = req;
        RestContext.response = res;


        MW_WebhookControlHandler.handleRequest();
        Test.stopTest();
    }

    static testMethod void TestDCPTransactions(){
        Test.startTest();
        List<account> accList = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        List<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;
        
        CL_Document__c clDocSetting = new CL_Document__c();
        clDocSetting.Doc1__c = 'Credit Score Notice';
        clDocSetting.Doc2__c = 'TIL Document';
        insert clDocSetting;

        //insert DCP Transactions
        StaticResource sr = [Select Body From StaticResource Where Name='DCPTransactionInsert' limit 1];
        String testJSON = sr.Body.toString();

        RestRequest req    = new RestRequest();
        RestResponse res   = new RestResponse();
        req.requestURI     = '/services/apexrest/CL_MiddleWare';
        req.addParameter('RequestType', 'dcp_transactions');
        req.addParameter('Lead_ID', 'c9149473-e69f-ee12-38a7-d18b0cba847d');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(testJSON);

        RestContext.request = req;
        RestContext.response = res;

        MW_WebhookControlHandler.handleRequest();
        List<DCp_Arcus_Transactions__c> testResult = [Select id, Application__c, Status__c, Bank_Name__c From DCp_Arcus_Transactions__c Where Application__c =: appList[0].id];
        System.assertEquals(1, testResult.size());
        System.assertEquals('CITI', testResult[0].Bank_Name__c);

        //update DCP Transactions
        sr = [Select Body From StaticResource Where Name='DCPTransactionUpdate' limit 1];
        testJSON = sr.Body.toString();
        req.requestURI     = '/services/apexrest/CL_MiddleWare';
        req.addParameter('RequestType', 'dcp_transactions');
        req.addParameter('Lead_ID', 'c9149473-e69f-ee12-38a7-d18b0cba847d');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(testJSON);
        RestContext.request = req;
        RestContext.response = res;
        MW_WebhookControlHandler.handleRequest();
        testResult = [Select id, Application__c, Status__c, Bank_Name__c From DCp_Arcus_Transactions__c Where Application__c =: appList[0].id];
        System.assertEquals(1, testResult.size());
        System.assertEquals('On Hold', testResult[0].Status__c);
        Test.stopTest();
    }

    static testMethod void TestOLNStacker(){
        Test.startTest();
        List<account> accList = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        List<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        StaticResource sr = [Select Body From StaticResource Where Name='oln_fcra_response' limit 1];
        String testXML = sr.Body.toString();

        RestRequest req    = new RestRequest();
        RestResponse res   = new RestResponse();
        req.requestURI     = '/services/apexrest/CL_MiddleWare';
        req.addParameter('RequestType', 'oln_stacker');
        req.addParameter('Lead_ID', 'c9149473-e69f-ee12-38a7-d18b0cba847d');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(testXML);

        RestContext.request = req;
        RestContext.response = res;

        MW_WebhookControlHandler.handleRequest();
        List<genesis__Applications__c> testedApp = [Select id, OLN_Stacker_Status__c From genesis__Applications__c Where id =: appList[0].id limit 1];
        System.assertEquals(-2, testedApp[0].OLN_Stacker_Status__c);
        Test.stopTest();
    }

    static testMethod void TestCredit_Optic(){
        Test.startTest();
        List<account> accList = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        List<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, accList[0].Id);
        insert appList;

        String testXML = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
        + '<soap:Body><api:Response xmlns:api="http://idanalytics.com/core/api"><api:Solution>Standard/MultiProduct</api:Solution><api:RequestID>77cfcab24034362f:272cd76e-1e0d-44b9-9714-b51e646d730f</api:RequestID>'
        + '<api:View>MultiProduct/FINISHED</api:View><api:Body><api:Item key="CreditOpticsAcquisitionsFAB1.0Response">'
        + '<OutputRecord xmlns="http://idanalytics.com/products/idscore/result" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:internal="http://idanalytics.com/internal/api" schemaVersion="3.0">'
        + '<IDAStatus>100</IDAStatus><AppID>11402459-55e0-4d61-8d75-ba59c08618ff</AppID><Designation>A1</Designation><IDASequence>117445880782143</IDASequence>'
                + '<IDATimeStamp>2019-05-07T16:49:24</IDATimeStamp><IDScore>500</IDScore><IDScoreResultCode1>386</IDScoreResultCode1><IDScoreResultCode2>411</IDScoreResultCode2>'
                + '<IDScoreResultCode3>413</IDScoreResultCode3><IDScoreResultCode4>435</IDScoreResultCode4><IDScoreResultCode5>702</IDScoreResultCode5></OutputRecord>'
                + '</api:Item></api:Body></api:Response></soap:Body></soap:Envelope>';

        RestRequest req    = new RestRequest();
        RestResponse res   = new RestResponse();
        req.requestURI     = '/services/apexrest/CL_MiddleWare';
        req.addParameter('RequestType', 'Credit_Optic');
        req.addParameter('Lead_ID', 'c9149473-e69f-ee12-38a7-d18b0cba847d');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(testXML);

        RestContext.request = req;
        RestContext.response = res;

        MW_WebhookControlHandler.handleRequest();
        List<genesis__Applications__c> testedApp = [Select id, CreditOptic_IdScore__c From genesis__Applications__c Where id =: appList[0].id limit 1];
        System.assertEquals(500, testedApp[0].CreditOptic_IdScore__c);
        Test.stopTest();
    }
}