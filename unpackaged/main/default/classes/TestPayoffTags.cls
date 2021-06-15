@isTest
public class TestPayoffTags {
     testmethod static void method1(){
         /*CRM-32*/
         TLO_URL_Config__c tlo = new TLO_URL_Config__c();
         tlo.TLO_URL__c = 'https://doppio-leads-dev.int.payoff.com/';
         tlo.TLOURLappname__c = 'verification';   
         insert tlo;
         /*CRM-32*/
         //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            //Borrower_s_Last_Name__c='Testborrower',
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert acc;
         List<Id> IDs = new List<Id>();
        System.assertEquals('Test',acc.Name,'Wrong Account');
         //Creating Application
        genesis__Applications__c app1= new genesis__Applications__c(
                                            genesis__Due_Day__c = 10,
                                            genesis__Expected_First_Payment_Date__c = system.Today(),
                                            genesis__Expected_Start_Date__c = system.Today(),
                                            genesis__Funding_in_Tranches__c = true,
                                            Borrower_s_Email__c = null,
                                            genesis__Account__c = acc.Id,
                                            Application_Start_DateV2__c = system.Today(),
                                            DocuSignFlag__c=true,
                                            genesis__Status__c = 'agent_verified',
                                            genesis__Draw_Period_End_Date__c = system.Today()
                                            );
        insert app1;
         IDs.add(app1.id);
        System.assertEquals(null,app1.Borrower_s_Email__c,'Borrower Email is not null');
         genesis__Applications__c app= new genesis__Applications__c(
                                            genesis__Due_Day__c = 20,
                                            genesis__Expected_First_Payment_Date__c = system.Today(),
                                            genesis__Expected_Start_Date__c = system.Today(),
                                            genesis__Funding_in_Tranches__c = true,
                                            Borrower_s_Email__c = null,
                                            genesis__Account__c = acc.Id,
                                            Application_Start_DateV2__c = system.Today(),
                                            DocuSignFlag__c=true,
                                            genesis__Status__c = 'offer_accepted',
                                            genesis__Draw_Period_End_Date__c = system.Today()
                                            );
        insert app;
         IDs.add(app.id);
        System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');
        test.startTest();
         PayoffTags.TagsParameter t = new PayoffTags.TagsParameter();
         t.apps = app.id;
         t.tag = 'Test';
         List<PayoffTags.TagsParameter> tagList = new List<PayoffTags.TagsParameter>();
         taglist.add(t);
        PayoffTags.appToPayoffTags(taglist);
        test.stopTest();
     }
     testmethod static void method2(){
         //Creating Account
         CL_Document__c cs = new CL_Document__c();
         cs.Doc1__c = 'Credit';
         cs.Doc2__c = 'Til';
         insert cs;
         
         /*CRM-32*/
         TLO_URL_Config__c tlo = new TLO_URL_Config__c();
         tlo.TLO_URL__c = 'https://doppio-leads-dev.int.payoff.com/';
         tlo.TLOURLappname__c = 'verification';   
         insert tlo;
         /*CRM-32*/

         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            //Borrower_s_Last_Name__c='Testborrower',
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert acc;
         List<Id> IDs = new List<Id>();
        System.assertEquals('Test',acc.Name,'Wrong Account');
         //Creating Application
        genesis__Applications__c app1= new genesis__Applications__c(
                                            genesis__Due_Day__c = 10,
                                            genesis__Expected_First_Payment_Date__c = system.Today(),
                                            genesis__Expected_Start_Date__c = system.Today(),
                                            genesis__Funding_in_Tranches__c = true,
                                            Borrower_s_Email__c = null,
                                            genesis__Account__c = acc.Id,
                                            Application_Start_DateV2__c = system.Today(),
                                            DocuSignFlag__c=true,
                                            genesis__Status__c = 'agent_verified',
                                            genesis__Draw_Period_End_Date__c = system.Today()
                                            );
        insert app1;
         IDs.add(app1.id);
        System.assertEquals(null,app1.Borrower_s_Email__c,'Borrower Email is not null');
         genesis__Applications__c app= new genesis__Applications__c(
                                            genesis__Due_Day__c = 20,
                                            genesis__Expected_First_Payment_Date__c = system.Today(),
                                            genesis__Expected_Start_Date__c = system.Today(),
                                            genesis__Funding_in_Tranches__c = true,
                                            Borrower_s_Email__c = null,
                                            genesis__Account__c = acc.Id,
                                            Application_Start_DateV2__c = system.Today(),
                                            DocuSignFlag__c=true,
                                            genesis__Status__c = 'offer_accepted',
                                            genesis__Draw_Period_End_Date__c = system.Today()
                                            );
        insert app;
         genesis__Document_Category__c docCat = new genesis__Document_Category__c(
            genesis__Category_Name__c = 'Test_Paystub_Id',
            genesis__Required__c = true
        );
        Insert docCat;
        genesis__Application_Document_Category__c appDocCat = new genesis__Application_Document_Category__c(
            Name = 'Test_AppDocCat',
            genesis__Document_Category__c = docCat.Id,
            genesis__Application__c = app.Id,
            genesis__Status__c = 'SUBMITTED'
        );
         Insert appDocCat;
         IDs.add(app.id);
        //System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');
        test.startTest();
         PayoffTags.TagsParameter t = new PayoffTags.TagsParameter();
         t.apps = app.id;
         t.tag = 'Test';
         List<PayoffTags.TagsParameter> tagList = new List<PayoffTags.TagsParameter>();
         taglist.add(t);
        PayoffTags.appToPayoffTags(taglist);
        test.stopTest();
     }
    testmethod static void method3(){
         /*CRM-32*/
         TLO_URL_Config__c tlo = new TLO_URL_Config__c();
         tlo.TLO_URL__c = 'https://doppio-leads-dev.int.payoff.com/';
         tlo.TLOURLappname__c = 'verification';   
         insert tlo;
         /*CRM-32*/
         //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            //Borrower_s_Last_Name__c='Testborrower',
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert acc;
         List<Id> IDs = new List<Id>();
        System.assertEquals('Test',acc.Name,'Wrong Account');
         //Creating Application
        genesis__Applications__c app1= new genesis__Applications__c(
                                            genesis__Due_Day__c = 10,
                                            genesis__Expected_First_Payment_Date__c = system.Today(),
                                            genesis__Expected_Start_Date__c = system.Today(),
                                            genesis__Funding_in_Tranches__c = true,
                                            Borrower_s_Email__c = null,
                                            genesis__Account__c = acc.Id,
                                            Application_Start_DateV2__c = system.Today(),
                                            DocuSignFlag__c=true,
                                            genesis__Status__c = 'agent_verified',
                                            genesis__Draw_Period_End_Date__c = system.Today()
                                            );
        insert app1;
         IDs.add(app1.id);
        System.assertEquals(null,app1.Borrower_s_Email__c,'Borrower Email is not null');
         genesis__Applications__c app= new genesis__Applications__c(
                                            genesis__Due_Day__c = 20,
                                            genesis__Expected_First_Payment_Date__c = system.Today(),
                                            genesis__Expected_Start_Date__c = system.Today(),
                                            genesis__Funding_in_Tranches__c = true,
                                            Borrower_s_Email__c = null,
                                            genesis__Account__c = acc.Id,
                                            Application_Start_DateV2__c = system.Today(),
                                            DocuSignFlag__c=true,
                                            genesis__Status__c = 'offer_accepted',
                                            genesis__Draw_Period_End_Date__c = system.Today()
                                            );
        insert app;
        /* genesis__Document_Category__c docCat = new genesis__Document_Category__c(
            genesis__Category_Name__c = 'Test_Paystub_Id',
            genesis__Required__c = true
        );
        Insert docCat;
        genesis__Application_Document_Category__c appDocCat = new genesis__Application_Document_Category__c(
            Name = 'Test_AppDocCat',
            genesis__Document_Category__c = docCat.Id,
            genesis__Application__c = app.Id,
            genesis__Status__c = 'SUBMITTED'
        );
         Insert appDocCat;*/
        Application_Tags__c apptags = new Application_Tags__c(
            Application__c = app.Id,
        Application_Tag__c = 'New Documents');
         IDs.add(app.id);
        //System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');
        test.startTest();
         PayoffTags.TagsParameter t = new PayoffTags.TagsParameter();
         t.apps = app.id;
         t.tag = 'New Interaction';
         List<PayoffTags.TagsParameter> tagList = new List<PayoffTags.TagsParameter>();
         taglist.add(t);
        PayoffTags.appToPayoffTags(taglist);
        test.stopTest();
     }
}