/* ****************Modification History******************
 * Created By        Date          JIRA number
 * 		
 * 		1. Neha          2021/01/10        LOP-4
 * Modified By        Date          JIRA number
 *      1. Pallavi       2021/01/25        LOP-4
 *      
 ******************Modification History******************/
global class YodleeDeactivateAccountsBatch implements Database.Batchable<sObject>,Schedulable,Database.AllowsCallouts {
   
    String query;
    /*LOP-4 update*/
    Expiry_Date__c expiryDate =  Expiry_Date__c.getInstance();
    List<String> AppStatus = expiryDate.Application_Status_to_deactivate_Yodlee__c.split(',');	
    List<String> LoanStatus = expiryDate.Loan_Status_to_deactivate_Yodlee__c.split(',');
    String yodleeStatus = 'Active';	
    /*LOP-4 update*/
    	String CSD = String.valueof(new loan.GlobalLoanUtilFacade().getCurrentSystemDate());
   
    Date currentSystemDate = (new loan.GlobalLoanUtilFacade().getCurrentSystemDate());   
    Set<String> YodleeAccountId = new Set<String>();
    Set<Id> accId = new Set<Id>();
    //List<String> skipLoanStatus = System.Label.Application_Expired_Status.split(',');
       
    
    global YodleeDeactivateAccountsBatch(Set<String> YodleeAccId, Set<Id> accountId){
        
        YodleeAccountId = YodleeAccId;
        accId = accountId;
        System.debug('accId : '+accId);
        
        query = 'Select id,Yodlee_Account__c,YodleeBankAccountId__c from Yodlee_User_Account__c where YodleeBankAccountId__c in: YodleeAccountId and Yodlee_Account__c in : accId and ((Yodlee_Application__r.Yodlee_Acc_expiry_Date__c < '+ CSD + ' AND Yodlee_Application__r.genesis__Status__c in : AppStatus) OR Yodlee_Application__r.CL_Contract_Status__c in : LoanStatus) and status__c = \'' +yodleeStatus+ '\' ';   //LOP-4 update	                     
        System.debug('Query : '+query);   
    
    }
    
    global YodleeDeactivateAccountsBatch(){
        
         /*LOP-4 update(to increase test coverage)*/
        if(test.isRunningTest())
            CSD = String.valueOf(System.today());
         /*LOP-4 update*/
        System.debug('CSD----' + CSD);
        
        query = 'Select id,Yodlee_Account__c,YodleeBankAccountId__c from Yodlee_User_Account__c where ((Yodlee_Application__r.Yodlee_Acc_expiry_Date__c < '+ CSD + ' AND Yodlee_Application__r.genesis__Status__c in : AppStatus) OR (Yodlee_Application__r.CL_Contract_Status__c in : LoanStatus)) and status__c = \'' +yodleeStatus+ '\' ';            //LOP-4 update                   
        System.debug('Query :: '+query);   
    }
    
    global void execute(SchedulableContext sc) {        
        YodleeDeactivateAccountsBatch b = new YodleeDeactivateAccountsBatch();
        Database.executeBatch(b,1);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        System.debug('In Database.QueryLocator : '+query);          
        return Database.getQueryLocator(query);
    }
        
    global void execute(Database.BatchableContext bc,List<sObject> scope){
    
        List<Yodlee_User_Account__c> listOfYodleeAcc = (List<Yodlee_User_Account__c>)scope;
     
        for(Yodlee_User_Account__c  acc : listOfYodleeAcc){
          
            YodleeDeactivateAccounts y = new YodleeDeactivateAccounts();
            y.deactivateAccount(acc.YodleeBankAccountId__c,acc.Yodlee_Account__c);

        }
       
    }
    
    global void finish(Database.BatchableContext bc){
        System.debug('in finish method');
    }    
}