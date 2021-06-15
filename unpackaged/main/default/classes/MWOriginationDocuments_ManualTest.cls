@isTest
private class MWOriginationDocuments_ManualTest {
    @testSetup static void setup(){
        loan.TestHelper.createSeedDataForTesting();
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();

        //Party Type insert
        clcommon__Party_Type__c pt = new clcommon__Party_Type__c();
        pt.name = 'Borrower';
        insert pt;

        CL_Document__c cs = new CL_Document__c();
        cs.Doc1__c = 'Credit Score Notice';
        cs.Doc2__c = 'TIL Document';
        cs.Doc3__c = 'Adverse Action Document';
        cs.UploadedBOX__c = 'UploadedBOX';
        cs.OrginaitionDocumentFolder__C = '1111111111';
        insert cs;

        //Document category
        genesis__Document_Category__c dc = new genesis__Document_Category__c();
        dc.genesis__Responsible_Party_Type__c = pt.id;
        dc.genesis__Applicable_For__c = 'PARTY';
        insert dc;
        Account acc = new Account(
                Name = 'Test',
                loan__Investor__c = True,
                Amount_Invested__c = 1200,
                Number_Of_Applications_Invested__c =3,
                cnotify__Email__c = 'abc@test.com',
                loan__SOCIAL_SECURITY_NUMBER__c = '123'
        );
        insert acc;

        //Inserting Application record
        genesis__Applications__c genesis_applications_Obj = new genesis__Applications__c(
                genesis__Due_Day__c = 20,
                genesis__Expected_First_Payment_Date__c = system.Today(),
                genesis__Expected_Start_Date__c = system.Today(),
                genesis__Funding_in_Tranches__c = true,
                Investor__c = acc.id,
                genesis__Status__c = 'pre_funding',
                DocuSign_Sign_Date__c = system.Today(),
                genesis__Draw_Period_End_Date__c = system.Today(),
                Lead_ID__c = '1231231231',
                Payment_Mode__c = 'AutoPay');
        insert genesis_applications_Obj;

        Origination_Documents__c ogDoc = new Origination_Documents__c();
        ogDoc.Application__c = genesis_applications_Obj.id;
        ogDoc.type__c = 'cbr';
        insert ogDoc;

        Origination_Documents__c ogDoc1 = new Origination_Documents__c();
        ogDoc1.Application__c = genesis_applications_Obj.id;
        ogDoc1.type__c = 'autopay_authorization';
        ogDoc1.Code_FF__c = 'autopay_authorization';
        insert ogDoc1;

        Origination_Documents__c ogDoc2 = new Origination_Documents__c();
        ogDoc2.Application__c = genesis_applications_Obj.id;
        ogDoc2.type__c = 'terms_of_use';
        ogDoc2.Code_FF__c = 'terms_of_use';
        insert ogDoc2;

        list<Attachment> attachment_ObjList = new list<Attachment>();
        attachment_ObjList.add(new Attachment(
                ParentId = genesis_applications_Obj.id,
                Name = 'DocuSignName312',
                IsPrivate = false,
                Body = Blob.valueOf('Unit Test Attachment Body'),
                Description = '15'));

        attachment_ObjList.add(new Attachment(
                ParentId = genesis_applications_Obj.id,
                Name = 'preciseid_1231231231.xml',
                IsPrivate = false,
                Body = Blob.valueOf('Unit Test Attachment Body'),
                Description = '15'));

        attachment_ObjList.add(new Attachment(
                ParentId = genesis_applications_Obj.id,
                Name = 'cbr_1231231231.xml',
                IsPrivate = false,
                Body = Blob.valueOf('Unit Test Attachment Body'),
                Description = '15'));

        attachment_ObjList.add(new Attachment(
                ParentId = genesis_applications_Obj.id,
                Name = 'linked_acct_1231231231.json',
                IsPrivate = false,
                Body = Blob.valueOf('Unit Test Attachment Body'),
                Description = '15'));

        attachment_ObjList.add(new Attachment(
                ParentId = acc.id,
                Name = 'autopay_authorization',
                IsPrivate = false,
                Body = Blob.valueOf('Unit Test Attachment Body'),
                Description = '15'));
        
        attachment_ObjList.add(new Attachment(
                ParentId = genesis_applications_Obj.id,
                Name = 'TIL Document',
                IsPrivate = false,
                Body = Blob.valueOf('Unit Test Attachment Body'),
                Description = 'TIL Document'));
        insert attachment_ObjList;

        genesis__Application_Document_Category__c adc = new genesis__Application_Document_Category__c();
        adc.name = 'TIL Document';
        adc.genesis__Active__c = true;
        adc.genesis__Document_Category__c =  dc.id;
        adc.genesis__Application__c = genesis_applications_Obj.id;
        adc.Box_URl__c = '';
        insert adc;

        genesis__AppDocCatAttachmentJunction__c adcj = new genesis__AppDocCatAttachmentJunction__c();
        adcj.genesis__Application_Document_Category__c = adc.id;
        adcj.genesis__AttachmentId__c = attachment_ObjList[0].id;
        insert adcj;

    }
    @isTest static void testMWOriginationDocuments_AppDocs() {
        Test.startTest();
        genesis__Application_Document_Category__c docBeforeBatch = [Select Id, name, Box_URl__c From genesis__Application_Document_Category__c limit 1];

        Set<String> appStatus = new Set<String>{'Decline_Manual_Review', 'Declined'};
        String selectAppsBy = 'AppCreatedDate';
        //String appStartDate = '2019-05-15T00:00:00Z';
        String appStartDate = String.valueOf(DateTime.now().year()).leftPad(2,'0') + '-' + String.valueOf(DateTime.now().month()).leftPad(2,'0') + '-'
                + String.valueOf(DateTime.now().day()).leftPad(2,'0') + 'T00:00:00Z';
        //String appEndDate = '2019-05-16T24:00:00Z';
        String appEndDate = String.valueOf(DateTime.now().year()).leftPad(2,'0') + '-' + String.valueOf(DateTime.now().month()).leftPad(2,'0') + '-'
                + String.valueOf(DateTime.now().day()).leftPad(2,'0') + 'T23:00:00Z';
        MWOriginationDocuments_AppDocs_Manual b = new MWOriginationDocuments_AppDocs_Manual(selectAppsBy, appStartDate, appEndDate, appStatus);
        Database.executeBatch(b,200);


        Set<String> appStatusAD = new Set<String>{'pre_funding'};
        String selectAppsByAD = 'DocuSignSignedDate';
        //String appStartDateAD = '2020-05-21';
        String appStartDateAD = String.valueOf(DateTime.now().year()).leftPad(2,'0') + '-' + String.valueOf(DateTime.now().month()).leftPad(2,'0') + '-'
                + String.valueOf(DateTime.now().day()).leftPad(2,'0');
        //String appEndDateAD = '2020-05-21';
        String appEndDateAD = String.valueOf(DateTime.now().year()).leftPad(2,'0') + '-' + String.valueOf(DateTime.now().month()).leftPad(2,'0') + '-'
                + String.valueOf(DateTime.now().day()).leftPad(2,'0');

        MWOriginationDocuments_AppDocs_Manual bAD = new MWOriginationDocuments_AppDocs_Manual(selectAppsByAD, appStartDateAD, appEndDateAD, appStatusAD);
        Database.executeBatch(bAD,200);

        genesis__Application_Document_Category__c docAfterBatch = [Select Id, name, Box_URl__c From genesis__Application_Document_Category__c limit 1];
        System.assertEquals(docBeforeBatch.Box_URl__c, docAfterBatch.Box_URl__c);
        Test.stopTest();
    }

    @isTest static void testMWOriginationDocuments_OrgiDocs() {
        Test.startTest();
        Set<String> appStatus = new Set<String>{'Decline_Manual_Review', 'Declined'};
        String selectAppsBy = 'AppCreatedDate';
        //String appStartDate = '2019-05-15T00:00:00Z';
        String appStartDate = String.valueOf(DateTime.now().year()).leftPad(2,'0') + '-' + String.valueOf(DateTime.now().month()).leftPad(2,'0') + '-'
                + String.valueOf(DateTime.now().day()).leftPad(2,'0') + 'T00:00:00Z';
        //String appEndDate = '2019-05-16T24:00:00Z';
        String appEndDate = String.valueOf(DateTime.now().year()).leftPad(2,'0') + '-' + String.valueOf(DateTime.now().month()).leftPad(2,'0') + '-'
                + String.valueOf(DateTime.now().day()).leftPad(2,'0') + 'T23:00:00Z';
        MWOriginationDocuments_OrgiDocs_Manual b = new MWOriginationDocuments_OrgiDocs_Manual(selectAppsBy, appStartDate, appEndDate, appStatus);
        Database.executeBatch(b,200);

        Set<String> appStatusOD = new Set<String>{'pre_funding'};
        String selectAppsByOD = 'DocuSignSignedDate';
        //String appStartDateOD = '2020-05-21';
        String appStartDateOD = String.valueOf(DateTime.now().year()).leftPad(2,'0') + '-' + String.valueOf(DateTime.now().month()).leftPad(2,'0') + '-'
                + String.valueOf(DateTime.now().day()).leftPad(2,'0');
        //String appEndDateOD = '2020-05-21';
        String appEndDateOD = String.valueOf(DateTime.now().year()).leftPad(2,'0') + '-' + String.valueOf(DateTime.now().month()).leftPad(2,'0') + '-'
                + String.valueOf(DateTime.now().day()).leftPad(2,'0');

        MWOriginationDocuments_OrgiDocs_Manual bOD = new MWOriginationDocuments_OrgiDocs_Manual(selectAppsByOD, appStartDateOD, appEndDateOD, appStatusOD);
        Database.executeBatch(bOD,200);

        Test.stopTest();
    }

}