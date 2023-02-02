@isTest
public class TestCustomIdentityVerificationTrigger{
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
        
        loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
         org.loan__Disable_Triggers__c = true;
         upsert org;  
         
        //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123456789',
            peer__Last_Name__c = 'LastName',
            peer__First_Name__c = 'FirstName'
            );
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
        //Creating Application
        genesis__Applications__c app= new genesis__Applications__c(
                                            genesis__Due_Day__c = 20,
                                            genesis__Expected_First_Payment_Date__c = system.Today(),
                                            genesis__Expected_Start_Date__c = system.Today(),
                                            genesis__Account__c = acc.Id,
                                            Affiliate_Partner__c =true,
                                            Sift_Status__c = 80
                                            );
        insert app;
        
        
        KBA_Details__c kba = new KBA_Details__c();
        kba.Application__c = app.id;
        kba.Precise_ID_Overall_SCore__c =9012;
        kba.Precise_ID_First_Payment_Default__c =9012;
        kba.Precise_ID_ID_Theft__c =9012;
        kba.Precise_ID_Validation__c =9012;
        kba.Precise_ID_General_Fraud_Shield_Indicat__c = 'F05';
        kba.KBA_Attempts__c = 5;
        kba.Paste_Count__c = 2;
        kba.Id_Analytics_Score__c =760;
        kba.Precise_ID_Adverse_Action_Code__c='R90';
        insert kba;
        
        Identity_Verification__c idv= new Identity_Verification__c();
        idv.Application__c = app.id;
        idv.IDMV_Status__c = 'Fail';
        idv.IDMA_Status__c = 'Fail';
        idv.Bank_Verification_Flag__c= 'Fail';
        idv.Deal_room_Verification_Flag__c = 'Fail';
        idv.Identity_Verification__c ='Fail';
        idv.Income_Verification_Flag__c = 'Fail';
        idv.Neo_Verification_Flag__c ='Fail';
        idv.KBA_Verification_Flag__c = 'Fail';
        idv.Credit_Policy_Verification_Flag__c ='Fail';
        insert idv;
        

        
       
   }
   Testmethod static void method1(){
       Identity_Verification__c idv = [Select id from Identity_Verification__c idv Limit 1];
       idv.Precise_Identity_Screening_Status__c = 'Accept';
        update idv;
   }
   Testmethod static void method2(){
       Identity_Verification__c idv = [Select id from Identity_Verification__c idv Limit 1];
       idv.Precise_Account_Opening_Status__c = 'Accept';
        update idv;
   }
   Testmethod static void method3(){
       Identity_Verification__c idv = [Select id from Identity_Verification__c idv Limit 1];
       idv.IDMV_Status__c = 'Accept';
        update idv;
   }
   Testmethod static void method4(){
       Identity_Verification__c idv = [Select id from Identity_Verification__c idv Limit 1];
       idv.IDMA_Status__c = 'Accept';
        update idv;
   }
   Testmethod static void method5(){
       Identity_Verification__c idv = [Select id from Identity_Verification__c idv Limit 1];
       idv.OFAC_Status__c = 'Performed';
        update idv;
   }
   Testmethod static void method6(){
       Identity_Verification__c idv = [Select id from Identity_Verification__c idv Limit 1];
       idv.Bank_Verification_Flag__c = 'PASS';
        update idv;
   }
   Testmethod static void method8(){
       Identity_Verification__c idv = [Select id from Identity_Verification__c idv Limit 1];
       idv.TLO_Status__c = 'Performed';
        update idv;
   }
   Testmethod static void method9(){
       Identity_Verification__c idv = [Select id from Identity_Verification__c idv Limit 1];
       idv.Deal_room_Verification_Flag__c = 'PASS';
        update idv;
   }
   Testmethod static void method10(){
       Identity_Verification__c idv = [Select id from Identity_Verification__c idv Limit 1];
       idv.Income_Verification_Flag__c = 'PASS';
        update idv;
   }
   Testmethod static void method11(){
       Identity_Verification__c idv = [Select id from Identity_Verification__c idv Limit 1];
       idv.Neo_Verification_Flag__c = 'PASS';
        update idv;
    }
    Testmethod static void method12(){

        Account acc = new Account(
            Name = 'Test2',
            loan__Investor__c=False,
            cnotify__Email__c = '2abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123456780',
            peer__Last_Name__c = '2LastName',
            peer__First_Name__c = '2FirstName'
            );
        insert acc;
        System.assertEquals('Test2',acc.Name,'Wrong Account');
        
        //Creating Application
        genesis__Applications__c app= new genesis__Applications__c(
                                            genesis__Due_Day__c = 20,
                                            genesis__Expected_First_Payment_Date__c = system.Today(),
                                            genesis__Expected_Start_Date__c = system.Today(),
                                            genesis__Account__c = acc.Id,
                                            Affiliate_Partner__c =true,
                                            Sift_Status__c = 80
                                            );
        insert app;
        
        
        KBA_Details__c kba = new KBA_Details__c();
        kba.Application__c = app.id;
        kba.Precise_ID_Overall_SCore__c =9012;
        kba.Precise_ID_First_Payment_Default__c =9012;
        kba.Precise_ID_ID_Theft__c =9012;
        kba.Precise_ID_Validation__c =9012;
        kba.Precise_ID_General_Fraud_Shield_Indicat__c = 'F05';
        kba.KBA_Attempts__c = 5;
        kba.Paste_Count__c = 2;
        kba.Id_Analytics_Score__c =760;
        kba.Precise_ID_Adverse_Action_Code__c='R90';
        insert kba;
        
        Identity_Verification__c idv= new Identity_Verification__c();
        idv.Application__c = app.id;
        idv.IDMV_Status__c = 'Fail';
        idv.IDMA_Status__c = 'Fail';
        idv.Bank_Verification_Flag__c= 'Fail';
        idv.Deal_room_Verification_Flag__c = 'Fail';
        idv.Identity_Verification__c ='Fail';
        idv.Income_Verification_Flag__c = 'Fail';
        idv.Neo_Verification_Flag__c ='Fail';
        idv.KBA_Verification_Flag__c = 'Fail';
        idv.Credit_Policy_Verification_Flag__c ='Fail';
        idv.Precise_Identity_Screening_Status__c = 'Accept';
        insert idv;
    }
}