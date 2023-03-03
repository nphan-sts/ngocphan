/* ****************Modification History*****************************************************************
 * Modified by      Date        JIRA number
 *     Pallavi      2020/05/22      LOP-56/CRM-557(fixed routing number)
 * 	   Anusha		2021/07/14 		LSP-256 IO Interest Calculation Must Use Accrual Start Date Not Contract Date
 * 	   Anusha		2021/07/21 		LSP-218 update APS type to last billed amount in ApplicationToContractConverter CLS case #02694756(added assert)
 *     Shakul       2022/02/07      LSP-513 
 ******************Modification History*****************************************************************/
@isTest
private class TestApplicationToContractConverter{
    @TestSetup
    public static void testSetup(){
        List<loan__Org_Parameters__c> loanorgs = new List<loan__Org_Parameters__c>();
        loan__Org_Parameters__c loanorg = loan.CustomSettingsUtil.getOrgParameters();
        loanorg.Manual_Payer_Lending_product_name__c = 'Manual Payer';
        loanorg.Auto_Payer_Lending_Product_Name__c = 'Auto Payer';
        loanorgs.add(loanorg);
        
        loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
        org.loan__Disable_Triggers__c = true;
        loanorgs.add(org);
        upsert loanorgs;
        
       loan.TestHelper.createSeedDataForTesting();
       loan__Currency__c curr = loan.TestHelper.createCurrency();
       //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
     
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);                                    
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        //Create a dummy Loan Product
        List<loan__Loan_Product__c> loanProds = new List<loan__Loan_Product__c>();
        loan__Loan_Product__c dummyLP1 = loan.TestHelper.createLoanProduct(dummyOffice,dummyAccount,curr,dummyFeeSet);
        dummyLP1.name = 'Auto Payer';
        dummyLP1.loan__Minimum_Amount_Due_Type__c = 'Percent';
        dummyLP1.loan__Pre_Bill_Days__c = 5;
        loanProds.add(dummyLP1);

        loan__Loan_Product__c loanProdObj = new loan__Loan_Product__c(name='TestProduct'); 
        loanProds.add(loanProdObj);

        upsert loanProdObj;

        //Creating Account
        List<Account> listofAccs = new List<Account>();
        Account acc1 = new Account(
            Name = 'Test',
            loan__Investor__c = True,
            Is_Funding_Partner__c = True,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123456789'//LSP-256
            );
        acc1.loan__Undeployed_Funds__c = 50000;//LSP-256
        acc1.peer__First_Name__c ='test';//LSP-256
        acc1.peer__Last_Name__c = 'account';//LSP-256
        listofAccs.add(acc1);
        
        //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c = False,
            loan__Collect_Service_Fees_on__c = 'Principal',
            Funding_Partner__c = acc1.id,
            loan__Service_Rate_On_Investment__c =12.45,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123456779',
            peer__First_Name__c ='test',//LSP-256
        	peer__Last_Name__c = 'account'//LSP-256
            );
        listofAccs.add(acc);
        
        Account acc2 = new Account(
            Name = 'Test',
            loan__Investor__c = True,
            loan__Collect_Service_Fees_on__c = 'Principal',
            //Funding_Partner__c = acc1.id,
            loan__Service_Rate_On_Investment__c =12.45,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123456777'
            );
        acc2.peer__First_Name__c ='test';//LSP-256
        acc2.peer__Last_Name__c = 'account';//LSP-256
        acc2.loan__Undeployed_Funds__c = 5000;//LSP-256
        listofAccs.add(acc2);
        insert listofAccs;

        Date systemDate =  new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
        
        List<loan__Bank_Account__c> bankAccs = new List<loan__Bank_Account__c>();
        loan__Bank_Account__c bnk1 = new loan__Bank_Account__c();
        bnk1.loan__Account__c = acc1.id;
        bnk1.loan__Bank_Name__c = 'TestBank';
        bnk1.Unmasked_Bank_Account_Number__c ='1244536753735';
        bnk1.loan__Active__c = true;
        bnk1.loan__Account_Type__c = 'Savings';  //pallavi(LOS-63)
        bnk1.loan__Account_Usage__c = 'Borrower/Investor Account';  //pallavi(LOS-63)
	    bnk1.loan__Routing_Number__c = '999999999'; //CRM-557
        bankAccs.add(bnk1);

        loan__Bank_Account__c bnk = new loan__Bank_Account__c();
        bnk.loan__Account__c = acc.id;
        bnk.loan__Bank_Name__c = 'TestBank';
        bnk.Unmasked_Bank_Account_Number__c ='12344536753735';
        bnk.loan__Active__c = true;
        bnk.loan__Account_Type__c = 'Savings';  //pallavi(LOS-63)
        bnk.loan__Account_Usage__c = 'Borrower/Investor Account';  //pallavi(LOS-63)
	    bnk.loan__Routing_Number__c = '999999999'; //CRM-557
        bankAccs.add(bnk);
        insert bankAccs;

        List<loan__Payment_Mode__c> pms = new List<loan__Payment_Mode__c>();
        loan__Payment_Mode__c pm1 = new loan__Payment_Mode__c();
        pm1.name = 'ACH';
        pms.add(pm1);

        loan__Payment_Mode__c pm = new loan__Payment_Mode__c();
        pm.name = 'cash';
        pms.add(pm);
        insert pms;

        List<loan__Automated_Payment_Configuration__c> listApcs = new List<loan__Automated_Payment_Configuration__c>();
        loan__Automated_Payment_Configuration__c apc1 = new loan__Automated_Payment_Configuration__c();
        apc1.loan__Payment_Mode__c = pm1.id;
        apc1.loan__Bank_Account__c = bnk1.id;
        apc1.loan__Filegen_Class__c = 'Test';
        apc1.loan__Folder_Name__c = 'TestFolder';
        listApcs.add(apc1);

        loan__Automated_Payment_Configuration__c apc = new loan__Automated_Payment_Configuration__c();
        apc.loan__Payment_Mode__c = pm.id;
        apc.loan__Bank_Account__c = bnk.id;
        apc.loan__Filegen_Class__c = 'Test';
        apc.loan__Folder_Name__c = 'TestFolder';
        listApcs.add(apc);
        insert listApcs;

        //Creating Application
        List<genesis__Applications__c> listofApps = new List<genesis__Applications__c>();
        genesis__Applications__c app= new genesis__Applications__c(
                                        genesis__Due_Day__c = 20,
                                        genesis__Expected_First_Payment_Date__c = system.Today(),
                                        genesis__Payment_Frequency__c ='Monthly',
                                        genesis__Expected_Start_Date__c = system.Today(),
                                        genesis__Funding_in_Tranches__c = true,
                                        genesis__Loan_Amount__c = 12000,
                                        genesis__Interest_Rate__c = 12,
                                        genesis__Monthly_Debt_Payments__c = 100,
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
        listofApps.add(app);

        genesis__Applications__c app1= new genesis__Applications__c(
                                        genesis__Due_Day__c = 20,
                                        genesis__Expected_First_Payment_Date__c = system.Today(),
                                        genesis__Payment_Frequency__c ='Monthly',
                                        genesis__Expected_Start_Date__c = system.Today(),
                                        genesis__Funding_in_Tranches__c = true,
                                        genesis__Loan_Amount__c = 12000,
                                        genesis__Interest_Rate__c = 12,
                                        genesis__Monthly_Debt_Payments__c = 100,
                                        Borrower_s_Email__c = null,
                                        Investor__c=acc1.id,
                                        Loan_Origination_Date__c = systemDate.adddays(10),
                                        genesis__Account__c = acc.Id,
                                        Anniversary_Date__c = systemDate.adddays(20),
                                        genesis__Expected_Close_Date__c =Date.newInstance(2017,10,11),
                                        DocuSignFlag__c=true,
                                        genesis__Status__c = 'Approved for Funding',
                                        genesis__Draw_Period_End_Date__c = system.Today()
                                        );
        listofApps.add(app1);
        insert listofApps;

        peer__Note_Type__c nt = new peer__Note_Type__c();
        insert nt;
        
        LoanPaymentDays__c lpdays = new LoanPaymentDays__c();
        lpdays.AutoPaymentRemainder__c= 3;
        lpdays.ManualPaymentRemainder__c= 5;
        insert lpdays;

        loan__Loan_Account__c lacc = new loan__Loan_Account__c(
                                    loan__Account__c= acc.Id,
                                    loan__Product_Type__c='Flexible Amz Loan',
                                    loan__Loan_Amount__c =1000,
                                    loan__Loan_Product_Name__c=loanProdObj.Id,
                                    loan__Payment_Amount__c=100, 
                                    loan__Next_Installment_Date__c=system.today(), 
                                    loan__Previous_Installment_Date__c= system.today()
                                    );
        insert lacc;

        //Party Type insert
        clcommon__Party_Type__c pt = new clcommon__Party_Type__c();
        pt.name = 'Borrower';
        insert pt;

        //Document category
        genesis__Document_Category__c dc = new genesis__Document_Category__c();
        dc.genesis__Responsible_Party_Type__c = pt.id;
        dc.genesis__Applicable_For__c = 'PARTY';
        insert dc;

        genesis__Application_Document_Category__c adc = new genesis__Application_Document_Category__c();
        adc.name = 'TIL Document';
        adc.genesis__Active__c = true;
        adc.genesis__Document_Category__c =  dc.id;
        adc.genesis__Application__c = app.id;
        insert adc;
    }

    /*Created By: Shakul Siddharth
      Purpose: To test overall logic of ApplicationtoContractConverter Apex Class */
    static testMethod void testApptoContractConversion(){
        loan__Loan_Product__c dummyLP1 = [SELECT id, name FROM loan__Loan_Product__c WHERE Name = 'TestLoanProductXXX'];
        dummyLP1.name = 'Auto Payer';
        update dummyLP1;

        clcommon__CL_Product__c dummyCLPRoduct = new clcommon__CL_Product__c();
        dummyCLPRoduct.clcommon__Product_Name__c = 'Auto Payer';            
        dummyCLPRoduct.loan__Lending_Product__c = dummyLP1.id;
        
        insert dummyCLPRoduct;

        genesis__Applications__c app = [SELECT id, genesis__CL_Product__c FROM genesis__Applications__c LIMIT 1];
        app.genesis__CL_Product__c = dummyCLPRoduct.id;
        update app;
        
        loan__Loan_Account__c lacc = [SELECT id FROM loan__Loan_Account__c LIMIT 1];
        Sobject appobj = app;
        SObject lacobj = lacc;

        Map<SObject,SObject> appVsLoanAppMap = new Map<SObject,SObject>();
        appVsLoanAppMap.put(appobj,lacobj);

        Test.StartTest();
        ApplicationToContractConverter appconvert = new ApplicationToContractConverter();
        appconvert.setContracts(appVsLoanAppMap);
        String msg = appconvert.processContract();//LSP-256 (capturing returned msg, so it can be used in assert)
        System.assertEquals('Application converted to Loan successfully!!', msg);//LSP-256
        ApplicationToContractConverter.getApplicationDetails(app.id);
        ApplicationToContractConverter.callDCPIntegration(app.id);
        //LSP-256 start
        List<genesis__applications__c> convertedApp = [select id,CL_Contract__c from genesis__applications__c where id =:app.id];
        System.assert(convertedApp.get(0).CL_Contract__c != null);   
        id contractId = convertedApp.get(0).CL_Contract__c;
        List<loan__Investor_Loan__c> ioCreated = [select id, name, loan__Investor_Start_Date__c, loan__Loan__r.loan__Accrual_Start_Date__c 
                                                           from loan__Investor_Loan__c where loan__Loan__c =:contractId order by createdDate desc limit 1];
        if(ioCreated != null && ioCreated.size()>0){
            System.assertEquals(ioCreated.get(0).loan__Loan__r.loan__Accrual_Start_Date__c, ioCreated.get(0).loan__Investor_Start_Date__c); 
        }        
        //LSP-256 end
        //LSP-218 start
        List<loan__loan_account__c> laCreated = [select id, name, loan__Loan_Product_Name__r.name 
                                                           from loan__loan_account__c where id =:contractId limit 1];
        if(laCreated != null && laCreated.size()>0){
            if(laCreated.get(0).loan__Loan_Product_Name__r.name == 'Auto Payer'){
               List<loan__Automated_Payment_Setup__c> aps =  [select id, name, loan__Amount_Type__c from loan__Automated_Payment_Setup__c
                                                             where loan__CL_Contract__c =:laCreated.get(0).id and loan__Type__c = 'RECURRING'
                                                             order by createdDate desc limit 1];
               System.assertEquals('LAST BILLED AMOUNT',aps.get(0).loan__Amount_Type__c);
            }
        } 
        //LSP-218 end
        Test.StopTest();
    }

    /*Created By: Shakul Siddharth
      Purpose: To make callout to DCP Integration */
    static testMethod void testDCPIntegration(){
        MW_Settings__c mwSetting = new MW_Settings__c(API_User_Filter__c = 'test@example.com');
        mwSetting.FE_User_Filter__c = 'serviceapi@happymoney.com.cliqa';
	    insert mwSetting;

        DCP_Arcus__c acr = new DCP_Arcus__c(secret_key__c='ltJj93aM0bn5R/ItWqJy75bBtF/VeeVsWlcGIoyg0yutj45cXIc83QEbprJye+PsEF07iW2KND8q4YBJnHlmXQ==');
        insert acr;

        genesis__Applications__c app = [SELECT id, genesis__CL_Product__c FROM genesis__Applications__c LIMIT 1];
        DCp_Arcus_Transactions__c dt = new DCp_Arcus_Transactions__c (Application__c = app.id,Pay_at_Funding__c = true,
                                                                      Transaction_Id__c = '25410207-47dc-4454-817a-fcabc9bfb3c2'
                                                                      );
        insert dt;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestDCPHttpCalloutMock());
        ApplicationToContractConverter.callDCPIntegration(app.id);
        Test.stopTest();
        DCp_Arcus_Transactions__c testDt = [SELECT id, DCP_Callout_successful__c FROM DCp_Arcus_Transactions__c WHERE id =: dt.id];
        System.assertEquals(true, testDt.DCP_Callout_successful__c);
    }

    /*Created By: Shakul Siddharth
      Purpose: To test contract conversion with DCP Transactions and DCP Acrus PM*/
    static testMethod void testApptoContractConvWithDCPTxnAcrus(){
        loan__Payment_Mode__c dummyPM = new loan__Payment_Mode__c(name='DCP Arcus');
        insert dummyPM;

        loan__Loan_Product__c dummyLP1 = [SELECT id, name FROM loan__Loan_Product__c WHERE Name = 'TestLoanProductXXX'];
        dummyLP1.name = 'Auto Payer';
        update dummyLP1;

        clcommon__CL_Product__c dummyCLPRoduct = new clcommon__CL_Product__c();
        dummyCLPRoduct.clcommon__Product_Name__c = 'Auto Payer';            
        dummyCLPRoduct.loan__Lending_Product__c = dummyLP1.id;
        
        insert dummyCLPRoduct;

        genesis__Applications__c app = [SELECT id, genesis__CL_Product__c FROM genesis__Applications__c LIMIT 1];
        app.genesis__CL_Product__c = dummyCLPRoduct.id;
        update app;

        DCp_Arcus_Transactions__c dt = new DCp_Arcus_Transactions__c (Application__c = app.id,Pay_at_Funding__c = true,
                                                                      Transaction_Id__c = '25410207-47dc-4454-817a-fcabc9bfb3c2'
                                                                      );
        insert dt;

        loan__Loan_Account__c lacc = [SELECT id FROM loan__Loan_Account__c LIMIT 1];
        Sobject appobj = app;
        SObject lacobj = lacc;

        Map<SObject,SObject> appVsLoanAppMap = new Map<SObject,SObject>();
        appVsLoanAppMap.put(appobj,lacobj);

        Test.StartTest();
        ApplicationToContractConverter appconvert = new ApplicationToContractConverter();
        appconvert.setContracts(appVsLoanAppMap);
        String msg = appconvert.processContract();
        Test.stopTest();
        System.assertEquals('Application converted to Loan successfully!!', msg);
    }
}