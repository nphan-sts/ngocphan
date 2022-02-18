@isTest
public class TestQueueAssignment{
    @testSetup
    static void setupTestData(){
        
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
        
        loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
        org.loan__Disable_Triggers__c = true;
        upsert org;  
        
        //Creating Account
        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            peer__Last_Name__c = 'abc',
            peer__First_Name__c = 'def'
            //loan__SOCIAL_SECURITY_NUMBER__c = '123'
        );
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
        //Creating Application
        genesis__Applications__c app= new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_Start_Date__c = system.today(),
            genesis__Account__c = acc.Id,
            Affiliate_Partner__c =true,
            Sift_Status__c = 80
        );
        insert app;
        
        
        KBA_Details__c kba = new KBA_Details__c();
        kba.Application__c = app.id;
        kba.Precise_ID_Overall_SCore__c =9013;
        kba.Precise_ID_First_Payment_Default__c =9013;
        kba.Precise_ID_ID_Theft__c =9013;
        kba.Precise_ID_Validation__c =9013;
        kba.Precise_ID_General_Fraud_Shield_Indicat__c = 'F05';
        kba.KBA_Attempts__c = 6;
        kba.Paste_Count__c = 3;
        kba.Id_Analytics_Score__c =800;
        kba.Precise_ID_Adverse_Action_Code__c='R91';
        insert kba;
        
        Identity_Verification__c idv= new Identity_Verification__c();
        idv.Application__c = app.id;
        idv.IDMA_Status__c = 'Accept';
        idv.Bank_Verification_Flag__c= 'PASS';
        idv.Deal_room_Verification_Flag__c = 'PASS';
        idv.Identity_Verification__c ='PASS';
        idv.Income_Verification_Flag__c = 'PASS';
        idv.Neo_Verification_Flag__c ='PASS';
        idv.KBA_Verification_Flag__c = 'PASS';
        idv.Credit_Policy_Verification_Flag__c ='PASS';
        insert idv;
        
        idv.Precise_Identity_Screening_Status__c = 'Not Performed';
        update idv;
        
        
        MW_Settings__c mwsetting = MW_Settings__c.getOrgDefaults();
        mwsetting.Sift_score__c = 98;
        insert mwsetting;
    }
    
    Testmethod static void FraudbasedOnIDMAStatus(){
        Account acc1 = [select id from Account Limit 1];
        genesis__Applications__c app1 =[select id,genesis__Account__c,Sift_Status__c from genesis__Applications__c where genesis__Account__c =: acc1.id Limit 1];
        
        app1.Sift_Status__c = 100;
        List<Id> appIdlist = new List<Id>();
        appIdlist.add(app1.id);
        KBA_Details__c kba1 = [select id,
                               Application__c,
                               Precise_ID_Overall_SCore__c,
                               KBA_Attempts__c
                               from KBA_Details__c
                               where Precise_ID_Overall_SCore__c=9013 Limit 1];
        
        Identity_Verification__c idv1 = [select id, IDMA_Status__c,Identity_Verification__c from Identity_Verification__c where IDMA_Status__c ='Accept' limit 1];  
        idv1.Identity_Verification__c = 'PASS';
        update idv1;
        Test.startTest();
        QueueAssignment.appToQueueAssignment(appIdlist);
        Test.stopTest();
        List<Application_Tags__c> appTags = [SELECT Application_Tag__c FROM Application_Tags__c where Application__c = :app1.Id];
        System.assertEquals(appTags[0].Application_Tag__c, 'Fraud', 'Fraud tag been assigned');
    }
    
    Testmethod static void FraudbasedOnSiftStatus(){
        Account acc1 = [select id from Account Limit 1];
        genesis__Applications__c app1 =[select id,genesis__Account__c,Sift_Status__c from genesis__Applications__c where genesis__Account__c =: acc1.id Limit 1];
        app1.Sift_Status__c = 100;
        
        KBA_Details__c kba1 = [select id,
                               Application__c,
                               Precise_ID_Overall_SCore__c,
                               KBA_Attempts__c
                               from KBA_Details__c
                               where Precise_ID_Overall_SCore__c=9013 Limit 1];
        kba1.Precise_ID_General_Fraud_Shield_Indicat__c = null;
        kba1.KBA_Attempts__c =null;
        kba1.Paste_Count__c = null;
        kba1.Id_Analytics_Score__c =null;
        kba1.Precise_ID_Adverse_Action_Code__c=null;
        update kba1;
        Identity_Verification__c idv1 = [select id, IDMA_Status__c,Identity_Verification__c from Identity_Verification__c where IDMA_Status__c ='Accept' limit 1];  
        idv1.Identity_Verification__c = 'PASS';
        update idv1;
        update app1;
        List<Id> appIdlist = new List<Id>();
        appIdlist.add(app1.id);
        Test.startTest();
        QueueAssignment.appToQueueAssignment(appIdlist);
        Test.stopTest();
        List<Application_Tags__c> appTags = [SELECT Application_Tag__c FROM Application_Tags__c where Application__c = :app1.Id];
        System.assertEquals(appTags[0].Application_Tag__c, 'Fraud', 'Fraud tag been assigned');
    }
    
    Testmethod static void FraudBasedOnPreciseIdScores(){
        Account acc1 = [select id from Account Limit 1];
        genesis__Applications__c app1 =[select id,genesis__Account__c,Sift_Status__c from genesis__Applications__c where genesis__Account__c =: acc1.id Limit 1];
        app1.Affiliate_Partner__c = true;
        app1.Sift_Status__c = 10;
        update app1;
        List<Id> appIdlist = new List<Id>();
        appIdlist.add(app1.id);
        KBA_Details__c kba1 = [select id,
                               Application__c,
                               Precise_ID_Overall_SCore__c,
                               KBA_Attempts__c
                               from KBA_Details__c
                               where Application__c=: app1.id Limit 1];
        kba1.Precise_ID_Overall_SCore__c = 9013;
        kba1.Precise_ID_First_Payment_Default__c = 9013;
        kba1.Precise_ID_ID_Theft__c = 9013;
        kba1.Precise_ID_Validation__c = 9013;
        kba1.Id_Analytics_Score__c =800;
        update kba1;
        
        Identity_Verification__c idv1 = [select id, IDMA_Status__c from Identity_Verification__c where IDMA_Status__c ='Accept' limit 1];  
        Test.startTest();
        QueueAssignment.appToQueueAssignment(appIdlist);
        Test.stopTest();
        genesis__Applications__c resultApp = [SELECT Fraud_Assignment_Reason__c FROM genesis__Applications__c where Id =: app1.Id];
        System.assertNotEquals(resultApp.Fraud_Assignment_Reason__c, null, 'Fraud reason is being set as '+ resultApp.Fraud_Assignment_Reason__c);
    }
    
    Testmethod static void FraidBasedONFraidSheieldIndicat(){
        Account acc1 = [select id from Account Limit 1];
        genesis__Applications__c app1 =[select id,genesis__Account__c,Sift_Status__c from genesis__Applications__c where genesis__Account__c =: acc1.id Limit 1];
        app1.Affiliate_Partner__c = true;
        app1.Sift_Status__c = 10;
        update app1;
        List<Id> appIdlist = new List<Id>();
        appIdlist.add(app1.id);
        KBA_Details__c kba1 = new KBA_Details__c();
        kba1.Application__c = app1.id;
        kba1.Id_Analytics_Score__c =740;
        kba1.Precise_ID_Overall_SCore__c = 9001;
        kba1.Precise_ID_First_Payment_Default__c = 9001;
        kba1.Precise_ID_ID_Theft__c = 9001;
        kba1.Precise_ID_Validation__c = 9001;
        kba1.Precise_ID_General_Fraud_Shield_Indicat__c= 'Consumer reported as deceased';
        insert kba1;
        
        Test.startTest();
        QueueAssignment.appToQueueAssignment(appIdlist);
        Test.stopTest();
        genesis__Applications__c resultApp = [SELECT Fraud_Assignment_Reason__c FROM genesis__Applications__c where Id =: app1.Id];
        System.assertNotEquals(resultApp.Fraud_Assignment_Reason__c, null, 'Fraud reason is being set as '+ resultApp.Fraud_Assignment_Reason__c);
    }
    Testmethod static void FraudBasedOnKBAAttempts(){
        Account acc1 = [select id from Account Limit 1];
        genesis__Applications__c app1 =[select id,genesis__Account__c,Sift_Status__c from genesis__Applications__c where genesis__Account__c =: acc1.id Limit 1];
        app1.Sift_Status__c = 10;
        update app1;
        List<Id> appIdlist = new List<Id>();
        appIdlist.add(app1.id);
        KBA_Details__c kba1 = [select id,
                               Application__c,
                               Precise_ID_Overall_SCore__c,
                               KBA_Attempts__c,
                               Paste_Count__c
                               from KBA_Details__c
                               where Precise_ID_Overall_SCore__c=9013 Limit 1];
        kba1.KBA_Attempts__c = 5;
        kba1.Paste_Count__c = 2;
        update kba1;
        Identity_Verification__c idv1 = [select id, IDMA_Status__c from Identity_Verification__c where IDMA_Status__c ='Accept' limit 1];  
        Test.startTest();
        QueueAssignment.appToQueueAssignment(appIdlist);
        Test.stopTest();
        genesis__Applications__c resultApp = [SELECT Fraud_Assignment_Reason__c FROM genesis__Applications__c where Id =: app1.Id];
        System.assertNotEquals(resultApp.Fraud_Assignment_Reason__c, null, 'Fraud reason is being set as '+ resultApp.Fraud_Assignment_Reason__c);
    }
    Testmethod static void FraudBasedOnPasteCountAndShieldIndicat(){
        Account acc1 = [select id from Account Limit 1];
        genesis__Applications__c app1 =[select id,genesis__Account__c,Sift_Status__c from genesis__Applications__c where genesis__Account__c =: acc1.id Limit 1];
        app1.Sift_Status__c = 10;
        app1.Affiliate_Partner__c = true;
        update app1;
        List<Id> appIdlist = new List<Id>();
        appIdlist.add(app1.id);
        KBA_Details__c kba1 = new KBA_Details__c();
        kba1.Application__c = app1.id;
        kba1.Id_Analytics_Score__c =760;
        kba1.Precise_ID_General_Fraud_Shield_Indicat__c = 'F05';
        kba1.Paste_Count__c = 2;
        insert kba1;
        
        Test.startTest();
        QueueAssignment.appToQueueAssignment(appIdlist);
        Test.stopTest();
        genesis__Applications__c resultApp = [SELECT Fraud_Assignment_Reason__c FROM genesis__Applications__c where Id =: app1.Id];
        System.assertNotEquals(resultApp.Fraud_Assignment_Reason__c, null, 'Fraud reason is being set as '+ resultApp.Fraud_Assignment_Reason__c);
    }
    
    Testmethod static void FraudBasedonUTMMediumAndSource(){
        Account acc1 = [select id from Account Limit 1];
        genesis__Applications__c app1 =[select id,genesis__Account__c,Sift_Status__c, utm_medium__c from genesis__Applications__c where genesis__Account__c =: acc1.id Limit 1];
        
        app1.utm_medium__c = 'partner';
        app1.utm_source__c = 'creditkarma';
        app1.Sift_Status__c = 10;
        app1.Affiliate_Partner__c = false;
        update app1;
        List<Id> appIdlist = new List<Id>();
        appIdlist.add(app1.id);
        KBA_Details__c kba1 = new KBA_Details__c();
        kba1.Application__c = app1.id;
        kba1.Id_Analytics_Score__c =800;
        kba1.Paste_Count__c = null;
        kba1.Precise_ID_Overall_SCore__c = null;
        kba1.Precise_ID_ID_Theft__c = null;
        kba1.Precise_ID_Validation__c = null;
        kba1.Precise_ID_First_Payment_Default__c = null;
        kba1.Precise_ID_Overall_SCore__c = null;
        kba1.Precise_ID_First_Payment_Default__c = null;
        kba1.Precise_ID_ID_Theft__c = null;
        kba1.Precise_ID_Validation__c = null;
        kba1.Precise_ID_General_Fraud_Shield_Indicat__c = null;
        insert kba1;    
        Test.startTest();
        QueueAssignment.appToQueueAssignment(appidlist); 
        Test.stopTest();
        genesis__Applications__c resultApp = [SELECT Fraud_Assignment_Reason__c FROM genesis__Applications__c where Id =: app1.Id];
        System.assertNotEquals(resultApp.Fraud_Assignment_Reason__c, null, 'Fraud reason is being set as '+ resultApp.Fraud_Assignment_Reason__c);
    } 
    
    Testmethod static void FraudBasedonUTMMediumBlank(){
        Account acc1 = [select id from Account Limit 1];
        genesis__Applications__c app1 =[select id,genesis__Account__c,Sift_Status__c from genesis__Applications__c where genesis__Account__c =: acc1.id Limit 1];
        app1.utm_medium__c = '';
        app1.utm_source__c = 'creditkarma';
        app1.Affiliate_Partner__c = false;
        app1.Sift_Status__c = 10;
        update app1;
        List<Id> appIdlist = new List<Id>();
        appIdlist.add(app1.id);
        KBA_Details__c kba1 = new KBA_Details__c();
        kba1.Application__c = app1.id;
        kba1.Id_Analytics_Score__c = 900;
        kba1.Precise_ID_General_Fraud_Shield_Indicat__c = null;
        kba1.paste_count__c = null;
        insert kba1;
        
        Test.startTest();
        QueueAssignment.appToQueueAssignment(appIdlist);
        Test.stopTest();
        genesis__Applications__c resultApp = [SELECT Fraud_Assignment_Reason__c FROM genesis__Applications__c where Id =: app1.Id];
        System.assertNotEquals(resultApp.Fraud_Assignment_Reason__c, null, 'Fraud reason is being set as '+ resultApp.Fraud_Assignment_Reason__c);
    }
    
    Testmethod static void FraudBasedOnPreciseIdScoresInNegative(){
        Account acc1 = [select id from Account Limit 1];
        genesis__Applications__c app1 =[select id,genesis__Account__c,Sift_Status__c from genesis__Applications__c where genesis__Account__c =: acc1.id Limit 1];
        app1.utm_medium__c = null;
        app1.utm_source__c = null;
        app1.Sift_Status__c = 10;
        update app1;
        List<Id> appIdlist = new List<Id>();
        appIdlist.add(app1.id);
        KBA_Details__c kba1 = new KBA_Details__c();
        kba1.Application__c = app1.id;
        kba1.Id_Analytics_Score__c = 100;
        kba1.Precise_ID_General_Fraud_Shield_Indicat__c = 'F05';
        kba1.Paste_Count__c = 3;
        kba1.Precise_ID_Overall_SCore__c = -1;
        kba1.Precise_ID_ID_Theft__c = -1;
        kba1.Precise_ID_Validation__c = -1;
        kba1.Precise_ID_First_Payment_Default__c = -1;
        insert kba1;
        
        Test.startTest();
        QueueAssignment.appToQueueAssignment(appIdlist);
        Test.stopTest();
        genesis__Applications__c resultApp = [SELECT Fraud_Assignment_Reason__c FROM genesis__Applications__c where Id =: app1.Id];
        System.assertNotEquals(resultApp.Fraud_Assignment_Reason__c, null, 'Fraud reason is being set as '+ resultApp.Fraud_Assignment_Reason__c);
    }
    
    Testmethod static void KBAFraudBasedonUTMMediumDM(){
        Account acc1 = [select id from Account Limit 1];
        genesis__Applications__c app1 =[select id,genesis__Account__c,Sift_Status__c, utm_medium__c from genesis__Applications__c where genesis__Account__c =: acc1.id Limit 1];
        app1.Sift_Status__c = 10;
        app1.utm_medium__c = 'DM';
        app1.Affiliate_Partner__c = true;
        update app1;
        List<Id> appIdlist = new List<Id>();
        appIdlist.add(app1.id);
        KBA_Details__c kba1 = new KBA_Details__c();
        kba1.Application__c = app1.id;
        kba1.Id_Analytics_Score__c =760;
        kba1.Precise_ID_General_Fraud_Shield_Indicat__c = null;
        insert kba1;
        
        
        Test.startTest();
        QueueAssignment.appToQueueAssignment(appIdlist);
        Test.stopTest();
        genesis__Applications__c resultApp = [SELECT Fraud_Assignment_Reason__c FROM genesis__Applications__c where Id =: app1.Id];
        System.assertNotEquals(resultApp.Fraud_Assignment_Reason__c, null, 'Fraud reason is being set as '+ resultApp.Fraud_Assignment_Reason__c);
    } 
    
    Testmethod static void KBAFraudBasedonUTMMediumPartner(){
        Account acc1 = [select id from Account Limit 1];
        genesis__Applications__c app1 =[select id,genesis__Account__c,Sift_Status__c, utm_medium__c from genesis__Applications__c where genesis__Account__c =: acc1.id Limit 1];
        
        app1.utm_medium__c = 'partner';
        app1.Sift_Status__c = 10;
        app1.Affiliate_Partner__c = true;
        update app1;
        List<Id> appIdlist = new List<Id>();
        appIdlist.add(app1.id);
        KBA_Details__c kba1 = new KBA_Details__c();
        kba1.Application__c = app1.id;
        kba1.Id_Analytics_Score__c =800;
        kba1.Paste_Count__c = null;
        kba1.Precise_ID_General_Fraud_Shield_Indicat__c = null;
        insert kba1;    
        Test.startTest();
        QueueAssignment.appToQueueAssignment(appidlist); 
        Test.stopTest();
        genesis__Applications__c resultApp = [SELECT Fraud_Assignment_Reason__c FROM genesis__Applications__c where Id =: app1.Id];
        System.assertNotEquals(resultApp.Fraud_Assignment_Reason__c, null, 'Fraud reason is being set as '+ resultApp.Fraud_Assignment_Reason__c);
    } 
    
    Testmethod static void NonFraud(){
        Account acc1 = [select id from Account Limit 1];
        genesis__Applications__c app1 =[select id,genesis__Account__c,Sift_Status__c, utm_medium__c from genesis__Applications__c where genesis__Account__c =: acc1.id Limit 1];
        
        KBA_Details__c kba = [select Application__c,Precise_ID_Overall_SCore__c,
                                 Precise_ID_First_Payment_Default__c,
                                 Precise_ID_ID_Theft__c,
                                 Precise_ID_Validation__c,
                                 Precise_ID_General_Fraud_Shield_Indicat__c,
                                 Paste_Count__c,
                                 Precise_ID_Adverse_Action_Code__c,
                                 Id_Analytics_Score__c,
                                 KBA_Attempts__c
                                 from KBA_Details__c WHERE Application__c =: app1.Id order by createddate desc limit 1];
        kba.Paste_Count__c = null;
        kba.Id_Analytics_Score__c = 100;
        kba.KBA_Attempts__c = null;
        kba.Precise_ID_Overall_SCore__c = 9013;
        kba.Precise_ID_First_Payment_Default__c = null;
        kba.Precise_ID_ID_Theft__c = null;
        kba.Precise_ID_Validation__c = null;
        kba.Precise_ID_General_Fraud_Shield_Indicat__c = null;
        update kba;
        app1.utm_medium__c = null;
        app1.Sift_Status__c = 10;
        app1.Affiliate_Partner__c = false;
        update app1;
        List<Id> appIdlist = new List<Id>();
        appIdlist.add(app1.id);
        Test.startTest();
        QueueAssignment.appToQueueAssignment(appidlist); 
        Test.stopTest();
        genesis__Applications__c resultApp = [SELECT Fraud_Assignment_Reason__c FROM genesis__Applications__c where Id =: app1.Id];
        System.assertEquals(resultApp.Fraud_Assignment_Reason__c, null, 'Fraud reason is being set as '+ resultApp.Fraud_Assignment_Reason__c);
        System.assertEquals(QueueAssignment.KBAFraudT, false, 'No fraud tag being assigned');
    } 
    
}