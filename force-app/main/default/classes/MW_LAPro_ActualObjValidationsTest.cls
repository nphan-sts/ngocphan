@isTest
private class MW_LAPro_ActualObjValidationsTest {
    @testSetup
	static void testSetupData() {
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        loan__Trigger_Parameters__c triggerParam = new loan__Trigger_Parameters__c();
        triggerParam.loan__Disable_Loan_Account_Trigger__c=true;
        insert triggerParam;
        
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();  
        //Account a2 = loan.TestHelper2.createInvestor('Bull', 1000); 
        loan.CustomSettingsUtil.getNS();
        //Create Borrower 
        Account b1 = loan.TestHelper2.createBorrower('ShoeString'); 
        loan.TestHelper.systemDate = Date.today(); 
        Id rtId = Schema.SObjectType.loan__Office_Name__c.getRecordTypeInfosByName().get('Root Branch').getRecordTypeId();
        Id prodRTId = Schema.SObjectType.loan__Loan_Product__c.getRecordTypeInfosByName().get('Loan Product Record Type').getRecordTypeId();

        loan__Currency__c curr = loan.TestHelper.createCurrency();
        loan__office_Type__c testBranchType = new loan__Office_Type__c(Name='Data Migration',
                                                        loan__Office_Type_Short_Code__c='TestSC' );
        insert testBranchType;
                                                               
        loan__MF_Account__c a1 = loan.TestHelper.createMFAccount('TestAccountForOffice', '10000 - ASSETS');
    
        loan__Branch_Location__c testLoc = new loan__Branch_Location__c(Name='Data Migration',
                                            loan__Address_Line_1__c = 'Add1',
                                            loan__Address_Line_2__c = 'Add2',
                                            loan__State__c = 'MH',
                                            loan__Phone__C = '32323232',
                                            loan__Zip_code__c = 33333
                                            );
        insert testLoc;
        
        
        
        
        loan__Office_Name__c dummyOffice = new loan__Office_Name__c(Name='Data Migration',
                                                    loan__Office_Location__c = testLoc.ID,
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
                
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount); 
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet(); 
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        List<loan__Loan_Product__c> loanProductList = new List<loan__Loan_Product__c>();
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
        
        loan__Bank_Account__c bankAccount = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12345678', 
                                                 loan__Bank_Name__c = 'Some Bank', 
                                                 loan__Routing_Number__c = '999999999', 
                                                 loan__Account_Type__c = 'Savings', 
                                                 loan__Account_Usage__c = 'Borrower/Investor Account', 
                                                 loan__Account__c = b1.id,
                                                 Unmasked_Bank_Account_Number__c = '12345678');
        insert bankAccount;
        
        List<DM_Loan_Account__c> dmLoanList = new List<DM_Loan_Account__c>();
        DM_Loan_Account__c dmloan = DM_TestHelper.createDMLOC(simpleLP,0.0,b1,dummyFeeSet,dummyOffice,5,'Declining Balance');
        //dmloan.DM_Application__c = app.Id;
        dmLoanList.add(dmloan);
        
        DM_Loan_Account__c dmloan2 = DM_TestHelper.createDMLOC(difficultLP,0.0,b1,dummyFeeSet,dummyOffice,5,'Declining Balance');
        //dmloan2.DM_Application__c = app.Id;
        dmLoanList.add(dmloan2);
        
        DM_Loan_Account__c dmloan3 = DM_TestHelper.createDMLOC(errorLp,0.0,b1,dummyFeeSet,dummyOffice,5,'Error');
        //dmloan3.DM_Application__c = app.Id;
        dmLoanList.add(dmloan3);
        insert dmLoanList;
        
        DM_Loan_Disbursal_Transaction__c ldt =  DM_TestHelper.fundLoan(dmLoan, Date.Today(), pmode,bankAccount);
        insert ldt;
                                                        
        DM_Bill__c bill =  DM_TestHelper.createUnpaidDue(dmLoan, 6500.00);
        insert bill;
        
        DM_Repayment_Schedule_Summary__c dm_RSS = DM_TestHelper.CreateRSSData(dmLoan, 600.00);
        insert dm_RSS;
        
        DM_Charge__c charge =  DM_TestHelper.createUnpaidCharge(dmLoan, dummyFee, 100.00 );
        insert charge;
        
        DM_Repayment_Schedule__c AmzSchedule = DM_TestHelper.CreateAmzScheduleData(dmLoan, 1000.00);
        insert AmzSchedule;
        
        DM_Automated_Payment_Setup__c aps =  DM_TestHelper.createAutomatedPaymentSetup('DO it later', '', bankAccount,
                                                         dmLoan, '', pMode, Date.Today(),1);
        insert aps;
        
        DM_Loan_Payment_Transaction__c lpt = DM_TestHelper.createLoanPayment(dmLoan.Id, 10000.00,Date.today(),aPS, pMode, null);
        insert lpt;
    }
    
    private static testmethod void testActualObj(){
        List<DM_Loan_Account__c> dmLoanList = new List<DM_Loan_Account__c>();
        
        Account b1 = [Select Id, Name from Account limit 1];
        loan__Fee_Set__c dummyFeeSet = [Select Id, name from loan__Fee_Set__c limit 1];
        loan__Loan_Product__c simpleLP = [Select Id, Name from loan__Loan_Product__c limit 1];
        loan__Office_Name__c dummyOffice = [Select Id, Name from loan__Office_Name__c limit 1];
        /*DM_Automated_Payment_Setup__c aps = [Select Id, Name from DM_Automated_Payment_Setup__c limit 1];
        //DM_Loan_Payment_Transaction__c lpt = [Select Id, Name from DM_Loan_Payment_Transaction__c limit 1];
        DM_Loan_Account__c dmloan = [select id, 
                                     DM_Interest_Calculation_Method__c, 
                                     DM_Time_Counting_Method__c ,
                                     DM_Product__c  ,
                                     DM_Product_Type__c  ,
                                     DM_Number_of_Installments__c  ,
                                     DM_Grace_Period_for_Repayments__c ,
                                     DM_Delinquency_Grace_Days__c ,
                                     DM_Pre_Bill_Days__c ,
                                     DM_Loan_Amount__c ,
                                     DM_Contractual_Interest_Rate__c ,
                                     DM_Account__c ,
                                     DM_Contact__c ,
                                     DM_Due_Day__c ,
                                     DM_Expected_Repayment_Start_Date__c
                                     from DM_Loan_Account__c limit 1];
        loan__Payment_Mode__c pMode = new loan__Payment_Mode__c(name='Cash');*/
        
        Account InvAcc = new Account(Name = 'TestInvestor',loan__Investor__c=True);
        Insert InvAcc; 
        Account acc = new Account(
            Name = 'TestAcc',
            loan__Investor__c=false,
            peer__First_Name__c='Test_PeerFName', 
            peer__Last_Name__c='Test_PeerLName',
            ints__SSN__c='12345678', 
            peer__Date_of_Birth__c=System.today(),
            Address_1__c='TestAddr1', 
            Address_2__c='TestAddr2', 
            City__c='Test_City',
            State__c='Test_State', 
            ZIP_Code__c='12345', 
            Suffix__c='Mr',
            Phone='2345677', 
            peer__Email__c='test@testOrg.com',
            Payoff_UID__c='1324325346547', 
            cnotify__Email__c='notify@testOrg.com',
            loan__social_security_number__c = '123456789',
            US_Citizen__c=true);
        Insert acc;
        genesis__Applications__c app = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            Investor__c = InvAcc.Id, 
            genesis__Account__c = acc.Id,
            Lead_ID__c='716d3efb-0047-4f93-9909-6fedfaa779781',
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'funded',
            DocuSignFlag__c=true,
            genesis__Draw_Period_End_Date__c = system.Today()
        );
        Insert app; 
        genesis__Applications__c app1 = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            //Investor__c = InvAcc.Id, 
            //genesis__Account__c = acc.Id,
            //Lead_ID__c='716d3efb-0047-4f93-9909-6fedfaa779781',
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'funded',
            DocuSignFlag__c=true,
            genesis__Draw_Period_End_Date__c = system.Today()
        );
        Insert app1; 
        Pricing_Offer__c pOffer = new Pricing_Offer__c(
            Application__c=app.Id, 
            Amount__c=1000, 
            Interest_Rate__c=2.0, 
            Monthly_Payment__c=99, 
            Term__c=5,
            Is_Offer_Selected__c=true
        );
        Insert pOffer;
        
        Credit_Policy__c crPolicy = new Credit_Policy__c();
        crPolicy.Net_Disposable_Income_NDI__c = '1200';
        crPolicy.Application__c =app.id;
        insert crPolicy;
        
        
        DM_Loan_Account__c dmloan1 = DM_TestHelper.createDMLOC(simpleLP,0.0,b1,dummyFeeSet,dummyOffice,5,'Declining Balance');
        dmloan1.DM_Time_Counting_Method__c = null;
        dmloan1.DM_Application__c = app.Id;
        dmLoanList.add(dmloan1);
        
        DM_Loan_Account__c dmloan2 = DM_TestHelper.createDMLOC(simpleLP,0.0,b1,dummyFeeSet,dummyOffice,5,'Declining Balance');
        dmloan2.DM_Application__c = app1.Id;
        dmLoanList.add(dmloan2);
        
        insert dmLoanList;
        
        Test.startTest();
        MW_LAPro_ActualObjValidations.getActualObjValidationErrors(dmLoanList);
        Test.stopTest();
    }

}