/***************************************************************************************************
Created By: Vikram Gehlot
Purpose: a reusable util class for test data insertion can only be invoked in test classes

****************************************************************************************************/
@isTest
public with sharing class MW_GlobalTestUtility {

    public static CL_Document__c getCLDocumentRecord() {
        CL_Document__c cs = new CL_Document__c();
        cs.Doc1__c = 'Credit Score Notice';
        cs.Doc2__c = 'TIL Document';
        cs.Doc3__c = 'Adverse Action Document';
        cs.UploadedBOX__c = 'UploadedBOX';
        cs.OrginaitionDocumentFolder__C = '1111111111';
        return cs;
    }

    public static MW_Settings__c GetSettings() {
        MW_Settings__c objSettings = new MW_Settings__c(
                SalesforceLimitsUrl__c = '/services/data/v45.0/limits',
                thresholdApiAndStorage__c = 70,
                thresholdFundingCaps__c = 80,
                MissingDocumentsAppStatuses__c = 'Approved for funding;agent_document_verification_pending;agent_verified;pre_funding;docusign_loan_docs_sent;docusign_loan_docs_complete;Stacker_Check_Passed;'

        );
        return objSettings;
    }

    public static string GetRecTypeId(string objName, string recTypeName) {
        string recTypeId = '';
        if (objName == 'Account') {
            recTypeId = string.isNotblank(recTypeName) && Schema.SObjectType.Account.getRecordTypeInfosByName().containsKey(recTypeName) ? (string) Schema.SObjectType.Account.getRecordTypeInfosByName().get(recTypeName).getRecordTypeId() : '';
        }
        return recTypeId;
    }

    public static Account GetAccount(string recordtype) {
        Account objAccount = new Account();
        if (recordtype == 'Investor') {
            objAccount.RecordTypeId = GetRecTypeId('Account', recordtype);
            objAccount.Name = 'AccountTest';
            objAccount.peer__First_Name__c ='Account';
            objAccount.peer__Last_Name__c = 'Test';
            objAccount.Annual_Funded_Cap__c = 100;
            objAccount.Total_Funded_YTD__c = 81;
            //Annual_Available_Balance__c = 19;
            objAccount.Monthly_Allocation_Cap__c = 100;
            objAccount.Total_Allocations_MTD__c = 81;
            //Current_Month_s_Available_Allocation__c = 19;
            objAccount.Monthly_Funded_Cap__c = 100;
            objAccount.Total_Funded_MTD__c = 81;
            //Current_Month_s_Available_Funded_Balance__c = 19;
            objAccount.loan__Investor__c = true;
            objAccount.loan__SOCIAL_SECURITY_NUMBER__c = string.valueOf(math.random()).right(9);

        }

        else if (recordtype == 'Member') {
            objAccount.RecordTypeId = GetRecTypeId('Account', recordtype);
            objAccount.Name = 'AccountTest';
            objAccount.peer__First_Name__c ='Account';
            objAccount.peer__Last_Name__c = 'Test';
            objAccount.loan__Investor__c = False;
            objAccount.cnotify__Email__c = 'test@happymoney.com';
            objAccount.Annual_Individual_Income__c = 100000;
            objAccount.Monthly_Housing_Payment__c = 1200;
            objAccount.loan__SOCIAL_SECURITY_NUMBER__c = string.valueOf(math.random()).right(9);
        }
        return objAccount;

    }

    public static Profile GetProfile(string name) {
        Profile profile = [SELECT Id FROM Profile WHERE Name = :name];
        return profile;
    }

    public static Application_Tags__c GetApplicationTag(string tagName) {
        Application_Tags__c appTag = new Application_Tags__c(
                Application_Tag__c = tagName
        );
        return appTag;
    }

    public static User GetUser(String userName) {
        User objUsr = new User(
                Alias = 'tu',
                Email = 'TestUser@HappyMoney.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'TestUser',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = userName
        );

        return objUsr;
    }


    public static genesis__Applications__c GetApplication() {

        genesis__Applications__c objApp = new genesis__Applications__c(
                genesis__Status__c = 'kba_fail',
                Investor__c = null,
                genesis__Days_Convention__c = 'ACTUAL/ACTUAL',
                //genesis__Account__c=acct,
                genesis__Interest_Calculation_Method__c = 'Declining Balance',
                genesis__Interest_Rate__c = 10.0000,
                Estimated_Amount_needed__c = 2000.00,
                genesis__Payment_Frequency__c = 'WEEKLY',
                genesis__Product_Type__c = 'LOAN',
                genesis__Term__c = 24,
                Estimated_credit_card_balances__c = 3000.00,
                genesis__Loan_Amount__c = 22120.00,
                Employment_Status__c = 'Retired',
                Application_Start_DateV2__c = system.Today(),
                genesis__Draw_Period_End_Date__c = system.Today(),
                genesis__Expected_First_Payment_Date__c = system.Today(),
                genesis__Expected_Start_Date__c = system.Today(),
                LEAD_ID__C = 'c9149473-e69f-ee12-38a7-d18b0cba847d');
        return objApp;
    }

    // Application Object Alert using same util class to cover testing
    public static genesis__Application_Document_Category__c GetApplicationDocumentCategory() {
        genesis__Application_Document_Category__c objAdc = new genesis__Application_Document_Category__c(
                name = 'CU Membership',
                genesis__Active__c = true,
                //genesis__Document_Category__c =  dc.id,
                //genesis__Application__c = genesis_applications_Obj.id;
                Box_URl__c = ''
        );

        return objAdc;
    }


    // Create Bank Account
    Public static loan__Bank_Account__c GetBankAccount() {
        loan__Bank_Account__c ba = new loan__Bank_Account__c(
                loan__Bank_Account_Number__c = 'XXXXXXXX1212',
                loan__Bank_Name__c = 'Some Bank',
                loan__Routing_Number__c = '999999999',
                loan__Account_Type__c = 'Checking',
                // Unmasked_Bank_Account_Number__c = accid,
                loan__Account_Usage__c = 'Borrower/Investor Account',
                //loan__Contact__c = conid,
                //loan__Account__c = accid,
                loan__Active__c = True);

        return ba;

    }
    Public static LoanPaymentDays__c GetLoanPaymentDays() {
        LoanPaymentDays__c lpdays = new LoanPaymentDays__c(
                AutoPaymentRemainder__c = 3,
                ManualPaymentRemainder__c = 5);
        return lpdays;

    }

    Public static loan__Loan_Product__c GetLoanProduct() {
        loan__Loan_Product__c loanProdObj = new loan__Loan_Product__c(name = 'TestProduct');
        return loanProdObj;

    }

    Public static Contact GetContact() {
        Contact a1 = new Contact(LastName = 'TestACH');
        return a1;
    }

    Public static loan__Payment_Mode__c GetPMode() {
        loan__Payment_Mode__c pMode = new loan__Payment_Mode__c(Name = 'CASH');
        return pMode;
    }

    Public static loan__Payment_Mode__c GetPMode1() {
        loan__Payment_Mode__c pMode1 = new loan__Payment_Mode__c(Name = 'ACH');
        return pMode1;

    }

    Public static loan__Loan_Account__c GetCLContract() {
        loan__Loan_Account__c lacc = new loan__Loan_Account__c(
                //loan__Account__c= acc.Id,
                //loan__Contact__c= a1.ID,
                loan__Product_Type__c = 'Flexible Amz Loan',
                loan__Loan_Amount__c = 5000,
                //loan__Loan_Product_Name__c=loanProdObj.Id,
                loan__Payment_Amount__c = 439.70,
                loan__Principal_Remaining__c = 4243.60,
                loan__Previous_Installment_Date__c = system.today(),
                //application__c = application.id,
                loan__First_Installment_Date__c = Date.newInstance(2020, 03, 01),
                loan__Next_Installment_Date__c = Date.newInstance(2020, 05, 01),
                loan__Maturity_Date_Current__c = Date.newInstance(2021, 02, 01),
                loan__Frequency_of_Loan_Payment__c = 'Monthly',
                loan__Last_Installment_Date__c = Date.newInstance(2021, 02, 01),
                loan__Loan_Status__c = 'Active - Good Standing',
                loan__Interest_Rate__c = 10,
                loan__Term_Cur__c = 12,
                Skipped_a_pay_Date__c = null,
                Skipped_a_Pay__c = false,
                lead_guid__c = 'TestClassGuid0',
                loan__Disbursal_Date__c = Date.newInstance(2020, 02, 01));

        return lacc;
    }

    public static Pricing_Offer__c getPricingOffer(string tier) {
        Pricing_Offer__c pOfferTrue = new Pricing_Offer__c();
        pOfferTrue.Above_prime_max__c = 'false';
        pOfferTrue.Amount__c = 8000;
        //pOfferTrue.Application__c =app.id;
        pOfferTrue.APR__c = 11.997986061655;
        pOfferTrue.Interest_Rate__c = 9.97;
        pOfferTrue.Is_Offer_Selected__c = true;
        pOfferTrue.Key__c = 6;
        pOfferTrue.Monthly_Payment__c = 215.489647581694;
        pOfferTrue.Origination_fee__c = 160;
        pOfferTrue.Origination_fee_rate__c = 2;
        pOfferTrue.Pricing_Tier__c = 'tier';
        pOfferTrue.Segment__c = 'prime';
        pOfferTrue.Term__c = 24;
        pOfferTrue.Type__c = 'ABC';
        return pOfferTrue;
    }

    Public static Approved_Offer__c getApprovedOffer() {
        Approved_Offer__c appOffer = new Approved_Offer__c();
        appOffer.Above_prime_max__c = 'false';
        appOffer.Amount__c = 1200.00;
        //Application__c=app.id;
        appOffer.APR__c = '11.99';
        appOffer.Interest_Rate__c = '9.97';
        appOffer.Key__c = '5';
        appOffer.Monthly_Payment__c = 200;
        appOffer.Origination_fee__c = '150.00';
        appOffer.Origination_fee_rate__c = '2.00';
        appOffer.Pricing_Tier__c = 't2';
        appOffer.Segment__c = 'prime';
        appOffer.Term__c = 24;
        appOffer.Type__c = 'test' ;

        return appOffer;
    }

    Public static genesis__Employment_Information__c GetEmploymentInformation() {
        genesis__Employment_Information__c sobj = new genesis__Employment_Information__c(
                //Name = 'a7641000000fxTT',                       // Employment Information Name
                genesis__Name_of_employer__c = 'Payoff',          // Name of employer
                genesis__Position__c = 'Principal SDET',          // Position
                genesis__Number_of_years_on_job__c = 6,           // Number of years on job
                genesis__Self_Employed__c = false,                // Self Employed
                Work_Email__c = 'qa+9898989893@happymoney.com',   // Work Email
                Work_email_verified_check_box__c = false,         // Work email verified check box
                Income_Include_Bonuses_or_Commissions__c = false, // Income Include Bonuses or Commissions
                Neo_Verify__c = NULL
        );
        return sobj;
    }

    Public static KBA_Details__c GetKbaDetails() {
        KBA_Details__c sobj = new KBA_Details__c(
                //Name = 'aC12M00000004SH',        // KBA Details Name
                //Account__c = '0012M00002K0tjr',    // Account
                //Application__c = 'a6h2M000000H02M',// Application
                Precise_ID_Decision__c = 'Accept', // Precise ID Decision
                Precise_ID_Overall_SCore__c = 9012, // Precise ID Overall Score
                Precise_ID_OFAC__c = '1',          // Precise ID OFAC
                OFAC_Description__c = 'No match',  // OFAC Description
                Precise_ID_Fraud_Classification__c = 'IMP', // Precise ID Fraud Classification
                Fraud_Description__c = 'Impersonation Match', // Fraud Description
                Precise_ID_Adverse_Action_Code__c = 'Fair Credit Billing Act dispute on-file codeG">Fair Credit Reporting Act dispute on-file</AdverseActionCode2>',  // Precise ID Adverse Action Code
                SSN_Result__c = 'YA',              // SSN Result
                SSN_Result_Description__c = 'Match to full name and address-Match performed using SSN', // SSN Result Description
                Date_of_Birth_Match__c = '6',      // Date of Birth Match
                Date_of_Birth_Match_Description__c = 'DOB not provided on request',// Date of Birth Match Description
                Phone_Verification_Result__c = 'MA', // Phone Verification Result
                Phone_Verification_Result_Description__c = 'Match to header data(additional phone search found a match)', // Phone Verification Result Description
                Precise_ID_First_Payment_Default__c = 714,// Precise ID First Payment Default
                Precise_ID_Validation__c = 708,  // Precise ID Validation
                Precise_ID_ID_Theft__c = 494,    // Precise ID ID Theft
                Precise_ID_Reference_Number__c = '44d68197-8358-c0b9-4758-55a3c3', // Precise ID Reference Number
                Precise_ID_Reference_ID__c = '430227456',   // Precise ID Reference ID
                SSN_Issue_Date__c = '1982',        // SSN Issue Date
                SSN_Issue_End_Date__c = '1984',    // SSN Issue End Date
                Precise_ID_Decision_KIQ__c = 'No Decision', // Precise ID Decision (KIQ) - //No Decision,Accept,Refer, ''
                Precise_ID_Score_KIQ__c = 544,   // Precise ID Score (KIQ)
                Precise_ID_Reference_Number_KIQ__c = '44d68197-8358-c0b9-4758-55a3c3', // Precise ID Reference Number (KIQ)
                Precise_ID_Reference_ID_KIQ__c = '430226964', // Precise ID Reference ID (KIQ)
                Id_Analytics_Score__c = 463,     // Id Analytics Score
                Consistency_Snapd_score__c = 81, // Consistency Snapd score
                KBA_Attempts__c = 1,             // KBA Attempts
                Paste_Count__c = 0,              // Paste Count
                Public_Records__c = 81,          // Public Records
                IsKBA_06__c = true,                // IsKBA_06
                IsKBA_18__c = true,                // IsKBA_18
                Accept_Refer_Code__c = 'ACC'      // Accept Refer Code
        );
        return sobj;
    }

    Public static Talx__c GetTalx() {
        Talx__c sobj = new Talx__c(
                //Application__c = 'a6h410000004OV8',         // Application
                //Account__c = '0014100001zMZlu'             // Account
                Employeer__c = 'Test Employer',             // Employeer
                Salary__c = 100000,                         // Salary
                Length_of_Employement__c = '143',           // Length of Employement
                Hire_Date__c = Date.valueOf(System.Today().addDays(-400)),  // Hire Date
                Position__c = '9INSTRDF',                   // Position
                API__c = true                              // API
        );
        return sobj;
    }
}