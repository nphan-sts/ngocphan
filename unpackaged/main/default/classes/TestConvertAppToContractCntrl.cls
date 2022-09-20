/* ****************Modification History******************
*    Created By        	 Date			Version
*1. Bhavya Maliwal        2022/02/02     Initial Version

******************Modification History******************/
@isTest
public Class TestConvertAppToContractCntrl{
    @testSetup
    static void setup(){ 
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
        
        ///CL Product...........
        clcommon__CL_Product__c dummyCLPRoduct = new clcommon__CL_Product__c();
        dummyCLPRoduct.clcommon__Product_Name__c = 'Auto Payer';            
        dummyCLPRoduct.loan__Lending_Product__c = dummyLP1.id;
        
        insert dummyCLPRoduct;
        ///CL Product...........
        clcommon__CL_Product__c dummyCLPRoduct1 = new clcommon__CL_Product__c();
        dummyCLPRoduct1.clcommon__Product_Name__c = 'Manual Payer';            
        dummyCLPRoduct1.loan__Lending_Product__c = dummyLP.id;
        
        insert dummyCLPRoduct1;
        
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();        
        dummyLoanPurpose.loan__Loan_Purpose_Code__c = 'Refinance';
        account dummyClient = new account(); 
        dummyClient.Name = 'Payoff';
        dummyClient.peer__Last_Name__c = 'Account';
        dummyClient.peer__First_Name__c = 'Test';
        insert dummyClient;
        
        account dummyClient2 = new account(); 
        dummyClient2.Name = 'Accounttwo Test';
        dummyClient2.peer__Last_Name__c = 'Accounttwo';
        dummyClient2.peer__First_Name__c = 'Test';
        insert dummyClient2;
        
        Account invacc = new Account();
        invacc.name = 'investor';
        invacc.peer__Last_Name__c='scenario';
        invacc.loan__Investor__c = True;
        insert invacc;
        
        loan__Payment_Mode__c pm = new loan__Payment_Mode__c();
        pm.name = 'Wire';
        insert pm;
        
        //investor bank acc.
        loan__Bank_Account__c bainv = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
                                                                loan__Bank_Name__c = 'Some Bank',
                                                                loan__Routing_Number__c = '999999999',
                                                                loan__Account_Type__c = 'Checking',
                                                                loan__Active__c = true,
                                                                Unmasked_Bank_Account_Number__c = '99999999',
                                                                loan__Account__c = invacc.id);
        insert bainv;
        
        loan__Automated_Payment_Configuration__c invaps = new loan__Automated_Payment_Configuration__c();
        invaps.loan__Payment_Mode__c = pm.id;
        invaps.loan__Bank_Account__c = bainv.id;
        invaps.loan__Filegen_Class__c = 'CustomLoanPaymentTxnNACHAGen';
        invaps.loan__Folder_Name__c = 'ACU';
        invaps.loan__File_Type__c = 'CSV';
        invaps.loan__Event__c = 'LOAN PAYMENT';
        insert invaps;
        
        
        loan__Bank_Account__c ba = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
                                                             loan__Bank_Name__c = 'Some Bank',
                                                             loan__Routing_Number__c = '999999999',
                                                             loan__Account_Type__c = 'Checking',
                                                             loan__Active__c = true,
                                                             Unmasked_Bank_Account_Number__c = '99999999',
                                                             loan__Account__c = dummyClient.id);
        insert ba;
        //// Queue
        QueueSobject pendingForFundingque = [Select queue.id,queue.name,QueueID 
                                             from QueueSobject 
                                             where SobjectType ='genesis__Applications__c'                                   
                                             AND queue.DeveloperName =: 'Pending_for_Funding' limit 1];
        ///////Creation Of Applications......
        genesis__Applications__c genesApp = new genesis__Applications__c();
        genesApp.genesis__Due_Day__c = 20;
        genesApp.genesis__Expected_First_Payment_Date__c = system.Today();
        genesApp.genesis__Expected_Start_Date__c = system.Today();
        genesApp.genesis__Funding_in_Tranches__c = true;
        genesApp.genesis__Draw_Period_End_Date__c = system.Today();
        genesApp.genesis__Account__c = dummyClient.id;
        genesApp.genesis__Loan_Amount__c = 9000;
        genesApp.genesis__Term__c = 24;
        genesApp.genesis__Interest_Rate__c = 9.97;
        genesApp.Employment_Status__c = 'Full time';
        genesApp.genesis__Product_Type__c = 'LOAN';
        //genesApp.Precise_Account_Opening_Status__c = 'Accept';
        genesApp.genesis__CL_Product__c = dummyCLPRoduct.id;
        genesApp.OwnerId = pendingForFundingque.Queue.Id;
        genesApp.genesis__status__c = 'Approved for funding';
        genesApp.Investor__c = invacc.id;
        genesApp.Anniversary_Date__c = date.today();
        genesApp.Loan_Doc_Signed_On__c = date.today() + 2;
        genesApp.Loan_Origination_Date__c = date.today() + 4;
        //genesApp.OwnerId = pendingForFundingque.Queue.Id;
        insert genesApp;
        genesApp.OwnerId = pendingForFundingque.QueueID;
        update genesApp;
        genesis__Applications__c genesApp1 = new genesis__Applications__c();
        genesApp1.genesis__Due_Day__c = 20;
        genesApp1.genesis__Expected_First_Payment_Date__c = system.Today();
        genesApp1.genesis__Expected_Start_Date__c = system.Today();
        genesApp1.genesis__Funding_in_Tranches__c = true;
        genesApp1.genesis__Draw_Period_End_Date__c = system.Today();
        genesApp1.genesis__Account__c = dummyClient.id;
        genesApp1.genesis__Loan_Amount__c = 9000;
        genesApp1.genesis__Term__c = 24;
        genesApp1.genesis__Interest_Rate__c = 9.97;
        genesApp1.Employment_Status__c = 'Full time';
        genesApp1.genesis__Product_Type__c = 'LOAN';
        //genesApp.Precise_Account_Opening_Status__c = 'Accept';
        genesApp1.genesis__CL_Product__c = dummyCLPRoduct.id;
        genesApp1.OwnerId = pendingForFundingque.Queue.Id;
        genesApp1.genesis__status__c = 'Approved for funding';
        genesApp1.Investor__c = invacc.id;
        genesApp1.Anniversary_Date__c = date.today();
        genesApp1.Loan_Doc_Signed_On__c = date.today() + 2;
        genesApp1.Loan_Origination_Date__c = date.today() + 4;
        //genesApp.OwnerId = pendingForFundingque.Queue.Id;
        insert genesApp1;
        
        
    }
    /*Created By : Bhavya Maliwal
Method name : ConvertAppToContractCntrl_UpdateApp_ConvertApp
Purpose : to cover code satisfying Application Update (updateApps) and conversion of Application (convertApps) for ConvertAppToContractCntrl 
*/ 
    public static testmethod void ConvertAppToContractCntrl_UpdateApp_ConvertApp(){
        List<genesis__Applications__c> appList =[Select id from genesis__Applications__c];
        Test.StartTest();
        ApexPages.StandardSetController stdctrl = new ApexPages.StandardSetController(appList);
        stdctrl.setSelected(appList);
        ConvertAppToContractCntrl ctopc = new ConvertAppToContractCntrl(stdctrl);
        //ctopc.checkJobStatus();
        ctopc.selectedAppList = appList;
        ctopc.convertApps();       
        PageReference uapp=ctopc.updateApps();
        system.assertEquals(TRUE, uapp!=null);
        
        ConvertAppToContractCntrl.Errors err= new ConvertAppToContractCntrl.Errors();
        err.appName = '';
        err.error = '';
        Test.stopTest();
        
    }
    /*Created By : Bhavya Maliwal
Method name : ConvertAppToContractCntrl_JobIdNotNull
Purpose : to cover code satisfying if condition for Method getIsEnabled inn ConvertAppToContractCntrl 
where JOB ID is NOT NULL
*/
    public static testmethod void ConvertAppToContractCntrl_JobIdNotNull(){
        Test.StartTest();
        PageReference pageRef = Page.ConvertApplication; 
        pageRef.getParameters().put('jobId','7074C00000UzIckQAF');// dummy id
        Test.setCurrentPage(pageRef);
        ConvertAppToContractCntrl ctopc = new ConvertAppToContractCntrl();
        Boolean result=  ctopc.getIsEnabled();
        system.assert(result);  
        test.stopTest();
        
    }
    /*Created By : Bhavya Maliwal
Method name : ConvertAppToContractCntrl_JobIdNull
Purpose : to cover code satisfying else condition for Method getIsEnabled inn ConvertAppToContractCntrl 
where JOB ID is NULL
*/
    public static testmethod void ConvertAppToContractCntrl_JobIdNull(){
        Test.StartTest();
        ConvertAppToContractCntrl ctopc = new ConvertAppToContractCntrl();
        ctopc.getIsEnabled();
        Boolean result=  ctopc.getIsEnabled();
        system.assert(!result);  
        test.stopTest();
        
    }
    
}