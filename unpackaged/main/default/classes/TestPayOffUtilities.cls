/* ****************Modification History******************
* Modified by    	Date    		JIRA number
*     Pallavi      2019/01/06      LOS-121(to increase the coverage)
******************Modification History******************/
@isTest
public class TestPayOffUtilities {
    
    @testSetup
    public static void testSetupData() {
        genesis__Org_Parameters__c cso = new genesis__Org_Parameters__c(genesis__Disable_Triggers__c = true);
        insert cso;
        
        //Creating Account
        Account acc = MW_GlobalTestUtility.GetAccount('Member');
        acc.peer__First_Name__c = 'FirstName1';
        acc.peer__Last_Name__c = 'LastName1';
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
        //Creating Application
        genesis__Applications__c app= new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            Borrower_s_Email__c = null,
            genesis__Account__c = acc.Id,
            Application_Start_DateV2__c = system.Today(),
            DocuSignFlag__c=true,
            genesis__Status__c = 'agent_verified',
            genesis__Draw_Period_End_Date__c = system.Today()
        );
        insert app;
        
        System.assertEquals(null, app.Borrower_s_Email__c, 'Borrower Email is not null');
        

    }
    
    @isTest static void method1(){
        genesis__Applications__c app = [SELECT Id, Borrower_s_Email__c FROM genesis__Applications__c LIMIT 1];
        
        List<id> applist = new List<id>();
        applist.add(app.id);
        
        test.startTest();
        PayOffUtilities.getRecordtypeId('ObjName','RtypName',true);
        PayOffUtilities.getRecordtypeName('01241000000XcA1AAK');
        PayOffUtilities.AssignToMXQueue(app.id);
        PayOffUtilities.AssignToFraudQueue(app.id);
        PayOffUtilities.AssignToVerificationQueue(app.id);
        PayOffUtilities.AssignToFundingQueue(app.id);
        PayOffUtilities.AssignToReviewQueue(app.id);
        PayOffUtilities.AssignToDeclinedQueue(app.id);
        PayOffUtilities.AssignToAgentVerifiedQueue(app.id);
        PayOffUtilities.AssignToFinalVerificationQueue(app.id);
        PayOffUtilities.createAppTagforSoftpull(app.id);
        PayOffUtilities.AssignToUser(app.id);
        PayOffUtilities.AssignToConsentQueue(applist);
        PayOffUtilities.DeleteAppTagforSoftpull(app.id);
        /*LOS-121*/
        PayOffUtilities.AssignToUserPreCheck(app.id);
        PayOffUtilities.AssignToDeclinedQueueStatus(app.id,'Declined');
        PayOffUtilities.AssignToUserOutbounder(app.id);
        PayOffUtilities.AssignToWithdrawnQueue(app.id);
        PayOffUtilities.WorkEmailVerify(app.id);
        /*LOS-121*/
        test.stopTest();
    }
    //Exception cases
    @isTest static void method2(){
        test.startTest();
        PayOffUtilities.AssignToMXQueue(null);
        PayOffUtilities.AssignToFraudQueue(null);
        PayOffUtilities.AssignToVerificationQueue(null);
        PayOffUtilities.AssignToFundingQueue(null);
        PayOffUtilities.AssignToDeclinedQueue(null);
        PayOffUtilities.AssignToAgentVerifiedQueue(null);
        test.stopTest();
    }
    
    @isTest static void  AgentVerifiedDQCheck(){
        
        genesis__Applications__c app = [SELECT Id FROM genesis__Applications__c LIMIT 1];
        
        pricing_offer__C po =new pricing_offer__c(
            Interest_Rate__c = 0, 
            Term__c = 0, 
            Amount__c = 10000, 
            Is_Offer_Selected__c = true, 
            Monthly_Payment__c =300, 
            Application__c = app.id
        );
        insert po;
        test.startTest();
        PayOffUtilities.AssignToAgentVerifiedQueue(app.id);
        //system.assertEquals(, actual)
        test.stopTest();
        
    }
}