@isTest
public class JobLoggingTriggerHandlerTest {
    
 @TestSetup
    public static void testSetup(){        
        loan.TestHelper.systemDate = Date.today();
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper2.createFileGenMetaData();
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        MW_Settings__c mwSettings = new MW_Settings__c();
        mwSettings.Slack_mentions_for_Nacha_alert__c = 'TestSlackMentions1,TestSlackMentions2';
        mwSettings.lsp_team_slack_channel_webhook__c = 'TestSlackChannelURL';
        insert mwSettings;

        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Account_External_ID__c = 'Test';
        acc.peer__Last_Name__c = 'Account';
        insert acc;
        
        Contact a1 = new Contact(LastName='TestACH');
        insert a1;
        
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,dummyAccount,curr,dummyFeeSet);
        
        loan__Payment_Mode__c pMode = [select id, name from loan__Payment_Mode__c where Name= 'ACH'];
        
        loan__Bank_Account__c ba = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12',
                                                             loan__Bank_Name__c = 'Some Bank',
                                                             loan__Routing_Number__c = '999999999',
                                                             loan__Account_Type__c = 'Checking',
                                                             loan__Account_Usage__c = 'Collections Trust Account',
                                                             Unmasked_Bank_Account_Number__c = '123234324',
                                                             loan__Contact__c = a1.id,
                                                             loan__Account__c = acc.id,
                                                             loan__Active__c = true);
        insert ba;
        
        loan__Automated_Payment_Configuration__c aPC = loan.TestHelper2.createAutomatedPaymentConfiguration(loan.LoanConstants.LOAN_PAYMENT,pMode,ba,'CustomLoanPaymentTxnNACHAGen');
        apc.loan__Immediate_Destination__c = '2222222222';
        apc.loan__Folder_Name__c = 'ACU';
        apc.Box_Folder_ID__c = '123456';
        update apc;
    }
    @isTest
    public static void testAfterjobLogInsert(){
        clcommon__DAG_Logging__c dagLogging = new clcommon__DAG_Logging__c(clcommon__Status__c = 'Success');
        insert dagLogging;
        
        clcommon__Job_Logging__c jlog = new clcommon__Job_Logging__c();
        jlog.clcommon__Label__c  = 'Loan Payment Filegen';
        jlog.clcommon__Status__c  = 'Processing';
        jlog.clcommon__DAG_Logging__c = dagLogging.Id;
        insert jlog;
        
        system.assertEquals(0, [SELECT count() FROM Document WHERE CreatedDate = Today]);
    }
    @isTest
    public static void testAfterjobLogUpdate(){
        clcommon__DAG_Logging__c dagLogging = new clcommon__DAG_Logging__c(clcommon__Status__c = 'Success');
        insert dagLogging;
        
        Folder folder = [
                SELECT Id, Name
                FROM   Folder
                WHERE  Name = 'ACU'
                LIMIT  1
        ];

        /* make a csv as an attachment, just to test attachments */
        Document doc = new Document();
        doc.Name = 'Nacha Test File Created today';
        doc.Body = Blob.valueOf('TestNachaFileContent');
        doc.ContentType = 'text/csv';
        doc.Type = 'text';
        doc.Description = '';
        doc.FolderId = folder.Id;
        insert doc;
        
        clcommon__Job_Logging__c jlog = new clcommon__Job_Logging__c();
        jlog.clcommon__Label__c  = 'Loan Payment Filegen';
        jlog.clcommon__Status__c  = 'Processing';
        jlog.clcommon__DAG_Logging__c = dagLogging.Id;
        insert jlog;
        
        jlog.clcommon__Status__c  = 'Success';
        update jlog;
        
        system.assertEquals(1, [SELECT count() FROM Document WHERE CreatedDate = Today]);
    }
}