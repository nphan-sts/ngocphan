@isTest

private class TestInvestorAllocation{
    @isTest static Void InvestorAllocation_Usecase1(){
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
     * Retrigger relaxed quality gate
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

    @isTest static Void InvestorAllocation_UsecaseWeightAllocation(){
        test.startTest();
        
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
     @isTest static Void InvestorAllocation_UsecaseWeightAllocationDCP(){
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
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0,
			DCP_Allowed__c = true            
        );
        Insert acc2;
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
        
        List<id> appId = new List<id>();
        appId.add(app1.id);
        InvestorAllocation.allocateInvestor(appId);
        
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
        Insert app2;
         
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
            Investor_Current_Weight__c = 0,
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
            Investor_Current_Weight__c = 0,
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
    
    @isTest static Void investorAllocationWhenAllInvestorsCurrentWeightisnotZeroandAllocatedWeightisNull(){
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
    
}