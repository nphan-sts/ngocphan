@isTest
global class TestYodleeTransactionAPICallout{

    public static TestMethod void TestMethod1(){
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
        Test.startTest();
        
        YodleeTransactionAPICallOut.getCobSession();
        
        Test.stopTest();
    }
    
    public static TestMethod void TestMethod2(){
        
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
        
        Account acc = new Account();
        acc.name = 'Test Yodlee Account';
        acc.Account_External_ID__c = 'Yodlee';
        acc.cnotify__Email__c = 'no-reply@testorganization.com';
        insert acc;
        
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
            								Number_of_days__c = 30
                                            );
        insert app;
        System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');
        
        Test.startTest();
        
        YodleeTransactionAPICallOut.UserToken(acc.Id);
        YodleeTransactionAPICallOut.deleteYodleeTxn(acc.Id,app.id);
        
        Test.stopTest();
    }
    
    public static TestMethod void TestMethod3(){
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
        
        Account acc = new Account();
        acc.name = 'Test Yodlee Account2';
        acc.Account_External_ID__c = 'Yodlee1';
        acc.cnotify__Email__c = 'no-reply@testorganization.com';
        insert acc;
        
        ints__Yodlee_User_Credentials__c userCred = new ints__Yodlee_User_Credentials__c();
        userCred.ints__Account__c = acc.Id;
        userCred.ints__Yodlee_Username__c = 'testuserName';
        userCred.ints__Yodlee_Password__c = 'testpassword';
        userCred.yodlee_Account_count__c  =1;
        insert userCred;
        
        Test.startTest();
        
        YodleeTransactionAPICallOut.UserToken(acc.Id);
        
        Test.stopTest();
    }
    
    public static TestMethod void testMethod4(){
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
        
        Account acc = new Account();
        acc.name = 'Test Yodlee Account';
        acc.Account_External_ID__c = 'Yodlee';
        acc.cnotify__Email__c = 'no-reply@testorganization.com';
        insert acc;
        
        
        ints__Yodlee_User_Credentials__c userCred = new ints__Yodlee_User_Credentials__c();
        userCred.ints__Account__c = acc.Id;
        userCred.ints__Yodlee_Username__c = 'testuserName';
        userCred.ints__Yodlee_Password__c = 'testpassword';
        userCred.yodlee_Account_count__c  =1;
        insert userCred;
        
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
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        
        Test.startTest();
        
        
        Test.setMock(HttpCalloutMock.class, new MockYodleeTransactionAPICallOut1());
        YodleeTransactionAPICallOut.getTransactions(acc.Id,app.id,10);
        
        Test.stopTest();
    }
    
    public static TestMethod void testMethod5(){
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
        
        Account acc = new Account();
        acc.name = 'Test Yodlee Account';
        acc.Account_External_ID__c = 'Yodlee';
        acc.cnotify__Email__c = 'no-reply@testorganization.com';
        insert acc;
        
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
            								Number_of_days__c = 10
                                            );
        insert app;
        System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');
        
        list<Yodlee_User_Transaction__c> yodleeTxn = new list<Yodlee_User_Transaction__c>();
        
        Yodlee_User_Transaction__c yodlee = new Yodlee_User_Transaction__c();
        
        for(integer i=0; i<3;i++){
            yodlee.Balance__c = 100;
            yodlee.Category__c = 'Test';
            yodlee.Yodlee_Account__c = acc.Id;
            yodleeTxn.add(yodlee);
        }
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockYodleeTransactionAPICallOut());
        YodleeTransactionAPICallOut.deleteYodleeTxn(acc.Id,app.id);
        Test.stopTest();
        
    }
    
   /* public static TestMethod void TestMethod6(){	//COMMENTED(LOS-63) function not needed
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
        
        Account acc = new Account();
        acc.name = 'Test Yodlee Account';
        acc.Account_External_ID__c = 'Yodlee';
        acc.cnotify__Email__c = 'no-reply@testorganization.com';
        insert acc;
        
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
            								Number_of_days__c = 10
                                            );
        insert app;
        System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');
        
        ints__Yodlee_User_Credentials__c userCred = new ints__Yodlee_User_Credentials__c();
        userCred.ints__Account__c = acc.Id;
        userCred.ints__Yodlee_Username__c = 'testuserName';
        userCred.ints__Yodlee_Password__c = 'testpassword';
        userCred.yodlee_Account_count__c  =1;
        insert userCred;
        
        String leadsEndPoint = MW_Settings__c.getInstance().LEADS_FE_EndpointURL__c;	//temp
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockYodleeTransactionAPICallOut());
        String res = YodleeTransactionAPICallOut.getTransactions(acc.Id,app.id, Integer.valueof(app.Number_of_days__c));
        
        Test.stopTest();
    }
    public static TestMethod void TestMethod7(){
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
        
        Account acc = new Account();
        acc.name = 'Test Yodlee Account';
        acc.Account_External_ID__c = 'Yodlee';
        acc.cnotify__Email__c = 'no-reply@testorganization.com';
        insert acc;
        
        loan__Bank_Account__c ba = new loan__Bank_Account__c();
        ba.loan__Account__c = acc.id;
        ba.loan__Bank_Account_Number__c = 'XXXXXXXXXXX4802';
        ba.loan__Bank_Name__c = 'M&T Bank';
        ba.loan__Routing_Number__c = '022000046';
        ba.loan__ACH_Code__c = '081904808';
        ba.loan__Active__c = true;
        ba.Unmasked_Bank_Account_Number__c = '884895318794802';
        ba.loan__Account_Type__c = 'Savings';
        ba.loan__Account_Usage__c = 'Borrower/Investor Account';	//pallavi(LOS-63)
        insert ba;
        
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
        
        ints__Yodlee_User_Credentials__c userCred = new ints__Yodlee_User_Credentials__c();
        userCred.ints__Account__c = acc.Id;
        userCred.ints__Yodlee_Username__c = 'testuserName';
        userCred.ints__Yodlee_Password__c = 'testpassword';
        userCred.yodlee_Account_count__c  =1;
        insert userCred;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockYodleeTransactionAPICallOut1());
        YodleeTransactionAPICallOut.getYodleeAccount(acc.Id,app.id);
        
        Test.stopTest();

   }*/
}