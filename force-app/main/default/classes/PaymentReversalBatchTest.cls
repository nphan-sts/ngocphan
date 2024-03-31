@isTest
public class PaymentReversalBatchTest {

    static String autoPayer = 'Auto Payer';
    static String dummyEmail = 'abc@test.com';
    static testMethod void testPaymentReversal(){
         loan__Org_Parameters__c loanorg = loan.CustomSettingsUtil.getOrgParameters();
        loanorg.Manual_Payer_Lending_product_name__c = 'Manual Payer';
        loanorg.Auto_Payer_Lending_Product_Name__c = autoPayer;
        upsert loanorg;
   
       loan.TestHelper.createSeedDataForTesting();
       loan__Currency__c curr = loan.TestHelper.createCurrency();
       //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
     
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);                                    
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        System.debug(dummyFeeJunction);
        
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
         org.loan__Disable_Triggers__c = true;
         upsert org;  
          //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP1 = loan.TestHelper.createLoanProduct(dummyOffice,
                            dummyAccount, 
                            curr, 
                            dummyFeeSet);
        dummyLP1.name = autoPayer;
        dummyLP1.loan__Minimum_Amount_Due_Type__c = 'Percent';
        dummyLP1.loan__Pre_Bill_Days__c = 5;
        upsert dummyLP1;

        //dummy purpose
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();

        //dummy contact 
        Contact a1 = new Contact(LastName='TestACH');
        insert a1;
        
        loan__Payment_Mode__c paymentMode = [select id from loan__Payment_Mode__c where Name= 'Cash' limit 1];
        
        ///CL Product...........
        clcommon__CL_Product__c dummyCLPRoduct = new clcommon__CL_Product__c();
        dummyCLPRoduct.clcommon__Product_Name__c = autoPayer;            
        dummyCLPRoduct.loan__Lending_Product__c = dummyLP1.id;
        
        insert dummyCLPRoduct;
        
        //Creating Account
        Account acc1 = new Account(
            Name = 'Test',
            loan__Investor__c = True,
            Is_Funding_Partner__c = True,
            cnotify__Email__c = dummyEmail,
            loan__SOCIAL_SECURITY_NUMBER__c = '123456789'//LSP-256
            );
        acc1.loan__Undeployed_Funds__c = 50000;//LSP-256
        acc1.peer__First_Name__c ='test';//LSP-256
        acc1.peer__Last_Name__c = 'account';//LSP-256
        insert acc1;
        
        //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c = False,
            loan__Collect_Service_Fees_on__c = 'Principal',
            Funding_Partner__c = acc1.id,
            loan__Service_Rate_On_Investment__c =12.45,
            cnotify__Email__c = dummyEmail,
            loan__SOCIAL_SECURITY_NUMBER__c = '123456779',
            peer__First_Name__c ='test',//LSP-256
            peer__Last_Name__c = 'account'//LSP-256
            );
        insert acc;
        Account acc2 = new Account(
            Name = 'Test',
            loan__Investor__c = True,
            loan__Collect_Service_Fees_on__c = 'Principal',
            //Funding_Partner__c = acc1.id,
            loan__Service_Rate_On_Investment__c =12.45,
            cnotify__Email__c = dummyEmail,
            loan__SOCIAL_SECURITY_NUMBER__c = '123456777'
            );
        acc2.peer__First_Name__c ='test';//LSP-256
        acc2.peer__Last_Name__c = 'account';//LSP-256
        acc2.loan__Undeployed_Funds__c = 5000;//LSP-256
        insert acc2;
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
        Date systemDate =  new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
        
        loan__Bank_Account__c bnk1 = new loan__Bank_Account__c();
        bnk1.loan__Account__c = acc1.id;
        bnk1.loan__Bank_Name__c = 'TestBank';
        bnk1.Unmasked_Bank_Account_Number__c ='1244536753735';
        bnk1.loan__Active__c = true;
        bnk1.loan__Account_Type__c = 'Savings';  //pallavi(LOS-63)
        bnk1.loan__Account_Usage__c = 'Borrower/Investor Account';  //pallavi(LOS-63)
	bnk1.loan__Routing_Number__c = '999999999'; //CRM-557
        insert bnk1;
        //
        loan__Payment_Mode__c pm1 = new loan__Payment_Mode__c();
        pm1.name = 'ACH';
        insert pm1;
        
        loan__Automated_Payment_Configuration__c apc1 = new loan__Automated_Payment_Configuration__c();
        apc1.loan__Payment_Mode__c = pm1.id;
        apc1.loan__Bank_Account__c = bnk1.id;
        apc1.loan__Filegen_Class__c = 'Test';
        apc1.loan__Folder_Name__c = 'TestFolder';
        insert apc1;
        
         //Creating Application
        genesis__Applications__c app= new genesis__Applications__c(
                                        genesis__Due_Day__c = 20,
                                        genesis__Expected_First_Payment_Date__c = system.Today(),
                                        genesis__Payment_Frequency__c ='Monthly',
                                        genesis__Expected_Start_Date__c = system.Today(),
                                        genesis__Funding_in_Tranches__c = true,
                                        genesis__Loan_Amount__c = 12000,
                                        genesis__Interest_Rate__c = 12,
                                        genesis__Monthly_Debt_Payments__c = 100,
                                        genesis__CL_Product__c = dummyCLPRoduct.id,
                                        Borrower_s_Email__c = null,
                                        Investor__c=acc1.id,
                                        Loan_Origination_Date__c = systemDate.adddays(10),
                                        genesis__Account__c = acc.Id,
                                        Anniversary_Date__c = systemDate.adddays(20),
                                        genesis__Expected_Close_Date__c =Date.newInstance(2017,10,11),
                                        Application_Start_DateV2__c = system.Today(),
                                        DocuSignFlag__c=true,
                                        genesis__Status__c = 'Approved for Funding',
                                        genesis__Draw_Period_End_Date__c = system.Today()
                                        );
        insert app;
        
        genesis__Applications__c app1= new genesis__Applications__c(
                                        genesis__Due_Day__c = 20,
                                        genesis__Expected_First_Payment_Date__c = system.Today(),
                                        genesis__Payment_Frequency__c ='Monthly',
                                        genesis__Expected_Start_Date__c = system.Today(),
                                        genesis__Funding_in_Tranches__c = true,
                                        genesis__Loan_Amount__c = 12000,
                                        genesis__Interest_Rate__c = 12,
                                        genesis__Monthly_Debt_Payments__c = 100,
                                        genesis__CL_Product__c = dummyCLPRoduct.id,
                                        Borrower_s_Email__c = null,
                                        Investor__c=acc1.id,
                                        Loan_Origination_Date__c = systemDate.adddays(10),
                                        genesis__Account__c = acc.Id,
                                        Anniversary_Date__c = systemDate.adddays(20),
                                        genesis__Expected_Close_Date__c =Date.newInstance(2017,10,11),
                                        //Application_Start_DateV2__c = system.Today(),
                                        DocuSignFlag__c=true,
                                        genesis__Status__c = 'Approved for Funding',
                                        genesis__Draw_Period_End_Date__c = system.Today()
                                        );
        insert app1;
        app1.Bureau_SSN__c = '123456789';
        app1.Loan_Doc_Signed_On__c = systemDate.adddays(20);
        update app1;
        
        Sobject appobj = app;
        //
        peer__Note_Type__c nt = new peer__Note_Type__c();
        insert nt;
        
        LoanPaymentDays__c lpdays = new LoanPaymentDays__c();
        lpdays.AutoPaymentRemainder__c= 3;
        lpdays.ManualPaymentRemainder__c= 5;
        insert lpdays;
        
        loan__Loan_Product__c loanProdObj = new loan__Loan_Product__c(name='TestProduct'); 
        insert loanProdObj;
        System.assertEquals('TestProduct', loanProdObj.Name,'Wrong Loan Product');
        
        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);
        
        //dummy contract
        loan__Loan_Account__c lacc = loan.TestHelper.createLoanAccountForContactObj(dummyLP,
                                                                                    a1,
                                                                                    dummyFeeSet,
                                                                                    dummyLoanPurpose,
                                                                                    dummyOffice); 

        //loan Disbursal Txn
        loan__Loan_Disbursal_Transaction__c disTxn = new loan__Loan_Disbursal_Transaction__c();
        disTxn.loan__Disbursed_Amt__c = lacc.loan__Loan_Amount__c;
        disTxn.loan__Mode_of_Payment__c = paymentMode.Id;
        disTxn.loan__Loan_Account__c = lacc.Id;
        disTxn.loan__Disbursal_Date__c = loan.TestHelper.systemDate;
        insert disTxn;
        disTxn.loan__Cleared__c = true;
        update disTxn;

        SObject lacobj = lacc;
        loan__Bank_Account__c bnk = new loan__Bank_Account__c();
        bnk.loan__Account__c = acc.id;
        bnk.loan__Bank_Name__c = 'TestBank';
        bnk.Unmasked_Bank_Account_Number__c ='12344536753735';
        bnk.loan__Active__c = true;
        bnk.loan__Account_Type__c = 'Savings';  //pallavi(LOS-63)
        bnk.loan__Account_Usage__c = 'Borrower/Investor Account';  //pallavi(LOS-63)
	bnk.loan__Routing_Number__c = '999999999'; //CRM-557
        insert bnk;
        //
        loan__Payment_Mode__c pm = new loan__Payment_Mode__c();
        pm.name = 'cash';
        insert pm;
        
        loan__Automated_Payment_Configuration__c apc = new loan__Automated_Payment_Configuration__c();
        apc.loan__Payment_Mode__c = pm.id;
        apc.loan__Bank_Account__c = bnk.id;
        apc.loan__Filegen_Class__c = 'Test';
        apc.loan__Folder_Name__c = 'TestFolder';
        insert apc;
        
        Map<SObject,SObject> appVsLoanAppMap = new Map<SObject,SObject>();
        appVsLoanAppMap.put(appobj,lacobj);
                
        loan__Loan_Payment_Transaction__c lpt = new loan__Loan_Payment_Transaction__c();
        lpt.loan__Transaction_Date__c = system.today();
        lpt.loan__Loan_Account__c = lacc.id;
        lpt.loan__Cleared__c = True;
        lpt.loan__Transaction_Amount__c	= 500;
        lpt.loan__Receipt_Date__c = System.today();
        lpt.loan__Payment_Mode__c = paymentMode.Id;
        lpt.loan__Cleared__c = true;
        insert lpt;
        
        
        Test.startTest();
        PaymentReversalsBatch ba= new PaymentReversalsBatch();
        Database.executeBatch(ba,1);
        Test.stopTest();
    }
}