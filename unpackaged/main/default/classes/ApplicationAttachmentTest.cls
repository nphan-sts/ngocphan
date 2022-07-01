@isTest
private class ApplicationAttachmentTest{
  @testSetup
  static void setupTestData(){
    test.startTest();  
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
    /*genesis__Applications__c genesis_applications_Obj = new genesis__Applications__c(     //pallavi(LOS-63)(commented)
        genesis__Due_Day__c = 20,
        genesis__Expected_First_Payment_Date__c = system.Today(),
        genesis__Expected_Start_Date__c = system.Today(),
        genesis__Funding_in_Tranches__c = true,
        Investor__c = acc.id,
        genesis__Status__c = 'offer_accepted',
        genesis__Draw_Period_End_Date__c = system.Today());
    Insert genesis_applications_Obj; */
    /*pallavi(LOS-63)*/
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
        insert genesis_applications_Obj;
    /*pallavi(LOS-63)*/
    Attachment attachment_Obj = new Attachment(
        ParentId = genesis_applications_Obj.id, 
        Name = 'DocuSignName312', 
        IsPrivate = false, 
        Body = Blob.valueOf('Unit Test Attachment Body'), 
        Description = '15');
    Insert attachment_Obj; 
    
     genesis__Application_Document_Category__c adc = new genesis__Application_Document_Category__c();
        adc.name = 'TIL Document';
        adc.genesis__Active__c = true;
        adc.genesis__Document_Category__c =  dc.id;
        adc.genesis__Application__c = genesis_applications_Obj.id;
        insert adc;
        
        genesis__AppDocCatAttachmentJunction__c adcj = new genesis__AppDocCatAttachmentJunction__c();
        adcj.genesis__Application_Document_Category__c = adc.id;
        adcj.genesis__AttachmentId__c = attachment_Obj.id;
        insert adcj;
    
    test.stopTest();
  }
  static testMethod void test_savePdfAttachment_UseCase1(){
      test.startTest();
    List<genesis__Applications__c> genesis_applications_Obj  =  [SELECT Id from genesis__Applications__c];
    System.assertEquals(true,genesis_applications_Obj.size()>0);
    List<Attachment> attachment_Obj  =  [SELECT Id,ParentId,Name,IsPrivate,Body,Description from Attachment];
    System.assertEquals(true,attachment_Obj.size()>0);
    ApplicationAttachmentHandler obj01 = new ApplicationAttachmentHandler(true);
    //ApplicationAttachmentHandler.isTrgExecuting = false; Commented by Neha
    ApplicationAttachmentHandler.savePdfAttachment(genesis_applications_Obj[0].id);
    ApplicationAttachmentHandler.savePdfAttachment(genesis_applications_Obj[0].id,'abc','xyz');
    ApplicationAttachmentHandler.delAttachments(genesis_applications_Obj[0].id,'Name312');
    ApplicationAttachmentHandler.attachmentHandler(genesis_applications_Obj[0].id,'offer_accepted','offer_accepted');
    ApplicationAttachmentHandler.attachmentHandler(genesis_applications_Obj[0].id,'dcp_accepted','dcp_accepted');
    ApplicationAttachmentHandler.attachmentHandler(genesis_applications_Obj[0].id,'Reallocation','Reallocation');
    ApplicationAttachmentHandler.createCSN(genesis_applications_Obj);
    
    test.stopTest();
  }
    static testMethod void test_savePdfAttachment_UseCase2(){
      test.startTest();
    //List<genesis__Applications__c> genesis_applications_Obj  =  [SELECT Id from genesis__Applications__c ];
    genesis__Applications__c genesis_applications_Obj1 = new genesis__Applications__c(     
        genesis__Due_Day__c = 20,
        genesis__Expected_First_Payment_Date__c = system.Today(),
        genesis__Expected_Start_Date__c = system.Today(),
        genesis__Funding_in_Tranches__c = true,
        //Investor__c = acc.id,
        genesis__Status__c = 'offer_accepted',
        genesis__Draw_Period_End_Date__c = system.Today());
    Insert genesis_applications_Obj1;
    //System.assertEquals(true,genesis_applications_Obj.size()>0);
    List<Attachment> attachment_Obj  =  [SELECT Id,ParentId,Name,IsPrivate,Body,Description from Attachment];
    System.assertEquals(true,attachment_Obj.size()>0);
    ApplicationAttachmentHandler obj01 = new ApplicationAttachmentHandler(true);
    //ApplicationAttachmentHandler.isTrgExecuting = false; Commented by Neha
    ApplicationAttachmentHandler.savePdfAttachment(genesis_applications_Obj1.id);
    ApplicationAttachmentHandler.savePdfAttachment(genesis_applications_Obj1.id,'abc','xyz');
    //ApplicationAttachmentHandler.delAttachments(genesis_applications_Obj[0].id,'Name312');
    //ApplicationAttachmentHandler.attachmentHandler(genesis_applications_Obj[0].id,'offer_accepted','offer_accepted');
    //ApplicationAttachmentHandler.attachmentHandler(genesis_applications_Obj[0].id,'dcp_accepted','dcp_accepted');
    //ApplicationAttachmentHandler.attachmentHandler(genesis_applications_Obj[0].id,'Reallocation','Reallocation');
    //ApplicationAttachmentHandler.createCSN(genesis_applications_Obj);
    
    test.stopTest();
  }

  
  
}