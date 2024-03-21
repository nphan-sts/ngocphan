@isTest
private class MW_LoanAccountTest {
    static final String BANKRUPTCY_STATUS_ACTIVE = 'Active';
    static final String BANKRUPTCY_STATUS_DISMISS = 'Dismiss';
    static final String BANKRUPTCY_STATUS_DISCHARGE = 'Discharge';
    static final String RETENTION_CONFIRMED = 'Confirmed';
    static final String RETENTION_NOT_CONFIRMED = 'Not Confirmed';
    static final String CHAPTER_13 = '13';
    static final String CHAPTER_7 = '7';
    static final String CHAPTER_11 = '11';
    static final String ATTORNEY_NAME = 'test name';
    static final String ATTORNEY_PHONE = '0123123124';
    static final String ERROR_MESSAGE_REQUIRED_FIELDS = 'Agent Processed Date, Bankruptcy Status, Chapter, Attorney Name, Attorney Phone, Retention Confirmed must be filled';
    @testSetup
    static void setup() {
        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();

        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');

        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);

        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();

        loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
        org.loan__Disable_Triggers__c = true;
        upsert org;

        genesis__Org_Parameters__c genorg = genesis__Org_Parameters__c.getOrgDefaults();
        genorg.genesis__Disable_Triggers__c = true;
        upsert genorg;

        LoanPaymentDays__c lpdays = MW_GlobalTestUtility.GetLoanPaymentDays();
        insert lpdays;

        loan__Loan_Product__c loanProdObj = MW_GlobalTestUtility.GetLoanProduct();
        insert loanProdObj;

        genesis__Company__c comp = genesis.TestHelper.createCompany();
        comp.Name = 'payoff';
        update comp;

        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);

        clcommon__CL_Product__c pr = new clcommon__CL_Product__c();
        pr.loan__Lending_Product__c = dummyLp.id;
        pr.clcommon__Product_Name__c = 'P1';
        insert pr;

        Account account_Obj = new Account(Name = 'Test', peer__Last_Name__c = 'LastName', loan__Investor__c = false, cnotify__Email__c = 'no-reply@testorganization.com');
        insert account_Obj;

        Account acc = MW_GlobalTestUtility.GetAccount('Member');
        insert acc;

        Contact a1 = MW_GlobalTestUtility.GetContact();
        insert a1;

        loan__Bank_Account__c ba = MW_GlobalTestUtility.GetBankAccount();
        ba.Unmasked_Bank_Account_Number__c = acc.Id;
        ba.loan__Contact__c = a1.id;
        ba.loan__Account__c = acc.id;

        insert ba;

        loan__Payment_Mode__c pMode = MW_GlobalTestUtility.GetPMode();
        insert pMode;

        loan__Payment_Mode__c pMode1 = MW_GlobalTestUtility.GetPMode1();
        insert pMode1;

        genesis__applications__c objApp = MW_GlobalTestUtility.GetApplication();
        objApp.genesis__Account__c = account_Obj.Id;
        objApp.genesis__Company__c = comp.id;
        objApp.genesis__CL_Product__c = pr.id;
        insert objApp;

        loan__Loan_Account__c lacc = MW_GlobalTestUtility.GetCLContract();
        lacc.loan__Account__c = acc.Id;
        lacc.loan__Contact__c = a1.ID;
        lacc.loan__Loan_Product_Name__c = loanProdObj.Id;
        lacc.application__c = objApp.id;
        insert lacc;
    }

    static testMethod void updateLoanAcc() {
        test.startTest();
        loan__loan_account__c loanAcc = [
            SELECT id, name, loan__Loan_Status__c
            FROM loan__loan_account__c
            WHERE lead_guid__c = 'TestClassGuid0'
        ];

        try {
            loanAcc.loan__Loan_Status__c = 'Closed - obligations met';
            update loanAcc;
        } catch (exception e) {
            System.debug('****** Exception Caught :   ' + e.getMessage());
        }

        test.stopTest();
    }

    static testMethod void testSkipAPay() {
        test.startTest();
        loan__loan_account__c loanAcc = [
            SELECT id, name, loan__Loan_Status__c, Mod_End_Date__c, Mod_Payment_Amount__c, U_LoanModForbearDt__c, U_LoanModForbearance__c
            FROM loan__loan_account__c
            WHERE lead_guid__c = 'TestClassGuid0'
        ];

        loanAcc.U_LoanModForbearDt__c = System.today().addMonths(-12);
        loanAcc.U_LoanModForbearance__c = 1;
        loanAcc.Skipped_a_Pay__c = true;
        update loanAcc;

        loan__loan_account__c result = [
            SELECT id, name, loan__Loan_Status__c, Mod_End_Date__c, Mod_Payment_Amount__c, U_LoanModForbearDt__c, U_LoanModForbearance__c
            FROM loan__loan_account__c
            WHERE lead_guid__c = 'TestClassGuid0'
        ];

        System.assertEquals(result.Mod_End_Date__c, System.today().addMonths(-12).addDays(-1).addMonths(1), 'correct date');
        System.assertEquals(result.Mod_Payment_Amount__c, null, 'correct date');

        test.stopTest();
    }

    @isTest
    static void testUpdateAgentCompletePOC() {

        Test.startTest();
        loan__loan_account__c loanAcc = queryLoan('TestClassGuid0');

        loanAcc = updateFullBankruptcyFields(loanAcc);
        loanAcc.POC_Deadline_Date__c= System.today();
        loanAcc.POC_Completed_Date__c = System.today();
        update loanAcc;
        
        // Verify the updated loan accounts
        loan__Loan_Account__c updatedLoanAccount = queryLoan('TestClassGuid0');
        System.assertEquals(UserInfo.getUserId(), updatedLoanAccount.Agent_Name_Completed_POC__c, 'The Agent_Name_Completed_POC__c field should be set to the current user ID');
        Test.stopTest();
    }
    @isTest
    static void testBankruptcyRequiredFieldsMissingFileDate() {
        Test.startTest();
        try {
            loan__loan_account__c loanAcc = queryLoan('TestClassGuid0');

            loanAcc = updateFullBankruptcyFields(loanAcc);
            loanAcc.File_Date__c = null;

            update loanAcc;
            
        } catch (Exception e) {
            System.assertEquals(true,e.getMessage().contains('Can only be filled when Bankruptcy Status is either Active, Dismiss, or Discharge'),'validate File_Date__c');
        }
        Test.stopTest();
    }
    @isTest
    static void testBankruptcyRequiredFieldsMissingChapter() {
        Test.startTest();
        try {
            loan__loan_account__c loanAcc = queryLoan('TestClassGuid0');

            loanAcc = updateFullBankruptcyFields(loanAcc);
            loanAcc.Chapter__c = null;

            update loanAcc;
            
        } catch (Exception e) {
            System.assertEquals(true,e.getMessage().contains(ERROR_MESSAGE_REQUIRED_FIELDS),'validate Chapter');
        }
        Test.stopTest();
    }
    @isTest
    static void testBankruptcyRequiredFieldsMissingBankruptcyStatus() {
        Test.startTest();
        try {
            loan__loan_account__c loanAcc = queryLoan('TestClassGuid0');
            loanAcc = updateFullBankruptcyFields(loanAcc);
            loanAcc.Bankruptcy_Status__c = null;

            update loanAcc;
            
        } catch (Exception e) {
            System.assertEquals(true,e.getMessage().contains(ERROR_MESSAGE_REQUIRED_FIELDS),'validate BankruptcyStatus');
        }
        Test.stopTest();
    }
    @isTest
    static void testBankruptcyRequiredFieldsMissingAttoryneyName() {
        Test.startTest();
        try {
            loan__loan_account__c loanAcc = queryLoan('TestClassGuid0');
            loanAcc = updateFullBankruptcyFields(loanAcc);
            loanAcc.Attorney_Name__c = null;

            update loanAcc;
            
        } catch (Exception e) {
            System.assertEquals(true,e.getMessage().contains(ERROR_MESSAGE_REQUIRED_FIELDS),'validate AttoryneyName');
        }
        Test.stopTest();
    }
    @isTest
    static void testBankruptcyRequiredFieldsMissingAttoryneyPhone() {
        Test.startTest();
        try {
            loan__loan_account__c loanAcc = queryLoan('TestClassGuid0');
            loanAcc = updateFullBankruptcyFields(loanAcc);
            loanAcc.Attorney_Phone__c = null;

            update loanAcc;
            
        } catch (Exception e) {
            System.assertEquals(true,e.getMessage().contains(ERROR_MESSAGE_REQUIRED_FIELDS),'validate AttoryneyPhone');
        }
        Test.stopTest();
    }
    @isTest
    static void testBankruptcyRequiredFieldsMissingRetentionConfirmed() {
        Test.startTest();
        try {
            loan__loan_account__c loanAcc = queryLoan('TestClassGuid0');
            loanAcc.Bankruptcy_Status__c = BANKRUPTCY_STATUS_ACTIVE;
            loanAcc.Chapter__c=CHAPTER_13;
            loanAcc.Attorney_Name__c = ATTORNEY_NAME;
            loanAcc.Attorney_Phone__c = ATTORNEY_PHONE;
            loanAcc.File_Date__c = System.today();

            update loanAcc;
            
        } catch (Exception e) {
            System.assertEquals(true,e.getMessage().contains(ERROR_MESSAGE_REQUIRED_FIELDS),'validate RetentionConfirmed');
        }
        Test.stopTest();
    }
    @isTest
    static void testBankruptcyRequiredFieldsPopulatePOCrequired() {
        Test.startTest();

        loan__loan_account__c loanAcc = queryLoan('TestClassGuid0');
        loanAcc = updateFullBankruptcyFields(loanAcc);
        update loanAcc;
        
        // Verify the updated loan accounts
        loan__Loan_Account__c updatedLoanAccount = queryLoan('TestClassGuid0');
        System.assertEquals(true,updatedLoanAccount.POC_Required__c,'POC_Required__c should be true when chapter is 13');

        Test.stopTest();
    }
    @isTest
    static void testBankruptcyRequiredFieldsMissingPOCDeadlineDate() {
        Test.startTest();
        try {
            loan__loan_account__c loanAcc = queryLoan('TestClassGuid0');
            loanAcc = updateFullBankruptcyFields(loanAcc);
            loanAcc.POC_Completed_Date__c = System.today();
            update loanAcc;
            
        } catch (Exception e) {
            System.assertEquals(true,e.getMessage().contains('POC Deadline Date must be filled when POC Completed Date is filled'),'validate POC deadline date');
        }
        Test.stopTest();
    }

    @isTest
    static void testBankruptcyRequiredFieldsMissingPOCCompletedDate() {
        Test.startTest();
        try {
            loan__loan_account__c loanAcc = queryLoan('TestClassGuid0');
            loanAcc = updateFullBankruptcyFields(loanAcc);
            loanAcc.POC_Deadline_Date__c = System.today();
            update loanAcc;
            
        } catch (Exception e) {
            System.assertEquals(true,e.getMessage().contains('POC Completed Date must be filled when Agent Name: Completed POC is filled'),'validate POC completed date');
        }
        Test.stopTest();
    }

    @isTest
    static void testBankruptcyFileDateShouldNotBeInFuture() {
        Test.startTest();
        try {
            loan__loan_account__c loanAcc = queryLoan('TestClassGuid0');
            loanAcc = updateFullBankruptcyFields(loanAcc);
            loanAcc.File_Date__c = System.today().addDays(1);
            update loanAcc;
            
        } catch (Exception e) {
            System.assertEquals(true,e.getMessage().contains('File Date must not in future'),'validate File Date');
        }
        Test.stopTest();
    }
    @isTest
    static void testBankruptcyDismissalDateMustAfterFileDate() {
        Test.startTest();
        try {
            loan__loan_account__c loanAcc = queryLoan('TestClassGuid0');
            loanAcc = updateFullBankruptcyFields(loanAcc);
            loanAcc.File_Date__c = System.today();
            loanAcc.Dismissal_Date__c = System.today().addDays(-1);
            update loanAcc;
            
        } catch (Exception e) {
            System.assertEquals(true,e.getMessage().contains('Dismissal Date or Discharge Date must be after File Date'),'validate Dimissal Date');
        }
        Test.stopTest();
    }
    @isTest
    static void testBankruptcyDischargeDateMustAfterFileDate() {
        Test.startTest();
        try {
            loan__loan_account__c loanAcc = queryLoan('TestClassGuid0');
            loanAcc = updateFullBankruptcyFields(loanAcc);
            loanAcc.File_Date__c = System.today();
            loanAcc.Discharge_Date__c = System.today().addDays(-1);
            update loanAcc;
            
        } catch (Exception e) {
            System.assertEquals(true,e.getMessage().contains('Dismissal Date or Discharge Date must be after File Date'),'validate Discharge Date');
        }
        Test.stopTest();
    }
    @isTest
    static void testBankruptcyEitherDischargeOrDismissalDate() {
        Test.startTest();
        try {
            loan__loan_account__c loanAcc = queryLoan('TestClassGuid0');
            loanAcc = updateFullBankruptcyFields(loanAcc);
            loanAcc.File_Date__c = System.today();
            loanAcc.Discharge_Date__c = System.today();
            loanAcc.Dismissal_Date__c = System.today();
            update loanAcc;
            
        } catch (Exception e) {
            System.assertEquals(true,e.getMessage().contains('Either Discharge or Dismissal Date can be populated, not both'),'validate Discharge Date and Dismissal Date');
        }
        Test.stopTest();
    }
    @isTest
    static void testBankruptcyRequiredFieldsAutoPopulateBankruptcyStatus() {
        Test.startTest();

        loan__loan_account__c loanAcc = queryLoan('TestClassGuid0');
        loanAcc = updateFullBankruptcyFields(loanAcc);
        loanAcc.Discharge_Date__c = System.today();
        loanAcc.Bankruptcy_Status__c = '';
        update loanAcc;
        
        // Verify the updated loan accounts
        loan__Loan_Account__c updatedLoanAccount = queryLoan('TestClassGuid0');
        System.assertEquals('Discharge',updatedLoanAccount.Bankruptcy_Status__c,'Bankruptcy_Status__c should be auto populated to Discharge');

        Test.stopTest();
    }
    @isTest
    static void testBankruptcyRequiredFieldsAutoPopulateBankruptcyStatus2() {
        Test.startTest();

        loan__loan_account__c loanAcc = queryLoan('TestClassGuid0');
        loanAcc = updateFullBankruptcyFields(loanAcc);
        loanAcc.Dismissal_Date__c = System.today();
        loanAcc.Bankruptcy_Status__c = '';
        update loanAcc;
        
        // Verify the updated loan accounts
        loan__Loan_Account__c updatedLoanAccount = queryLoan('TestClassGuid0');
        System.assertEquals('Dismiss',updatedLoanAccount.Bankruptcy_Status__c,'Bankruptcy_Status__c should be auto populated to Dismiss');

        Test.stopTest();
    }
    @isTest
    static void testBankruptcyRequiredFieldsSkipAgentProcessedDate() {
        Test.startTest();

        loan__loan_account__c loanAcc = queryLoan('TestClassGuid0');
        loanAcc = updateFullBankruptcyFields(loanAcc);
        loanAcc.Bankruptcy_Status__c = 'Pending Retention';
        loanAcc.File_Date__c = null;
        update loanAcc;
        
        // Verify the updated loan accounts
        loan__Loan_Account__c updatedLoanAccount = queryLoan('TestClassGuid0');
        System.assertEquals(null,updatedLoanAccount.Agent_Processed_Date__c,'Agent Processed Date should be skip when status not Active,Dismiss or Discharge');

        Test.stopTest();
    }

    @isTest
    static void testVerificationTeamPermisison() {
        User usr = MW_GlobalTestUtility.createUserWithProfile('Membership Team Advocate');
        User usr2 = MW_GlobalTestUtility.createUserWithProfile('Membership Team Lead');
        User usr3 = MW_GlobalTestUtility.createUserWithProfile('Membership Team Manager');
        User usr4 = MW_GlobalTestUtility.createUserWithProfile('Verification Specialist');
        User usr5 = MW_GlobalTestUtility.createUserWithProfile('Verification Team Lead');
        User usr6 = MW_GlobalTestUtility.createUserWithProfile('Verification Team Mgr');
        User usr7 = MW_GlobalTestUtility.createUserWithProfile('Verification Team Sr Specialist');
        User usr8 = MW_GlobalTestUtility.createUserWithProfile('Verification Team Specialist');

        List<User> userList = new List<User>();
        userList.add(usr);
        userList.add(usr2);
        userList.add(usr3);
        userList.add(usr4);
        userList.add(usr5);
        userList.add(usr6);
        userList.add(usr7);
        userList.add(usr8);
        insert userList;

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Collection_Team_Field_Visibility']; 
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        assignments.add(new PermissionSetAssignment(AssigneeId = usr.Id, PermissionSetId = ps.Id));
        assignments.add(new PermissionSetAssignment(AssigneeId = usr2.Id, PermissionSetId = ps.Id));
        insert assignments;

        String message = 'should be user:';
        Test.startTest();
        System.runAs(usr) {
            
            loan__loan_account__c loanAcc = queryLoan('TestClassGuid0');
            loanAcc = updateFullBankruptcyFields(loanAcc);
            loanAcc.POC_Deadline_Date__c= System.today();
            loanAcc.POC_Completed_Date__c = System.today();
            update loanAcc;
            loan__Loan_Account__c updatedLoanAccount = queryLoan('TestClassGuid0');
            System.assertEquals(usr.Id, updatedLoanAccount.Agent_Name_Completed_POC__c, message + usr.Id);
        }
        System.runAs(usr2) {
            loan__loan_account__c loanAcc = queryLoan('TestClassGuid0');
            loanAcc = updateFullBankruptcyFields(loanAcc);
            loanAcc.POC_Completed_Date__c = System.today().addDays(-1);
            loanAcc.File_Date__c = System.today().addDays(-1);
            loanAcc.POC_Deadline_Date__c= System.today().addDays(-1);
            update loanAcc;
            
            loan__Loan_Account__c updatedLoanAccount = queryLoan('TestClassGuid0');
            System.assertEquals(usr2.Id, updatedLoanAccount.Agent_Name_Completed_POC__c, message + usr2.Id);

        }
        try {
            System.runAs(usr3) {
                loan__loan_account__c loanAcc = queryLoan('TestClassGuid0');
                loanAcc = updateFullBankruptcyFields(loanAcc);
                loanAcc.POC_Completed_Date__c = System.today().addDays(-1);
                loanAcc.File_Date__c = System.today().addDays(-1);
                loanAcc.POC_Deadline_Date__c= System.today().addDays(-1);
                update loanAcc;
            }
            
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    static loan__Loan_Account__c updateFullBankruptcyFields(loan__loan_account__c loanAcc) {
        loanAcc.Bankruptcy_Status__c = BANKRUPTCY_STATUS_ACTIVE;
        loanAcc.Chapter__c=CHAPTER_13;
        loanAcc.Attorney_Name__c = ATTORNEY_NAME;
        loanAcc.Attorney_Phone__c = ATTORNEY_PHONE;
        loanAcc.Retention_Confirmed__c = RETENTION_NOT_CONFIRMED;
        loanAcc.File_Date__c = System.today();

        return loanAcc;
    }

    
    
    static loan__Loan_Account__c queryLoan(String leadGuid) {
        return [SELECT Agent_Name_Completed_POC__c,
                Bankruptcy_Status__c,
                Attorney_Name__c,
                Attorney_Phone__c,
                Retention_Confirmed__c,
                Agent_Processed_Date__c,
                File_Date__c,
                POC_Required__c
                FROM loan__Loan_Account__c
                WHERE lead_guid__c =:leadGuid limit 1];
    }
}