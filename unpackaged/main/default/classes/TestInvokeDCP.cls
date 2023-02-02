@isTest
public class TestInvokeDCP {

    private static final String DOC_NAME = 'TIL Document';

    @isTest
    public static void testInvokeDCPsuccess(){
        
        
        MW_Settings__c mwSettings = new MW_Settings__c();
        mwSettings.docCategoriesNamestoskip__c = 'skip1,skip2';
       	mwSettings.FE_User_Filter__c ='abcUser@filtertest.com';
        insert mwSettings;
        
        DCP_Arcus__c dcpParameters = new DCP_Arcus__c();
        dcpParameters.secret_key__c = 'ltJj93aM0bn5R/ItWqJy75bBtF/VeeVsWlcGIoyg0yutj45cXIc83QEbprJye+PsEF07iW2KND8q4YBJnHlmXQ==';
        dcpParameters.Endpoint__c = 'https://apix.staging.arcusapi.com/';
        dcpParameters.API_Key__c = '0683f8c05b4540f7f0ac0ca8a0046445';
        insert dcpParameters;

        CL_Document__c document = new CL_Document__c();

        document.Doc1__c = 'Credit Score Notice';
        document.Doc2__c = DOC_NAME;
        document.Doc3__c = 'Adverse Action Notice';
        insert document;
         
        Account acco = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName3',
            peer__Last_Name__c='TestLName3', 
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456'
        );
        Insert acco;
         
        genesis__Applications__c app = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = false,
            genesis__Account__c = acco.Id,
            Invested_Amount__c  = 1000,       
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'offer_accepted',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c    = 'Full Time',
            genesis__Loan_Amount__c = 1000,
            DCP_Investor_Eligibility__c = false,
            dcp_eligible__c = 'Yes',
            genesis__Financed_Amount__c  = 10000
        );      
        Insert app;
        
        Attachment attachment = new Attachment(
            ParentId = app.id, 
            Name = 'TIL', 
            IsPrivate = false, 
            Body = Blob.valueOf('Unit Test Attachment Body Two'), 
            Description = '15');
        insert attachment;
        
        genesis__Application_Document_Category__c adc = new genesis__Application_Document_Category__c();
        adc.name = DOC_NAME;
        adc.genesis__Application__c = app.id;
        
        insert adc;
        
        DCp_Arcus_Transactions__c dcpObj = new DCp_Arcus_Transactions__c();
        dcpObj.Application__c = app.Id;
        dcpObj.Card_Number__c = '1234567';
        dcpObj.Bank_Name__c = 'CITI';
        dcpObj.Pay_at_Funding__c = true;
        dcpObj.Requested_Amount__c = 200;
        dcpObj.Transaction_id__c = '87007jj798888';
        insert dcpObj;
        Test.setMock(HttpCalloutMock.class, new TestDCPHttpCalloutMock());
        test.startTest();
        
        InvokeDCP.InvokeDCP(app.Id);

        test.stopTest();
    }
    
    @isTest
    public static void testInvokeDCPsuccess(){
        
        
        MW_Settings__c mwSettings = new MW_Settings__c();
        mwSettings.docCategoriesNamestoskip__c = 'skip1,skip2';
       	mwSettings.FE_User_Filter__c ='abcUser@filtertest.com';
        insert mwSettings;
        
        DCP_Arcus__c dcpParameters = new DCP_Arcus__c();
        dcpParameters.secret_key__c = 'ltJj93aM0bn5R/ItWqJy75bBtF/VeeVsWlcGIoyg0yutj45cXIc83QEbprJye+PsEF07iW2KND8q4YBJnHlmXQ==';
        dcpParameters.Endpoint__c = 'https://apix.staging.arcusapi.com/';
        dcpParameters.API_Key__c = '0683f8c05b4540f7f0ac0ca8a0046445';
        insert dcpParameters;

        CL_Document__c document = new CL_Document__c();

        document.Doc1__c = 'Credit Score Notice';
        document.Doc2__c = 'TIL Document';
        document.Doc3__c = 'Adverse Action Notice';
        insert document;
         
        Account acco = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName3',
            peer__Last_Name__c='TestLName3', 
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456'
        );
        Insert acco;
         
        genesis__Applications__c app = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = false,
            genesis__Account__c = acco.Id,
            Invested_Amount__c  = 1000,       
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'offer_accepted',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c    = 'Full Time',
            genesis__Loan_Amount__c = 1000,
            DCP_Investor_Eligibility__c = false,
            dcp_eligible__c = 'Yes',
            genesis__Financed_Amount__c  = 10000
        );      
        Insert app;
        
        Attachment attachment = new Attachment(
            ParentId = app.id, 
            Name = 'TIL', 
            IsPrivate = false, 
            Body = Blob.valueOf('Unit Test Attachment Body Two'), 
            Description = '15');
        insert attachment;
        
        genesis__Application_Document_Category__c adc = new genesis__Application_Document_Category__c();
        adc.name = 'TIL Document';
        adc.genesis__Application__c = app.id;
        
        insert adc;
        
        DCp_Arcus_Transactions__c dcpObj = new DCp_Arcus_Transactions__c();
        dcpObj.Application__c = app.Id;
        dcpObj.Card_Number__c = '1234567';
        dcpObj.Bank_Name__c = 'CITI';
        dcpObj.Pay_at_Funding__c = true;
        dcpObj.Requested_Amount__c = 200;
        dcpObj.Transaction_id__c = '87007jj798888';
        insert dcpObj;
        Test.setMock(HttpCalloutMock.class, new TestDCPHttpCalloutMock());
        test.startTest();
        
        InvokeDCP.InvokeDCP(app.Id);

        test.stopTest();
    }
    
    @isTest
    public static void TestInvokeDCP_usecase(){
        test.startTest();
        
       CL_Document__c document = new CL_Document__c();
         document.Doc1__c = 'Credit Score Notice';
         document.Doc2__c = 'TIL Document';
         document.Doc3__c = 'Adverse Action Notice';
         insert document;
        
       Account acco = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName2',
            peer__Last_Name__c='TestLName2', 
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456'
        );
        Insert acco;
        
        genesis__Applications__c app = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = false,
            genesis__Account__c = acco.Id,
            Invested_Amount__c  = 1000,       
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'offer_accepted',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c    = 'Full Time',
            genesis__Loan_Amount__c = 1000,
            DCP_Investor_Eligibility__c = false
        );      
        Insert app;
        
        Attachment attachment = new Attachment(
            ParentId = app.id, 
            Name = 'TIL', 
            IsPrivate = false, 
            Body = Blob.valueOf('Unit Test Attachment Body Two'), 
            Description = '15');
        insert attachment;
        
        genesis__Application_Document_Category__c adc = new genesis__Application_Document_Category__c();
        adc.name = DOC_NAME;
        adc.genesis__Application__c = app.id;
        
        insert adc;
        
        DCp_Arcus_Transactions__c DCP_obj = new DCp_Arcus_Transactions__c();
        DCP_obj.Application__c = app.Id;
        DCP_obj.Card_Number__c = '1234568';
        DCP_obj.Bank_Name__c = 'CITI';
        DCP_obj.Pay_at_Funding__c = true;
        DCP_obj.Requested_Amount__c = 200;
        DCP_obj.Transaction_id__c = '87007jj798889';
        insert DCP_obj;

        
        try {
            InvokeDCP.InvokeDCP(app.Id);
            
        } catch (Exception ex) {
            System.debug(logginglevel.Error, ex.getMessage());
        }

        test.stopTest();
       
    }


}