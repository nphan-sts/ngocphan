@isTest (SeeAllData=true)
public with sharing class MW_DocumentCategoryHandlerTEMPTest {

    static testMethod void TestDOcumentCategoryWithYodlee(){
        

        clcommon__Party_Type__c pt = new clcommon__Party_Type__c();
        pt.name = 'Borrower';
        insert pt;

        clcommon__Party_Type__c lo = new clcommon__Party_Type__c();
        lo.Name = 'LOAN OFFICER';
        lo.Check__c = false;
        insert lo;

        clcommon__Party_Type__c entityparty = new clcommon__Party_Type__c();
        entityparty.Name = 'ENTITY';
        entityparty.Check__c = false;
        insert entityparty;

        genesis__Document_Category__c dc = new genesis__Document_Category__c();
        dc.genesis__Responsible_Party_Type__c = pt.id;
        dc.genesis__Applicable_For__c = 'PARTY';
        dc.genesis__Category_Name__c = 'Verification Documents';
        dc.genesis__Required__c = true;
        dc.genesis__Generation_Status__c = 'Default Documents';
        dc.genesis__Send_Notification__c = true;
        dc.genesis__Create_Tasks__c = true;
        dc.genesis__Review_Assigned_To_Party_Type__c=lo.id;
        insert dc;

        genesis__Document_Category__c payStub = new genesis__Document_Category__c();
        payStub.genesis__Applicable_For__c = 'PARTY';
        payStub.genesis__Category_Name__c = 'Credit Card Balances';
        payStub.genesis__Create_Tasks__c = true;
        payStub.genesis__Description__c = 'Credit Card Balances';
        payStub.genesis__Parent_Document_Category__c = dc.id;
        payStub.genesis__Required__c = true;
        payStub.genesis__Responsible_Party_Type__c = pt.id;
        payStub.genesis__Send_Notification__c = true;
        payStub.Application_Status__c = 'Default Documents';
        payStub.Code_FF__c = 'income';
        insert payStub;

        //Insert Account
        List<account> accList = MW_DataFactoryTest.createAccounts(1);
        insert accList;
        ints__Yodlee_User_Credentials__c yodleeUserCredentialTest = new ints__Yodlee_User_Credentials__c();
        yodleeUserCredentialTest.ints__Account__c = accList[0].Id;
        yodleeUserCredentialTest.ints__Yodlee_Username__c = 'testUser1234';
        yodleeUserCredentialTest.ints__Yodlee_Password__c = 'testPassword1234';
        yodleeUserCredentialTest.yodlee_Account_count__c = 1;
        insert yodleeUserCredentialTest;

        genesis__Applications__c genesis_applications_Obj = MW_DataFactoryTest.createApplication(1, accList[0].Id)[0];
        Insert genesis_applications_Obj;

        Attachment attachment_Obj = new Attachment(
            ParentId = genesis_applications_Obj.id,
            Name = 'Name312',
            IsPrivate = false,
            Body = Blob.valueOf('Unit Test Attachment Body'),
            Description = '15');
        Insert attachment_Obj;

        genesis__Application_Document_Category__c root = new genesis__Application_Document_Category__c();
        root.Name = 'test';
        root.genesis__Active__c = true;
        root.genesis__Application__c = genesis_applications_Obj.id;
        root.genesis__Email__c = 'qa+3855474713@payoff.com';
        root.genesis__Required__c = false;
        root.genesis__Send_Notification__c = false;
        root.genesis__Status__c = 'OPEN';
        root.Doc_Upload_Notification__c = false;
        insert root;

        genesis__Application_Document_Category__c parentDoc = new genesis__Application_Document_Category__c();
        parentDoc.Name = 'Verification Documents';
        parentDoc.genesis__Active__c = true;
        parentDoc.genesis__Application__c = genesis_applications_Obj.id;
        parentDoc.genesis__Document_Category__c = dc.Id;
        parentDoc.genesis__Email__c = 'qa+3855474713@payoff.com';
        parentDoc.genesis__Id__c = '0';
        parentDoc.genesis__Parent_Application_Document_Category__c = root.Id;
        parentDoc.genesis__Party_Type__c = entityparty.id;
        parentDoc.genesis__Required__c = true;
        parentDoc.genesis__Send_Notification__c = false;
        parentDoc.genesis__Status__c = 'OPEN';
        parentDoc.Borrower_s_Email__c = 'qa+3855474713@payoff.com';
        parentDoc.Doc_Upload_Notification__c = false;
        parentDoc.Box_URl__c = 'test@abc.com';
        insert parentDoc;
        
        //test.startTest();
        genesis__Application_Document_Category__c apdc = new genesis__Application_Document_Category__c();
        apdc.Name = 'Credit Card Balances';
        apdc.genesis__Active__c = true;
        apdc.genesis__Application__c = genesis_applications_Obj.id;
        apdc.genesis__Description__c = 'Credit Card Balances - Additional';
        apdc.genesis__Document_Category__c = payStub.id;
        apdc.genesis__Email__c = 'qa+3855474713@payoff.com';
        apdc.genesis__Id__c = '1';
        apdc.genesis__Parent_Application_Document_Category__c = parentDoc.id;
        apdc.genesis__Parent_Id__c = '0';
        apdc.genesis__Party_Type__c = pt.id;
        apdc.genesis__Required__c = true;
        apdc.genesis__Status__c = 'OPEN';
        apdc.Doc_Upload_Notification__c = false;
        apdc.Box_URl__c = 'test@abc.com';
        insert apdc;

        genesis__Application_Document_Category__c bankDoc = new genesis__Application_Document_Category__c();
        bankDoc.Name = 'ESign Documents';
        bankDoc.genesis__Active__c = true;
        bankDoc.genesis__Application__c = genesis_applications_Obj.id;
        bankDoc.genesis__Document_Category__c = dc.Id;
        bankDoc.genesis__Email__c = 'qa+3855474713@payoff.com';
        bankDoc.genesis__Id__c = '0';
        bankDoc.genesis__Parent_Application_Document_Category__c = root.Id;
        bankDoc.genesis__Party_Type__c = entityparty.id;
        bankDoc.genesis__Required__c = true;
        bankDoc.genesis__Send_Notification__c = false;
        bankDoc.genesis__Status__c = 'OPEN';
        bankDoc.Borrower_s_Email__c = 'qa+3855474713@payoff.com';
        bankDoc.Doc_Upload_Notification__c = false;
        bankDoc.Box_URl__c = 'test@abc.com';
        insert bankDoc;

        bankDoc.Box_URl__c = 'test2@abc.com';
        update bankDoc;

        genesis__Application_Document_Category__c bank1Doc = new genesis__Application_Document_Category__c();
        apdc.Name = 'Bank Statements1';
        bank1Doc.genesis__Active__c = true;
        bank1Doc.genesis__Application__c = genesis_applications_Obj.id;
        bank1Doc.genesis__Description__c = 'Credit Card Balances - Additional';
        bank1Doc.genesis__Document_Category__c = payStub.id;
        bank1Doc.genesis__Email__c = 'qa+3855474713@payoff.com';
        bank1Doc.genesis__Id__c = '1';
        bank1Doc.genesis__Parent_Application_Document_Category__c = bankDoc.id;
        bank1Doc.genesis__Parent_Id__c = '0';
        bank1Doc.genesis__Party_Type__c = pt.id;
        bank1Doc.genesis__Required__c = true;
        bank1Doc.genesis__Status__c = 'OPEN';
        bank1Doc.Doc_Upload_Notification__c = false;
        bank1Doc.Box_URl__c = 'test@abc.com';
        insert bank1Doc;

        List<String> apList = new List<String>();
        apList.add(genesis_applications_Obj.Id);
        loan__Batch_Process_Log__c logRec = new loan__Batch_Process_Log__c();
        logRec.Name = 'MW_PostDealRoomToFE';
        logRec.App_Ids__c = genesis_applications_Obj.Id;
        insert logRec;
        test.startTest();
        //MW_DocumentCategoryHandlerTEMP.processDataCate(apList);
        MW_DocumentCategoryHandlerTEMP mtp = new MW_DocumentCategoryHandlerTEMP(new List<string>{genesis_applications_Obj.Id});
        Database.executeBatch(mtp,1);
        test.stopTest();
    }
}