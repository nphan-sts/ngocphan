@isTest
public class MW_PricingOfferTriggerTest {
    
    @testSetup static void Testsetup(){
        Account acc = MW_GlobalTestUtility.GetAccount('Member');
        insert acc;
        
        genesis__Applications__c app = MW_GlobalTestUtility.GetApplication();
        app.genesis__Account__c = acc.Id;
        insert app;
        
    }
        static testmethod void insertOffer(){
            genesis__Applications__c app1 = [select id, name from genesis__Applications__c];
            test.startTest();
            Pricing_Offer__c POffer = MW_GlobalTestUtility.getPricingOffer('t1');
            POffer.Application__c = app1.id;
            insert POffer;
            test.stopTest();
            
        }
        static testmethod void updateOffer(){
            genesis__Applications__c app1 = [select id, name from genesis__Applications__c];
            
            Pricing_Offer__c POffer2 = MW_GlobalTestUtility.getPricingOffer('t2');
            POffer2.Application__c = app1.id;
            insert POffer2;
            test.startTest();
            update POffer2;
            test.stopTest();
        }
        
    }