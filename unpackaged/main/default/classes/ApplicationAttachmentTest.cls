/*****************Modification History******************
* Modified By       Date                    JIRA Number
*   Shakul        2/3/2022          LSP-563 (Refactored Test Class)	
*/
@isTest
private class ApplicationAttachmentTest{
    static final String CREDIT_SCORE_NOTICE = 'Credit Score Notice';
    static final String PDF = '%.pdf%';
    @testSetup
    static void setupTestData(){
        Test.startTest();  
        loan.TestHelper.createSeedDataForTesting();
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        CL_Document__c cs = new CL_Document__c();
        cs.Doc1__c = CREDIT_SCORE_NOTICE;
        cs.Doc2__c = 'TIL Document';
        cs.Doc3__c = 'Adverse Action Document';
        cs.UploadedBOX__c = 'UploadedBOX';
        insert cs;
        
        Account acc = new Account(
            peer__First_Name__c ='Account',
            peer__Last_Name__c = 'Test',
            loan__Investor__c = True,
            Amount_Invested__c = 1200,
            Number_Of_Applications_Invested__c =3,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
        );
        insert acc;
        
        /*pallavi(LOS-63)*/
        List<genesis__Applications__c> lstApp = new List<genesis__Applications__c>();
        genesis__Applications__c genesis_applications_Obj= new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            Borrower_s_Email__c = null,
            Bureau_SSN__c ='21616590',
            Loan_Doc_Signed_On__c = Date.newInstance(2013,12,13),
            Anniversary_Date__c = null,
            Investor__c = acc.id,
            Invested_Amount__c =1000,
            genesis__Account__c = acc.Id,
            genesis__loan_amount__c = 1000,
            Application_Start_DateV2__c = null,
            DocuSignFlag__c=true,
            genesis__Status__c = 'agent_verified',
            genesis__term__c = 36,
            genesis__payment_frequency__c = 'Monthly',
            genesis__Draw_Period_End_Date__c = system.Today()
        );
        lstApp.add(genesis_applications_Obj);
        /*pallavi(LOS-63)*/
        genesis__Applications__c genesis_applications_Obj1 = new genesis__Applications__c(genesis__Due_Day__c = 20,
                                                                                          genesis__Expected_First_Payment_Date__c = system.Today(),
                                                                                          genesis__Expected_Start_Date__c = system.Today(),
                                                                                          genesis__Funding_in_Tranches__c = true,
                                                                                          Investor__c = acc.id,
                                                                                          genesis__Status__c = 'offer_accepted',
                                                                                          genesis__Draw_Period_End_Date__c = system.Today());
        lstApp.add(genesis_applications_Obj1);
        insert lstApp;
        
        List<Attachment> lstAttach = new List<Attachment>(); 
        
        Attachment attachmentOne = new Attachment(
            ParentId = genesis_applications_Obj.id, 
            Name = CREDIT_SCORE_NOTICE, 
            IsPrivate = false, 
            Body = Blob.valueOf('Unit Test Attachment Body One'), 
            Description = '15');
        lstAttach.add(attachmentOne); 
        
        Attachment attachmentTwo = new Attachment(
            ParentId = genesis_applications_Obj1.id, 
            Name = 'TIL', 
            IsPrivate = false, 
            Body = Blob.valueOf('Unit Test Attachment Body Two'), 
            Description = '15');
        lstAttach.add(attachmentTwo); 
        insert lstAttach;
        
        List<genesis__Application_Document_Category__c> lstCat = new List<genesis__Application_Document_Category__c>();
        genesis__Application_Document_Category__c adc = new genesis__Application_Document_Category__c();
        adc.name = 'TIL Document';
        adc.genesis__Application__c = genesis_applications_Obj1.id;
        lstCat.add(adc);
        
        genesis__Application_Document_Category__c adcOne = new genesis__Application_Document_Category__c();
        adcOne.name = CREDIT_SCORE_NOTICE;
        adcOne.genesis__Application__c = genesis_applications_Obj.id;
        lstCat.add(adcOne);
        
        genesis__Application_Document_Category__c adcTwo = new genesis__Application_Document_Category__c();
        adcTwo.name = 'TILDocument_DCP';
        adcTwo.genesis__Application__c = genesis_applications_Obj1.id;
        lstCat.add(adcTwo);
        
        genesis__Application_Document_Category__c adcThree = new genesis__Application_Document_Category__c();
        adcThree.name = 'TILDocument_forDCP';
        adcThree.genesis__Application__c = genesis_applications_Obj1.id;
        lstCat.add(adcThree);
        
        insert lstCat;
        
        Test.stopTest();
    }
    
    /*Created By: Shakul Siddharth
	  Purpose: To test CSN Doc creation */
    static testMethod void testCSNDocCreation(){
        List<genesis__Applications__c> testApp = [SELECT id FROM genesis__Applications__c WHERE genesis__Status__c = 'agent_verified'];
        Test.startTest();
        ApplicationAttachmentHandler.createCSN(testApp);
        Test.stopTest();
        String docNm = PDF;
        Attachment att = [SELECT id FROM Attachment WHERE ParentId IN: testApp AND Name like : docNm];
        System.debug(att != null);
        genesis__AppDocCatAttachmentJunction__c testJunc = [SELECT id FROM genesis__AppDocCatAttachmentJunction__c 
                                                            WHERE genesis__AttachmentId__c =: att.id];
        System.assert(testJunc != null); 
    }
    
    /*Created By: Shakul Siddharth
		Purpose: To test PDF attachment creation passing application id as the sole parameter */
    static testMethod void testSaveAttachOneParam(){
        genesis__Applications__c testApp = [SELECT id FROM genesis__Applications__c WHERE genesis__Status__c = 'offer_accepted'];
        ApplicationAttachmentHandler obj01 = new ApplicationAttachmentHandler(true);
        Test.startTest();
        ApplicationAttachmentHandler.savePdfAttachment(testApp.id);
        Test.stopTest();
        String docNm = PDF;
        Attachment att = [SELECT id FROM Attachment WHERE ParentId =: testApp.id AND Name like : docNm];
        System.debug(att != null);
        genesis__AppDocCatAttachmentJunction__c testJunc = [SELECT id FROM genesis__AppDocCatAttachmentJunction__c 
                                                            WHERE genesis__AttachmentId__c =: att.id];
        System.assert(testJunc != null); 
    }
    
    /*Created By: Shakul Siddharth
		Purpose: To test PDF attachment creation passing three parameters with Application status as dcp_accepted */
    static testMethod void testSaveAttachMultiParams(){
        genesis__Applications__c testApp = [SELECT id FROM genesis__Applications__c WHERE genesis__Status__c = 'offer_accepted'];
        ApplicationAttachmentHandler obj01 = new ApplicationAttachmentHandler(true);
        Test.startTest();
        ApplicationAttachmentHandler.savePdfAttachment(testApp.id,'abc','dcp_accepted');
        Test.stopTest();
        String docNm = PDF;
        Attachment att = [SELECT id FROM Attachment WHERE ParentId =: testApp.id AND Name like : docNm];
        System.debug(att != null);
        genesis__AppDocCatAttachmentJunction__c testJunc = [SELECT id FROM genesis__AppDocCatAttachmentJunction__c 
                                                            WHERE genesis__AttachmentId__c =: att.id];
        System.assert(testJunc != null); 
    }
    
    /*Created By: Shakul Siddharth
		Purpose: To test PDF attachment creation passing three parameters with Application status as TILDocument_forDCP */
    static testMethod void testSaveAttachMultiParamsDCP(){
        genesis__Applications__c testApp = [SELECT id FROM genesis__Applications__c WHERE genesis__Status__c = 'offer_accepted'];
        ApplicationAttachmentHandler obj01 = new ApplicationAttachmentHandler(true);
        Test.startTest();
        ApplicationAttachmentHandler.savePdfAttachment(testApp.id,'abc','TILDocument_forDCP');
        Test.stopTest();
        String docNm = PDF;
        Attachment att = [SELECT id FROM Attachment WHERE ParentId =: testApp.id AND Name like : docNm];
        System.debug(att != null);
        genesis__AppDocCatAttachmentJunction__c testJunc = [SELECT id FROM genesis__AppDocCatAttachmentJunction__c 
                                                            WHERE genesis__AttachmentId__c =: att.id];
        System.assert(testJunc != null); 
    }
    static testMethod void test_delBoxURl(){
        String exceptionError;
        test.startTest();
        try{
            ApplicationAttachmentHandler.delBoxURl(null);
        }
        Catch(Exception ex){
            exceptionError = ex.getMessage();
                    }
        
        test.stopTest();
        System.assertEquals('List has no rows for assignment to SObject', exceptionError);
        
          }  
}