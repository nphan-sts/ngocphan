/* ****************Modification History******************
* Modified by    	Date    		JIRA number
*     Pallavi      2019/01/06      LOS-121(to increase the coverage)
* 	Bhanupriya		2022/02/14		LSP-534 (Update fields and add assert statements)
******************Modification History******************/
@isTest
public class TestPayOffUtilities{
    
    //create testsetup method
    @testsetup()
    public static void testsetup(){
        //Creating Account
        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            //Borrower_s_Last_Name__c='Testborrower',
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123456789',			  	//LSP-534 Must be 9 digit number    
            peer__Last_Name__c = 'Test Last Name'						//LSP-534 Required Last name  
        );
        insert acc;
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

        //Creating Pricing offer	
        pricing_offer__C po =new pricing_offer__c(
            Interest_Rate__c = 0, 
            Term__c = 0, 
            Amount__c = 10000, 
            Is_Offer_Selected__c = true, 
            Monthly_Payment__c =300, 
            Application__c = app.id
        );
        insert po;
    }
    //test method 1
    @isTest static void payoffWebservice(){
        
        genesis__Applications__c app = [select id,
                                        genesis__Due_Day__c,
                                        genesis__Status__c,
                                        genesis__Expected_First_Payment_Date__c,
                                        genesis__Expected_Start_Date__c,
                                        genesis__Funding_in_Tranches__c,
                                        genesis__Account__c,
                                        Borrower_s_Email__c,
                                        Application_Start_DateV2__c
                                        from genesis__Applications__c];
        
        List<id> applist = new List<id>();
        applist.add(app.id);


        test.startTest();
        PayOffUtilities.getRecordtypeId('ObjName','RtypName',true);
       // PayOffUtilities.getRecordtypeName('01241000000XcA1AAK');
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
        PayOffUtilities.AssignToMe();//LOP-415
        test.stopTest();

        system.assert(!String.isEmpty(app.Borrower_s_Email__c));
        
    }
    
    //create method 2 for Exception cases 
    @isTest static void payoffExceptionCase(){
        test.startTest();

        PayOffUtilities.AssignToMXQueue(null);
        PayOffUtilities.AssignToFraudQueue(null);
        PayOffUtilities.AssignToVerificationQueue(null);
        PayOffUtilities.AssignToFundingQueue(null);
        PayOffUtilities.AssignToDeclinedQueue(null);
        PayOffUtilities.AssignToAgentVerifiedQueue(null);

        PayOffUtilities.WorkEmailVerify(null);
        PayOffUtilities.AssignToWithdrawnQueue(null);
        PayOffUtilities.AssignToUserOutbounder(null);
        PayOffUtilities.AssignToConsentQueue(null);
        PayOffUtilities.DeleteAppTagforSoftpull(null);
        PayOffUtilities.AssignToUserPreCheck(null);
        PayOffUtilities.AssignToUser(null);
        PayOffUtilities.AssignToConsentQueue(null);
        test.stopTest();        
    } 
    
    // create method 3 for agent verified	
    @isTest static void  agentVerifiedDQCheck(){
        
        genesis__Applications__c app = [select id,
                                        genesis__Due_Day__c,
                                        OwnerId,
                                        genesis__Status__c,
                                        genesis__Expected_First_Payment_Date__c,
                                        genesis__Expected_Start_Date__c,
                                        genesis__Funding_in_Tranches__c,
                                        genesis__Account__c,
                                        Borrower_s_Email__c,
                                        Application_Start_DateV2__c
                                        from genesis__Applications__c];
        
        system.debug('App ' +app.OwnerId);

        test.startTest();
        PayOffUtilities.AssignToAgentVerifiedQueue(app.id);
        
        test.stopTest();
        genesis__Applications__c app1 = [select id,
                                         genesis__Due_Day__c,
                                         OwnerId,
                                         genesis__Status__c,
                                         Borrower_s_Email__c
                                         from genesis__Applications__c];
        
       // system.assert(app.OwnerId != app1.OwnerId,'Application OwnerId is updated');
        
    }
    
      
}