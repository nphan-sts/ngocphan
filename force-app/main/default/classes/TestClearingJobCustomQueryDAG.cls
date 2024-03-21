@isTest
private class TestClearingJobCustomQueryDAG{
    Testmethod static void method1(){
        loan.TestHelper.createSeedDataForTesting();
        //Create Currency...
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        string job = 'LPTclearingjob';
        //Create a dummy MF_Account... 
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('AccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('IncAccountForTest','30000 - INCOME');
        
        //Create a Fee,Fee Set and link them...
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);                                    
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        
        //Create Company...
        loan__Office_Name__c dummyCompany = loan.TestHelper.createOffice();
        
        User loggedUser = [select Id, Name,username, 
                           CompanyName,
                           loan__Current_Branch__c
                           from User where Id = :UserInfo.getUserId()];
        
        //User Compnay Assignment...
        loan__User_Branch_Info__c userCompany = new loan__User_Branch_Info__c();
        
        userCompany.loan__Branch__c = dummyCompany.id;
        userCompany.loan__Default_Branch__c = True;
        userCompany.loan__User__c = loggedUser.id;
        insert userCompany;
        LoanPaymentTxnClearingJobCustomQueryDAG.getCustomQuery(job);
    }
}