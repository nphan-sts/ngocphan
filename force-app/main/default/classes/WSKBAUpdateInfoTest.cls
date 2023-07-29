@isTest
private class WSKBAUpdateInfoTest{
    
    //For New KBA_Details__c
    Testmethod static void updateKBAInfoTest_UseCase1(){   
        
        Account acc = new Account(
        Name = 'TestAcc',
        loan__Investor__c=false, 
        cnotify__Email__c='notify@testOrg.com'
        );
        Insert acc;
        System.assertEquals('TestAcc',acc.Name,'Wrong Account');
        
        genesis__Applications__c app = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Account__c = acc.Id,
            Lead_ID__c='1324325346547',
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'agent_verified',
            DocuSignFlag__c=true,
            genesis__Draw_Period_End_Date__c = system.Today()
        );
        Insert app; 
        System.assertEquals(20,app.genesis__Due_Day__c,'Wrong Due Day');
        
        String JsonStr = '{"PublicRecords":4,"IDScore":2,"ConsistencySNAPD":4}';
        Test.StartTest();
        WSKBAUpdateInfo.updateKBAInfo(app.id,JsonStr);
        Test.stopTest();
    }
    
    //For existing KBA_Details__c
    Testmethod static void updateKBAInfoTest_UseCase2(){   
        
        Account acc = new Account(
        Name = 'TestAcc',
        loan__Investor__c=false, 
        cnotify__Email__c='notify@testOrg.com'
        );
        Insert acc;
        System.assertEquals('TestAcc',acc.Name,'Wrong Account');
        
        genesis__Applications__c app = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Account__c = acc.Id,
            Lead_ID__c='1324325346547',
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'agent_verified',
            DocuSignFlag__c=true,
            genesis__Draw_Period_End_Date__c = system.Today()
        );
        Insert app; 
        System.assertEquals(20,app.genesis__Due_Day__c,'Wrong Due Day');
        
        String JsonStr = '{"PublicRecords":4,"IDScore":2,"ConsistencySNAPD":4}';
        Test.StartTest();
        WSKBAUpdateInfo.updateKBAInfo(app.id,JsonStr);
        List<KBA_Details__c> fraudDetails = [SELECT id,
                                                Id_Analytics_Score__c, 
                                                Consistency_Snapd_score__c, 
                                                Public_Records__c 
                                                FROM KBA_Details__c 
                                                where application__c=:app.id 
                                                Limit 1];
        System.AssertEquals(1,fraudDetails.size(),'KBA Details not present');
        WSKBAUpdateInfo.updateKBAInfo(app.id,JsonStr);
        Test.stopTest();
    }    
}