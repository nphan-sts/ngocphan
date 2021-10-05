@isTest
public class TestCustomAutoWriteOffDynamicJob{
 
      
  @testSetup static void methodName() {
      
       Account acc = new Account();
        acc.Name = 'Test Account';
        acc.peer__Last_Name__c = 'test last name';
        acc.Account_External_ID__c = 'Test';
        insert acc;
        System.assertEquals('Test',acc.Name,'Wrong Account');
        
        loan__loan_account__c loanAccount = CreateLoanContract(acc.id);
        
        System.debug('Loan Account --' + loanAccount);
        loanAccount.loan__Account__c = acc.Id;
        loanAccount.loan__Loan_Status__c = 'Active - Good Standing';
        update loanAccount;
      
        system.assertNotEquals(loanAccount.id,null,'LoanAccount not inserted');
        System.debug('Loan Account 2--' + loanAccount);
  }
    
    
    public static testMethod void test1(){
        list<loan__Loan_Account__c> acc1 = [select id,name,loan__Interest_Remaining__c,Skip_AutoWriteOff__c,loan__Principal_Remaining__c,loan__Invalid_Data__c,loan__Loan_Balance__c,loan__Number_of_Days_Overdue__c from loan__Loan_Account__c where loan__Number_of_Days_Overdue__c != null AND loan__Invalid_Data__c=false AND Skip_AutoWriteOff__c=false];
  
        Test.StartTest();
        
        CustomAutowriteoffDynamicJob job = new CustomAutowriteoffDynamicJob();
        Database.executebatch(job,1);
        //job.initialize();
        job.execute(null,acc1);
        job.finish(null);
       Test.stopTest();
       loan__loan_account__c loan =  [select id,loan__Loan_Status__c,name,loan__Interest_Remaining__c,Skip_AutoWriteOff__c,loan__Principal_Remaining__c,loan__Invalid_Data__c,loan__Loan_Balance__c,loan__Number_of_Days_Overdue__c from loan__Loan_Account__c where loan__Number_of_Days_Overdue__c != null AND loan__Invalid_Data__c=false AND Skip_AutoWriteOff__c=false];
           //System.assertEquals(true, loan.Skipped_a_Pay__c);
            System.assertEquals('Testloan', loan.name);
            System.assertEquals(2, loan.loan__Interest_Remaining__c);
            System.assertEquals(False,loan.Skip_AutoWriteOff__c);
            System.assertEquals(2000, loan.loan__Principal_Remaining__c);
            System.assertEquals(False, loan.loan__Invalid_Data__c);
            //System.assert(1000.00,loan.loan__Loan_Balance__c);
            System.assertEquals(2, loan.loan__Number_of_Days_Overdue__c);
            System.assertEquals('Active - Bad Standing',loan.loan__Loan_Status__c);
        
       
    }
    
    
    
     public static testmethod void test2(){
         
        test.startTest();
           
           string  query = 'select id,name,loan__Interest_Remaining__c,Skip_AutoWriteOff__c,loan__Principal_Remaining__c,loan__Invalid_Data__c,loan__Loan_Balance__c,loan__Number_of_Days_Overdue__c from loan__Loan_Account__c where loan__Number_of_Days_Overdue__c != null AND loan__Invalid_Data__c=false AND Skip_AutoWriteOff__c=false';
              CustomAutowriteoffDynamicJob  dm = new CustomAutowriteoffDynamicJob(query);
              Database.executeBatch(dm);
              dm.execute(null);
              dm.finish(null);
              test.StopTest();
           loan__loan_account__c loan =  [select id,loan__Loan_Status__c,name,loan__Interest_Remaining__c,Skip_AutoWriteOff__c,loan__Principal_Remaining__c,loan__Invalid_Data__c,loan__Loan_Balance__c,loan__Number_of_Days_Overdue__c from loan__Loan_Account__c where loan__Number_of_Days_Overdue__c != null AND loan__Invalid_Data__c=false AND Skip_AutoWriteOff__c=false];
           //System.assertEquals(true, loan.Skipped_a_Pay__c);
            System.assertEquals('Testloan', loan.name);
            System.assertEquals(2, loan.loan__Interest_Remaining__c);
            System.assertEquals(False,loan.Skip_AutoWriteOff__c);
            System.assertEquals(2000, loan.loan__Principal_Remaining__c);
            System.assertEquals(False, loan.loan__Invalid_Data__c);
            //System.assert(1000.00,loan.loan__Loan_Balance__c);
            System.assertEquals(2, loan.loan__Number_of_Days_Overdue__c);
            System.assertEquals('Active - Good Standing',loan.loan__Loan_Status__c);
           
    }
    
    
    public static Loan__loan_account__c CreateLoanContract(id accId){
        
        loan.TestHelper.createSeedDataForTesting();
       
        Loan.TestHelper.systemDate = Date.today();
        //List<filegen__File_Metadata__c> metadata = Test.loadData(filegen__File_Metadata__c.sObjectType,'TestMetaData');
        loan.TestHelper.setupMultiplePaymentModeACH();
        loan.TestHelper2.createFileGenMetaData();        
        loan__Org_Parameters__c orgParams = loan.CustomSettingsUtil.getOrgParameters();
        orgParams.loan__Enable_New_Spread_Option__c = true;
        orgParams.loan__Draw_Amortization_Schedule__c = true;
        //orgParams.loan__Rounding_Mode__c ='ROUNDING MODE NEAREST';
        orgParams.loan__Concurrent_BatchJobs__c = 8;
        //orgParams.Payment_Job_Days__c = 20;
        update(orgParams);
        loan__Transaction_Approval_Config__c txnApprovalParams = loan.CustomSettingsUtil.getApprovalConfig();
        txnApprovalParams.loan__Payment__c = true; 
        txnApprovalParams.loan__Write_Off__c = false;
        upsert(txnApprovalParams);
        loan__ACH_Parameters__c achParams = loan.CustomSettingsUtil.getACHParameters();
        achParams.loan__Multiple_Payment_Method_Support__c = true;
        upsert(achParams);
       
        //Create Currency...
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        
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
        
        //Create a Client
        loan__Client__c dummyClient = loan.TestHelper.createClient(dummyCompany);
        
        //Create a dummy Loan Product...
        loan__Loan_Product__c dummyLoanLP = loan.TestHelper.createLoanProduct(dummyCompany,
                                                                              dummyAccount, 
                                                                              curr, 
                                                                              dummyFeeSet);
        dummyLoanLP.Name = 'Regular Loan';
        dummyLoanLP.loan__Minimum_Amount_Due_Type__c = 'Percent';
        system.assertEquals(dummyLoanLP.Name, 'Regular Loan','Dummy loan created');
        update dummyLoanLP;
        
        //Company Product Assignment...
        loan__Branch_Loan_Product__c branchProduct = new loan__Branch_Loan_Product__c();
        branchProduct.loan__Branch__c = dummyCompany.id;
        branchProduct.loan__Loan_Product__c = dummyLoanLP.Id;
        insert branchProduct;
        
        Contact con = genesis.TestHelper.createContact();
        
        //Create Loan Purpose...
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        
        Loan__loan_account__c loanContract = new loan__loan_account__c();
        
        Date da = date.today();
        
        loanContract.loan__Account__c = accId;
        loanContract.loan__Loan_Purpose__c=dummyLoanPurpose.id;
        loanContract.loan__Fee_Set__c = dummyFeeSet.id;
        loanContract.loan__Loan_Product_Name__c = dummyLoanLP.id;
        loanContract.OwnerId = loggedUser.id;
        loanContract.loan__Branch__c = dummyClient.id;
        loanContract.loan__Overdue_Interest_Rate__c=12; 
        loanContract.loan__Frequency_of_Loan_Payment__c='Monthly'; 
        loanContract.loan__Client__c = dummyClient.id;
        loanContract.loan__First_Installment_Date__c= da.addMonths(1); 
        loanContract.loan__Expected_Disbursal_Date__c=da; 
        loanContract.loan__Repayment_Tied_to_Meeting_Schedule__c=false; 
        loanContract.loan__Repayment_Procedure__c='Equal Monthly Installments'; 
        loanContract.loan__Interest_Calculation_Method__c='Declining Balance'; 
        loanContract.loan__Expected_Repayment_Start_Date__c=da.addMonths(1); 
        loanContract.loan__Contractual_Due_Day__c=3; 
        loanContract.loan__Due_Day__c=3; 
        loanContract.loan__Next_Due_Generation_Date__c=da.addMonths(1); 
        loanContract.loan__Next_Installment_Date__c=da.addMonths(1); 
        loanContract.loan__Last_Installment_Date__c=da.addYears(1); 
        loanContract.loan__Maturity_Date_Current__c=da.addYears(1); 
        loanContract.loan__la_next_amortization_date__c=da; 
        loanContract.loan__LA_Amortization_Enabled__c=true; 
        loanContract.loan__LA_Amortized_Balance_Type__c='Interest'; 
        loanContract.loan__LA_Amortization_Frequency__c='Monthly'; 
        loanContract.loan__Delinquency_Grace_Days__c=10; 
        loanContract.loan__Interest_Remaining__c=0;
        loanContract.loan__Loan_Amount__c =1000;
        loanContract.loan__Number_of_Days_Overdue__c = 91; 
        loanContract.loan__Excess__c=0;
        loanContract.loan__Delinquent_Amount__c=0; 
        loanContract.loan__Pmt_Amt_Cur__c=1200; 
        loanContract.loan__Branch__c=dummyCompany.id; 
        loanContract.loan__Oldest_Due_Date__c=da.addMonths(1); 
        loanContract.loan__Term_Cur__c=12;  
        loanContract.loan__Disbursal_Date__c=da; 
        loanContract.loan__Last_Accrual_Date__c=da; 
        loanContract.loan__Loan_Status__c='Active - Good Standing';
        
        insert loanContract;
        System.assertEquals(loanContract.loan__Loan_Status__c,'Active - Good Standing');
        return loanContract;
    }
}