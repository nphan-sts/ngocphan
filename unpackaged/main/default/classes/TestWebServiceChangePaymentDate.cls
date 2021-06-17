/* ****************Modification History*****************************************************************
 * 
 * Modified by              Date        JIRA number
 * 1.   Pallavi/Neha      2020/12/11  CRM-1056 CPD issue/Reverting issue (short-term fix) - Case #02430069 
 ******************Modification History*****************************************************************/
@isTest
private class TestWebServiceChangePaymentDate{

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
        
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        loan__Org_Parameters__c org = loan__Org_Parameters__c.getOrgDefaults();
         org.loan__Disable_Triggers__c = true;
         upsert org;  
   
        //Creating Account
         Account acc = new Account(
            Name = 'Test',
            loan__Investor__c=False,
            cnotify__Email__c = 'abc@test.com',
            loan__SOCIAL_SECURITY_NUMBER__c = '123'
            );
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
         //Creating Application
        genesis__Applications__c app= new genesis__Applications__c(
                                            genesis__Due_Day__c = 20,
                                            genesis__Expected_First_Payment_Date__c = system.Today(),
                                            genesis__Expected_Start_Date__c = system.Today(),
                                            genesis__Funding_in_Tranches__c = true,
                                            Borrower_s_Email__c = null,
                                            genesis__Account__c = acc.Id,
                                            Application_Start_DateV2__c = system.Today(),
                                            DocuSignFlag__c=true,
                                            genesis__Status__c = 'agent_verified',
                                            genesis__Draw_Period_End_Date__c = system.Today()
                                            );
        insert app;
        System.assertEquals(null,app.Borrower_s_Email__c,'Borrower Email is not null');
        
        loan__Loan_Product__c loanProdObj = new loan__Loan_Product__c(name='TestProduct'); 
        insert loanProdObj;
        System.assertEquals('TestProduct', loanProdObj.Name,'Wrong Loan Product');
        
        
        loan__Loan_Account__c lacc = new loan__Loan_Account__c(
                                            loan__Account__c= acc.Id,
                                            loan__Product_Type__c='Flexible Amz Loan',
                                            loan__Loan_Amount__c =1000,
                                            loan__Loan_Status__c = 'Active - Good Standing',
                                            loan__Loan_Product_Name__c=loanProdObj.Id,
                                            loan__Payment_Amount__c=100, 
                                            loan__Next_Installment_Date__c=system.today(), 
                                            loan__Previous_Installment_Date__c= system.today(),
                                            loan__Maturity_Date_Current__c = system.today().addDays(10)
                                            );
        insert lacc; 
        
        /*clcommon__Repayment_Plan__c rplan = new clcommon__Repayment_Plan__c();
        rplan.loan__Loan_Account__c = lacc.id;
        rplan.genesis__Application__c=app.id;
        rplan.clcommon__Due_Day__c = 5;
        rplan.clcommon__Frequency__c ='Monthly';
        rplan.clcommon__Payment_Start_Date__c = system.today();
        rplan.clcommon__Payment_Amount__c = 1200;
        rplan.clcommon__Number_Of_Payments__c = 10;
        rplan.clcommon__Payment_Type__c = 'Interest Only';
        insert rplan;*/
       }
       Testmethod static void method1(){
            loan__Loan_Account__c lapp = [SELECT ID, 
                                                    loan__Previous_Installment_Date__c,
                                                    loan__Account__r.cnotify__Email__c,
                                                    loan__Loan_Product_Name__r.name, 
                                                    loan__Payment_Amount__c, 
                                                    loan__Next_Installment_Date__c, 
                                                    loan__Account__r.ID,Borrowers_First_Name__c,
                                                    loan__Account__r.Borrower_s_Last_Name__c,
                                                    loan__Loan_Product_Name__c 
                                                    from loan__Loan_Account__c Limit 1];
        
        Date dt = date.newInstance(2015,12,12);
        Map<String,object> reqMap = new Map<String,object>(); 
        reqMap.put('loanid',lapp.Id);
        reqMap.put('paymentDate',dt);
        String jsonStr= JSON.serialize(reqMap);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/selectedoffer';
        req.requestBody = Blob.valueOf(jsonStr);
        req.httpMethod = 'POST';
                
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        WebServiceChangePaymentDate.ChangePaymentDate();
        
        Test.stopTest();
    }   
    
    Testmethod static void method2(){
            loan__Loan_Account__c lapp = [SELECT ID, 
                                                    loan__Previous_Installment_Date__c,
                                                    loan__Account__r.cnotify__Email__c,
                                                    loan__Loan_Product_Name__r.name, 
                                                    loan__Payment_Amount__c, 
                                                    loan__Next_Installment_Date__c, 
                                                    loan__Account__r.ID,Borrowers_First_Name__c,
                                                    loan__Account__r.Borrower_s_Last_Name__c,
                                                    loan__Loan_Product_Name__c 
                                                    from loan__Loan_Account__c Limit 1];
        
        
        
       
    }
    /*CRM-1056*/
    Testmethod static void method3(){
            loan__Loan_Account__c lapp = [SELECT ID, 
                                                    loan__Previous_Installment_Date__c,
                                                    loan__Account__r.cnotify__Email__c,
                                                    loan__Loan_Product_Name__r.name, 
                                                    loan__Payment_Amount__c, 
                                                    loan__Next_Installment_Date__c, 
                                                    loan__Account__r.ID,Borrowers_First_Name__c,
                                                    loan__Account__r.Borrower_s_Last_Name__c,
                                                    loan__Loan_Product_Name__c 
                                                    from loan__Loan_Account__c Limit 1];
        
        loan__Loan_account_Due_Details__c futureBill = new loan__Loan_account_Due_Details__c(loan__Loan_Account__c = lapp.id,
                                                                                             loan__Payment_Satisfied__c = false,
                                                                                             loan__DD_Primary_Flag__c = true,
                                                                                             loan__Due_Date__c = System.today().addDays(1));
        insert futureBill;
        
        Date dt = date.newInstance(2015,12,12);
        Map<String,object> reqMap = new Map<String,object>(); 
        reqMap.put('loanid',lapp.Id);
        reqMap.put('paymentDate',dt);
        String jsonStr= JSON.serialize(reqMap);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/selectedoffer';
        req.requestBody = Blob.valueOf(jsonStr);
        req.httpMethod = 'POST';
                
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        WebServiceChangePaymentDate.ChangePaymentDate();
        
        Test.stopTest();
     }
     /*CRM-1056*/   
}