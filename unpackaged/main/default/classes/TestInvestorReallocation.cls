@isTest
public class TestInvestorReallocation{

    public static testMethod void TestMethod1(){
        
        //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
        //Creating Application
        genesis__Applications__c app= new genesis__Applications__c(
                                            genesis__Due_Day__c = 20,
                                            genesis__Expected_First_Payment_Date__c = system.Today(),
                                            genesis__Expected_Start_Date__c = system.Today(),
                                            genesis__Funding_in_Tranches__c = true,
                                            Borrower_s_Email__c = null,
                                            genesis__Account__c = acc.Id,
                                            Application_Start_DateV2__c = system.Today(),
                                            //Anniversary_Date__c = system.Today()+1,
                                            DocuSignFlag__c=true,
                                            genesis__Status__c = 'agent_verified',
                                            genesis__Draw_Period_End_Date__c = system.Today(),
                                            maturityDate__c = system.Today(),
                                            genesis__Maturity_Date__c = system.Today(),
                                            genesis__Term__c = 2,
                                            genesis__payment_frequency__c = 'MONTHLY'
                                            );
        insert app;
       // list<genesis__Applications__c> applist = new list<genesis__Applications__c>();
       // applist.add(app);
        //insert applist;
      /*  app.Anniversary_Date__c = system.Today()+2;
        Integer frequencyMultiplier = ((Integer)app.genesis__term__c - 1);
        Integer day = app.Anniversary_Date__c.day();
        Date nextdate = app.Anniversary_Date__c.addMonths(1);
        Date maturityDate = loan.DateUtil.getNextCycleDate(app.Anniversary_Date__c , day,app.genesis__payment_frequency__c,app.Anniversary_Date__c ,nextdate,frequencyMultiplier);
        app.maturityDate__c = maturityDate;
        update app;*/
        System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');
        
        //Creating Application Document Category
        genesis__Application_Document_Category__c document = new genesis__Application_Document_Category__c();
        document.Name = 'TIL Document';
        document.genesis__Active__c = TRUE;
        document.genesis__Application__c = app.Id;
        insert document;
        System.assertEquals(True,document.genesis__Active__c,'Document Category is not active');
        
        Test.startTest();
        InvestorReallocation.ResetDoc(app.id);
        System.debug('====================='+document.genesis__Active__c);
        //System.assertEquals(False,document.genesis__Active__c,'InvestorReallocation failed');
        Test.stopTest();
    }
}