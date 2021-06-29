@isTest
private class MW_SkipAPayControllerTest {
    @testSetup
    static void dataSetup() {
        //Todo
        loan__Loan_Account__c loan = new loan__Loan_Account__c(
            id = 'Testing'
        );
        insert loan;
    }

    static testMethod void testPost() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/skipapay/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{ "loanId": "Testing", "numberOfSkips": "4"}');
        RestContext.request = req;
        RestContext.response= res;
        MW_SkipAPayController.SkipAPayController();
        loan__Loan_Account__c loan = [ SELECT Id, Name, Skipped_a_Pay__c FROM loan__Loan_Account__c WHERE Id = 'Testing' ];
        system.assertEquals(loan.Skipped_a_Pay__c, true, 'passed');
    }
}
