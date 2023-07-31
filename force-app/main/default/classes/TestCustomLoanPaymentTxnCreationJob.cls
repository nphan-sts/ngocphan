@isTest
public class TestCustomLoanPaymentTxnCreationJob {
    
     @isTest
     public static void Testone(){
        
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Account_External_ID__c = 'Test';
        insert acc;
        
        loan__loan_account__c loanAccount = CreateLoanContract(acc.id);
        
        System.debug('Loan Account --' + loanAccount);
        loanAccount.loan__Account__c = acc.Id;
        loanAccount.loan__Loan_Status__c = 'Active - Good Standing';
        update loanAccount;
        System.debug('Loan Account 2--' + loanAccount);
        
        Test.startTest();
        
        /*Batch_Size_for_NACHA_file_gen__c batchSize = new Batch_Size_for_NACHA_file_gen__c();
        batchSize.Batch_Size__c = 500;
        insert batchSize;*/
        
        Try{
        CustomLoanPaymentTxnCreationJobScheduler sh = new CustomLoanPaymentTxnCreationJobScheduler(200);
        
        String sch = '0 10 14 * * ?'; 
        system.schedule('CustomLoanPaymentTxnCreationJob', sch,sh); 
      }
      Catch(exception e){}
        
        Test.stopTest();
    }
    
    public static Loan__loan_account__c CreateLoanContract(id accId){
        
        loan.TestHelper.createSeedDataForTesting();
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
        return loanContract;
    }
}