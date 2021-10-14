/*
Include existing test class - 'TestCustomTriggerOnApplication.cls' as well for increasing coverage. 
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
    Insert actWithDuplicateSsn;

    //Create app for one more account with duplicate SSN
    genesis__Applications__c appForDuplicateAct = MW_GlobalTestUtility.GetApplication();
    appForDuplicateAct.genesis__Account__c = actWithDuplicateSsn.Id;
    appForDuplicateAct.Bureau_SSN__c = preExistAct.loan__SOCIAL_SECURITY_NUMBER__c;
    appForDuplicateAct.genesis__Status__c = null;
    Insert appForDuplicateAct;

    Test.stopTest();
  }
  
  @isTest static void TestPifLoanUpdates(){
    genesis__Applications__c appForDuplicateAct = [SELECT Id, Name, Bureau_SSN__c, genesis__Status__c, genesis__Account__c FROM genesis__Applications__c WHERE genesis__Account__r.Name = 'ActWithDuplicate Ssn' LIMIT 1];
    System.debug('appForDuplicateAct=' + appForDuplicateAct);
    appForDuplicateAct.genesis__Status__c = 'kba_fail';
    Update appForDuplicateAct;

    Account preExistAct = [SELECT Id, Name, loan__SOCIAL_SECURITY_NUMBER__c FROM Account WHERE Name = 'PreExist Act' LIMIT 1];

    Account actWithDuplicateSsn = [SELECT Id, Name, loan__SOCIAL_SECURITY_NUMBER__c FROM Account WHERE Name = 'ActWithDuplicate Ssn' LIMIT 1];

    loan__Loan_Account__c loanForPreExistAcct = [SELECT Id, loan__Account__c, loan__Loan_Status__c FROM loan__Loan_Account__c WHERE loan__Account__c =: actWithDuplicateSsn.Id LIMIT 1];

    //SSN moved to new Account
    System.AssertEquals(actWithDuplicateSsn.loan__SOCIAL_SECURITY_NUMBER__c, appForDuplicateAct.Bureau_SSN__c);

    //Closed loan moved to new Account
    System.AssertEquals(loanForPreExistAcct.loan__Account__c, actWithDuplicateSsn.Id);

    //Old Account's SSN has been set to NULL
    System.AssertEquals(true, String.isEmpty(PreExistAct.loan__SOCIAL_SECURITY_NUMBER__c));
  }  
}