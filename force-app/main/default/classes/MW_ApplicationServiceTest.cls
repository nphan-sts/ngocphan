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
    
     @isTest static void TestPifLoanUpdates2(){
    

    test.startTest();
	genesis__Applications__c appForDuplicateAct2 = [SELECT Id, Name, Bureau_SSN__c, genesis__Status__c, genesis__Account__c FROM genesis__Applications__c WHERE genesis__Account__r.Name = 'ActWithDuplicate Ssn2' LIMIT 1];
  
    Account preExistAct = [SELECT Id, Name, loan__SOCIAL_SECURITY_NUMBER__c FROM Account WHERE Name = 'PreExist Act2' LIMIT 1];

    Account actWithDuplicateSsn = [SELECT Id, Name, loan__SOCIAL_SECURITY_NUMBER__c FROM Account WHERE Name = 'ActWithDuplicate Ssn' LIMIT 1];

    appForDuplicateAct2.genesis__Status__c = 'kba_fail';
    Update appForDuplicateAct2;
	Test.stopTest();
   
   
     Account ActWithDuplicate = [SELECT Id, Name, loan__SOCIAL_SECURITY_NUMBER__c FROM Account WHERE Name = 'ActWithDuplicate Ssn2' LIMIT 1];
	 
	 system.assertEquals(ActWithDuplicate.loan__SOCIAL_SECURITY_NUMBER__c,appForDuplicateAct2.Bureau_SSN__c);
  }

  @isTest static void TestUpdateAccounts(){
    genesis__Applications__c app = [SELECT Id, Annual_Individual_Income_App__c, Monthly_Housing_Payment_App__c, genesis__Status__c, genesis__Account__c, 
                                    genesis__Account__r.Annual_Individual_Income__c,genesis__Account__r.Monthly_Housing_Payment__c FROM genesis__Applications__c 
                                                   WHERE genesis__Account__r.peer__First_Name__c ='PreExist' LIMIT 1];
    
    System.AssertEquals(app.Annual_Individual_Income_App__c, app.genesis__Account__r.Annual_Individual_Income__c,'Income on Account updated after app insert');
    System.AssertEquals(app.Monthly_Housing_Payment_App__c, app.genesis__Account__r.Monthly_Housing_Payment__c,'Housing payment on Account updated after app insert');

    app.Annual_Individual_Income_App__c = 110000;
    app.Monthly_Housing_Payment_App__c = 750;
    update app;

    app = [SELECT Id, Annual_Individual_Income_App__c, Monthly_Housing_Payment_App__c, genesis__Status__c, genesis__Account__c, 
                                    genesis__Account__r.Annual_Individual_Income__c,genesis__Account__r.Monthly_Housing_Payment__c FROM genesis__Applications__c 
                                     WHERE Id =: app.Id LIMIT 1];

    System.assertEquals(110000, app.genesis__Account__r.Annual_Individual_Income__c,'Income on Account updated after app update');
    System.assertEquals(750, app.genesis__Account__r.Monthly_Housing_Payment__c,'Housing payment on Account updated after app update');
    
  }
}