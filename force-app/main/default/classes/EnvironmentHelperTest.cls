@isTest
public class EnvironmentHelperTest {
    @isTest
    static void testGetPageDetailUrl(){
        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c = false,
            cnotify__Email__c = 'no-reply@testorganization.com',
            peer__First_Name__c = 'TestFName',
            peer__Last_Name__c = 'TestLName',
            City__c = 'TestCity',
            State__c = 'TestState',
            ZIP_Code__c = '123456',
            ints__SSN__c = '12345678'
        );
        insert acc;
        
        EnvironmentHelper.getPageDetailUrl(acc.Id);        
    }

}