/* ****************Modification History******************
*    Created By        	 Date			Version
*1. Bhavya Maliwal        2022/02/21   LSP-548 Initial Version

******************Modification History******************/
@isTest
public class TestPayoffTags {
    @testSetup
    static void setup(){
        //Creating Account
        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            peer__Last_Name__c='TestLName1',
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123123123'
        );
        insert acc;
        List<Id> ids = new List<Id>();
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
        ids.add(app1.id);
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
        ids.add(app.id);
    }
    /*Created By : Bhavya Maliwal
Method name : appToPayoffTagsNodoc
Purpose : to cover code satisfying appToPayoffTags
*/
    testmethod static void appToPayoffTagsNodoc(){
        //Creating Account
        Account acc = [Select id,name,peer__Last_Name__c from Account LIMIT 1];
        System.assertEquals('TestLName1',acc.peer__Last_Name__c,'Wrong Account');
        //Creating Application
        genesis__Applications__c app1= [Select id,genesis__Status__c,Borrower_s_Email__c from genesis__Applications__c 
                                        where genesis__Status__c = 'agent_verified' LIMIT 1 ];
        
        System.assertEquals('abc@test.com',app1.Borrower_s_Email__c,'Borrower Email is not null');
        genesis__Applications__c app= [Select id,genesis__Status__c,Borrower_s_Email__c from genesis__Applications__c 
                                       where genesis__Status__c = 'offer_accepted' LIMIT 1 ];
        
        
        System.assertEquals('abc@test.com',app.Borrower_s_Email__c,'Borrower Email is not null');
        test.startTest();
        PayoffTags.TagsParameter t = new PayoffTags.TagsParameter();
        t.apps = app.id;
        t.tag = 'Test';
        List<PayoffTags.TagsParameter> tagList = new List<PayoffTags.TagsParameter>();
        taglist.add(t);
        PayoffTags.appToPayoffTags(taglist);
        test.stopTest();
    }
    /*Created By : Bhavya Maliwal
Method name : appToPayoffTags_documentCheckisTrue
Purpose : to cover code satisfying appToPayoffTags where document check is True
*/
    testmethod static void appToPayoffTags_documentCheckisTrue(){
        //Creating Account
        CL_Document__c cs = new CL_Document__c();
        cs.Doc1__c = 'Credit';
        cs.Doc2__c = 'Til';
        insert cs;
        
        //Creating Account
        Account acc = [Select id,name,peer__Last_Name__c from Account LIMIT 1];
        System.assertEquals('TestLName1',acc.peer__Last_Name__c,'Wrong Account');
        //Creating Application
        genesis__Applications__c app1= [Select id,genesis__Status__c,Borrower_s_Email__c from genesis__Applications__c 
                                        where genesis__Status__c = 'agent_verified' LIMIT 1 ];
        
        
        System.assertEquals('abc@test.com',app1.Borrower_s_Email__c,'Borrower Email is not null');
        genesis__Applications__c app= [Select id,genesis__Status__c,Borrower_s_Email__c from genesis__Applications__c 
                                       where genesis__Status__c = 'offer_accepted' LIMIT 1 ];
        
        
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
        test.startTest();
        PayoffTags.TagsParameter t = new PayoffTags.TagsParameter();
        t.apps = app.id;
        t.tag = 'Test';
        List<PayoffTags.TagsParameter> tagList = new List<PayoffTags.TagsParameter>();
        taglist.add(t);
        PayoffTags.appToPayoffTags(taglist);
        test.stopTest();
        List<Application_Tags__c> atag=[Select id from Application_Tags__c where Application__c=:app.id];
        system.assert(atag.size()>0);
    }
    /*Created By : Bhavya Maliwal
Method name : interactionCheck
Purpose : to cover code satisfying InteractionCheck
*/
    testmethod static void interactionCheck(){
        //Creating Account
        Account acc = [Select id,name,peer__Last_Name__c from Account LIMIT 1];
        System.assertEquals('TestLName1',acc.peer__Last_Name__c,'Wrong Account');
        //Creating Application
        genesis__Applications__c app1= [Select id,genesis__Status__c,Borrower_s_Email__c from genesis__Applications__c 
                                        where genesis__Status__c = 'agent_verified' LIMIT 1 ];
        
        System.assertEquals('abc@test.com',app1.Borrower_s_Email__c,'Borrower Email is not null');
        genesis__Applications__c app= [Select id,genesis__Status__c,Borrower_s_Email__c from genesis__Applications__c 
                                       where genesis__Status__c = 'offer_accepted' LIMIT 1 ];
        
        test.startTest();
        PayoffTags.TagsParameter t = new PayoffTags.TagsParameter();
        t.apps = app.id;
        t.tag = 'New Interaction';
        List<PayoffTags.TagsParameter> tagList = new List<PayoffTags.TagsParameter>();
        taglist.add(t);
        PayoffTags.appToPayoffTags(taglist);
        test.stopTest();
        List<Application_Tags__c> at=[Select id from Application_Tags__c where Application__c=:app.id];
        system.assert(at.size()>0);
    }
}