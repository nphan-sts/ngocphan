public with sharing class TestDataFactory {
    public static final String SUFFIX_EMAIL = '@testorganization.com';
    public static Account createTestAccount() {
        return new Account(
            Name = 'Test Account',
            loan__Investor__c = false,
            cnotify__Email__c = 'test@test.com',
            peer__First_Name__c = 'Test',
            peer__Last_Name__c = 'Account',
            loan__SOCIAL_SECURITY_NUMBER__c = string.valueOf(math.random()).right(9)
            //social_security_number_uniqueness_field__c = string.valueOf(math.random()).right(9)
        );
    }

    public static Account createTestInvestor() {
        return new Account(
            Name = 'TEST',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Number_Of_Applications_Invested__c = 3,
            Total_No_of_Application_Limit__c = 30,
            Last_Application_assigned_on__c = System.now() - 7,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply' + SUFFIX_EMAIL,
            peer__First_Name__c = 'TestFirstName',
            peer__Last_Name__c = 'TestLastName',
            loan__Active__c = 'YES',
            City__c = 'CANADA',
            State__c = 'CA',
            ZIP_Code__c = '123456',
            loan__SOCIAL_SECURITY_NUMBER__c = '987654321',
            social_security_number_uniqueness_field__c = '987654321'
        );
    }

    public static genesis__Applications__c createTestApplication(
        Id acctId,
        Id invId,
        String leadId,
        Date originationDate,
        String status
    ) {
        return new genesis__Applications__c(
            Lead_ID__c = leadId,
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = System.today(),
            genesis__Expected_Start_Date__c = System.today(),
            genesis__Funding_in_Tranches__c = true,
            Borrower_s_Email__c = null,
            genesis__Account__c = acctId,
            Investor__c = invId,
            Application_Start_DateV2__c = System.today(),
            DocuSignFlag__c = true,
            genesis__Status__c = String.isBlank(status) ? 'agent_verified' : status,
            genesis__Draw_Period_End_Date__c = System.today(),
            Loan_Origination_Date__c = originationDate == null ? Date.today().addDays(2) : originationDate
        );
    }

    public static clcommon__Party_Type__c createTestPartyType(String name) {
        return new clcommon__Party_Type__c(name = name);
    }

    public static genesis__Document_Category__c createTestDocumentCategory(Id partyTypeId, String code) {
        return new genesis__Document_Category__c(
            genesis__Responsible_Party_Type__c = partyTypeId,
            genesis__Applicable_For__c = 'PARTY',
            Code_FF__c = code
        );
    }

    public static genesis__Document_Category__c createTestDocumentCategory(
        Id partyTypeId,
        String catName,
        String code
    ) {
        return new genesis__Document_Category__c(
            genesis__Responsible_Party_Type__c = partyTypeId,
            genesis__Applicable_For__c = 'PARTY',
            genesis__Category_Name__c = catName,
            Code_FF__c = code
        );
    }

    public static genesis__Application_Document_Category__c createTestApplicationDocumentCategory(
        String name,
        Id appId,
        Id catId,
        String boxUrl,
        String status
    ) {
        return new genesis__Application_Document_Category__c(
            name = name,
            genesis__Active__c = true,
            genesis__Application__c = appId,
            genesis__Document_Category__c = catId,
            Box_URl__c = boxUrl,
            genesis__Status__c = status
        );
    }

    public Dataset dataset = new Dataset();
    public static String ADMIN_USERNAME = 'admin.testclass1234567890@mail.com';
    public static String ADMIN_EMAIL = 'admin_email.testclass@happymoney.com';

    /******************************* Create Data *******************************/
    public static User createSysAdmin() {
        // Profile
        List<Profile> profile = [
            SELECT Id
            FROM Profile
            WHERE UserType = 'standard' AND Name LIKE 'System Administrator'
        ];
        // Username
        String uniqueName =
            UserInfo.getOrganizationId() + // Org Id
            Datetime.now().format('yyyyMMddHHmmssSSS') + // Current Datetime
            Integer.valueOf(Math.rint(Math.random() * (2000000 - 1))); // Random
        // User
        User user = new User(
            FirstName = uniqueName.subString(29, 34),
            LastName = uniqueName.subString(30, 35),
            Email = ADMIN_EMAIL,
            UserName = ADMIN_USERNAME,
            EmailEncodingKey = 'UTF-8',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ProfileId = profile[0].Id,
            PostalCode = '123456789',
            Department = 'test',
            Phone = '123456789',
            Fax = '123456789',
            CompanyName = 'Company'
        );
        insert user;
        return user;
    }

    public List<genesis__Applications__c> createApplications() {
        this.dataset.applications = prepareApplications(this.dataset);

        return this.dataset.applications;
    }

    /******************************* Prepare Data *******************************/
    public static List<genesis__Applications__c> prepareApplications(Dataset dataset) {
        List<genesis__Applications__c> applications = new List<genesis__Applications__c>();

        Account acc = new Account(
            Name = 'Test0',
            loan__Investor__c = false,
            cnotify__Email__c = 'no-reply0@testorganization.com',
            peer__First_Name__c = 'TestFName0',
            peer__Last_Name__c = 'TestLName0',
            City__c = 'TestCity',
            State__c = 'TestState',
            ZIP_Code__c = '123456'
        );
        insert acc;

        Account investor = new Account(
            Name = 'TestInvestor',
            loan__Investor__c = true,
            Amount_Invested__c = 1200,
            Number_Of_Applications_Invested__c = 3,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123',
            Investor_Code__c = 'FTCU'
        );
        insert investor;

        list<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(1, acc.Id);
        insert appList;

        appList[0].genesis__Bank_Name__c = 'TEST';
        appList[0].genesis__Account__c = acc.Id;
        appList[0].genesis__Bank_Account_Number__c = '0123456780';
        appList[0].genesis__Bank_Account_Type__c = 'Checking';
        appList[0].genesis__Bank_Name__c = 'Testing Bank';
        appList[0].Borrower_s_Email__c = 'borrowerEmail0' + SUFFIX_EMAIL;
        appList[0].Borrowers_Work_Email__c = 'borrowerWorkEmail0' + SUFFIX_EMAIL;
        appList[0].Investor__c = investor.Id;
        appList[0].genesis__Due_Day__c = 20;
        appList[0].genesis__Expected_First_Payment_Date__c = system.Today();
        appList[0].genesis__Expected_Start_Date__c = system.Today();
        appList[0].genesis__Funding_in_Tranches__c = true;
        appList[0].Borrower_s_Email__c = null;
        appList[0].Bureau_SSN__c = '21616590';
        appList[0].Loan_Doc_Signed_On__c = Date.newInstance(2013, 12, 13);
        appList[0].Anniversary_Date__c = null;
        appList[0].Invested_Amount__c = 1000;
        appList[0].genesis__loan_amount__c = 1000;
        appList[0].Application_Start_DateV2__c = null;
        appList[0].DocuSignFlag__c = true;
        appList[0].genesis__Status__c = 'NEW - ENTERED';
        appList[0].genesis__term__c = 36;
        appList[0].genesis__payment_frequency__c = 'Monthly';
        appList[0].genesis__Draw_Period_End_Date__c = system.Today();

        update appList[0];
        applications.add(appList[0]);

        return applications;
    }

    /******************************* Get Data *******************************/
    public static User retrieveTestUserAdmin() {
        List<User> users = [
            SELECT
                Id,
                Name,
                Username,
                LastName,
                Email,
                Alias,
                TimeZoneSidKey,
                LocaleSidKey,
                EmailEncodingKey,
                ProfileId,
                LanguageLocaleKey
            FROM User
            WHERE UserName = :ADMIN_USERNAME
        ];
        return users.isEmpty() ? new User() : users[0];
    }

    public class Dataset {
        public List<genesis__Applications__c> applications = new List<genesis__Applications__c>();
    }
}