@isTest
public class TestUpdatePromissoryFieldJob {
    static testMethod void testPromissoryFieldJob(){
        
        
        MW_Settings__c customSetting = new MW_Settings__c();
		customSetting.TagsAPI_URL__c = 'https://sfapi-dev.payoff.com/lsa/api/v1/resource_tagging/add_tag';
		customSetting.CertificateNameForLEADS__c = 'sfapi_staging';
        customSetting.CLSDSIntgnTurnOff__c = false;
		insert customSetting;
        TestTriggerParameter.disableTriggerHandler(true);
        System.assertEquals(true, TestTriggerParameter.disableTriggerTest);
        Test.startTest();
        Account InvAcc = new Account(Name = 'TestInvestor', peer__First_Name__c='TestInv_PeerFName', 
            peer__Last_Name__c='TestInv_PeerLName', loan__Investor__c=True);
        Insert InvAcc;  
        Account acc = new Account(
            Name = 'TestAcc',
            loan__Investor__c=false,
            peer__First_Name__c='Test_PeerFName', 
            peer__Last_Name__c='Test_PeerLName',
            ints__SSN__c='123456789', 
            peer__Date_of_Birth__c=System.today(),
            Address_1__c='TestAddr1', 
            Address_2__c='TestAddr2', 
            City__c='Test_City',
            State__c='Test_State', 
            ZIP_Code__c='12345', 
            Suffix__c='Mr',
            Phone='2345677', 
            peer__Email__c='test@testOrg.com',
            Payoff_UID__c='1324325346547', 
            cnotify__Email__c='notify@testOrg.com',
            loan__social_security_number__c = '123456789',
            US_Citizen__c=true);
        Insert acc;
        genesis__Applications__c app = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            Investor__c = InvAcc.Id, 
            genesis__Account__c = acc.Id,
            Lead_ID__c='716d3efb-0047-4f93-9909-6fedfaa779781',
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'agent_verified',
            DocuSignFlag__c=true,
            genesis__Draw_Period_End_Date__c = system.Today()
        );
        Insert app; 
        
        genesis__Employment_Information__c empInfo = new genesis__Employment_Information__c(
            genesis__Application__c = app.Id,
            Income_Include_Bonuses_or_Commissions__c = false,
            genesis__Name_of_employer__c = 'Test',
            genesis__Number_of_years_on_job__c = 5,
            genesis__Phone__c = '1234567890',
            genesis__Position__c = 'Position',
            Work_Email__c = 'test@gmail.com'
        );
        insert empInfo;
        
        genesis__Document_Category__c docType = new genesis__Document_Category__c(
            genesis__Category_Name__c='ESign Documents',
            Application_Status__c=app.genesis__Status__c
        );
        insert docType;
        
        DocuSign_Template__c DSTemplate = new DocuSign_Template__c(
            Name='Test_DSTemplate', 
            Template_Id__c='12345678', 
            State__c='Test_State,Test_state1',  
            Account__c =InvAcc.Id, 
            Document_Category__c=docType.Id,
            Active__c = True
        );
        Insert DSTemplate;
        dsfs__DocuSign_Status__c dfsStatus = new dsfs__DocuSign_Status__c();
        dfsStatus.Application__c = app.id;
        dfsStatus.dsfs__Envelope_Status__c ='Sent';
        dfsStatus.dsfs__Sent_Date_Time__c = Date.today()-1;
        dfsStatus.dsfs__DocuSign_Envelope_ID__c = '1234dfgwdw1e23';
        insert dfsStatus;
        loan__Bank_Account__c ba = new loan__Bank_Account__c(
            loan__Bank_Account_Number__c = '123234324',
            loan__Bank_Name__c = 'Test_Bank',
            loan__Routing_Number__c = '999999999',
            Unmasked_Bank_Account_Number__c = '123234324',
            loan__Account_Type__c = 'Checking',
            loan__Account__c = acc.Id,
            loan__Active__c = true
        );
        insert ba;
        
        Pricing_Offer__c pOffer = new Pricing_Offer__c(
            Application__c=app.Id, 
            Amount__c=1000, 
            Interest_Rate__c=2.0, 
            Monthly_Payment__c=99, 
            Term__c=5,
            Is_Offer_Selected__c=true
        );
        Insert pOffer;
        
        genesis__Amortization_Schedule__c amSchedle = new genesis__Amortization_Schedule__c(
            genesis__Due_Date__c=System.Today(),
            genesis__Application__c=app.Id
        );
        Insert amSchedle;

		String chron = '0 0 23 * * ?';
		Id scheduleId = System.schedule('Test UpdatePromissoryFieldsDocusignJob', chron, new UpdatePromissoryFieldsDocusignJob());
		System.assertNotEquals(null, scheduleId);
		Test.stopTest();        
    }
}