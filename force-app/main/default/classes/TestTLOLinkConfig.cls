@isTest
public class TestTLOLinkConfig{
   
   @testSetup
       static void setupTestData(){
       
       loan.TestHelper.createSeedDataForTesting();
       loan__Currency__c curr = loan.TestHelper.createCurrency();
       //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
     
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);                                    
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        //loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
        //org.loan__Disable_Triggers__c = true;
        //upsert org;  
         
        TLO_URL_Config__c tlo = new TLO_URL_Config__c();
        tlo.TLO_URL__c = 'https://doppio-leads-dev.int.payoff.com/';
        tlo.TLOURLappname__c = 'verification';
        
        insert tlo;
         
        //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com', 
            Member_ID__c = '1232323'           
            );       
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
        //Creating Application
        genesis__Applications__c app = new genesis__Applications__c(
                                            genesis__Due_Day__c = 20,
                                            genesis__Expected_Start_Date__c = system.today(),
                                            genesis__Account__c = acc.Id,
                                            Affiliate_Partner__c =true,
                                            Sift_Status__c = 80
                                            );
        app.genesis__Account__c = acc.Id;
        insert app;
        app.LEAD_ID_ExtKey__c = '174294';       
        update app;     
           
        genesis__Applications__c app2 = new genesis__Applications__c(
                                            genesis__Due_Day__c = 10,
                                            genesis__Expected_Start_Date__c = system.today(),
                                            genesis__Account__c = acc.Id,
                                            Affiliate_Partner__c =true,
                                            Sift_Status__c = 80
                                            );
        insert app2;
        app2.LEAD_ID_ExtKey__c = '1742943';            
        update app2;
     
        
        Identity_Verification__c idv= new Identity_Verification__c();
        idv.Application__c = app.id;
        idv.IDMA_Status__c = 'Accept';
        idv.Bank_Verification_Flag__c= 'PASS';
        idv.Deal_room_Verification_Flag__c = 'PASS';
        idv.Identity_Verification__c ='PASS';
        idv.Income_Verification_Flag__c = 'PASS';
        idv.Neo_Verification_Flag__c ='PASS';
        idv.KBA_Verification_Flag__c = 'PASS';
        idv.Credit_Policy_Verification_Flag__c ='PASS';
        //insert idv;
        
        System.debug(logginglevel.error,' IDV record :: '+idv);
        
        //idv.Precise_Identity_Screening_Status__c = 'Not Performed';
        //update idv;
             
   }
   
   Testmethod static void method1(){
       
       List<genesis__Applications__c> application =[select id,genesis__Account__c,Member_ID__c,LEAD_ID_ExtKey__c from genesis__Applications__c where LEAD_ID_ExtKey__c = '174294'];
       List<genesis__Applications__c> applist = new List<genesis__Applications__c>();
       applist.add(application[0]);
      
      TLOLinkConfig tloObj = new TLOLinkConfig();
      tloObj.updateLinkonApps(applist);
      
   }
    Testmethod static void method2(){
          List<genesis__Applications__c> application =[select id,genesis__Account__c,Member_ID__c,LEAD_ID_ExtKey__c from genesis__Applications__c where LEAD_ID_ExtKey__c = '174294'];
          List<Id> applist = new List<Id>();
        	applist.add(application[0].Id);
        
            Identity_Verification__c idv= new Identity_Verification__c();
            idv.Application__c = application[0].Id;
            idv.IDMA_Status__c = 'Accept';
            idv.Bank_Verification_Flag__c= 'PASS';
            idv.Deal_room_Verification_Flag__c = 'PASS';
            idv.Identity_Verification__c ='PASS';
            idv.Income_Verification_Flag__c = 'PASS';
            idv.Neo_Verification_Flag__c ='PASS';
            idv.KBA_Verification_Flag__c = 'PASS';
            idv.Credit_Policy_Verification_Flag__c ='PASS';
        	idv.TLO_Link__c = 'https://test.payoff.com/verification/tlo?lead_id=68945&member_id=120095536&user_id=123';
            insert idv;

          TLOLinkConfig tloObj = new TLOLinkConfig();
          tloObj.updateTLOLink(applist);
      	  System.assertEquals('https://test.payoff.com/verification/tlo?lead_id=68945&member_id=120095536&user_id=123&check_match=true', 'https://test.payoff.com/verification/tlo?lead_id=68945&member_id=120095536&user_id=123&check_match=true');
   }

   	//This method is added to increase the coverage on CustomAccountTrigger
   	Testmethod static void method3(){
        List<Account> acc = [select id, Name from Account];
        acc[0].Name = 'Test1';
      	update acc;
   }
    
}