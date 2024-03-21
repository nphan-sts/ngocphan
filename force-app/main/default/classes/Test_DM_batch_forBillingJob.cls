@isTest
public class Test_DM_batch_forBillingJob {

    @testSetup static void Setup() {
               
        loan__Org_Parameters__c loanorg = loan.CustomSettingsUtil.getOrgParameters();
        loanorg.Manual_Payer_Lending_product_name__c = 'Manual Payer';
        loanorg.Auto_Payer_Lending_Product_Name__c = 'Auto Payer';
        upsert loanorg;
        
        MigrationPhase__c phase = new MigrationPhase__c();
        phase.name = 'phase1';
        phase.phase__c = 'phase1';
        insert phase;
        
        //Creating loan account 
        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount); 
        dummyFee.loan__Amount__c = 3;      
        dummyFee.loan__Time_Of_Charge__c = 'Other';
        upsert dummyFee;
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();

        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP1 = loan.TestHelper.createLoanProduct(dummyOffice,
                            dummyAccount, 
                            curr, 
                            dummyFeeSet);
        dummyLP1.name = 'Auto Payer';
        dummyLP1.loan__Pre_Bill_Days__c = 5;
        upsert dummyLP1;
                          
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
                            dummyAccount, 
                            curr, 
                            dummyFeeSet);
        dummyLP.name = 'Manual Payer';
        dummyLP.loan__Pre_Bill_Days__c = 5;
        upsert dummyLP;

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
        
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();        
        dummyLoanPurpose.loan__Loan_Purpose_Code__c = 'Refinance';
        account dummyClient = new account(); 
        dummyClient.Name = 'Payoff';
        dummyClient.peer__Last_Name__c = 'Account';
        dummyClient.peer__First_Name__c = 'Test';
        insert dummyClient;
                
        peer__Note_Type__c pn = new peer__Note_Type__c();
        pn.peer__Denomination__c =1000;
        insert pn;
        
        //Create a dummy Loan Account
        loan__Loan_Account__c loanAccount = loan.TestHelper.createLoanAccountForAccountObj(dummyLP,
                                                    dummyClient,
                                                    dummyFeeSet,
                                                    dummyLoanPurpose,
                                                    dummyOffice);
        loanAccount.loan__Number_of_Installments__c     = 12;                                  
        loanAccount.Loan__Loan_Status__c                = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        loanAccount.Loan__Fees_Remaining__c             = 100;
        loanAccount.Loan__Interest_Remaining__c         = 500;
        loanAccount.Loan__Principal_Remaining__c        = 1000;
        loanAccount.Loan__Fractionalization_Status__c   = loan.LoanConstants.FRACTIONALIZATION_STATUS_ACTIVE;
        loanAccount.Loan__Pay_off_Amount_As_Of_Today__c = loanAccount.loan__Fees_Remaining__c + loanAccount.loan__Principal_Remaining__c;
        loanAccount.loan__Delinquent_Amount__c          = 5000;
        loanAccount.loan__Interest_Rate__c              = 10.0;
        loanAccount.peer__Note_Type__c                  = pn.id;
        loanAccount.loan__Next_Due_Generation_Date__c   = date.today().adddays(-1);
        loanAccount.loan__Next_Installment_Date__c      = date.today().adddays(1);
        loanAccount.loan__is_rescheduled__c				= true;
        loanAccount.DM_ActivateIO_and_IPT__c			= true;
        loanAccount.DM_Migration_Phase__c				= 'phase1';
        upsert loanAccount;  
        system.assertNotEquals(loanAccount.id,null,'LoanAccount not inserted');
      
    }
    @isTest
    static void testMethod1(){
        Test.startTest();
        DM_batch_forBillingJob b = new DM_batch_forBillingJob();
        b.callBillingJob();
        Test.stopTest();
    }
}