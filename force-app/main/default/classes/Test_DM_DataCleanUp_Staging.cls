/**
 *
 * 
 * @author - Pallavi
 * **/
@isTest
public class Test_DM_DataCleanUp_Staging {
    
    @testSetup
    static void testData(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        MigrationPhase__c phase = new MigrationPhase__c();
        phase.name = 'phase1';
        phase.phase__c = 'phase1';
        insert phase;
        
        Account a2 = new Account(Name = 'Bull', loan__Undeployed_Funds__c = 999999,loan__Investor__c = true);   //pallavi
        insert a2;
        loan.CustomSettingsUtil.getNS();
        //Create Borrower 
        Account b1 = loan.TestHelper2.createBorrower('ShoeString'); 
        loan.TestHelper.systemDate = Date.today(); 
        Id rtId = Schema.SObjectType.loan__Office_Name__c.getRecordTypeInfosByName().get('Root Branch').getRecordTypeId();
        //Id prodRTId = Schema.SObjectType.loan__Loan_Product__c.getRecordTypeInfosByName().get('Loan Product Record Type').getRecordTypeId();
        
        loan__office_Type__c testBranchType = new loan__Office_Type__c(Name='Data Migration',
                                                        loan__Office_Type_Short_Code__c='TestSC' );
        insert testBranchType;
      
        loan__MF_Account__c a1 = loan.TestHelper.createMFAccount('TestAccountForOffice', '10000 - ASSETS');        
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount); 
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet(); 
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        List<loan__Loan_Product__c> loanProductList = new List<loan__Loan_Product__c>();
        
         loan__Office_Name__c dummyOffice = new loan__Office_Name__c(Name='PayOff Inc.',
                                                    //loan__Office_Location__c = testLoc.ID,
                                                    loan__Office_Short_Name__c = 'XXXCSN',
                                                    loan__Cash_Account__c = a1.Id,
                                                    loan__Check_Account__c = a1.Id,
                                                    loan__Bank_Account_Checks__c = a1.Id,
                                                    loan__Inward_Check_Clearance_Account__c = a1.Id,
                                                    loan__Outward_Check_Clearance_Account__c= a1.Id,
                                                    loan__Profit_and_Loss_Account__c = a1.Id,
                                                    loan__Loan_Schedule_tied_to_Meeting_Schedule__c = false,
                                                    loan__Mark_Suspended_After_Days__c = 180,
                                                    loan__State__c = 'Active',
                                                    loan__Write_Off_Suggestion_Days__c = 90,
                                                    loan__Office_Type__c = testBranchType.ID,
                                                    loan__Days_in_advance_to_create_Collection_Rep__c=1,
                                                    loan__Current_System_Date__c = Date.Today().addDays(-30),
                                                    RecordTypeId = rtId,
                                                    loan__Is_Branch__c=true);
        insert dummyOffice;
        
        loan__Loan_Product__c simpleLP = DM_TestHelper.createLoanProduct('Simple Loan',dummyOffice, 
                                              dummyAccount, curr, dummyFeeSet, 'Loan'); 
        loanProductList.add(simpleLP);
        
        loan__Loan_Product__c difficultLP = DM_TestHelper.createLoanProduct('Difficult Loan',dummyOffice, 
                                              dummyAccount, curr, dummyFeeSet, 'Loan');
        loanProductList.add(difficultLP);
        
        loan__Loan_Product__c errorLp = DM_TestHelper.createLoanProduct('Simple Loan',dummyOffice,  
                                              dummyAccount, curr, dummyFeeSet, 'Loan');
        loanProductList.add(errorLp);
        
        
        insert loanProductList;
                     
        loan__Payment_Mode__c pMode = new loan__Payment_Mode__c(name='Cash');
       // insert pMode;
        
        loan__Bank_Account__c bankAccount = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12', 
                                                 loan__Bank_Name__c = 'Some Bank', 
                                                 loan__Routing_Number__c = '999999999', 
                                                 loan__Account_Type__c = 'Savings', 
                                                 loan__Account_Usage__c = 'Borrower/Investor Account', 
                                                 loan__Account__c = b1.id,
                                                 Unmasked_Bank_Account_Number__c = '12345');    //pallavi
        insert bankAccount;
        
        List<DM_Loan_Account__c> dmLoanList = new List<DM_Loan_Account__c>();
        DM_Loan_Account__c dmloan = DM_TestHelper.createDMLOC(simpleLP,0.0,b1,dummyFeeSet,dummyOffice,5,'Declining Balance');
        dmLoanList.add(dmloan);
        
        insert dmLoanList;
        
        DM_Loan_Disbursal_Transaction__c ldt =  DM_TestHelper.fundLoan(dmLoan, Date.Today(), pmode,bankAccount);
        insert ldt;
        
        DM_Disbursal_Transaction_Distribution__c ddt = DM_TestHelper.createDDTD();
        insert ddt;
        
        DM_Multi_Step_Loan_Setup__c rss = DM_TestHelper.createRSS(dmLoan);
        insert rss;
        /*pallavi*/
                                                        
        DM_Bill__c bill =  DM_TestHelper.createUnpaidDue(dmLoan, 6500.00);
        insert bill;
        
        DM_Repayment_Schedule_Summary__c dm_RSS = DM_TestHelper.CreateRSSData(dmLoan, 600.00);
        insert dm_RSS;
        
        DM_Repayment_Schedule__c AmzSchedule = DM_TestHelper.CreateAmzScheduleData(dmLoan, 1000.00);
        insert AmzSchedule;
  
        DM_Automated_Payment_Setup__c aps =  DM_TestHelper.createAutomatedPaymentSetup('DO it later', '', bankAccount,
                                                         dmLoan, '', pMode, Date.Today(),1);
        insert aps;
        
        DM_Loan_Payment_Transaction__c lpt = DM_TestHelper.createLoanPayment(dmLoan.Id, 10000.00,Date.today(),aPS, pMode, null);
        insert lpt;
            
        DM_Investment_Order__c dmInvOrder = DM_TestHelper.createInvestmentOrder(a2,dmLoan,70000);
        insert dmInvOrder;
    }
    @isTest
    static void testMehod_1(){ 
        User u = [Select Id from User limit 1];
        system.runAs(u){
            Test.startTest();
            DM_DataCleanUp_Staging dm = new DM_DataCleanUp_Staging();
            Database.executeBatch(dm,1);
            Test.stopTest();
        }
    } 
}