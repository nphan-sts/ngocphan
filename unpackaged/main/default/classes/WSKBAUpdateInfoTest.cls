/* ****************Modification History******************
* Modified By        Date          JIRA number
*1. Bhanupriya		2022/03/03		LSP-595
******************Modification History******************/
@isTest
private class WSKBAUpdateInfoTest{
    
    //Create testsetup()
    @testsetup()
    public static void testsetup(){
        
        //create account
        Account acc = new Account(
            Name = 'TestAcc',
            loan__Investor__c=false, 
            cnotify__Email__c='notify@testOrg.com',
            peer__Last_Name__c = 'TestAcc Last Name'			//LSP-595
        );
        Insert acc;
        
        //create application
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
        
    }
    
    //For New KBA_Details__c
   @istest static void newKBAInfo(){   
        
        genesis__Applications__c app = [select id from genesis__Applications__c];
        String jsonStr = '{"PublicRecords":4,"IDScore":2,"ConsistencySNAPD":4}';
        Test.StartTest();
        WSKBAUpdateInfo.updateKBAInfo(app.id,jsonStr);
        Test.stopTest();
        List<KBA_Details__c> fraudDetails = [SELECT id,
                                             Id_Analytics_Score__c, 
                                             Consistency_Snapd_score__c, 
                                             Public_Records__c 
                                             FROM KBA_Details__c 
                                             where application__c=:app.id 
                                             Limit 1];
        System.AssertEquals(1,fraudDetails.size(),'KBA Details not present');
        
    }
    
   //For existing KBA_Details__c
    @istest static void updateKBAInfo(){   
        genesis__Applications__c app = [select id from genesis__Applications__c];
        
        String jsonStr = '{"PublicRecords":4,"IDScore":2,"ConsistencySNAPD":4}';
        
        Test.StartTest();
        WSKBAUpdateInfo.updateKBAInfo(app.id,jsonStr);
        List<KBA_Details__c> fraudDetails = [SELECT id,
                                             Id_Analytics_Score__c, 
                                             Consistency_Snapd_score__c, 
                                             Public_Records__c 
                                             FROM KBA_Details__c 
                                             where application__c=:app.id 
                                             Limit 1];
        
        WSKBAUpdateInfo.updateKBAInfo(app.id,jsonStr);
        Test.stopTest();
        System.AssertEquals(1,fraudDetails.size(),'KBA Details not present');     
    }    
    
}