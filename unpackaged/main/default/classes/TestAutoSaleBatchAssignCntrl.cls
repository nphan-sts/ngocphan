/* ****************Modification History******************
 * Created by    	Date    	JIRA number
 *     Pallavi      2019/12/13    LOS-185/186 auto sale in bulk
 * Modified By       Date                    JIRA Number
 *   Shakul        4/3/2022          LSP-564 (Refactored Test Class)	
 ******************Modification History******************/
@isTest
public class TestAutoSaleBatchAssignCntrl {
    @TestSetup
    public static void testSetup(){
        //Creating Seed Data for Testing
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
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct('Loan Product',
                                                                            dummyOffice,
                                                                            dummyAccount,
                                                                            curr,
                                                                            dummyFeeSet,
                                                                            'Interest Only',
                                                                            40,
                                                                            12,
                                                                            null);
        List<Account> lstAcc = new List<Account>();

        Account acc = new Account(peer__First_Name__c ='Account',peer__Last_Name__c = 'Test');
        lstAcc.add(acc);

        Account invacc = new Account(loan__Investor__c = true,
                                    Amount_Invested__c = 1000,
                                    Number_Of_Applications_Invested__c = 3, 
                                    Total_No_of_Application_Limit__c = 30,
                                    Last_Application_assigned_on__c = system.now()-7,
                                    Total_Investment_Limit__c = 1000000,
                                    loan__Undeployed_Funds__c = 500000,
                                    cnotify__Email__c = 'no-reply@testorganization.com',
                                    peer__First_Name__c = 'TestFName1',
                                    peer__Last_Name__c='TestLName2',
                                    no_of_shares_to_be_Sold__c = 1,
                                    Number_of_Days__c = 0,
                                    loan__Active__c = 'YES', 
                                    City__c='CANADA',
                                    State__c='CA',
                                    ZIP_Code__c='123456'
        );
        lstAcc.add(invacc);

        Account accOne = new Account(peer__First_Name__c ='AccountTwo',peer__Last_Name__c = 'TestTwo', loan__Undeployed_Funds__c = 10000);
        lstAcc.add(accOne);

        insert lstAcc;

        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();

        //Create a dummy Loan Account
        loan__Loan_Account__c loanAccount = loan.TestHelper.createLoanAccountForAccountObj(dummyLP,
                                                                                            acc,
                                                                                            dummyFeeSet,
                                                                                            dummyLoanPurpose,
                                                                                            dummyOffice);

           loan__Investor_Loan__c lo = new loan__Investor_Loan__c();
           lo.loan__Certificate_Rate__c                   = 1.0;
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
    }

    /*Created By: Shakul Siddharth
	  Purpose: To test selected contracts from the page and investor loan is updated with buyer account */
    public static testMethod void testSaveBuyerandDate(){
        List<loan__loan_account__c> contractList = [SELECT id, Buyer__c FROM loan__loan_account__c];
        Test.startTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(contractList);
        stdSetController.setSelected(contractList);
        AutoSaleBatchAssignCntrl ctopc = new AutoSaleBatchAssignCntrl(stdSetController);
        ctopc.saveBuyerandDate();
        ctopc.updateBuyerandDate();
        Test.stopTest();
        loan__Investor_Loan__c testLoan = [SELECT id, Buyer__c FROM loan__Investor_Loan__c LIMIT 1];
        System.assertEquals(testLoan.Buyer__c, contractList[0].Buyer__c);
        System.assert(ctopc.SelectedContracts.size()>0);
    }

    /*Created By: Shakul Siddharth
	  Purpose: To test whether account investor flag is true */
    public static testMethod void testValidateBuyerandDate(){
        Account buyerAcc = [SELECT id FROM Account WHERE peer__First_Name__c ='AccountTwo'];
        List<loan__loan_account__c> contractList = [SELECT id, Buyer__c, Effective_Date_for_AutoSale__c FROM loan__loan_account__c];
        contractList[0].Buyer__c = buyerAcc.Id;        	
        contractList[0].Effective_Date_for_AutoSale__c = Date.newInstance(2015, 02, 02);
        update contractList[0];
        Test.startTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(contractList);
        AutoSaleBatchAssignCntrl ctopc = new AutoSaleBatchAssignCntrl(stdSetController);
        ctopc.contract = contractList[0];
        ctopc.validateBuyerandDate();
        Test.stopTest();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertEquals(1, pageMessages.size());
    }

    /*Created By: Shakul Siddharth
	  Purpose: To test the logic when effective date for auto sale is blank */
    public static testMethod void testValidateBuyerandDate_EffDtBlank(){
        Account buyerAcc = [SELECT id FROM Account WHERE peer__First_Name__c ='AccountTwo'];
        List<loan__loan_account__c> contractList = [SELECT id, Buyer__c, Effective_Date_for_AutoSale__c FROM loan__loan_account__c];
        contractList[0].Buyer__c = buyerAcc.Id;
        update contractList[0];
        Test.startTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(contractList);
        AutoSaleBatchAssignCntrl ctopc = new AutoSaleBatchAssignCntrl(stdSetController);
        ctopc.contract = contractList[0];
        ctopc.validateBuyerandDate();
        Test.stopTest();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertEquals(1, pageMessages.size());
    }

    /*Created By: Shakul Siddharth
	  Purpose: To test the logic when buyer account is blank */
    public static testMethod void testValidateBuyerandDate_BuyerBlank(){
        List<loan__loan_account__c> contractList = [SELECT id, Buyer__c, Effective_Date_for_AutoSale__c FROM loan__loan_account__c];
        contractList[0].Effective_Date_for_AutoSale__c = Date.newInstance(2015, 02, 02);
        update contractList[0];
        Test.startTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(contractList);
        AutoSaleBatchAssignCntrl ctopc = new AutoSaleBatchAssignCntrl(stdSetController);
        ctopc.contract = contractList[0];
        ctopc.validateBuyerandDate();
        Test.stopTest();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertEquals(1, pageMessages.size());
    }

    /*Created By: Shakul Siddharth
	  Purpose: To test the logic when effective date for auto sale is before the system date */
    public static testMethod void testValidateBuyerandDate_beforeSysDt(){
        Account buyerAcc = [SELECT id FROM Account WHERE peer__First_Name__c ='TestFName1'];
        List<loan__loan_account__c> contractList = [SELECT id, Buyer__c, Effective_Date_for_AutoSale__c FROM loan__loan_account__c];
        contractList[0].Buyer__c = buyerAcc.Id;        	
        contractList[0].Effective_Date_for_AutoSale__c = Date.newInstance(2015, 02, 02);
        update contractList[0];
        Test.startTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(contractList);
        AutoSaleBatchAssignCntrl ctopc = new AutoSaleBatchAssignCntrl(stdSetController);
        ctopc.contract = contractList[0];
        ctopc.validateBuyerandDate();
        Test.stopTest();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertEquals(1, pageMessages.size());
    }

    /*Created By: Shakul Siddharth
	  Purpose: To test the logic when validation is successful */
    public static testMethod void testValidateBuyerandDate_AllData(){
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        Date systemDate = util.getCurrentSystemDate();
        Account buyerAcc = [SELECT id FROM Account WHERE peer__First_Name__c ='TestFName1'];
        List<loan__loan_account__c> contractList = [SELECT id, Buyer__c, Effective_Date_for_AutoSale__c FROM loan__loan_account__c];
        contractList[0].Buyer__c = buyerAcc.Id;        	
        contractList[0].Effective_Date_for_AutoSale__c = systemDate.addDays(2);
        update contractList[0];
        Test.startTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(contractList);
        AutoSaleBatchAssignCntrl ctopc = new AutoSaleBatchAssignCntrl(stdSetController);
        ctopc.contract = contractList[0];
        ctopc.validateBuyerandDate();
        Test.stopTest();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertEquals(1, pageMessages.size());
    }

    /*Created By: Shakul Siddharth
	  Purpose: To test the logic on buyer change */
    public static testMethod void testOnChangeBuyer(){
        List<loan__loan_account__c> contractList = [SELECT id FROM loan__loan_account__c];
        Test.startTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(contractList);
        AutoSaleBatchAssignCntrl ctopc = new AutoSaleBatchAssignCntrl(stdSetController);
        ctopc.onChangeBuyer();
        Test.stopTest();
        System.assertEquals(false, ctopc.btnEnabled);
    }

}