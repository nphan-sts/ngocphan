/******************Modification History******************
 * Created By       	 Date          JIRA number
 *1. Anusha		2020/12/01 	   CRM-1022 Status 500 responses causing missing data in CLS - CLS Case #02456279
 *
 ******************Modification History******************/
@isTest
public class TestSelectOfferFromUI{
    testmethod static void method1(){
        
        //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
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
        Test.startTest();
       	app.genesis__Financed_Amount__c = 1050.00;
        SelectOfferFromUI.selectOffer(app.id,pOfferTrue.id);
        SelectOfferFromUI.getselectedoffer(app.id);
        //SelectOfferFromUI.getselectedoffer(app1.id);
        Test.stopTest();
             
    }
    
    testmethod static void method2(){
        
        //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert acc;
         Account acc1 = new Account(
            Name = 'Test',
            loan__Investor__c=true,
            loan__active__c = 'Yes',
            Investor_Alloted_Weight__c = 2,
            Investor_Current_Weight__c = 0,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = 500,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert acc1;
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
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
       	app.genesis__Financed_Amount__c = 1050.00;
        SelectOfferFromUI.selectOffer(app.id,pOfferTrue.id);
        SelectOfferFromUI.getselectedoffer(app.id);
        //SelectOfferFromUI.getselectedoffer(app1.id);
        Test.stopTest();
             
    }
    
    //CRM-1022 - start
    testmethod static void method3SingleInvestor(){
        
        //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert acc;
         Account acc1 = new Account(
            Name = 'Test',
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
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123',
            Amount_Invested__c = 200
            );
        insert acc1;
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
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
        SelectOfferFromUI.selectOffer(app.id,pOfferTrue.id);
        Test.stopTest();
    }
    
    testmethod static void method4TwoInvestors(){
        
        //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert acc;
         Account acc1 = new Account(
            Name = 'Test',
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
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123',
            Amount_Invested__c = 8000
            );
        insert acc1;
        Account acc2 = new Account(
            Name = 'DifferentInvestor',
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
            cnotify__Email__c = 'abc@test2.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123',
            Amount_Invested__c = 8000
            );
        insert acc2;
        
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
        SelectOfferFromUI.selectOffer(app.id,pOfferTrue.id);
        Test.stopTest();
    }
    
   	testmethod static void method5InvestorCurrentWeightNotZero(){
        //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert acc;
         Account acc1 = new Account(
            Name = 'Test',
            loan__Investor__c=true,
            loan__active__c = 'Yes',
            Investor_Alloted_Weight__c = 2,
            Investor_Current_Weight__c = 1,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = null,
            Total_Funded_YTD__c = null,
            Total_Funded_Till_date__c = null,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123',
            Amount_Invested__c = 8000
            );
        insert acc1;
        /*Account acc2 = new Account(
            Name = 'DifferentInvestor',
            loan__Investor__c=true,
            loan__active__c = 'Yes',
            Investor_Alloted_Weight__c = 2,
            Investor_Current_Weight__c = 1,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = null,
            Total_Funded_YTD__c = null,
            Total_Funded_Till_date__c = null,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0,
            cnotify__Email__c = 'abc@test2.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123',
            Amount_Invested__c = 8000
            );
        insert acc2;*/
        
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
        SelectOfferFromUI.runInvestorAllocationBasedOnWeighting(app);
        Test.stopTest();
    }
    
    testmethod static void method6currentWeightZeroNotEqualtoTotalInvestor(){
        //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert acc;
         Account acc1 = new Account(
            Name = 'Test',
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
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123',
            Amount_Invested__c = 8000
            );
        insert acc1;
                
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
        SelectOfferFromUI.runInvestorAllocationBasedOnWeighting(app);
        Test.stopTest();
    }
    
    testmethod static void method7InvestorCurrentWeightGreater(){
        //Creating Account
        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert acc;
         Account acc1 = new Account(
            Name = 'Test',
            loan__Investor__c=true,
            loan__active__c = 'Yes',
            Investor_Alloted_Weight__c = 2,
            Investor_Current_Weight__c = 3,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = null,
            Total_Funded_YTD__c = null,
            Total_Funded_Till_date__c = null,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123',
            Amount_Invested__c = 8000
            );
        insert acc1;
               
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
        SelectOfferFromUI.runInvestorAllocationBasedOnWeighting(app);
        Test.stopTest();
    }
    
    testmethod static void method8NoActiveInvestor(){
        //Creating Account
        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert acc;
         Account acc1 = new Account(
            Name = 'Test',
            loan__Investor__c=true,
            loan__active__c = 'No',
            Investor_Alloted_Weight__c = 2,
            Investor_Current_Weight__c = null,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = null,
            Total_Funded_YTD__c = null,
            Total_Funded_Till_date__c = null,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123',
            Amount_Invested__c = 8000
            );
        insert acc1;
        
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
        
        SelectOfferFromUI.runInvestorAllocationBasedOnWeighting(app);
        Test.stopTest();
    }
    
    testmethod static void method9AppNull(){
        //Creating Account
        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert acc;
         Account acc1 = new Account(
            Name = 'Test',
            loan__Investor__c=true,
            loan__active__c = 'No',
            Investor_Alloted_Weight__c = 2,
            Investor_Current_Weight__c = null,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = null,
            Total_Funded_YTD__c = null,
            Total_Funded_Till_date__c = null,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123',
            Amount_Invested__c = 8000
            );
        insert acc1;
                                        
        Test.startTest();
        SelectOfferFromUI.runInvestorAllocationBasedOnWeighting(null);
        Test.stopTest();
    }
    
    testmethod static void method10GetSelectedOfferCatch(){
        //Creating Account
        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert acc;
         Account acc1 = new Account(
            Name = 'Test',
            loan__Investor__c=true,
            loan__active__c = 'No',
            Investor_Alloted_Weight__c = 2,
            Investor_Current_Weight__c = null,
            Monthly_Funded_Cap__c = 10000,
            Total_Funded_MTD__c = null,
            Total_Funded_YTD__c = null,
            Total_Funded_Till_date__c = null,
            Monthly_Allocation_Cap__c = 10,
            Total_Allocations_MTD__c =0,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123',
            Amount_Invested__c = 8000
            );
        insert acc1;
        
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
    
    testmethod static void method11InvestedAmountNotNull(){
        
        //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert acc;
         Account acc1 = new Account(
            Name = 'Test',
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
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123',
            Amount_Invested__c = 200
            );
        insert acc1;
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
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
        SelectOfferFromUI.runInvestorAllocationBasedOnWeighting(app);
        Test.stopTest();
    }
    //CRM-1022 - end
    
}