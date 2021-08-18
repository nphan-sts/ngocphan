/*Description: Test class for AttachmentTrg trigger and AttachmentTriggerHandler class.
* Modification Log : 
---------------------------------------------------------------------------
Developer               Date                Description
---------------------------------------------------------------------------
Mohseen Begum           06/27/2017          Created.                   */

@isTest
public class AttachmentTriggerTest {
    /* Description: Test method to cover Attachment Trigger funtionality.  */
    public testMethod static void attachmentTest()
    { 
        
        genesis__Org_Parameters__c cso = new genesis__Org_Parameters__c(genesis__Disable_Triggers__c = true);
        insert cso; 

        CL_Document__c cs = new CL_Document__c();
        cs.Doc1__c = 'Credit';
        cs.Doc2__c = 'Til';
        insert cs;
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.createOffice();
        //Inserting Application record'
        
        Account account_Obj = MW_GlobalTestUtility.GetAccount('Investor');
        account_Obj.peer__First_Name__c = 'FirstName';
        account_Obj.peer__Last_Name__c = 'LastName';
        Insert account_Obj;
        
        Account acc = [select Id, Annual_Individual_Income__c from Account where Name = 'AccountTest' LIMIT 1];
        
        
        genesis__Applications__c genesApp = new genesis__Applications__c();
        genesApp.genesis__Due_Day__c = 20;
        genesApp.genesis__Expected_First_Payment_Date__c = system.Today();
        genesApp.genesis__Expected_Start_Date__c = system.Today();
        genesApp.genesis__Funding_in_Tranches__c = true;
        genesApp.genesis__Account__c = acc.Id;
        genesApp.genesis__Draw_Period_End_Date__c = system.Today();
        insert genesApp;
        
        List<String> AppList = new List<String>();
        AppList.add(genesApp.id);
        
        genesis__Application_Document_Category__c genAppDocCat = new genesis__Application_Document_Category__c();
        genAppDocCat.Name = 'Promissory';
        genAppDocCat.genesis__Application__c = genesApp.Id;
        insert genAppDocCat;
        
        dsfs__DocuSign_Status__c docuSignProject = new dsfs__DocuSign_Status__c();
        docuSignProject.dsfs__Subject__c = 'Promissory Note'+genesApp.id;
        docuSignProject.dsfs__Envelope_Status__c = 'Completed';
        insert docuSignProject;
        
        cso.genesis__Disable_Triggers__c = false;
        update cso;
        
        //Inserting Attachment record to cover Promissory section
        Attachment attach = new Attachment();       
        attach.Name = genesApp.Id+'.Promissory';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = docuSignProject.Id;
        attach.description =genAppDocCat.id;
        insert attach;  
        
        cso.genesis__Disable_Triggers__c = true;
        update cso;
        
        Test.startTest();
        //Inserting Application Document Category record
        genesis__Application_Document_Category__c genAppDocCatTIL = new genesis__Application_Document_Category__c();
        genAppDocCatTIL.Name = 'TIL Document';
        genAppDocCatTIL.genesis__Application__c = genesApp.Id;
        insert genAppDocCatTIL;
        
        cso.genesis__Disable_Triggers__c = false;
        update cso;
        
        //Inserting Attachment record to cover TIL Document section
        Attachment attachTIL = new Attachment();    
        attachTIL.Name = 'TIL Document' + genesApp.Id;
        Blob bodyBlobTIL = Blob.valueOf('Unit Test Attachment Body');
        attachTIL.body = bodyBlobTIL;
        attachTIL.parentId = genesApp.Id;
        attach.description =genAppDocCatTIL.id;
        insert attachTIL;
        
        cso.genesis__Disable_Triggers__c = true;
        update cso;
        
        //Inserting Credit Score Notice Application Document Category record
        genesis__Application_Document_Category__c genAppDocCatCSN = new genesis__Application_Document_Category__c();
        genAppDocCatCSN.Name = 'Credit Score Notice';
        genAppDocCatCSN.genesis__Application__c = genesApp.Id;
        insert genAppDocCatCSN;
        
        cso.genesis__Disable_Triggers__c = false;
        update cso;
        
        //Inserting Attachment record for Credit Score Notice
        Attachment attachCSN = new Attachment();    
        attachCSN.Name = 'TIL Document' + genesApp.Id;
        Blob bodyBlobCSN = Blob.valueOf('Unit Test Attachment Body');
        attachCSN.body = bodyBlobCSN;
        attachCSN.parentId = genesApp.Id;
        attach.description =genAppDocCatCSN.id;
        insert attachCSN;      
        Test.stopTest();
        
    }
    //To Cover attachment Handler.
    public testMethod static void attachmentHandlerTest()
    { 
        genesis__Org_Parameters__c cso = new
            genesis__Org_Parameters__c(genesis__Disable_Triggers__c = true);
        insert cso;
        

        
        CL_Document__c cs = new CL_Document__c();
        cs.Doc1__c = 'Credit';
        cs.Doc2__c = 'Til';
        insert cs;
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.createOffice();
        
        Account account_Obj = MW_GlobalTestUtility.GetAccount('Investor');
        account_Obj.peer__First_Name__c = 'FirstName';
        account_Obj.peer__Last_Name__c = 'LastName';
        Insert account_Obj;
        
        Account acc = [select Id, Annual_Individual_Income__c from Account  where Name = 'AccountTest' LIMIT 1];
        
        
        //Inserting Application record
        genesis__Applications__c genesApp = new genesis__Applications__c();
        genesApp.genesis__Due_Day__c = 20;
        genesApp.genesis__Expected_First_Payment_Date__c = system.Today();
        genesApp.genesis__Expected_Start_Date__c = system.Today();
        genesApp.genesis__Funding_in_Tranches__c = true;
        genesApp.genesis__Account__c = acc.Id;
        genesApp.genesis__Draw_Period_End_Date__c = system.Today();
        genesApp.DocuSign_EnvelopeId__c ='TestName';
        insert genesApp;
        
        //Inserting Application Document Category record 
        genesis__Application_Document_Category__c genAppDocCat = new genesis__Application_Document_Category__c();
        genAppDocCat.Name = 'Promissory';
        genAppDocCat.genesis__Application__c = genesApp.Id;
        insert genAppDocCat;
        
        dsfs__DocuSign_Status__c docuSignProject = new dsfs__DocuSign_Status__c();
        docuSignProject.dsfs__Subject__c = 'Promissory Note'+genesApp.id;
        docuSignProject.dsfs__Envelope_Status__c = 'Completed';
        insert docuSignProject;
        
        cso.genesis__Disable_Triggers__c = false;
        update cso;
        //Inserting Attachment record to cover Promissory section
        Attachment attach = new Attachment();       
        attach.Name = genesApp.Id+'.Promissory';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = docuSignProject.Id;
        attach.description =genAppDocCat.id;
        insert attach;  
        
        cso.genesis__Disable_Triggers__c = true;
        update cso;
        
        
        //Inserting Application Document Category record
        genesis__Application_Document_Category__c genAppDocCatTIL = new genesis__Application_Document_Category__c();
        genAppDocCatTIL.Name = 'TIL Document';
        genAppDocCatTIL.genesis__Application__c = genesApp.Id;
        insert genAppDocCatTIL;
        
        cso.genesis__Disable_Triggers__c = false;
        update cso;
        
        //Inserting Attachment record to cover TIL Document section
        Attachment attachTIL = new Attachment();    
        attachTIL.Name = 'TIL Document' + genesApp.Id;
        Blob bodyBlobTIL = Blob.valueOf('Unit Test Attachment Body');
        attachTIL.body = bodyBlobTIL;
        attachTIL.parentId = genesApp.Id;
        attach.description =genAppDocCatTIL.id;
        insert attachTIL;
        
        cso.genesis__Disable_Triggers__c = true;
        update cso;
        
        Test.startTest();
        //Inserting Credit Score Notice Application Document Category record
        genesis__Application_Document_Category__c genAppDocCatCSN = new genesis__Application_Document_Category__c();
        genAppDocCatCSN.Name = 'Credit Score Notice';
        genAppDocCatCSN.genesis__Application__c = genesApp.Id;
        insert genAppDocCatCSN;
        
        //Inserting Attachment record for Credit Score Notice
        Attachment attachCSN = new Attachment();    
        attachCSN.Name = 'TIL Document' + genesApp.Id;
        Blob bodyBlobCSN = Blob.valueOf('Unit Test Attachment Body');
        attachCSN.body = bodyBlobCSN;
        attachCSN.parentId = genesApp.Id;
        attach.description =genAppDocCatCSN.id;
        insert attachCSN;  
        
        cso.genesis__Disable_Triggers__c = true;
        update cso;
        
        dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c();
        ds.dsfs__Subject__c = 'Promissory Note'+genesApp.id;
        ds.dsfs__DocuSign_Envelope_ID__c = 'TestName';
        insert ds;
        
        List <id> attachId = new List <id>();
        attachId.add(attach.id);
        Map<Id,List<Id>> appWithAttchMap = new Map<Id,List<Id>>();
        appWithAttchMap.put(genesApp.id,attachId);
        
        cso.genesis__Disable_Triggers__c = false;
        update cso;
        
        AttachmentTriggerHandler ath = new AttachmentTriggerHandler(true);
        AttachmentTriggerHandler.createDocumentAttCategory(attach.id,ds.id);    
        AttachmentTriggerHandler.createDocument (appWithAttchMap,'Promissory'); 
        AttachmentTriggerHandler.delAttachments(genesApp.id);   
        AttachmentTriggerHandler.getApplicationId('TestName');
        Test.stopTest();
        
    }
}