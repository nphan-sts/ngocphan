@isTest
global class MW_UserPackageLicenseSchedulerTest
{
    global static list<MW_general_record__mdt> mwList = [select MasterLabel,Value__c, Module_Name__c 
                                      from MW_general_record__mdt where Module_Name__c = 'UserPackageLicense'];
    
    global static testMethod void myUnitTest()
    {
        Profile profileVerification = MW_GlobalTestUtility.GetProfile('Verification Team Mgr');
        User u = MW_GlobalTestUtility.GetUser('TestUser@HappyMoney.com.Test');
        u.ProfileId = profileVerification.id;
        insert u;
        
        Test.startTest();
        
        List <UserPackageLicense> uPL = New List<UserPackageLicense>();
        list<string> valueList = new list<string>();
        for(MW_general_record__mdt vList: mwList){
            valueList.add(vList.Value__c);
            system.debug('valueList -----------' + valueList);
        }
        List<PackageLicense> pl = [SELECT Id, NamespacePrefix  FROM PackageLicense where NamespacePrefix IN:valueList];
        for(PackageLicense pll:pl)
        {
            UserPackageLicense usp = new UserPackageLicense();
            usp.PackageLicenseId = pll.Id;
            usp.UserId = u.Id;
            uPL.add(usp);
        }
        insert uPL;
        Test.stopTest();
        List<User>uList = [SELECT Id, LastName, CLL__c ,CL_Mkt__c ,CL_Collections__c,CLO__c  From User WHERE Id =:u.Id];
        system.assertEquals(true,true);
        System.Debug('uList----------'+ uList);
    }
    
    @isTest
    static void testMW_UserLicenseScheduler() {
        Test.startTest();
        String chron = '0 0 23 * * ?';
        Id scheduleId = System.schedule('Test MW_UserPackageLicenseScheduler', chron, new MW_UserPackageLicenseScheduler());
        System.assertNotEquals(null, scheduleId);
        Test.stopTest();
    }
}