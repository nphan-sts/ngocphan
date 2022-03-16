/******************Modification History*****************************************
 * Pallavi      2019-11-29      LOS-205/LOS-214**
 * Bhanupriya	2022-02-21		LSP-539
 * 	
 * ****************************************************************************/
@isTest
private class SendEnvDocuSignAPITest{
    
    //Create testsetup()
    @testsetup()
    public static void testsetup(){
        
	// Create Investor Account
        Account InvAcc = new Account(Name = 'TestInvestor',loan__Investor__c=True);
				InvAcc.peer__Last_Name__c = 'TestInvestor Last Name';					//LSP-539 create required field
		Insert InvAcc;  
		
	//Create new Account 
		Account acc = new Account(
							Name = 'TestAcc',
							loan__Investor__c=false,
							peer__First_Name__c='Test_PeerFName', 
							peer__Last_Name__c='Test_PeerLName',
							loan__SOCIAL_SECURITY_NUMBER__c='123456789', 	//LSP-539 update Social Security number (must be 9 digit)
							peer__Date_of_Birth__c=System.today(),
							Address_1__c='TestAddr1', 
							Address_2__c='TestAddr2', 
							City__c='Test_City',
							State__c='Test_State', 
							ZIP_Code__c='12345', 
							Suffix__c='Mr',
							Phone='2345677', 
							peer__Email__c='test@testOrg.com',
							Payoff_UID__c='1324325346547', 
							cnotify__Email__c='notify@testOrg.com',
							US_Citizen__c=true);
		Insert acc;
		
	//Create Applications
		genesis__Applications__c app = new genesis__Applications__c(
							genesis__Due_Day__c = 20,
							genesis__Expected_First_Payment_Date__c = system.Today(),
							genesis__Expected_Start_Date__c = system.Today(),
							genesis__Funding_in_Tranches__c = true,
							Investor__c = InvAcc.Id, 
							genesis__Account__c = acc.Id,
							Lead_ID__c='716d3efb-0047-4f93-9909-6fedfaa779781',
							Application_Start_DateV2__c = system.Today(),
							genesis__Status__c = 'agent_verified',
							DocuSignFlag__c=true,
							genesis__Draw_Period_End_Date__c = system.Today(),
							TU_consumer_id__c = '1324536829',
							genesis__Loan_Amount__c = 1000,  //pallavi
							Origination_fee__c = 50
						);
		Insert app; 
    
	//Create Employment Information
		genesis__Employment_Information__c empInfo = new genesis__Employment_Information__c(
                                                        genesis__Application__c = app.Id,
                                                        Income_Include_Bonuses_or_Commissions__c = false,
                                                        genesis__Name_of_employer__c = 'Test',
                                                        genesis__Number_of_years_on_job__c = 5,
                                                        genesis__Phone__c = '1234567890',
                                                        genesis__Position__c = 'Position',
                                                        Work_Email__c = 'test@gmail.com'
                                                        );
		insert empInfo;
    
	//Create Document category
		genesis__Document_Category__c docType = new genesis__Document_Category__c(
										genesis__Category_Name__c='ESign Documents',
										Application_Status__c=app.genesis__Status__c
									);
		insert docType;
    
	//Create Document Signature template
		DocuSign_Template__c DSTemplate = new DocuSign_Template__c(
										Name='Test_DSTemplate', 
										Template_Id__c='12345678', 
										State__c='Test_State,Test_state1',  
										Account__c =InvAcc.Id, 
										Document_Category__c=docType.Id,
										Active__c = True
									);
		Insert DSTemplate;
    
	//Create a new Loan Bank account
		loan__Bank_Account__c ba = new loan__Bank_Account__c(
										loan__Bank_Account_Number__c = '123234324',
										loan__Bank_Name__c = 'Test_Bank',
										loan__Routing_Number__c = '999999999',
										Unmasked_Bank_Account_Number__c = '123234324',
										loan__Account_Type__c = 'Checking',
										loan__Account__c = acc.Id,
										loan__Active__c = true,
										loan__Account_Usage__c = 'Borrower/Investor Account'  //LOS-205
									);
		insert ba;
    
	//Create pricing offer
		Pricing_Offer__c pOffer = new Pricing_Offer__c(
									Application__c=app.Id, 
									Amount__c=1000, 
									Interest_Rate__c=2.0, 
									Monthly_Payment__c=99, 
									Term__c=5,
									Is_Offer_Selected__c=true
								);
		Insert pOffer;
    
	//Create Amortization Schedule
		genesis__Amortization_Schedule__c amSchedle = new genesis__Amortization_Schedule__c(
									genesis__Due_Date__c=System.Today(),
									genesis__Application__c=app.Id
								);
		Insert amSchedle;
    
    }
  
    //Test method
    
    static testMethod void test_sendDocuSignEnvelope_UseCase1(){
        
        	genesis__Applications__c app = [select id,
                                            genesis__Due_Day__c,
                                            DocuSignFlag__c
                                            from genesis__Applications__c];
        
        	DocuSign_Template__c DSTemplate = [select id,
                                               name, 
                                               Template_Id__c,
                                               State__c,
                                               Document_Category__c 
                                               from DocuSign_Template__c];
   
            TestTriggerParameter.disableTriggerHandler(true);
            System.assertEquals(true, TestTriggerParameter.disableTriggerTest);
        	List<genesis__Applications__c> lstgenesis_applications_Obj  =  [SELECT DocuSign_EnvelopeId__c from genesis__Applications__c];
    		Test.startTest();
          	 	
                SendEnvDocuSignAPI snd = new SendEnvDocuSignAPI(true);
                SendEnvDocuSignAPI.sendDocuSignEnvelope(app.Id); 
                SendEnvDocuSignAPI.voidDocuSignEnvelope(lstgenesis_applications_Obj[0].DocuSign_EnvelopeId__c);
                SendEnvDocuSignAPI.getDocumentId(lstgenesis_applications_Obj[0].DocuSign_EnvelopeId__c);
                SendEnvDocuSignAPI.getEnvelopeStatus(lstgenesis_applications_Obj[0].DocuSign_EnvelopeId__c);
                SendEnvDocuSignAPI.updateDocumentFields(lstgenesis_applications_Obj[0].DocuSign_EnvelopeId__c,DSTemplate.Id);
        		TestTriggerParameter.disableTriggerHandler(false);  
                
             Test.stopTest();  
    			
        		System.assertEquals(false, TestTriggerParameter.disableTriggerTest);
        		System.assertEquals(true, lstgenesis_applications_Obj.size()>0);   
     
                system.assertEquals([select Id from genesis__Applications__c].size(),1);
			
    }
}
    
    
  
 /* static testMethod void test_sendDocuSignEnvelope_UseCase1(){
   
    TestTriggerParameter.disableTriggerHandler(true);
    System.assertEquals(true, TestTriggerParameter.disableTriggerTest);
    Test.startTest();
    Account InvAcc = new Account(Name = 'TestInvestor',loan__Investor__c=True);
      		InvAcc.peer__Last_Name__c = 'TestInvestor Last Name';
    Insert InvAcc;  
    Account acc = new Account(
        Name = 'TestAcc',
        loan__Investor__c=false,
        peer__First_Name__c='Test_PeerFName', 
        peer__Last_Name__c='Test_PeerLName',
        loan__SOCIAL_SECURITY_NUMBER__c='123456789', 
        peer__Date_of_Birth__c=System.today(),
        Address_1__c='TestAddr1', 
        Address_2__c='TestAddr2', 
        City__c='Test_City',
        State__c='Test_State', 
        ZIP_Code__c='12345', 
        Suffix__c='Mr',
        Phone='2345677', 
        peer__Email__c='test@testOrg.com',
        Payoff_UID__c='1324325346547', 
        cnotify__Email__c='notify@testOrg.com',
        US_Citizen__c=true);
    Insert acc;
    genesis__Applications__c app = new genesis__Applications__c(
        genesis__Due_Day__c = 20,
        genesis__Expected_First_Payment_Date__c = system.Today(),
        genesis__Expected_Start_Date__c = system.Today(),
        genesis__Funding_in_Tranches__c = true,
        Investor__c = InvAcc.Id, 
        genesis__Account__c = acc.Id,
        Lead_ID__c='716d3efb-0047-4f93-9909-6fedfaa779781',
        Application_Start_DateV2__c = system.Today(),
        genesis__Status__c = 'agent_verified',
        DocuSignFlag__c=true,
        genesis__Draw_Period_End_Date__c = system.Today(),
        TU_consumer_id__c = '1324536829',
        genesis__Loan_Amount__c = 1000,  //pallavi
        Origination_fee__c = 50
    );
    Insert app; 
    
    genesis__Employment_Information__c empInfo = new genesis__Employment_Information__c(
                                                        genesis__Application__c = app.Id,
                                                        Income_Include_Bonuses_or_Commissions__c = false,
                                                        genesis__Name_of_employer__c = 'Test',
                                                        genesis__Number_of_years_on_job__c = 5,
                                                        genesis__Phone__c = '1234567890',
                                                        genesis__Position__c = 'Position',
                                                        Work_Email__c = 'test@gmail.com'
                                                        );
    insert empInfo;
    
    genesis__Document_Category__c docType = new genesis__Document_Category__c(
        genesis__Category_Name__c='ESign Documents',
        Application_Status__c=app.genesis__Status__c
    );
    insert docType;
    
    DocuSign_Template__c DSTemplate = new DocuSign_Template__c(
        Name='Test_DSTemplate', 
        Template_Id__c='12345678', 
        State__c='Test_State,Test_state1',  
        Account__c =InvAcc.Id, 
        Document_Category__c=docType.Id,
        Active__c = True
    );
    Insert DSTemplate;
    
    loan__Bank_Account__c ba = new loan__Bank_Account__c(
        loan__Bank_Account_Number__c = '123234324',
        loan__Bank_Name__c = 'Test_Bank',
        loan__Routing_Number__c = '999999999',
        Unmasked_Bank_Account_Number__c = '123234324',
        loan__Account_Type__c = 'Checking',
        loan__Account__c = acc.Id,
        loan__Active__c = true,
        loan__Account_Usage__c = 'Borrower/Investor Account'  //LOS-205
    );
    insert ba;
    
    Pricing_Offer__c pOffer = new Pricing_Offer__c(
        Application__c=app.Id, 
        Amount__c=1000, 
        Interest_Rate__c=2.0, 
        Monthly_Payment__c=99, 
        Term__c=5,
        Is_Offer_Selected__c=true
    );
    Insert pOffer;
    
    genesis__Amortization_Schedule__c amSchedle = new genesis__Amortization_Schedule__c(
        genesis__Due_Date__c=System.Today(),
        genesis__Application__c=app.Id
    );
    Insert amSchedle;
    Test.stopTest();
    
    List<genesis__Applications__c> lstgenesis_applications_Obj  =  [SELECT DocuSign_EnvelopeId__c from genesis__Applications__c];
    System.assertEquals(true, lstgenesis_applications_Obj.size()>0);   
     
    TestTriggerParameter.disableTriggerHandler(false);  
    System.assertEquals(false, TestTriggerParameter.disableTriggerTest);
    SendEnvDocuSignAPI snd = new SendEnvDocuSignAPI(true);
    SendEnvDocuSignAPI.sendDocuSignEnvelope(app.Id); 
    SendEnvDocuSignAPI.voidDocuSignEnvelope(lstgenesis_applications_Obj[0].DocuSign_EnvelopeId__c);
    SendEnvDocuSignAPI.getDocumentId(lstgenesis_applications_Obj[0].DocuSign_EnvelopeId__c);
    SendEnvDocuSignAPI.getEnvelopeStatus(lstgenesis_applications_Obj[0].DocuSign_EnvelopeId__c);
    SendEnvDocuSignAPI.updateDocumentFields(lstgenesis_applications_Obj[0].DocuSign_EnvelopeId__c,DSTemplate.Id);
    /*DSTemplate.State__c = 'test_state';
    update DSTemplate;
    SendEnvDocuSignAPI.sendDocuSignEnvelope(app.Id); */ 
      
    /*
  }
}*/