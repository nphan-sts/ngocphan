@isTest
private class ActivityOnOtherAccountsControllerTest {
  @testSetup 
  static void setup(){

    test.startTest();
    
    //Create pre-exist account
    Account preExistAct = MW_GlobalTestUtility.GetAccount('Member');
    //preExistAct.Name = 'PreExist Act';
    preExistAct.peer__First_Name__c ='PreExist';
    preExistAct.peer__Last_Name__c = 'Act';
    Insert preExistAct;

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
    loanForPreExistAcct.loan__Loan_Status__c = 'Active - Good Standing'; //'Closed - Obligations met';
    Insert loanForPreExistAcct;

    //Create one more Account
    Account actWithDuplicateSsn = MW_GlobalTestUtility.GetAccount('Member');
    //actWithDuplicateSsn.Name = 'ActWithDuplicate Ssn';
    actWithDuplicateSsn.peer__First_Name__c ='ActWithDuplicate';
    actWithDuplicateSsn.peer__Last_Name__c = 'Ssn';
    Insert actWithDuplicateSsn;

    //Create app for one more account with duplicate SSN
    genesis__Applications__c appForDuplicateAct = MW_GlobalTestUtility.GetApplication();
    appForDuplicateAct.genesis__Account__c = actWithDuplicateSsn.Id;
    appForDuplicateAct.Bureau_SSN__c = preExistAct.loan__SOCIAL_SECURITY_NUMBER__c;
    Insert appForDuplicateAct;

    Test.stopTest();
  }
  
  @isTest static void TestActivities(){
    //call controller          
    Account actWithDuplicateSsn = [SELECT Id, Name, loan__SOCIAL_SECURITY_NUMBER__c FROM Account WHERE Name = 'ActWithDuplicate Ssn' LIMIT 1];
    ActivityOnOtherAccountsController actyOnOtherAcct = new ActivityOnOtherAccountsController();
    actyOnOtherAcct.AcctId = actWithDuplicateSsn.Id;
    actyOnOtherAcct.PopulateAcctActivities();

    System.AssertEquals(true, actyOnOtherAcct.IsAcctActivitiesExist);
  }
}