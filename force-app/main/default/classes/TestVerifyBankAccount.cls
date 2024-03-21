@isTest
public class TestVerifyBankAccount {
	public static testMethod void  Testverify() {	
        CL_Document__c cs = new CL_Document__c();
        cs.Doc1__c = 'Credit';
        cs.Doc2__c = 'Til';
        insert cs;
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
        
       Account acc = new Account();
        acc.name = 'Test Yodlee Account';
        acc.Account_External_ID__c = 'Yodlee';
        acc.cnotify__Email__c = 'no-reply@testorganization.com';
        insert acc;
         
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
        insert application; 
        System.debug('=====Application ID in test class===='+application.id);
         
        //Application document category 
        genesis__Application_Document_Category__c adc = new genesis__Application_Document_Category__c();
        adc.name = 'Bank Statement 1';
        adc.genesis__Active__c = true;
        adc.genesis__Document_Category__c =  dc.id;
        adc.genesis__Application__c = application.id;
        insert adc;
        genesis__Application_Document_Category__c adc1 = new genesis__Application_Document_Category__c();
        adc.name = 'Bank Statement 2';
        adc.genesis__Active__c = true;
        adc.genesis__Document_Category__c =  dc.id;
        adc.genesis__Application__c = application.id;
        insert adc1;
        
         ints__Yodlee_Cobrand_Credentials__c ycc = new ints__Yodlee_Cobrand_Credentials__c();
        ycc.ints__APP_ID__c = '10003600';
        //ycc.ints__Application_Key__c = 
        //ycc.ints__APP_Secret__c =
        //ycc.ints__Auto_Register_User__c = 
        //ycc.ints__Callback_URL__c =
        ycc.ints__Cobrand_id__c = '4410018556';
        ycc.ints__Cobrand_Password__c = 'fpoie176bPIOY!T';
        ycc.ints__Cobrand_Username__c = 'payoff';
        ycc.FromDate_Attribute_value__c = 1100;
        ycc.ints__Node_URL__c = 'https://yieapnodestage.yodlee.com/authenticate/payoff/?channelAppName=yisandbox';
        ycc.ints__Rest_URL__c = 'https://stage.api.yodlee.com/ysl/payoff/v1/';
        ycc.ints__Soap_URL__c = 'https://stage.api.yodlee.com/ysl/payoff/v1/';
        
        insert  ycc;
       Yodlee_User_Account__c yacc = new Yodlee_User_Account__c();
        yacc.Yodlee_Account__c = acc.Id;
        yacc.verified__c = true;
        yacc.Yodlee_Application__c = application.id;
        insert yacc;
        List<genesis__Application_Document_Category__c> docCatToUpdate = new list<genesis__Application_Document_Category__c>();
        /*if(yacc.verified__c == true ){
            	adc.genesis__Status__c = 'cleared';
                adc.Cleared_Reason__c = 'satisfied by yodlee bank account';
                docCatToUpdate.add(adc);
            	adc1.genesis__Status__c = 'cleared';
                adc1.Cleared_Reason__c = 'satisfied by yodlee bank account';
                docCatToUpdate.add(adc1);
        } 
        update docCatToUpdate;*/
        
       list<Yodlee_User_Transaction__c> yodleeTxn = new list<Yodlee_User_Transaction__c>();
        
        Yodlee_User_Transaction__c yodlee = new Yodlee_User_Transaction__c();
        
        //for(integer i=0; i<3;i++){
            yodlee.Balance__c = 100;
            yodlee.Category__c = 'Test';
            yodlee.Yodlee_Account__c = acc.Id;
            yodleeTxn.add(yodlee);
        	yodlee.Balance__c = 200;
            yodlee.Category__c = 'Test1';
            yodlee.Yodlee_Account__c = acc.Id;
        	//Yodlee.verified__c = 'true';
            yodleeTxn.add(yodlee);
        	yodlee.Balance__c = 300;
            yodlee.Category__c = 'Test2';
            yodlee.Yodlee_Account__c = acc.Id;
            yodleeTxn.add(yodlee);
        //}
        //insert yodleeTxn;
        verifyBankAccount.Verify(application.id);
        
        Test.stopTest();
    }
}