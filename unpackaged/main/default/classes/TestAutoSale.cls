/* ****************Modification History******************
 * Updated By        Date			Version					Purpose 
 *1. Bhanupriya       2022/02/01     Initial Version		added assert statements and fix the test case and created a new method for batch job
 ******************Modification History******************/
/* overwrite qa branch version */
@isTest
public Class TestAutoSale{
    
    
    @testSetup static void testSetup() {
        //Test.StartTest();
        
        loan__Org_Parameters__c loanorg = loan.CustomSettingsUtil.getOrgParameters();
        loanorg.Manual_Payer_Lending_product_name__c = 'Manual Payer';
        loanorg.Auto_Payer_Lending_Product_Name__c = 'Auto Payer';
        upsert loanorg;
        
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
        System.debug('dummyOffice'+dummyOffice.name);

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

        // Create Rule
        genesis__Rule__c rule = new genesis__Rule__c();
        rule.name                       = 'TCU ruleset';
        rule.genesis__Enabled__c        = true;
        rule.genesis__Object_Type__c    = 'genesis__Object_Type__c';
        insert rule;
        
        //Creating Rule Criteria
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
        
        //Create Dummy loan Purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();        
        dummyLoanPurpose.loan__Loan_Purpose_Code__c = 'Refinance';
        account dummyClient = new account(); 
        dummyClient.Name = 'Payoff';
        dummyClient.peer__Last_Name__c = 'Account';
        dummyClient.peer__First_Name__c = 'Test';
        insert dummyClient;
        
      //Create new Investor Account
        Account invacc = new Account(
            Name = 'Investor',
            loan__Investor__c = true,
            Amount_Invested__c = 1000,
            Investment_Rules__c = rule.id,
            Number_Of_Applications_Invested__c = 3, 
            Total_No_of_Application_Limit__c = 30,
            Last_Application_assigned_on__c = system.now()-7,
            Total_Investment_Limit__c = 1000000,
            loan__Undeployed_Funds__c = 500000,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'InvestorFirstName',
            peer__Last_Name__c='InvestorLastName',
            no_of_shares_to_be_Sold__c = 1,
            Number_of_Days__c = 0,
            loan__Active__c = 'YES', 
            City__c='CANADA',
            State__c='CA',
            ZIP_Code__c='123456'
        );
        Insert invacc;
        
        loan__Payment_Mode__c pm = new loan__Payment_Mode__c();
        pm.name = 'Wire';
        insert pm;
        
        //investor bank acc.
        loan__Bank_Account__c bainv = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
                                                 loan__Bank_Name__c = 'Some Bank',
                                                 loan__Routing_Number__c = '123456789',
                                                 loan__Account_Type__c = 'Checking',
                                                 loan__Active__c = true,
                                                 Unmasked_Bank_Account_Number__c = '12345689',
                                                 loan__Account__c = invacc.id);
        insert bainv;
        
        //Create Automated Loan Payment Configuration
        loan__Automated_Payment_Configuration__c invaps = new loan__Automated_Payment_Configuration__c();
        invaps.loan__Payment_Mode__c = pm.id;
        invaps.loan__Bank_Account__c = bainv.id;
        invaps.loan__Filegen_Class__c = 'CustomLoanPaymentTxnNACHAGen';
        invaps.loan__Folder_Name__c = 'ACU';
        invaps.loan__File_Type__c = 'CSV';
        invaps.loan__Event__c = 'LOAN PAYMENT';
        insert invaps;
        
        //Create a new Bank loan account
        loan__Bank_Account__c ba = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
                                                 loan__Bank_Name__c = 'Some Bank',
                                                 loan__Routing_Number__c = '123456789',
                                                 loan__Account_Type__c = 'Checking',
                                                 loan__Active__c = true,
                                                 Unmasked_Bank_Account_Number__c = '12345689',
                                                 loan__Account__c = dummyClient.id);
        insert ba;
        
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
        loanAccount.loan__Next_Due_Generation_Date__c = date.today().adddays(15);
        //loanAccount.Investor_Account__c = invacc.id;  //commented(LOS-28)
        upsert loanAccount;  
        system.assertNotEquals(loanAccount.id,null,'LoanAccount not inserted');
        
        Date d = date.newInstance(2021, 08, 06);
        Date Enddate = date.newInstance(2024, 08, 06) ;
        
        loan__Automated_Payment_Setup__c apss = new loan__Automated_Payment_Setup__c () ;
        
        apss.loan__Type__c = 'RECURRING';
        apss.loan__Active__c = true ;
        apss.loan__Amount_Type__c ='CURRENT PAYMENT AMOUNT' ;
        apss.loan__Debit_Date__c = d;
        apss.loan__Recurring_ACH_End_Date__c = Enddate;
        apss.loan__Recurring_ACH_Start_Date__c = d;
        apss.loan__Frequency__c = 'Monthly';
        apss.loan__CL_Contract__c = loanAccount.id;
        apss.loan__Bank_Account__c = ba.id;
        insert apss;
       
        list<loan__Investor_Loan__c> ioList = new list<loan__Investor_Loan__c>();
         
           loan__Investor_Loan__c lo = new loan__Investor_Loan__c();
           lo.loan__Certificate_Rate__c                   = 7.0;
           lo.Buyer__c                                    = invacc.id;
           lo.loan__Service_Rate__c                       = 10.0;
           lo.loan__Account__c                            = invacc.id;
           lo.loan__Loan__c                               = loanAccount.id;
           lo.loan__Share__c                              = 100;
           lo.loan__Status__c                             = 'Active';
           lo.loan__Enabled_Flag__c                       =  true;
           lo.loan__Inv_Accrued_Interest_Amt__c           =  0;
           lo.loan__Investment_Amount__c                  = 1000;
           lo.loan__Principal_Amount_Paid__c              = 2;
           lo.loan__Loan_Principal_Remaining__c           =1000;
           lo.loan__Investor_Start_Date__c                = System.today();
           
         
           insert lo;
      
           
        //Test.stopTest();

    }
    @isTest static Void autoMethod(){
        test.startTest();

        Account ac =[select id from Account limit 1];// where name = 'Investor'];
        System.debug(ac);
        List<loan__Investor_Loan__c> lo = [select id,name,loan__Certificate_Rate__c,Buyer__c,loan__Account__r.no_of_shares_to_be_Sold__c,loan__Service_Rate__c,
                                           loan__Account__c,loan__Loan__c,loan__Share__c,loan__Status__c,
                                            peer__Number_Of_Shares__c,loan__Enabled_Flag__c,loan__Inv_Accrued_Interest_Amt__c, 
                                            loan__Remaining_Investment_Amount__c from loan__Investor_Loan__c where Buyer__c != null 
                                            and loan__Status__c = 'Active' limit 1];
              AutoSale Auto = new AutoSale();
              Database.QueryLocator ql = Auto.start(null);
              Auto.execute(null,lo);
              Auto.Finish(null); 
            
        test.stopTest();
        
        
        List<loan__Automated_Payment_Setup__c> aps = [select id,loan__Payment_Mode__c from loan__Automated_Payment_Setup__c where
                                                     loan__CL_Contract__c =: io[0].loan__loan__c];
        system.assert(aps[0].loan__Payment_Mode__c == apc.loan__Payment_Mode__c, 'Payment mode should match');
        
       
    }
    
}