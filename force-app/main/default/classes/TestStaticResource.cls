@isTest
public with sharing class TestStaticResource {
    static testMethod void testLoadData() {
        // Load the test accounts from the static resource
        List<Account> ls = Test.loadData(Account.sObjectType, 'TestStaticResource');
        // Verify that all 3 test accounts were created
        //System.assert(ls.size() == 3);

        // Get first test account
        //Account a1 = (Account) ls[0];
        //String acctName = a1.Name;
        //System.debug(acctName);

        // Perform some testing using the test records
    }
}