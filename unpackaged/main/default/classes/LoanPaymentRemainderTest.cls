/* ****************Modification History******************
 * Updated By        Date				Jira Number		 
 *1. Bhanupriya       2022/03/30     	LSP-636	(add required fields ,add comments, add assert statement )
 ******************Modification History******************/

@isTest
private class LoanPaymentRemainderTest{

   public static String cron_EXP = '0 0 0 15 3 ? ';
    //create testsetup
   @testSetup static void setup() {
   
       loan.TestHelper.createSeedDataForTesting();
       loan__Currency__c curr = loan.TestHelper.createCurrency();
       //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
     
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);                                    
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        system.debug('Dummy Fee Junction'+dummyFeeJunction);
       //dummy Office
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        system.debug('Dummy Office'+dummyOffice);
       //Org Parameters
        loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
         org.loan__Disable_Triggers__c = true;
         upsert org;  
   
        //Creating Account
         Account acc = new Account(
                        Name = 'Test',
                        loan__Investor__c=False,
                        cnotify__Email__c = 'abc@test.com',
                        peer__Last_Name__c = 'Test Last Name',				//LSP-636 required field
                        loan__SOCIAL_SECURITY_NUMBER__c = '123456789'			//LSP-636 must be 9 digit
                        );
         insert acc;
        
       //create Loan payment days
        LoanPaymentDays__c lpdays = new LoanPaymentDays__c();
        lpdays.AutoPaymentRemainder__c= 3;
        lpdays.ManualPaymentRemainder__c= 5;
        insert lpdays;
       //create loan product
        loan__Loan_Product__c loanProdObj = new loan__Loan_Product__c(name='TestProduct'); 
        insert loanProdObj;
        
        Date csd = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
        
       //create dummy loan account
        loan__Loan_Account__c lacc = new loan__Loan_Account__c(
                                            loan__Account__c= acc.Id,
                                            loan__Product_Type__c='Flexible Amz Loan',
                                            loan__Loan_Amount__c =1000,
                                            loan__Loan_Product_Name__c=loanProdObj.Id,
                                            loan__Payment_Amount__c=100, 
                                            loan__Next_Installment_Date__c=system.today(), 
                                            loan__Previous_Installment_Date__c= csd.adddays(3)
                                            );
        insert lacc;        
        
   }
    //test method for loan Payment
   Testmethod static void loanPaymentRemainderBatch_UseCase1(){
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
        
        LoanPaymentRemainder job = new LoanPaymentRemainder();
        Database.QueryLocator ql = job.start(null);
        job.execute(null,lappList);
        ID batchprocessid = Database.executeBatch(job);
        job.finish(null);
    	  String jobIdLDTAdd = System.schedule('LoanPaymentRemainder',
                            cron_EXP, 
                            new LoanPaymentRemainder());
        System.assert(batchprocessid!=null);
        test.stopTest();
       system.assert(jobIdLDTAdd!=null);
       system.debug(ql);
    }
    
      //test method
   Testmethod static void loanPaymentRemainderBatch_UseCase2(){
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
       	string Query ='SELECT ID, loan__Previous_Installment_Date__c,loan__Account__r.cnotify__Email__c,loan__Loan_Product_Name__r.name, loan__Payment_Amount__c, loan__Next_Installment_Date__c,loan__Account__r.Borrower_s_Last_Name__c,loan__Loan_Product_Name__c from loan__Loan_Account__c';

        test.startTest();
        
        LoanPaymentRemainder job = new LoanPaymentRemainder(Query);
        Database.QueryLocator ql = job.start(null);
        job.execute(null,lappList);
        ID batchprocessid = Database.executeBatch(job);
        job.finish(null);
    	 String jobIdLDTAdd = System.schedule('LoanPaymentRemainder',
                            cron_EXP, 
                            new LoanPaymentRemainder());
        System.assert(batchprocessid!=null);
        test.stopTest();
       	system.debug(ql);
        system.assert(jobIdLDTAdd!=null);
    }
  
     
}