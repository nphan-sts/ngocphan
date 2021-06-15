/* ****************Modification History******************
 * Created by    	Date    	JIRA number
 *     Pallavi      2019/12/13    LOS-185/186 auto sale in bulk
 ******************Modification History******************/
@isTest
public class TestAutoSaleBatchAssignCntrl {
    
    static loan__Loan_Account__c createLoanAccount() {
        
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

        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();


        Account acc = new Account(Name = 'SF');
        insert acc;

        loan__Payment_Mode__c paymentMode = new loan__Payment_Mode__c(name='ACH');
        insert paymentMode;
        //Create a dummy Loan Account
        loan__Loan_Account__c loanAccount = loan.TestHelper.createLoanAccountForAccountObj(dummyLP,
                                                    acc,
                                                    dummyFeeSet,
                                                    dummyLoanPurpose,
                                                    dummyOffice);
        return loanAccount;
    }
    
    @isTest
    static void test_AutoSaleBatchAssignCntrl(){
        //loan.TestHelper.systemDate = Date.newInstance(2016, 1, 15);
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        loan__Loan_Account__c lAcct = createLoanAccount();
        Date systemDate = util.getCurrentSystemDate();

        Account invacc = new Account(
            Name = 'Investor',
            loan__Investor__c = true,
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
        Insert invacc;
        
        Account acc = new Account(Name = 'Test Account', loan__Undeployed_Funds__c = 10000);
        insert acc;
        
        list<loan__Investor_Loan__c> ioList = new list<loan__Investor_Loan__c>();
         
           loan__Investor_Loan__c lo = new loan__Investor_Loan__c();
           lo.loan__Certificate_Rate__c                   = 1.0;
           lo.Buyer__c                                    = invacc.id;
           lo.loan__Service_Rate__c                       = 10.0;
           lo.loan__Account__c                            = invacc.id;
           lo.loan__Loan__c                               = lAcct.id;
           lo.loan__Share__c                              = 100;
           lo.loan__Status__c                             = 'Active';
           lo.loan__Enabled_Flag__c                       =  true;
           lo.loan__Inv_Accrued_Interest_Amt__c           =  0;
           lo.loan__Investment_Amount__c                  = 1000;
           lo.loan__Principal_Amount_Paid__c              = 2;
           lo.loan__Loan_Principal_Remaining__c           =1000;
           lo.loan__Investor_Start_Date__c                = System.today();
           
         
           insert lo;
        
           List<loan__loan_account__c> contractList = new List<loan__loan_account__c>();
           contractList.add(lAcct);
        
            Test.startTest();
            Test.setCurrentPage(Page.AutoSaleBatchAssign);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(contractList);
            stdSetController.setSelected(contractList);
            AutoSaleBatchAssignCntrl ctopc = new AutoSaleBatchAssignCntrl(stdSetController);
            ctopc.contract = lAcct;
            ctopc.saveBuyerandDate();
            ctopc.validateBuyerandDate();
        
        	lAcct.Buyer__c = acc.id;
        	update lAcct;
        
            Test.setCurrentPage(Page.AutoSaleBatchAssign);
            stdSetController.setSelected(contractList);
            ctopc.contract = lAcct;
            ctopc.saveBuyerandDate();
            ctopc.validateBuyerandDate();
        
        	lAcct.Effective_Date_for_AutoSale__c = Date.newInstance(2015, 02, 02);
        	update lAcct;
        	
        	Test.setCurrentPage(Page.AutoSaleBatchAssign);
            ctopc.contract = lAcct;
            ctopc.saveBuyerandDate();
            ctopc.validateBuyerandDate();
        
        	lAcct.Buyer__c = invacc.id;
        	update lAcct;
        
            Test.setCurrentPage(Page.AutoSaleBatchAssign);
            stdSetController.setSelected(contractList);
            ctopc.contract = lAcct;
            ctopc.saveBuyerandDate();
            ctopc.validateBuyerandDate();
        
        	lAcct.Effective_Date_for_AutoSale__c = systemDate.addDays(2);
        	update lAcct;
        	
        	Test.setCurrentPage(Page.AutoSaleBatchAssign);
            ctopc.contract = lAcct;
            ctopc.saveBuyerandDate();
            ctopc.validateBuyerandDate();
        
        	lAcct.Buyer__c = invacc.id;
        	update lAcct;
             
        	ctopc.updateBuyerandDate();
                
            Test.stopTest();
        
        	
    }

}