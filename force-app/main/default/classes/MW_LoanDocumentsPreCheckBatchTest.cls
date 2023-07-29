@isTest
private class MW_LoanDocumentsPreCheckBatchTest {
	@testSetup static void setup(){
    	loan.TestHelper.createSeedDataForTesting();
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
    
        //Party Type insert1
        clcommon__Party_Type__c pt = new clcommon__Party_Type__c();
        pt.name = 'Borrower';
        insert pt;
    
        MW_Settings__c mwSett = MW_GlobalTestUtility.GetSettings();
        insert mwSett;
        
        CL_Document__c cs = MW_GlobalTestUtility.getCLDocumentRecord();
        insert cs;
    
        //Document category
        genesis__Document_Category__c dc = new genesis__Document_Category__c();
        dc.genesis__Responsible_Party_Type__c = pt.id;
        dc.genesis__Applicable_For__c = 'PARTY';
        insert dc;
        Account acc = MW_GlobalTestUtility.GetAccount('Investor');
        insert acc;
    
        //Inserting Application record
        genesis__Applications__c genesis_applications_Obj = MW_GlobalTestUtility.GetApplication();
        genesis_applications_Obj.Investor__c = acc.id;
        genesis_applications_Obj.genesis__Status__c = 'pre_funding';
		genesis_applications_Obj.DocuSign_Sign_Date__c = system.Today().addDays(-1);
        genesis_applications_Obj.Lead_ID__c = '1231231231';
        genesis_applications_Obj.Payment_Mode__c = 'AutoPay';
        insert genesis_applications_Obj;
        
        List<Origination_Documents__c> origDocList = new List<Origination_Documents__c>();
        Origination_Documents__c ogDoc = new Origination_Documents__c(); 
    	ogDoc.Application__c = genesis_applications_Obj.id;
    	ogDoc.type__c = 'cbr';
    	origDocList.add(ogDoc);
    	
    	Origination_Documents__c ogDoc1 = new Origination_Documents__c(); 
    	ogDoc1.Application__c = genesis_applications_Obj.id;
    	ogDoc1.type__c = 'autopay_authorization';
    	ogDoc1.Code_FF__c = 'autopay_authorization';
    	origDocList.add(ogDoc1);
    	
    	Origination_Documents__c ogDoc2 = new Origination_Documents__c(); 
    	ogDoc2.Application__c = genesis_applications_Obj.id;
    	ogDoc2.type__c = 'terms_of_use';
    	ogDoc2.Code_FF__c = 'terms_of_use';
    	origDocList.add(ogDoc2);
        
        insert origDocList;
        
        list<Attachment> attachment_ObjList = new list<Attachment>();
        attachment_ObjList.add(new Attachment(
            ParentId = genesis_applications_Obj.id,
            Name = 'TIL Document 1231231231.pdf',
            IsPrivate = false,
            Body = Blob.valueOf('Unit Test Attachment Body'),
            Description = '15'));
        
        attachment_ObjList.add(new Attachment(
            ParentId = genesis_applications_Obj.id,
            Name = 'Credit Score Notice 1231231231.pdf',
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
            Name = 'talx_1231231231.xml',
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
        
        Yodlee_User_Account__c yacc = new Yodlee_User_Account__c();
        yacc.Yodlee_Account__c = acc.Id;
        yacc.verified__c = true;
        yacc.Yodlee_Application__c = genesis_applications_Obj.id;
        insert yacc;
        
        Talx__c talx = new Talx__c(
            Application__c = genesis_applications_Obj.Id,
            Employeer__c = 'Test',
            Salary__c = 18500,
            Hire_Date__c = System.Today()
        );
        Insert talx;
	}
	@isTest static void testMWOriginationDocuments_AppDocs() {
		Test.startTest();
		Database.executeBatch(new MW_LoanDocumentsPreCheckBatch(), 1);
		System.assertEquals(null, MW_LoanDocumentsPreCheckBatch.logList); 
        MW_LoanDocumentsPreCheckScheduler sch = new MW_LoanDocumentsPreCheckScheduler(200);
		System.schedule('MissingLoanDocumentsAlert', '0 59 * * * ?', sch);
        Test.stopTest();
	}
}