/* ****************Modification History*****************************************************************
 * Modified by      Date        JIRA number
 *     Pallavi      2020/05/22      LOP-56/CRM-557(fixed routing number)
 * 	   Anusha		2021/07/14 		LSP-256 IO Interest Calculation Must Use Accrual Start Date Not Contract Date
 * 	   Anusha		2021/07/21 		LSP-218 update APS type to last billed amount in ApplicationToContractConverter CLS case #02694756(added assert)
 ******************Modification History*****************************************************************/
@isTest
private class TestApplicationToContractConverter{

    Testmethod static void method1(){
        
        loan__Org_Parameters__c loanorg = loan.CustomSettingsUtil.getOrgParameters();
        loanorg.Manual_Payer_Lending_product_name__c = 'Manual Payer';
        loanorg.Auto_Payer_Lending_Product_Name__c = 'Auto Payer';
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
        
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
         org.loan__Disable_Triggers__c = true;
         upsert org;  
          //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP1 = loan.TestHelper.createLoanProduct(dummyOffice,
                            dummyAccount, 
                            curr, 
                            dummyFeeSet);
        dummyLP1.name = 'Auto Payer';
        dummyLP1.loan__Minimum_Amount_Due_Type__c = 'Percent';
        dummyLP1.loan__Pre_Bill_Days__c = 5;
        upsert dummyLP1;
                          
       
        ///CL Product...........
        clcommon__CL_Product__c dummyCLPRoduct = new clcommon__CL_Product__c();
        dummyCLPRoduct.clcommon__Product_Name__c = 'Auto Payer';            
        dummyCLPRoduct.loan__Lending_Product__c = dummyLP1.id;
        
        insert dummyCLPRoduct;
        
        //Creating Account
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
        insert acc1;
        
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
        insert acc;
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
        apc1.loan__Active__c = true;
        insert apc1;

        loan__Automated_Payment_Configuration__c apcNullPaymentMode = new loan__Automated_Payment_Configuration__c();
        apcNullPaymentMode.loan__Payment_Mode__c = null;
        apcNullPaymentMode.loan__Bank_Account__c = bnk1.id;
        apcNullPaymentMode.loan__Filegen_Class__c = 'Test';
        apcNullPaymentMode.loan__Folder_Name__c = 'TestFolder';
        apcNullPaymentMode.loan__Active__c = false;
        insert apcNullPaymentMode;
        
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
        //app1.Anniversary_Date__c = systemDate.adddays(2);
        app1.Loan_Doc_Signed_On__c = systemDate.adddays(20);
        //app1.Investor__c = acc2.Id;
        update app1;
        
        Sobject appobj = app;
        //insert appobj;
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
        SObject lacobj = lacc;
        //insert lacobj;
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
        apc.loan__Active__c = true;
        insert apc;
        
        Map<SObject,SObject> AppVsLoanAppMap = new Map<SObject,SObject>();
        AppVsLoanAppMap.put(appobj,lacobj);
        
        
        Test.StartTest();
        Savepoint sp = Database.setSavepoint();
        ApplicationToContractConverter appconvert = new ApplicationToContractConverter();
        appconvert.setContracts(AppVsLoanAppMap);
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
        List<loan__Loan_Account__c> laCreated = [
            SELECT Id,
                   Name,
                   loan__Payment_Mode__c,
                   loan__Loan_Product_Name__r.Name,
                   (SELECT Id,
                           loan__Payment_Mode__c
                    FROM   loan__Automated_Payment_Setup__r)
            FROM   loan__Loan_Account__c
            WHERE  Id =:contractId
            LIMIT 1
        ];

        /* assert that the contract was created by using the active automated payment configuration */
        System.assertEquals(apc1.loan__Payment_Mode__c, laCreated.get(0).loan__Payment_Mode__c);
        System.assertEquals(apc1.loan__Payment_Mode__c, laCreated.get(0).loan__Automated_Payment_Setup__r[0].loan__Payment_Mode__c);

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
   
}