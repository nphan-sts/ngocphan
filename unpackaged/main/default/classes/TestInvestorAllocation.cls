@isTest

private class TestInvestorAllocation{

    private enum RelatedObject {CREDIT_POLICY, APPLICATIONS}

    @TestSetup static void setup() {
        MW_Settings__c mwSetting = new MW_Settings__c();
        mwSetting.FE_User_Filter__c = 'serviceapi@happymoney.com.cliqa';
        insert mwSetting;
    }

    @isTest static Void InvestorAllocation_Usecase1(){
        test.startTest();
        genesis__Rule__c rule = new genesis__Rule__c();
        rule.name                       = 'TCU ruleset';
        rule.genesis__Enabled__c        = true;
        rule.genesis__Object_Type__c    = 'genesis__applications__c';
        rule.genesis__Evaluation_Expression__c = '1';
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
            Total_Allocations_MTD__c =0,
            DCP_Allowed__c = true
        );
        Insert acc1;
        
            genesis__Applications__c app1 = new genesis__Applications__c(
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
            Investor__c = acc1.id    
        );      
        Insert app1;
        
        Attachment attachment = new Attachment(
            ParentId = app1.id, 
            Name = 'TIL', 
            IsPrivate = false, 
            Body = Blob.valueOf('Unit Test Attachment Body Two'), 
            Description = '15');
        insert attachment;
        
        genesis__Application_Document_Category__c adc = new genesis__Application_Document_Category__c();
        adc.name = 'TIL Document';
        adc.genesis__Application__c = app1.id;
        
        insert adc;
        
        DCp_Arcus_Transactions__c DCP_obj = new DCp_Arcus_Transactions__c();
        DCP_obj.Application__c = app1.Id;
        DCP_obj.Card_Number__c = '1234568';
        DCP_obj.Bank_Name__c = 'CITI';
        DCP_obj.Pay_at_Funding__c = true;
        DCP_obj.Requested_Amount__c = 200;
        DCP_obj.Transaction_id__c = '87007jj798889';
        insert DCP_obj;
        
        Pricing_Offer__c  pOffer = new Pricing_Offer__c();
        pOffer.Above_prime_max__c= 'false';
        pOffer.Amount__c = 8000;
        pOffer.Application__c =app1.id;
        pOffer.APR__c = 11.997986061655;
        pOffer.Interest_Rate__c =9.97;
        pOffer.Is_Offer_Selected__c = true;
        pOffer.Key__c = 6;
        pOffer.Monthly_Payment__c = 215.489647581694;
        pOffer.Origination_fee__c = 160;
        pOffer.Origination_fee_rate__c = 2;
        pOffer.Pricing_Tier__c = 't2';
        pOffer.Segment__c = 'prime';
        pOffer.Term__c = 24;
        pOffer.Type__c = 'ABC';
        insert pOffer; 
        
        app1.genesis__Status__c = 'agent_document_verification_pending';
        try{
           update app1; 
        }catch(Exception e){
            //Do nothing
		}
        
        
                 
        test.stopTest();
        //pallavi
        
        
    }

    @isTest static Void InvestorAllocation_Usecase2(){
        test.startTest();
        
        genesis__Rule__c rule = new genesis__Rule__c();
        rule.name                       = 'TCU ruleset';
        rule.genesis__Enabled__c        = true;
        rule.genesis__Object_Type__c    = 'genesis__applications__c';
        rule.genesis__Evaluation_Expression__c = '1';
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
        //genesis__RuleCriteria__c rul =[select id,name,genesis__Rule__r.name from genesis__RuleCriteria__c where genesis__Rule__r.name = 'TCU ruleset'];
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
        
        Account acc1 = new Account(
            Name = 'Test1',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Investment_Rules__c = rule.id,
            Number_Of_Applications_Invested__c = 3, 
            Total_No_of_Application_Limit__c = 30,
            Last_Application_assigned_on__c = system.now()-7,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName1',
            peer__Last_Name__c='TestLName2',
            loan__Active__c = 'YES', 
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456'
        );
        Insert acc1;
        
        
        genesis__Applications__c app1 = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = false,
            genesis__Account__c = acco.Id,
            Investor__c  = acc1.id,
            Invested_Amount__c  = 1000,       
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'Offer_accepted',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c    = 'Full Time',
            genesis__Loan_Amount__c = 1000
        );      
        Insert app1;
        List<Account> listInvestor = [Select id,name,
                                      Investment_Rules__c,
                                      loan__Investor__c,
                                      Last_Application_assigned_on__c,
                                      Amount_Invested__c,
                                      Number_Of_Applications_Invested__c
                                      FROM Account
                                      WHERE loan__Investor__c = true
                                      AND Remaining_Amount__c >=: app1.genesis__loan_amount__c
                                      AND Remaining_Applications__c >=: 1
                                      AND loan__Active__c = 'Yes'
                                      AND Name = 'Test1'
                                      order by Last_Application_assigned_on__c
                                     ];
        
        System.debug('****System.debug in Test Class*******'+listInvestor.size());
        InvestorAllocation inv = new InvestorAllocation(true);
        InvestorAllocation.runInvestorRule(app1.id);
        genesis.RulesAPI.evaluateRules(app1,null,true,false); 
        
        Test.StopTest();      
        
    }

    /**
     * Confirm that rulesets work correctly when using related objects.
     */
    @IsTest static void testCreditPolicyRelationRuleCriteria() {

        Test.startTest();

        /*
        Create document
         */
        CL_Document__c document = new CL_Document__c();
        document.Doc1__c = 'Credit Score Notice';
        document.Doc2__c = 'TIL Document';
        document.Doc3__c = 'Adverse Action Notice';
        insert document;

        /*
        Create Rule and Rule Criteria
         */
        genesis__Rule__c rule = new genesis__Rule__c();
        rule.Name                       = 'CP 6.2 ruleset';
        rule.genesis__Enabled__c        = true;
        rule.genesis__Object_Type__c    = 'genesis__applications__c';
        rule.genesis__Message_failure__c = 'FAIL cannot allocate to CP 6.2 ruleset';
        rule.genesis__Message_success__c = 'Successful allocation to CP 6.2 ruleset';
        rule.genesis__Evaluation_Expression__c = '(1 AND 20)';
        insert rule;

        genesis__RuleCriteria__c ruleCriteria1 = new genesis__RuleCriteria__c(
                genesis__Criteria_Sequence__c = 1.0,
                genesis__Field_API_Name__c    = 'genesis__Account__r.State__c',
                genesis__Field_Name__c        = 'State',
                genesis__Field_Type__c        = 'STRING',
                genesis__Matching_Type__c     = 'IN',
                genesis__Matching_Value__c    = 'AA,AE,AL,AK,AP,AZ,AR,CA,CO,CT,FL,GA,HI,ID,IL,IN,KS,KY,ME,MO,MT,NJ,NM,NY,ND,OR,PA,RI,SC,SD,TN,UT,WY,TS',
                genesis__Related_Object__c    = 'genesis__Applications__c',
                genesis__Rule_Object_Reference__c = 'genesis__Applications__c',
                genesis__Rule__c = rule.Id,
                genesis__Stipulation_Type__c = 'FUNDING'
        );
        insert ruleCriteria1;

        genesis__RuleCriteria__c ruleCriteria2 = new genesis__RuleCriteria__c(
                genesis__Criteria_Sequence__c = 20.0,
                genesis__Field_API_Name__c    = 'FICO__c',
                genesis__Field_Name__c        = 'FICO',
                genesis__Field_Type__c        = 'DOUBLE',
                genesis__Matching_Type__c     = '>=',
                genesis__Matching_Value__c    = '640',
                genesis__Maximum_Value__c     = '',
                genesis__Minimum_Value__c     = '',
                genesis__Related_Object__c    = 'Credit_Policy__c',
                genesis__Rule_Object_Reference__c = 'Application__r',
                genesis__Rule__c = rule.Id,
                genesis__Stipulation_Type__c = 'FUNDING'
        );
        insert ruleCriteria2;

        /*
        Create the investor and attach rule
         */
        Account acc1 = new Account(
                Name = 'Test1',
                loan__Investor__c = true,
                Amount_Invested__c = 1000,
                Investment_Rules__c = rule.Id,
                Number_Of_Applications_Invested__c = 3,
                Total_No_of_Application_Limit__c = 30,
                Last_Application_assigned_on__c = System.now()-7,
                Total_Investment_Limit__c = 1000000,
                loan__Undeployed_Funds__c = 500000,
                cnotify__Email__c = 'no-reply@testorganization.com',
                peer__First_Name__c = 'TestFName1',
                peer__Last_Name__c='TestLName2',
                loan__Active__c = 'YES',
                City__c='CANADA',
                State__c='CA',
                ZIP_Code__c='123456'
        );
        insert acc1;

        /*
        Create the account and application and credit policy
         */
        Account acco = new Account(
                Name = 'Test',
                loan__Investor__c= false,
                cnotify__Email__c = 'no-reply@testorganization.com',
                peer__First_Name__c = 'TestFName2',
                peer__Last_Name__c='TestLName2',
                City__c='CANADA',
                State__c='CA',
                ZIP_Code__c='123456'
        );
        insert acco;

        genesis__Applications__c app1 = new genesis__Applications__c(
                genesis__Due_Day__c = 20,
                genesis__Expected_First_Payment_Date__c = System.today(),
                genesis__Expected_Start_Date__c = System.today(),
                genesis__Funding_in_Tranches__c = false,
                genesis__Account__c = acco.Id,
                Investor__c  = acc1.Id,
                Invested_Amount__c  = 1000,
                Application_Start_DateV2__c = System.today(),
                genesis__Status__c = 'Offer_accepted',
                genesis__Draw_Period_End_Date__c = System.today(),
                Employment_Status__c    = 'Full Time',
                genesis__Loan_Amount__c = 1000
        );
        insert app1;

        Credit_Policy__c creditPolicy = new Credit_Policy__c();
        creditPolicy.FICO__c = 640.0;
        creditPolicy.Net_Disposable_Income_NDI__c = '1200';
        creditPolicy.Application__c = app1.Id;
        insert creditPolicy;

        /*
        Execute the test as code would execute.
        Pull investor and execute rules api against application.
         */
        List<Account> listInvestor = [
                SELECT Id, Name,
                    Investment_Rules__c,
                    loan__Investor__c,
                    Last_Application_assigned_on__c,
                    Amount_Invested__c,
                    Number_Of_Applications_Invested__c
                FROM Account
                WHERE loan__Investor__c = TRUE
                AND Remaining_Amount__c >=: app1.genesis__Loan_Amount__c
                AND Remaining_Applications__c >=: 1
                AND loan__Active__c = 'Yes'
                AND Name = 'Test1'
                ORDER BY Last_Application_assigned_on__c
        ];

        System.debug('****System.debug in Test Class*******'+listInvestor.size());

        /*
        Assert that application meets the condition for cp 6.2 simple eval
         */
        new InvestorAllocation(true);
        InvestorAllocation.runInvestorRule(app1.Id);
        List<genesis__Checklist__c> checklists1 = genesis.RulesAPI.evaluateRules(app1, null, true, false);

        System.assertEquals(checklists1.size(), 1);
        System.assertEquals(checklists1.get(0).genesis__Message__c, 'Successful allocation to CP 6.2 ruleset');

        /*
        Assert that now application will not meet fico score criteria
         */
        ruleCriteria2.genesis__Matching_Value__c = '650';
        update ruleCriteria2;

        new InvestorAllocation(true);
        InvestorAllocation.runInvestorRule(app1.Id);
        List<genesis__Checklist__c> checklists2 = genesis.RulesAPI.evaluateRules(app1, null, true, false);

        System.assertEquals(checklists2.size(), 1);
        System.assertEquals(checklists2.get(0).genesis__Message__c, 'FAIL cannot allocate to CP 6.2 ruleset');

        Test.stopTest();
    }


    /**
     * Demonstrate that RulesAPI will return the exception message in the checklist.description if an exception occurs.
     * For every field access attempt on the null object, a checklist will be produced.  A final checklist
     * will contain the summary of the rule execution.
     */
    @IsTest static void testExceptionChecklistsInCaseOfMissingCreditPolicy() {

        Test.startTest();

        CL_Document__c docs = MW_GlobalTestUtility.getCLDocumentRecord();
        insert docs;

        genesis__Rule__c rule = GetRule('Test FICO Only Rule', '1');
        insert rule;

        genesis__RuleCriteria__c ficoCriteria = GetCreditPolicyCriteria(1, rule, RelatedObject.CREDIT_POLICY);
        ficoCriteria.genesis__Field_API_Name__c    = 'FICO__c';
        ficoCriteria.genesis__Field_Name__c        = 'FICO';
        ficoCriteria.genesis__Matching_Type__c     = '>=';
        ficoCriteria.genesis__Matching_Value__c    = '640';
        insert ficoCriteria;

        Account investor = GetInvestorWithRuleset(rule);
        insert investor;

        Account applicantAccount = GetApplicantAccount();
        insert applicantAccount;

        genesis__Applications__c appInsert = GetADVPApplication(investor, applicantAccount);
        insert appInsert;

        /* using identical query to InvestorAllocation */
        genesis__Applications__c appTest =
            [SELECT Id,
                    Name,
                    Investor__c,
                    DCP_Investor_Eligibility__c,
                    genesis__Status__c,
                    genesis__Loan_Amount__c,
                    Invested_Amount__c,
                    genesis__Lending_Product__c,
                    Last_Investor_Assigned_On__c,
                    Total_Arcus_Transactions__c
             FROM   genesis__Applications__c
             WHERE  Id =: appInsert.Id
             LIMIT 1];

        new InvestorAllocation(true);
        InvestorAllocation.runInvestorRule(appTest.Id);
        List<genesis__Checklist__c> checklists = genesis.RulesAPI.evaluateRules(appTest, null, true, false);

        System.assertEquals(2, checklists.size());

        genesis__Checklist__c exceptionChecklist = checklists.get(0);
        genesis__Checklist__c summaryChecklist = checklists.get(1);

        System.debug('Fail exception checklist description: ' + exceptionChecklist.genesis__Description__c);
        System.debug('Fail exception checklist message: ' + exceptionChecklist.genesis__Message__c);
        System.assert(exceptionChecklist.genesis__Description__c.containsIgnoreCase('exception'), 'First checklist.description will contain the exception text');
        System.assert(exceptionChecklist.genesis__Message__c.containsIgnoreCase('fail') , 'First checklist.message will contain the exception rule specifics');

        System.debug('Fail summary checklist description: ' + summaryChecklist.genesis__Description__c);
        System.assertEquals('FAIL cannot allocate to Test FICO Only Rule', summaryChecklist.genesis__Message__c);

        Test.stopTest();
    }

    /**
     *  Assert multiple credit policies will only consider the second when two are available.
     */
    @IsTest static void testShouldPassFirstFailSecond() {

        Test.startTest();

        genesis__Applications__c application = setupDebugRulesetWithFICOAndNDI(640, 1000, RelatedObject.APPLICATIONS);

        Credit_Policy__c cp1 = GetCreditPolicy(application, 640.0, 1200);
        assertSingleChecklistAndExpectation(application, cp1,true);

        Credit_Policy__c cp2 = GetCreditPolicy(application, 640.0, 900);
        assertSingleChecklistAndExpectation(application, cp2, false);

        Test.stopTest();
    }

    /**
     * The same as the test above, but in reverse order
     */
    @IsTest static void testShouldFailFirstPassSecond() {

        Test.startTest();

        genesis__Applications__c application = setupDebugRulesetWithFICOAndNDI(640, 1000, RelatedObject.APPLICATIONS);

        Credit_Policy__c cp1 = GetCreditPolicy(application, 640.0, 901);
        assertSingleChecklistAndExpectation(application, cp1, false);

        Credit_Policy__c cp2 = GetCreditPolicy(application, 640.0, 1201);
        assertSingleChecklistAndExpectation(application, cp2, true);

        Test.stopTest();
    }

    /**
     * The RulesAPI combines all passes in field "columns" as ORs.
     * ie:
     *                    Cri1 , Cri2
     *  policy record A : PASS1, FAIL2
     *  policy record B : FAIL1, PASS2
     *  policy record C : FAIL1, FAIL2
     *                  = PASS1, PASS2 = PASS X.
     *
     *  To avoid this, use RelatedObject.APPLICATIONS
     *  This configures the RuleCriteria to use the single application object instead of the potential multiple credit policies.
     */
    @IsTest static void testShouldNotCombineAllPassCriteria() {

        Test.startTest();

        genesis__Applications__c application = setupDebugRulesetWithFICOAndNDI(640, 1000, RelatedObject.APPLICATIONS);

        Credit_Policy__c cp1 = GetCreditPolicy(application, 640.0, 902);
        assertSingleChecklistAndExpectation(application, cp1, false);

        Credit_Policy__c cp2 = GetCreditPolicy(application, 501.0, 1200);
        assertSingleChecklistAndExpectation(application, cp2, false);

        Credit_Policy__c cp3 = GetCreditPolicy(application, 502.0, 980);
        assertSingleChecklistAndExpectation(application, cp3, false);

        Credit_Policy__c cp4 = GetCreditPolicy(application, 641.0, 1001);
        assertSingleChecklistAndExpectation(application, cp4, true);

        Credit_Policy__c cp5 = GetCreditPolicy(application, null, null);
        assertSingleChecklistAndExpectation(application, cp5, false);

        Test.stopTest();
    }

    /**
     * Setup a debug ruleset with fico >= 640 and ndi >= 1000 on an advp app
     * @return Application
     */
    private static genesis__Applications__c setupDebugRulesetWithFICOAndNDI(Integer fico, Integer ndi, RelatedObject ro) {
        CL_Document__c clDocument = GetDocument();
        insert clDocument;

        /* insert rules */
        genesis__Rule__c rule = GetRule('Debug Rule Set', '(1 AND 2)');
        insert rule;

        genesis__RuleCriteria__c ficoCriteria = GetFICOCriteria(1, rule, fico, ro);
        insert ficoCriteria;

        genesis__RuleCriteria__c ndiCriteria = GetNDICriteria(2, rule, ndi, ro);
        insert ndiCriteria;

        /* create our applicant */
        Account applicantAccount = GetApplicantAccount();
        insert applicantAccount;

        Account investor = MW_GlobalTestUtility.GetAccount('Investor');
        insert investor;

        genesis__Applications__c application = GetADVPApplication(investor, applicantAccount);
        insert application;

        genesis__Applications__c testApp = selectApplicationForRuleset(application.Id);

        return testApp;
    }

    private static void assertSingleChecklistAndExpectation(genesis__Applications__c application,
                                                            Credit_Policy__c creditPolicy,
                                                            Boolean expectation) {
        new InvestorAllocation(true);
        InvestorAllocation.runInvestorRule(application.Id);

        insert creditPolicy;
        CreditPolicyResponse.updateAppRulesetCreditPolicyFields(application.Id, creditPolicy.Id);
        List<genesis__Checklist__c> checklists1 = genesis.RulesAPI.evaluateRules(application, null, true, false);

        System.assertEquals(1, checklists1.size());
        genesis__Checklist__c checklist = checklists1.get(0);
        System.debug(checklist);
        System.assertEquals(expectation, checklist.genesis__Result__c);
    }

    /**
     * Demonstrate three things
     *
     * 1. We can remove the credit policy subquery from the application selection since it does nothing.
     * The RulesAPI class will query credit policy on its own, regardless if we pass in the data with a value or try to update it.
     * The top level Application field values are still required.
     *
     *      Per cls internal logging, the RulesAPI query appears like:
     * SELECT Name,Id,(SELECT fico__c,num_trades_opened_past_24mo__c FROM Credit_Policy__r ORDER BY ID DESC) FROM genesis__applications__c WHERE Id IN:parentIds
     *
     * 2. When the credit policy is present, but only a field is null, RulesAPI will not produce an exception message in the description field,
     * but will show up as a null result.  The checklist.message field result will produce the failure message.
     * In this scenario, only 1 checklist will be produced.
     *
     * 3. When we update the credit policy object record, the rule evaluation produces one successful, valid checklist.
     */
    @IsTest static void testNullFieldProducesNullResult() {

        Test.startTest();

        CL_Document__c docs = MW_GlobalTestUtility.getCLDocumentRecord();
        insert docs;

        genesis__Rule__c rule = GetRule('Test Deref Rule', '(1 AND 2)');
        insert rule;

        genesis__RuleCriteria__c ficoCriteria = GetCreditPolicyCriteria(1, rule, RelatedObject.CREDIT_POLICY);
        ficoCriteria.genesis__Field_API_Name__c    = 'FICO__c';
        ficoCriteria.genesis__Field_Name__c        = 'FICO';
        ficoCriteria.genesis__Matching_Type__c     = '>=';
        ficoCriteria.genesis__Matching_Value__c    = '620';
        insert ficoCriteria;

        genesis__RuleCriteria__c tradeCriteria = GetCreditPolicyCriteria(2, rule, RelatedObject.CREDIT_POLICY);
        tradeCriteria.genesis__Field_API_Name__c    = 'Num_Trades_Opened_Past_24mo__c';
        tradeCriteria.genesis__Field_Name__c        = 'Num Trades Opened Past 24mo';
        tradeCriteria.genesis__Matching_Type__c     = '<';
        tradeCriteria.genesis__Matching_Value__c    = '10';
        insert tradeCriteria;

        Account investor = GetInvestorWithRuleset(rule);
        insert investor;

        Account applicantAccount = GetApplicantAccount();
        insert applicantAccount;

        genesis__Applications__c appInsert = GetADVPApplication(investor, applicantAccount);
        insert appInsert;

        Credit_Policy__c creditPolicy = new Credit_Policy__c();
        creditPolicy.FICO__c = 650;
        creditPolicy.Num_Trades_Opened_Past_24mo__c = null;
        creditPolicy.Application__c = appInsert.Id;
        insert creditPolicy;

        /* used identical query to InvestorAllocation */
        genesis__Applications__c appTest =
        [SELECT Id,
                Name,
                Investor__c,
                DCP_Investor_Eligibility__c,
                genesis__Status__c,
                genesis__Loan_Amount__c,
                Invested_Amount__c,
                genesis__Lending_Product__c,
                Last_Investor_Assigned_On__c,
                Total_Arcus_Transactions__c,
                (SELECT FICO__c,
                        Num_Trades_Opened_Past_24mo__c
                 FROM   Credit_Policy__r)
        FROM   genesis__Applications__c
        WHERE  Id =: appInsert.Id
        LIMIT 1];

        /* attempt to set a default value for null 24 mo fields */
        for (Credit_Policy__c cpTest : appTest.Credit_Policy__r) {
            cpTest.Num_Trades_Opened_Past_24mo__c = 1;
        }

        /*
        Produce the expected null value in the description json string.
         */
        new InvestorAllocation(true);
        InvestorAllocation.runInvestorRule(appTest.Id);
        List<genesis__Checklist__c> checklistsFail = genesis.RulesAPI.evaluateRules(appTest, null, true, false);

        System.assertEquals(1, checklistsFail.size());
        genesis__Checklist__c failChecklist = checklistsFail.get(0);

        System.assert(failChecklist.genesis__Description__c != null);
        System.assert(failChecklist.genesis__Description__c.containsIgnoreCase('"ActualResult" : null'));
        System.assertEquals('FAIL cannot allocate to Test Deref Rule', failChecklist.genesis__Message__c);
        System.assert(failChecklist.genesis__Result__c == false);

        System.debug('Fail checklist description: ' + failChecklist.genesis__Description__c);
        System.debug('Fail checklist message: ' + failChecklist.genesis__Message__c);

        /*
        Update the credit policy object and produce one valid checklist message.
         */
        creditPolicy.Num_Trades_Opened_Past_24mo__c = 9;
        update creditPolicy;

        new InvestorAllocation(true);
        InvestorAllocation.runInvestorRule(appTest.Id);
        List<genesis__Checklist__c> checklistsPass = genesis.RulesAPI.evaluateRules(appTest, null, true, false);

        System.assertEquals(1, checklistsPass.size());
        genesis__Checklist__c passChecklist = checklistsPass.get(0);

        System.assert(passChecklist.genesis__Description__c != null);
        System.assert(!passChecklist.genesis__Description__c.containsIgnoreCase('"ActualResult" : null'));
        System.assertEquals('Successful allocation to Test Deref Rule', passChecklist.genesis__Message__c);
        System.assert(passChecklist.genesis__Result__c == true);

        System.debug('Success checklist description: ' + passChecklist.genesis__Description__c);
        System.debug('Success checklist message: ' + passChecklist.genesis__Message__c);

        Test.stopTest();
    }

    @isTest static Void InvestorAllocation_UsecaseWeightAllocation(){
        test.startTest();
        
        genesis__Rule__c rule = new genesis__Rule__c();
        rule.name                       = 'TCU ruleset';
        rule.genesis__Enabled__c        = true;
        rule.genesis__Object_Type__c    = 'genesis__applications__c';
        rule.genesis__Evaluation_Expression__c = '1';
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
        //genesis__RuleCriteria__c rul =[select id,name,genesis__Rule__r.name from genesis__RuleCriteria__c where genesis__Rule__r.name = 'TCU ruleset'];
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
            Investor_Alloted_Weight__c = 2,
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
        
        Account acc3 = new Account(
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
            Investor_Alloted_Weight__c = 1,
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0
        );
        Insert acc3;
         
        genesis__Applications__c app1 = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = false,
            genesis__Account__c = acc1.Id,
            Invested_Amount__c  = 1000,       
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'Offer_accepted',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c    = 'Full Time',
            genesis__Loan_Amount__c = 1000
        );      
        Insert app1;
        List<Account> listInvestor = [Select id,name,
                                      Investment_Rules__c,
                                      loan__Investor__c,
                                      Last_Application_assigned_on__c,
                                      Amount_Invested__c,
                                      Number_Of_Applications_Invested__c
                                      FROM Account
                                      WHERE loan__Investor__c = true
                                      AND Remaining_Amount__c >=: app1.genesis__loan_amount__c
                                      AND Remaining_Applications__c >=: 1
                                      AND loan__Active__c = 'Yes'
                                      AND Name = 'Test1'
                                      order by Last_Application_assigned_on__c
                                     ];
        
        System.debug('****System.debug in Test Class*******'+listInvestor.size());
        InvestorAllocation inv = new InvestorAllocation(true);
        InvestorAllocation.runInvestorAllocationBasedOnWeighting(app1.id);
        genesis__applications__c apps = [select id,name,investor__c from genesis__applications__c where id =: app1.id];
        System.assertEquals(apps.investor__c,acc2.id );
        genesis.RulesAPI.evaluateRules(app1,null,true,false); 
        Test.StopTest();      
        
    } 
    
    @isTest static Void InvestorAllocation_UsecaseWeightAllocationWithMultipleApplications(){
        
        
        genesis__Rule__c rule = new genesis__Rule__c();
        rule.name                       = 'TCU ruleset';
        rule.genesis__Enabled__c        = true;
        rule.genesis__Object_Type__c    = 'genesis__applications__c';
        rule.genesis__Evaluation_Expression__c = '1';
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
        //genesis__RuleCriteria__c rul =[select id,name,genesis__Rule__r.name from genesis__RuleCriteria__c where genesis__Rule__r.name = 'TCU ruleset'];
        List<Account> accs = new List<Account>();
        Account acco = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName2',
            peer__Last_Name__c='TestLName2', 
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456',
            Monthly_Funded_Cap__c = 1000,
            Total_Funded_MTD__c = 500
        );
        accs.add(acco);
        //Insert acco;
        
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
            Investor_Alloted_Weight__c = 2,
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0
        );
        accs.add(acc1);
        Account acc3 = new Account(
            Name = 'Test2',
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
            Investor_Alloted_Weight__c = 1,
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0
        );
        accs.add(acc3);
        insert accs;
        
        List<genesis__Applications__c> appInsert = new List<genesis__Applications__c>();
        genesis__Applications__c app1 = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = false,
            genesis__Account__c = accs[2].Id,
            Invested_Amount__c  = 1000,       
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'Offer_accepted',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c    = 'Full Time',
            genesis__Loan_Amount__c = 1000
     
        );    
        appInsert.add(app1);
        
        genesis__Applications__c app2 = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = false,
            genesis__Account__c = accs[2].Id,
            Invested_Amount__c  = 1000,       
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'Offer_accepted',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c    = 'Full Time',
            genesis__Loan_Amount__c = 1000
        );  
        appInsert.add(app2);
        
        genesis__Applications__c app3 = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = false,
            genesis__Account__c = accs[2].Id,
            Invested_Amount__c  = 1000,       
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'Offer_accepted',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c    = 'Full Time',
            genesis__Loan_Amount__c = 1000
            
        );             
        appInsert.add(app3);
        
        genesis__Applications__c app4 = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = false,
            genesis__Account__c = accs[2].Id,
            Invested_Amount__c  = 1000,       
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'Offer_accepted',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c    = 'Full Time',
            genesis__Loan_Amount__c = 1000
           
        );     
        appInsert.add(app4);
        
        insert appInsert;
        
        Test.startTest();
        InvestorAllocation.runInvestorAllocationBasedOnWeighting(appInsert[0].id);
        InvestorAllocation.runInvestorAllocationBasedOnWeighting(appInsert[1].id);
        //InvestorAllocation.runInvestorAllocationBasedOnWeighting(appInsert[2].id);
        //InvestorAllocation.runInvestorAllocationBasedOnWeighting(appInsert[3].id);
        
        List<genesis__applications__c> apps = [select id,name,investor__c,investor__r.name from genesis__applications__c where id in: appInsert];
        System.assertEquals(apps[0].investor__c,accs[1].id );
        //System.assertEquals(apps[1].investor__c,accs[2].id  );
        //System.assertEquals(apps[2].investor__r.name,accs[3].name);
        //System.assertEquals(apps[2].investor__c,accs[3].id );
        //System.assertEquals(apps[3].investor__c,accs[1].id );
        
        
        Test.stopTest();
        
        
    } 
    
    @isTest static Void InvestorAllocation_UsecaseWeightAllocationWithReallocation(){
        
        
        genesis__Rule__c rule = new genesis__Rule__c();
        rule.name                       = 'TCU ruleset';
        rule.genesis__Enabled__c        = true;
        rule.genesis__Object_Type__c    = 'genesis__applications__c';
        rule.genesis__Evaluation_Expression__c = '1';
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
        //genesis__RuleCriteria__c rul =[select id,name,genesis__Rule__r.name from genesis__RuleCriteria__c where genesis__Rule__r.name = 'TCU ruleset'];
        List<Account> accs = new List<Account>();
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
        accs.add(acco);
        //Insert acco;
        
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
            loan__Active__c = 'NO', 
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456',
            Investor_Alloted_Weight__c = 2,
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0
        );
        accs.add(acc1);
        Account acc3 = new Account(
            Name = 'Test2',
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
            Investor_Alloted_Weight__c = 1,
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =9
        );
        accs.add(acc3);
        insert accs;
        
        List<genesis__Applications__c> appInsert = new List<genesis__Applications__c>();
        genesis__Applications__c app1 = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = false,
            genesis__Account__c = acco.Id,
            Invested_Amount__c  = 1000,       
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'Offer_accepted',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c    = 'Full Time',
            genesis__Loan_Amount__c = 1000
        );    
        appInsert.add(app1);
        
        genesis__Applications__c app2 = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = false,
            genesis__Account__c = accs[1].Id,
            Invested_Amount__c  = 1000,       
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'Offer_accepted',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c    = 'Full Time',
            genesis__Loan_Amount__c = 1000
        );  
        appInsert.add(app2);
        
        genesis__Applications__c app3 = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = false,
            genesis__Account__c = acco.Id,
            Invested_Amount__c  = 1000,       
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'Offer_accepted',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c    = 'Full Time',
            genesis__Loan_Amount__c = 1000
        );      
        
        appInsert.add(app3);
        genesis__Applications__c app4 = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = false,
            genesis__Account__c = accs[1].Id,
            Invested_Amount__c  = 1000,       
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'Offer_accepted',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c    = 'Full Time',
            genesis__Loan_Amount__c = 1000
        );     
        appInsert.add(app4);
        genesis__Applications__c app5 = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = false,
            genesis__Account__c = accs[1].Id,
            Invested_Amount__c  = 1000,       
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'Offer_accepted',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c    = 'Full Time',
            genesis__Loan_Amount__c = 1000
        );     
        appInsert.add(app5);
        /*genesis__Applications__c app6 = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = false,
            genesis__Account__c = acco.Id,
            Invested_Amount__c  = 1000,       
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'Offer_accepted',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c    = 'Full Time',
            genesis__Loan_Amount__c = 1000
        );     
        appInsert.add(app6);*/
        insert appInsert;
        
        Test.startTest();
        InvestorAllocation.runInvestorAllocationBasedOnWeighting(appInsert[0].id);
        appInsert[0].investor__c = accs[2].id;
        update appInsert[0];
        
        /*List<genesis__applications__c> apps = [select id,name,investor__c,investor__r.name from genesis__applications__c where id in: appInsert];
        List<Account> accounts = [select id,name,Investor_Alloted_Weight__c,Investor_Current_Weight__c
                                  from Account
                                  where id in:accs and Investor_Alloted_Weight__c!=null
                                  order by Investor_Alloted_Weight__c desc];
        
        System.assertEquals(apps[0].investor__c,accounts[1].id );
       // System.assertEquals(accounts[1].Investor_Current_Weight__c,1 );
        System.assertEquals(accounts[0].Investor_Current_Weight__c,0 );*/
        
        
        InvestorAllocation.runInvestorAllocationBasedOnWeighting(appInsert[0].id);
        InvestorAllocation.runInvestorAllocationBasedOnWeighting(appInsert[1].id);
       // InvestorAllocation.runInvestorAllocationBasedOnWeighting(appInsert[2].id);
        //InvestorAllocation.runInvestorAllocationBasedOnWeighting(appInsert[3].id);
        //apps = [select id,name,investor__c,investor__r.name from genesis__applications__c where id=: appInsert];
        //System.assertEquals(apps[1].investor__c,accounts[0].id ); //LOS-63
        //System.assertEquals(apps[2].investor__c,accounts[1].id );
        /// reset happen
        //System.assertEquals(apps[3].investor__c,accounts[0].id );
        //System.assertEquals(apps[4].investor__c,accounts[0].id );
                
        Test.stopTest();
          
    }

    @IsTest static Void InvestorAllocation_UsecaseWeightAllocationDCP(){

        Test.startTest();
        genesis__Rule__c rule = new genesis__Rule__c();
        rule.name                       = 'Test TCU ruleset';
        rule.genesis__Enabled__c        = true;
        rule.genesis__Object_Type__c    = 'genesis__applications__c';
        rule.genesis__Message_failure__c = 'FAIL cannot allocate to to Test TCU ruleset';
        rule.genesis__Message_success__c = 'Successful allocation to Test TCU ruleset';
        rule.genesis__Evaluation_Expression__c = '1';
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
            genesis__Rule__c = rule.Id,
            genesis__Stipulation_Type__c = 'FUNDING'
        );
        insert rul; 
        Decimal investorWithLargestWeight = 0;

        List<Account> accList = new List<Account>();

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
            Total_Allocations_MTD__c =10
        );
        accList.add(acc1);
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
        accList.add(acc2);

        Insert accList;
        /*Account acco = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName2',
            peer__Last_Name__c='TestLName2', 
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456'
        );
        Insert acco;*/
        //pallavi

        List<genesis__Applications__c> listApp = new List<genesis__Applications__c>();

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
        listApp.add(app1);

        genesis__Applications__c app2 = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = false,
            genesis__Account__c = acc1.Id,
            Invested_Amount__c  = 1000,       
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'offer_shown',//agent_document_verification_pending',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c    = 'Full Time',
            genesis__Loan_Amount__c = 1000,
            DCP_Investor_Eligibility__c = false,
            Investor__c = acc1.id
        );      
        listApp.add(app2);

        insert listApp;

        List<genesis__Application_Document_Category__c> listAdc = new List<genesis__Application_Document_Category__c>();
        
        genesis__Application_Document_Category__c adc1 = new genesis__Application_Document_Category__c();
        adc1.name = 'TIL Document';
        adc1.genesis__Application__c = app1.id;
        
        listAdc.add(adc1);

        genesis__Application_Document_Category__c adc2 = new genesis__Application_Document_Category__c();
        adc2.name = 'TIL Document';
        adc2.genesis__Application__c = app2.id;

        listAdc.add(adc2);

        insert listAdc;


        Credit_Policy__c creditPolicy = new Credit_Policy__c();
        creditPolicy.FICO__c = 750.0;
        creditPolicy.Net_Disposable_Income_NDI__c = '2400';
        creditPolicy.Application__c = app1.Id;
        insert creditPolicy;
        
        DCp_Arcus_Transactions__c DCP_obj = new DCp_Arcus_Transactions__c();
        DCP_obj.Application__c = app1.Id;
        DCP_obj.Card_Number__c = '1234568';
        DCP_obj.Bank_Name__c = 'CITI';
        DCP_obj.Pay_at_Funding__c = true;
        DCP_obj.Requested_Amount__c = 200;
        DCP_obj.Transaction_id__c = '87007jj798889';
        insert DCP_obj;
        
        List<id> appId = new List<id>();
        appId.add(app1.id);
        InvestorAllocation.allocateInvestor(appId);

        /* retrigger again for re-allocation coverage */
        InvestorAllocation.allocateInvestor(appId);
        
        Pricing_Offer__c  pOffer = new Pricing_Offer__c();
        pOffer.Above_prime_max__c= 'false';
        pOffer.Amount__c = 8000;
        pOffer.Application__c =app2.id;
        pOffer.APR__c = 11.997986061655;
        pOffer.Interest_Rate__c =9.97;
        pOffer.Is_Offer_Selected__c = true;
        pOffer.Key__c = 6;
        pOffer.Monthly_Payment__c = 215.489647581694;
        pOffer.Origination_fee__c = 160;
        pOffer.Origination_fee_rate__c = 2;
        pOffer.Pricing_Tier__c = 't2';
        pOffer.Segment__c = 'prime';
        pOffer.Term__c = 24;
        pOffer.Type__c = 'ABC';
        insert pOffer; 
        System.debug('pOffer ' + pOffer.Pricing_Tier__c); 
        
        DCp_Arcus_Transactions__c DCP_obj2 = new DCp_Arcus_Transactions__c();
        DCP_obj2.Application__c = app2.Id;
        DCP_obj2.Card_Number__c = '1234568';
        DCP_obj2.Bank_Name__c = 'CITI';
        DCP_obj2.Pay_at_Funding__c = true;
        DCP_obj2.Requested_Amount__c = 200;
        DCP_obj2.Transaction_id__c = '87007jj798889';
        insert DCP_obj2;
        
        app2.genesis__Status__c = 'agent_document_verification_pending';
        try{
            update app2;
        }catch(Exception e){
            //Do nothing
        }
         
         
        /*List<id> appId1 = new List<id>();
        appId1.add(app2.id);
        InvestorAllocation.allocateInvestor(appId1);*/
                 
        test.stopTest();
        //pallavi
     }  
    
    @isTest static Void investorAllocationWhenAllInvestorsCurrentWeightHasReachedTheLimit(){
        test.startTest();
        genesis__Rule__c rule = new genesis__Rule__c();
        rule.name                       = 'TCU ruleset';
        rule.genesis__Enabled__c        = true;
        rule.genesis__Object_Type__c    = 'genesis__applications__c';
        rule.genesis__Evaluation_Expression__c = '1';
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
            Investor_Current_Weight__c = 4,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =10
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
            Investor_Current_Weight__c = 4,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0,
			DCP_Allowed__c = true            
        );
        Insert acc2;
        
        genesis__Applications__c app1 = new genesis__Applications__c(
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
        Insert app1;
         
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
            DCP_Investor_Eligibility__c = false,
            Investor__c = acc1.id
        );      
        Insert app2;
        
        app2.genesis__Status__c = 'Offer_accepted';
        update app2; 
                 
        test.stopTest();
     }
    
    @isTest static Void investorAllocationWhenAllInvestorsCurrentWeightisZeroandAllocatedWeightisNull(){
        test.startTest();
        genesis__Rule__c rule = new genesis__Rule__c();
        rule.name                       = 'TCU ruleset';
        rule.genesis__Enabled__c        = true;
        rule.genesis__Object_Type__c    = 'genesis__applications__c';
        rule.genesis__Evaluation_Expression__c = '1';
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
                //genesis__RuleCriteria__c rul =[select id,name,genesis__Rule__r.name from genesis__RuleCriteria__c where genesis__Rule__r.name = 'TCU ruleset'];
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
            Investor_Alloted_Weight__c = 0,
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            // Total_Allocations_MTD__c =1,
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
            Investor_Alloted_Weight__c = 0,
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0,
			DCP_Allowed__c = true            
        );
        Insert acc2;
        
         Account acc3 = new Account(
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
            Investor_Alloted_Weight__c = 0,
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0
        );
        Insert acc3;
         
        
        genesis__Applications__c app1 = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = false,
            genesis__Account__c = acc1.Id,
            Invested_Amount__c  = 1000,       
            Application_Start_DateV2__c = system.Today(),
            //genesis__Status__c = 'offer_shown',
            genesis__Status__c = 'Offer_accepted',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c    = 'Full Time',
            genesis__Loan_Amount__c = 1000,
            DCP_Investor_Eligibility__c = false
        );      
        Insert app1;
        List<Account> listInvestor = [Select id,name,
                                      Investment_Rules__c,
                                      loan__Investor__c,
                                      Last_Application_assigned_on__c,
                                      Amount_Invested__c,
                                      Number_Of_Applications_Invested__c
                                      FROM Account
                                      WHERE loan__Investor__c = true
                                      AND Remaining_Amount__c >=: app1.genesis__loan_amount__c
                                      AND Remaining_Applications__c >=: 1
                                      AND loan__Active__c = 'Yes'
                                      AND Name = 'Test1'
                                      order by Last_Application_assigned_on__c
                                     ];
        
        System.debug('****System.debug in Test Class*******'+listInvestor.size());
        InvestorAllocation inv = new InvestorAllocation(true);
        InvestorAllocation.runInvestorAllocationBasedOnWeighting(app1.id);
        genesis__applications__c apps = [select id,name,investor__c from genesis__applications__c where id =: app1.id];
        System.assertEquals(apps.investor__c,null );
        genesis.RulesAPI.evaluateRules(app1,null,true,false);                 
        
         
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
            DCP_Investor_Eligibility__c = false,
            Investor__c = null
        );      
        Insert app2;
        
        app2.genesis__Status__c = 'Offer_accepted';
        update app2; 
                 
        test.stopTest();
     }
    
    @isTest static Void investorAllocationWhenAllInvestorsCurrentWeightisnotZeroandAllocatedWeightisNull(){
        test.startTest();
        genesis__Rule__c rule = new genesis__Rule__c();
        rule.name                       = 'TCU ruleset';
        rule.genesis__Enabled__c        = true;
        rule.genesis__Object_Type__c    = 'genesis__applications__c';
        rule.genesis__Evaluation_Expression__c = '1';
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
            //Investor_Alloted_Weight__c = 4,
            Investor_Current_Weight__c = 2,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c = 1
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
            //Investor_Alloted_Weight__c = 4,
            Investor_Current_Weight__c = 2,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0,
			DCP_Allowed__c = true            
        );
        Insert acc2;
        
        genesis__Applications__c app1 = new genesis__Applications__c(
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
        Insert app1;
         
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
            DCP_Investor_Eligibility__c = false,
            Investor__c = null
        );      
        Insert app2;
        
        app2.genesis__Status__c = 'Offer_accepted';
        update app2; 
                 
        test.stopTest();
     }

    @IsTest static void testSendMissingCreditPolicyLog() {

        Account applicantAccount = GetApplicantAccount();
        insert applicantAccount;

        Account investor = MW_GlobalTestUtility.GetAccount('Investor');
        insert investor;

        genesis__Applications__c application = GetADVPApplication(investor, applicantAccount);
        insert application;

        List<Id> appIds = new List<Id>();
        appIds.add(application.Id);

        InvestorAllocation.sendMissingCreditPolicyLog(appIds);

        InvestorAllocation.sendMissingCreditPolicyLog(null);
    }

    @IsTest static void testInsertBatchLogsForAppException() {

        Account applicantAccount = GetApplicantAccount();
        insert applicantAccount;

        Account investor = MW_GlobalTestUtility.GetAccount('Investor');
        insert investor;

        genesis__Applications__c application = GetADVPApplication(investor, applicantAccount);
        insert application;

        /* test missing exception */
        InvestorAllocation.insertBatchLogsForAppException(null, investor, application);

        try {
            throw new IllegalArgumentException('exception for test coverage');
        } catch (Exception e) {

            /* test missing investor */
            InvestorAllocation.insertBatchLogsForAppException(e, null, application);

            /* test missing application */
            InvestorAllocation.insertBatchLogsForAppException(e, investor, null);

            /* test current usage */
            InvestorAllocation.insertBatchLogsForAppException(e, investor, application);

            List<clcommon__Batch_Process_Log__c> logs =
                [SELECT Id,
                        clcommon__Batch_Id__c,
                        clcommon__Message__c,
                        clcommon__Type__c
                 FROM   clcommon__Batch_Process_Log__c
                 WHERE  clcommon__Batch_Id__c =: application.Id];

            System.assertEquals(3, logs.size());

            clcommon__Batch_Process_Log__c nullExceptionBl = logs.get(0);
            System.assertEquals(String.valueOf(application.Id), nullExceptionBl.clcommon__Batch_Id__c);

            clcommon__Batch_Process_Log__c missingAppBl = logs.get(1);
            System.assertEquals(String.valueOf(application.Id), missingAppBl.clcommon__Batch_Id__c);
            System.assert(missingAppBl.clcommon__Message__c.contains('missing'));

            clcommon__Batch_Process_Log__c appBl = logs.get(2);
            System.assertEquals(String.valueOf(application.Id), appBl.clcommon__Batch_Id__c);
            System.assert(appBl.clcommon__Message__c.contains(application.Lead_ID__c));
        }
    }

    @IsTest static void testInsertLoanBatchLogsForGenericException() {

        InvestorAllocation.insertLoanBatchLogsForGenericException(null);

        try {
            throw new IllegalArgumentException('exception for test coverage');
        } catch (Exception e) {
            InvestorAllocation.insertLoanBatchLogsForGenericException(e);

            List<loan__Batch_Process_Log__c> logs =
                [SELECT loan__Origin__c,
                        loan__Message__c,
                        loan__Type__c
                 FROM   loan__Batch_Process_Log__c];

            System.assertEquals(2, logs.size());

            loan__Batch_Process_Log__c nullExceptionLog = logs.get(0);
            System.assertEquals('Business Rule Engine', nullExceptionLog.loan__Origin__c);

            loan__Batch_Process_Log__c testExceptionLog = logs.get(1);
            System.assertEquals('Business Rule Engine', testExceptionLog.loan__Origin__c);
            System.assert(testExceptionLog.loan__Message__c.contains('exception for test coverage'));
        }
    }

    @IsTest static void testAddBatchLogsToList() {

        Account investor = MW_GlobalTestUtility.GetAccount('Investor');
        investor.Name = 'BatchLogInvestor';
        insert investor;

        Account applicantAccount = GetApplicantAccount();
        insert applicantAccount;

        genesis__Applications__c application = GetADVPApplication(investor, applicantAccount);
        insert application;

        try {
            InvestorAllocation.addBatchLogsToList(null, investor, application);
        } catch (Exception e) {
            System.assertEquals('Null batch process logs', e.getMessage());
        }

        List<clcommon__Batch_Process_Log__c> logs = new List<clcommon__Batch_Process_Log__c>();

        InvestorAllocation.addBatchLogsToList(logs, investor, null);
        InvestorAllocation.addBatchLogsToList(logs, null, application);

        System.assertEquals(2, logs.size());

        clcommon__Batch_Process_Log__c nullAppLog = logs.get(0);
        System.assertEquals('missing', nullAppLog.clcommon__Batch_Id__c);
        System.assert(nullAppLog.clcommon__Message__c.startsWith('Can not allocate'));

        clcommon__Batch_Process_Log__c nullInvestorLog = logs.get(1);
        System.assertEquals(String.valueOf(application.Id), nullInvestorLog.clcommon__Batch_Id__c);
        System.assert(nullInvestorLog.clcommon__Message__c.startsWith('Can not allocate'));
        System.assert(nullInvestorLog.clcommon__Message__c.contains(application.Lead_ID__c));
    }

    private static Account GetInvestorWithRuleset(genesis__Rule__c rule) {
        Account acc1 = new Account(
                Name = 'Test1',
                loan__Investor__c = true,
                Amount_Invested__c = 1000,
                Investment_Rules__c = rule.Id,
                Number_Of_Applications_Invested__c = 3,
                Total_No_of_Application_Limit__c = 30,
                Last_Application_assigned_on__c = System.now()-7,
                Total_Investment_Limit__c = 1000000,
                loan__Undeployed_Funds__c = 500000,
                cnotify__Email__c = 'no-reply@testorganization.com',
                peer__First_Name__c = 'TestFName1',
                peer__Last_Name__c='TestLName2',
                loan__Active__c = 'YES',
                City__c='CANADA',
                State__c='CA',
                ZIP_Code__c='123456'
        );
        return acc1;
    }

    private static Account GetApplicantAccount() {
        Account acco = new Account(
                Name = 'Test',
                loan__Investor__c= false,
                cnotify__Email__c = 'no-reply@testorganization.com',
                peer__First_Name__c = 'TestFName2',
                peer__Last_Name__c='TestLName2',
                City__c='CANADA',
                State__c='CA',
                ZIP_Code__c='123456'
        );
        return acco;
    }

    private static genesis__Applications__c GetADVPApplication(Account investor, Account applicant) {
        genesis__Applications__c app1 = new genesis__Applications__c(
                Lead_ID__c = 'c9149473-e69f-ee12-38a7-d18b0cba847d',
                genesis__Due_Day__c = 20,
                genesis__Expected_First_Payment_Date__c = System.today(),
                genesis__Expected_Start_Date__c = System.today(),
                genesis__Funding_in_Tranches__c = false,
                genesis__Account__c = applicant.Id,
                Investor__c  = investor.Id,
                Invested_Amount__c  = 1000,
                Application_Start_DateV2__c = System.today(),
                genesis__Status__c = 'agent_document_verification_pending',
                genesis__Draw_Period_End_Date__c = System.today(),
                Employment_Status__c    = 'Full Time',
                genesis__Loan_Amount__c = 1000
        );
        return app1;
    }

    private static genesis__Rule__c GetRule(String name, String expression) {
        genesis__Rule__c rule = new genesis__Rule__c();
        rule.Name                       = name;
        rule.genesis__Enabled__c        = true;
        rule.genesis__Object_Type__c    = 'genesis__applications__c';
        rule.genesis__Message_failure__c = 'FAIL cannot allocate to ' + name;
        rule.genesis__Message_success__c = 'Successful allocation to ' + name;
        rule.genesis__Evaluation_Expression__c = expression;
        return rule;
    }

    private static genesis__RuleCriteria__c GetCreditPolicyCriteria(Decimal sequenceNum, genesis__Rule__c rule, RelatedObject ro) {

        String relatedObj;
        String objectReference;

        switch on ro {
            when CREDIT_POLICY {
                relatedObj = 'Credit_Policy__c';
                objectReference = 'Application__r';
            }
            when APPLICATIONS {
                relatedObj = 'genesis__Applications__c';
                objectReference = 'genesis__Applications__c';
            }
            when else {
                throw new IllegalArgumentException('Configure a new type for testing credit policy creation');
            }
        }

        genesis__RuleCriteria__c criteria = new genesis__RuleCriteria__c(
                genesis__Criteria_Sequence__c = sequenceNum,
                genesis__Field_Type__c        = 'DOUBLE',
                genesis__Maximum_Value__c     = '',
                genesis__Minimum_Value__c     = '',
                genesis__Related_Object__c    = relatedObj,
                genesis__Rule_Object_Reference__c = objectReference,
                genesis__Rule__c = rule.Id,
                genesis__Stipulation_Type__c = 'FUNDING'
        );

        return criteria;
    }

    private static CL_Document__c GetDocument() {
        CL_Document__c document = new CL_Document__c();
        document.Doc1__c = 'Credit Score Notice';
        document.Doc2__c = 'TIL Document';
        document.Doc3__c = 'Adverse Action Notice';
        return document;
    }

    private static Credit_Policy__c GetCreditPolicy(genesis__Applications__c application, Decimal fico, Decimal ndi) {
        Credit_Policy__c creditPolicy = new Credit_Policy__c();
        creditPolicy.request_intent__c = 'application';
        creditPolicy.FICO__c = fico;
        creditPolicy.Net_Disposable_Income_NDI__c = ndi == null ? null : String.valueOf(ndi);
        creditPolicy.Application__c = application.Id;
        return creditPolicy;
    }

    private static genesis__RuleCriteria__c GetFICOCriteria(Decimal sequenceNum, genesis__Rule__c rule, Integer matchingValue, RelatedObject ro) {
        genesis__RuleCriteria__c fico = GetCreditPolicyCriteria(sequenceNum, rule, ro);
        fico.genesis__Field_API_Name__c = 'FICO__c';
        fico.genesis__Field_Name__c = 'FICO';
        fico.genesis__Matching_Type__c = '>=';
        fico.genesis__Matching_Value__c = String.valueOf(matchingValue);
        return fico;
    }

    private static genesis__RuleCriteria__c GetNDICriteria(Decimal sequenceNum, genesis__Rule__c rule, Integer matchingValue, RelatedObject ro) {
        genesis__RuleCriteria__c ndi = GetCreditPolicyCriteria(sequenceNum, rule, ro);
        ndi.genesis__Field_API_Name__c = 'Net_Disposable_Income_NDI_Num__c';
        ndi.genesis__Field_Name__c = 'Net Disposable Income NDI Num';
        ndi.genesis__Matching_Type__c = '>=';
        ndi.genesis__Matching_Value__c = String.valueOf(matchingValue);
        return ndi;
    }

    /**
     * @param id Id of a valid applicatoin
     * @return An application with columns identical to RulesApi columns used in IA.
     */
    private static genesis__Applications__c selectApplicationForRuleset(Id id) {

        genesis__Applications__c appTest =
        [SELECT Id,
                Name,
                Investor__c,
                DCP_Investor_Eligibility__c,
                genesis__Status__c,
                genesis__Loan_Amount__c,
                Invested_Amount__c,
                genesis__Lending_Product__c,
                Last_Investor_Assigned_On__c,
                Total_Arcus_Transactions__c
        FROM   genesis__Applications__c
        WHERE  Id =: id
        LIMIT 1];

        return appTest;
    }
}