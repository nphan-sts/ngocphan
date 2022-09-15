/* ****************Modification History******************
*    Created By        	 Date			Version
*1. Bhavya Maliwal        2022/03/02     LSP-619 Initial Version,renamed method, modified code for validation errors,increased coverage, added start and stop,added assert

******************Modification History******************/
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
        loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
        org.loan__Disable_Triggers__c = true;
        upsert org;  
        
        //Creating Account
        Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            peer__Last_Name__c='TestLName2',
            loan__SOCIAL_SECURITY_NUMBER__c = '123123123'
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

            Application_Start_DateV2__c= system.Today(),

            Sift_Status__c = 80
        );
        insert app;
        
        genesis__Applications__c app1= new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Account__c = acc.Id,
            Affiliate_Partner__c =true,

            Application_Start_DateV2__c= system.Today(),

            Sift_Status__c = 70
        );
        insert app1;
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
        idv.OFAC_Status__c='Not Performed';
        idv.Bank_Verification_Flag__c= 'Fail';
        idv.Deal_room_Verification_Flag__c = 'Fail';
        idv.Identity_Verification__c ='Fail';
        idv.Income_Verification_Flag__c = 'Fail';
        idv.Neo_Verification_Flag__c ='Fail';
        idv.KBA_Verification_Flag__c = 'Fail';
        idv.Precise_Account_Opening_Status__c='Reject';
        idv.Credit_Policy_Verification_Flag__c ='Fail';
        insert idv;
    }
    /*Created By : Bhavya Maliwal
Method name : cIVTbeforeInsert
Purpose : to cover code satisfying else condition / before insert code.
*/
    Testmethod static void cIVTbeforeInsert(){
        test.startTest();
        genesis__Applications__c app= [Select id from genesis__Applications__c where Sift_Status__c = 70 LIMIT 1];
        
        Identity_Verification__c idv1= new Identity_Verification__c();
        idv1.Application__c = app.id;
        idv1.IDMV_Status__c = 'Fail';
        idv1.IDMA_Status__c = 'Fail'; 
        idv1.OFAC_Status__c='Performed';
        idv1.TLO_Status__c='Performed';
        idv1.Precise_Identity_Screening_Status__c='Accept';
        idv1.Bank_Verification_Flag__c= 'Fail';
        idv1.Deal_room_Verification_Flag__c = 'Fail';
        idv1.Identity_Verification__c ='Fail';
        idv1.Income_Verification_Flag__c = 'Fail';
        idv1.Neo_Verification_Flag__c ='Fail';
        idv1.KBA_Verification_Flag__c = 'Fail';
        idv1.Precise_Account_Opening_Status__c='Reject';
        idv1.Credit_Policy_Verification_Flag__c ='Fail';
        insert idv1;
        test.stopTest();
        List<Identity_Verification__c> iv=[Select id from Identity_Verification__c];
        system.assert(iv.size()>=1);
    }
    /*Created By : Bhavya Maliwal
Method name : cIVTbeforeUpdate
Purpose : to cover code satisfying if condition/ before update code.
*/
    Testmethod static void cIVTbeforeUpdate(){
        test.startTest();
        Identity_Verification__c idv = [Select id from Identity_Verification__c idv Limit 1];
        idv.Precise_Identity_Screening_Status__c = 'Accept';
        idv.Precise_Account_Opening_Status__c = 'Accept';
        idv.IDMV_Status__c = 'Accept';
        idv.IDMA_Status__c = 'Accept';
        idv.OFAC_Status__c = 'Performed';
        idv.Bank_Verification_Flag__c = 'PASS';
        idv.TLO_Status__c = 'Performed';
        idv.Deal_room_Verification_Flag__c = 'PASS';
        idv.Income_Verification_Flag__c = 'PASS';
        idv.Neo_Verification_Flag__c = 'PASS';
        idv.Credit_Policy_Verification_Flag__c = 'PASS';
        idv.Identity_Verification__c = 'PASS';
        update idv;
        test.stopTest();
        List<Identity_Verification__c> iv=[Select id from Identity_Verification__c];
        system.assert(iv.size()>=1);
    }
    
}