/******************Modification History******************
 * Created By       	 Date          JIRA number
 *1. Anusha		2020/12/01 	   CRM-1022 Status 500 responses causing missing data in CLS - CLS Case #02456279
 *
 ******************Modification History******************/
@isTest
public class TestSelectOfferFromUI{
    @testSetup static void methodName() {
        // retriggering update
        Account acc = new Account(
            Name = 'TestF1Name TestL1Name',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc1@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123123123',
            peer__First_Name__c = 'TestF1Name',
            peer__Last_Name__c='TestL1Name', 
            City__c='TestCity',
            State__c='TestState',
            ZIP_Code__c='12345'
            );
        insert acc;
       

        Account acc1 = new Account(
            Name = 'TestF2Name TestL2Name',
            loan__Investor__c=true,
            loan__active__c = 'Yes',
            Investor_Alloted_Weight__c = 2,
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0,
            cnotify__Email__c = 'abc2@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123123124',
            peer__First_Name__c = 'TestF2Name',
            peer__Last_Name__c='TestL2Name', 
            City__c='TestCity',
            State__c='TestState',
            ZIP_Code__c='12345'
            );
            
            insert acc1;

        Account acc2 = new Account(
            Name = 'TestF3Name TestL3Name',
            loan__Investor__c=true,
            loan__active__c = 'Yes',
            Investor_Alloted_Weight__c = 2,
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = null,
            Total_Funded_YTD__c = null,
            Total_Funded_Till_date__c = null,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0,
            cnotify__Email__c = 'abc3@test2.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123123125',
            Amount_Invested__c = 8000,
            peer__First_Name__c = 'TestF3Name',
            peer__Last_Name__c='TestL3Name', 
            City__c='TestCity',
            State__c='TestState',
            ZIP_Code__c='12345'
            );
            insert acc2;

        Account acc3 = new Account(
            Name = 'TestF4Name TestL4Name',
            loan__Investor__c=true,
            loan__active__c = 'Yes',
            Investor_Alloted_Weight__c = 2,
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = null,
            Total_Funded_YTD__c = null,
            Total_Funded_Till_date__c = null,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0,
            cnotify__Email__c = 'abc4@test2.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123123126',
            Amount_Invested__c = 8000,
            peer__First_Name__c = 'TestF4Name',
            peer__Last_Name__c='TestL4Name', 
            City__c='TestCity',
            State__c='TestState',
            ZIP_Code__c='12345'
            );
            insert acc3;
    }

    @isTest static void method1(){
        Account acc =[Select id, name from Account where name='TestF1Name TestL1Name' limit 1];
        //Creating Application
        genesis__Applications__c app= new genesis__Applications__c(
                                            genesis__Due_Day__c = 20,
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
        insert app;
        
        System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');

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
        pOfferTrue.EBP_Offer_Code__c = '2021Feb_ebp_DCP_75';
        pOfferTrue.EBP_Parent_Offer_Key__c = '';
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
                                            Type__c ='test',
                                            EBP_Offer_Code__c = '2021Feb_ebp_DCP_75',
                                            EBP_Parent_Offer_Key__c = ''    
                                            );
        insert appOffer;

        Test.startTest();

        CL_Document__c document = new CL_Document__c();
        document.Doc1__c = 'Credit Score Notice';
        document.Doc2__c = 'TIL Document';
        document.Doc3__c = 'Adverse Action Notice';
        insert document;

       	app.genesis__Financed_Amount__c = 1050.00;
        String result = SelectOfferFromUI.selectOffer(app.id,pOfferTrue.id);
        SelectOfferFromUI.getselectedoffer(app.id);
        System.assertEquals('Offer is been successfully approved/selected', result, 'Success');
        //SelectOfferFromUI.getselectedoffer(app1.id);
        Test.stopTest();
             
    }
    
    @isTest static void method2(){
        Account acc =[Select id, name from Account where name='TestF1Name TestL1Name' limit 1];
        Account acc1 =[Select id, name from Account where name='TestF2Name TestL2Name' limit 1];
        //Creating Application
        genesis__Applications__c app= new genesis__Applications__c(
                                            genesis__Due_Day__c = 20,
                                            genesis__Expected_First_Payment_Date__c = system.Today(),
                                            genesis__Expected_Start_Date__c = system.Today(),
                                            genesis__Funding_in_Tranches__c = true,
                                            Borrower_s_Email__c = null,
                                            genesis__Account__c = acc.Id,
                                            Application_Start_DateV2__c = system.Today(),
                                            DocuSignFlag__c=true,
                                            genesis__Status__c = 'agent_verified',
                                            genesis__Draw_Period_End_Date__c = system.Today(),
            								Investor__c = acc1.id
                                            );
        insert app;
        
        System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');
                
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
        pOfferTrue.EBP_Offer_Code__c = '2021Feb_ebp_DCP_90';
        pOfferTrue.EBP_Parent_Offer_Key__c = '';
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
                                            Type__c ='test',
                                            EBP_Offer_Code__c = '2021Feb_ebp_DCP_90',
                                            EBP_Parent_Offer_Key__c = ''    
                                            );
        insert appOffer;  
        Test.startTest();

        CL_Document__c document = new CL_Document__c();
        document.Doc1__c = 'Credit Score Notice';
        document.Doc2__c = 'TIL Document';
        document.Doc3__c = 'Adverse Action Notice';
        insert document;

       	app.genesis__Financed_Amount__c = 1050.00;
        String result = SelectOfferFromUI.selectOffer(app.id,pOfferTrue.id);
        SelectOfferFromUI.getselectedoffer(app.id);
        //SelectOfferFromUI.getselectedoffer(app1.id);
        System.assertEquals('Offer is been successfully approved/selected', result, 'Success');
        Test.stopTest();
             
    }
    
    //CRM-1022 - start
    @isTest static void method3SingleInvestor(){   
        Account acc =[Select id, name from Account where name='TestF1Name TestL1Name' limit 1];
        Account acc1 =[Select id, name from Account where name='TestF2Name TestL2Name' limit 1];
        Account acc2 =[Select id, name from Account where name='TestF3Name TestL3Name' limit 1];
        acc2.loan__active__c = 'No';
        update acc2;
        Account acc3 =[Select id, name from Account where name='TestF4Name TestL4Name' limit 1];
        acc3.loan__active__c = 'No';
        update acc3;
        //Creating Application
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
                                            genesis__Draw_Period_End_Date__c = system.Today(),
            								Investor__c = acc1.id,
            								Invested_Amount__c = 200,
            								genesis__loan_amount__c = 5000
                                            );
        insert app;
        
        System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');
        
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
        pOfferTrue.EBP_Offer_Code__c = '2021Feb_ebp_DCP_optout';
        pOfferTrue.EBP_Parent_Offer_Key__c = '';
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
                                            Type__c ='test',
                                            EBP_Offer_Code__c = '2021Feb_ebp_DCP_optout',
                                            EBP_Parent_Offer_Key__c = ''  
                                            );
        insert appOffer;  
        Test.startTest();
       	app.genesis__Financed_Amount__c = 1050.00;
        String result = SelectOfferFromUI.selectOffer(app.id,pOfferTrue.id);
        System.assertEquals('Offer is been successfully approved/selected', result, 'Success');
        Test.stopTest();
        acc2.loan__active__c = 'Yes';
        update acc2;
        acc3.loan__active__c = 'Yes';
        update acc3;
    }
    
    @isTest static void method4TwoInvestors(){
        Account acc =[Select id, name from Account where name='TestF1Name TestL1Name' limit 1];
        Account acc2 =[Select id, name from Account where name='TestF3Name TestL3Name' limit 1];
        Account acc3 =[Select id, name from Account where name='TestF4Name TestL4Name' limit 1];
        acc3.loan__active__c = 'No';
        update acc3;
        //Creating Application
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
                                            genesis__Draw_Period_End_Date__c = system.Today(),
            								Invested_Amount__c = 200,
            								genesis__Loan_Amount__c = 15000,
            								Investor__c = acc2.id
                                            );
        insert app;
        
        System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');
        
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
        pOfferTrue.EBP_Offer_Code__c = '2021Feb_ebp_DCP_optout';
        pOfferTrue.EBP_Parent_Offer_Key__c = '';
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
                                            Type__c ='test',
                                            EBP_Offer_Code__c = '2021Feb_ebp_DCP_optout',
                                            EBP_Parent_Offer_Key__c = ''    
                                            );
        insert appOffer;  
        Test.startTest();
       	app.genesis__Financed_Amount__c = 1050.00;
        String result = SelectOfferFromUI.selectOffer(app.id,pOfferTrue.id);
        System.assertEquals('Offer is been successfully approved/selected', result, 'Success');
        app.Investor__c = acc3.Id;
        update app;
        String result2 = SelectOfferFromUI.runInvestorAllocationBasedOnWeighting(app);
        System.assertEquals('No such investors available', result2, 'No available investors');
        Test.stopTest();
        acc3.loan__active__c = 'Yes';
        update acc3;
    }

    @IsTest static void testMultipleInvestorsWithRuleset() {


        genesis__Rule__c rule = new genesis__Rule__c();
        rule.Name                       = 'Simple rule';
        rule.genesis__Enabled__c        = true;
        rule.genesis__Object_Type__c    = 'genesis__applications__c';
        rule.genesis__Message_failure__c = 'FAIL cannot allocate to Simple Rule';
        rule.genesis__Message_success__c = 'Successful allocation to Simple Rule';
        rule.genesis__Evaluation_Expression__c = '1';
        insert rule;

        genesis__RuleCriteria__c criteria = new genesis__RuleCriteria__c();
        criteria.genesis__Criteria_Sequence__c = 1.0;
        criteria.genesis__Field_Type__c        = 'DOUBLE';
        criteria.genesis__Maximum_Value__c     = '';
        criteria.genesis__Minimum_Value__c     = '';
        criteria.genesis__Related_Object__c    = 'Credit_Policy__c';
        criteria.genesis__Rule_Object_Reference__c = 'Application__r';
        criteria.genesis__Rule__c = rule.Id;
        criteria.genesis__Stipulation_Type__c = 'FUNDING';
        insert criteria;

        Account applicantAccount =[SELECT Id, Name FROM Account WHERE Name='TestF1Name TestL1Name' LIMIT 1];
        Account investor1 =[SELECT Id, Name FROM Account WHERE Name='TestF3Name TestL3Name' LIMIT 1];
        Account investor2 =[SELECT Id, Name FROM Account WHERE Name='TestF4Name TestL4Name' LIMIT 1];
        investor2.Loan__Active__c = 'No';
        update investor2;

        investor1.Investment_Rules__c = rule.Id;
        update investor1;

        /* create application */
        genesis__Applications__c app = MW_GlobalTestUtility.GetApplication();
        app.genesis__Due_Day__c = 20;
        app.genesis__Funding_in_Tranches__c = true;
        app.Borrower_s_Email__c = null;
        app.genesis__Account__c = applicantAccount.Id;
        app.DocuSignFlag__c=true;
        app.genesis__Status__c = 'offer_accepted';
        app.Invested_Amount__c = 200;
        app.Investor__c = investor1.Id;
        insert app;

        System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');

        Pricing_Offer__c  pOfferTrue = new Pricing_Offer__c();
        pOfferTrue.Above_prime_max__c= 'false';
        pOfferTrue.Amount__c = 8000;
        pOfferTrue.Application__c =app.Id;
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
        pOfferTrue.EBP_Offer_Code__c = '2021Feb_ebp_DCP_optout';
        pOfferTrue.EBP_Parent_Offer_Key__c = '';
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
                Type__c ='test',
                EBP_Offer_Code__c = '2021Feb_ebp_DCP_optout',
                EBP_Parent_Offer_Key__c = ''
        );
        insert appOffer;

        Test.startTest();
        app.genesis__Financed_Amount__c = 1050.00;
        String result = SelectOfferFromUI.selectOffer(app.id,pOfferTrue.id);
        System.assertEquals('Offer is been successfully approved/selected', result, 'Success');
        app.Investor__c = investor2.Id;
        update app;
        String result2 = SelectOfferFromUI.runInvestorAllocationBasedOnWeighting(app);
        System.assertEquals('No such investors available', result2, 'No available investors');
        Test.stopTest();
        investor2.Loan__Active__c = 'Yes';
        update investor2;
    }

    @IsTest static void testBatchProcessInsertion() {
        genesis__Applications__c app = MW_GlobalTestUtility.GetApplication();
        insert app;
        String applicationId = String.valueOf(app.Id);
        try {
            throw new IllegalArgumentException('exception for test coverage purposes');
        } catch (Exception ex) {
            SelectOfferFromUI.insertBatchLogFromException(ex, applicationId);
        }

        List <loan__Batch_Process_Log__c> logs =
        [SELECT loan__Message__c
         FROM    loan__Batch_Process_Log__c
         WHERE   loan__Origin__c = 'SelectOfferUI'];

        System.assert(logs.size() == 1);
        System.assert(logs.get(0).loan__Message__c.containsIgnoreCase(app.Lead_ID__c));
    }

    @isTest static void method5InvestorCurrentWeightNotZero(){
        Account acc =[Select id, name from Account where name='TestF1Name TestL1Name' limit 1];
        Account acc1 =[Select id, name from Account where name='TestF2Name TestL2Name' limit 1];
        acc1.Investor_Current_Weight__c = 1;
        update acc1;
        Account acc2 =[Select id, name from Account where name='TestF3Name TestL3Name' limit 1];
        acc2.loan__active__c = 'No';
        update acc2;
        Account acc3 =[Select id, name from Account where name='TestF4Name TestL4Name' limit 1];
        acc3.loan__active__c = 'No';
        update acc3;
        
        //Creating Application
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
                                            genesis__Draw_Period_End_Date__c = system.Today(),
            								Invested_Amount__c = 200,
            								genesis__loan_amount__c = 8000,
            								Investor__c = null
                                            );
        insert app;
        
        System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');
        
        Pricing_Offer__c  pOfferTrue = new Pricing_Offer__c();
        pOfferTrue.Above_prime_max__c= 'false';
        pOfferTrue.Amount__c = 8000;
        pOfferTrue.Application__c =app.id;
        pOfferTrue.APR__c = 11.997986061655;
        pOfferTrue.Interest_Rate__c =9.97;
        pOfferTrue.Is_Offer_Selected__c = false;
        pOfferTrue.Key__c = 6;
        pOfferTrue.Monthly_Payment__c = 215.489647581694;
        pOfferTrue.Origination_fee__c = 160;
        pOfferTrue.Origination_fee_rate__c = 2;
        pOfferTrue.Pricing_Tier__c = 't2';
        pOfferTrue.Segment__c = 'prime';
        pOfferTrue.Term__c = 24;
        pOfferTrue.Type__c = 'ABC';
        pOfferTrue.EBP_Offer_Code__c = '2021Feb_ebp_DCP_optout';
        pOfferTrue.EBP_Parent_Offer_Key__c = '';
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
                                            Type__c ='test',
                                            EBP_Offer_Code__c = '2021Feb_ebp_DCP_optout',
                                            EBP_Parent_Offer_Key__c = ''    
                                            );
        insert appOffer;
        Test.startTest();
       	app.genesis__Financed_Amount__c = 1050.00;
        //SelectOfferFromUI.selectOffer(app.id,pOfferTrue.id);
        String result = SelectOfferFromUI.runInvestorAllocationBasedOnWeighting(app);
        System.assertEquals('Success', result, 'Success');

        Test.stopTest();
        acc1.Investor_Current_Weight__c = 0;
        update acc1;
        acc2.loan__active__c = 'Yes';
        update acc2;
        acc3.loan__active__c = 'Yes';
        update acc3;
    }
    
    @isTest static void method6currentWeightZeroNotEqualtoTotalInvestor(){
        Account acc =[Select id, name from Account where name='TestF1Name TestL1Name' limit 1];

        //Creating Application
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
                                            genesis__Draw_Period_End_Date__c = system.Today(),
            								Invested_Amount__c = 200,
            								genesis__loan_amount__c = 8000,
            								Investor__c = null
                                            );
        insert app;
        
        System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');
        
        Pricing_Offer__c  pOfferTrue = new Pricing_Offer__c();
        pOfferTrue.Above_prime_max__c= 'false';
        pOfferTrue.Amount__c = 8000;
        pOfferTrue.Application__c =app.id;
        pOfferTrue.APR__c = 11.997986061655;
        pOfferTrue.Interest_Rate__c =9.97;
        pOfferTrue.Is_Offer_Selected__c = false;
        pOfferTrue.Key__c = 6;
        pOfferTrue.Monthly_Payment__c = 215.489647581694;
        pOfferTrue.Origination_fee__c = 160;
        pOfferTrue.Origination_fee_rate__c = 2;
        pOfferTrue.Pricing_Tier__c = 't2';
        pOfferTrue.Segment__c = 'prime';
        pOfferTrue.Term__c = 24;
        pOfferTrue.Type__c = 'ABC';
        pOfferTrue.EBP_Offer_Code__c = '2021Feb_ebp_DCP_optout';
        pOfferTrue.EBP_Parent_Offer_Key__c = '';
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
                                            Type__c ='test',
                                            EBP_Offer_Code__c = '2021Feb_ebp_DCP_optout',
                                            EBP_Parent_Offer_Key__c = ''    
                                            );
        insert appOffer;
        Test.startTest();
       	app.genesis__Financed_Amount__c = 1050.00;
        //SelectOfferFromUI.selectOffer(app.id,pOfferTrue.id);
        String result = SelectOfferFromUI.runInvestorAllocationBasedOnWeighting(app);
        System.assertEquals('Success', result, 'Success');
        Test.stopTest();
    }
    
    @isTest static void method7InvestorCurrentWeightGreater(){
        Account acc =[Select id, name from Account where name='TestF1Name TestL1Name' limit 1];
        Account acc1 =[Select id, name from Account where name='TestF2Name TestL2Name' limit 1];
        acc1.Investor_Current_Weight__c = 3;
        update acc1;
        Account acc2 =[Select id, name from Account where name='TestF3Name TestL3Name' limit 1];
        acc2.loan__active__c = 'No';
        update acc2;
        Account acc3 =[Select id, name from Account where name='TestF4Name TestL4Name' limit 1];
        acc3.loan__active__c = 'No';
        update acc3;

        //Creating Application
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
                                            genesis__Draw_Period_End_Date__c = system.Today(),
            								Invested_Amount__c = 200,
            								genesis__loan_amount__c = 8000,
            								Investor__c = null
                                            );
        insert app;
        
        System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');
        
        Pricing_Offer__c  pOfferTrue = new Pricing_Offer__c();
        pOfferTrue.Above_prime_max__c= 'false';
        pOfferTrue.Amount__c = 8000;
        pOfferTrue.Application__c =app.id;
        pOfferTrue.APR__c = 11.997986061655;
        pOfferTrue.Interest_Rate__c =9.97;
        pOfferTrue.Is_Offer_Selected__c = false;
        pOfferTrue.Key__c = 6;
        pOfferTrue.Monthly_Payment__c = 215.489647581694;
        pOfferTrue.Origination_fee__c = 160;
        pOfferTrue.Origination_fee_rate__c = 2;
        pOfferTrue.Pricing_Tier__c = 't2';
        pOfferTrue.Segment__c = 'prime';
        pOfferTrue.Term__c = 24;
        pOfferTrue.Type__c = 'ABC';
        pOfferTrue.EBP_Offer_Code__c = '2021Feb_ebp_DCP_optout';
        pOfferTrue.EBP_Parent_Offer_Key__c = '';
        insert pOfferTrue;
        Approved_Offer__c appOffer = new Approved_Offer__c( 
                                            Above_prime_max__c = 'false',
                                            Amount__c = 1200.00,
                                            Application__c=null,
                                            APR__c ='11.99',
                                            Interest_Rate__c = '9.97',
                                            Key__c = '5',
                                            Monthly_Payment__c = 200,
                                            Origination_fee__c = '150.00',
                                            Origination_fee_rate__c = '2.00',
                                            Pricing_Tier__c = 't2',
                                            Segment__c = 'prime',
                                            Term__c = 24,
                                            Type__c ='test',
                                            EBP_Offer_Code__c = '2021Feb_ebp_DCP_optout',
                                            EBP_Parent_Offer_Key__c = ''    
                                            );
        insert appOffer;
        Test.startTest();
       	app.genesis__Financed_Amount__c = 1050.00;
        String result = SelectOfferFromUI.runInvestorAllocationBasedOnWeighting(app);
        System.assertEquals('Success', result, 'Success');
        Test.stopTest();
        acc1.Investor_Current_Weight__c = 0;
        update acc1;
        acc2.loan__active__c = 'Yes';
        update acc2;
        acc3.loan__active__c = 'Yes';
        update acc3;
    }
    
    @isTest static void method8NoActiveInvestor(){
        Account acc1 =[Select id, name from Account where name='TestF2Name TestL2Name' limit 1];
        acc1.loan__active__c = 'No';
        update acc1;
        Account acc2 =[Select id, name from Account where name='TestF3Name TestL3Name' limit 1];
        acc2.loan__active__c = 'No';
        update acc2;
        Account acc3 =[Select id, name from Account where name='TestF4Name TestL4Name' limit 1];
        acc3.loan__active__c = 'No';
        update acc3;
        Account acc =[Select id, name from Account where name='TestF1Name TestL1Name' limit 1];

        //Creating Application
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
                                            genesis__Draw_Period_End_Date__c = system.Today(),
            								Invested_Amount__c = 200,
            								genesis__loan_amount__c = 8000,
            								Investor__c = null
                                            );
        insert app;
                                
        Test.startTest();
       	app.genesis__Financed_Amount__c = 1050.00;
        
        String result = SelectOfferFromUI.runInvestorAllocationBasedOnWeighting(app);
        System.assertEquals('No active investors available', result, 'No available investor');
        Test.stopTest();

        acc1.loan__active__c = 'Yes';
        update acc1;
        acc2.loan__active__c = 'Yes';
        update acc2;
        acc3.loan__active__c = 'Yes';
        update acc3;
    }
    
    @isTest static void method9AppNull(){
        Account acc1 =[Select id, name from Account where name='TestF2Name TestL2Name' limit 1];
        acc1.loan__active__c = 'No';
        update acc1;
                                        
        Test.startTest();
        String result = SelectOfferFromUI.runInvestorAllocationBasedOnWeighting(null);
        System.assertEquals('Error Attempt to de-reference a null object Occured at line number:22', result, 'Success');

        Test.stopTest();
    }
    
    @isTest static void method10GetSelectedOfferCatch(){
        Account acc1 =[Select id, name from Account where name='TestF2Name TestL2Name' limit 1];
        acc1.loan__active__c = 'No';
        update acc1;
        Account acc2 =[Select id, name from Account where name='TestF3Name TestL3Name' limit 1];
        acc2.loan__active__c = 'No';
        update acc2;
        Account acc3 =[Select id, name from Account where name='TestF4Name TestL4Name' limit 1];
        acc3.loan__active__c = 'No';
        update acc3;
        Account acc =[Select id, name from Account where name='TestF1Name TestL1Name' limit 1];

        //Creating Application
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
                                            genesis__Draw_Period_End_Date__c = system.Today(),
            								Invested_Amount__c = 200,
            								genesis__loan_amount__c = 8000
                                            );
        insert app;                   
        Test.startTest();
       	app.genesis__Financed_Amount__c = 1050.00;
        try{
            SelectOfferFromUI.getselectedoffer(app.Id);
        }catch(Exception e){
            System.debug('This is to check exception scenario');
        }
        
        Test.stopTest();
    }
    
    @isTest static void method11InvestedAmountNotNull(){
        Account acc =[Select id, name from Account where name='TestF1Name TestL1Name' limit 1];
        Account acc1 =[Select id, name from Account where name='TestF2Name TestL2Name' limit 1];

        //Creating Application
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
                                            genesis__Draw_Period_End_Date__c = system.Today(),
            								Investor__c = acc1.id,
            								Invested_Amount__c = 200,
            								genesis__loan_amount__c = 5000
                                            );
        insert app;
        
        System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');
        
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
        pOfferTrue.EBP_Offer_Code__c = '2021Feb_ebp_DCP_optout';
        pOfferTrue.EBP_Parent_Offer_Key__c = '';
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
                                            Type__c ='test',
                                            EBP_Offer_Code__c = '2021Feb_ebp_DCP_optout',
                                            EBP_Parent_Offer_Key__c = ''    
                                            );
        insert appOffer;  
        Test.startTest();
       	app.genesis__Financed_Amount__c = 1050.00;
        String result = SelectOfferFromUI.runInvestorAllocationBasedOnWeighting(app);
        System.assertEquals('Success', result, 'Success');
        Test.stopTest();
    }
    //CRM-1022 - end   
}