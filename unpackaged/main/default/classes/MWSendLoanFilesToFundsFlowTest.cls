@isTest
private class MWSendLoanFilesToFundsFlowTest {
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
		DocuSign_Sign_Date__c = system.Today().addDays(-1),
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
    static testMethod void testGetDocuments() {
        String leadId = '1231231231';
       
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/Application/Documents/getLoanDocuments';
        req.addParameter('lead_id', leadId);
       
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        MWSendLoanFilesToFundsFlow.getLoanDocuments();
        Test.stopTest();
    }
    
    static testMethod void testGetDocumentsNoLeadId() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/Application/Documents/getLoanDocuments';
        req.addParameter('lead_id', '');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        MWSendLoanFilesToFundsFlow.getLoanDocuments();
        Test.stopTest();
        
        //System.assertEquals(400, res.statusCode);
        //System.assertEquals('lead_id is required', res.responseBody.toString());
    }
}