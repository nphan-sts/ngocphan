/* ****************Modification History******************
*    Created By        	 Date			Version
*1. Bhavya Maliwal        2022/07/07     Initial Version

******************Modification History******************/
@isTest
Private class TestCustomBankAccountHandler {
    /*Created By : Bhavya Maliwal
Method name : inactiveAPS
Purpose : to cover code satisfying if Bank Account gets inactive the corresponding APS gets inactive ; for CustomBankAccountHandler
*/
    @isTest static Void inactiveAPS(){
        loan__Bank_Account__c bankAccount=new loan__Bank_Account__c();
        bankAccount.Account_Number__c='2345678755699';
        bankAccount.Unmasked_Bank_Account_Number__c='30983456787346';
        bankAccount.loan__Active__c=true;
        bankAccount.loan__Routing_Number__c='245765432';
        bankAccount.loan__Bank_Name__c='hdfc';
        insert bankAccount;
        
        loan__Automated_Payment_Setup__c aps=new loan__Automated_Payment_Setup__c();
        aps.loan__Active__c=true;
        aps.loan__Bank_Account__c=bankAccount.id;
        aps.loan__Transaction_Amount__c=1221;
        
        insert aps;
        test.startTest();
        bankAccount.loan__Active__c=false;
        test.stopTest();
        loan__Automated_Payment_Setup__c apscheck=[Select id,loan__Active__c from loan__Automated_Payment_Setup__c
                                                   where loan__Bank_Account__c=:bankAccount.id limit 1];
        system.assert(!apscheck.loan__Active__c);
    }
    
}