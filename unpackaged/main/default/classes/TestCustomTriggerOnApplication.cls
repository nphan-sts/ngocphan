@isTest
public class TestCustomTriggerOnApplication {
    //Before update
    public static void mwSettingSetup(){
        MW_Settings__c mwSetting = new MW_Settings__c();
        mwSetting.API_User_Filter__c = 'test@example.com';
        insert mwSetting;
    }

    testmethod static void method1(){
        //mwSettingSetup();

        CL_Document__c doc = new CL_Document__c();
        doc.Doc1__c = 'Credit File';
        doc.Doc2__c = 'Til File';
        insert doc;

        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');

        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount,dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);

        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();

        //Creating Account
        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c = True,
            Amount_Invested__c = 1200,
            Number_Of_Applications_Invested__c =3,
            cnotify__Email__c = 'abc@test.com',
            peer__First_Name__c ='Test',
			peer__Last_Name__c = 'Account',
            loan__SOCIAL_SECURITY_NUMBER__c = string.valueOf(math.random()).right(9),
            Investor_Code__c = 'TNA'
            );
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');

    //CRM-543 start
    TLO_URL_Config__c tlo = new TLO_URL_Config__c();
        tlo.TLO_URL__c = 'https://doppio-leads-dev.int.payoff.com/';
        tlo.TLOURLappname__c = 'verification';
        insert tlo;
        //CRM-543 end

        //Creating Another Account
        Account acc1 = new Account(
            Name = 'TestNewAccount',
            Amount_Invested__c = 1100,
            loan__Investor__c=True,
            Number_Of_Applications_Invested__c =2,
            cnotify__Email__c = 'abcd@test.com',
            peer__First_Name__c ='Test',
			peer__Last_Name__c = 'NewAccount',
            loan__SOCIAL_SECURITY_NUMBER__c = string.valueOf(math.random()).right(9),
            Investor_Code__c = 'TNA'
            );
        insert acc1;
        System.assertEquals('TestNewAccount',acc1.Name,'Wrong Account');
        TalxInt__c TalxIntegrationSetting =new TalxInt__c();
        TalxIntegrationSetting.APPID__c = 'PAYOFF';
        TalxIntegrationSetting.APPVER__c = 1;
        TalxIntegrationSetting.TalxCertificateName__c = 'equifax';
        TalxIntegrationSetting.DTCLIENT__c = '20170612131212';
        TalxIntegrationSetting.Endpoint__c = 'https://test.ofx4.talx.com/verifierinterimct2/xmlb2b_router.dll';
        TalxIntegrationSetting.USERID__c ='PayoffIntUsrTest@50005';
        TalxIntegrationSetting.USERPASS__c = 'payoffTalx12!';
        TalxIntegrationSetting.LANGUAGE__c = 'ENG';
        insert TalxIntegrationSetting;
        //Creating Application
        genesis__Applications__c app= new genesis__Applications__c(
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
        insert app;
        genesis__Application_Document_Category__c adc = new genesis__Application_Document_Category__c();
        adc.genesis__Application__c = app.Id;
        adc.Name = 'ESign Documents';
        insert adc;
        app.Anniversary_Date__c = system.today();
        app.Loan_Doc_Signed_On__c = Date.newInstance(2013,12,20);
        //app.Investor__c = acc1.id;
        app.Invested_Amount__c =1000;
        //app.Bureau_SSN__c ='216165345';
        app.genesis__Status__c = 'agent_verified';
        app.Last_Investor_Assigned_On__c = datetime.newInstance(2014, 9, 15, 13, 30, 0);
        update app;
        System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');


    }
    //After update
    testmethod static void method2(){
        mwSettingSetup();

        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');

        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount,dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);

        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();

        //CRM-543 start
    TLO_URL_Config__c tlo = new TLO_URL_Config__c();
        tlo.TLO_URL__c = 'https://doppio-leads-dev.int.payoff.com/';
        tlo.TLOURLappname__c = 'verification';
        insert tlo;
        //CRM-543 end

        //Creating Account
        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=True,
            Amount_Invested__c = 1200,
            Number_Of_Applications_Invested__c =3,
            cnotify__Email__c = 'abc@test.com',
            peer__First_Name__c ='Test',
			peer__Last_Name__c = 'Account',
            loan__SOCIAL_SECURITY_NUMBER__c = string.valueOf(math.random()).right(9),
            Investor_Code__c = 'TNA'
            );
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');

        //Creating Another Account
        Account acc1 = new Account(
            Name = 'TestNewAccount',
            loan__Investor__c=True,
            Number_Of_Applications_Invested__c =2,
            Amount_Invested__c = 1100,
            cnotify__Email__c = 'abcd@test.com',
            peer__First_Name__c ='Test',
			peer__Last_Name__c = 'NewAccount',
            loan__SOCIAL_SECURITY_NUMBER__c = string.valueOf(math.random()).right(9),
            Investor_Code__c = 'TNA'
            );
        insert acc1;
        System.assertEquals('TestNewAccount',acc1.Name,'Wrong Account');

        //Creating Application
        genesis__Applications__c app= new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            Borrower_s_Email__c = null,
            Bureau_SSN__c ='21616590',
            Loan_Doc_Signed_On__c = Date.newInstance(2013,12,13),
            Anniversary_Date__c = null,
            Investor__c = acc.id,
            Invested_Amount__c = 1000,
            genesis__loan_amount__c = 1000,
            genesis__Account__c = acc.Id,
            Application_Start_DateV2__c = null,
            DocuSignFlag__c=true,
            genesis__Status__c = 'agent_verified',
            genesis__Draw_Period_End_Date__c = system.Today()
            );
        insert app;
        //app.genesis__Status__c ='Default Documents';
        //update app;
        //System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');


    }

    /*testmethod static void method4(){
        //mwSettingSetup();

    //pallavi
         genesis__Rule__c rule = new genesis__Rule__c();
        rule.name                       = 'TCU ruleset';
        rule.genesis__Enabled__c        = true;
        rule.genesis__Object_Type__c    = 'genesis__Object_Type__c';
        insert rule;

         genesis__RuleCriteria__c rul = new genesis__RuleCriteria__c(
            genesis__Criteria_Sequence__c = 1.0,
            genesis__Field_API_Name__c    = 'genesis__Account__r.State__c',
            genesis__Field_Name__c        = 'State',
            genesis__Field_Type__c        = 'STRING',
            genesis__Matching_Type__c     = 'IN',
            genesis__Matching_Value__c    = 'AA,AE,AL,AK,AP,AZ,AR,CA,CO,CT,FL,GA,HI,ID,IL,IN,KS,KY,ME,MO,MT,NJ,NM,NY,ND,OR,PA,RI,SC,SD,TN,UT,WY,TS',
            genesis__Related_Object__c    = 'genesis__Applications__c',
            genesis__Rule_Object_Reference__c = 'genesis__Applications__c',
            genesis__Rule__c = rule.id,
            genesis__Stipulation_Type__c = 'FUNDING'
        );
        insert rul;
        Decimal investorWithLargestWeight = 0;
        Account acc = new Account(
            Name = 'Test1',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Investment_Rules__c = rule.id,
            Number_Of_Applications_Invested__c = 3,
            Total_No_of_Application_Limit__c = 30,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName2',
            loan__Active__c = 'YES',
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456',
            Investor_Alloted_Weight__c = 4,
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0
        );
        Insert acc;

         Account acc1 = new Account(
            Name = 'Test1',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Investment_Rules__c = rule.id,
            Number_Of_Applications_Invested__c = 3,
            Total_No_of_Application_Limit__c = 30,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName2',
            loan__Active__c = 'YES',
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456',
            Investor_Alloted_Weight__c = 4,
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0
        );
        Insert acc1;
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
        //pallavi
        CL_Document__c doc = new CL_Document__c();
        doc.Doc1__c = 'Credit File';
        doc.Doc2__c = 'Til File';
        insert doc;
        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');

        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount,dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);

        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();

        //Creating Account
       /* Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=True,
            Amount_Invested__c = 1200,
            Number_Of_Applications_Invested__c =3,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123',
            Investor_Code__c = 'TNA'
            );
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');*/

        //Creating Another Account
        /*Account acc1 = new Account(
            Name = 'TestNewAccount',
            loan__Investor__c=True,
            Number_Of_Applications_Invested__c =2,
            Amount_Invested__c = 1100,
            cnotify__Email__c = 'abcd@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '1234',
            Investor_Code__c = 'TNA'
            );
        insert acc1;
        System.assertEquals('TestNewAccount',acc1.Name,'Wrong Account');*/

        //Creating Application
        /*genesis__Applications__c app= new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            Borrower_s_Email__c = null,
            Bureau_SSN__c ='21616590',
            Loan_Doc_Signed_On__c = Date.newInstance(2013,12,13),
            Anniversary_Date__c = null,
            Investor__c = null,
            Invested_Amount__c = 1000,
            genesis__loan_amount__c = 1000,
            genesis__Account__c = acc.Id,
            Application_Start_DateV2__c = null,
            DocuSignFlag__c=true,
            genesis__Status__c = 'agent_verified',
            genesis__Draw_Period_End_Date__c = system.Today()
            );
        insert app;
        app.genesis__Status__c ='offer_accepted';
       /* System.debug('investor code');
        System.debug(app.Investor__r.Investor_code__c);
        //app.Investor__c = acc1.id;
        update app;
        System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');*/
        //update app;


    //}
    //Investor Account of application is null
    testmethod static void method3(){
        mwSettingSetup();

        //pallavi
         genesis__Rule__c rule = new genesis__Rule__c();
        rule.name                       = 'TCU ruleset';
        rule.genesis__Enabled__c        = true;
        rule.genesis__Object_Type__c    = 'genesis__Object_Type__c';
        insert rule;

         CL_Document__c document = new CL_Document__c();
         document.Doc1__c = 'Credit Score Notice';
         document.Doc2__c = 'TIL Document';
         document.Doc3__c = 'Adverse Action Notice';
         insert document;

         genesis__RuleCriteria__c rul = new genesis__RuleCriteria__c(
            genesis__Criteria_Sequence__c = 1.0,
            genesis__Field_API_Name__c    = 'genesis__Account__r.State__c',
            genesis__Field_Name__c        = 'State',
            genesis__Field_Type__c        = 'STRING',
            genesis__Matching_Type__c     = 'IN',
            genesis__Matching_Value__c    = 'AA,AE,AL,AK,AP,AZ,AR,CA,CO,CT,FL,GA,HI,ID,IL,IN,KS,KY,ME,MO,MT,NJ,NM,NY,ND,OR,PA,RI,SC,SD,TN,UT,WY,TS',
            genesis__Related_Object__c    = 'genesis__Applications__c',
            genesis__Rule_Object_Reference__c = 'genesis__Applications__c',
            genesis__Rule__c = rule.id,
            genesis__Stipulation_Type__c = 'FUNDING'
        );
        insert rul;
        Decimal investorWithLargestWeight = 0;
        Account acc = new Account(
            Name = 'Test1',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Investment_Rules__c = rule.id,
            Number_Of_Applications_Invested__c = 3,
            Total_No_of_Application_Limit__c = 30,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName2',
            loan__Active__c = 'YES',
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456',
            Investor_Alloted_Weight__c = 4,
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0
        );
        Insert acc;

        //CRM-543 start
    TLO_URL_Config__c tlo = new TLO_URL_Config__c();
        tlo.TLO_URL__c = 'https://doppio-leads-dev.int.payoff.com/';
        tlo.TLOURLappname__c = 'verification';
        insert tlo;
        //CRM-543 end

         Account acc1 = new Account(
            Name = 'Test1',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Investment_Rules__c = rule.id,
            Number_Of_Applications_Invested__c = 3,
            Total_No_of_Application_Limit__c = 30,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName2',
            loan__Active__c = 'YES',
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456',
            Investor_Alloted_Weight__c = 4,
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0
        );
        Insert acc1;
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
        //pallavi

        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');

        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount,dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);

        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();

        //Creating Account
       /* Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=True,
            Amount_Invested__c = 1200,
            Number_Of_Applications_Invested__c =3,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123',
            Investor_Code__c = 'TAN'
            );
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');*/

        //Creating Another Account
      /*  Account acc1 = new Account(
            Name = 'TestNewAccount',
            Amount_Invested__c = 1100,
            loan__Investor__c=True,
            Number_Of_Applications_Invested__c =2,
            cnotify__Email__c = 'abcd@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '1234',
            Investor_Code__c = 'TNA'
            );
        insert acc1;
        System.assertEquals('TestNewAccount',acc1.Name,'Wrong Account');*/
        List<genesis__Applications__c> list1 = new List<genesis__Applications__c>();
        List<genesis__Applications__c> list2 = new List<genesis__Applications__c>();
        Map<id,genesis__Applications__c> oldMap = new Map<id,genesis__Applications__c>();

        //Creating Application
        genesis__Applications__c app= new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            Borrower_s_Email__c = null,
            Bureau_SSN__c ='21616590',
            Loan_Doc_Signed_On__c = Date.newInstance(2013,12,13),
            Anniversary_Date__c = null,
            Investor__c = null,
            Invested_Amount__c =1000,
            genesis__loan_amount__c = 1000,
            genesis__Account__c = acc.Id,
            Application_Start_DateV2__c = null,
            Requested_loan_amount__c = 100000,
            DocuSignFlag__c=true,
            genesis__Status__c = 'agent_verified',
            genesis__Draw_Period_End_Date__c = system.Today(),
            genesis__term__c = 36,
            genesis__payment_frequency__c = 'Monthly'
            );
        insert app;

         Pricing_Offer__c  pOfferTrue = new Pricing_Offer__c();
        pOfferTrue.Above_prime_max__c= 'false';
        pOfferTrue.Amount__c = 8000;
        pOfferTrue.Application__c =app.id;
        pOfferTrue.APR__c = 11.997986061655;
        pOfferTrue.Interest_Rate__c =9.97;
        pOfferTrue.Is_Offer_Selected__c = true;
        pOfferTrue.Key__c = 6;
        pOfferTrue.Monthly_Payment__c = 215.489647581694;
        pOfferTrue.Origination_fee__c = 160;
        pOfferTrue.Origination_fee_rate__c = 2;
        pOfferTrue.Pricing_Tier__c = 't2';
        pOfferTrue.Segment__c = 'prime';
        pOfferTrue.Term__c = 24;
        pOfferTrue.Type__c = 'ABC';
        pOfferTrue.InvestorCodeOnApp__c = 'TA';
        insert pOfferTrue;
        Approved_Offer__c appOffer = new Approved_Offer__c(
                                            Above_prime_max__c = 'false',
                                            Amount__c = 1200.00,
                                            Application__c=app.id,
                                            APR__c ='11.99',
                                            Interest_Rate__c = '9.97',
                                            Key__c = '5',
                                            Monthly_Payment__c = 200,
                                            Origination_fee__c = '150.00',
                                            Origination_fee_rate__c = '2.00',
                                            Pricing_Tier__c = 't2',
                                            Segment__c = 'prime',
                                            Term__c = 24,
                                            Type__c ='test'

                                            );
        insert appOffer;


        list1.add(app);
        oldMap.put(app.Id,app);
        app.Anniversary_Date__c = system.today();
        app.Loan_Doc_Signed_On__c = Date.newInstance(2013,12,20);
        app.Investor__c = acc1.id;
        app.Invested_Amount__c =1000;
        app.Bureau_SSN__c ='216165345';
        app.Requested_loan_amount__c = 20000;
        app.genesis__Status__c = 'offer_accepted';
        app.Last_Investor_Assigned_On__c = datetime.newInstance(2014, 9, 15, 13, 30, 0);
        System.debug('BBBBBBBBBBBBBBBBBBBBBBB********----------' + app.investor__c);
        System.debug('BBBBBBBBBBBBBBBBBBBBBBB********----------' + app.genesis__Status__c);
        update app;
        list2.add(app);
        System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');
        CustomTriggerOnApplicationHandler cta = new CustomTriggerOnApplicationHandler(true);
        cta.runInvestorAllocationFieldsUpdate(list1,list2,oldMap);

    }
    @isTest static Void method5(){
        test.startTest();
        genesis__Rule__c rule = new genesis__Rule__c();
        rule.name                       = 'TCU ruleset';
        rule.genesis__Enabled__c        = true;
        rule.genesis__Object_Type__c    = 'genesis__Object_Type__c';
        insert rule;

         CL_Document__c document = new CL_Document__c();
         document.Doc1__c = 'Credit Score Notice';
         document.Doc2__c = 'TIL Document';
         document.Doc3__c = 'Adverse Action Notice';
         insert document;

        genesis__RuleCriteria__c rul = new genesis__RuleCriteria__c(
            genesis__Criteria_Sequence__c = 1.0,
            genesis__Field_API_Name__c    = 'genesis__Account__r.State__c',
            genesis__Field_Name__c        = 'State',
            genesis__Field_Type__c        = 'STRING',
            genesis__Matching_Type__c     = 'IN',
            genesis__Matching_Value__c    = 'AA,AE,AL,AK,AP,AZ,AR,CA,CO,CT,FL,GA,HI,ID,IL,IN,KS,KY,ME,MO,MT,NJ,NM,NY,ND,OR,PA,RI,SC,SD,TN,UT,WY,TS',
            genesis__Related_Object__c    = 'genesis__Applications__c',
            genesis__Rule_Object_Reference__c = 'genesis__Applications__c',
            genesis__Rule__c = rule.id,
            genesis__Stipulation_Type__c = 'FUNDING'
        );
        insert rul;

        //CRM-543 start
    TLO_URL_Config__c tlo = new TLO_URL_Config__c();
        tlo.TLO_URL__c = 'https://doppio-leads-dev.int.payoff.com/';
        tlo.TLOURLappname__c = 'verification';
        insert tlo;
        //CRM-543 end

        Decimal investorWithLargestWeight = 0;
        Account acc1 = new Account(
            Name = 'Test1',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Investment_Rules__c = rule.id,
            Number_Of_Applications_Invested__c = 3,
            Total_No_of_Application_Limit__c = 30,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName2',
            loan__Active__c = 'YES',
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456',
            Investor_Alloted_Weight__c = 4,
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0
        );
        Insert acc1;
        Account acc2 = new Account(
            Name = 'Test1',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Investment_Rules__c = rule.id,
            Number_Of_Applications_Invested__c = 3,
            Total_No_of_Application_Limit__c = 30,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName2',
            loan__Active__c = 'YES',
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456',
            Investor_Alloted_Weight__c = 4,
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0
        );
        Insert acc2;
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
        //pallavi
        genesis__Applications__c app1 = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = false,
            genesis__Account__c = acc1.Id,
            Invested_Amount__c  = 1000,
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'offer_accepted',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c    = 'Full Time',
            genesis__Loan_Amount__c = 1000,
            DCP_Investor_Eligibility__c = false
        );
        Insert app1;

        DCp_Arcus_Transactions__c DCP_obj = new DCp_Arcus_Transactions__c();
        DCP_obj.Application__c = app1.Id;
        DCP_obj.Card_Number__c = '1234568';
        DCP_obj.Bank_Name__c = 'CITI';
    DCP_obj.Pay_at_Funding__c = true;
    DCP_obj.Requested_Amount__c = 200;
    DCP_obj.Transaction_id__c = '87007jj798889';
    insert DCP_obj;

        app1.genesis__Status__c = 'agent_document_verification_pending';
        update app1;

        genesis__Applications__c app2 = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = false,
            genesis__Account__c = acc1.Id,
            Invested_Amount__c  = 1000,
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'offer_shown',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c    = 'Full Time',
            genesis__Loan_Amount__c = 1000,
            DCP_Investor_Eligibility__c = false
        );
        Insert app2;

        DCp_Arcus_Transactions__c DCP_obj2 = new DCp_Arcus_Transactions__c();
        DCP_obj2.Application__c = app2.Id;
        DCP_obj2.Card_Number__c = '1234568';
        DCP_obj2.Bank_Name__c = 'CITI';
    DCP_obj2.Pay_at_Funding__c = true;
    DCP_obj2.Requested_Amount__c = 200;
    DCP_obj2.Transaction_id__c = '87007jj798889';
    insert DCP_obj2;

        app2.genesis__Status__c = 'agent_document_verification_pending';
    update app2;
        test.stopTest();
        //pallavi
     }
    @isTest static Void method6(){
        test.startTest();
        genesis__Rule__c rule = new genesis__Rule__c();
        rule.name                       = 'TCU ruleset';
        rule.genesis__Enabled__c        = true;
        rule.genesis__Object_Type__c    = 'genesis__Object_Type__c';
        insert rule;

         CL_Document__c document = new CL_Document__c();
         document.Doc1__c = 'Credit Score Notice';
         document.Doc2__c = 'TIL Document';
         document.Doc3__c = 'Adverse Action Notice';
         insert document;

        genesis__RuleCriteria__c rul = new genesis__RuleCriteria__c(
            genesis__Criteria_Sequence__c = 1.0,
            genesis__Field_API_Name__c    = 'genesis__Account__r.State__c',
            genesis__Field_Name__c        = 'State',
            genesis__Field_Type__c        = 'STRING',
            genesis__Matching_Type__c     = 'IN',
            genesis__Matching_Value__c    = 'AA,AE,AL,AK,AP,AZ,AR,CA,CO,CT,FL,GA,HI,ID,IL,IN,KS,KY,ME,MO,MT,NJ,NM,NY,ND,OR,PA,RI,SC,SD,TN,UT,WY,TS',
            genesis__Related_Object__c    = 'genesis__Applications__c',
            genesis__Rule_Object_Reference__c = 'genesis__Applications__c',
            genesis__Rule__c = rule.id,
            genesis__Stipulation_Type__c = 'FUNDING'
        );
        insert rul;

        //CRM-543 start
    TLO_URL_Config__c tlo = new TLO_URL_Config__c();
        tlo.TLO_URL__c = 'https://doppio-leads-dev.int.payoff.com/';
        tlo.TLOURLappname__c = 'verification';
        insert tlo;
        //CRM-543 end

        Decimal investorWithLargestWeight = 0;
        Account acc1 = new Account(
            Name = 'Test1',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Investment_Rules__c = rule.id,
            Number_Of_Applications_Invested__c = 3,
            Total_No_of_Application_Limit__c = 30,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName2',
            loan__Active__c = 'YES',
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456',
            Investor_Alloted_Weight__c = 4,
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0
        );
        Insert acc1;
        Account acc2 = new Account(
            Name = 'Test1',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Investment_Rules__c = rule.id,
            Number_Of_Applications_Invested__c = 3,
            Total_No_of_Application_Limit__c = 30,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName2',
            loan__Active__c = 'YES',
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456',
            Investor_Alloted_Weight__c = 4,
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0
        );
        Insert acc2;
        Account acco = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName2',
            peer__Last_Name__c='TestLName2',
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456',
            loan__SOCIAL_SECURITY_NUMBER__c = string.valueOf(math.random()).right(9)
        );
        Insert acco;
        //pallavi
        genesis__Applications__c app3 = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = false,
            genesis__Account__c = acco.Id,
            Invested_Amount__c  = 1000,
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'offer_shown',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c    = 'Full Time',
            genesis__Loan_Amount__c = 1000,
            DCP_Investor_Eligibility__c = false,
            Investor__c = acc1.id
        );
        Insert app3;

        app3.genesis__Status__c = 'Stacker_Check_Passed';
    update app3;

        test.stopTest();
        //pallavi
     }
    @isTest static Void method7(){
        test.startTest();
        genesis__Rule__c rule = new genesis__Rule__c();
        rule.name                       = 'TCU ruleset';
        rule.genesis__Enabled__c        = true;
        rule.genesis__Object_Type__c    = 'genesis__Object_Type__c';
        insert rule;

         CL_Document__c document = new CL_Document__c();
         document.Doc1__c = 'Credit Score Notice';
         document.Doc2__c = 'TIL Document';
         document.Doc3__c = 'Adverse Action Notice';
         insert document;

        genesis__RuleCriteria__c rul = new genesis__RuleCriteria__c(
            genesis__Criteria_Sequence__c = 1.0,
            genesis__Field_API_Name__c    = 'genesis__Account__r.State__c',
            genesis__Field_Name__c        = 'State',
            genesis__Field_Type__c        = 'STRING',
            genesis__Matching_Type__c     = 'IN',
            genesis__Matching_Value__c    = 'AA,AE,AL,AK,AP,AZ,AR,CA,CO,CT,FL,GA,HI,ID,IL,IN,KS,KY,ME,MO,MT,NJ,NM,NY,ND,OR,PA,RI,SC,SD,TN,UT,WY,TS',
            genesis__Related_Object__c    = 'genesis__Applications__c',
            genesis__Rule_Object_Reference__c = 'genesis__Applications__c',
            genesis__Rule__c = rule.id,
            genesis__Stipulation_Type__c = 'FUNDING'
        );
        insert rul;

        //CRM-543 start
    TLO_URL_Config__c tlo = new TLO_URL_Config__c();
        tlo.TLO_URL__c = 'https://doppio-leads-dev.int.payoff.com/';
        tlo.TLOURLappname__c = 'verification';
        insert tlo;
        //CRM-543 end

        Decimal investorWithLargestWeight = 0;
        Account acc1 = new Account(
            Name = 'Test1',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Investment_Rules__c = rule.id,
            Number_Of_Applications_Invested__c = 3,
            Total_No_of_Application_Limit__c = 30,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName2',
            loan__Active__c = 'YES',
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456',
            Investor_Alloted_Weight__c = 4,
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0
        );
        Insert acc1;
        Account acc2 = new Account(
            Name = 'Test1',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Investment_Rules__c = rule.id,
            Number_Of_Applications_Invested__c = 3,
            Total_No_of_Application_Limit__c = 30,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName2',
            loan__Active__c = 'YES',
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456',
            Investor_Alloted_Weight__c = 4,
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0
        );
        Insert acc2;
        Account acco = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName2',
            peer__Last_Name__c='TestLName2',
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456',
            loan__SOCIAL_SECURITY_NUMBER__c = string.valueOf(math.random()).right(9)
        );
        Insert acco;
        //pallavi
        genesis__Applications__c app3 = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = false,
            genesis__Account__c = acco.Id,
            Invested_Amount__c  = 1000,
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'offer_shown',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c    = 'Full Time',
            genesis__Loan_Amount__c = 1000,
            DCP_Investor_Eligibility__c = false,
            Investor__c = acc1.id
        );
        Insert app3;

        app3.genesis__Loan_Amount__c = 1001;
       update app3;

        app3.Investor__c = acc2.id;
        app3.genesis__Status__c = 'offer_accepted';
        update app3;

        app3.genesis__Status__c = 'docusign_loan_docs_sent';
        update app3;

        test.stopTest();
        //pallavi
     }
    @isTest static Void method8(){
        test.startTest();
        genesis__Rule__c rule = new genesis__Rule__c();
        rule.name                       = 'TCU ruleset';
        rule.genesis__Enabled__c        = true;
        rule.genesis__Object_Type__c    = 'genesis__Object_Type__c';
        insert rule;

         CL_Document__c document = new CL_Document__c();
         document.Doc1__c = 'Credit Score Notice';
         document.Doc2__c = 'TIL Document For DCP';
         document.Doc3__c = 'Adverse Action Notice';
         insert document;

        genesis__RuleCriteria__c rul = new genesis__RuleCriteria__c(
            genesis__Criteria_Sequence__c = 1.0,
            genesis__Field_API_Name__c    = 'genesis__Account__r.State__c',
            genesis__Field_Name__c        = 'State',
            genesis__Field_Type__c        = 'STRING',
            genesis__Matching_Type__c     = 'IN',
            genesis__Matching_Value__c    = 'AA,AE,AL,AK,AP,AZ,AR,CA,CO,CT,FL,GA,HI,ID,IL,IN,KS,KY,ME,MO,MT,NJ,NM,NY,ND,OR,PA,RI,SC,SD,TN,UT,WY,TS',
            genesis__Related_Object__c    = 'genesis__Applications__c',
            genesis__Rule_Object_Reference__c = 'genesis__Applications__c',
            genesis__Rule__c = rule.id,
            genesis__Stipulation_Type__c = 'FUNDING'
        );
        insert rul;

        //CRM-543 start
    TLO_URL_Config__c tlo = new TLO_URL_Config__c();
        tlo.TLO_URL__c = 'https://doppio-leads-dev.int.payoff.com/';
        tlo.TLOURLappname__c = 'verification';
        insert tlo;
        //CRM-543 end

        Decimal investorWithLargestWeight = 0;
        Account acc1 = new Account(
            Name = 'Test1',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Investment_Rules__c = rule.id,
            Number_Of_Applications_Invested__c = 3,
            Total_No_of_Application_Limit__c = 30,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName2',
            loan__Active__c = 'YES',
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456',
            Investor_Alloted_Weight__c = 4,
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0
        );
        Insert acc1;
        Account acc2 = new Account(
            Name = 'Test1',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Investment_Rules__c = rule.id,
            Number_Of_Applications_Invested__c = 3,
            Total_No_of_Application_Limit__c = 30,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName2',
            loan__Active__c = 'YES',
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456',
            Investor_Alloted_Weight__c = 4,
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0,
			DCP_Allowed__c = true
        );
        Insert acc2;
        Account acco = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName2',
            peer__Last_Name__c='TestLName2',
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456',
            loan__SOCIAL_SECURITY_NUMBER__c = string.valueOf(math.random()).right(9)
        );
        Insert acco;
        //pallavi
        genesis__Applications__c app3 = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = false,
            genesis__Account__c = acco.Id,
            Invested_Amount__c  = 1000,
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'offer_shown',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c    = 'Full Time',
            genesis__Loan_Amount__c = 1000,
            DCP_Investor_Eligibility__c = false,
            Investor__c = acc1.id,
            dcp_eligible__c = 'Yes',
            Bureau_SSN__c = '12344',
            Loan_Doc_Signed_On__c = Date.newInstance(2016, 12, 9)
        );
        Insert app3;

        List<DCp_Arcus_Transactions__c> DCP_obj = new List<DCp_Arcus_Transactions__c>();
        DCp_Arcus_Transactions__c DCP_obj1 = new DCp_Arcus_Transactions__c();
        DCP_obj1.Application__c = app3.Id;
        DCP_obj1.Card_Number__c = '1234568';
        DCP_obj1.Bank_Name__c = 'CITI';
        DCP_obj1.Pay_at_Funding__c = True;
        DCP_obj1.Requested_Amount__c = 200;
        DCP_obj1.Transaction_id__c = '87007jj798889';
        DCP_obj1.Account__c = acco.id;
        DCP_obj1.Arcus_Eligible__c = true;
        DCP_obj.add(DCP_obj1);

        DCp_Arcus_Transactions__c DCP_obj2 = new DCp_Arcus_Transactions__c();
        DCP_obj2.Application__c = app3.Id;
        DCP_obj2.Card_Number__c = '12345689';
        DCP_obj2.Bank_Name__c = 'CITI';
        DCP_obj2.Pay_at_Funding__c = True;
        DCP_obj2.Requested_Amount__c = 200;
        DCP_obj2.Transaction_id__c = '87007jj7988890';
        DCP_obj2.Account__c = acco.id;
        DCP_obj.add(DCP_obj2);
        insert DCP_obj;

        //app3.Investor__c = acc2.id;
        /*app3.genesis__Status__c = 'agent_document_verification_pending';
        update app3;*/

        Credit_Policy__c cPolicy = new Credit_Policy__c(
            Application__c=app3.Id,
            Credit_Card_Total_Count__c= 0.00,
            Unsecured_Installment_Loans_Count__c = 0.00
        );
        insert cPolicy;

        QueueSobject Verificationqueue = [Select queue.id,queue.name,QueueID
                                        from QueueSobject
                                        where SobjectType ='genesis__Applications__c'
                                        AND queue.DeveloperName =: 'Final_Verification' limit 1];

        app3.Bureau_SSN__c = '54658';
        app3.OwnerId = Verificationqueue.Queue.Id;
        update app3;

        app3.Loan_Doc_Signed_On__c = System.today();
        update app3;

        test.stopTest();
        //pallavi
     }

     @isTest static void method9() {
        Account acct = TestDataFactory.createTestAccount();
        insert acct;

        Account inv = TestDataFactory.createTestInvestor();
        inv.Investor_Code__c = 'TEST';
        insert inv;

        genesis__Applications__c app = TestDataFactory.createTestApplication(acct.Id, inv.Id, '9ffffff9-9fff-f999-ff99-9f9f9f9f9f9f',
            Date.today().addDays(2), 'agent_document_verification_pending');
        insert app;

        clcommon__Party_Type__c partyType = TestDataFactory.createTestPartyType('BORROWER');
        insert partyType;

        genesis__Document_Category__c docCat1 = TestDataFactory.createTestDocumentCategory(partyType.Id, 'Bank Statement 1', 'statement');
        insert docCat1;

        genesis__Document_Category__c docCat2 = TestDataFactory.createTestDocumentCategory(partyType.Id, 'Plaid Asset Report', 'linked_acct');
        insert docCat2;

        genesis__Application_Document_Category__c appDocCat1 = TestDataFactory.createTestApplicationDocumentCategory('Bank Statement 1',
            app.Id, docCat1.Id, null, 'OPEN');
        appDocCat1.genesis__Required__c = true;
        insert appDocCat1;

        genesis__Application_Document_Category__c appDocCat2 = TestDataFactory.createTestApplicationDocumentCategory('Plaid Asset Report',
            app.Id, docCat2.Id, null, 'OPEN');
        insert appDocCat2;

        Test.startTest();

        appDocCat1.Box_URl__c = 'https://test.app.box.com/file/123456789';
        appDocCat1.genesis__Status__c = 'SUBMITTED';
        update appDocCat1;

        appDocCat2.Doc_URL__c = 'S3//Plaid_Asset_Report';
        appDocCat2.genesis__Status__c = 'SUBMITTED';
        update appDocCat2;

        app.is_Plaid_Asset_Available__c = true;
        update app;

        app.Plaid_Status__c = 'Accept';
        update app;

        appDocCat1 = [SELECT Cleared_Reason__c, genesis__Status__c
            FROM genesis__Application_Document_Category__c
            WHERE genesis__Application__c =: app.Id AND Name like 'Bank Statement %' AND genesis__Required__c = true LIMIT 1];

        appDocCat2 = [SELECT Cleared_Reason__c, genesis__Status__c
            FROM genesis__Application_Document_Category__c
            WHERE genesis__Application__c =: app.Id AND Name = 'Plaid Asset Report' AND Doc_URL__c != NULL LIMIT 1];

        System.assertEquals('CLEARED', appDocCat1.genesis__Status__c);
        System.assertEquals('Satisfied by PLAID transactions', appDocCat1.Cleared_Reason__c);

        app.GIACT_Status__c = 'Accept';

        app.GIACT_Status__c = 'Accept';
        update app;

        Test.stopTest();
     }
}