/*test class for RedecisionCntrl . Added by Pallavi on 7th Nov 2019*/
@isTest
public class TestRedecisionCntrl {
    
    @isTest
    static void method1(){
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
        
         Profiles_NotConsidered_ForRedecision__c profile = new Profiles_NotConsidered_ForRedecision__c();
         profile.Name = 'System API';
         profile.Profile_Name__c = 'System API';
         insert profile;
        
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
            peer__Last_Name__c='TestLName1',
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
            Annual_Individual_Income__c = 1000,
            Monthly_Housing_Payment__c = 100,
            Address_1__c = 'AA',
            Address_2__c = 'BB',
            peer__Date_of_Birth__c = Date.newInstance(1986, 06, 06)
        );
        Insert acc1;
       
        genesis__Applications__c app = new genesis__Applications__c(
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
            DCP_Investor_Eligibility__c = false,
            Investor__c = acc1.id,
            Bureau_SSN__c = '123',
            Requested_loan_amount__c = 1000,
            Annual_Individual_Income_App__c = 1000,
            Monthly_Housing_Payment_App__c = 100
        );      
        Insert app;
        Map<id,Account> oldAccMap = new Map<id,Account>();
        //oldAccMap.put(acco.id,acco);
        
        acc1.Annual_Individual_Income__c = 1500;
        acc1.peer__Date_of_Birth__c = Date.newInstance(1986, 06, 07);
        acc1.peer__First_Name__c = 'Test1FHName311';
        acc1.peer__Last_Name__c ='Test1Name311';
        acc1.Suffix__c = 'Dr';
        acc1.Address_1__c = 'aa3';
        acc1.Address_2__c = 'bb3';
        acc1.State__c = 'NJ';
        acc1.City__c = 'NY';
        acc1.ZIP_Code__c='123457';
        acc1.Monthly_Housing_Payment__c = 200;
        update acc1;
        
        test.stopTest();
    }
    testmethod static void method2(){
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
            loan__SOCIAL_SECURITY_NUMBER__c = string.valueOf(math.random()).right(9),
            Investor_Code__c = 'TNA'
            );
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');
     
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
            genesis__Draw_Period_End_Date__c = system.Today(),
            Requested_loan_amount__c = 1000,
            Annual_Individual_Income_App__c = 1000,
            Monthly_Housing_Payment_App__c = 100
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
        app.Requested_loan_amount__c = 1001;
        update app;
        //System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');


    }

}