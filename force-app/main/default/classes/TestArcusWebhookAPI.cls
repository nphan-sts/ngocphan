/* ****************Modification History*****************************************************************
 * @author - Pallavi  CRM-65
 * Modified by      Date            JIRA number
 *     Pallavi      2020/10/21      CRM-65(DCP - Read and post the webhook response on payments from Arcus)
 *  Shakul          2022/02/25      LSP-532 (Refactored Test Class)
 ******************Modification History*****************************************************************/
@isTest
private class TestArcusWebhookAPI {
    static final String STRING_CONST = URL.getSalesforceBaseUrl().toExternalForm() +'/services/apexrest/CallbackArcus/';
    @TestSetup
    public static void testSetup(){

        Account acc = new Account(Name = 'Test_DCP',
                                    loan__Investor__c=false,
                                    cnotify__Email__c = 'no-reply@testorganization.com',
                                    peer__First_Name__c = 'TestFName1',
                                    peer__Last_Name__c='TestLName1', 
                                    City__c='TestCity',
                                    State__c='TestState',
                                    ZIP_Code__c='123456');
        insert acc;

        Contact a1 = new Contact(LastName='TestACH');
        insert a1;

        loan.TestHelper.createSeedDataForTesting();

        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        
        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct('Loan Product',
                                                                            dummyOffice,
                                                                            dummyAccount,
                                                                            curr,
                                                                            dummyFeeSet,
                                                                            'Interest Only',
                                                                            40,
                                                                            12,
                                                                            null);
               
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        loan__Loan_Account__c loanAccount = loan.TestHelper.createLoanAccountForAccountObj(dummyLP,
                                                                                            acc,
                                                                                            dummyFeeSet,
                                                                                            dummyLoanPurpose,
                                                                                            dummyOffice);
                                                                                     
        loan__Bank_Account__c ba = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
                                                 loan__Bank_Name__c = 'Some Bank',
                                                 loan__Routing_Number__c = '999999999',
                                                 Unmasked_Bank_Account_Number__c = '99999999',
                                                 loan__Account_Type__c = 'Checking',
                                                 loan__Contact__c = a1.id,
                                                 loan__Account__c = acc.id);
        insert ba;

        loan__Payment_Mode__c lp=new loan__Payment_Mode__c();
        lp.Name='DCP Arcus';
        lp.loan__Summary__c=False;
        lp.loan__Master_Archive_Object__c=False;
        lp.loan__Summary_Record_Id__c='TestRec';
        lp.loan__Archived__c=False;
        insert lp;

        loan__Loan_Disbursal_Transaction__c disbTxn = new loan__Loan_Disbursal_Transaction__c();
        disbTxn.loan__Disbursal_Date__c = loan.TestHelper.systemDate;
        disbTxn.loan__Disbursed_Amt__c = 2000;
        disbTxn.loan__Loan_Account__c = loanAccount.id;
        disbTxn.loan__Bank_Account__c = ba.Id;
        disbTxn.loan__Mode_of_Payment__c =  lp.id;
        disbTxn.loan__Loan_Disbursal_Transaction_Type__c = 'DM-Regular';
        insert disbTxn;
        
        String txnId = '123456789';
        
        loan__Disbursal_Txn_Distribution__c loanDistribution = new loan__Disbursal_Txn_Distribution__c();
        loanDistribution.loan__Distribution_Amount__c = 2000;
        loanDistribution.Arcus_Transaction_Id__c = txnId;
        loanDistribution.loan__Distribution_Type__c ='Disbursement';
        loanDistribution.loan__Loan_Disbursal_Transaction__c = disbTxn.id;
        insert loanDistribution;

        genesis__Applications__c app= new genesis__Applications__c(genesis__Due_Day__c = 20,
                                                                    genesis__Expected_First_Payment_Date__c = system.Today(),
                                                                    genesis__Expected_Start_Date__c = system.Today(),
                                                                    genesis__Funding_in_Tranches__c = true,
                                                                    Borrower_s_Email__c = null,
                                                                    genesis__Account__c = acc.Id,
                                                                    genesis__Expected_Close_Date__c =Date.newInstance(2017,10,11),
                                                                    Application_Start_DateV2__c = system.Today(),
                                                                    DocuSignFlag__c=true,
                                                                    genesis__Status__c = 'Approved for funding',
                                                                    genesis__Draw_Period_End_Date__c = system.Today(),
                                                                    genesis__Loan_Amount__c=3000
                                                                    );
        insert app;

        //Inserting Application Document Category record
        genesis__Application_Document_Category__c genAppDocCatTIL = new genesis__Application_Document_Category__c();
        genAppDocCatTIL.Name = 'TIL Document';
        genAppDocCatTIL.genesis__Application__c = app.Id;
        insert genAppDocCatTIL;

        DCp_Arcus_Transactions__c dcpTxn = new DCp_Arcus_Transactions__c(application__c = app.id);
        dcpTxn.pay_at_funding__c = true;
        dcpTxn.Requested_Amount__c = 2000;
        dcpTxn.Transaction_Id__c = txnId;
        insert dcpTxn;
    }

    /* Created By : Shakul Siddharth
       Description : To cover DCP Arcus status successfully getting updated
    */
    public static testMethod void updateArcusStatus(){
        String txnId = '123456789';

        MW_Settings__c settings = new MW_Settings__c();
        settings.FE_User_Filter__c = 'serviceapi@happymoney.com.cliqa,';
        insert settings;

        RestRequest request = new RestRequest();
        request.requestURI = STRING_CONST +txnId ;
        request.httpMethod = 'PATCH';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"id": "123456789","status": "confirmed","bill_id": null,"account_number": "1234-56","currency": "USD","amount": 2000,"created_at": "2018-04-06T15:41:52.846Z","updated_at": "2018-04-06T15:41:52.846Z","error_code": null,"error_message": null,"client_number": "805-612-0442"}');
        RestContext.request = request;
        
        RestResponse response = new RestResponse();
        RestContext.response = response;
        
        Test.startTest();
        ArcusWebhookAPI.arcusCallback();
        Test.stopTest();
        DCp_Arcus_Transactions__c testDCP = [SELECT id, status__c FROM DCp_Arcus_Transactions__c LIMIT 1];
        System.assertEquals('confirmed', testDCP.status__c);
    }

    /* Created By : Shakul Siddharth
       Description : To cover exception since FE_User_Filter__c is blank
    */
    public static testMethod void updateArcusStatusException(){
        String txnId = '123456789';
        
        RestRequest request = new RestRequest();
        request.requestURI = STRING_CONST +txnId ;
        request.httpMethod = 'PATCH';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"id": "123456789","status": "confirmed","bill_id": null,"account_number": "1234-56","currency": "USD","amount": 2000,"created_at": "2018-04-06T15:41:52.846Z","updated_at": "2018-04-06T15:41:52.846Z","error_code": null,"error_message": null,"client_number": "805-612-0442"}');
        RestContext.request = request;
        
        RestResponse response = new RestResponse();
        RestContext.response = response;
        
        Test.startTest();
        ArcusWebhookAPI.arcusCallback();
        Test.stopTest();
        loan__Disbursal_Txn_Distribution__c testDCP = [SELECT id, Arcus_Transaction_Status__c FROM loan__Disbursal_Txn_Distribution__c LIMIT 1];
        System.assertEquals('confirmed', testDCP.Arcus_Transaction_Status__c);
    }

    /* Created By : Shakul Siddharth
       Description : To cover scenario when transaction id is not passed in the request
    */
    public static testMethod void testBlankTxnId(){
        RestRequest request1 = new RestRequest();
        request1.requestURI = STRING_CONST ;
        request1.httpMethod = 'PATCH';
        request1.addHeader('Content-Type', 'application/json');
        request1.requestBody = Blob.valueOf('{"id": "123456789","status": "confirmed","bill_id": null,"account_number": "1234-56","currency": "USD","amount": 2000,"created_at": "2018-04-06T15:41:52.846Z","updated_at": "2018-04-06T15:41:52.846Z","error_code": null,"error_message": null,"client_number": "805-612-0442"}');
        RestContext.request = request1;
        
        RestResponse response1 = new RestResponse();
        RestContext.response = response1;

        Test.startTest();
        ArcusWebhookAPI.arcusCallback();
        Test.stopTest();
        ArcusWebhookAPI.errorResponse err = new ArcusWebhookAPI.errorResponse();
        String msg = err.errorCode;
        System.assertEquals(null, msg);
    }

    /* Created By : Shakul Siddharth
       Description : To cover scenario when invalid transaction id is passed along with the request
    */
    public static testMethod void testInvalidTxnId(){
        RestRequest request2 = new RestRequest();
        request2.requestURI = STRING_CONST + '/9999' ;
        request2.httpMethod = 'PATCH';
        request2.addHeader('Content-Type', 'application/json');
        request2.requestBody = Blob.valueOf('{"id": "123456789","status": "confirmed","bill_id": null,"account_number": "1234-56","currency": "USD","amount": 2000,"created_at": "2018-04-06T15:41:52.846Z","updated_at": "2018-04-06T15:41:52.846Z","error_code": null,"error_message": null,"client_number": "805-612-0442"}');
        RestContext.request = request2;
        
        RestResponse response2 = new RestResponse();
        RestContext.response = response2;
        
        Test.startTest();
        ArcusWebhookAPI.arcusCallback();
        Test.stopTest();
        ArcusWebhookAPI.Response resp = new ArcusWebhookAPI.Response();
        String msg = resp.transactionId;
        System.assertEquals(null, msg);
    }
}