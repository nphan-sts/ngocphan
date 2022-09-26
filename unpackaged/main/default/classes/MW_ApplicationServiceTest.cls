/*
Include existing test class - 'TestCustomTriggerOnApplication.cls' as well for increasing coverage. 
Mohan Kiran - 09/26/2022 - Made changes to fix test failures.
*/
@isTest
private class MW_ApplicationServiceTest {
    @testSetup 
    static void setup(){
        
        test.startTest();
        
        //Create pre-exist account
        Account preExistAct = MW_GlobalTestUtility.GetAccount('Member');
        //preExistAct.Name = 'PreExistAct';
        preExistAct.peer__First_Name__c ='PreExist';
        preExistAct.peer__Last_Name__c = 'Act';
        Insert preExistAct;
        System.debug('preExistAct=' + preExistAct);
        
        //Create app for pre-exist account
        genesis__Applications__c appForPreExistAct = MW_GlobalTestUtility.GetApplication();
        appForPreExistAct.genesis__Account__c = preExistAct.Id;
        appForPreExistAct.Bureau_SSN__c = preExistAct.loan__SOCIAL_SECURITY_NUMBER__c;
        Insert appForPreExistAct;
        
        //Create Loan for pre-exist account
        loan.TestHelper.createSeedDataForTesting();
        loan__Office_Name__c office = loan.TestHelper.createOffice();
        loan__Loan_Product__c loanProd = MW_GlobalTestUtility.GetLoanProduct(); 
        insert loanProd;
        
        loan__Loan_Account__c loanForPreExistAcct = MW_GlobalTestUtility.GetCLContract();
        loanForPreExistAcct.loan__Account__c= preExistAct.Id;
        loanForPreExistAcct.loan__Loan_Product_Name__c=loanProd.Id;
        loanForPreExistAcct.application__c = appForPreExistAct.id;
        loanForPreExistAcct.loan__Loan_Status__c = 'Closed - Obligations met'; //'Active - Good Standing';
        Insert loanForPreExistAcct;
        
        //Create one more Account
        Account actWithDuplicateSsn = MW_GlobalTestUtility.GetAccount('Member');
        //actWithDuplicateSsn.Name = 'ActWithDuplicateSsn';
        actWithDuplicateSsn.peer__First_Name__c ='ActWithDuplicate';
        actWithDuplicateSsn.peer__Last_Name__c = 'Ssn';
        actWithDuplicateSsn.loan__SOCIAL_SECURITY_NUMBER__c = null;
        actWithDuplicateSsn.social_security_number_uniqueness_field__c = '123987123';
        Insert actWithDuplicateSsn;
        
        //Create app for one more account with duplicate SSN
        genesis__Applications__c appForDuplicateAct = MW_GlobalTestUtility.GetApplication();
        appForDuplicateAct.genesis__Account__c = actWithDuplicateSsn.Id;
        appForDuplicateAct.Bureau_SSN__c = actWithDuplicateSsn.loan__SOCIAL_SECURITY_NUMBER__c;
        appForDuplicateAct.genesis__Status__c = null;
        appForDuplicateAct.LEAD_ID__C = 'c9149473-e69f-ee12-38a7-d18b0cba847z';
        Insert appForDuplicateAct;
        
        loan__Loan_Product__c loanProd1 = MW_GlobalTestUtility.GetLoanProduct(); 
        loanProd1.name = 'TestProductNew';
        insert loanProd1;
        
        loan__Loan_Account__c loanForDuplicateSSN = MW_GlobalTestUtility.GetCLContract();
        loanForDuplicateSSN.loan__Account__c= actWithDuplicateSsn.Id;
        loanForDuplicateSSN.loan__Loan_Product_Name__c=loanProd1.Id;
        loanForDuplicateSSN.application__c = appForDuplicateAct.id;
        loanForDuplicateSSN.loan__Loan_Status__c = 'Closed - Obligations met'; 
        loanForDuplicateSSN.lead_guid__c = 'TestClassGuid01';
        Insert loanForDuplicateSSN;
        
        Account preExistAct2 = MW_GlobalTestUtility.GetAccount('Member');
        //preExistAct2.Name = 'preExistAct2';
        preExistAct2.peer__First_Name__c ='PreExist';
        preExistAct2.peer__Last_Name__c = 'Act2';
        //preExistAct2.social_security_number_uniqueness_field__c = '';
        Insert preExistAct2;
        
        //Create one more Account
        Account actWithDuplicateSsn2 = MW_GlobalTestUtility.GetAccount('Member');
        //actWithDuplicateSsn2.Name = 'actWithDuplicateSsn2';
        actWithDuplicateSsn2.peer__First_Name__c ='ActWithDuplicate';
        actWithDuplicateSsn2.peer__Last_Name__c = 'Ssn2';
        actWithDuplicateSsn2.loan__SOCIAL_SECURITY_NUMBER__c = null;
        Insert actWithDuplicateSsn2;
        
        //Create app for one more account with duplicate SSN
        genesis__Applications__c appForDuplicateAct2 = MW_GlobalTestUtility.GetApplication();
        appForDuplicateAct2.genesis__Account__c = actWithDuplicateSsn2.Id;
        appForDuplicateAct2.Bureau_SSN__c = preExistAct2.loan__SOCIAL_SECURITY_NUMBER__c;
        appForDuplicateAct2.genesis__Status__c = null;
        Insert appForDuplicateAct2;
        
        Test.stopTest();
    }
    
    @isTest static void TestPifLoanUpdates(){
        test.startTest();
        genesis__Applications__c appForDuplicateAct2 = [SELECT Id, Name, Bureau_SSN__c, genesis__Status__c, genesis__Account__c FROM genesis__Applications__c WHERE genesis__Account__r.Name = 'ActWithDuplicate Ssn2' LIMIT 1];
        appForDuplicateAct2.Required_Docs_Count__c=0;
        appForDuplicateAct2.genesis__Status__c = 'offer_shown';
        update appForDuplicateAct2;
        
        list<genesis__Applications__c> appList = new list<genesis__Applications__c>();
        Account preExistAct = [SELECT Id, Name, loan__SOCIAL_SECURITY_NUMBER__c FROM Account WHERE Name = 'PreExist Act2' LIMIT 1];
        
        Account actWithDuplicateSsn = [SELECT Id, Name, loan__SOCIAL_SECURITY_NUMBER__c FROM Account WHERE Name = 'ActWithDuplicate Ssn' LIMIT 1];
        
        appForDuplicateAct2.BoxFolderID__c = null;
        appForDuplicateAct2.genesis__Status__c = 'NEW - ENTERED';
        appForDuplicateAct2.genesis__CL_Product__c = null;
        appList.add(appForDuplicateAct2);
        
        MW_ApplicationService.updateBoxFolder(appList);
        MW_ApplicationService.PostAccounts(preExistAct,actWithDuplicateSsn);
        
        
        Test.stopTest();
        
        Account actwithDuplicate = [SELECT Id, Name, loan__SOCIAL_SECURITY_NUMBER__c FROM Account WHERE Name = 'ActWithDuplicate Ssn2' LIMIT 1];
        
        
        system.assertEquals(appForDuplicateAct2.genesis__Status__c,'Default Documents');
        system.assertEquals(appForDuplicateAct2.BoxFolderID__c,null);
        system.assertEquals(appForDuplicateAct2.Required_Docs_Count__c,0);
        
    }
    @isTest static void testExistingDupeAccts(){
        
        
        test.startTest();
        genesis__Applications__c appForDuplicateAct2 = [SELECT Id, Name, Bureau_SSN__c, genesis__Status__c, genesis__Account__c FROM genesis__Applications__c WHERE genesis__Account__r.Name = 'ActWithDuplicate Ssn2' LIMIT 1];
        appForDuplicateAct2.Bureau_SSN__c = '123987123';
        appForDuplicateAct2.genesis__Status__c = 'kba_fail';
        
        
        Account preExistAct = [SELECT Id, Name, loan__SOCIAL_SECURITY_NUMBER__c FROM Account WHERE Name = 'PreExist Act2' LIMIT 1];
        appForDuplicateAct2.genesis__Account__c = preExistAct.id;
        Update appForDuplicateAct2;
        
        Account actWithDuplicateSsn = [SELECT Id, Name, loan__SOCIAL_SECURITY_NUMBER__c FROM Account WHERE Name = 'ActWithDuplicate Ssn' LIMIT 1];
        
        
        Test.stopTest();
        
        
        Account actwithDuplicate = [SELECT Id, Name, loan__SOCIAL_SECURITY_NUMBER__c FROM Account WHERE Name = 'ActWithDuplicate Ssn2' LIMIT 1];
        
        system.assertEquals(appForDuplicateAct2.Bureau_SSN__c,'123987123');
        system.assertEquals(appForDuplicateAct2.genesis__Status__c,'kba_fail');
        
    }
}