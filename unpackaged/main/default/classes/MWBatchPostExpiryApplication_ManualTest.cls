@isTest
private class MWBatchPostExpiryApplication_ManualTest {

    @isTest static void MWRunBatchJob() {
        Set<String> appStatus = new Set<String>{'Decline_Manual_Review','Expired','Declined','Expired-Withdrawn'};

        //setup for system date
        loanSetup();

        //setup custom settings
        customSettingSetup();

        //Setup Account
        Date currentSystemDate = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
        List<account> accList = MW_DataFactoryTest.createAccounts(1);
        insert accList;

        List<genesis__Applications__c> appList = MW_DataFactoryTest.createApplication(4, accList[0].Id);
        appList[0].genesis__Status__c = 'Expired';
        appList[1].genesis__Status__c = 'Declined';
        appList[3].genesis__Status__c = 'Expired-Withdrawn';
        appList[1].Application_Start_DateV2__c = currentSystemDate;
        appList[2].genesis__Status__c = 'Decline_Manual_Review';
        appList[2].Last_Investor_Assigned_On__c = DateTime.newInstance(currentSystemDate.year(), currentSystemDate.month(), currentSystemDate.day());
        insert appList;

        Test.startTest();

        //setup decline user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User usr = new User(Alias = 'standt', Email='standarduser@happymoney.com',
                EmailEncodingKey='UTF-8', LastName='Declined', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@happymoneytestorg.com');
        insert usr ;
        System.runAs(usr)
        {
            appList[1].ownerId = usr.Id;
            appList[2].ownerId = usr.Id;
            update appList;
        }

        //run batch
        MWBatchPostExpiryApplication_Manual obj = new MWBatchPostExpiryApplication_Manual(string.valueOf(currentSystemDate), appStatus);
        DataBase.executeBatch(obj);
        Test.stopTest();
    }

    private static void customSettingSetup(){
        Expiry_Date__c customSetting = new Expiry_Date__c();
        customSetting.No_of_days_for_Expiration__c = 0;
        insert customSetting;
    }

    private static void loanSetup(){
        clcommon__Party_Type__c pt = new clcommon__Party_Type__c();
        pt.name = 'Borrower';
        insert pt;

        //Document category
        genesis__Document_Category__c dc = new genesis__Document_Category__c();
        dc.genesis__Responsible_Party_Type__c = pt.id;
        dc.genesis__Applicable_For__c = 'PARTY';
        insert dc;

        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();

        //Dummy GLAccount
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');

        //Dummy Office insert
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();

        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);

        //Creating Conpany
        genesis__Company__c comp = genesis.TestHelper.createCompany();
        comp.Name = 'payoff';
        update comp;

        //creating lending product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice, dummyAccount, curr, dummyFeeSet);

        //creating CL Product
        clcommon__CL_Product__c pr = new clcommon__CL_Product__c();
        pr.loan__Lending_Product__c = dummyLp.id;
        pr.clcommon__Product_Name__c = 'P1';
        insert pr;
    }

}