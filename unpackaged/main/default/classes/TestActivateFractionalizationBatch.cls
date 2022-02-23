/* ****************Modification History******************
*    Created By        	 Date			Version
*1. Bhavya Maliwal        2022/02/16    LSP-546 Initial Version

******************Modification History******************/
@isTest
private class TestActivateFractionalizationBatch{

   public static String CRON_EXP = '0 0 0 15 3 ? 2022';
   @testSetup static void setup() {
   
       loan.TestHelper.createSeedDataForTesting();
       //pallavi
        MigrationPhase__c phase = new MigrationPhase__c();
        phase.name = 'phase1';
        phase.phase__c = 'phase1';
        insert phase;
        //pallavi
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
             peer__Last_Name__c='TestLName2',
            //Borrower_s_Last_Name__c='Testborrower',
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123123123'
            );
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
        LoanPaymentDays__c lpdays = new LoanPaymentDays__c();
        lpdays.AutoPaymentRemainder__c= 3;
        lpdays.ManualPaymentRemainder__c= 5;
        insert lpdays;
        
        loan__Loan_Product__c loanProdObj = new loan__Loan_Product__c(name='TestProduct'); 
        insert loanProdObj;
        System.assertEquals('TestProduct', loanProdObj.Name,'Wrong Loan Product');
        
        
        loan__Loan_Account__c lacc = new loan__Loan_Account__c(
                                            loan__Account__c= acc.Id,
                                            loan__Product_Type__c='Flexible Amz Loan',
                                            loan__Loan_Amount__c =1000,
                                            loan__Loan_Product_Name__c=loanProdObj.Id,
                                            loan__Payment_Amount__c=100, 
                                            loan__Next_Installment_Date__c=system.today(), 
                                            loan__Previous_Installment_Date__c= system.today()
                                            );
        insert lacc; 
        
        
        
   }
     /*Created By : Bhavya Maliwal
Method name : ActivateFractionalizationBatch_SetofLoanIds_Constructor
Purpose : to cover code satisfying constructor where Set of loan Ids is passed and for Batch execution,  for ActivateFractionalizationBatch
*/
   Testmethod static void ActivateFractionalizationBatch_SetofLoanIds_Constructor(){
        List<loan__Loan_Account__c> lappList = [SELECT ID, 
                                                    loan__Previous_Installment_Date__c,
                                                    loan__Account__r.cnotify__Email__c,
                                                    loan__Loan_Product_Name__r.name, 
                                                    loan__Payment_Amount__c, 
                                                    loan__Next_Installment_Date__c, 
                                                    loan__Account__r.ID,Borrowers_First_Name__c,
                                                    loan__Account__r.Borrower_s_Last_Name__c,
                                                    loan__Loan_Product_Name__c 
                                                    from loan__Loan_Account__c];
                                                    
        System.debug('==============lapp=============='+lappList);
        test.startTest();
        Set<Id> Idset = new Set<Id>();
        for(loan__Loan_Account__c lc : lappList){
            Idset.add(lc.id);
        }
        ActivateFractionalizationBatch job = new ActivateFractionalizationBatch(Idset);
        Database.QueryLocator ql = job.start(null);
        job.execute(null,lappList);
        ID batchprocessid = Database.executeBatch(job);
        job.finish(null);
       
        test.stopTest();
    }
     /*Created By : Bhavya Maliwal
Method name : ActivateFractionalizationBatch_default_Constructor
Purpose : to cover code satisfying default constructor and Batch execution for ActivateFractionalizationBatch
*/
     Testmethod static void ActivateFractionalizationBatch_default_Constructor(){
        List<loan__Loan_Account__c> lappList = [SELECT ID, 
                                                    loan__Previous_Installment_Date__c,
                                                    loan__Account__r.cnotify__Email__c,
                                                    loan__Loan_Product_Name__r.name, 
                                                    loan__Payment_Amount__c, 
                                                    loan__Next_Installment_Date__c, 
                                                    loan__Account__r.ID,Borrowers_First_Name__c,
                                                    loan__Account__r.Borrower_s_Last_Name__c,
                                                    loan__Loan_Product_Name__c 
                                                    from loan__Loan_Account__c];
                                                    
        System.debug('==============lapp=============='+lappList);
        test.startTest();
      ActivateFractionalizationBatch b = new ActivateFractionalizationBatch();
        test.stopTest();
    }
     /*Created By : Bhavya Maliwal
Method name : InvestorAllocation_runInvestorAllocationBasedOnWeighting
Purpose : to cover code satisfying constructor where thread is passed and for Batch execution, for ActivateFractionalizationBatch
*/
     Testmethod static void ActivateFractionalizationBatch_thread_Constructor(){
        List<loan__Loan_Account__c> lappList = [SELECT ID, 
                                                    loan__Previous_Installment_Date__c,
                                                    loan__Account__r.cnotify__Email__c,
                                                    loan__Loan_Product_Name__r.name, 
                                                    loan__Payment_Amount__c, 
                                                    loan__Next_Installment_Date__c, 
                                                    loan__Account__r.ID,Borrowers_First_Name__c,
                                                    loan__Account__r.Borrower_s_Last_Name__c,
                                                    loan__Loan_Product_Name__c 
                                                    from loan__Loan_Account__c];
                                                    
        System.debug('==============lapp=============='+lappList);
        test.startTest();
        ActivateFractionalizationBatch b1 = new ActivateFractionalizationBatch(1);
       test.stopTest();
    }

}