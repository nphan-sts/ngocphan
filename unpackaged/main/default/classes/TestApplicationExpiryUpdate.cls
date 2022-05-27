@isTest
public class TestApplicationExpiryUpdate {
     Static testMethod Void testone(){
         Test.startTest();
        //Party Type insert
        clcommon__Party_Type__c pt = new clcommon__Party_Type__c();
        pt.name = 'Borrower';
        insert pt;
         
        //Document category
        genesis__Document_Category__c dc = new genesis__Document_Category__c();
        dc.genesis__Responsible_Party_Type__c = pt.id;
        dc.genesis__Applicable_For__c = 'PARTY';
        insert dc;
        
         loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        
        //Dummy GLAccount
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        
        //Dummy Office insert
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr);                                    
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        
        //Creating Conpany
        genesis__Company__c comp = genesis.TestHelper.createCompany(); 
        comp.Name = 'payoff';
        update comp;
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        
        //creating CL Product
        clcommon__CL_Product__c pr = new clcommon__CL_Product__c();
        pr.loan__Lending_Product__c = dummyLp.id;
        pr.clcommon__Product_Name__c = 'P1';
        insert pr; 
        
        Date currentSystemDate = (new loan.GlobalLoanUtilFacade().getCurrentSystemDate());
        
         Account account_Obj = new Account(
            Name='Testfname Testlname',
            loan__Investor__c=False,
            peer__First_Name__c= 'Testfname',
            peer__Last_Name__c= 'Testlname',
            cnotify__Email__c = 'no-reply@testorganization.com'
        );
        Insert account_Obj;
        
         Account acc = [select Id, Annual_Individual_Income__c from Account  where Name='Testfname Testlname' LIMIT 1];
         
        //Create Application
        genesis__applications__c application = new genesis__applications__c();
        application.genesis__Product_Type__c = 'LOAN';
        application.genesis__Loan_Amount__c = 6700;
        application.genesis__status__c = 'NEW - ENTERED';
        application.genesis__Term__c = 12;
        application.genesis__Payment_Frequency__c = 'MONTHLY';
        application.genesis__Interest_Rate__c = 10;
        application.genesis__Days_Convention__c = 'ACTUAL/ACTUAL';
        application.genesis__Expected_Start_Date__c = system.today();
        application.genesis__Expected_First_Payment_Date__c = system.today().addDays(60);
        application.genesis__Expected_Close_Date__c = system.today().addDays(30);
        application.genesis__Interest_Calculation_Method__c = 'Declining Balance';
        application.genesis__Interest_Only_Period__c = 0;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Account__c = acc.Id;
        application.genesis__Total_Estimated_Interest__c=500;
        application.genesis__Valid_Pricing_Flag__c=false;
        application.genesis__Probability__c=100.00;
        application.genesis__Payment_Amount__c=523.80;
        application.genesis__Company__c = comp.id;
        application.genesis__CL_Product__c = pr.id;
        application.Application_Start_DateV2__c = currentSystemDate.adddays(-30);
        insert application; 
        genesis__applications__c application2 = new genesis__applications__c();
        application2.genesis__Product_Type__c = 'LOAN';
        application2.genesis__Loan_Amount__c = 6700;
        application2.genesis__status__c = 'NEW - ENTERED';
        application2.genesis__Term__c = 12;
        application2.genesis__Payment_Frequency__c = 'MONTHLY';
        application2.genesis__Interest_Rate__c = 10;
        application2.genesis__Days_Convention__c = 'ACTUAL/ACTUAL';
        application2.genesis__Expected_Start_Date__c = system.today();
        application2.genesis__Expected_First_Payment_Date__c = system.today().addDays(60);
        application2.genesis__Expected_Close_Date__c = system.today().addDays(30);
        application2.genesis__Interest_Calculation_Method__c = 'Declining Balance';
        application2.genesis__Interest_Only_Period__c = 0;
        application2.genesis__Interest_Rate__c = 100;
        application2.genesis__Account__c = acc.Id;
        application2.genesis__Total_Estimated_Interest__c=500;
        application2.genesis__Valid_Pricing_Flag__c=false;
        application2.genesis__Probability__c=100.00;
        application2.genesis__Payment_Amount__c=523.80;
        application2.genesis__Company__c = comp.id;
        application2.genesis__CL_Product__c = pr.id;
        application2.application_Start_DateV2__c = currentSystemDate.adddays(-30);        
        insert application2; 
        Credit_Policy__c responseCP = new Credit_Policy__c	();
        responseCP.Loan_amount_counteroffer__c = 150.00;         
        responseCP.Application__c = application2.id;
        insert responseCP; 
        Manual_Adverse_Action_Decline__c mda = new 	Manual_Adverse_Action_Decline__c();
         mda.Decline_Name__c = 'insufficient tradeline balance';
         mda.Description__c = 'So we are unable to proceed with your loan application.';
         mda.Name = 'Expiration_decline_insufficient_tradeline_balances';
         mda.Reason__c = 'Your unsecured consumer debt does not support the amount requested.';
         insert mda;
        
        Expiry_Date__c exp = new Expiry_Date__c();
        exp.Alert_Before_Expiration_Date__c = 5;
        exp.No_of_days_for_Expiration__c = 30;
        insert exp;
        
        ApplicationExpiryUpdate obj = new ApplicationExpiryUpdate(); 
        Database.executeBatch(obj,1);
         Set<String> skipLoanStatus = new Set<String>{'Funded','Expired','Expired-Withdrawn'};
        String CSD = String.valueof(new loan.GlobalLoanUtilFacade().getCurrentSystemDate());
        string query = 'select id, Expiry_Date__c, genesis__Status__c, CreatedById, DocuSign_EnvelopeId__c, Expiration_Tag__c from genesis__Applications__c where Expiry_Date__c =' + CSD +' and genesis__Status__c not in : skipLoanStatus';
        obj.start(null);
        obj = new ApplicationExpiryUpdate(query);
        Database.executeBatch(obj,1);
        obj.execute(null);
        List <genesis__Applications__c> genApp = [select id, Expiry_Date__c, CreatedById, genesis__Status__c, DocuSign_EnvelopeId__c, Expiration_Tag__c from genesis__Applications__c where id =:application.id];
        obj.execute(null,genApp);
         List <genesis__Applications__c> genApp2 = [select id, Expiry_Date__c, genesis__Status__c,CreatedById, DocuSign_EnvelopeId__c, Expiration_Tag__c, (select id,name,Loan_amount_counteroffer__c from Credit_Policy__r where Loan_amount_counteroffer__c!=null limit 1 ) from genesis__Applications__c where id =:application2.id];
        obj.execute(null,genApp2);  
        
        
        
        
        Test.stopTest();
    }
}