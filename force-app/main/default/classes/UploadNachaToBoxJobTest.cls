/*
*    This class tests these classes UploadNachaToBoxJob, LogsCalloutBatch and LogsCalloutBatchHelper
*    Tests if box url is updated in Description field on the Document object record which holds the NACHA file
*    Tests the success and failure of the BOX upload by checking the box url updates in Document
*/

@isTest
private class UploadNachaToBoxJobTest {
    @testSetup static void setupData() {
        CL_Document__c cdRec = CL_Document__c.getOrgDefaults();
        cdRec.UploadedBOX__c = 'UploadedBOX';
        upsert cdRec;
        
        BoxUrl__c box = new BoxUrl__c();
        box.BoxService__c='BoxSB.com';
        box.Boxurl__c='https://happymoney.app.box.com/';
        insert box;
    
        ints__OAuth_Settings__c oAuthName = new ints__OAuth_Settings__c();
        oAuthName.ints__Consumer_Key__c     = 'd998c67720u9bf2zg34ll4ogesxppsh7';
        oAuthName.ints__Consumer_Secret__c  = 'fSmCcCTwBxYHFpxElbYcJJywiw4CelFd';
        oAuthName.ints__Access_Token_URL__c = 'https://api.box.com/oauth2/token';
        oAuthName.ints__Service_Name__c     = 'BoxSB.com';
        insert oAuthName;
    
        ints__OAuth_Token__c authToken = new ints__OAuth_Token__c();
        authToken.ints__Token__c = 'yBE4Ci4BP9wa8D00AXH4rm9t9Y6blKrL';
        authToken.ints__Refresh_Token__c = 'NqDQcTONAkM0U1NJKVBeTi3bNmNHoDwS88TkS-quSK1RVn4tQKlWFBzDkxXy9woPq';
        authToken.ints__OAuth_Settings__c = oAuthName.id;
        authToken.ints__Is_Valid__c = true;
        insert authToken;
        
        loan__Org_Parameters__c loanorg = loan.CustomSettingsUtil.getOrgParameters();
        loanorg.Manual_Payer_Lending_product_name__c = 'Manual Payer';
        loanorg.Auto_Payer_Lending_Product_Name__c = 'Auto Payer';
        upsert loanorg;

        loan__Payment_Mode__c pm = new loan__Payment_Mode__c();
        pm.name = 'Wire';
        insert pm;
        
        Account invacc = new Account();
        invacc.peer__First_Name__c = 'Test';
        invacc.peer__Last_Name__c = 'MandatoryLastName';
        invacc.loan__SOCIAL_SECURITY_NUMBER__c = '123456789';
        insert invacc;
        
        loan__Bank_Account__c bainv = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
                                                 loan__Bank_Name__c = 'Some Bank',
                                                 loan__Routing_Number__c = '999999999',
                                                 loan__Account_Type__c = 'Checking',
                                                 loan__Active__c = true,
                                                 Unmasked_Bank_Account_Number__c = '99999999',
                                                 loan__Account__c = invacc.id);
        insert bainv;

        loan__Automated_Payment_Configuration__c apc = new loan__Automated_Payment_Configuration__c();
        apc.loan__Payment_Mode__c = pm.id;
        apc.loan__Bank_Account__c = bainv.id;
        apc.loan__Filegen_Class__c = 'CustomLoanPaymentTxnNACHAGen';
        apc.loan__Folder_Name__c = 'ACU';
        apc.loan__File_Type__c = 'CSV';
        apc.loan__Event__c = 'LOAN PAYMENT';
        apc.loan__Active__c = true;
        apc.Box_Folder_ID__c = '48673238292';
        insert apc;

        Document docRec = new Document();
        docRec.Body = Blob.valueOf('Some Text');
        docRec.ContentType = 'application/pdf';
        docRec.DeveloperName = 'my_document1';
        docRec.IsPublic = true;
        docRec.Name = 'My Document1';
        docRec.FolderId = [SELECT Id FROM Folder WHERE Name = 'ACU'].Id;
        insert docRec;

    }
    
    @isTest
    private static void testUploadJobScheduler(){
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute() + 1); 
        String ss = String.valueOf(Datetime.now().second());
        
        //parse to cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        
            UploadNachaToBoxJob s = new UploadNachaToBoxJob(); 
            System.schedule('Job Started At ' + String.valueOf(Datetime.now()), nextFireTime, s);
    }
    
    @isTest
    private static void testUploadJobFailure(){
        Test.startTest();
            UploadNachaToBoxJob s = new UploadNachaToBoxJob(); // No Mock call to check if it fails when there's no box url in response
            Database.executeBatch(s,1);
        Test.stopTest(); 
        Document doc = [SELECT Id, Description FROM Document LIMIT 1];   
        system.assertEquals(null,doc.Description);
    }
    
    @isTest
    private static void testUploadJobSuccess(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TestUploadFileToBoxMock()); // Mock call to check the success if there's a box url respone
            UploadNachaToBoxJob s = new UploadNachaToBoxJob(); 
            Database.executeBatch(s,1);
        Test.stopTest();   
        Document doc = [SELECT Id, Description FROM Document LIMIT 1];
        system.assertNotEquals(null,doc.Description); 
    }
}