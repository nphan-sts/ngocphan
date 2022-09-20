/*MW_ApplicationTagsTriggerTest - */
@isTest
private class MW_ApplicationTagsTriggerTest {
    
    private static genesis__Org_Parameters__c cso;
    
    @testSetup
    static void setupTestData() {
        cso = new genesis__Org_Parameters__c(genesis__Disable_Triggers__c = true);
        insert cso;
        
        genesis__Applications__c app = MW_GlobalTestUtility.GetApplication();
        insert app;
        
        Application_Tags__c appTags = MW_GlobalTestUtility.GetApplicationTag('Needs Review');
        appTags.Application__c = app.Id;
        insert appTags;
        
        cso.genesis__Disable_Triggers__c = false;
        update cso;
    }
    
    static testMethod void checkDeleteTagsPermissionsTest(){
        User userFraud = MW_GlobalTestUtility.GetUser('TestUser@HappyMoney.com.Test');
        userFraud.ProfileId = UserInfo.getProfileId();
        insert userFraud;
        
        system.runAs(userFraud) {
            Test.startTest();
            Application_Tags__c appTag = [SELECT Application_Tag__c, Application__c FROM Application_Tags__c WHERE Application_Tag__c = 'Needs Review'];
            
            try {
                appTag.softDelete__c = true;
                Update appTag;
                
            } catch (exception e) {
                System.debug('****** Exception Caught :   '+e.getMessage());
                System.assert(e.getMessage().contains('You do not have access to delete this record!'));
            }
            
            Test.stopTest();
        }
        Profile profileVerification = MW_GlobalTestUtility.GetProfile('Fraud Manager');
        
        User userFraud1 = MW_GlobalTestUtility.GetUser('TestUser1@HappyMoney.com.Test');
        userFraud1.ProfileId = profileVerification.Id;
        insert userFraud1;
        
        system.runAs(userFraud1) {            
            Application_Tags__c appTag = [SELECT Application_Tag__c, Application__c FROM Application_Tags__c WHERE Application_Tag__c = 'Needs Review'];
            try {
                appTag.softDelete__c = true;
                Update appTag;
                
            } catch (exception e) {
                System.debug('****** Exception Caught :   '+e.getMessage());
                System.assert(e.getMessage().contains('You do not have access to delete this record!'));
            }
        }
    }
    
    static testMethod void checkAddTagsPermissionsTest() {
        if( cso == null ){
            cso = [SELECT ID FROM genesis__Org_Parameters__c LIMIT 1];
        }
        cso.genesis__Disable_Triggers__c = true;
        upsert cso;
        
        User userFraud = MW_GlobalTestUtility.GetUser('TestUser@HappyMoney.com.Test');
        userFraud.ProfileId = UserInfo.getProfileId();
        insert userFraud;
        
        Test.startTest();
        system.runAs(userFraud) {
            
            
            genesis__Applications__c app = MW_GlobalTestUtility.GetApplication();
            insert app;
            Application_Tags__c appTags = MW_GlobalTestUtility.GetApplicationTag('Needs Review');
            appTags.Application__c = app.Id;
            
            try {
                cso.genesis__Disable_Triggers__c = false;
                update cso;
                insert appTags;
                
            } catch (exception e) {
                System.debug('****** Exception Caught :   '+e.getMessage());
            }
        }
        Test.stopTest();
        Profile profileVerification = MW_GlobalTestUtility.GetProfile('Fraud Manager');
        
        User userFraud1 = MW_GlobalTestUtility.GetUser('TestUser1@HappyMoney.com.Test');
        userFraud1.ProfileId = profileVerification.Id;
        insert userFraud1;
        
        system.runAs(userFraud1) {
            
            genesis__Applications__c app = MW_GlobalTestUtility.GetApplication();
            insert app;
            Application_Tags__c appTags = MW_GlobalTestUtility.GetApplicationTag('Needs Review');
            appTags.Application__c = app.Id;
            
            try {
                
                insert appTags;
                
            } catch (exception e) {
                System.debug('****** Exception Caught :   '+e.getMessage());
                // System.assert(e.getMessage().contains('You do not have access to add this record!'));
                
            }
        }
    }
}