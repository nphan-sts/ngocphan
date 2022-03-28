/* ****************Modification History******************
 * Modified By        Date          JIRA number
 *1. Bhanupriya		2022/03/03		LSP-592
 ******************Modification History******************/

@isTest
private class TestPrepaidFeeCalculator{
    
    	//Create testsetup() 
    	@testsetup()
    public static void testsetup(){
        
        loan.TestHelper.createSeedDataForTesting();
       	loan__Currency__c curr = loan.TestHelper.createCurrency();
       //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
     
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);                                    
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        system.debug('Fee Junction '+dummyFeeJunction);
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        system.debug('Dummy Office'+dummyOffice);
        loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
        org.loan__Disable_Triggers__c = true;
        upsert org; 
   
        //Creating Account
         Account acc = new Account(
                            Name = 'Test',
                            loan__Investor__c=False,
                            //Borrower_s_Last_Name__c='Testborrower',
                            cnotify__Email__c = 'abc@test.com',
                            peer__Last_Name__c = 'Test Last Name',			//LSP-592
                            loan__SOCIAL_SECURITY_NUMBER__c = '123456789'				//LSP-592
                            );
        	insert acc;
        
        
        loan__Loan_Product__c loanProdObj = new loan__Loan_Product__c(name='TestProduct'); 
        insert loanProdObj;
             
        //create loan account
        loan__Loan_Account__c lacc = new loan__Loan_Account__c(
                                            loan__Account__c= acc.Id,
                                            loan__Product_Type__c='Flexible Amz Loan',
                                            loan__Loan_Amount__c =1000,
                                            peer__Origination_Fee__c =100,
                                            loan__Loan_Product_Name__c=loanProdObj.Id,
                                          	loan__Payment_Amount__c=100, 
                                            loan__Next_Installment_Date__c=system.today(), 
                                            loan__Previous_Installment_Date__c= system.today()
                                            );
        insert lacc; 
       
    }

    Testmethod static void method1(){
        				
       				loan__Fee__c dummyFee = [select id from loan__Fee__c];
        			loan__Loan_Account__c lacc = [select id,peer__Origination_Fee__c from loan__Loan_Account__c];
        			test.startTest();
        			PrepaidFeeCalculator prepaidFee = new PrepaidFeeCalculator();
                    prepaidFee.computeFee(dummyFee,lacc);
                    test.stopTest(); 
        			list<loan__Loan_Account__c> loans =[SELECT id,peer__Origination_Fee__c FROM loan__Loan_Account__c];
        			system.assert(loans[0].peer__Origination_Fee__c!=null);
                    
       }
}