@isTest
public class TestRegenerateTIL {
    
    public static testMethod void testWF_tilRegenerate(){
        
        genesis__Org_Parameters__c cso = new genesis__Org_Parameters__c(genesis__Disable_Triggers__c = true);
        insert cso;
        
        Account account_Obj = MW_GlobalTestUtility.GetAccount('Member');
        Insert account_Obj; 
        
        Account investor_Obj = MW_GlobalTestUtility.GetAccount('Investor');
        Insert investor_Obj; 
        
        CL_Document__c cs = new CL_Document__c();
        cs.Doc1__c = 'Credit Score Notice';
        cs.Doc2__c = 'TIL Document';
        cs.Doc3__c = 'Adverse Action Document';
        cs.UploadedBOX__c = 'UploadedBOX';
        insert cs;
        
        cso.genesis__Disable_Triggers__c = false;
        update cso;
        
        genesis__Applications__c genesis_applications_Obj = new genesis__Applications__c(
            genesis__Due_Day__c = 20,
            genesis__Expected_First_Payment_Date__c = system.Today(),
            genesis__Expected_Start_Date__c = system.Today(),
            genesis__Funding_in_Tranches__c = true,
            genesis__Account__c = account_Obj.Id,        
            Application_Start_DateV2__c = system.Today(),
            genesis__Status__c = 'Default Documents',
            genesis__Draw_Period_End_Date__c = system.Today(),
            Employment_Status__c = 'Full Time',
            Investor__c = investor_Obj.Id
        );      
        Insert genesis_applications_Obj; 
        
        cso.genesis__Disable_Triggers__c = true;
        update cso;
        
        Test.startTest();
        RegenerateTIL.WF_tilRegenerate(new List<Id>{genesis_applications_Obj.Id});
        Test.stopTest();
        
        CL_Document__c testDoc = [SELECT Id,Name,Doc2__c FROM CL_Document__c WHERE Id=:cs.Id LIMIT 1];
        System.assertEquals(testDoc.Doc2__c,'TIL Document');

    }
    
}